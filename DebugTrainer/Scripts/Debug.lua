import "UnityEngine"
import "UnityEngine.SceneManagement"
import "Assembly-CSharp"
import "NeatoLib"
import "System"
import "System.IO"
import "System.Reflection"
import "NLua"

import ("PhotonUnityNetworking", "Photon.Pun")

meta["source"] = "https://raw.githubusercontent.com/Metalloriff/ElementalReignMods/main/DebugTrainer/Scripts/Debug.lua"
meta["version"] = "0.0.1"

function Load()
	a = ""
	uiEnabled = true

	weatherIntensity = 1
	timeLocked = TimeCycle.speedMult == 0
	luacmd = "enter lua here..."
	inspectorSearch = ""
	freecam = false
end

function Unload()
	
end

function _()
	if Input.GetKeyDown(KeyCode.F12) then
		local ui = GameObject.Find("Environment").transform:Find("UI").gameObject

		ui:SetActive(not ui.activeSelf)
		uiEnabled = ui.activeSelf
	end
end

function ___()
	
end

function RenderGUI()
	if not uiEnabled then return end

	if a ~= "" then
		if GUILayout.Button("Back") then a = "" end
	end

	if a == "" then
		GUILayout.Label("Debug script version 1.0")

		if GUILayout.Button("Time") then a = "time" end
		if GUILayout.Button("Weather") then a = "weather" end
		if GUILayout.Button("Housing") then a = "housing" end
		if GUILayout.Button("Encounters") then a = "encounters" end
		if GUILayout.Button("Tools") then a = "tools" end
	elseif a == "time" then
		GUILayout.Label("Time of Day " .. Math.Round(TimeCycle.instance.tod, 2))
		TimeCycle.instance.tod = GUILayout.HorizontalSlider(TimeCycle.instance.tod, 0, 1)
		timeLocked = GUILayout.Toggle(timeLocked, "Time locked?")

		if timeLocked == true then
			TimeCycle.speedMult = 0
		else
			TimeCycle.speedMult = 1
		end
	elseif a == "weather" then
		if GUILayout.Button("Clear") then SetWeather(Weather.Type.Clear) end
		if GUILayout.Button("Rain") then SetWeather(Weather.Type.Rain) end
		if GUILayout.Button("Thunderstorm") then SetWeather(Weather.Type.Thunderstorm) end
		if GUILayout.Button("Snow") then SetWeather(Weather.Type.Snow) end
		if GUILayout.Button("Snowstorm") then SetWeather(Weather.Type.Snowstorm) end
		if GUILayout.Button("Foggy") then SetWeather(Weather.Type.Foggy) end
		if GUILayout.Button("Darkness") then SetWeather(Weather.Type.Darkness) end

		GUILayout.Label("Weather Intensity " .. Mathf.Round(weatherIntensity))
		weatherIntensity = GUILayout.HorizontalSlider(weatherIntensity, 0, 5)

		GUILayout.Label("Snow Amount " .. Math.Round(Weather.instance.snowAmount, 2))
		Weather.instance.snowAmount = GUILayout.HorizontalSlider(Weather.instance.snowAmount, 0, 0.35)

		Weather.locked = GUILayout.Toggle(Weather.locked, "Weather locked?")
	elseif a == "tools" then
		luacmd = GUILayout.TextArea(luacmd)
		if GUILayout.Button("Run Lua Command") then
			API.Self:DoString(luacmd)
			luacmd = ""
		end

		if GUILayout.Button("Toggle Freecam") then
			freecam = not freecam

			if freecam == true then
				PlayerMovement.instance.enabled = false
				PlayerB.instance.enabled = false
			else
				PlayerMovement.instance.enabled = true
				PlayerB.instance.enabled = true
			end
		end

		if GUILayout.Button("Inspector") then a = "inspector" end
	elseif a == "inspector" then
		local la = PlayerB.lookingAt.transform

		GUILayout.Label("Search")
		inspectorSearch = GUILayout.TextArea(inspectorSearch)
		isi = GameObject.Find(inspectorSearch)

		if string.len(inspectorSearch) > 0 and isi ~= nil then
			la = isi.transform
		end

		if la ~= nil then
			if la ~= lastla then
				SetInspecting(la)
				lastla = la
				scrollpos = Vector2.zero
			end

			scrollpos = GUILayout.BeginScrollView(scrollpos)

			if i_comp ~= nil then
				GUILayout.Label(tostring(i_comp))
				Debug.Log(tostring(i_comp))

				local type = i_comp:GetType()
				local properties = type:GetProperties()
				local fields = type:GetFields()
				local methods = type:GetMethods()
				
				GUILayout.Label(properties.Length .. " properties")

				for i = 0, properties.Length - 1 do
					if GUILayout.Button(properties[i].Name) then
					end
				end

				GUILayout.Label(fields.Length .. " fields")

				for i = 0, fields.Length - 1 do
					if GUILayout.Button(fields[i].Name) then
					end
				end

				GUILayout.Label(methods.Length .. " methods")

				for i = 0, methods.Length - 1 do
					local params = methods[i]:GetParameters()
					local parameters = ""

					if params.Length ~= 0 then
						for p = 0, params.Length - 1 do
							parameters = parameters .. tostring(params[p].ParameterType) .. " " .. params[p].Name

							if params[p].DefaultValue ~= nil then
								parameters = parameters .. " = " .. tostring(params[p].DefaultValue)
							end

							if p ~= params.Length - 1 then
								parameters = parameters .. ", "
							end
						end
					end

					if GUILayout.Button(methods[i].Name .. "(" .. parameters .. ")") then
					end
				end
			else
				GUILayout.Label(inspecting.name .. " (" .. i_components.Length .. " components)")
	
				for i = 0, i_components.Length - 1 do
					if GUILayout.Button(tostring(i_components[i])) then
						i_comp = i_components[i]
					end
				end
	
				GUILayout.Label(i_children.Length - 1 .. " children")
	
				for i = 1, i_children.Length - 1 do
					if GUILayout.Button(i_children[i].name) then
						SetInspecting(i_children[i])
					end
				end
			end

			GUILayout.EndScrollView()
		end
	elseif a == "housing" then
		GUILayout.Label("Generate")
		local allhousings = Resources.LoadAll("E")
		for i = 0, allhousings.Length - 1 do
			if GUILayout.Button(allhousings[i].name) then
				HousingsManager.GenerateHousingData(HousingsManager.GenerateKey(), allhousings[i].name)
			end
		end

		GUILayout.Label("Load")
		local housings = Directory.GetFiles(Application.persistentDataPath .. "/Housing")
		for i = 0, housings.Length - 1 do
			if GUILayout.Button(Path.GetFileName(housings[i])) then
				HousingsManager.LoadHousingScene(Path.GetFileNameWithoutExtension(housings[i]))
			end
		end
	elseif a == "encounters" then
		local encounters = Resources.LoadAll("RandomEncounters/" .. SceneManager.GetActiveScene().name)
		for i = 0, encounters.Length - 1 do
			if GUILayout.Button(encounters[i].name) then
				local e = Resources.Load("RandomEncounters/" .. SceneManager.GetActiveScene().name .. "/" .. encounters[i].name):GetComponent("Encounter")
				RandomEncounters.instance:SummonEncounter(e)
			end
		end
	end
