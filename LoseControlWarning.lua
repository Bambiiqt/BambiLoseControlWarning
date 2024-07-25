--GIT HUB

local scf = { }
local hieght = 30
local width = 30

local spellIds = {
		--["Unstable Affliction"] = "True",
		[233490] = "True", -- UA
		[233497] = "True", -- UA
		[233496] = "True", -- UA
		[233498] = "True", -- UA
		[233499] = "True", -- UA
		[316099] = "True", -- UA
		[342938] = "True", -- UA Shadowlands
		[316099] = "True", -- UA
		[43522] = "True", -- UA
		[34438] = "True", -- UA
		[34439] = "True", -- UA
		[251502] = "True", -- UA
		[65812] = "True", -- UA
		[35183] = "True", -- UA
		[211513] = "True", -- UA
		[285142] = "True", -- UA
		[285143] = "True", -- UA
		[285144] = "True", -- UA
		[285145] = "True", -- UA
		[285146] = "True", -- UA
		[34914] = "True", -- VT
}

local UnitAura = UnitAura
if UnitAura == nil then
  --- Deprecated in 10.2.5
  UnitAura = function(unitToken, index, filter)
		local aura = C_UnitAuras.GetAuraDataByIndex(unitToken, index, filter)
		if not aura then
			return nil;
		end

		return aura.name, aura.icon, aura.applications, aura.dispelName, aura.duration, aura.expirationTime, aura.sourceUnit, aura.isStealable, nil, aura.spellId
	end
end

local LoseControlWarning = CreateFrame('Frame')
LoseControlWarning:SetScript('OnEvent', function(self, event, arg1, arg2)
	if event == 'PLAYER_ENTERING_WORLD' then LoseControlWarning:PLAYER_ENTERING_WORLD()
	elseif event == 'GROUP_ROSTER_UPDATE' then LoseControlWarning:GROUP_ROSTER_UPDATE()
	elseif event == 'GROUP_JOINED' then LoseControlWarning:GROUP_ROSTER_UPDATE()
	elseif event == "UNIT_AURA" then LoseControlWarning:UNIT_AURA(arg1)
	end
end)

LoseControlWarning:RegisterEvent('PLAYER_ENTERING_WORLD')
LoseControlWarning:RegisterEvent("GROUP_ROSTER_UPDATE")
LoseControlWarning:RegisterEvent("GROUP_JOINED")

function LoseControlWarning:PLAYER_ENTERING_WORLD()
	local inInstance, instanceType = IsInInstance()
	local GrSize = GetNumGroupMembers()
	if GrSize <= 5 and (instanceType ~= "pvp" or instanceType ~= "raid") then
		LoseControlWarning:RegisterEvent("UNIT_AURA")
		LoseControlWarning:UNIT_AURA("player")
		LoseControlWarning:UNIT_AURA("party1")
		LoseControlWarning:UNIT_AURA("party2")
		LoseControlWarning:UNIT_AURA("party3")
		LoseControlWarning:UNIT_AURA("party4")
	else
		LoseControlWarning:UnregisterEvent("UNIT_AURA")
		LoseControlWarning:Reset()
	end
end

function LoseControlWarning:GROUP_ROSTER_UPDATE()
	local inInstance, instanceType = IsInInstance()
	local GrSize = GetNumGroupMembers()
	if GrSize <= 5 and (instanceType ~= "pvp" or instanceType ~= "raid") then
		LoseControlWarning:RegisterEvent("UNIT_AURA")
		LoseControlWarning:UNIT_AURA("player")
		LoseControlWarning:UNIT_AURA("party1")
		LoseControlWarning:UNIT_AURA("party2")
		LoseControlWarning:UNIT_AURA("party3")
		LoseControlWarning:UNIT_AURA("party4")
	else
		LoseControlWarning:UnregisterEvent("UNIT_AURA")
		LoseControlWarning:Reset()
	end
end

function LoseControlWarning:Reset()
	for i = 1, #scf do
		local unitId = "party"..i
		if scf[unitId] then
			for j = 1, #scf[unitId] do
				if scf[unitId][j] then
					scf[unitId][j]:Hide()
					scf[unitId][j] = nil
				end
			end
			scf[unitId] = nil
		end
	end
	local unitId = "player"
	if scf[unitId] then
		for j = 1, #scf[unitId] do
			if scf[unitId][j] then
				scf[unitId][j]:Hide()
				scf[unitId][j] = nil
			end
		end
		scf[unitId] = nil
	end
end

