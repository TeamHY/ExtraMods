

function TSIL.__EnableInternalCallback(id)
	local foundInternalCallback = nil

	for _, internalVanillaCallback in ipairs(TSIL.__INTERNAL_CALLBACKS) do
		if internalVanillaCallback.Id == id then
			foundInternalCallback = internalVanillaCallback
		end
	end

	if not foundInternalCallback then return end
	if foundInternalCallback.Enabled then return end

	foundInternalCallback.Enabled = true
	TSIL.__MOD:AddPriorityCallback(
		foundInternalCallback.Callback,
		foundInternalCallback.Priority - 10000,
		foundInternalCallback.Funct,
		foundInternalCallback.OptionalParam
	)
end


function TSIL.__DisableInternalCallback(id)
	local foundInternalCallback = nil

	for _, internalVanillaCallback in ipairs(TSIL.__INTERNAL_CALLBACKS) do
		if internalVanillaCallback.Id == id then
			foundInternalCallback = internalVanillaCallback
		end
	end

	if not foundInternalCallback then return end
	if not foundInternalCallback.Enabled then return end

	foundInternalCallback.Enabled = false
	TSIL.__MOD:RemoveCallback(
		foundInternalCallback.Callback,
		foundInternalCallback.Funct
	)
end