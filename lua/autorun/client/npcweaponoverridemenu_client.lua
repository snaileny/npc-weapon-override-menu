AddCSLuaFile()

NPCWeaponOverrideMenu = {}
NPCWeaponOverrideMenu.__index = NPCWeaponOverrideMenu

function NPCWeaponOverrideMenu:new()

    local newTable = {

        selectedWeaponsList = {}

    } 

    return setmetatable(newTable, NPCWeaponOverrideMenu)

end

function NPCWeaponOverrideMenu:getSelectedWeaponsList()

    return self.selectedWeaponsList

end

function NPCWeaponOverrideMenu:setPanel(nwomForm)
                      
    local nwomList = vgui.Create("DListView", nwomForm)

    nwomList:SetHeight(300)    
    nwomList:AddColumn("Weapon"):SetWidth(150)
    nwomList:AddColumn("Selected"):SetWidth(10)
    nwomList:SetMultiSelect(false)

    nwomForm:CheckBox("Enabled", "npcweaponoverridemenu_enabled")
    nwomForm:ControlHelp("Enable NPC Weapon Override Menu")
    nwomForm:CheckBox("Randomize", "npcweaponoverridemenu_random")
    nwomForm:ControlHelp("Give selected weapons to NPCs randomly instead of giving in selection order")
    nwomForm:Help("Double-click to select the weapons you wish to spawn NPCs with. Be aware that weapons listed here may not be compatible with all NPCs.")
    nwomForm:AddItem(nwomList)
    local nwomSelectButton = nwomForm:Button("Select All")
    local nwomDeselectButton = nwomForm:Button("Deselect All")

    local nwomWeapons = list.Get("NPCUsableWeapons")
    local nwomWeaponClasses = {}
    local selectionList = nwomList:GetLines()


    for key, value in pairs(nwomWeapons) do

        nwomList:AddLine(value["title"])
        nwomWeaponClasses[value["title"]] = value["class"]

    end

    function nwomList.DoDoubleClick(parent, lineID, line)

        local firstColumnText = line:GetColumnText(1)
        local secondColumnText =  line:GetColumnText(2)
        local weaponClass = nwomWeaponClasses[firstColumnText]

        if secondColumnText ~= "True" then 

            line:SetColumnText(2, "True")
            self:addToSelectedWeaponsList(weaponClass)

        else

            line:SetColumnText(2, "")
            self:removeFromSelectedWeaponsList(weaponClass)

        end

    end

    function nwomSelectButton.DoClick(parent)

        for _, line in pairs(selectionList) do

            local firstColumnText = line:GetColumnText(1)
            local secondColumnText =  line:GetColumnText(2)
            local weaponClass = nwomWeaponClasses[firstColumnText]

            if secondColumnText ~= "True" then

                line:SetColumnText(2, "True")
                self:addToSelectedWeaponsList(weaponClass)

            end

        end

    end

    function nwomDeselectButton.DoClick(parent)

        for _, line in pairs(selectionList) do

            local firstColumnText = line:GetColumnText(1)
            local secondColumnText =  line:GetColumnText(2)
            local weaponClass = nwomWeaponClasses[firstColumnText]

            if secondColumnText == "True" then

                line:SetColumnText(2, "")
                self:removeFromSelectedWeaponsList(weaponClass)

            end

        end

    end

end

function NPCWeaponOverrideMenu:sendDataToServer() 

    local slcWpnLst = self:getSelectedWeaponsList()
    local localPly = LocalPlayer()

    net.Start("selectedWeaponsList")

        net.WriteType(localPly)
        net.WriteTable(slcWpnLst)

    net.SendToServer()

end

function NPCWeaponOverrideMenu:addToSelectedWeaponsList(weaponClass)

    local slcWpnLst = self:getSelectedWeaponsList()

    if table.HasValue(slcWpnLst, weaponClass) == false then

        table.insert(slcWpnLst, weaponClass)
        self:sendDataToServer()
        
    end

end

function NPCWeaponOverrideMenu:removeFromSelectedWeaponsList(weaponClass) 

    local slcWpnLst = self:getSelectedWeaponsList()

    if table.HasValue(slcWpnLst, weaponClass) == true then

        for key, value in pairs(slcWpnLst) do 

            if value == weaponClass then

                table.remove(slcWpnLst, key)
                self:sendDataToServer()
            
            end

        end

    end

end

setmetatable(NPCWeaponOverrideMenu, {__call = NPCWeaponOverrideMenu.new})