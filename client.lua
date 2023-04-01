local playerPed = PlayerPedId()
local playerCoords = GetEntityCoords(playerPed)
local dancing = false
local currentIntensity = 1
local currentDanceId = nil
local currentDance = nil
local lastAnimation
local lastDict
local lastIntensity

Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(500)
        playerPed = PlayerPedId()
        playerCoords = GetEntityCoords(playerPed)
    end
end)

RegisterCommand("ustawtaniec", function(source, args)
    arg = tonumber(args[1])
    if arg <= 210 and arg > 0 then 
        currentDanceId = tonumber(args[1])
        currentDance = Dances[currentDanceId]
    end
end)

RegisterCommand('taniec', function(source, args)
    TriggerEvent('dancing_startdance', danceStyle)
end)

RegisterNetEvent("dancing_startdance", function()
    currentDanceId = 1
    currentDance = Dances[currentDanceId]
    dancing = true 
end)


Citizen.CreateThread(function()
    while true do 
        sleep = 1000
        -- distanced = false
        -- for i=1, #Config.Zones do 
        --     local distance = #(playerCoords-vector3(Config.Zones[i]))
        --     if distance < 20 then 
        --         sleep = 3
        --         distanced = true
        --         --DrawMarker(27, Config.Zones[i].x, Config.Zones[i].y, Config.Zones[i].z-0.9, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 20.0, 20.0, 2.0, 255, 0, 0, 100, false, true, 2, false, false, false, false)
        --         if not dancing then 
        --             HelpText("Naciśnij ~INPUT_PICKUP~ aby zacząć tańczyć")
        --             if IsControlJustReleased(0, 38) then 
        --                 currentDanceId = math.random(#Dances)
        --                 currentDance = Dances[currentDanceId]
        --                 dancing = true 
        --             end
        --         end
        --     end
        -- end
        if dancing then 
            sleep = 3
			local controlable = ""
			if currentDance.controlable then 
				controlable = "\n~INPUT_MOVE_UP_ONLY~ ~INPUT_MOVE_DOWN_ONLY~ ~INPUT_MOVE_LEFT_ONLY~ ~INPUT_MOVE_RIGHT_ONLY~ Ruchy taneczne"
            end
			HelpText("~INPUT_WEAPON_WHEEL_PREV~ ~INPUT_WEAPON_WHEEL_NEXT~ Zmień intensywność"..controlable.."\n~INPUT_CELLPHONE_LEFT~ ~INPUT_CELLPHONE_RIGHT~ Zmień taniec \n~INPUT_CELLPHONE_CAMERA_EXPRESSION~ Przestań tańczyć \nobecny numer tańca: "..currentDanceId.."")
            if IsControlJustReleased(0, 186) then 
                ClearPedTasks(playerPed)
                dancing = false
            end
            if IsControlJustPressed(0, 181) then -- up scroll 
				if currentIntensity ~= 3 then
					currentIntensity = currentIntensity + 1
				end
			end
			if IsControlJustPressed(0, 180) then -- down scroll 
				if currentIntensity ~= 1 then
					currentIntensity = currentIntensity - 1
				end
			end
			if IsControlJustPressed(0, 174) then -- left arrow
				currentDanceId = currentDanceId - 1
				if currentDanceId < 1 then
					currentDanceId = #Dances
				end
				currentDance = Dances[currentDanceId]
			end
			if IsControlJustPressed(0, 175) then -- right arrow 
				currentDanceId = currentDanceId + 1
				if currentDanceId > #Dances then
					currentDanceId = 1
				end
				currentDance = Dances[currentDanceId]
			end
            
            if currentDance.controlable then
				if IsControlPressed(0, 34) then -- A
					if IsControlPressed(0, 32) then -- A and W
						tempAnim = "left_up"
					elseif IsControlPressed(0, 33) then -- A and S
						tempAnim = "left_down"
					else
						tempAnim = "left"
					end
				elseif IsControlPressed(0, 35) then -- D
					if IsControlPressed(0, 32) then -- D and W
						tempAnim = "right_up"
					elseif IsControlPressed(0, 33) then -- D and S
						tempAnim = "right_down"
					else
						tempAnim = "right"
					end
				elseif IsControlPressed(0, 32) then -- W
					tempAnim = "center_up"
				elseif IsControlPressed(0, 33) then -- S
					tempAnim = "center_down"
				else -- No keys pressed
					tempAnim = "center"
				end
				if currentIntensity == 1 then
					tempAnim = currentDance.intensityLevels[currentIntensity] .. tempAnim
				elseif currentIntensity == 2 then
					tempAnim = currentDance.intensityLevels[currentIntensity] .. tempAnim
				else
					tempAnim = currentDance.intensityLevels[currentIntensity] .. tempAnim
				end
				tempDict = currentDance.dict[1]
			else
				if #currentDance.intensityLevels == 1 then
					tempAnim = currentDance.intensityLevels[1] .. currentDance.anim
					tempDict = currentDance.dict[1]
					currentIntensity = 3
				else
					tempAnim = currentDance.intensityLevels[currentIntensity] .. currentDance.anim
					tempDict = currentDance.dict[currentIntensity]
				end
			end

            if lastIntensity ~= currentIntensity or tempAnim ~= lastAnimation or tempDict ~= lastDict then
                LoadAnimationDict(tempDict)
                TaskPlayAnim(PlayerPedId(), tempDict, tempAnim, 1.0, 1.0, -1, 1, 0, 0, 0, 0)
                lastIntensity = currentIntensity
                lastAnimation = tempAnim
                lastDict = tempDict
            end
        end

        Citizen.Wait(sleep)
    end
end)

function LoadAnimationDict(dict)
	if not HasAnimDictLoaded(dict) then
		RequestAnimDict(dict)
		while not HasAnimDictLoaded(dict) do
			Wait(10)
		end
	end
end

function HelpText(text)
    AddTextEntry('77', text)
    BeginTextCommandDisplayHelp('77')
    EndTextCommandDisplayHelp(0, false, true, -1)
end

