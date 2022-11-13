--Convars--
--If you dont use ESX put your own notifications in replace of prints
enableESX = false --Allows saving colours & item
enableItem = false --Must have "enableESX = true" on both client and server // Allows using item
Item = 'spraycan' --Itemname used for painting (Must have both convars above on true, on both client and server)
removePaintItem = 'spraycan2' ----Itemname used for removing colour (Must have both convars above on true, on both client and server)
--Make sure itemnames match on server + client
--Convars end--

if enableESX then
	ESX = nil
	Citizen.CreateThread(function()
		while ESX == nil do
			TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
			Citizen.Wait(0)
		end
	end)
end


RegisterNetEvent('s_paint:removeColor', function()
	nearveh = GetClosestVehicle(GetEntityCoords(PlayerPedId()), 2.000, 0, 70)
	if nearveh ~= 0 then
		if enableESX then --Saves database // Yoink vehicleprop table from somewhere like ESX funcs to implement prop saving yourself
			myCar = ESX.Game.GetVehicleProperties(vehicle)
			TriggerServerEvent('s_paint:refreshOwnedVehicle', myCar)
		end
		local r = 40
		local g = 40
		local b = 40
		RemovePaint(r,g,b, nearveh)
	else
		if enableESX then
			ESX.ShowNotification('Ei ajoneuvoa lähellä')
		else
			print('No vehicles close')
		end
	end
end)

RegisterNetEvent('s_paint:chooseColor', function()
	nearveh = GetClosestVehicle(GetEntityCoords(PlayerPedId()), 2.000, 0, 70)
    if nearveh ~= 0 then
		maxLength = 3
		AddTextEntry('FMMC_KEY_TIP8', "Set vehicle colour [~r~R~s~]")
		DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP8", "", "", "", "", "", maxLength)
		--TriggerEvent('mythic_notify:client:SendAlert', { type = 'inform', text = 'Choose R = 0 - 255', lenght = 10000 })
		while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
			Citizen.Wait( 0 )
		end

		local colorR = GetOnscreenKeyboardResult()
		local r = colorR
		if tonumber(colorR) ~= nil and tonumber(colorR) >= 0 and tonumber(colorR) <= 255 then --Punainen väri valittu
			maxLength = 3
			AddTextEntry('FMMC_KEY_TIP8', "Set vehicle colour [~g~G~s~]")
			DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP8", "", "", "", "", "", maxLength)
			--TriggerEvent('mythic_notify:client:SendAlert', { type = 'inform', text = 'Choose G = 0 - 255', lenght = 10000 })
			while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
				Citizen.Wait( 0 )
			end
			local colorG = GetOnscreenKeyboardResult()
			local g = colorG
			if tonumber(colorR) ~= nil and tonumber(colorR) >= 0 and tonumber(colorR) <= 255 then --Green väri valittu
				maxLength = 3
				AddTextEntry('FMMC_KEY_TIP8', "Set vehicle colour [~b~B~s~]")
				DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP8", "", "", "", "", "", maxLength)
				--TriggerEvent('mythic_notify:client:SendAlert', { type = 'inform', text = 'Choose B = 0 - 255', lenght = 10000 })
				while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
					Citizen.Wait( 0 )
				end
				local colorB = GetOnscreenKeyboardResult()
				local b = colorB
				if tonumber(colorB) ~= nil and tonumber(colorB) >= 0 and tonumber(colorB) <= 255 then --Green väri valittu
					StartPaint(r,g,b, nearveh)
				else
					if enableESX then
						ESX.ShowNotification('B = Choose real value')
					else
						print('B = Choose real value')
					end
				end
			else
				if enableESX then
					ESX.ShowNotification('G = Choose real value')
				else
					print('B = Choose real value')
				end
			end
		else
			if enableESX then
				ESX.ShowNotification('R = Choose real value')
			else
				print('B = Choose real value')
			end
		end
	else
		print('No vehicles nearby')
	end
end)

function StartPaint(r,g,b, vehicle)
    if not spray then
        spraying = true
        local ped = PlayerPedId()
		if enableItem and enableESX then
			TriggerServerEvent('s_paint:removeItem', item)
		end
        spraycan = CreateObject(GetHashKey('ng_proc_spraycan01a'),0.0, 0.0, 0.0,true, false, false)
        AttachEntityToEntity(spraycan, ped, GetPedBoneIndex(ped, 57005), 0.072, 0.041, -0.06,33.0, 38.0, 0.0, true, true, false, true, 1, true)
        local nearveh = nil
		CreateThread(function()
			local min = 255
			while spraying do
				local sleep = 3000
				min = min - (min/sleep) * 1000
				SprayParticles(ped,dict,r,g,b,vehicle,min)
				Wait(3000)
			end
		end)
		RemoveNamedPtfxAsset(dict)
		while ( not HasAnimDictLoaded( 'anim@amb@business@weed@weed_inspecting_lo_med_hi@' ) ) do
			RequestAnimDict( 'anim@amb@business@weed@weed_inspecting_lo_med_hi@' )
			Citizen.Wait( 1 )
		end
		TaskPlayAnim(ped, 'anim@amb@business@weed@weed_inspecting_lo_med_hi@', 'weed_spraybottle_stand_spraying_01_inspector', 1.0, 1.0, -1, 16, 0, 0, 0, 0 )
		local rd,gd,bd = 255, 255, 255
		while spraying do
			while rd ~= tonumber(r) or gd ~= tonumber(g) or bd ~= tonumber(b) do
				if rd ~= tonumber(r) then
					rd = rd - 1
				end
				if gd ~= tonumber(g) then
					gd = gd - 1
				end
				if bd ~= tonumber(b) then
					bd = bd - 1
				end
				SetVehicleCustomPrimaryColour(vehicle,tonumber(rd),tonumber(gd),tonumber(bd))
				Wait(100)
			end
			spraying = false
			Wait(100)
			ClearPedTasks(ped)
			ReqAndDelete(spraycan)
			if enableESX then
				myCar = ESX.Game.GetVehicleProperties(vehicle)
				TriggerServerEvent('s_paint:refreshOwnedVehicle', myCar)
			end
		end
	end
