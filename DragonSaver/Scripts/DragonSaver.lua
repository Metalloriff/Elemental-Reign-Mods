import "UnityEngine" -- Import Unity library, for types and classes
import "Assembly-CSharp" -- Import the game's main assembly, for types and classes
import "System.Collections" -- Import system collections, for ArrayList
import "AI" -- Import the game's AI library, for access to the dragon classes and API
import "Managers" -- Import the game's manager library, for several useful functions
import "Player" -- Import the game's player library, for player location and lookingAt data
import ("PhotonUnityNetworking", "Photon.Pun") -- Import the game's networking library, for spawning dragons and sending multiplayer data

-- Set the mod's meta data
meta["description"] = "Allows you to save and load dragon color palettes."
meta["source"] = "https://raw.githubusercontent.com/Metalloriff/ElementalReignMods/main/DragonSaver/Scripts/DragonSaver.lua"
meta["version"] = "0.0.1"

-- Initialize global variables
menuOpen = false

function Load()
    -- Initialize saved dragons
    data = ArrayList()
    openMenuKey = "f8"
    
    -- Load saved dragons
    API:LoadSettings(Name, "data", "openMenuKey")
end

function _()
    if Input.GetKeyDown(openMenuKey) then
        menuOpen = not menuOpen
    end
end

function RenderGUI()
    -- Create window rect
    local width = 500
    local height = 300
    local rect = Rect((Screen.width / 2) - (width / 2), (Screen.height / 2) - (height / 2), width, height)
    
    -- Ensure the window is ready to be shown
    if menuOpen then
        -- Render the window
        GUI.Window(1257, rect, RenderWindow, "Dragon Saver v" .. meta["version"])
    end
end

function RenderWindow(id)
    -- Initialize local window variables
    local dragon = nil
    local uiColor = GUI.backgroundColor
    local colorStyle = GUIStyle(GUI.skin.box)
    
    -- Set color style background to white square
    colorStyle.normal.background = Resources.Load("box_4")

    -- Ensure player is looking at something
    if PlayerB.lookingAt.transform then
        -- Try get dragon class
        dragon = PlayerB.lookingAt.transform:GetComponent("DragonNPC")
    end

    for i = 0, data.Count - 1 do
        local dataItem = data[i]
        
        GUILayout.BeginVertical(GUI.skin.box);
            -- Render color previews
            GUILayout.BeginHorizontal();
                -- Render accent color
                 GUI.backgroundColor = dataItem[0]:ToColor()
                GUILayout.Box("", colorStyle)
        
                -- Render main body color
                 GUI.backgroundColor = dataItem[1]:ToColor()
                GUILayout.Box("", colorStyle)
        
                GUI.backgroundColor = uiColor
            GUILayout.EndHorizontal();
        
            -- Remove the current color from the entries list
            if GUILayout.Button("Remove") then
                data:RemoveAt(i)

                -- Save data
                API:SaveSettings(Name, "data", "openMenuKey")
            end

            -- Spawn dragon using colors
            if GUILayout.Button("Spawn") then 
                -- Instantiate the dragon prefab and get its network view
                local instance = PhotonNetwork.Instantiate("NPCS/[BOSS] Furred Dragon", Lib.Player.Position, Quaternion.identity)
                local net = instance:GetComponent("PhotonView")
                
                -- Wait half a second to ensure the dragon is fully initialized
                API:Delay(0.5, function()
                    -- Send and apply the colors to all connected players and future-joining players
                    net:RPC("SetColors", RpcTarget.AllBuffered,
                            Vector3(dataItem[0].r, dataItem[0].g, dataItem[0].b),
                            Vector3(dataItem[1].r, dataItem[1].g, dataItem[1].b))
                end)
            end

            -- Ensure dragon was found
            if dragon then
                -- Apply colors to dragon
                if GUILayout.Button("Apply Colors") then
                    -- Get the dragon's network view
                    local net = PlayerB.lookingAt.transform.root:GetComponent("PhotonView")
                    
                    -- Send and apply the colors to all connected players and future-joining players
                    net:RPC("SetColors", RpcTarget.AllBuffered,
                            Vector3(dataItem[0].r, dataItem[0].g, dataItem[0].b),
                            Vector3(dataItem[1].r, dataItem[1].g, dataItem[1].b))
                end
            end
        GUILayout.EndVertical();
    end

    -- Ensure dragon was found
    if dragon then
        -- Get dragon body and materials
        local renderer = dragon.transform:Find("Dregin"):GetComponent("SkinnedMeshRenderer")
        local materials = renderer.materials
        
        -- Display dragon name
        GUILayout.Label(dragon.name .. tostring(dragon.transform.root.position))

        -- Render dragon colors
        GUILayout.BeginHorizontal()
            -- Render accent color
            GUI.backgroundColor = materials[0]:GetColor("_Color")
            GUILayout.Box("", colorStyle)
        
            -- Render main body color
            GUI.backgroundColor = materials[1]:GetColor("_Color")
            GUILayout.Box("", colorStyle)
        
            GUI.backgroundColor = uiColor
        GUILayout.EndHorizontal()

        -- Render save button
        if GUILayout.Button("Save Dragon") then
            -- Create temporary array list for colors
            local item = ArrayList()
            
            -- Add accent and body colors to the temporary list
            item:Add(SColor(materials[0]:GetColor("_Color")))
            item:Add(SColor(materials[1]:GetColor("_Color")))

            -- Insert current dragon's colors into data cache
            data:Add(item)
            
            -- Save data
             API:SaveSettings(Name, "data", "openMenuKey")
        end
    end
end
