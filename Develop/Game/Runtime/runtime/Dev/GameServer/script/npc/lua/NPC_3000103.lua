function NPC_3000103:OnSpawn(SpawnInfo)
	this:SetTimer(1, 10, false)
end

function NPC_3000103:OnTimer(TimerID)
	if (TimerID == 1) then
		this:UseTalentSelf(3000011);
	end
end










