import "UnityEngine" -- Imports the UnityEngine assembly. This will almost always be used.
import "Assembly-CSharp" -- Imports the game's main assembly. This will almost always be used.
import "NeatoLib" -- Imports the game's extended library. This contains useful functions and extensions to objects.

import ("PhotonUnityNetworking", "Photon.Pun") -- Imports the networking system used in ER. This will be necessary for any multiplayer mods.

-- The meta is an optional dictionary that can be used for auto-updates amongst other things.
meta["source"] = "https://raw.githubusercontent.com/Metalloriff/ElementalReignMods/main/ExampleMod/Scripts/ExampleMod.lua"
	-- The source meta is used to request the updated version of the script, this is required for auto-updates to work.
	-- NOTE: The source meta, if present, must be paired with the version meta.
meta["version"] = "0.0.2"
	-- The version meta is used for update version comparisons.
	-- If the remote source version is higher than the local version, an update request prompt will be shown.
	-- NOTE: The version must follow the semantic versioning format (https://semver.org/) of MAJOR.MINOR.PATCH.
meta["description"] = "An example mod showcasing most of the API available for script modding."
	-- The description meta is used to describe what your script/mod does. This will show in the game launcher/mod manager.
-- meta["required"] = "some mod, some other mod"
	-- The required meta is used to require other mods. This can be scripts or assets.
	-- This will ensure that your script will not start unless all required mods are installed.
	-- NOTE: This is commented out to ensure that the mod will still start without the fake requirement examples.

function Load() -- Called as soon as the script starts. Use this for initialization.
	test = GameObject.Find("Test")

	if test ~= nil then -- It is always good to ensure an object's existence before working with it.
		test.transform.localScale = Vector3.one
	end

	-- Example of registering commands. This is not mandatory, commands will still work without being registered, but without, your users may not know how to use
	-- your commands. If you register a command, you must unregister it with API:UnregisterAllCommands() before re-registering. (recommended in Unload())
	API:RegisterCommand(Console.Command("size", "Scales the player.", "size 5",
		Console.Command.Argument("size multiplier", "The amount of times by default to scale the player to.")))

	-- Two example settings of different types. You can have an infinite number of settings fields.
	-- NOTE: The settings types must be serializable.
	someIntSetting = 5
	someStringSetting = "test"

	-- Load the settings fields from the settings.json file for this mod.
	API:LoadSettings(Name, "someIntSetting", "someStringSetting")
end

-- Call this function to see how applying and saving settings works.
function ExampleSaveSettings()
	-- Example of setting the setting fields.
	-- The integer is set to a random number between 0 and 19, and the string is set to a randomly generated string with a length of 5.
	someIntSetting = Random.Range(0, 20)
	someStringSetting = Lib.CreateUniqueID(5)

	-- Now save the settings, the same as you do when you load them.
	API:SaveSettings(Name, "someIntSetting", "someStringSetting")
end

function Unload() -- Called before the script is unloaded (usually when reloading). Use this to detach events and objects created during your script's runtime.
					-- Does not call when the game closes.
	API:UnregisterAllCommands()
end

function _() end -- Called every frame.
function __() end -- Called every physics update.
function ___() end -- Called at the end of every frame. This is useful for overriding animations and other values that are updated every frame.
function RenderGUI() end -- Called every frame when the GUI is ready to be rendered.

function PlayerSpawned(player) end -- Called when a player spawns into the game. This includes, but is not limited to yourself. -- player: PlayerB
function ReceivedDamage(player, dmg, type) end -- Called when you receive damage. -- player: PlayerB, dmg: float, type: DamageType
function MapChanged(scene) end -- Called when changing scenes (maps). This includes going to and from the main menu. -- scene: UnityEngine.SceneManagement.Scene
function PostModManagerInit() end -- Called after all mods and scripts are loaded and ready. Use this for extending onto other mods seamlessly.
									-- To extend onto PostManagerInit(), all script mods (.lua) are loaded after every other type of mod,
									-- so you may safely access non script mods in Load()

function Command(cmd, arg1) -- Called when the user runs a command. Can have an infinite amount of arguments. -- cmd: string, arg*: string
	if cmd == "size" then
		Lib.Player.self.transform.localScale = Vector3.one * tonumber(arg1)
	end
end
