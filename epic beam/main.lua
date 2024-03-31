local json = require "json"

local mod = RegisterMod("EpicBeam", 1)

local libFolder = "library_of_isaac"
local LOCAL_TSIL = require(libFolder .. ".TSIL")
LOCAL_TSIL.Init(libFolder)

local threeSoundId = Isaac.GetSoundIdByName("Epic1")
local fourSoundId = Isaac.GetSoundIdByName("Epic2")

-- 투명도 설정
local alpha = 1 -- (0.1 ~ 1) 까지 편하신대로 설정 하시면 됩니다 0일 경우 출력 안됨

-- 볼륨 설정
local volume = 0.6 -- (0.1 ~ 1) 까지 편하신대로 설정 하시면 됩니다 0일 경우 출력 안됨

-- 지속 프레임
local duration = 2.2 * 30 -- 오른쪽 30 은 건들지 마시고, 왼쪽 숫자만 건드시면 됩니다 10 * 30 -> 10초동안 에픽 애니메이션 출력

-- 장면당 프레임 (숫자가 낮을수록 빠름)
local speed = 1.1

local blackList = {
    CollectibleType.COLLECTIBLE_MOMS_BRA,
    CollectibleType.COLLECTIBLE_MOMS_PAD,
}

mod.Data = {
    History = {}
}

mod:AddPriorityCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    CallbackPriority.IMPORTANT,
    ---@param isContinued boolean
    function(_, isContinued)
        if mod:HasData() then
            local raw = mod:LoadData()
            local data = json.decode(raw)

            mod.Data = data or {
                History = {}
            }
        end

        if not isContinued then
            mod.Data.History = {}
        end
    end
)

mod:AddPriorityCallback(
    ModCallbacks.MC_PRE_GAME_EXIT,
    CallbackPriority.LATE,
    ---@param shouldSave boolean
    function(_, shouldSave)
        mod:SaveData(json.encode(mod.Data))
    end
)

---@type {pickup: EntityPickup, sprite: Sprite, prevFrame: integer, endFrame: integer}[]
local nowPlayings = {}

mod:AddCallback(
    ModCallbacks.MC_POST_UPDATE,
    function(_)
        for _, target in ipairs(nowPlayings) do
            local frameCount = Game():GetFrameCount()

            if target.prevFrame + speed < frameCount then
                target.sprite:Update()
                target.prevFrame = frameCount
            end
        end
    end
)

mod:AddCallback(
    ModCallbacks.MC_POST_RENDER,
    function(_)
        local removeIndexs = {}

        for i, target in ipairs(nowPlayings) do
            if target.pickup:Exists() and target.pickup.SubType ~= 0 and Game():GetFrameCount() < target.endFrame then
                target.sprite:Render(Isaac.WorldToRenderPosition(target.pickup.Position + Vector(0, -40)), Vector(0, 0), Vector(0, 0))
            else
                table.insert(removeIndexs, i)
            end
        end

        for _, value in ipairs(removeIndexs) do
            table.remove(nowPlayings, value)
        end
    end
)

---@return Sprite
local function CreateEpicSprite()
    local sprite = Sprite()
    sprite:Load("gfx/effects/epic.anm2", true)
    sprite.Color = Color(1, 1, 1, alpha, 0, 0, 0)
    sprite:Play("Play", true)

    return sprite
end

---@param list any[]
---@param value any
---@return integer
local function FindIndex(list, value)
    for i, v in ipairs(list) do
        if v == value then
            return i
        end
    end

    return -1
end

local function IsDeathCertificateRoom()
    local level = Game():GetLevel()
    local roomName = level:GetCurrentRoomDesc().Data.Name
    
    if roomName == "Death Certificate" then
        return true
    end

    return false
end

mod:AddCallback(
    ModCallbacks.MC_POST_PICKUP_INIT,
    ---@param pickup EntityPickup
    function(_, pickup)
        if pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE then
            local quality = Isaac.GetItemConfig():GetCollectible(pickup.SubType).Quality

            if Game():GetLevel():GetCurses() & LevelCurse.CURSE_OF_BLIND == 0 and not IsDeathCertificateRoom() then
                if FindIndex(blackList, pickup.SubType) == -1 and FindIndex(mod.Data.History, pickup.SubType) == -1 and quality >= 3 then
                    pickup:GetData().ShowEpic = true
                end
            end
        end
    end
)

mod:AddCallback(
    ModCallbacks.MC_POST_PICKUP_RENDER,
    ---@param pickup EntityPickup
    ---@param renderOffset Vector
    function(_, pickup, renderOffset)
        local data = pickup:GetData()

        if data.ShowEpic then
            local roomType = Game():GetLevel():GetCurrentRoom():GetType()
            local stageType = Game():GetLevel():GetStageType()

            print(TSIL.Collectibles.IsBlindCollectible(pickup))

            if not (roomType == RoomType.ROOM_TREASURE and (stageType == StageType.STAGETYPE_REPENTANCE or stageType == StageType.STAGETYPE_REPENTANCE_B) and TSIL.Collectibles.IsBlindCollectible(pickup)) then
                local quality = Isaac.GetItemConfig():GetCollectible(pickup.SubType).Quality
                local frameCount = Game():GetFrameCount()

                table.insert(nowPlayings, { pickup = pickup, sprite = CreateEpicSprite(), prevFrame = frameCount, endFrame = frameCount + duration })

                SFXManager():Play(quality == 3 and threeSoundId or fourSoundId, volume)

                table.insert(mod.Data.History, pickup.SubType)
            end

            data.ShowEpic = false
        end
    end
)
