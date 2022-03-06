include("autorun/client/npcweaponoverridemenu_client.lua")

if CLIENT then

    local nwom = NPCWeaponOverrideMenu()

    nwom:setConVars();
    nwom:setTab("Options")

    hook.Add("AddToolMenuCategories", "NwomCategoryHook", function()

        nwom:setCategory("snaileny", "snaileny")
        nwom:addCategory() 
 
    end)

    hook.Add("PopulateToolMenu", "NwomPopulateHook", function()
    
        nwom:setOption("nwomOption", "NPC Weapon Override Menu")
        nwom:addOption() 

    end)

end

if SERVER then

    util.AddNetworkString("selectedWeaponsList")

    local slcWpnLst = {}
    local localPly = nil
    local counter = 1

    net.Receive("selectedWeaponsList", function() 
    
        localPly = net.ReadType()
        slcWpnLst = net.ReadTable()

    end)

    function giveWeapons(ply, npc) 

        if #slcWpnLst > 0 then

            if counter < #slcWpnLst then

                if slcWpnLst[counter] ~= nil then

                    npc:Give(slcWpnLst[counter])

                end
                counter = counter + 1
                
            else
                
                if slcWpnLst[counter] ~= nil then

                    npc:Give(slcWpnLst[counter])

                end
                counter = 1

            end

        end

    end

    function giveWeaponsRandom(ply, npc)

        if #slcWpnLst > 0 then

            local randNum = math.random(1, #slcWpnLst)
            npc:Give(slcWpnLst[randNum])

        end

    end

    hook.Add("PlayerSpawnedNPC", "NwomSpawnHook", function(ply, npc) 
    
        if localPly then 
        
            local conVarEnabled = ply:GetInfo("npcweaponoverridemenu_enabled")
            local conVarRandom = ply:GetInfo("npcweaponoverridemenu_random")

            if conVarEnabled == "1" and  ply:UserID() == localPly:UserID() then

                if conVarRandom == "1" then

                    giveWeaponsRandom(ply, npc)

                else

                    giveWeapons(ply, npc) 

                end

            end
        
        end
    
    end)

end
