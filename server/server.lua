local registeredStashes = {}
local ox_inventory = exports.ox_inventory
local count_bagpacks = 0
local countbagpacks = 0

local function GenerateText(num)
	local str
	repeat
		str = {}
		for i = 1, num do str[i] = string.char(math.random(65, 90)) end
		str = table.concat(str)
	until str ~= 'POL' and str ~= 'EMS'
	return str
end

local function GenerateSerial(text)
	if text and text:len() > 3 then
		return text
	end
	return ('%s%s%s'):format(math.random(100000, 999999), text == nil and GenerateText(3) or text,
		math.random(100000, 999999))
end

RegisterServerEvent('unr3al_backpack:openBackpack')
AddEventHandler('unr3al_backpack:openBackpack', function(identifier, bagtype)
	bagtype = bagtype
	if not registeredStashes[identifier] then
		ox_inventory:RegisterStash(bagtype .. '_' .. identifier, Config.Backpacks[bagtype].Label,
			Config.Backpacks[bagtype].Slots, Config.Backpacks[bagtype].Weight, false)
		registeredStashes[identifier] = true
	end
end)

lib.callback.register('unr3al_backpack:getNewIdentifier', function(source, slot, bagtype)
	bagtype = bagtype
	local newId = GenerateSerial()
	ox_inventory:SetMetadata(source, slot, { identifier = newId })
	ox_inventory:RegisterStash(bagtype .. '_' .. newId, Config.Backpacks[bagtype].Label, Config.Backpacks[bagtype].Slots,
		Config.Backpacks[bagtype].Weight, false)
	registeredStashes[newId] = true
	return newId
end)


CreateThread(function()
	while GetResourceState('ox_inventory') ~= "started" do
		Wait(500)
	end
	if Config.Debug then print("Inventory Started") end

	local swaphook = ox_inventory:registerHook('swapItems', function(payload)
		local count_bagpacks = 0
		local fromInv, toInv, move_type = payload.fromInventory, payload.toInventory, payload.toType
		
		for vbag in pairs(Config.Backpacks) do
			count_bagpacks = count_bagpacks + ox_inventory:GetItemCount(payload.source, vbag, nil, false)
		end
		if Config.Debug then
			print("Count: " .. count_bagpacks)
			print("Toinv: " .. toInv)
			print("fromInv: "..fromInv)
			print("From inv name: "..payload.fromSlot.name)
			print("Movetype: " .. move_type)
		end

		if string.find(toInv, 'bag') and string.find(payload.fromSlot.name, 'bag') then
			TriggerClientEvent('ox_lib:notify', payload.source,
				{ type = 'error', title = Strings.action_incomplete, description = Strings.backpack_in_backpack })
			return false
		end

		if Config.OneBagInInventory then
			if (move_type == "player" and count_bagpacks > 0 and string.find(payload.fromSlot.name, 'bag')) then
				if fromInv ~= toInv then
					TriggerClientEvent('ox_lib:notify', payload.source,
					{ type = 'error', title = Strings.action_incomplete, description = Strings.one_backpack_only })
					return false
				end
			end
		end

		--[[
		if Config.OneBagInInventory then
			for vbag in pairs(Config.Backpacks) do
				if (move_type == 'player' and count_bagpacks > 0) then
					if (payload.fromSlot.name == vbag) then
						if fromInv ~= toInv then
							TriggerClientEvent('ox_lib:notify', payload.source,
							{ type = 'error', title = Strings.action_incomplete, description = Strings.one_backpack_only })
							return false
						end
					end

				end
			end
		end
--]]
		return true
	end, {
		print = true,
		Config.Filter
	})
end)

local buyHook = exports.ox_inventory:registerHook('buyItem', function(payload)
	local countbagpacks = 0
	local inventoryId = payload.inventoryId

	if (Config.OneBagInInventory) then
		for vbag, _ in pairs(Config.Backpacks) do
			countbagpacks = countbagpacks + ox_inventory:GetItem(payload.source, vbag, nil, true)
		end
		
		for vbag in pairs (Config.Backpacks) do
			if (countbagpacks > 0 and payload.itemName == vbag) then
				TriggerClientEvent('ox_lib:notify', payload.source,
				{ type = 'error', title = Strings.action_incomplete, description = Strings.one_backpack_only })
			return false
			end
		end
	end
--[[
	if (countbagpacks > 0 and string.find(payload.fromSlot.name, 'bag')) then
		TriggerClientEvent('ox_lib:notify', payload.source,
			{ type = 'error', title = Strings.action_incomplete, description = Strings.one_backpack_only })
		return false
	end
	--]]
	return true
end, {
	print = true,
	Config.Filter
})


AddEventHandler('onResourceStop', function()
	ox_inventory:removeHooks(swapHook)
	ox_inventory:removeHooks(buyHook)
end)

if Config.Framework == 'ESX' then
	ESX = exports["es_extended"]:getSharedObject()
	RegisterServerEvent('unr3al_backpack:save')
	AddEventHandler('unr3al_backpack:save', function(skin)
		local src = source
		local xPlayer = ESX.GetPlayerFromId(src)

		MySQL.update('UPDATE users SET skin = @skin WHERE identifier = @identifier', {
			['@skin'] = json.encode(skin),
			['@identifier'] = xPlayer.identifier
		})
	end)
elseif Config.Framework == 'ND' then


elseif Config.Framework == 'OX' then
elseif Config.Framework == 'QB' then
end
