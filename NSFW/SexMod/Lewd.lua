import "UnityEngine"
import "Assembly-CSharp"
import "System"

meta["source"] = "https://raw.githubusercontent.com/Metalloriff/ElementalReignMods/main/NSFW/SexMod/Lewd.lua"
meta["version"] = "0.0.1"
meta["description"] = "A sex mod for a low poly game? Why? Because furries."
-- meta["required"] = ["lewd", "pp"]

function Load()
	animator = {}

	local lewd = API:FindMod("lewd")
	local ppmod = API:FindMod("pp")

	if lewd ~= nil and ppmod ~= nil then
		animations = lewd:FindAllByType("lewd")
	end
end

function _()
	if Input.GetKeyDown(KeyCode.Home) and PlayerB.lookingAt.transform ~= nil and PlayerB.lookingAt.transform:GetComponent("NPC") ~= nil then
		selected = PlayerB.lookingAt.transform:GetComponent("NPC")
	end
end

function RenderGUI()
	if selected ~= nil then
		GUILayout.Label("SELECTED " .. selected.name)

		local anim = selected:GetComponent("Animation")
		if anim:Equals(nil) then
			if GUILayout.Button("Attach Override Animator") then
				selected:GetComponent("Animator").enabled = false
				selected:GetComponent("NavMeshAgent").enabled = false
				selected.gameObject:AddComponent(API:FindType("UnityEngine", "Animation"))
	
				for a = 0, animations.Length - 1 do
					selected:GetComponent("Animation"):AddClip(animations[a].asset, animations[a].asset.name)
				end
			end
		else
			if GUILayout.Button("Detach Override Animator") then
				anim:Stop()

				selected:GetComponent("Animator").enabled = true
				selected:GetComponent("NavMeshAgent").enabled = true

				Component.Destroy(anim)
				anim = nil
			end
		end

		for a = 0, animations.Length - 1 do
			if GUILayout.Button(animations[a].asset.name) then
				anim:Play(animations[a].asset.name)

				allanims = Object.FindObjectsOfType(API:FindType("UnityEngine", "Animation"))
				for i = 0, allanims.Length - 1 do
					for n = 0, animations.Length - 1 do
						allanims[i]:Rewind(animations[n].asset.name)
					end
				end
			end
		end

		others = Object.FindObjectsOfType(API:FindType("Assembly-CSharp", "NPC"))
		for o = 0, others.Length - 1 do
			if GUILayout.Button("Attach to " .. others[o].name .. " (" .. Vector3.Distance(selected.transform.position, others[o].transform.position) .. "m)") then
				selected.transform.position = others[o].transform:TransformPoint(0, -0.1, 0.3)
				selected.transform.rotation = others[o].transform.rotation
			end
		end

		if GUILayout.Button("Remove Shirt") then
			selected.transform:Find("Torso"):GetComponent("SkinnedMeshRenderer").sharedMesh = nil
		end

		if GUILayout.Button("Remove Pants") then
			selected.transform:Find("Legs"):GetComponent("SkinnedMeshRenderer").sharedMesh = nil
		end

		if GUILayout.Button("Remove Underwear") then
			selected.transform:Find("Under"):GetComponent("SkinnedMeshRenderer").sharedMesh = nil
		end

		local ppinstance = selected.transform:Find("PP")
		if ppinstance ~= nil and not ppinstance:Equals(nil) then
			local pp = ppinstance:GetComponent("SkinnedMeshRenderer")
			v = GUILayout.HorizontalSlider(pp:GetBlendShapeWeight(4), 0, 100)

			pp:SetBlendShapeWeight(3, 100 - v)
			pp:SetBlendShapeWeight(4, v)
		end
	end
end
