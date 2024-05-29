local registeredStashes = {}
local ox_inventory = exports.ox_inventory
local count_bagpacks = 0
local countbagpacks = 0
local bagList = {}

local swapHook, buyHook

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
	for vbag in pairs(Config.Backpacks) do
		table.insert(bagList, vbag)
	end

	if Config.Debug then print("Inventory Started") end

	swapHook = ox_inventory:registerHook('swapItems', function(payload)
		local player = ESX.GetPlayerFromId(payload.source)
		local fromInv, toInv, move_type = payload.fromInventory, payload.toInventory, payload.toType


		if move_type == 'player' and (fromInv ~= toInv) and (lib.table.contains(bagList, payload.fromSlot.name)) then
			if Config.OneBagInInventory then
				local hasBag = getBagCountPlayerHas(player.identifier)
				if hasBag then
					TriggerClientEvent('ox_lib:notify', payload.source,
					{ type = 'error', title = Strings.action_incomplete, description = Strings.one_backpack_only })
					return false
				else
					givePlayerBag(player.identifier)
				end
			end
		end
		if move_type == 'stash' and string.find(toInv, 'bag') and string.find(payload.fromSlot.name, 'bag') then
			TriggerClientEvent('ox_lib:notify', payload.source,
				{ type = 'error', title = Strings.action_incomplete, description = Strings.backpack_in_backpack })
			return false
		end
		if Config.OneBagInInventory then
			if toInv ~= payload.source then
				removePlayerBag(player.identifier)
				return true
			end
		end
		return true
	end, {
		print = Config.Debug,
	})
	if Config.OneBagInInventory then
		buyHook = exports.ox_inventory:registerHook('buyItem', function(payload)
			local player = ESX.GetPlayerFromId(payload.source)
			local hasBag = getBagCountPlayerHas(player.identifier)
			if hasBag and lib.table.contains(bagList, payload.itemName) then
				TriggerClientEvent('ox_lib:notify', payload.source,
				{ type = 'error', title = Strings.action_incomplete, description = Strings.one_backpack_only })
				return false
			elseif not hasBag and lib.table.contains(bagList, payload.itemName) then
				givePlayerBag(player.identifier)
			end
			return true
		end, {
			print = Config.Debug,
		})
	
	end
end)


AddEventHandler('onResourceStop', function()
	ox_inventory:removeHooks(swapHook)
	if Config.OneBagInInventory then
		ox_inventory:removeHooks(buyHook)
	end
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
