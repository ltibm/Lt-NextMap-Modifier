//#include "../xp_string"
CCVar@ cvar_Enabled;
CCVar@ cvar_Random;
CCVar@ cvar_MapNotFoundAction;

uint currentMapId;
uint currrentRndId;
string currentMap;
string nextMap;
array<string> original_mapCycles;
array<string> random_mapCycles;
bool firstInitial = true;
void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "Lt." );
	g_Module.ScriptInfo.SetContactInfo( "https://steamcommunity.com/id/ibmlt/" );
	g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );
	@cvar_Enabled = CCVar("nextmap_enabled", 1, "0: disabled, 1: Enabled", ConCommandFlag::AdminOnly);
	@cvar_Random = CCVar("nextmap_random", 0, "0: disabled, 1: Enabled(Get Next Map Randomly, Not Shuffled), 2: Enabled(All Maps List Are Shuffled)", ConCommandFlag::AdminOnly);
	@cvar_MapNotFoundAction = CCVar("nextmap_mapnfaction", 1, "0: do nothing(always set first map), 1: Keep previous nextmap cycle, 2: Set Nextmap Randomly", ConCommandFlag::AdminOnly);
	MapInit();
}
HookReturnCode ClientSay( SayParameters@ pParams )
{		
	if(original_mapCycles.length() == 0 || cvar_Enabled.GetInt() == 0) return HOOK_CONTINUE;
	CBasePlayer@ cPlayer = pParams.GetPlayer();
	const CCommand@ sArguments = pParams.GetArguments();
	string allargs = pParams.GetCommand();
	if(allargs.ToLowercase() == "nextmap")
	{
		g_PlayerFuncs.SayTextAll( cPlayer, "nextmap: " + nextMap);
	}
	return HOOK_CONTINUE;
}
void MapInit()
{
	currentMap = string(g_Engine.mapname);
	bool mapCyclesChanged = IsMapCycleChanged();
	if(mapCyclesChanged)
	{
		 original_mapCycles = g_MapCycle.GetMapCycle();
	}
	if(original_mapCycles.length() == 0 || cvar_Enabled.GetInt() == 0) return;
	int mapid = original_mapCycles.find(currentMap);
	if(cvar_Random.GetInt() == 1)
	{
		currentMapId = Math.RandomLong(0, original_mapCycles.length() - 1);
		if(mapid == int(currentMapId)) 	currentMapId++;
	}
	else if(cvar_Random.GetInt() == 2)
	{
		//Refresh random map list
		currrentRndId++;
		if(mapCyclesChanged || random_mapCycles.length() == 0 || currrentRndId >= random_mapCycles.length())
		{
			currrentRndId = 0;
			random_mapCycles.resize(0);
			array<string> temp_mapCycles = original_mapCycles;
			for(uint i = 0; i < temp_mapCycles.length(); i++)
			{
				uint rnd = Math.RandomLong(0, temp_mapCycles.length() - 1);
				random_mapCycles.insertLast(temp_mapCycles[rnd]);
				temp_mapCycles.removeAt(i);
				i--;
			}
		}
		int rndmapid = random_mapCycles.find(currentMap);
		if(rndmapid == -1)
		{
			int nfaction = cvar_MapNotFoundAction.GetInt();
			if(nfaction == 2)
			{
				currrentRndId = Math.RandomLong(0, random_mapCycles.length() - 1);
			}
			else if(nfaction == 1)
			{
				if(currrentRndId == random_mapCycles[currrentRndId]) currentMapId++;
			}
			else
			{
				currrentRndId = 0;
			}
		}
		else if(rndmapid >= 0) 	currrentRndId = rndmapid + 1;
		SetNextMap(random_mapCycles[currrentRndId]);
		firstInitial = false;
		return;
	}
	else
	{

		if(mapid == -1) //Current map if not containing mapcycles
		{
			int nfaction = cvar_MapNotFoundAction.GetInt();
			if(nfaction == 2)
			{
				currentMapId = Math.RandomLong(0, original_mapCycles.length() - 1);
			}
			else if(nfaction == 1)
			{
				if(currentMap == original_mapCycles[currentMapId]) currentMapId++;
			}
			else
			{
				currentMapId = 0;
			}
		}
		else
		{
			currentMapId = mapid + 1;
		}
	}
	if(currentMapId >= original_mapCycles.length())
	{
		currentMapId = 0;
	}
	SetNextMap(original_mapCycles[currentMapId]);
	firstInitial = false;
}
bool IsMapCycleChanged()
{
	if(firstInitial) return true;
	array<string> temp_mapCycles = g_MapCycle.GetMapCycle();
	if(temp_mapCycles.length() != original_mapCycles.length()) return true;
	for(uint i = 0; i < original_mapCycles.length(); i++)
	{
		if(temp_mapCycles.find(original_mapCycles[i]) < 0) return false;
	}
	return true;
}
void SetNextMap(string mapName)
{
	nextMap = mapName;
	g_EngineFuncs.ServerCommand("mp_nextmap_cycle \"" + mapName + "\"\n");
}