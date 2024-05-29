local datastring = LoadResourceFile(GetCurrentResourceName(), "database.json")
database = json.decode(datastring)

---@param data table
saveDatabase = function(data)
    SaveResourceFile(GetCurrentResourceName(), "database.json", json.encode(data, { indent = true }), -1)
end

---@param identifier string
---@return boolean
getBagCountPlayerHas = function(identifier)
    if not database[identifier] then
        database[identifier] = false
        saveDatabase(database)
    end

    return database[identifier]
end

---comment
---@param identifier string
givePlayerBag = function(identifier)
    database[identifier] = true
    saveDatabase(database)
end
removePlayerBag = function(identifier)
    database[identifier] = false
    saveDatabase(database)
end