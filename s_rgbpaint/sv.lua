--Convars--
--If you dont use ESX put your own notifications in replace of prints
enableESX = false --Allows saving colours & item
enableItem = false --Must have "enableESX = true" on both client and server // Allows using item
enableCommand = true --Allows to paint and remove paint with command (Maybe shouldn't be used without permission checks / items)
Item = 'spraycan' --Itemname used for painting (Must have both convars above on true, on both client and server)
removePaintItem = 'spraycan2' ----Itemname used for removing colour (Must have both convars above on true, on both client and server)
--Make sure itemnames match on server + client
--Convars end--

if enableESX then
    ESX = nil 
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
end

if enableCommand then
    RegisterCommand('paintvehicle', function(source)
        if source ~= nil then
            TriggerClientEvent('s_paint:chooseColor', source)
        end
    end)

    RegisterCommand('paintvehicle', function(source)
        if source ~= nil then
            TriggerClientEvent('s_paint:removeColor', source)
        end
    end)
end

if enableESX then

    --Registering Event to save vehicle--
    RegisterServerEvent('s_paint:refreshOwnedVehicle') --If you use this, you should implement some sort of security in here
    AddEventHandler('s_paint:refreshOwnedVehicle', function(vehicleProps)
        local s = source
        local xPlayer = ESX.GetPlayerFromId(s)
        MySQL.Async.fetchAll('SELECT vehicle FROM owned_vehicles WHERE plate = @plate', {
            ['@plate'] = vehicleProps.plate
        }, function(result)
            if result[1] then
                local vehicle = json.decode(result[1].vehicle)
                if vehicleProps.model == vehicle.model then
                    MySQL.Async.execute('UPDATE owned_vehicles SET vehicle = @vehicle WHERE plate = @plate', {
                        ['@plate'] = vehicleProps.plate,
                        ['@vehicle'] = json.encode(vehicleProps)
                    })
                else
                    print('Models do not match!')
                end
            end
        end)
    end)

    --Creating Items
    if enableItem then
        ESX.RegisterUsableItem('spraycan', function(source)--add job checks etc what u want
            if source ~= nil then
                TriggerClientEvent("s_paint:chooseColor", source)
            end
        end)

        ESX.RegisterUsableItem('spraycan2', function(source) --add job checks etc what u want
            if source ~= nil then
                TriggerClientEvent("s_paint:removeColor", source)
            end
        end)
    end

    --Removing Item
    RegisterServerEvent('s_paint:removeItem', function(useditem)
        local xPlayer = ESX.GetPlayerFromId(source)
        if source ~= nil then
            if useditem == Item or useditem == removePaintItem then
                xPlayer.removeInventoryItem(item, 1)
            else
                print(GetPlayerName(source), 'tried to remove something else..?', useditem)
            end
        end
    end)
end



--Example log: 
--Logging(3424143, 'Spraypaints', '**'..GetPlayerName(source)..'** used spraypaint!', 'serverLog')

local webhook = 'ENTER WEBHOOK'
function Logging(color, name, message, footer)
    local embed = {
          {
              ["color"] = color,
              ["title"] = "**".. name .."**",
              ["description"] = message,
              ["footer"] = {
            	["text"] = footer,
              },
          }
      }
    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
end