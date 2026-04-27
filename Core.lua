local addonName, addonTable = ...
local L = addonTable.L

-- DB layout: TransmogSetHideDB = { showHidden = false, hidden = { [setID] = true, ... } }
local DB

local function InitDB()
    if type(TransmogSetHideDB) ~= "table" then
        TransmogSetHideDB = {}
    end
    if type(TransmogSetHideDB.hidden) ~= "table" then
        TransmogSetHideDB.hidden = {}
    end
    if TransmogSetHideDB.showHidden == nil then
        TransmogSetHideDB.showHidden = false
    end
    DB = TransmogSetHideDB
end

local function IsHidden(setID)
    return DB ~= nil and DB.hidden[setID] == true
end

local function SetHidden(setID, hide)
    DB.hidden[setID] = hide or nil
end

local SetsFrame

local function RefreshSets()
    if SetsFrame then
        SetsFrame:UpdateSets()
    end
end

local function InitBlizzardCollections()
    SetsFrame = WardrobeCollectionFrame and WardrobeCollectionFrame.SetsCollectionFrame
    if not SetsFrame then return end

    -- "Show Hidden" checkbox to the right of the search box
    local showHiddenCB = CreateFrame("CheckButton", "TransmogSetHideToggle", SetsFrame, "UICheckButtonTemplate")
    showHiddenCB:SetSize(24, 24)
    showHiddenCB:SetPoint("LEFT", SetsFrame.SearchBox, "RIGHT", 10, 0)
    showHiddenCB.Text:SetText(L["SHOW_HIDDEN_SETS"])
    showHiddenCB.Text:SetFontObject("GameFontNormalSmall")
    showHiddenCB.Text:ClearAllPoints()
    showHiddenCB.Text:SetPoint("LEFT", showHiddenCB, "RIGHT", 2, 1)
    showHiddenCB:SetChecked(DB.showHidden)
    showHiddenCB:SetScript("OnClick", function(self)
        DB.showHidden = self:GetChecked()
        RefreshSets()
    end)

    -- Hook each recycled scroll frame for right-click menu + tooltip + visual dim
    SetsFrame.ScrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnAcquiredFrame, function(_, frame, elementData)
        frame:RegisterForClicks("LeftButtonUp", "RightButtonUp")

        if not frame.TransmogSetHideHooked then
            frame:HookScript("OnMouseUp", function(self, button)
                if button ~= "RightButton" then return end
                local data = self:GetElementData()
                if not (data and data.setID) then return end

                MenuUtil.CreateContextMenu(self, function(_, rootDescription)
                    local hidden = IsHidden(data.setID)
                    rootDescription:CreateButton(
                        hidden and L["UNHIDE_SET"] or L["HIDE_SET"],
                        function()
                            SetHidden(data.setID, not hidden)
                            RefreshSets()
                        end
                    )
                end)
            end)

            -- Append a red hint line to the set's existing tooltip when hidden
            frame:HookScript("OnEnter", function(self)
                local data = self:GetElementData()
                if data and data.setID and IsHidden(data.setID) and GameTooltip:IsShown() then
                    GameTooltip:AddLine(L["HIDDEN_SET_TOOLTIP"], 1, 0.4, 0.4, true)
                    GameTooltip:Show()
                end
            end)

            frame.TransmogSetHideHooked = true
        end

        -- Dim hidden frames when "Show Hidden" is on
        local data = frame:GetElementData()
        frame:SetAlpha((data and data.setID and IsHidden(data.setID)) and 0.4 or 1.0)
    end)

    -- Remove hidden entries from the DataProvider after each UpdateSets call
    hooksecurefunc(SetsFrame, "UpdateSets", function(self)
        if DB.showHidden then return end

        local dp = self.ScrollBox:GetDataProvider()
        if not dp then return end

        local toRemove = {}
        for _, data in dp:Enumerate() do
            if data and data.setID and IsHidden(data.setID) then
                toRemove[#toRemove + 1] = data
            end
        end
        for _, data in ipairs(toRemove) do
            dp:Remove(data)
        end
    end)
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 == addonName then
            InitDB()
        elseif arg1 == "Blizzard_Collections" then
            InitBlizzardCollections()
        end
    end
end)

-- Handle the case where Blizzard_Collections was already loaded (e.g. /reload)
if C_AddOns.IsAddOnLoaded("Blizzard_Collections") then
    C_Timer.After(0, InitBlizzardCollections)
end
