--[[-------------------------------------------------------------------------
  Copyright (c) 2006-2008, Trond A Ekseth
  Copyright (c) 2008, p3lim
  Copyright (c) 2008, zork
  All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:

      * Redistributions of source code must retain the above copyright
        notice, this list of conditions and the following disclaimer.
      * Redistributions in binary form must reproduce the above
        copyright notice, this list of conditions and the following
        disclaimer in the documentation and/or other materials provided
        with the distribution.
      * Neither the name of rUnits nor the names of its contributors may
        be used to endorse or promote products derived from this
        software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
  OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
---------------------------------------------------------------------------]]
  
  local table_insert = table.insert
  local UnitBuff = UnitBuff
  local UnitDebuff = UnitDebuff
  local GetTime = GetTime
  local DebuffTypeColor = DebuffTypeColor
  
  local row, icons, button, nb, buff, timeLeft, count, texture
  local dtype, debuff, rank, name, nd, color, nd, duration
  
  local debuffOnEnter = function(self)
  	if(not self:IsVisible()) then return end
  	local unit = self:GetParent():GetParent().unit
  
  	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
  
  	GameTooltip:SetUnitDebuff(unit, self:GetID())
  end
  
  local buffOnEnter = function(self)
  	if(not self:IsVisible()) then return end
  	local unit = self:GetParent():GetParent().unit
  
  	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
  
  	GameTooltip:SetUnitBuff(unit, self:GetID())
  end
  
  local onLeave = function()
  	GameTooltip:Hide()
  end
  
  local createButton = function(self, index, debuff)
  	local button = CreateFrame("Frame", nil, self)
  	button:EnableMouse(true)
  	button:SetID(index)
  
  	button:SetWidth(self.size or 16)
  	button:SetHeight(self.size or 16)
  
  	local cd = CreateFrame("Cooldown", nil, button)
  	cd:SetAllPoints(button)
  
  	local icon = button:CreateTexture(nil, "BACKGROUND")
  	icon:SetAllPoints(button)
  	icon:SetTexCoord(0.1,0.9,0.1,0.9)
    icon:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
    icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
  
  	local count = button:CreateFontString(nil, "OVERLAY")
  	count:SetFontObject(NumberFontNormal)
  	count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 0)
      
  	local texture = button:CreateTexture(nil, "OVERLAY")
  	texture:SetTexture"Interface\\AddOns\\rTextures\\gloss"
  	texture:SetAllPoints(button)
  	
  	if(debuff) then
  		--button.overlay = texture
  		texture:SetVertexColor(0,0,0)
  		button:SetScript("OnEnter", debuffOnEnter)
  	else
  		texture:SetVertexColor(0,0,0)
  		button:SetScript("OnEnter", buffOnEnter)
  	end
  	button:SetScript("OnLeave", onLeave)
  
  	table_insert(self, button)
  
  	button.icon = icon
  	button.count = count
  	button.cd = cd
  
  	return button
  end
  
  function rUnits:SetAuraPosition(unit, nb, nd)
  	icons = self.Buffs
  	if(icons and nb > 0) then
  		for i=1, nb do
  			button = icons[i]
  			button:ClearAllPoints()
  			if(i == 1) then
  				button:SetPoint("BOTTOMLEFT", icons, 3, 0)
  			elseif(i == 11) then
  				button:SetPoint("BOTTOMLEFT", icons[1], "TOPLEFT", 0, 2)
  			elseif(i == 21) then
  				button:SetPoint("BOTTOMLEFT", icons[11], "TOPLEFT", 0, 2)
  			elseif(i == 31) then
  				button:SetPoint("BOTTOMLEFT", icons[21], "TOPLEFT", 0, 2)
  			else
  				button:SetPoint("LEFT", icons[i-1], "RIGHT", 3, 0)
  			end
  		end
  	end
  
  	icons = self.Debuffs
  	if(icons and nd > 0) then
  		for i=1, nd do
  			button = icons[i]
  			button:ClearAllPoints()
  			if(i == 1) then
  				button:SetPoint("TOPLEFT", icons, 3, 0)
  			elseif(i == 11) then
  				button:SetPoint("TOPLEFT", icons[1], "BOTTOMLEFT", 0, -2)		
  			elseif(i == 21) then
  				button:SetPoint("TOPLEFT", icons[11], "BOTTOMLEFT", 0, -2)		
  			elseif(i == 31) then
  				button:SetPoint("TOPLEFT", icons[21], "BOTTOMLEFT", 0, -2)		
  			else
  				button:SetPoint("LEFT", icons[i-1], "RIGHT", 3, 0)
  			end
  		end
  	end
  end
  
  function rUnits:UpdateAura(unit)
  	if(self.unit ~= unit) then return end
  
  	nb = 0
  	icons = self.Buffs
  	if(icons) then
  		for i=1, self.numBuffs do
  			buff = icons[i]
  			name, rank, texture, count, duration, timeLeft = UnitBuff(unit, i)
  
  			if(not buff and not name) then
  				break
  			elseif(name) then
  				if(not buff) then buff = createButton(icons, i) end
  
  				if(duration and duration > 0) then
  					buff.cd:SetCooldown(GetTime()-(duration-timeLeft), duration)
  					buff.cd:Show()
  				else
  					buff.cd:Hide()
  				end
  
  				buff:Show()
  				buff.icon:SetTexture(texture)
  				buff.count:SetText((count > 1 and count) or nil)
  
  				nb = nb + 1
  			elseif(buff) then
  				buff:Hide()
  			end
  		end
  	end
  
  	nd = 0
  	icons = self.Debuffs
  	if(icons) then
  		for i=1, self.numDebuffs do
  			debuff = icons[i]
  			name, rank, texture, count, dtype, duration, timeLeft = UnitDebuff(unit, i)
  
  			if(not debuff and not name) then
  				break
  			elseif(name) then
  				if(not debuff) then debuff = createButton(icons, i, true) end
  
  				if(duration and duration > 0) then
  					debuff.cd:SetCooldown(GetTime()-(duration-timeLeft), duration)
  					debuff.cd:Show()
  				else
  					debuff.cd:Hide()
  				end
  
  				debuff:Show()
  				debuff.icon:SetTexture(texture)
  
  				color = DebuffTypeColor[dtype or "none"]
  				--debuff.overlay:SetVertexColor(color.r, color.g, color.b)
  				debuff.count:SetText((count > 1 and count) or nil)
  
  				nd = nd + 1
  			elseif(debuff) then
  				debuff:Hide()
  			end
  		end
  	end
  
  	self:SetAuraPosition(unit, nb, nd)
  end