function LoseControlWarning:CreateFrame(unitId, j)
	local relativeFrame, relativePoint, Point, id, LoseControlparty, PartyAnchor 
	scf[unitId][j] = CreateFrame("Frame", "LCWarning"..j..unitId, UIParent)
	scf[unitId][j]:SetHeight(hieght)
	scf[unitId][j]:SetWidth(width)
	scf[unitId][j].texture = scf[unitId][j]:CreateTexture(nil, 'BACKGROUND')
	scf[unitId][j].texture:SetAllPoints(scf[unitId][j])
	scf[unitId][j].texture:SetTexCoord(0.01, .99, 0.01, .99) -- smallborder
	scf[unitId][j].cooldown = CreateFrame("Cooldown", nil, scf[unitId][j], 'CooldownFrameTemplate')
	scf[unitId][j].cooldown:SetEdgeTexture("Interface\\Cooldown\\edge")    --("Interface\\Cooldown\\edge-LoC") Blizz LC CD
	scf[unitId][j].cooldown:SetDrawSwipe(true)
	scf[unitId][j].cooldown:SetDrawEdge(false)
	scf[unitId][j].cooldown:SetSwipeColor(0.17, 0, 0)
	scf[unitId][j].cooldown:SetReverse(true) --will reverse the swipe if actionbars or debuff, by default bliz sets the swipe to actionbars if this = true it will be set to debuffs
	scf[unitId][j].cooldown:SetDrawBling(false)
	scf[unitId][j].cooldown:SetAllPoints(scf[unitId][j])
	scf[unitId][j].count = scf[unitId][j]:CreateFontString(nil, "OVERLAY","NumberFontNormal");
	scf[unitId][j].count:SetPoint("BOTTOMRIGHT",-2,1);
	scf[unitId][j].count:SetJustifyH("RIGHT");
	if j == 1 then
		if unitId ~= "player" then
			id = strmatch(unitId, '%d')
			LoseControlparty = _G["LoseControlparty"..id]
			if unitId == "party1" then PartyAnchor = PartyAnchor1 end
			if unitId == "party2" then PartyAnchor = PartyAnchor2 end
			if unitId == "party3" then PartyAnchor = PartyAnchor3 end
			if unitId == "party4" then PartyAnchor = PartyAnchor4 end
			LoseControlparty:HookScript("OnShow", function(self)
				relativeFrame = LoseControlparty;relativePoint = "BOTTOMLEFT";Point = "BOTTOMRIGHT"
				scf[unitId][j]:ClearAllPoints()
				scf[unitId][j]:SetParent(relativeFrame)
				scf[unitId][j]:SetPoint(Point, relativeFrame, relativePoint, 0, 0)
			end)
			LoseControlparty:HookScript("OnHide", function(self)
				relativeFrame = PartyAnchor;relativePoint = "BOTTOMRIGHT";Point = "BOTTOMRIGHT"
				scf[unitId][j]:ClearAllPoints()
				scf[unitId][j]:SetParent(relativeFrame)
				scf[unitId][j]:SetPoint(Point, relativeFrame, relativePoint, 0, 0)
			end)
			scf[unitId][j]:SetScript("OnShow", function()
				if LoseControlparty:IsShown() then
					relativeFrame = LoseControlparty;relativePoint = "BOTTOMLEFT";Point = "BOTTOMRIGHT"
				else
					relativeFrame = PartyAnchor;relativePoint = "BOTTOMRIGHT";Point = "BOTTOMRIGHT"
				end
				scf[unitId][j]:ClearAllPoints()
				scf[unitId][j]:SetParent(relativeFrame)
				scf[unitId][j]:SetPoint(Point, relativeFrame, relativePoint, 0, 0)
			end)
		end
		if unitId == "player" then
			relativeFrame = PartyAnchor5
			relativePoint = "BOTTOMRIGHT"
			Point = "BOTTOMRIGHT"
		 elseif strmatch(unitId, "party") then
			id = strmatch(unitId, '%d')
			LoseControlparty = _G["LoseControlparty"..id]
			if unitId == "party1" then PartyAnchor = PartyAnchor1 end
			if unitId == "party2" then PartyAnchor = PartyAnchor2 end
			if unitId == "party3" then PartyAnchor = PartyAnchor3 end
			if unitId == "party4" then PartyAnchor = PartyAnchor4 end
			if LoseControlparty:IsShown() then
				relativeFrame = LoseControlparty
				relativePoint = "BOTTOMLEFT"
				Point = "BOTTOMRIGHT"
			else
				relativeFrame = PartyAnchor
				relativePoint = "BOTTOMRIGHT"
				Point = "BOTTOMRIGHT"
			end
		end
		scf[unitId][j]:ClearAllPoints()
		scf[unitId][j]:SetParent(relativeFrame)
		scf[unitId][j]:SetPoint(Point, relativeFrame, relativePoint, 0, 0)
	else
		scf[unitId][j]:SetParent(scf[unitId][j-1])
		scf[unitId][j]:SetPoint("BOTTOMRIGHT", scf[unitId][j-1], "BOTTOMLEFT",0,0)
	end
end

function LoseControlWarning:UNIT_AURA(unitId)
	if (unitId == "player" or strmatch(unitId, "party")) and not strmatch(unitId, "partypet") then
		local j = 1;
		if not scf[unitId] then scf[unitId] = {} end
		for i = 1, 40 do
			local name, icon, count, _, duration, expirationTime, _, _, _, spellId = UnitAura(unitId, i,  "HARMFUL")
			if not name then break end
			if spellIds[spellId] or spellIds[name] then
				if not scf[unitId][j] then 
					LoseControlWarning:CreateFrame(unitId, j)
				end
				scf[unitId][j].texture:SetTexture(icon)
				local enabled = expirationTime and expirationTime ~= 0;
				if enabled then
					local startTime = expirationTime - duration;
					scf[unitId][j].cooldown:SetCooldown( startTime, duration)
				end
				if count then
					if ( count > 1 ) then
						local countText = count
						if ( count >= 100 ) then
							countText = BUFF_STACKS_OVERFLOW
						end
						scf[unitId][j].count:Show();
						scf[unitId][j].count:SetText(countText)
					else
					scf[unitId][j].count:Hide();
					end
				end
				scf[unitId][j]:Show();
				j = j + 1
			end
		end
		for i = j, #scf[unitId] do
			if scf[unitId][i] then
				scf[unitId][i]:Hide()
			end
		end
	end
end
