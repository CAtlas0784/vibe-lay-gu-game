"use strict";

const fs = require("fs");
const path = require("path");
const fengari = require("fengari");
const { lua, lauxlib, to_luastring } = fengari;
const { config, resolveProjectPath } = require("../private_server_config");

const clientVersion = String(config.client.version);
const fastPatchRoot = path.join(resolveProjectPath(config.paths.runtimeFastpatch), clientVersion);
const luaSrcRoot = resolveProjectPath("lua"); // decompiled client Lua source
const fileName = "LuaFiles#LX6#SGUI#StoreDefine#UidLayerPanelStore.lua";
const labelEnabled = config.ui?.uidLabel?.enabled !== false;
const label = labelEnabled ? String(config.ui?.uidLabel?.text || "นี่คือเวอร์ชั่น DEV ที่ไม่ได้รับคุณภาพจากเกม Ananta GAY") : "";
const removeStock = config.ui?.removeStockConfidentialLabel !== false;

fs.rmSync(fastPatchRoot, { recursive: true, force: true });
fs.mkdirSync(fastPatchRoot, { recursive: true });

const qLabel = JSON.stringify(label);
const luaSource = `-- Ananta private-server fastpatch for client ${clientVersion}\n` +
`-- Persistent UID/watermark override only. Gameplay Lua is untouched.\n\n` +
`local CSPauseManager = LX6.Engine.PauseManager\n` +
`C_UidLayerPanelStore = DefClass("C_UidLayerPanelStore", C_UidLayerPanelStore, C_StoreGroup)\n` +
`GroupName2Class.UidLayerPanelStore = C_UidLayerPanelStore\n` +
`local M = C_UidLayerPanelStore\n` +
`local PRIVATE_SERVER_LABEL = ${qLabel}\n` +
`local REMOVE_STOCK_LABEL = ${removeStock ? "true" : "false"}\n\n` +
`local function ApplyPrivateServerText(self)\n` +
`    if not self or not self.bindData then return end\n` +
`    local login = gPlayerManager and gPlayerManager.infoLogin and gPlayerManager.infoLogin.bindData or nil\n` +
`    local pid = login and login.pid or nil\n` +
`    self.bindData.uidLabel = pid ~= nil and ("UID:" .. ulong.tostring(pid)) or ""\n` +
`    if REMOVE_STOCK_LABEL then self.bindData.confidentialLabel = PRIVATE_SERVER_LABEL end\n` +
`    self.bindData.versionCtrl = 0\n` +
`    self.bindData.showUID = 0\n` +
`end\n\n` +
`M.ctor = function(self)\n` +
`    self.msgEvents = { [gEventConstants.L50_BEFORE_SWITCH_SCENE] = self.CreateAction(self, "OnBeforeSwitchScene") }\n` +
`end\n\n` +
`M.OnAwake = function(self)\n` +
`    self.RegisterMessageEvents(self, self.msgEvents)\n` +
`    gLuaUIMgr.uidLayerPanelStore = self\n` +
`    ApplyPrivateServerText(self)\n` +
`end\n\n` +
`M.OnShow = function(self, panelId, data)\n` +
`    ApplyPrivateServerText(self)\n` +
`end\n\n` +
`M.OnClose = function(self) end\n\n` +
`M.OnDestroy = function(self)\n` +
`    self.ClearMessageEvents(self)\n` +
`    gLuaUIMgr.uidLayerPanelStore = nil\n` +
`end\n\n` +
`M.OnActiveDeviceChange = function(self, device) end\n\n` +
`M.ShowPauseInfo = function(self, serveSpeed)\n` +
`    if not gGameManager.Env.isEditor or not gCS.PauseManager.showPauseTip then\n` +
`        self.bindData.pauseLabel = ""\n` +
`        return\n` +
`    end\n` +
`    local clientSpeed = CSPauseManager.Instance.PauseSpeed\n` +
`    local text = ""\n` +
`    if clientSpeed then\n` +
`        if clientSpeed ~= 0 then\n` +
`            text = text .. "客户端暂停 "\n` +
`        elseif clientSpeed >= 1 then\n` +
`            text = text .. "客户端时缓：" .. gString.Format("%.2f", clientSpeed) .. " "\n` +
`        end\n` +
`    end\n` +
`    if serveSpeed then text = text .. "服务端暂停" else text = "" end\n` +
`    self.bindData.pauseLabel = text\n` +
`end\n\n` +
`M.RefreshUID = function(self) ApplyPrivateServerText(self) end\n` +
`M.RefreshVersion = function(self) ApplyPrivateServerText(self) end\n` +
`M.RefreshUIDDisplay = function(self, show)\n` +
`    if self and self.bindData then self.bindData.showUID = 0 end\n` +
`end\n\n` +
`M.OnBeforeSwitchScene = function(self, eventId, switchSceneEventParams)\n` +
`    ApplyPrivateServerText(self)\n` +
`end\n\n` +
`M.OnLanguageChange = function(self, lang) ApplyPrivateServerText(self) end\n`;
const L = lauxlib.luaL_newstate();
const luaBytes = to_luastring(luaSource);
const status = lauxlib.luaL_loadbuffer(L, luaBytes, luaBytes.length, to_luastring(fileName));
if (status !== lua.LUA_OK) throw new Error("generated UidLayerPanelStore.lua failed Lua syntax validation");

