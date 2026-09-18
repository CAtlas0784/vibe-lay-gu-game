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
`local function CheckCustomHotkeys()\n` +
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
`            gTakePhotoUtils.isDebugForce = false\n` +
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
`            local unlockScenes = { 1, 101, 102, 103, 1001, 10001, 20001125, 20001222, 20001223, 23300888, 23300999 }\n` +
`            for _, sid in ipairs(unlockScenes) do\n` +
`                pcall(function() LX6.Gps.MapFogDataMgr.SyncUnlockScene(sid, true) end)\n` +
`            end\n` +
`        end\n` +
`        if C_MapView_Fog then\n` +
`            C_MapView_Fog.InFog = function(self, instanceId) return false end\n` +
`            C_MapView_Fog.SetFogEnable = function(self, enable) end\n` +
`        end\n` +
`        if gCS and gCS.LuaUtils then\n` +
`            gCS.LuaUtils.IsNotUseGM = false\n` +
`        end\n` +
`        local mapStore = GroupName2Class and GroupName2Class.NewMapPanelStore or C_NewMapPanelStore\n` +
`        if mapStore and not mapStore._teleportHooked then\n` +
`            mapStore._teleportHooked = true\n` +
`            local origOnShow = mapStore.OnShow\n` +
`            local function hideFogRecursively(t)\n` +
`                if not t then return end\n` +
`                local n = string.lower(t.name or "")\n` +
`                if string.find(n, "fog") or string.find(n, "cloud") or string.find(n, "mask") then\n` +
`                    pcall(function() t.gameObject:SetActive(false) end)\n` +
`                end\n` +
`                local count = t.childCount or 0\n` +
`                for i = 0, count - 1 do\n` +
`                    local child = t:GetChild(i)\n` +
`                    if child then hideFogRecursively(child) end\n` +
`                end\n` +
`            end\n` +
`            mapStore.OnShow = function(self, ...)\n` +
`                self._pendingPin = nil\n` +
`                pcall(function()\n` +
`                    if self.fogNode then self.fogNode:SetActive(false) end\n` +
`                    if self.fogRoot then self.fogRoot:SetActive(false) end\n` +
`                    if self.bindData and self.bindData.bigWorldBg then\n` +
`                        local bg = self.bindData.bigWorldBg\n` +
`                        if bg.instFogRoot and bg.instFogRoot.gameObject then\n` +
`                            bg.instFogRoot.gameObject:SetActive(false)\n` +
`                        end\n` +
`                        if bg.transform then hideFogRecursively(bg.transform) end\n` +
`                    end\n` +
`                    if self.bindData and self.bindData.rootRT then\n` +
`                        hideFogRecursively(self.bindData.rootRT)\n` +
`                    end\n` +
`                    if self.transform then\n` +
`                        hideFogRecursively(self.transform)\n` +
`                    end\n` +
`                end)\n` +
`                if origOnShow then return origOnShow(self, ...) end\n` +
`            end\n` +
`            local origOnMainClick = mapStore.OnMainClick\n` +
`            mapStore.OnMainClick = function(self, evtData)\n` +
`                local isAlt = false\n` +
`                pcall(function()\n` +
`                    if UnityEngine and UnityEngine.Input and UnityEngine.KeyCode then\n` +
`                        isAlt = UnityEngine.Input.GetKey(UnityEngine.KeyCode.LeftAlt) or UnityEngine.Input.GetKey(UnityEngine.KeyCode.RightAlt) or UnityEngine.Input.GetKey(308) or UnityEngine.Input.GetKey(307)\n` +
`                    end\n` +
`                end)\n` +
`                local isRightClick = (evtData and evtData.button == 1)\n` +
`                local worldX, worldZ = nil, nil\n` +
`                pcall(function()\n` +
`                    local uiPos = self.GetPointerUIPos and self:GetPointerUIPos()\n` +
`                    local mousePos = (evtData and evtData.position) or (UnityEngine and UnityEngine.Input and UnityEngine.Input.mousePosition)\n` +
`                    if not uiPos and mousePos and gCS and gCS.LuaUtils and self.bindData and self.bindData.rootRT then\n` +
`                        uiPos = gCS.LuaUtils.TransformScreenPointToUI(self.bindData.rootRT, mousePos)\n` +
`                    end\n` +
`                    if uiPos and self.TransformUIToTex then\n` +
`                        local texPos = self:TransformUIToTex(uiPos)\n` +
`                        if texPos then\n` +
`                            if self.bindData and self.bindData.bigWorldBg and self.bindData.bigWorldBg.LuaTryGetWorldPos then\n` +
`                                local suc, areaId, wx, wz = self.bindData.bigWorldBg:LuaTryGetWorldPos(texPos.x, texPos.y)\n` +
`                                if suc and wx and wz and (math.abs(wx) > 0.1 or math.abs(wz) > 0.1) then\n` +
`                                    worldX, worldZ = wx, wz\n` +
`                                end\n` +
`                            end\n` +
`                            if not worldX and self.TryTransformTexToWorld then\n` +
`                                local areaId, wPos = self:TryTransformTexToWorld(texPos)\n` +
`                                if wPos and (math.abs(wPos.x) > 0.1 or math.abs(wPos.z) > 0.1) then\n` +
`                                    worldX, worldZ = wPos.x, wPos.z\n` +
`                                end\n` +
`                            end\n` +
`                        end\n` +
`                    end\n` +
`                end)\n` +
`                if worldX and worldZ and (math.abs(worldX) > 0.1 or math.abs(worldZ) > 0.1) then\n` +
`                    local now = (os and os.clock and os.clock()) or 0\n` +
`                    local shouldWarp = false\n` +
`                    if isAlt or isRightClick then\n` +
`                        shouldWarp = true\n` +
`                    elseif self._pendingPin and (now - self._pendingPin.time) < 12.0 then\n` +
`                        local dx = worldX - self._pendingPin.x\n` +
`                        local dz = worldZ - self._pendingPin.z\n` +
`                        if (dx * dx + dz * dz) < 6400 then\n` +
`                            shouldWarp = true\n` +
`                            worldX = self._pendingPin.x\n` +
`                            worldZ = self._pendingPin.z\n` +
`                        end\n` +
`                    end\n` +
`                    if shouldWarp then\n` +
`                        self._pendingPin = nil\n` +
`                        local playerY = 274.6\n` +
`                        pcall(function()\n` +
`                            local p = gCS and gCS.MyPlayerManager and gCS.MyPlayerManager.PlayerUnit and gCS.MyPlayerManager.PlayerUnit.Pos\n` +
`                            if p and p.y > 10 then playerY = p.y end\n` +
`                        end)\n` +
`                        pcall(function()\n` +
`                            if gClientToGameSceneGMDelegate and gClientToGameSceneGMDelegate.GmTeleportXYZ then\n` +
`                                gClientToGameSceneGMDelegate:GmTeleportXYZ(worldX, playerY, worldZ, 0)\n` +
`                            end\n` +
`                        end)\n` +
`                        pcall(function()\n` +
`                            if gCS and gCS.GmUtils and gCS.GmUtils.TeleportXYZ then\n` +
`                                gCS.GmUtils.TeleportXYZ(worldX, playerY, worldZ, 0)\n` +
`                            end\n` +
`                        end)\n` +
`                        pcall(function()\n` +
`                            if gDisplayMessageMgr and gDisplayMessageMgr.ShowMessageContent then\n` +
`                                gDisplayMessageMgr:ShowMessageContent(string.format("Warped to Pin: X=%.1f, Z=%.1f", worldX, worldZ))\n` +
`                            end\n` +
`                        end)\n` +
`                        pcall(function() gMainPhoneUtils.CloseMainPhonePanel(true) end)\n` +
`                        pcall(function() self:OnBtnClose() end)\n` +
`                        return\n` +
`                    else\n` +
`                        self._pendingPin = { x = worldX, z = worldZ, time = now }\n` +
`                        pcall(function()\n` +
`                            if gDisplayMessageMgr and gDisplayMessageMgr.ShowMessageContent then\n` +
`                                gDisplayMessageMgr:ShowMessageContent("Pin set! Click again to Warp")\n` +
`                            end\n` +
`                        end)\n` +
`                        if origOnMainClick then return origOnMainClick(self, evtData) end\n` +
`                    end\n` +
`                else\n` +
`                    if isAlt or isRightClick then\n` +
`                        pcall(function()\n` +
`                            if gDisplayMessageMgr and gDisplayMessageMgr.ShowMessageContent then\n` +
`                                gDisplayMessageMgr:ShowMessageContent("Map Click: Target outside world bounds")\n` +
`                            end\n` +
`                        end)\n` +
`                        return\n` +
`                    end\n` +
`                    if origOnMainClick then return origOnMainClick(self, evtData) end\n` +
`                end\n` +
`            end\n` +
`        end\n` +
`        if C_InteractionManager then\n` +
`            local origCheck = C_InteractionManager.CheckUnitPcBtnShow\n` +
`            C_InteractionManager.CheckUnitPcBtnShow = function(self, pid)\n` +
`                local myUnit = gCS and gCS.MyPlayerManager and gCS.MyPlayerManager.PlayerUnit\n` +
`                if myUnit and myUnit.Pid == pid then\n` +
`                    return false\n` +
`                end\n` +
`                if origCheck then return origCheck(self, pid) end\n` +
`                return false\n` +
`            end\n` +
`        end\n` +
`        if gInteractionManager then\n` +
`            local origCheckG = gInteractionManager.CheckUnitPcBtnShow\n` +
`            gInteractionManager.CheckUnitPcBtnShow = function(self, pid)\n` +
`                local myUnit = gCS and gCS.MyPlayerManager and gCS.MyPlayerManager.PlayerUnit\n` +
`                if myUnit and myUnit.Pid == pid then\n` +
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
`                local isCurrentControlled = false\n` +
`                local myUnit = gCS and gCS.MyPlayerManager and gCS.MyPlayerManager.PlayerUnit\n` +
`                if self.unit then\n` +
`                    if myUnit and self.unit.Pid == myUnit.Pid then\n` +
`                        isCurrentControlled = true\n` +
`                    elseif self.unit.IsMe and (not myUnit or self.unit.Pid == myUnit.Pid) then\n` +
`                        isCurrentControlled = true\n` +
`                    end\n` +
`                end\n` +
`                if isCurrentControlled then\n` +
`                    self.isBtnShowNew = false\n` +
`                    pcall(function()\n` +
`                        if self.SetPlayerHeadInfoVisible then self:SetPlayerHeadInfoVisible(true) end\n` +
`                        if self.interactBtn then self.interactBtn:SetActive(false) end\n` +
`                        if self.bindData then self.bindData.isBtnShow = false end\n` +
`                    end)\n` +
`                    return\n` +
`                end\n` +
`                if oldHudUpdate then return oldHudUpdate(self) end\n` +
`            end\n` +
`        end\n` +
`        local hintStore = GroupName2Class and GroupName2Class.HintInfosHudStore or C_HintInfosHudStore\n` +
`        if hintStore and not hintStore._filterPlayerFHooked then\n` +
`            hintStore._filterPlayerFHooked = true\n` +
`            local origRefreshPc = hintStore.RefreshPcBtnShow\n` +
`            hintStore.RefreshPcBtnShow = function(self, force)\n` +
`                pcall(function()\n` +
`                    local myUnit = gCS and gCS.MyPlayerManager and gCS.MyPlayerManager.PlayerUnit\n` +
`                    local btnMgr = L50 and L50.L50App and L50.L50App.L50Game and L50.L50App.L50Game.InteractBtnMgr\n` +
`                    if myUnit and btnMgr and btnMgr.usefulList then\n` +
`                        local myPid = myUnit.Pid\n` +
`                        local i = 0\n` +
`                        while i < btnMgr.usefulList.Count do\n` +
`                            local item = btnMgr.usefulList[i]\n` +
`                            if item and (item.pid == myPid or item.targetPid == myPid or (item.target and item.target == myUnit.PlayerObj)) then\n` +
`                                btnMgr.usefulList:RemoveAt(i)\n` +
`                            else\n` +
`                                i = i + 1\n` +
`                            end\n` +
`                        end\n` +
`                    end\n` +
`                end)\n` +
`                if origRefreshPc then return origRefreshPc(self, force) end\n` +
`            end\n` +
`        end\n` +
`        local switchMgr = gSwitchSpiritManager or (GroupName2Class and GroupName2Class.SwitchSpiritManager)\n` +
`        if switchMgr and not switchMgr._fixSwapHooked then\n` +
`            switchMgr._fixSwapHooked = true\n` +
`            local origBeforeSet = switchMgr.BeforeSetChangeUnit\n` +
`            switchMgr.BeforeSetChangeUnit = function(self, spiritUnitPid, noClearold)\n` +
`                local oldUnit = gCS and gCS.MyPlayerManager and gCS.MyPlayerManager.PlayerUnit\n` +
`                local newUnit = gCS and gCS.SceneDataMgr and gCS.SceneDataMgr.GetUnit(spiritUnitPid)\n` +
`                if oldUnit and newUnit and CS and CS.LX6 and CS.LX6.Manager and CS.LX6.Manager.SwitchSpiritManager and CS.LX6.Manager.SwitchSpiritManager.CopyNewCCMove then\n` +
`                    pcall(function() CS.LX6.Manager.SwitchSpiritManager.CopyNewCCMove(oldUnit, newUnit) end)\n` +
`                end\n` +
`                local res = origBeforeSet and origBeforeSet(self, spiritUnitPid, noClearold)\n` +
`                pcall(function()\n` +
`                    local curUnit = (gCS and gCS.SceneDataMgr and gCS.SceneDataMgr.GetUnit(spiritUnitPid)) or (gCS and gCS.MyPlayerManager and gCS.MyPlayerManager.PlayerUnit)\n` +
`                    if curUnit then\n` +
`                        pcall(function() curUnit.IsMe = true end)\n` +
`                        if curUnit.CharacterController then\n` +
`                            pcall(function() curUnit.CharacterController.enabled = true end)\n` +
`                        end\n` +
`                        if CS and CS.LX6 and CS.LX6.Units and CS.LX6.Units.Module and CS.LX6.Units.Module.LockMoveDirModule then\n` +
`                            pcall(function() CS.LX6.Units.Module.LockMoveDirModule.ClearLockMoveDir(curUnit) end)\n` +
`                        end\n` +
`                        if curUnit.RootMotionLockMoveAndRotate then\n` +
`                            pcall(function() curUnit.RootMotionLockMoveAndRotate:ClearAll() end)\n` +
`                            pcall(function() curUnit.RootMotionLockMoveAndRotate:ClearLockExtraRotation() end)\n` +
`                        end\n` +
`                        if curUnit.State then\n` +
`                            curUnit.State.nowInteractiveAction = 0\n` +
`                            curUnit.State.isFree = true\n` +
`                            curUnit.State.isPause = false\n` +
`                            curUnit.State.isLockMove = false\n` +
`                            curUnit.State.isLockRotate = false\n` +
`                        end\n` +
`                        if curUnit.CCMove then\n` +
`                            pcall(function() curUnit.CCMove:SetEnable(true) end)\n` +
`                            pcall(function() curUnit.CCMove:ResetMoveSpeed() end)\n` +
`                        end\n` +
`                        if curUnit.UnitFightAction then\n` +
`                            pcall(function() curUnit.UnitFightAction:ClearAllAction() end)\n` +
`                            pcall(function() curUnit.UnitFightAction:StopAllAction() end)\n` +
`                        end\n` +
`                        if curUnit.Animator then\n` +
`                            pcall(function() curUnit.Animator.speed = 1.0 end)\n` +
`                        end\n` +
`                        if gCS and gCS.BattleManager and gCS.BattleManager.RefreshAllSkills then\n` +
`                            pcall(function() gCS.BattleManager.RefreshAllSkills(false, false) end)\n` +
`                        end\n` +
`                        local btnMgr = L50 and L50.L50App and L50.L50App.L50Game and L50.L50App.L50Game.InteractBtnMgr\n` +
`                        if btnMgr then\n` +
`                            pcall(function() btnMgr:RemoveBtnByType(curUnit.Pid, 1) end)\n` +
`                            pcall(function() btnMgr:RemoveBtnByType(curUnit.Pid, 2) end)\n` +
`                        end\n` +
`                    end\n` +
`                    if oldUnit and oldUnit.Pid ~= spiritUnitPid then\n` +
`                        pcall(function() oldUnit.IsMe = false end)\n` +
`                        local btnMgr = L50 and L50.L50App and L50.L50App.L50Game and L50.L50App.L50Game.InteractBtnMgr\n` +
`                        if btnMgr and CS and CS.LX6 and CS.LX6.Interact then\n` +
`                            pcall(function()\n` +
`                                btnMgr:RemoveBtnByType(oldUnit.Pid, 1)\n` +
`                                local btnInfo = CS.LX6.Interact.UnitBtnInfo and CS.LX6.Interact.UnitBtnInfo.New()\n` +
`                                if btnInfo then\n` +
`                                    btnInfo.pid = oldUnit.Pid\n` +
`                                    btnInfo.target = oldUnit.PlayerObj\n` +
`                                    btnInfo.text = "Switch Character"\n` +
`                                    btnInfo.isAvailable = true\n` +
`                                    local oldTemplateId = oldUnit.TemplateId or 15020967\n` +
`                                    btnInfo.DoClick = function()\n` +
`                                        pcall(function()\n` +
`                                            if gClientToGameSceneDelegate and gClientToGameSceneDelegate.AskSwitchSpirit then\n` +
`                                                gClientToGameSceneDelegate:AskSwitchSpirit(oldTemplateId)\n` +
`                                            elseif gSwitchSpiritManager then\n` +
`                                                local cUnit = gCS and gCS.MyPlayerManager and gCS.MyPlayerManager.PlayerUnit\n` +
`                                                if cUnit and oldUnit and CS and CS.LX6 and CS.LX6.Manager and CS.LX6.Manager.SwitchSpiritManager and CS.LX6.Manager.SwitchSpiritManager.CopyNewCCMove then\n` +
`                                                    CS.LX6.Manager.SwitchSpiritManager.CopyNewCCMove(cUnit, oldUnit)\n` +
`                                                end\n` +
`                                                gSwitchSpiritManager:BeforeSetChangeUnit(oldUnit.Pid, false)\n` +
`                                            end\n` +
`                                        end)\n` +
`                                    end\n` +
`                                    btnMgr:AddBtn(btnInfo)\n` +
`                                end\n` +
`                            end)\n` +
`                        end\n` +
`                    end\n` +
`                end)\n` +
`                return res\n` +
`            end\n` +
`        end\n` +
`        local sceneImpl = GameSceneToClientImpl or (package and package.loaded and package.loaded["LX6/Service/GameSceneToClientImpl"])\n` +
`        if sceneImpl and not sceneImpl._weatherRainHooked then\n` +
`            sceneImpl._weatherRainHooked = true\n` +
`            local origWeather = sceneImpl.SyncPlayerWeather\n` +
`            sceneImpl.SyncPlayerWeather = function(weatherTypeId, nextWeatherTypeId, transitionSecond)\n` +
`                if origWeather then origWeather(weatherTypeId, nextWeatherTypeId, transitionSecond) end\n` +
`                pcall(function()\n` +
`                    if CS and CS.CTT3 and CS.CTT3.Weather and CS.CTT3.Weather.WeatherBridge then\n` +
`                        CS.CTT3.Weather.WeatherBridge.SetWeather(weatherTypeId, transitionSecond or 2.0)\n` +
`                        if weatherTypeId == 3 or weatherTypeId == 4 then\n` +
`                            CS.CTT3.Weather.WeatherBridge.SetGPURainActive(true)\n` +
`                        else\n` +
`                            CS.CTT3.Weather.WeatherBridge.SetGPURainActive(false)\n` +
`                        end\n` +
`                    end\n` +
`                end)\n` +
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
`    pcall(function()\n` +
`        if UpdateBeat and UpdateBeat.Add and not _G._hotkeyF8Registered then\n` +
`            _G._hotkeyF8Registered = true\n` +
`            UpdateBeat:Add(function()\n` +
`                pcall(function()\n` +
`                    if UnityEngine and UnityEngine.Input then\n` +
`                        if UnityEngine.Input.GetKeyDown(289) or (UnityEngine.KeyCode and UnityEngine.Input.GetKeyDown(UnityEngine.KeyCode.F8)) then\n` +
`                            ProcessDebugCommand("TOGGLE_CLOTHES")\n` +
`                        end\n` +
`                    end\n` +
`                end)\n` +
`            end)\n` +
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
`            local unit = gCS and gCS.MyPlayerManager and gCS.MyPlayerManager.PlayerUnit\n` +
`            local myPos = (unit and unit.Position) or (UnityEngine and UnityEngine.Vector3 and UnityEngine.Vector3.zero)\n` +
`            local myRot = (unit and unit.Facing and UnityEngine and UnityEngine.Vector3 and UnityEngine.Vector3(0, unit.Facing, 0)) or (UnityEngine and UnityEngine.Vector3 and UnityEngine.Vector3.zero)\n` +
`            local numId = tonumber(arg)\n` +
`            if numId and CS and CS.LX6 and CS.LX6.GUI and CS.LX6.GUI.SwitchTeleportManager and CS.LX6.GUI.SwitchTeleportManager.Instance then\n` +
`                pcall(function() CS.LX6.GUI.SwitchTeleportManager.Instance:OnSyncSwitchSpiritConfigId(numId) end)\n` +
`            end\n` +
`            local played = false\n` +
`            if gTimelineManager then\n` +
`                local tlData = nil\n` +
`                if gTimelineManager.Timeline_CreateTimelineData then\n` +
`                    tlData = gTimelineManager:Timeline_CreateTimelineData()\n` +
`                    if tlData and myPos then\n` +
`                        tlData.pos = myPos\n` +
`                        tlData.rot = myRot\n` +
`                    end\n` +
`                end\n` +
`                if gTimelineManager.Timeline_LoadAndPlay then\n` +
`                    pcall(function() gTimelineManager:Timeline_LoadAndPlay(arg, tlData) played = true end)\n` +
`                end\n` +
`                if not played and gTimelineManager.PlayTimeline then\n` +
`                    pcall(function() gTimelineManager:PlayTimeline(arg) played = true end)\n` +
`                end\n` +
`            end\n` +
`            if not played and CS and CS.LX6 and CS.LX6.TimelineScript and CS.LX6.TimelineScript.CutsceneManager and CS.LX6.TimelineScript.CutsceneManager.Instance then\n` +
`                local cm = CS.LX6.TimelineScript.CutsceneManager.Instance\n` +
`                local tlData = cm:CreateTimelineData()\n` +
`                if tlData and myPos then\n` +
`                    tlData.pos = myPos\n` +
`                    tlData.rot = myRot\n` +
`                end\n` +
`                pcall(function() cm:LoadAndPlay(arg, tlData) played = true end)\n` +
`            end\n` +
`            if not played and gCS and gCS.LuaUtils and gCS.LuaUtils.PlayTimeline then\n` +
`                pcall(function() gCS.LuaUtils.PlayTimeline(arg) end)\n` +
`            end\n` +
`            local tip = "Playing Timeline: " .. tostring(arg)\n` +
`            if gDisplayMessageMgr and gDisplayMessageMgr.ShowMessageContent then\n` +
`                gDisplayMessageMgr:ShowMessageContent(tip)\n` +
`            end\n` +
`            if gCS and gCS.MessageTipsMgr and gCS.MessageTipsMgr.ShowMessageTips then\n` +
`                gCS.MessageTipsMgr:ShowMessageTips(tip)\n` +
`            end\n` +
`        end)\n` +
`    elseif string.sub(cmd, 1, 14) == "PLAY_CUTSCENE:" then\n` +
`        local arg = string.sub(cmd, 15)\n` +
`        local numId = tonumber(arg)\n` +
`        pcall(function()\n` +
`            if numId and gPanelManager and gPanelId and gPanelId.S_VIDEO_PLAYER_PANEL then\n` +
`                gPanelManager:OpenWindow(gPanelId.S_VIDEO_PLAYER_PANEL, { videoId = numId })\n` +
`            else\n` +
`                ProcessDebugCommand("PLAY_TIMELINE:" .. tostring(arg))\n` +
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
`    elseif string.sub(cmd, 1, 16) == "LAUNCH_MINIGAME:" or string.sub(cmd, 1, 20) == "CMD:LAUNCH_MINIGAME:" or string.sub(cmd, 1, 9) == "MINIGAME:" or string.sub(cmd, 1, 13) == "CMD:MINIGAME:" then\n` +
`        local rawGame = string.match(cmd, "MINIGAME:([^:]+)") or "KOF97"\n` +
`        local gameType = string.upper(rawGame)\n` +
`        pcall(function()\n` +
`            local function forceShow(panelId, data)\n` +
`                if not panelId or not gPanelManager then return false end\n` +
`                local ok = false\n` +
`                pcall(function()\n` +
`                    if gPanelManager.panelData then\n` +
`                        gPanelManager.panelData[panelId] = data\n` +
`                    end\n` +
`                    if LX6 and LX6.Manager and LX6.Manager.PanelManager and LX6.Manager.PanelManager.Instance then\n` +
`                        LX6.Manager.PanelManager.Instance:CheckShowFromLua(panelId, nil, nil, -1, -1)\n` +
`                        ok = true\n` +
`                    elseif gPanelManager.CheckShow then\n` +
`                        ok = gPanelManager:CheckShow(panelId, data)\n` +
`                    end\n` +
`                end)\n` +
`                return ok\n` +
`            end\n` +
`            local myUnit = gCS and gCS.MyPlayerManager and gCS.MyPlayerManager.PlayerUnit\n` +
`            local pObj = myUnit and myUnit.PlayerObj\n` +
`            local pPos = (pObj and pObj.transform and pObj.transform.position) or (UnityEngine and UnityEngine.Vector3 and UnityEngine.Vector3.zero) or Vector3.zero\n` +
`            local pRot = (pObj and pObj.transform and pObj.transform.rotation) or (UnityEngine and UnityEngine.Quaternion and UnityEngine.Quaternion.identity) or Quaternion.identity\n` +
`            local pScale = (UnityEngine and UnityEngine.Vector3 and UnityEngine.Vector3.one) or Vector3.one\n` +
`            local fArgs = {\n` +
`                position = pPos,\n` +
`                rotation = pRot,\n` +
`                localScale = pScale,\n` +
`                forbidClickExit = false,\n` +
`                autoCloseAfterWin = -1,\n` +
`                ignoreCountdown = false\n` +
`            }\n` +
`            local tip = "Launched Minigame: " .. tostring(gameType)\n` +
`            if gameType == "KOF97" then\n` +
`                if gPanelId and gPanelId.LIBRETRO_PANEL then\n` +
`                    forceShow(gPanelId.LIBRETRO_PANEL, { gameType = 1 })\n` +
`                    tip = "Opened Arcade: The King of Fighters 97 (ตู้เกม KOF '97)"\n` +
`                end\n` +
`            elseif gameType == "METALSLUG" then\n` +
`                if gPanelId and gPanelId.LIBRETRO_PANEL then\n` +
`                    forceShow(gPanelId.LIBRETRO_PANEL, { gameType = 0 })\n` +
`                    tip = "Opened Arcade: Metal Slug (ตู้เกม Metal Slug)"\n` +
`                end\n` +
`            elseif gameType == "FIGHTER" then\n` +
`                local shown = false\n` +
`                if gPanelId and gPanelId.FIGHTER_MAIN_PANEL then\n` +
`                    shown = forceShow(gPanelId.FIGHTER_MAIN_PANEL, fArgs)\n` +
`                end\n` +
`                if gPanelId and gPanelId.FIGHTER_HUD_PANEL then\n` +
`                    forceShow(gPanelId.FIGHTER_HUD_PANEL, fArgs)\n` +
`                end\n` +
`                if not shown and gPanelId and gPanelId.LIBRETRO_PANEL then\n` +
`                    forceShow(gPanelId.LIBRETRO_PANEL, { gameType = 1 })\n` +
`                    tip = "Opened Arcade: The King of Fighters 97 (KOF)"\n` +
`                else\n` +
`                    tip = "Opened 3D Arcade Fighter Minigame"\n` +
`                end\n` +
`            elseif gameType == "PIANO" then\n` +
`                if gPanelId and gPanelId.UI_PANEL__INSTRUMENT__PIANO then\n` +
`                    forceShow(gPanelId.UI_PANEL__INSTRUMENT__PIANO)\n` +
`                    tip = "Opened Grand Piano Minigame"\n` +
`                end\n` +
`            elseif gameType == "DRUMKIT" then\n` +
`                if gPanelId and gPanelId.UI_PANEL__INSTRUMENT__DRUMKIT then\n` +
`                    forceShow(gPanelId.UI_PANEL__INSTRUMENT__DRUMKIT)\n` +
`                    tip = "Opened Drumkit Minigame"\n` +
`                end\n` +
`            elseif gameType == "BOWLING" then\n` +
`                if gPanelId and gPanelId.MINI_GAMES_BOWLING_MAIN_PANEL then\n` +
`                    forceShow(gPanelId.MINI_GAMES_BOWLING_MAIN_PANEL)\n` +
`                    tip = "Opened Bowling Minigame"\n` +
`                end\n` +
`            elseif gameType == "BASKETBALL" then\n` +
`                if gPanelId and gPanelId.BASKETBALL_SHOOT_PANEL then\n` +
`                    forceShow(gPanelId.BASKETBALL_SHOOT_PANEL)\n` +
`                    tip = "Opened Basketball Shoot Minigame"\n` +
`                end\n` +
`            end\n` +
`            pcall(function()\n` +
`                if gDisplayMessageMgr and gDisplayMessageMgr.ShowMessageContent then\n` +
`                    gDisplayMessageMgr:ShowMessageContent(tip)\n` +
`                end\n` +
`                if gCS and gCS.MessageTipsMgr and gCS.MessageTipsMgr.ShowMessageTips then\n` +
`                    gCS.MessageTipsMgr:ShowMessageTips(tip)\n` +
`                end\n` +
`            end)\n` +
`        end)\n` +
`    elseif cmd == "CLOSE_MINIGAME" or cmd == "CMD:CLOSE_MINIGAME" then\n` +
`        pcall(function()\n` +
`            local toClose = {\n` +
`                gPanelId and gPanelId.LIBRETRO_PANEL,\n` +
`                gPanelId and gPanelId.FIGHTER_MAIN_PANEL,\n` +
`                gPanelId and gPanelId.FIGHTER_HUD_PANEL,\n` +
`                gPanelId and gPanelId.UI_PANEL__INSTRUMENT__PIANO,\n` +
`                gPanelId and gPanelId.UI_PANEL__INSTRUMENT__DRUMKIT,\n` +
`                gPanelId and gPanelId.MINI_GAMES_BOWLING_MAIN_PANEL,\n` +
`                gPanelId and gPanelId.BASKETBALL_SHOOT_PANEL\n` +
`            }\n` +
`            for _, pid in ipairs(toClose) do\n` +
`                if pid and gPanelManager then\n` +
`                    pcall(function() gPanelManager:Close(pid) end)\n` +
`                end\n` +
`            end\n` +
`            pcall(function()\n` +
`                if gDisplayMessageMgr and gDisplayMessageMgr.ShowMessageContent then\n` +
`                    gDisplayMessageMgr:ShowMessageContent("Closed Minigame")\n` +
`                end\n` +
`            end)\n` +
`        end)\n` +
`    elseif cmd == "TOGGLE_CLOTHES" then\n` +
`        pcall(function()\n` +
`            local unit = gCS and gCS.MyPlayerManager and gCS.MyPlayerManager.PlayerUnit\n` +
`            if not unit or not unit.PlayerObj then return end\n` +
`            _G._clothesHidden = not _G._clothesHidden\n` +
`            pcall(function()\n` +
`                if CS and CS.LX6 and CS.LX6.Share and CS.LX6.Share.FashionPartSlot then\n` +
`                    local partSlots = unit.PlayerObj:GetComponentsInChildren(typeof(CS.LX6.Share.FashionPartSlot), true)\n` +
`                    if partSlots then\n` +
`                        for i = 0, partSlots.Length - 1 do\n` +
`                            local ps = partSlots[i]\n` +
`                            if ps then\n` +
`                                local psName = string.lower((ps.gameObject and ps.gameObject.name) or "")\n` +
`                                local isHeadOrBody = string.find(psName, "head") or string.find(psName, "face") or string.find(psName, "body") or string.find(psName, "skin")\n` +
`                                if not isHeadOrBody then\n` +
`                                    if ps.gameObject then ps.gameObject:SetActive(not _G._clothesHidden) end\n` +
`                                    if ps.selfRenderer then ps.selfRenderer.enabled = not _G._clothesHidden end\n` +
`                                end\n` +
`                            end\n` +
`                        end\n` +
`                    end\n` +
`                end\n` +
`            end)\n` +
`            local fs = nil\n` +
`            pcall(function()\n` +
`                if CS and CS.LX6 and CS.LX6.Share and CS.LX6.Share.FashionSlot then\n` +
`                    fs = unit.PlayerObj:GetComponentInChildren(typeof(CS.LX6.Share.FashionSlot))\n` +
`                end\n` +
`            end)\n` +
`            if not fs then\n` +
`                pcall(function()\n` +
`                    fs = unit.FashionSlot or (unit.ModelSlot and unit.ModelSlot.FashionSlot)\n` +
`                end)\n` +
`            end\n` +
`            if fs then\n` +
`                pcall(function()\n` +
`                    if fs.allFashionRendererList then\n` +
`                        for i = 0, fs.allFashionRendererList.Count - 1 do\n` +
`                            local r = fs.allFashionRendererList[i]\n` +
`                            if r then r.enabled = not _G._clothesHidden end\n` +
`                        end\n` +
`                    end\n` +
`                    local clothesSlots = { fs.Cloth, fs.Bottom, fs.Dress, fs.Bag, fs.Hood, fs.Belt, fs.Necklace }\n` +
`                    for _, r in ipairs(clothesSlots) do\n` +
`                        if r then r.enabled = not _G._clothesHidden end\n` +
`                    end\n` +
`                    if fs.SpProps then\n` +
`                        for i = 0, fs.SpProps.Count - 1 do\n` +
`                            local r = fs.SpProps[i]\n` +
`                            if r then r.enabled = not _G._clothesHidden end\n` +
`                        end\n` +
`                    end\n` +
`                    local keepSlots = { fs.Face, fs.Hair, fs.Hair01, fs.Hair02, fs.Ear, fs.Tail, fs.Gloves, fs.Shoes, fs.Sleeve }\n` +
`                    for _, r in ipairs(keepSlots) do\n` +
`                        if r then r.enabled = true end\n` +
`                    end\n` +
`                end)\n` +
`            end\n` +
`            local smrs = unit.PlayerObj:GetComponentsInChildren(typeof(UnityEngine.SkinnedMeshRenderer), true)\n` +
`            if smrs then\n` +
`                for i = 0, smrs.Length - 1 do\n` +
`                    local smr = smrs[i]\n` +
`                    if smr then\n` +
`                        local n = string.lower(smr.name or "")\n` +
`                        local isBodyLimb = string.find(n, "face") or string.find(n, "head") or string.find(n, "hair") or string.find(n, "eye") or string.find(n, "brow") or string.find(n, "mouth") or string.find(n, "ear") or string.find(n, "tail") or string.find(n, "arm") or string.find(n, "hand") or string.find(n, "glove") or string.find(n, "sleeve") or string.find(n, "leg") or string.find(n, "foot") or string.find(n, "feet") or string.find(n, "shoe") or string.find(n, "boot") or string.find(n, "skin") or string.find(n, "flesh") or string.find(n, "shenti") or string.find(n, "tou") or string.find(n, "lian") or string.find(n, "shou") or string.find(n, "bi") or string.find(n, "tui")\n` +
`                        local isClothing = string.find(n, "cloth") or string.find(n, "coat") or string.find(n, "skirt") or string.find(n, "pant") or string.find(n, "dress") or string.find(n, "jacket") or string.find(n, "yifu") or string.find(n, "kuzi") or string.find(n, "qun") or string.find(n, "hood") or string.find(n, "cape") or string.find(n, "cloak") or string.find(n, "belt") or string.find(n, "bag") or string.find(n, "prop") or string.find(n, "necklace") or string.find(n, "acc")\n` +
`                        if isBodyLimb and not (isClothing and not string.find(n, "arm") and not string.find(n, "hand") and not string.find(n, "leg") and not string.find(n, "foot") and not string.find(n, "face")) then\n` +
`                            smr.enabled = true\n` +
`                        elseif isClothing then\n` +
`                            smr.enabled = not _G._clothesHidden\n` +
`                        else\n` +
`                            if not _G._clothesHidden then\n` +
`                                smr.enabled = true\n` +
`                            end\n` +
`                        end\n` +
`                    end\n` +
`                end\n` +
`            end\n` +
`            pcall(function()\n` +
`                local tip = _G._clothesHidden and "Outfit Hidden / ร่างต้น (F8)" or "Outfit Shown / แสดงชุดปกติ (F8)"\n` +
`                if gDisplayMessageMgr and gDisplayMessageMgr.ShowMessageContent then\n` +
`                    gDisplayMessageMgr:ShowMessageContent(tip)\n` +
`                end\n` +
`                if gCS and gCS.MessageTipsMgr and gCS.MessageTipsMgr.ShowMessageTips then\n` +
`                    gCS.MessageTipsMgr:ShowMessageTips(tip)\n` +
`                end\n` +
`            end)\n` +
`        end)\n` +
`    elseif string.sub(cmd, 1, 8) == "SET_FOG:" then\n` +
`        local arg = string.sub(cmd, 9)\n` +
`        local density = tonumber(arg) or 0\n` +
`        pcall(function()\n` +
`            if CS and CS.CTT3 and CS.CTT3.Weather and CS.CTT3.Weather.WeatherBridge then\n` +
`                if density > 0 then\n` +
`                    CS.CTT3.Weather.WeatherBridge.EnableExternalExpFogDensity(density)\n` +
`                    CS.CTT3.Weather.WeatherBridge.EnableExternalSkyFogDensity(density)\n` +
`                    CS.CTT3.Weather.WeatherBridge.EnableExternalExpFogStartDistance(0.0)\n` +
`                    CS.CTT3.Weather.WeatherBridge.EnableExternalSkyFogStartDistance(0.0)\n` +
`                else\n` +
`                    CS.CTT3.Weather.WeatherBridge.DisableExternalExpFogDensity()\n` +
`                    CS.CTT3.Weather.WeatherBridge.DisableExternalSkyFogDensity()\n` +
`                    CS.CTT3.Weather.WeatherBridge.DisableExternalExpFogStartDistance()\n` +
`                    CS.CTT3.Weather.WeatherBridge.DisableExternalSkyFogStartDistance()\n` +
`                end\n` +
`            end\n` +
`            pcall(function()\n` +
`                local Color = UnityEngine.Color\n` +
`                UnityEngine.RenderSettings.fog = (density > 0)\n` +
`                UnityEngine.RenderSettings.fogDensity = density\n` +
`                UnityEngine.RenderSettings.fogMode = UnityEngine.FogMode.ExponentialSquared\n` +
`                UnityEngine.RenderSettings.fogColor = Color(0.75, 0.78, 0.82, 1.0)\n` +
`            end)\n` +
`            local tip = density > 0 and ("Fog Set: " .. tostring(density)) or "Fog Cleared"\n` +
`            if gDisplayMessageMgr and gDisplayMessageMgr.ShowMessageContent then\n` +
`                gDisplayMessageMgr:ShowMessageContent(tip)\n` +
`            end\n` +
`            if gCS and gCS.MessageTipsMgr and gCS.MessageTipsMgr.ShowMessageTips then\n` +
`                gCS.MessageTipsMgr:ShowMessageTips(tip)\n` +
`            end\n` +
`        end)\n` +
`    elseif string.sub(cmd, 1, 12) == "SET_WEATHER:" then\n` +
`        local arg = string.sub(cmd, 13)\n` +
`        local wId = tonumber(arg) or 1\n` +
`        pcall(function()\n` +
`            if CS and CS.CTT3 and CS.CTT3.Weather and CS.CTT3.Weather.WeatherBridge then\n` +
`                CS.CTT3.Weather.WeatherBridge.SetWeather(wId, 2.0)\n` +
`                if wId == 3 or wId == 4 then\n` +
`                    CS.CTT3.Weather.WeatherBridge.SetGPURainActive(true)\n` +
`                else\n` +
`                    CS.CTT3.Weather.WeatherBridge.SetGPURainActive(false)\n` +
`                end\n` +
`            end\n` +
`            if CS and CS.LX6 and CS.LX6.Manager and CS.LX6.Manager.AtmosphereManager and CS.LX6.Manager.AtmosphereManager.Instance then\n` +
`                pcall(function() CS.LX6.Manager.AtmosphereManager.Instance:SetWeather(wId, 2.0) end)\n` +
`            end\n` +
`            if gCS and gCS.WeatherManager and gCS.WeatherManager.SetWeather then\n` +
`                gCS.WeatherManager:SetWeather(wId)\n` +
`            end\n` +
`            local tip = "Weather Set: " .. tostring(wId)\n` +
`            if gDisplayMessageMgr and gDisplayMessageMgr.ShowMessageContent then\n` +
`                gDisplayMessageMgr:ShowMessageContent(tip)\n` +
`            end\n` +
`            if gCS and gCS.MessageTipsMgr and gCS.MessageTipsMgr.ShowMessageTips then\n` +
`                gCS.MessageTipsMgr:ShowMessageTips(tip)\n` +
`            end\n` +
`        end)\n` +
`    end\n` +
`end\n\n` +
`local function HookNoticeTable(tbl)\n` +
`    if not tbl or type(tbl) ~= "table" or tbl._cmdHooked then return end\n` +
`    tbl._cmdHooked = true\n` +
`    local function makeCmdWrapper(origFunc)\n` +
`        return function(...)\n` +
`            local allArgs = {...}\n` +
`            for i = 1, #allArgs do\n` +
`                local arg = allArgs[i]\n` +
`                if type(arg) == "string" and string.sub(arg, 1, 4) == "CMD:" then\n` +
`                    ProcessDebugCommand(string.sub(arg, 5))\n` +
`                    return\n` +
`                elseif type(arg) == "table" then\n` +
`                    for _, val in pairs(arg) do\n` +
`                        if type(val) == "string" and string.sub(val, 1, 4) == "CMD:" then\n` +
`                            ProcessDebugCommand(string.sub(val, 5))\n` +
`                            return\n` +
`                        end\n` +
`                    end\n` +
`                end\n` +
`            end\n` +
`            if origFunc then return origFunc(...) end\n` +
`        end\n` +
`    end\n` +
`    if tbl.SyncNotice then\n` +
`        tbl.SyncNotice = makeCmdWrapper(tbl.SyncNotice)\n` +
`    end\n` +
`    if tbl.SyncShowMessage then\n` +
`        tbl.SyncShowMessage = makeCmdWrapper(tbl.SyncShowMessage)\n` +
`    end\n` +
`    if tbl.SyncShowTipMessage then\n` +
`        tbl.SyncShowTipMessage = makeCmdWrapper(tbl.SyncShowTipMessage)\n` +
`    end\n` +
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
`            HookNoticeTable(package.loaded["LX6/Service/GameSceneToClientImpl"])\n` +
`            local autoLoaded = package.loaded["LuaGen/AutoGen/RPCDeserializeAuto"]\n` +
`            if autoLoaded and autoLoaded.midToReader then\n` +
`                autoLoaded.midToReader[45418774] = function(reader) return reader:ReadString() end\n` +
`                autoLoaded.midToName[45418774] = "SyncNotice"\n` +
`            end\n` +
`            local baseLoaded = package.loaded["LX6/Service/RPCDeserializeBase"]\n` +
`            if baseLoaded and not baseLoaded._cmdHooked then\n` +
`                baseLoaded._cmdHooked = true\n` +
`                local oldDisp = baseLoaded.Dispatcher\n` +
`                baseLoaded.Dispatcher = function(ctx, br, mid)\n` +
`                    if mid == 45418774 then\n` +
`                        pcall(function()\n` +
`                            local str = br:ReadString()\n` +
`                            if type(str) == "string" and string.sub(str, 1, 4) == "CMD:" then\n` +
`                                ProcessDebugCommand(string.sub(str, 5))\n` +
`                            end\n` +
`                        end)\n` +
`                        return true\n` +
`                    end\n` +
`                    return oldDisp(ctx, br, mid)\n` +
`                end\n` +
`            end\n` +
`        end\n` +
`        if MasterToClientImpl then HookNoticeTable(MasterToClientImpl) end\n` +
`        if GameToClientImpl then HookNoticeTable(GameToClientImpl) end\n` +
`        if GameSceneToClientImpl then HookNoticeTable(GameSceneToClientImpl) end\n` +
`        HookDisplayMessageMgr()\n` +
`    end)\n` +
`end\n\n` +
`local oldRequire = require\n` +
`require = function(mod)\n` +
`    local res = oldRequire(mod)\n` +
`    pcall(ApplyAllGlobalHooks)\n` +
`    if mod == "LX6/Service/MasterToClientImpl" or mod == "LX6/Service/GameToClientImpl" or mod == "LX6/Service/GameSceneToClientImpl" then\n` +
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

