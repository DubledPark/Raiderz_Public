function NPC_3000011:OnSpawn(SpawnInfo)
	this:SetTimer(1, 6, false)
end

function NPC_3000011:OnTimer(TimerID)
	if (TimerID == 1) then
		this:UseTalentSelf(3000015);
	end
end










