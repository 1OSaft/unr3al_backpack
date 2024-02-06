Config = {}
Config.OneBagInInventory = true
Config.checkForUpdates = true -- Check for updates?
Config.Debug = false
Config.Framework = 'ESX' -- QB, ND, ESX
Config.Filter = { -- Items not allowed in your bags
    itemFilter = {
        bag1 = true,
        bag2 = true
    }
}

Config.CleanUniform = {
    Male = {
        ['bags_1'] = 0,
        ['bags_2'] = 0
    },
    Female = {
        ['bags_1'] = 0,
        ['bags_2'] = 0
    }

}

Config.Backpacks = {
    ['bag1'] = {
        Slots = 35,
        Weight = 20000,
        Label = 'Backpack',
        Uniform = {
            Male = {
                ['bags_1'] = 41,
                ['bags_2'] = 0,
            },
            Female = {
                ['bags_1'] = 41,
                ['bags_2'] = 0,
            }
        },
    },
    ['bag2'] = {
        Slots = 15,
        Weight = 5000,
        Label = 'Backpack',
        Uniform = {
            Male = {
                ['bags_1'] = 41,
                ['bags_2'] = 0,
            },
            Female = {
                ['bags_1'] = 41,
                ['bags_2'] = 0,
            }
        },
    },
}

Strings = { -- Notification strings
    action_incomplete = 'Action Incomplete',
    one_backpack_only = 'You can only have 1x backpack!',
    backpack_in_backpack = 'You can\'t place a backpack within another!',

}
