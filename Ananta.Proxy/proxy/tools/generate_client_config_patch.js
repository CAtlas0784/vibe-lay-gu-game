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
`local ProcessDebugCommand\n` +
`local _lastHotkeyFrame = -1\n` +
`local function CheckCustomHotkeys()\n` +
`    pcall(function()\n` +
`        if not UnityEngine or not UnityEngine.Input then return end\n` +
`        local curFrame = UnityEngine.Time and UnityEngine.Time.frameCount or -1\n` +
`        if curFrame == _lastHotkeyFrame then return end\n` +
`        _lastHotkeyFrame = curFrame\n\n` +
`        local f8 = false\n` +
`        local f7 = false\n` +
`        local isShift = false\n` +
`        pcall(function()\n` +
`            f8 = UnityEngine.Input.GetKeyDown("f8")\n` +
`            f7 = UnityEngine.Input.GetKeyDown("f7")\n` +
`            isShift = UnityEngine.Input.GetKey("left shift") or UnityEngine.Input.GetKey("right shift")\n` +
`        end)\n` +
`        if not f8 and UnityEngine.KeyCode then\n` +
`            pcall(function() f8 = UnityEngine.Input.GetKeyDown(UnityEngine.KeyCode.F8) end)\n` +
`        end\n` +
`        if not f7 and UnityEngine.KeyCode then\n` +
`            pcall(function() f7 = UnityEngine.Input.GetKeyDown(UnityEngine.KeyCode.F7) end)\n` +
`        end\n` +
`        if not isShift and UnityEngine.KeyCode then\n` +
`            pcall(function() isShift = UnityEngine.Input.GetKey(UnityEngine.KeyCode.LeftShift) or UnityEngine.Input.GetKey(UnityEngine.KeyCode.RightShift) end)\n` +
`        end\n` +
`        if not f8 and KeyCode then\n` +
`            pcall(function() f8 = UnityEngine.Input.GetKeyDown(KeyCode.F8) end)\n` +
`        end\n` +
`        if not f7 and KeyCode then\n` +
`            pcall(function() f7 = UnityEngine.Input.GetKeyDown(KeyCode.F7) end)\n` +
`        end\n` +
`        if not f8 then\n` +
`            pcall(function() f8 = UnityEngine.Input.GetKeyDown(289) end)\n` +
`        end\n` +
`        if not f7 then\n` +
`            pcall(function() f7 = UnityEngine.Input.GetKeyDown(288) end)\n` +
`        end\n` +
`        if not isShift then\n` +
`            pcall(function() isShift = UnityEngine.Input.GetKey(304) or UnityEngine.Input.GetKey(303) end)\n` +
`        end\n\n` +
`        if f8 then\n` +
`            if ProcessDebugCommand then ProcessDebugCommand("TOGGLE_CLOTHES") end\n` +
`        end\n` +
`        if f7 then\n` +
`            if isShift then\n` +
`                if ProcessDebugCommand then ProcessDebugCommand("OPEN_MONSTER_PANEL") end\n` +
`            else\n` +
`                if ProcessDebugCommand then ProcessDebugCommand("SPAWN_ENEMY") end\n` +
`            end\n` +
`        end\n` +
`    end)\n` +
`end\n\n` +
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
`        if LX6 and LX6.Gps and LX6.Gps.MapFogDataMgr then\n` +
`            LX6.Gps.MapFogDataMgr.IsInFog = function(sceneId, x, z) return false end\n` +
`            pcall(function() LX6.Gps.MapFogDataMgr.SyncUnlockScene(101, true) end)\n` +
`            pcall(function() LX6.Gps.MapFogDataMgr.SyncUnlockScene(102, true) end)\n` +
`            pcall(function() LX6.Gps.MapFogDataMgr.SyncUnlockScene(103, true) end)\n` +
`            pcall(function() LX6.Gps.MapFogDataMgr.SyncUnlockScene(1001, true) end)\n` +
`        end\n` +
`        if C_MapView_Fog then\n` +
`            C_MapView_Fog.InFog = function(self, instanceId) return false end\n` +
`            C_MapView_Fog.SetFogEnable = function(self, enable) end\n` +
`        end\n` +
`        if L50 and L50.Gm and L50.Gm.AutoQaFunctions then\n` +
`            L50.Gm.AutoQaFunctions.GetMapClickToTeleport = function() return true end\n` +
`        end\n` +
`        if gCS and gCS.LuaUtils then\n` +
`            gCS.LuaUtils.IsNotUseGM = false\n` +
`        end\n` +
`        local mapStore = GroupName2Class and GroupName2Class.NewMapPanelStore or C_NewMapPanelStore\n` +
`        if mapStore and not mapStore._teleportHooked then\n` +
`            mapStore._teleportHooked = true\n` +
`            local origOnShow = mapStore.OnShow\n` +
`            mapStore.OnShow = function(self, ...)\n` +
`                pcall(function()\n` +
`                    if self.fogNode then self.fogNode:SetActive(false) end\n` +
`                    if self.fogRoot then self.fogRoot:SetActive(false) end\n` +
`                end)\n` +
`                if origOnShow then return origOnShow(self, ...) end\n` +
`            end\n` +
`            local origOnMainClick = mapStore.OnMainClick\n` +
`            mapStore.OnMainClick = function(self, evtData)\n` +
`                local isAlt = false\n` +
`                pcall(function()\n` +
`                    if UnityEngine and UnityEngine.Input and UnityEngine.KeyCode then\n` +
`                        isAlt = UnityEngine.Input.GetKey(UnityEngine.KeyCode.LeftAlt) or UnityEngine.Input.GetKey(UnityEngine.KeyCode.RightAlt)\n` +
`                    end\n` +
`                end)\n` +
`                if isAlt or (evtData and evtData.button == 1) or (L50 and L50.Gm and L50.Gm.AutoQaFunctions and L50.Gm.AutoQaFunctions.GetMapClickToTeleport()) then\n` +
`                    local uiPos = self:GetPointerUIPos()\n` +
`                    local texPos = self:TransformUIToTex(uiPos)\n` +
`                    local areaId, worldPos = self:TryTransformTexToWorld(texPos)\n` +
`                    if worldPos then\n` +
`                        local playerY = 274.6\n` +
`                        pcall(function()\n` +
`                            if gCS and gCS.MyPlayerManager and gCS.MyPlayerManager.PlayerUnit then\n` +
`                                local p = gCS.MyPlayerManager.PlayerUnit.Pos\n` +
`                                if p and p.y > 10 then playerY = p.y end\n` +
`                            end\n` +
`                        end)\n` +
`                        if L50 and L50.Gm and L50.Gm.AutoQaFunctions and L50.Gm.AutoQaFunctions.TeleportXYZ then\n` +
`                            L50.Gm.AutoQaFunctions.TeleportXYZ(worldPos.x, playerY, worldPos.z)\n` +
`                        elseif L50 and L50.Gm and L50.Gm.AutoQaFunctions and L50.Gm.AutoQaFunctions.TeleportToPos then\n` +
`                            L50.Gm.AutoQaFunctions.TeleportToPos(worldPos.x, worldPos.z)\n` +
`                        end\n` +
`                        pcall(function() gMainPhoneUtils.CloseMainPhonePanel(true) end)\n` +
`                        pcall(function() self:OnBtnClose() end)\n` +
`                        return\n` +
`                    end\n` +
`                end\n` +
`                if origOnMainClick then return origOnMainClick(self, evtData) end\n` +
`            end\n` +
`        end\n` +
`        if C_InteractionManager then\n` +
`            local origCheck = C_InteractionManager.CheckUnitPcBtnShow\n` +
`            C_InteractionManager.CheckUnitPcBtnShow = function(self, pid)\n` +
`                if gCS and gCS.MyPlayerManager and gCS.MyPlayerManager.PlayerUnit and gCS.MyPlayerManager.PlayerUnit.Pid == pid then\n` +
`                    return false\n` +
`                end\n` +
`                if origCheck then return origCheck(self, pid) end\n` +
`                return false\n` +
`            end\n` +
`        end\n` +
`        if gInteractionManager then\n` +
`            local origCheckG = gInteractionManager.CheckUnitPcBtnShow\n` +
`            gInteractionManager.CheckUnitPcBtnShow = function(self, pid)\n` +
`                if gCS and gCS.MyPlayerManager and gCS.MyPlayerManager.PlayerUnit and gCS.MyPlayerManager.PlayerUnit.Pid == pid then\n` +
`                    return false\n` +
`                end\n` +
`                if origCheckG then return origCheckG(self, pid) end\n` +
`                return false\n` +
`            end\n` +
`        end\n` +
`        local hudCtrl = GroupName2Class and GroupName2Class.PlayerHUDCtrl or C_PlayerHUDCtrl\n` +
`        if hudCtrl and not hudCtrl._hideFHooked then\n` +
`            hudCtrl._hideFHooked = true\n` +
`            local oldHudUpdate = hudCtrl.Update\n` +
`            hudCtrl.Update = function(self)\n` +
`                if self.unit and self.unit.IsMe then\n` +
`                    pcall(function()\n` +
`                        if self.interactBtn then\n` +
`                            self.interactBtn:SetActive(false)\n` +
`                        end\n` +
`                    end)\n` +
`                end\n` +
`                if oldHudUpdate then return oldHudUpdate(self) end\n` +
`            end\n` +
`        end\n` +
`        if gBuyHouseUtils then\n` +
`            gBuyHouseUtils.CheckHasBuyTheHouse = function(houseId) return true end\n` +
`            gBuyHouseUtils.CheckBuyHouseMoneyEnough = function(houseId) return true end\n` +
`        end\n` +
`        if C_PlayerItemManager then\n` +
`            C_PlayerItemManager.GetPackItemNum = function(self, id) return 999999 end\n` +
`        end\n` +
`        if gPlayerItemManager then\n` +
`            gPlayerItemManager.GetPackItemNum = function(self, id) return 999999 end\n` +
`        end\n` +
`        local photoStore = GroupName2Class and GroupName2Class.PhotoPanelStore or C_PhotoPanelStore\n` +
`        if photoStore and not photoStore._selfieHooked then\n` +
`            photoStore._selfieHooked = true\n` +
`            local origOnShowPhoto = photoStore.OnShow\n` +
`            photoStore.OnShow = function(self, ...)\n` +
`                self.selectedSpirit = self.selectedSpirit or (gCS and gCS.MyPlayerManager and gCS.MyPlayerManager.PlayerUnit and gCS.MyPlayerManager.PlayerUnit.TemplateId) or 15020967\n` +
`                if origOnShowPhoto then origOnShowPhoto(self, ...) end\n` +
`            end\n` +
`            local origSetMode = photoStore.SetCurrentPhotoMode\n` +
`            photoStore.SetCurrentPhotoMode = function(self)\n` +
`                if origSetMode then origSetMode(self) end\n` +
`                if self.photoMode == 1 then\n` +
`                    pcall(function()\n` +
`                        if gCS and gCS.TransitionMgr then gCS.TransitionMgr.showMainCube = true end\n` +
`                        if gCS and gCS.CameraDataMgr and gCS.CameraDataMgr.cinemachineManager then\n` +
`                            gCS.CameraDataMgr.cinemachineManager:SwitchSelfiePhotoMode(true, 0.2)\n` +
`                            gCS.CameraDataMgr.cinemachineManager:SetFov(68, 0, 0, false)\n` +
`                        end\n` +
`                    end)\n` +
`                else\n` +
`                    pcall(function()\n` +
`                        if gCS and gCS.TransitionMgr then gCS.TransitionMgr.showMainCube = false end\n` +
`                    end)\n` +
`                end\n` +
`            end\n` +
`            local origOnClosePhoto = photoStore.OnClose\n` +
`            photoStore.OnClose = function(self, ...)\n` +
`                pcall(function()\n` +
`                    local unit = gCS and gCS.MyPlayerManager and gCS.MyPlayerManager.PlayerUnit\n` +
`                    if unit then\n` +
`                        if gCS.ClimbManager and gCS.ClimbManager.SetLayerActionStateAndCheckTransition then\n` +
`                            gCS.ClimbManager.SetLayerActionStateAndCheckTransition(unit, false, 42)\n` +
`                        end\n` +
`                        if MuGenStates and MuGenStates.Logic and MuGenStates.Logic.ABPVarManager and LTConfig and LTConfig.ABPVarConfig then\n` +
`                            MuGenStates.Logic.ABPVarManager.SetBool(unit, LTConfig.ABPVarConfig.PhoneSelfie, false)\n` +
`                        end\n` +
`                    end\n` +
`                    if gTakePhotoUtils and gTakePhotoUtils.PlayTakePhotoAction and LTConfig and LTConfig.TakePhotoActionConfig then\n` +
`                        gTakePhotoUtils.PlayTakePhotoAction(LTConfig.TakePhotoActionConfig.NormalTakePhoto)\n` +
`                    end\n` +
`                end)\n` +
`                if origOnClosePhoto then return origOnClosePhoto(self, ...) end\n` +
`            end\n` +
`        end\n` +
`        if gLuaClient and not gLuaClient._hotkeyHooked then\n` +
`            gLuaClient._hotkeyHooked = true\n` +
`            local oldClientUpdate = gLuaClient.OnUpdate\n` +
`            gLuaClient.OnUpdate = function(self, ...)\n` +
`                if oldClientUpdate then oldClientUpdate(self, ...) end\n` +
`                if CheckCustomHotkeys then CheckCustomHotkeys() end\n` +
`            end\n` +
`        end\n` +
`        if gLuaClient and gLuaClient.ForceUpdateArray and not gLuaClient._hotkeyForceRegistered then\n` +
`            gLuaClient._hotkeyForceRegistered = true\n` +
`            table.insert(gLuaClient.ForceUpdateArray, function()\n` +
`                if CheckCustomHotkeys then CheckCustomHotkeys() end\n` +
`            end)\n` +
`        end\n` +
`    end)\n` +
`    pcall(function()\n` +
`        local dm = CS and CS.L50 and CS.L50.Script and CS.L50.Script.LX6 and CS.L50.Script.LX6.Security and CS.L50.Script.LX6.Security.DavinciMgr and CS.L50.Script.LX6.Security.DavinciMgr.Instance\n` +
`        if dm then\n` +
`            pcall(function()\n` +
`                local t = dm:GetType()\n` +
`                local flags = 36\n` +
`                pcall(function() flags = System.Reflection.BindingFlags.NonPublic:ToInt() + System.Reflection.BindingFlags.Instance:ToInt() end)\n` +
`                local fDet = t:GetField("_detectors", flags)\n` +
`                if fDet then\n` +
`                    local list = fDet:GetValue(dm)\n` +
`                    if list then list:Clear() end\n` +
`                end\n` +
`                local fCol = t:GetField("_collectors", flags)\n` +
`                if fCol then\n` +
`                    local list = fCol:GetValue(dm)\n` +
`                    if list then list:Clear() end\n` +
`                end\n` +
`            end)\n` +
`        end\n` +
`    end)\n` +
`    pcall(function()\n` +
`        local nm = (CS and CS.LX6 and CS.LX6.Engine and CS.LX6.Engine.NetworkManager and CS.LX6.Engine.NetworkManager.Instance) or (gCS and gCS.NetworkManager and gCS.NetworkManager.Instance)\n` +
`        if nm then\n` +
`            nm.CheckNetwork = false\n` +
`            if CS and CS.LX6 and CS.LX6.Engine and CS.LX6.Engine.NetworkManager then\n` +
`                CS.LX6.Engine.NetworkManager.SilentReconnectEnabled = true\n` +
`            end\n` +
`            pcall(function()\n` +
`                local t = nm:GetType()\n` +
`                local flags = 36\n` +
`                pcall(function() flags = System.Reflection.BindingFlags.NonPublic:ToInt() + System.Reflection.BindingFlags.Instance:ToInt() end)\n` +
`                local fFocus = t:GetField("checkFocusChanged", flags)\n` +
`                if fFocus then fFocus:SetValue(nm, false) end\n` +
`                local fPing = t:GetField("checkPingpongTimeOut", flags)\n` +
`                if fPing then fPing:SetValue(nm, false) end\n` +
`                local fCheckNet = t:GetField("checkNetwork", flags)\n` +
`                if fCheckNet then fCheckNet:SetValue(nm, false) end\n` +
`                if nm.CancelDelayShowReconnectPanel then nm:CancelDelayShowReconnectPanel() end\n` +
`                if nm.ClearCheckNeedReconnect then nm:ClearCheckNeedReconnect() end\n` +
`            end)\n` +
`        end\n` +
`    end)\n` +
`    pcall(function()\n` +
`        local lmCS = (CS and CS.LX6 and CS.LX6.Manager and CS.LX6.Manager.LoginManager and CS.LX6.Manager.LoginManager.Instance) or (gCS and gCS.LoginManager and gCS.LoginManager.Instance)\n` +
`        if lmCS then\n` +
`            lmCS.CheckLoginConnected = false\n` +
`            pcall(function()\n` +
`                if lmCS.ClearReconnectState then lmCS:ClearReconnectState() end\n` +
`                if lmCS.ClearLoginTimeoutCo then lmCS:ClearLoginTimeoutCo() end\n` +
`            end)\n` +
`        end\n` +
`        local lm = gLoginManager or (GroupName2Class and GroupName2Class.LoginManager) or C_LoginManager\n` +
`        if lm then\n` +
`            lm.CheckNetworkState = function() end\n` +
`            lm.OnUpdate_CheckNet = function() end\n` +
`            lm.StopReconCo = function() end\n` +
`            lm.DoKickToLogin = function() end\n` +
`            lm.KickToLogin = function() end\n` +
`            lm.RetryServerInfo = function() return true end\n` +
`        end\n` +
`    end)\n` +
`    pcall(function()\n` +
`        local gu = (CS and CS.LX6 and CS.LX6.Utils and CS.LX6.Utils.GuiUtils) or (gCS and gCS.GuiUtils)\n` +
`        if gu then\n` +
`            gu.ShowReconnectMessage = function() end\n` +
`            gu.ShowDisconnectMessage = function() end\n` +
`            gu.ShowServerDonw = function() end\n` +
`        end\n` +
`        if gClientToAvatarDelegate then gClientToAvatarDelegate.DavinciCode = function() end end\n` +
`        if ClientToAvatarDelegate then ClientToAvatarDelegate.DavinciCode = function() end end\n` +
`    end)\n` +
`    pcall(function()\n` +
`        local bombStore = GroupName2Class and GroupName2Class.CommonBombStore or C_CommonBombStore\n` +
`        if bombStore and not bombStore._reconnectHooked then\n` +
`            bombStore._reconnectHooked = true\n` +
`            local oldOnShow = bombStore.OnShow\n` +
`            bombStore.OnShow = function(self, panelId, data)\n` +
`                if data then\n` +
`                    local t1 = tostring(data.tips1Text or "")\n` +
`                    local t2 = tostring(data.tips2Text or "")\n` +
`                    local cBtn = tostring(data.confirmBtnText or "")\n` +
`                    local all = t1 .. " " .. t2 .. " " .. cBtn\n` +
`                    if string.find(all, "重连") or string.find(all, "Reconnect") or string.find(all, "断开") or string.find(all, "网络") or string.find(all, "Network") or string.find(all, "connect") then\n` +
`                        pcall(function()\n` +
`                            if gPanelManager then gPanelManager:Close(panelId or gPanelId.S_COMMON_BOMB_PANEL) end\n` +
`                            if gDisplayMessageMgr then gDisplayMessageMgr:CloseBomb() end\n` +
`                        end)\n` +
`                        return\n` +
`                    end\n` +
`                end\n` +
`                if oldOnShow then return oldOnShow(self, panelId, data) end\n` +
`            end\n` +
`        end\n` +
`        if gPanelManager and not gPanelManager._bombFilterHooked then\n` +
`            gPanelManager._bombFilterHooked = true\n` +
`            local oldCheckShow = gPanelManager.CheckShow\n` +
`            gPanelManager.CheckShow = function(self, panelId, params, ...)\n` +
`                if panelId == (gPanelId and gPanelId.S_COMMON_BOMB_PANEL) and params then\n` +
`                    local t1 = tostring(params.tips1Text or "")\n` +
`                    local t2 = tostring(params.tips2Text or "")\n` +
`                    local cBtn = tostring(params.confirmBtnText or "")\n` +
`                    local all = t1 .. " " .. t2 .. " " .. cBtn\n` +
`                    if string.find(all, "重连") or string.find(all, "Reconnect") or string.find(all, "断开") or string.find(all, "网络") or string.find(all, "Network") or string.find(all, "connect") then\n` +
`                        return nil\n` +
`                    end\n` +
`                end\n` +
`                if oldCheckShow then return oldCheckShow(self, panelId, params, ...) end\n` +
`            end\n` +
`        end\n` +
`        if gDisplayMessageMgr and not gDisplayMessageMgr._bombFilterHooked then\n` +
`            gDisplayMessageMgr._bombFilterHooked = true\n` +
`            local oldShowBomb = gDisplayMessageMgr.ShowBomb\n` +
`            gDisplayMessageMgr.ShowBomb = function(self, params)\n` +
`                if params and params.tips1Text and type(params.tips1Text) == "string" then\n` +
`                    local t = params.tips1Text\n` +
`                    if string.find(t, "重连") or string.find(t, "Reconnect") or string.find(t, "网络连接已断开") or string.find(t, "network") or string.find(t, "Network") then\n` +
`                        return\n` +
`                    end\n` +
`                end\n` +
`                if oldShowBomb then return oldShowBomb(self, params) end\n` +
`            end\n` +
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
`ProcessDebugCommand = function(cmd)\n` +
`    if not cmd or type(cmd) ~= "string" then return end\n` +
`    if cmd == "UNSTUCK_BLACKSCREEN" then\n` +
`        pcall(function()\n` +
`            if gBlackScreenManager then gBlackScreenManager:ClearTransition(nil, true) end\n` +
`            if gVideoManager then gVideoManager:CloseBlackScreen() end\n` +
`            if gPanelManager and gPanelId and gPanelId.S_VIDEO_PLAYER_PANEL then\n` +
`                gPanelManager:CloseWindow(gPanelId.S_VIDEO_PLAYER_PANEL)\n` +
`            end\n` +
`            if LX6 and LX6.GUI and LX6.GUI.GuiMgr and gPanelId and gPanelId.COMMON_BLACK_TRANSITION then\n` +
`                LX6.GUI.GuiMgr.Instance:SetShowScenePanel(false, gPanelId.COMMON_BLACK_TRANSITION)\n` +
`                gPanelManager:RemoveVisibleMode(LX6.Manager.VisibleControlType.CommonBlack)\n` +
`                LX6.Manager.GameInputManager.SetEnableInput(gPanelId.COMMON_BLACK_TRANSITION)\n` +
`            end\n` +
`        end)\n` +
`    elseif string.sub(cmd, 1, 14) == "PLAY_TIMELINE:" then\n` +
`        local arg = string.sub(cmd, 15)\n` +
`        pcall(function()\n` +
`            if gTimelineManager and gTimelineManager.Timeline_LoadAndPlay then\n` +
`                gTimelineManager:Timeline_LoadAndPlay(arg, nil)\n` +
`            elseif gTimelineManager and gTimelineManager.PlayTimeline then\n` +
`                gTimelineManager:PlayTimeline(arg)\n` +
`            elseif gDramaManager and gDramaManager.PlayTimeline then\n` +
`                gDramaManager:PlayTimeline(arg)\n` +
`            elseif gCS and gCS.LuaUtils and gCS.LuaUtils.PlayTimeline then\n` +
`                gCS.LuaUtils.PlayTimeline(arg)\n` +
`            end\n` +
`        end)\n` +
`    elseif string.sub(cmd, 1, 14) == "PLAY_CUTSCENE:" then\n` +
`        local arg = string.sub(cmd, 15)\n` +
`        local numId = tonumber(arg)\n` +
`        pcall(function()\n` +
`            if numId and gPanelManager and gPanelId and gPanelId.S_VIDEO_PLAYER_PANEL then\n` +
`                gPanelManager:OpenWindow(gPanelId.S_VIDEO_PLAYER_PANEL, { videoId = numId })\n` +
`            elseif gTimelineManager and gTimelineManager.Timeline_LoadAndPlay then\n` +
`                gTimelineManager:Timeline_LoadAndPlay(arg, nil)\n` +
`            elseif gVideoManager and gVideoManager.PlayVideo then\n` +
`                gVideoManager:PlayVideo(numId or arg)\n` +
`            end\n` +
`        end)\n` +
`    elseif string.sub(cmd, 1, 11) == "SPAWN_ENEMY" then\n` +
`        local p1, p2, p3 = string.match(string.sub(cmd, 12), "^:?([^:]*):?([^:]*):?([^:]*)")\n` +
`        local reqId = tonumber(p1)\n` +
`        local enemyId = reqId or (function()\n` +
`            local id = 40900579\n` +
`            pcall(function()\n` +
`                if LTConfig and LTConfig.AutoTestBossTestConfig and LTConfig.AutoTestBossTestConfig.count and LTConfig.AutoTestBossTestConfig.count > 0 then\n` +
`                    for i = 0, LTConfig.AutoTestBossTestConfig.count - 1 do\n` +
`                        local cfg = LTConfig.AutoTestBossTestConfig.LoadAt(i)\n` +
`                        if cfg and cfg.BossId and #cfg.BossId > 0 and cfg.BossId[1] and cfg.BossId[1].EnemyId then\n` +
`                            id = cfg.BossId[1].EnemyId\n` +
`                            return\n` +
`                        end\n` +
`                    end\n` +
`                end\n` +
`            end)\n` +
`            return id\n` +
`        end)()\n` +
`        local camp = tonumber(p2) or 0\n` +
`        if camp == 2 then camp = 0 end\n` +
`        local count = tonumber(p3) or 1\n` +
`        pcall(function()\n` +
`            if gCS and gCS.LuaUtils and gCS.LuaUtils.AddEnemy then\n` +
`                gCS.LuaUtils.AddEnemy(enemyId, 1, camp, count)\n` +
`            elseif gCS and gCS.GmUtils and gCS.GmUtils.AddEnemyWithCamp then\n` +
`                gCS.GmUtils.AddEnemyWithCamp(enemyId, camp)\n` +
`            elseif gCS and gCS.GmUtils and gCS.GmUtils.AddEnemy then\n` +
`                gCS.GmUtils.AddEnemy(enemyId)\n` +
`            end\n` +
`            if gClientToGameSceneGMDelegate and gClientToGameSceneGMDelegate.GmAddEnemyByPlayer then\n` +
`                pcall(function() gClientToGameSceneGMDelegate:GmAddEnemyByPlayer(enemyId, camp) end)\n` +
`            end\n` +
`            pcall(function()\n` +
`                if gDisplayMessageMgr and gDisplayMessageMgr.ShowMessageContent then\n` +
`                    gDisplayMessageMgr:ShowMessageContent("Spawned Enemy ID: " .. tostring(enemyId))\n` +
`                end\n` +
`                if gCS and gCS.MessageTipsMgr and gCS.MessageTipsMgr.ShowMessageTips then\n` +
`                    gCS.MessageTipsMgr:ShowMessageTips("Spawned Enemy ID: " .. tostring(enemyId))\n` +
`                end\n` +
`            end)\n` +
`        end)\n` +
`    elseif cmd == "OPEN_MONSTER_PANEL" then\n` +
`        pcall(function()\n` +
`            if gPanelManager and gPanelId and gPanelId.S_SKILL_DEBUG_PANEL then\n` +
`                gPanelManager:CheckShow(gPanelId.S_SKILL_DEBUG_PANEL, { ShowAddEnemy = true })\n` +
`            end\n` +
`            pcall(function()\n` +
`                if gDisplayMessageMgr and gDisplayMessageMgr.ShowMessageContent then\n` +
`                    gDisplayMessageMgr:ShowMessageContent("Opened Monster Spawn Menu")\n` +
`                end\n` +
`            end)\n` +
`        end)\n` +
`    elseif cmd == "TOGGLE_CLOTHES" then\n` +
`        pcall(function()\n` +
`            local unit = gCS and gCS.MyPlayerManager and gCS.MyPlayerManager.PlayerUnit\n` +
`            if not unit or not unit.PlayerObj then return end\n` +
`            _G._clothesHidden = not _G._clothesHidden\n` +
`            local smrs = unit.PlayerObj:GetComponentsInChildren(typeof(UnityEngine.SkinnedMeshRenderer), true)\n` +
`            if smrs then\n` +
`                for i = 0, smrs.Length - 1 do\n` +
`                    local smr = smrs[i]\n` +
`                    local n = string.lower(smr.name)\n` +
`                    local isBaseBody = string.find(n, "body") or string.find(n, "face") or string.find(n, "head") or string.find(n, "hair") or string.find(n, "eye") or string.find(n, "skin") or string.find(n, "shenti") or string.find(n, "tou") or string.find(n, "lian")\n` +
`                    local isClothing = string.find(n, "cloth") or string.find(n, "coat") or string.find(n, "skirt") or string.find(n, "pant") or string.find(n, "dress") or string.find(n, "top") or string.find(n, "bottom") or string.find(n, "jacket") or string.find(n, "yifu") or string.find(n, "kuzi") or string.find(n, "qun") or string.find(n, "shoe") or string.find(n, "sock") or string.find(n, "hat") or string.find(n, "wa") or string.find(n, "xie") or string.find(n, "under") or string.find(n, "suit") or string.find(n, "acc")\n` +
`                    if isClothing and not (string.find(n, "body") and not string.find(n, "cloth")) then\n` +
`                        smr.enabled = not _G._clothesHidden\n` +
`                    elseif isBaseBody then\n` +
`                        smr.enabled = true\n` +
`                    else\n` +
`                        smr.enabled = not _G._clothesHidden\n` +
`                    end\n` +
`                end\n` +
`            end\n` +
`            pcall(function()\n` +
`                local tip = _G._clothesHidden and "Outfit Hidden (Base Body)" or "Outfit Shown"\n` +
`                if gDisplayMessageMgr and gDisplayMessageMgr.ShowMessageContent then\n` +
`                    gDisplayMessageMgr:ShowMessageContent(tip)\n` +
`                end\n` +
`                if gCS and gCS.MessageTipsMgr and gCS.MessageTipsMgr.ShowMessageTips then\n` +
`                    gCS.MessageTipsMgr:ShowMessageTips(tip)\n` +
`                end\n` +
`            end)\n` +
`        end)\n` +
`    end\n` +
`end\n\n` +
`local function HookNoticeTable(tbl)\n` +
`    if not tbl or type(tbl) ~= "table" or tbl._cmdHooked then return end\n` +
`    tbl._cmdHooked = true\n` +
`    local oldSync = tbl.SyncNotice\n` +
`    local newSync = function(...)\n` +
`        local allArgs = {...}\n` +
`        for i = 1, #allArgs do\n` +
`            if type(allArgs[i]) == "string" and string.sub(allArgs[i], 1, 4) == "CMD:" then\n` +
`                ProcessDebugCommand(string.sub(allArgs[i], 5))\n` +
`                return\n` +
`            end\n` +
`        end\n` +
`        if oldSync then return oldSync(...) end\n` +
`    end\n` +
`    if tbl._meta and type(tbl._meta) == "table" then\n` +
`        tbl._meta.SyncNotice = newSync\n` +
`    end\n` +
`    tbl.SyncNotice = nil\n` +
`    tbl.SyncNotice = newSync\n` +
`    rawset(tbl, "SyncNotice", newSync)\n` +
`end\n\n` +
`local function HookDisplayMessageMgr()\n` +
`    if gDisplayMessageMgr and not gDisplayMessageMgr._cmdHooked then\n` +
`        gDisplayMessageMgr._cmdHooked = true\n` +
`        local oldShow = gDisplayMessageMgr.ShowMessageContent\n` +
`        gDisplayMessageMgr.ShowMessageContent = function(self, content, ...)\n` +
`            if type(content) == "string" and string.sub(content, 1, 4) == "CMD:" then\n` +
`                ProcessDebugCommand(string.sub(content, 5))\n` +
`                return\n` +
`            end\n` +
`            return oldShow(self, content, ...)\n` +
`        end\n` +
`    end\n` +
`end\n\n` +
`local function HookAllNotices()\n` +
`    pcall(function()\n` +
`        if package and package.loaded then\n` +
`            HookNoticeTable(package.loaded["LX6/Service/MasterToClientImpl"])\n` +
`            HookNoticeTable(package.loaded["LX6/Service/GameToClientImpl"])\n` +
`        end\n` +
`        if MasterToClientImpl then HookNoticeTable(MasterToClientImpl) end\n` +
`        if GameToClientImpl then HookNoticeTable(GameToClientImpl) end\n` +
`        HookDisplayMessageMgr()\n` +
`    end)\n` +
`end\n\n` +
`local oldRequire = require\n` +
`require = function(mod)\n` +
`    local res = oldRequire(mod)\n` +
`    pcall(ApplyAllGlobalHooks)\n` +
`    if mod == "LX6/Service/MasterToClientImpl" or mod == "LX6/Service/GameToClientImpl" then\n` +
`        if type(res) == "table" then HookNoticeTable(res) end\n` +
`    end\n` +
`    pcall(HookAllNotices)\n` +
`    return res\n` +
`end\n\n` +
`pcall(ApplyAllGlobalHooks)\n` +
`pcall(HookAllNotices)\n`;
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

  const { execSync } = require("child_process");
  const publicZip = path.join(__dirname, "..", "public", `fastpatch_${clientVersion}.zip`);
  try {
    const pyCmd = `python -c "import zipfile, os; z = zipfile.ZipFile(r'${publicZip.replace(/\\/g, "\\\\")}', 'w', zipfile.ZIP_DEFLATED); [z.write(os.path.join(r'${fastPatchRoot.replace(/\\/g, "\\\\")}', f), f) for f in os.listdir(r'${fastPatchRoot.replace(/\\/g, "\\\\")}') if os.path.isfile(os.path.join(r'${fastPatchRoot.replace(/\\/g, "\\\\")}', f))]; z.close()"`;
    execSync(pyCmd);
    console.log(`Successfully generated and packed: ${publicZip}`);
  } catch (err) {
    console.warn(`Warning: Could not automatically create zip via python: ${err.message}`);
  }

