local json = require "json"

local mod = RegisterMod("ActiveDimerit", 1)

local speedDown = 0.1

local tearsDown = 0.3

local damageDown = 0.5

local rangeDown = 0.5

local shotSpeedDown = 0.1

mod.Data = {
    Count = 0,
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
                Count = 0
            }
        end

        if not isContinued then
            mod.Data.Count = 0
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

mod:AddCallback(
    ModCallbacks.MC_USE_ITEM,
    ---@param collectibleID CollectibleType
    ---@param rngObj RNG
    ---@param playerWhoUsedItem EntityPlayer
    ---@param useFlags UseFlag
    ---@param activeSlot ActiveSlot
    ---@param varData integer
    function(_, collectibleID, rngObj, playerWhoUsedItem, useFlags, activeSlot, varData)
        mod.Data.Count = mod.Data.Count + 1

        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
        
            player:AddCacheFlags(CacheFlag.CACHE_ALL)
            player:EvaluateItems()
        end
    end
)

--- Credit to Xalum(Retribution), _Kilburn and DeadInfinity
function mod:AddTears(baseFiredelay, tearsUp)
    local currentTears = 30 / (baseFiredelay + 1)
    local newTears = currentTears + tearsUp

    if newTears <= tearsDown then
        return (30 / (currentTears % tearsDown)) - 1
    end

    local newFiredelay = math.max((30 / newTears) - 1, -0.75)

    return newFiredelay
end

mod:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if cacheFlag == CacheFlag.CACHE_SPEED then
            player.MoveSpeed = player.MoveSpeed - mod.Data.Count * speedDown
        elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
            player.MaxFireDelay = mod:AddTears(player.MaxFireDelay, mod.Data.Count * -tearsDown)
        elseif cacheFlag == CacheFlag.CACHE_DAMAGE then
            player.Damage = player.Damage - mod.Data.Count * damageDown
        elseif cacheFlag == CacheFlag.CACHE_RANGE then
            player.TearRange = player.TearRange - mod.Data.Count * rangeDown * 40
        elseif cacheFlag == CacheFlag.CACHE_SHOTSPEED then
            player.ShotSpeed = player.ShotSpeed - mod.Data.Count * shotSpeedDown
        end
    end
)
