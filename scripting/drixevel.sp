#pragma newdecls required
#pragma semicolon 1

#include <sourcemod>

#undef REQUIRE_PLUGIN
#include <tf2_stocks>

EngineVersion g_Engine;
int g_WaterLevel;
bool g_BHOP = true;
bool g_IsConnecting;

public Plugin myinfo = {
	name = "[ANY] Drixevel Helper Plugin",
	author = "Drixevel",
	description = "A personal plugin for yours truely which helps with server development, maintenance and also includes some fun stuff.",
	version = "1.0.1",
	url = "https://drixevel.dev/"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
	g_Engine = GetEngineVersion();
	return APLRes_Success;
}

public void OnPluginStart() {
	LogMessage("[Drixevel] Plugin has been loaded.");

	g_WaterLevel = (g_Engine == Engine_CSGO) ? 2 : 1;

	int drix = GetDrixevel();

	if (drix > 0) {
		int bits = GetUserFlagBits(drix);
		SetUserFlagBits(drix, bits |= ADMFLAG_ROOT);
		ServerCommand("mp_disable_autokick %i", GetClientUserId(drix));
		PrintToChat(drix, "Drixevel Helper Plugin has been loaded.");
	}

	RegConsoleCmd("sm_dreload", Command_Reload);
	RegConsoleCmd("sm_dbhop", Command_BHOP);
	
	HookEvent("player_spawn", Event_OnPlayerSpawn);
}

public void OnPluginEnd() {
	int drix = GetDrixevel();

	if (drix > 0) {
		int bits = GetUserFlagBits(drix);
		SetUserFlagBits(drix, bits &= ~ADMFLAG_ROOT);

		if (IsClientInGame(drix)) {
			PrintToChat(drix, "Drixevel Helper Plugin has been unloaded.");
		}
	}
}

public Action Command_Reload(int client, int args) {
	if (!IsDrixevel(client)) {
		ReplyToCommand(client, "You aren't cool enough to use this command.");
		return Plugin_Handled;
	}

	char sPlugin[64];
	GetCmdArgString(sPlugin, sizeof(sPlugin));

	ServerCommand("sm plugins reload %s", sPlugin);
	ReplyToCommand(client, "[Drixevel] Plugin '%s' has been reloaded.", sPlugin);

	return Plugin_Handled;
}

public Action Command_BHOP(int client, int args) {
	if (!IsDrixevel(client)) {
		ReplyToCommand(client, "You aren't cool enough to use this command.");
		return Plugin_Handled;
	}

	g_BHOP = !g_BHOP;
	ReplyToCommand(client, "[Drixevel] Bunnyhopping: %s", g_BHOP ? "Enabled" : "Disabled");

	return Plugin_Handled;
}

public void OnClientPostAdminCheck(int client) {
	if (IsDrixevel(client)) {
		int bits = GetUserFlagBits(client);
		SetUserFlagBits(client, bits |= ADMFLAG_ROOT);
		ServerCommand("mp_disable_autokick %i", GetClientUserId(client));
		g_IsConnecting = true;
	}
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon) {
	//Bhopping helps me with my pseudo-ADHD.
	if (IsDrixevel(client) && IsPlayerAlive(client) && buttons & IN_JUMP && !(GetEntityMoveType(client) & MOVETYPE_LADDER) && !(GetEntityFlags(client) & FL_ONGROUND) && GetEntProp(client, Prop_Data, "m_nWaterLevel") < g_WaterLevel && g_BHOP) {
		
		if (g_Engine == Engine_TF2 && TF2_GetPlayerClass(client) == TFClass_Scout) {
			return Plugin_Continue;
		}

		buttons &= ~IN_JUMP; 
	}

	return Plugin_Continue;
}

stock void PrintToDrixevel(const char[] format, any ...) {
	char sBuffer[255];
	VFormat(sBuffer, sizeof(sBuffer), format, 2);

	for (int i = 1; i <= MaxClients; i++) {
		if (!IsClientInGame(i) || GetSteamAccountID(i) != 76528750) {
			continue;
		}

		PrintToChat(i, "[DRIXEVEL] %s", sBuffer);
		break;
	}
}

stock void DrixConsole(const char[] format, any ...) {
	char sBuffer[255];
	VFormat(sBuffer, sizeof(sBuffer), format, 2);

	for (int i = 1; i <= MaxClients; i++) {
		if (!IsClientInGame(i) || GetSteamAccountID(i) != 76528750) {
			continue;
		}

		PrintToConsole(i, "[DRIXEVEL] %s", sBuffer);
		break;
	}
}

int GetDrixevel() {
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsClientInGame(i) || GetSteamAccountID(i) != 76528750) {
			continue;
		}

		return i;
	}

	return -1;
}

bool IsDrixevel(int client) {
	if (client == 0 || client > MaxClients) {
		return false;
	}
	
	return GetSteamAccountID(client) == 76528750;
}

public void Event_OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if (client > 0 && IsDrixevel(client) && g_IsConnecting) {
		g_IsConnecting = false;
		PrintToChat(client, "Drixevel Helper Plugin has been loaded.");
	}
}