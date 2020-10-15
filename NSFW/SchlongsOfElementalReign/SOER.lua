import "UnityEngine"
import "Assembly-CSharp"
import "NeatoLib"

meta["source"] = "https://raw.githubusercontent.com/Metalloriff/ElementalReignMods/main/NSFW/SchlongsOfElementalReign/SOER.lua"
meta["version"] = "0.0.1"
meta["description"] = "Adds detailed nudity to all pants-less Vulpes. Press P to toggle pants and underwear on self, hold Page Up and Page Down to control erection. Kill me."
-- meta["required"] = ["pp"]

PP = {}

function PP.SetHardness(pp, hardness)
	pp:SetBlendShapeWeight(3, (1.0 - hardness) * 100.0)
	pp:SetBlendShapeWeight(4, hardness * 100.0)
end

function PP.Create(obj)
	local body = obj:Find("Body"):GetComponent("SkinnedMeshRenderer")
	local ppinstance = GameObject.Instantiate(obj:Find("Legs"), obj):GetComponent("SkinnedMeshRenderer")
	ppinstance.sharedMesh = PP.mesh.sharedMesh
	ppinstance.name = "PP"

	ppinstance:SetBlendShapeWeight(0, body:GetBlendShapeWeight(0))
	ppinstance:SetBlendShapeWeight(1, body:GetBlendShapeWeight(1))
	ppinstance:SetBlendShapeWeight(2, 0)
	ppinstance:SetBlendShapeWeight(5, Random.Range(0, 100))

	local mats = PP.mesh.sharedMaterials
	mats[1] = obj:Find("Body"):GetComponent("SkinnedMeshRenderer").materials[0]
	ppinstance.materials = mats

	PP.SetHardness(ppinstance, 0)

	return ppinstance
end

function Load()
	cm = API:FindMod("pp")
	active = false
	hardness = 0.0

	npcType = API:FindType("Assembly-CSharp", "NPC")

	if cm == nil then
		Lib.Prompts.BoolInput("SOER requires pp", "You must install pp.", null, null, "Close")
	else
		PP.mesh = cm:FindByName("pp.fbx").asset.transform:Find("Body.001"):GetComponent("SkinnedMeshRenderer")
	end

	if Lib.Player.self ~= nil and not Lib.Player.self:Equals(nil) then
		PlayerSpawned(Lib.Player.self:GetComponent("PlayerB"))
	end
end

function PlayerSpawned(player)
	players = GameObject.FindGameObjectsWithTag("Player")

	if player.photonView.IsMine then
		activePlayer = player

		legs = player.transform:Find("Legs"):GetComponent("SkinnedMeshRenderer")
		under = player.transform:Find("Under"):GetComponent("SkinnedMeshRenderer")

		startLegs = legs.sharedMesh
		startUnderwear = under.sharedMesh
	end
end

function CheckForNudity(p)
	if not p:Equals(nil) then
		local p_under_t = p.transform:Find("Under")
		local p_legs_t = p.transform:Find("Legs")

		if p_under_t ~= nil and p_legs_t ~= nil and p_under_t:Equals(nil) == false and p_legs_t:Equals(nil) == false then
			local p_under = p_under_t:GetComponent("SkinnedMeshRenderer")
			local p_legs = p_legs_t:GetComponent("SkinnedMeshRenderer")
			local p_pp_t = p.transform:Find("PP")

			if p_under.sharedMesh == nil and p_legs.sharedMesh == nil then
				if p_pp_t == nil then
					local pp_i = PP.Create(p.transform)

					if p.name == activePlayer.name then
						ppinstance = pp_i
					end
				end
			elseif p_pp_t ~= nil then
				GameObject.Destroy(p_pp_t.gameObject)
			end
		end
	end
end

function _()
	if PP.mesh ~= nil and activePlayer ~= nil and not activePlayer:Equals(nil) then
		for i = 0, players.Length - 1 do
			CheckForNudity(players[i])
		end

		npcs = Object.FindObjectsOfType(npcType)
		for i = 0, npcs.Length - 1 do
			CheckForNudity(npcs[i])
		end

		if Lib.Input.GetKeyDown(KeyCode.P) then
			TogglePP()
		end

		if ppinstance ~= nil then
			if Input.GetKey(KeyCode.PageUp) then
				hardness = Mathf.Clamp(hardness + 0.5 * Time.deltaTime, 0.0, 1.0)
				UpdatePP()
			end
	
			if Input.GetKey(KeyCode.PageDown) then
				hardness = Mathf.Clamp(hardness - 0.5 * Time.deltaTime, 0.0, 1.0)
				UpdatePP()
			end
		end
	end
end

function TogglePP()
	active = not active

	if active == true then
		legs.sharedMesh = nil
		under.sharedMesh = nil

		if Input.GetKey(KeyCode.LeftShift) then
			PlayerAnimations.CrossFadeAnimation("FML", 1, "Attack")
		end
	else
		legs.sharedMesh = startLegs
		under.sharedMesh = startUnderwear
	end
end

function UpdatePP()
	PP.SetHardness(ppinstance, hardness)
end

function Unload()
	if active == true then
		TogglePP()
	end
end
