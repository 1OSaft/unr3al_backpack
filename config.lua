Config = {}

Config.checkForUpdates = true -- Check for updates?
Config.Debug = true
Config.Framework = 'ESX' --Only supports 'ESX' at the moment

Config.OneBagInInventory = true



Config.Backpacks = {
    ['bag1'] = { --item name needs to have 'bag' in it to work properly
        Label = 'Backpack',
        Slots = 35,
        Weight = 20000,
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
        CleanUniform = {
            Male = {
                ['bags_1'] = 0,
                ['bags_2'] = 0,
            },
            Female = {
                ['bags_1'] = 0,
                ['bags_2'] = 0,
            }
        }
    },
    ['bag2'] = {
        Label = 'Backpack',
        Slots = 15,
        Weight = 5000,
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
        CleanUniform = {
            Male = {
                ['bags_1'] = 0,
                ['bags_2'] = 0,
            },
            Female = {
                ['bags_1'] = 0,
                ['bags_2'] = 0,
            }
        }
    },
}

Strings = { -- Notification strings
    action_incomplete = 'Action Incomplete',
    one_backpack_only = 'You can only have 1x backpack!',
    backpack_in_backpack = 'You can\'t place a backpack within another!',
}
