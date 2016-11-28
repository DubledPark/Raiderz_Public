#pragma once

class GEntityPlayer;

class GPlayerFalling : public MTestMemPool<GPlayerFalling>
{
public:
	GPlayerFalling(GEntityPlayer* pOwner);
	virtual ~GPlayerFalling(void);

	void EndFalling(bool bIsFallenOnWater, float fFallingHeight);

private:
	GEntityPlayer*	m_pOwner;

	bool _EndFalling(bool bIsFallenOnWater, float fFallingHeight);
	void RouteFallingDamage(int nFallingDamage);
};
