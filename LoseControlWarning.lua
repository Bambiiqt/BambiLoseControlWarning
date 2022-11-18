--GIT HUB

local scf = { }
local buffs1 = {}
local buffs2 = {}

local hieght = 30
local width = 30

local spellIds = {
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


local LoseControlWarning = CreateFrame('Frame')
LoseControlWarning:SetScript('OnEvent', function(self, event, ...)
	self[event](self, ...)
end)

LoseControlWarning:RegisterEvent('PLAYER_ENTERING_WORLD')
LoseControlWarning:RegisterEvent("GROUP_ROSTER_UPDATE")
LoseControlWarning:RegisterEvent("GROUP_JOINED")

LoseControlparty1:HookScript("OnShow", function(self)
	LoseControlWarning:UpdateFrames("party1")
end)
LoseControlparty2:HookScript("OnShow", function(self)
	LoseControlWarning:UpdateFrames("party2")
end)
LoseControlparty4:HookScript("OnShow", function(self)
	LoseControlWarning:UpdateFrames("party2")
end)
LoseControlparty3:HookScript("OnShow", function(self)
	LoseControlWarning:UpdateFrames("party2")
end)

LoseControlparty1:HookScript("OnHide", function(self)
	LoseControlWarning:UpdateFrames("party1")
end)
LoseControlparty2:HookScript("OnHide", function(self)
	LoseControlWarning:UpdateFrames("party2")
end)
LoseControlparty3:HookScript("OnHide", function(self)
	LoseControlWarning:UpdateFrames("party2")
end)
LoseControlparty4:HookScript("OnHide", function(self)
	LoseControlWarning:UpdateFrames("party2")
end)

function LoseControlWarning:PLAYER_ENTERING_WORLD()
	local inInstance, instanceType = IsInInstance()
	local GrSize = GetNumGroupMembers()
	if GrSize <= 5 and (instanceType ~= "pvp" or instanceType ~= "raid") then
		LoseControlWarning:RegisterUnitEvent('UNIT_AURA', "player")
		LoseControlWarning:UpdateFrames("player")
		for i = 1, GetNumGroupMembers() do
			local unitId = "party"..i
			if UnitExists(unitId) then
				LoseControlWarning:RegisterUnitEvent('UNIT_AURA', unitId)
				LoseControlWarning:UpdateFrames(unitId)
			end
		end
	else
		LoseControlWarning:UnregisterEvent("UNIT_AURA")
	end
end

function LoseControlWarning:GROUP_ROSTER_UPDATE()
	local inInstance, instanceType = IsInInstance()
	local GrSize = GetNumGroupMembers()
	if GrSize <= 5 and (instanceType ~= "pvp" or instanceType ~= "raid") then
		LoseControlWarning:RegisterUnitEvent('UNIT_AURA', "player")
		LoseControlWarning:UpdateFrames("player")
		for i = 1, GetNumGroupMembers() do
			local unitId = "party"..i
			if UnitExists(unitId) then
				LoseControlWarning:RegisterUnitEvent('UNIT_AURA', unitId)
				LoseControlWarning:UpdateFrames(unitId)
			end
		end
	else
		LoseControlWarning:UnregisterEvent("UNIT_AURA")
	end
end

function LoseControlWarning:GROUP_JOINED()
	self:GROUP_ROSTER_UPDATE()
end

local function compare(t1,t2,ignore_mt)
   local ty1 = type(t1)
   local ty2 = type(t2)
   if ty1 ~= ty2 then return false end
   -- non-table types can be directly compared
   if ty1 ~= 'table' and ty2 ~= 'table' then return t1 == t2 end
   -- as well as tables which have the metamethod __eq
   local mt = getmetatable(t1)
   if not ignore_mt and mt and mt.__eq then return t1 == t2 end
   for k1,v1 in pairs(t1) do
      local v2 = t2[k1]
      if v2 == nil or not compare(v1,v2) then return false end
   end
   for k2,v2 in pairs(t2) do
      local v1 = t1[k2]
      if v1 == nil or not compare(v1,v2) then return false end
   end
   return true
end

function LoseControlWarning:UNIT_AURA(unitId)
	local k = 1

	if not buffs1[unitId] then
		buffs1[unitId] = {}
	end
	if not buffs2[unitId] then
		buffs2[unitId] = {}
	end

	if #buffs1[unitId] > 0 then
		for i = 1, #buffs1[unitId] do
				buffs1[unitId][i] = nil
		end
	end

	for i = 1, 40 do
		local name, icon, count, _, duration, expirationTime, _, _, _, spellId = UnitAura(unitId, i,  "HARMFUL")
		if not spellId then break end
		if spellIds[spellId] then
		table.insert(buffs1[unitId], k , expirationTime )
			k = k + 1
		end
	end

	if #buffs1[unitId] ~= #buffs2[unitId] then
		LoseControlWarning:UpdateFrames(unitId)
		if #buffs2[unitId] > 0 then
			for i = 1, #buffs2[unitId] do
				buffs2[unitId][i] = nil
			end
		end
		if #buffs1[unitId] > 0 then
			for i = 1, #buffs1[unitId] do
				buffs2[unitId][i] = buffs1[unitId][i]
			end
  	end
	else
		if compare(buffs1[unitId], buffs2[unitId]) then
		else
			LoseControlWarning:UpdateFrames(unitId)
			if #buffs2[unitId] > 0 then
				for i = 1, #buffs2[unitId] do
					buffs2[unitId][i] = nil
				end
			end
			if #buffs1[unitId] > 0 then
				for i = 1, #buffs1[unitId] do
					buffs2[unitId][i] = buffs1[unitId][i]
				end
			end
		end
	end
end

function LoseControlWarning:UpdateFrames(unitId)
	local j = 1; local relativeFrame, relativePoint, Point
	for i = 1, 40 do
		local name, icon, count, _, duration, expirationTime, _, _, _, spellId = UnitAura(unitId, i,  "HARMFUL")
		if scf[i..unitId] then
			scf[i..unitId]:Hide()
		end
		if spellIds[spellId] then
			if unitId == "player" or strmatch(unitId, "party") then
				if not scf[j..unitId] then
					scf[j..unitId] = CreateFrame("Frame", "LCWarning"..j..unitId, UIParent)
					scf[j..unitId]:SetHeight(hieght)
					scf[j..unitId]:SetWidth(width)
					scf[j..unitId].texture = scf[j..unitId]:CreateTexture(nil, 'BACKGROUND')
					scf[j..unitId].texture:SetAllPoints(scf[j..unitId])
					scf[j..unitId].texture:SetTexCoord(0.01, .99, 0.01, .99) -- smallborder
					scf[j..unitId].cooldown = CreateFrame("Cooldown", nil, scf[j..unitId], 'CooldownFrameTemplate')
					scf[j..unitId].cooldown:SetEdgeTexture("Interface\\Cooldown\\edge")    --("Interface\\Cooldown\\edge-LoC") Blizz LC CD
					scf[j..unitId].cooldown:SetDrawSwipe(true)
					scf[j..unitId].cooldown:SetDrawEdge(false)
					scf[j..unitId].cooldown:SetSwipeColor(0.17, 0, 0)
					scf[j..unitId].cooldown:SetReverse(true) --will reverse the swipe if actionbars or debuff, by default bliz sets the swipe to actionbars if this = true it will be set to debuffs
					scf[j..unitId].cooldown:SetDrawBling(false)
					scf[j..unitId].cooldown:SetAllPoints(scf[j..unitId])
					scf[j..unitId].count = scf[j..unitId]:CreateFontString(nil, "OVERLAY","NumberFontNormal");
					scf[j..unitId].count:SetPoint("BOTTOMRIGHT",-2,1);
					scf[j..unitId].count:SetJustifyH("RIGHT");
				end
				scf[j..unitId].texture:SetTexture(icon)
				scf[j..unitId].cooldown:SetCooldown( expirationTime - duration, duration)
				if count then
					if ( count > 1 ) then
						local countText = count
						if ( count >= 100 ) then
						 countText = BUFF_STACKS_OVERFLOW
						end
						scf[j..unitId].count:Show();
						scf[j..unitId].count:SetText(countText)
					else
				  	scf[j..unitId].count:Hide();
					end
				end
				if unitId == "player" then
					relativeFrame = PartyAnchor5
					relativePoint = "BOTTOMRIGHT"
					Point = "BOTTOMRIGHT"
		 		elseif strmatch(unitId, "party") then
					local id = strmatch(unitId, '%d')
					LoseControlparty, PartyAnchor = _G["LoseControlparty"..id], _G["PartyAnchor"..id]
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
				if j == 1 then
					scf[j..unitId]:ClearAllPoints()
					scf[j..unitId]:SetParent(relativeFrame)
					scf[j..unitId]:SetPoint(Point, relativeFrame, relativePoint, 0, 0)
				else
					scf[j..unitId]:SetParent(relativeFrame)
					scf[j..unitId]:SetPoint("BOTTOMRIGHT", scf[(j-1)..unitId], "BOTTOMLEFT",0,0)
				end
				scf[j..unitId]:Show();
				j = j + 1
			end
		end
  end
end
