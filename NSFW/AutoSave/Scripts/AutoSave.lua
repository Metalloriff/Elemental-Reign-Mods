import "UnityEngine"
import "UnityEngine.SceneManagement"
import "Assembly-CSharp"
import "NeatoLib"

meta["source"] = "https://github.com/Metalloriff/ElementalReignMods/tree/main/AutoSave/Scripts/AutoSave.lua"
meta["version"] = "0.0.1"

function Load()
	lastTick = Time.time
	loaded = false

	MapChanged(SceneManager.GetActiveScene())
end

function PlayerSpawned(player)
	if loaded == false then
		Console.Run("loadgame AutoSave_" .. activeScene)

		loaded = true
	end
end

function MapChanged(scene)
	activeScene = scene.name
	loaded = false
end

function _()
	if Time.time - lastTick > 5 and Console.instance ~= nil and Lib.Player.self ~= nil and not Lib.Player.self:Equals(nil) and string.len(activeScene) > 0 then
		Console.Run("savegame AutoSave_" .. activeScene)
		lastTick = Time.time
	end
end