end

function RemovePaint(r,g,b,vehicle)
    if not spray then
        spraying = true
        local ped = PlayerPedId()
		if enableESX and enableItem then
			TriggerServerEvent('s_paint:removeItem', removePaintItem)
		end
        spraycan = CreateObject(GetHashKey('ng_proc_spraycan01a'),0.0, 0.0, 0.0,true, false, false)
        AttachEntityToEntity(spraycan, ped, GetPedBoneIndex(ped, 57005), 0.072, 0.041, -0.06,33.0, 38.0, 0.0, true, true, false, true, 1, true)
        local nearveh = nil
		CreateThread(function()
			local min = 255
			while spraying do
				local sleep = 3000
				min = min - (min/sleep) * 1000
				SprayParticles(ped,dict,r,g,b,vehicle,min)
				Wait(3000)
			end
		end)
		RemoveNamedPtfxAsset(dict)
		while ( not HasAnimDictLoaded( 'anim@amb@business@weed@weed_inspecting_lo_med_hi@' ) ) do
			RequestAnimDict( 'anim@amb@business@weed@weed_inspecting_lo_med_hi@' )
			Citizen.Wait( 1 )
		end
		TaskPlayAnim(ped, 'anim@amb@business@weed@weed_inspecting_lo_med_hi@', 'weed_spraybottle_stand_spraying_01_inspector', 1.0, 1.0, -1, 16, 0, 0, 0, 0 )
		local rd,gd,bd = 255, 255, 255
		while spraying do
			while rd ~= tonumber(r) or gd ~= tonumber(g) or bd ~= tonumber(b) do
				if rd ~= tonumber(r) then
					rd = rd - 1
				end
				if gd ~= tonumber(g) then
					gd = gd - 1
				end
				if bd ~= tonumber(b) then
					bd = bd - 1
				end
				SetVehicleCustomPrimaryColour(vehicle,tonumber(rd),tonumber(gd),tonumber(bd))
				SetVehicleCustomSecondaryColour(vehicle,tonumber(rd),tonumber(gd),tonumber(bd))
				Wait(100)
			end
			spraying = false
			Wait(100)
			ClearVehicleCustomPrimaryColour(vehicle)
			ClearVehicleCustomSecondaryColour(vehicle)
			SetVehicleColours(vehicle, 13,13)
			ClearPedTasks(ped)
			ReqAndDelete(spraycan)
			if enableESX then
				myCar = ESX.Game.GetVehicleProperties(vehicle)
				TriggerServerEvent('s_paint:refreshOwnedVehicle', myCar)
			end
		end
	end
end

function SprayParticles(ped,dict,r,g,b, vehicle)
    local dict = "scr_recartheft"
    local ped = PlayerPedId()
    local fwd = GetEntityForwardVector(ped)
    local coords = GetEntityCoords(ped) + fwd * 0.5 + vector3(0.0, 0.0, -0.5)

    RequestNamedPtfxAsset(dict)
    -- Wait for the particle dictionary to load.
    while not HasNamedPtfxAssetLoaded(dict) do
        Citizen.Wait(0)
    end
    local pointers = {}
    local heading = GetEntityHeading(ped)
    UseParticleFxAssetNextCall(dict)
    SetParticleFxNonLoopedColour(r / 255, g / 255, b / 255)
    SetParticleFxNonLoopedAlpha(1.0)
    local spray = StartNetworkedParticleFxNonLoopedAtCoord("scr_wheel_burnout", coords.x, coords.y, coords.z + 1.5, 0.0, 0.0, heading, 0.7, 0.0, 0.0, 0.0)
end

function ReqAndDelete(object, detach)
	if DoesEntityExist(object) then
		NetworkRequestControlOfEntity(object)
		local attempt = 0
		while not NetworkHasControlOfEntity(object) and attempt < 100 and DoesEntityExist(object) do
			NetworkRequestControlOfEntity(object)
			Citizen.Wait(1)
			attempt = attempt + 1
		end
        DetachEntity(object,true,false)
		SetEntityCollision(object, false, false)
		SetEntityAlpha(object, 0.0, true)
		SetEntityAsMissionEntity(object, true, true)
		SetEntityAsNoLongerNeeded(object)
		DeleteEntity(object)
        if DoesEntityExist(object) then
            SetEntityCoords(object,0.0,0.0,0.0)
        end
	end
end