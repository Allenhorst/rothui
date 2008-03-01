  
  local GetRaidTargetIndex = GetRaidTargetIndex
  local SetRaidTargetIconTexture = SetRaidTargetIconTexture
  
  function pUF:UpdateRaidIcon(unit)
  	if self.unit then
  		local index = GetRaidTargetIndex(self.unit)
  		local icon = self.RaidIcon
  
  		if index then
  			SetRaidTargetIconTexture(icon, index)
  			icon:Show()
  		else icon:Hide() end
  	end
  end