local bagEquipped, skin = nil, nil
local CurrentBag = nil
local ox_inventory = exports.ox_inventory
local ped = cache.ped
local count = 0
local timeout, changed, puttedon = false, false, false

local function PutOnBag(bagtype)
    bagtype = bagtype
    if Config.Debug then print("Putting on Backpack") end
    if Config.Debug then print("Bag type: " .. bagtype) end
    if Config.Framework == 'ESX' then
        TriggerEvent('skinchanger:getSkin', function(skin)
            if skin.sex == 0 then
                TriggerEvent('skinchanger:loadClothes', skin, Config.Backpacks[bagtype].Uniform.Male)
            else
                TriggerEvent('skinchanger:loadClothes', skin, Config.Backpacks[bagtype].Uniform.Female)
            end
            saveSkin()
        end)
    elseif Config.Framework == 'ND' then
        local appearance = fivemAppearance:getPedAppearance(cache.ped)
    end
    bagEquipped, CurrentBag = true, bagtype
end

saveSkin = function()
    Wait(100)
    if Config.Framework == 'ESX' then
        TriggerEvent('skinchanger:getSkin', function(skin)
            TriggerServerEvent('unr3al_backpack:save', skin)
        end)
    end
end

local function RemoveBag()
    if Config.Debug then print("Removing Backpack") end
    if Config.Framework == 'ESX' then
        TriggerEvent('skinchanger:getSkin', function(skin)
            local clothesWithoutBag
            if skin.sex == 0 then
                clothesWithoutBag = Config.Backpacks[CurrentBag].CleanUniform.Male
            else
                clothesWithoutBag = Config.Backpacks[CurrentBag].CleanUniform.Female
            end
            TriggerEvent('skinchanger:loadClothes', skin, clothesWithoutBag)
            saveSkin()
            bagEquipped = nil
        end)
    end
end

function tableChange(data)
    local count = 0
    for vbag in pairs(Config.Backpacks) do
        count = ox_inventory:Search('count', vbag)
        if count > 0 then
            if count >= 1 and bagEquipped == nil then
                PutOnBag(vbag)
                if Config.Debug then
                    print("Count: " .. count)
                end
            end
        end
    end
end

function boolChange()
    local count = 0

    for vbag in pairs(Config.Backpacks) do
        count = count + ox_inventory:Search('count', vbag)
    end

    if count > 0 and bagEquipped == true then
        if count >= 1 then
            PutOnBag(vbag)
            if Config.Debug then
                print("Count: " .. count)
            end
        end
    elseif count == 0 and bagEquipped then
        RemoveBag(vbag)
    end
end

AddEventHandler('ox_inventory:updateInventory', function(changed)
    print(tostring(changed))
    for k, v in pairs(changed) do
        if type(v) == 'table' and not timeout then
            timeout = true
            print("Tablechange")
            tableChange(v)
            timeout = false
        elseif type(v) == 'boolean' and not timeout then
            boolChange()
            print("boolChange")
        end
    end
end)

lib.onCache('ped', function(value)
    ped = value
end)

function CountBackpacksInInventory()
    local count = 0
    for vbag in pairs(Config.Backpacks) do
        count = count + ox_inventory:Search('count', vbag)
    end
    return count
end

lib.onCache('vehicle', function(value)
    if GetResourceState('ox_inventory') ~= 'started' then return end
    local count = CountBackpacksInInventory()
    if value then
        RemoveBag()
    elseif count >= 1 then
        PutOnBag(CurrentBag)
    end
end)


AddEventHandler('playerDropped', function(reason)
    RemoveBag()
end)

for kbag in pairs(Config.Backpacks) do
    local bagtype = kbag
    exports('openBackpack_' .. bagtype, function(data, slot)
        if Config.Debug then print("Export " .. bagtype .. " Triggered") end
        if not slot?.metadata?.identifier then
            local identifier = lib.callback.await('unr3al_backpack:getNewIdentifier', 100, data.slot, bagtype)
            ox_inventory:openInventory('stash', bagtype .. '_' .. identifier)
            if Config.Debug then print("Registered new identifier") end
        else
            TriggerServerEvent('unr3al_backpack:openBackpack', slot.metadata.identifier, bagtype)
            ox_inventory:openInventory('stash', bagtype .. '_' .. slot.metadata.identifier)
            if Config.Debug then print("Triggering open backpack") end
        end
    end)
end