end

function SetInspecting(la)
	inspecting = la
	i_components = la:GetComponents(API:FindType("UnityEngine", "Component"))
	i_children = la:GetComponentsInChildren(API:FindType("UnityEngine", "Transform"))
	i_comp = nil
end

function __()
	if freecam == true and UI.current == "Player/InGame" then
		PlayerMovement.cameraX:Translate(Input.GetAxis("Horizontal") / 3, 0, Input.GetAxis("Vertical") / 3)
		PlayerMovement.cameraY:GetChild(0).localPosition = Vector3.zero

		PlayerMovement.cameraX:Rotate(0, Input.GetAxis("Mouse X"), 0)
		PlayerMovement.cameraY:Rotate(-Input.GetAxis("Mouse Y"), 0, 0)

		if Input.GetKey(KeyCode.Space) then PlayerMovement.cameraX:Translate(Vector3.up / 3) end
		if Input.GetKey(KeyCode.LeftControl) then PlayerMovement.cameraX:Translate(Vector3.down / 3) end
	end
end

function Command(cmd, arg1, arg2)
	if cmd == "die" then
		PlayerB.instance.hp = 0
	end

	if cmd == "emote" then	
		PlayerAnimations.PlayAnimation(arg1, arg2)
	end
end

function SetWeather(t)
	Weather.instance:SetWeather(t, 1, weatherIntensity)
end
