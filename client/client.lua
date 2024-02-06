local bagEquipped, skin
local ox_inventory = exports.ox_inventory
local ped = cache.ped
local count = 0
local timeout, changed, puttedon = false, false, false
local PlayerState = LocalPlayer.state

local function PutOnBag(bagtype)
    bagtype = bagtype
    if Config.Debug then print("Putting on Backpack") end
    if Config.Debug then print("Bag type: "..bagtype) end
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
    PlayerState:set('backpack', true)
end

saveSkin = function()
    Wait(100)

    TriggerEvent('skinchanger:getSkin', function(skin)
        TriggerServerEvent('unr3al_backpack:save', skin)
    end)
end
--[[
local function RemoveBag(bagtype)
    bagtype = bagtype
    if Config.Debug then print("Removing Backpack") end
    TriggerEvent('skinchanger:getSkin', function(skin)
        if skin.sex == 0 then
            TriggerEvent('skinchanger:loadClothes', skin, Config.Backpacks[bagtype].CleanUniform.Male)
        else
            TriggerEvent('skinchanger:loadClothes', skin, Config.Backpacks[bagtype].CleanUniform.Female)
        end
        saveSkin()
        bagEquipped = nil
    end)
end
--]]

AddStateBagChangeHandler('backpack', nil, function(bagName, _, backItems, _, replicated)
    if replicated then
        return
    end
end)

local function RemoveBag(bagtype)
    bagtype = bagtype
    if Config.Debug then print("Removing Backpack") end
    TriggerEvent('skinchanger:getSkin', function(skin)
        local clothesWithoutBag
        if skin.sex == 0 then56
            clothesWithoutBag = Config.CleanUniform.Male
        else
            clothesWithoutBag = Config.CleanUniform.Female
        end
        TriggerEvent('skinchanger:loadClothes', skin, clothesWithoutBag)
        saveSkin()
        PlayerState:set('backpack', false)
    end)
end

function tableChange(data)
    local count = 0

    for vbag in pairs(Config.Backpacks) do
        count = ox_inventory:Search('count', vbag)
        local bag = PlayerState.backpack
        if count > 0 and bag == false then
            if count >= 1 then
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
    local bag = PlayerState.backpack
    if count > 0 and bag == false then
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
    if changed then return end
    for k, v in pairs(changed) do
        if type(v) == 'table' and not timeout then
            timeout = true
            tableChange(v)
            timeout = false
        elseif type(v) == 'boolean' and not timeout then
            boolChange()
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
        PutOnBag(bagtype)
    end
end)

for kbag in pairs(Config.Backpacks) do
    local bagtype = kbag
    exports('openBackpack_'..bagtype, function(data, slot)
        if Config.Debug then print("Export "..bagtype.." Triggered") end
        if not slot?.metadata?.identifier then
            local identifier = lib.callback.await('unr3al_backpack:getNewIdentifier', 100, data.slot, bagtype)
            ox_inventory:openInventory('stash', bagtype..'_'..identifier)
            if Config.Debug then print("Registered new identifier") end
        else
            TriggerServerEvent('unr3al_backpack:openBackpack', slot.metadata.identifier, bagtype)
            ox_inventory:openInventory('stash', bagtype..'_'..slot.metadata.identifier)
            if Config.Debug then print("Triggering open backpack") end
        end
    end)
end