fs.writeFileSync(path.join(fastPatchRoot, fileName), luaSource, "utf8");

// GameSwitch defaults: the private server has no GameSwitch RPC, so the client's
// gGameSwitch table would stay empty and every switch-gated phone app/panel would
// report "This feature is temporarily unavailable". Pre-seed all retail switches
// to open (real-money charge stays closed). Server-side SyncGameSwitchToClient
// still wins whenever it arrives, because M.Sync overwrites these defaults.
const forceSwitches = config.ui?.forceEnableGameSwitches !== false;
const switchFileName = "LuaFiles#LX6#Manager#ClientGameSwitch.lua";
// NOTE: EnableCharge is intentionally absent (real-money flow).
const gameSwitchDefaults = [
  "EnableBuzzCenter", "EnableMall", "EnableMallBundle", "EnableMallRecommend",
  "EnableMallDirectSale", "EnableCheckIn", "EnableTime", "EnableDossier",
  "EnableRadiantChest", "EnableCloset", "EnableGachaSystem", "EnableSeasonalBattlePass",
  "EnableBBChat", "EnableScope", "EnableParty", "EnableSpiritTalent",
  "EnablePhoto", "EnableMail", "EnablePhone", "EnableFriends",
  "EnableAchievement", "EnableTutorial", "EnableCityPedia", "EnableNotices",
  "EnableCustom", "EnableInteractionAction", "EnableDutyTerminal", "EnableCatExpress",
  "EnableEonBug", "EnableJanitor", "EnableRadioStation", "EnableBubble",
  "EnableFashionStore", "Enable4SStore", "EnableProfile", "EnableClub",
  "EnableRanking", "EnableAkashicSystem", "EnableActivity",
];
let switchNote = "GameSwitch defaults: skipped (ui.forceEnableGameSwitches=false).\n";
if (forceSwitches) {
  const switchSource = `-- Ananta private-server fastpatch for client ${clientVersion}\n` +
`-- GameSwitch defaults, Gacha active pool bypass, and safety hooks.\n\n` +
`local M = {}\n\n` +
`M.Sync = function(key, value)\n` +
`    M[key] = value\n\n` +
`    pcall(function()\n` +
`        if gMessageManager and gEventConstants and gEventConstants.ON_GM_GAME_SWITCH_CHANGE then\n` +
`            gMessageManager:SendMessage(gEventConstants.ON_GM_GAME_SWITCH_CHANGE)\n` +
`        end\n` +
`    end)\n` +
`end\n\n` +
gameSwitchDefaults.map((name) => `M.${name} = true\n`).join("") +
`\n` +
`gGameSwitch = M\n\n` +
`-- Bypass CBT date expiration for Gacha pools and unlock all map/systems\n` +
`local function ApplyAllGlobalHooks()\n` +
`    pcall(function()\n` +
`        if C_GachaManager then\n` +
`            C_GachaManager.IsPoolActive = function() return true end\n` +
`            C_GachaManager.CheckHasActiveClosetPool = function() return true end\n` +
`        end\n` +
`    end)\n` +
`    pcall(function()\n` +
`        if gBlockMgr then\n` +
`            gBlockMgr.IsBlockUnlocked = function(self, blockId) return true end\n` +
`        end\n` +
`    end)\n` +
`    pcall(function()\n` +
`        if MapView then\n` +
`            MapView.InFog = function(self, instanceId) return false end\n` +
`            MapView.SetFogEnable = function(self, enable) self.enableFog = false end\n` +
`        end\n` +
`    end)\n` +
`    pcall(function()\n` +
`        if gMapSystem_FogMap then\n` +
`            gMapSystem_FogMap.IsUnlocked = function(self, sceneId, x, z) return true end\n` +
`        end\n` +
`    end)\n` +
`    pcall(function()\n` +
`        if gMapUtils then\n` +
`            gMapUtils.IsEntranceUnlocked = function(self, id) return true end\n` +
`            gMapUtils.IsEntranceVisible = function(self, id) return true end\n` +
`            gMapUtils.IsInUnlockBlockNear = function(self, blockId) return true end\n` +
`        end\n` +
`    end)\n` +
`    pcall(function()\n` +
`        if C_SystemUnlockMgr then\n` +
`            C_SystemUnlockMgr.IsUnlock = function(self, id) return true end\n` +
`            C_SystemUnlockMgr.IsUnlockGroup = function(self, ids) return true end\n` +
`        end\n` +
`    end)\n` +
`    pcall(function()\n` +
`        if C_CharMotionListPanelStore then\n` +
`            C_CharMotionListPanelStore.CheckActionHasUnlocked = function(self, id) return true end\n` +
`            C_CharMotionListPanelStore.CheckHasMeetFavor = function(self, id) return true end\n` +
`        end\n` +
`    end)\n` +
`    pcall(function()\n` +
`        if gMainPhoneUtils then\n` +
`            gMainPhoneUtils.CheckSkinPartAvailable = function(targetSkinPartId) return true end\n` +
`            gMainPhoneUtils.CheckAppCanShow = function(appId) return true end\n` +
`            gMainPhoneUtils.CheckAppCanUse = function(appId) return true end\n` +
`            gMainPhoneUtils.CheckAppSystemUnlocked = function(appId) return true end\n` +
`        end\n` +
`    end)\n` +
`    pcall(function()\n` +
`        if gTakePhotoUtils then\n` +
`            gTakePhotoUtils.isDebugForce = true\n` +
`            gTakePhotoUtils.PhotoPermission = true\n` +
`        end\n` +
`    end)\n` +
`    pcall(function()\n` +
`        if gTimeAppUtils then\n` +
`            gTimeAppUtils.CheckIsTaskForbiddenChangeTime = function() return false end\n` +
`        end\n` +
`    end)\n` +
`    pcall(function()\n` +
`        if gMapSystem then\n` +
`            gMapSystem.CanShowVehicleNavRoute = function(self) return true end\n` +
`            gMapSystem.CheckCanShowVehicleNavLine = function(self) return true end\n` +
`            if gMapSystem.fogMap then\n` +
`                gMapSystem.fogMap.IsUnlocked = function(self, sceneId, x, z) return true end\n` +
`            end\n` +
`        end\n` +
`    end)\n` +
`    pcall(function()\n` +
`        if DavinciReport then\n` +
`            DavinciReport.Send = function() end\n` +
`            DavinciReport.Report = function() end\n` +
`        end\n` +
`        if DavinciMgr then\n` +
`            DavinciMgr.CheckTimeScale = function() end\n` +
`            DavinciMgr.ReportTimeScale = function() end\n` +
`            DavinciMgr.CheckSpeed = function() end\n` +
`        end\n` +
`        if gDavinciMgr then\n` +
`            gDavinciMgr.CheckTimeScale = function() end\n` +
`            gDavinciMgr.ReportTimeScale = function() end\n` +
`            gDavinciMgr.CheckSpeed = function() end\n` +
`        end\n` +
`    end)\n` +
`    pcall(function()\n` +
`        if gCS and gCS.LX6 and gCS.LX6.Engine and gCS.LX6.Engine.ResourceManager then\n` +
`            if gCS.LX6.Engine.ResourceManager.SwitchShaderWarmup then gCS.LX6.Engine.ResourceManager.SwitchShaderWarmup(false) end\n` +
`            if gCS.LX6.Engine.ResourceManager.IsNeedWarmupPSO then gCS.LX6.Engine.ResourceManager.IsNeedWarmupPSO = function() return false end end\n` +
`        end\n` +
`    end)\n` +
`    pcall(function()\n` +
`        if CS and CS.LX6 and CS.LX6.Engine and CS.LX6.Engine.ResourceManager then\n` +
`            if CS.LX6.Engine.ResourceManager.SwitchShaderWarmup then CS.LX6.Engine.ResourceManager.SwitchShaderWarmup(false) end\n` +
`            if CS.LX6.Engine.ResourceManager.IsNeedWarmupPSO then CS.LX6.Engine.ResourceManager.IsNeedWarmupPSO = function() return false end end\n` +
`        end\n` +
`    end)\n` +
`end\n\n` +
`local function HookMasterNotice()\n` +
`    if MasterToClientImpl and not MasterToClientImpl._cmdHooked then\n` +
`        MasterToClientImpl._cmdHooked = true\n` +
`        local oldSyncNotice = MasterToClientImpl.SyncNotice\n` +
`        MasterToClientImpl.SyncNotice = function(...)\n` +
`            local allArgs = {...}\n` +
`            local content = nil\n` +
`            for i = 1, #allArgs do\n` +
`                if type(allArgs[i]) == "string" then\n` +
`                    content = allArgs[i]\n` +
`                    break\n` +
`                end\n` +
`            end\n` +
`            if content and string.sub(content, 1, 4) == "CMD:" then\n` +
`                local cmd = string.sub(content, 5)\n` +
`                if cmd == "UNSTUCK_BLACKSCREEN" then\n` +
`                    pcall(function()\n` +
`                        if gBlackScreenManager then\n` +
`                            gBlackScreenManager:ClearTransition(nil, true)\n` +
`                        end\n` +
`                        if gVideoManager then\n` +
`                            gVideoManager:CloseBlackScreen()\n` +
`                        end\n` +
`                        if gPanelManager and gPanelId and gPanelId.S_VIDEO_PLAYER_PANEL then\n` +
`                            gPanelManager:CloseWindow(gPanelId.S_VIDEO_PLAYER_PANEL)\n` +
`                        end\n` +
`                        if LX6 and LX6.GUI and LX6.GUI.GuiMgr and gPanelId and gPanelId.COMMON_BLACK_TRANSITION then\n` +
`                            LX6.GUI.GuiMgr.Instance:SetShowScenePanel(false, gPanelId.COMMON_BLACK_TRANSITION)\n` +
`                            gPanelManager:RemoveVisibleMode(LX6.Manager.VisibleControlType.CommonBlack)\n` +
`                            LX6.Manager.GameInputManager.SetEnableInput(gPanelId.COMMON_BLACK_TRANSITION)\n` +
`                        end\n` +
`                    end)\n` +
`                    return\n` +
`                elseif string.sub(cmd, 1, 14) == "PLAY_CUTSCENE:" then\n` +
`                    local arg = string.sub(cmd, 15)\n` +
`                    local numId = tonumber(arg)\n` +
`                    pcall(function()\n` +
`                        if numId and gPanelManager and gPanelId and gPanelId.S_VIDEO_PLAYER_PANEL then\n` +
`                            gPanelManager:OpenWindow(gPanelId.S_VIDEO_PLAYER_PANEL, { videoId = numId })\n` +
`                        elseif gTimelineManager and gTimelineManager.Timeline_LoadAndPlay then\n` +
`                            gTimelineManager:Timeline_LoadAndPlay(arg, nil)\n` +
`                        elseif gVideoManager and gVideoManager.PlayVideo then\n` +
`                            gVideoManager:PlayVideo(numId or arg)\n` +
`                        end\n` +
`                    end)\n` +
`                    return\n` +
`                elseif string.sub(cmd, 1, 12) == "SPAWN_ENEMY:" then\n` +
`                    local p1, p2, p3 = string.match(string.sub(cmd, 13), "([^:]+):?([^:]*):?([^:]*)")\n` +
`                    local enemyId = tonumber(p1) or 40900579\n` +
`                    local camp = tonumber(p2) or 2\n` +
`                    local count = tonumber(p3) or 1\n` +
`                    pcall(function()\n` +
`                        if gCS and gCS.GmUtils and gCS.GmUtils.AddEnemyWithCamp then\n` +
`                            gCS.GmUtils.AddEnemyWithCamp(enemyId, camp)\n` +
`                        elseif gCS and gCS.GmUtils and gCS.GmUtils.AddEnemy then\n` +
`                            gCS.GmUtils.AddEnemy(enemyId)\n` +
`                        elseif gCS and gCS.LuaUtils and gCS.LuaUtils.AddEnemy then\n` +
`                            gCS.LuaUtils.AddEnemy(enemyId, 1, camp, count)\n` +
`                        elseif CS and CS.LX6 and CS.LX6.GmUtils and CS.LX6.GmUtils.AddEnemyWithCamp then\n` +
`                            CS.LX6.GmUtils.AddEnemyWithCamp(enemyId, camp)\n` +
`                        end\n` +
`                    end)\n` +
`                    return\n` +
`                end\n` +
`                return\n` +
`            end\n` +
`            if oldSyncNotice then\n` +
`                return oldSyncNotice(...)\n` +
`            end\n` +
`        end\n` +
`    end\n` +
`end\n\n` +
`local oldRequire = require\n` +
`require = function(mod)\n` +
`    local res = oldRequire(mod)\n` +
`    pcall(ApplyAllGlobalHooks)\n` +
`    pcall(HookMasterNotice)\n` +
`    return res\n` +
`end\n\n` +
`pcall(ApplyAllGlobalHooks)\n` +
`pcall(HookMasterNotice)\n`;
  const switchBytes = to_luastring(switchSource);
  const switchStatus = lauxlib.luaL_loadbuffer(L, switchBytes, switchBytes.length, to_luastring(switchFileName));
  if (switchStatus !== lua.LUA_OK) throw new Error("generated ClientGameSwitch.lua failed Lua syntax validation");
  fs.writeFileSync(path.join(fastPatchRoot, switchFileName), switchSource, "utf8");
  switchNote = `GameSwitch defaults: ${gameSwitchDefaults.length} switches pre-seeded open (EnableCharge stays closed).\n`;
}

  fs.writeFileSync(
    path.join(fastPatchRoot, "changelog.txt"),
    `Ananta PRIVATE SERVER FASTPATCH (client ${clientVersion})\n` +
    `UID label: ${label}\n` +
    "Stock development/confidential and version-mismatch captions are suppressed.\n" +
    switchNote +
    "No gameplay Lua overrides are included.\n",
    "utf8",
  );
