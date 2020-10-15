import "UnityEngine"
import "Assembly-CSharp"
import "NeatoLib"

meta["source"] = "https://raw.githubusercontent.com/Metalloriff/ElementalReignMods/main/AutoWalk/Scripts/AutoWalk.lua"
meta["version"] = "0.0.1"
meta["description"] = "Allows you to press the enter key to automatically path to the target location."

function SpawnBeam()
	local o = GameObject.Instantiate(Resources.Load("Projectiles/Dev/Cal"), PlayerB.lookingAt.point, Quaternion.Euler(-90, 0, 0))
	Object.Destroy(o:GetComponent("Projectile"))

	local aud = o:GetComponentsInChildren(API:FindType("UnityEngine", "AudioSource"))
	
	for i = 0, aud.Length - 1 do
		Object.Destroy(aud[i])
	end

	return o
end

function _()
	if UI.current == "Player/InGame" and PlayerB.lookingAt.transform ~= nil then
		if Lib.Input.GetKeyDown(KeyCode.Return) then
			local beam = SpawnBeam()

			PlayerMovement.SetTargetLocationThen(PlayerB.lookingAt.point, function()
				GameObject.Destroy(beam)
			end)
		end
	end
end
