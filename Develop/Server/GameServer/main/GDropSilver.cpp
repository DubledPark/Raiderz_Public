#include "StdAfx.h"
#include "GDropSilver.h"
#include "GLootInfo.h"
#include "GEntityPlayer.h"
#include "GSTLUtil.h"

GDropMoney::GDropMoney()
: m_nMoney(0)
{
}

void GDropMoney::Clear()
{
	m_nMoney = 0;
	m_setAuhorizedCID.clear();
}

void GDropMoney::Drop( CID nBeneficiaryCID, GLootInfo* pLootInfo )
{
	vector<CID> vecBeneficiaryCID;
	vecBeneficiaryCID.push_back(nBeneficiaryCID);

	Drop(vecBeneficiaryCID, pLootInfo);
}

void GDropMoney::Drop(const vector<CID>& vecBeneficiaryCID, GLootInfo* pLootInfo)
{
	if (true == vecBeneficiaryCID.empty()) return;

	for each(LOOT_MONEY_INFO* pLootMoneyInfo in pLootInfo->m_vecLootMoneys)
	{
		if (pLootMoneyInfo->m_fRate < RandomNumber(0, 100)) continue;

		int nMoney = RandomNumber(pLootMoneyInfo->m_nMin, pLootMoneyInfo->m_nMax);

		if (INT_MAX - nMoney < m_nMoney)
		{
			m_nMoney = INT_MAX;
			break;
		}

		m_nMoney += nMoney;
	}

	if (0 != m_nMoney) 
	{
		m_setAuhorizedCID = VectorToSet(vecBeneficiaryCID);
	}	
}

bool GDropMoney::IsAuthorizedCID(CID nCID)
{
	set<CID>::iterator itor = m_setAuhorizedCID.find(nCID);
	if (m_setAuhorizedCID.end() == itor) return false;

	return true;
}

bool GDropMoney::IsEmpty()
{
	return 0 >= m_nMoney;
}

int GDropMoney::GetQuantity()
{
	return m_nMoney;
}

void GDropMoney::GetViewableCID(set<CID>& outsetViewableCID)
{
	for each (CID nSetAuthorizedCID in m_setAuhorizedCID)
	{
		outsetViewableCID.insert(nSetAuthorizedCID);
	}	
}

void GDropMoney::GetAuthorizedCID( set<CID>& outsetAuthorizedCID )
{
	for each (CID nSetAuthorizedCID in m_setAuhorizedCID)
	{
		outsetAuthorizedCID.insert(nSetAuthorizedCID);
	}	
}