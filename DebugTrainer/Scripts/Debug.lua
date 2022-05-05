import "UnityEngine"
import "UnityEngine.SceneManagement"
import "Assembly-CSharp"
import "Managers"
import "System"
import "System.IO"
import "System.Reflection"
import "NLua"
import "Player"
import "UI"
import "Environment"
import "Spawners"

import("PhotonUnityNetworking", "Photon.Pun")

meta["source"] = "https://raw.githubusercontent.com/Metalloriff/ElementalReignMods/main/DebugTrainer/Scripts/Debug.lua"
meta["version"] = "0.1.7"

function Load()
	a = ""
	uiEnabled = true

	weatherIntensity = 1
	timeLocked = TimeCycle.speedMult == 0
	luacmd = "enter lua here..."
	freecam = false
	fps = 0
	lastChangedFps = -5.0

	Debug.Log("DEBUG MOD LOADED")
end

function Unload()

end

function _()
	-- if GameObject.Find("Spawn Target") ~= nil then
	-- 	Lib.Notifications.Hint(tostring(GameObject.Find("Spawn Target").transform.position))
	-- end

	if (Time.time - lastChangedFps > 0.25) then
		fps = Math.Round(1 / Time.unscaledDeltaTime)
		lastChangedFps = Time.time
	end

	if Lib.Input.GetKeyDown(KeyCode.RightBracket) then
		if Time.timeScale == 1 then
			Time.timeScale = 0.001
		else
			Time.timeSCale = 1
		end
	end
end

function ___()

end

function RenderGUI()
	if UI.current == "Player/BuildMode" then return end

	if a ~= "" then
		if GUILayout.Button("Back") then a = "" end
	end

	if a == "" then
		if GUILayout.Button("Debug script v" .. meta["version"]) then a = "main" end
	elseif a == "main" then
		if GUILayout.Button("Time") then a = "time" end
		if GUILayout.Button("Weather") then a = "weather" end
		if GUILayout.Button("Housing") then a = "housing" end
		if GUILayout.Button("Encounters") then a = "encounters" end
		if GUILayout.Button("Tools") then a = "tools" end
		if GUILayout.Button("Pets") then a = "pets" end
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

		GUILayout.Label("Wetness Amount " .. Math.Round(Weather.instance.wetnessAmount, 2))
		Weather.instance.wetnessAmount = GUILayout.HorizontalSlider(Weather.instance.wetnessAmount, 0, 1)

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
				PlayerCore.instance.enabled = false
			else
				PlayerMovement.instance.enabled = true
				PlayerCore.instance.enabled = true
			end
		end
	elseif a == "pets" then
		local allPets = Resources.LoadAll("Pets")

		for i = 0, allPets.Length - 1 do
			if GUILayout.Button(allPets[i].name) then
				local obj = PhotonNetwork.Instantiate("Pets/" .. allPets[i].name, PlayerCore.instance.transform.position, Quaternion.identity)
				local pet = obj:GetComponent("Pet")

				pet.owner = PlayerCore.instance
			end
		end

		GUILayout.Space(20)
		GUILayout.Label("Your active pets")

		local yourPets = PlayerCore.instance.pets

		for i = 0, yourPets.Count - 1 do
			GUILayout.BeginHorizontal()

			GUILayout.Button(yourPets[i].name)

			if GUILayout.Button("Kill") then
				Extensions.NetDestroy(yourPets[i].gameObject)
			end

			GUILayout.EndHorizontal()
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
		local encounters = Resources.LoadAll("RandomEncounters")
		for i = 0, encounters.Length - 1 do
			if GUILayout.Button(encounters[i].name) then
				local e = Resources.Load("RandomEncounters/" .. encounters[i].name):GetComponent("Encounter")
				RandomEncounters.instance:SummonEncounter(e)
			end
		end
	end

	GUILayout.Label(tostring(fps) .. " FPS")
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
		PlayerCore.instance.hp = 0
	end

	if cmd == "emote" then
		PlayerAnimations.PlayAnimation(arg1, arg2)
	end
end

function SetWeather(t)
	Weather.instance:SetWeather(t, 1, weatherIntensity)
end
