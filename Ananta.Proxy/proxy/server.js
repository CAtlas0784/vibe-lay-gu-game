const dns = require("dns").promises;
const crypto = require("crypto");
const fs = require("fs");
const http = require("http");
const https = require("https");
const net = require("net");
const os = require("os");
const path = require("path");
const util = require("util");

// Mirror the runtime console into the same files as the C# server. Run-All.ps1
// prepares these paths once per run, so both processes share one timestamp.
const Ananta_CONSOLE_LATEST = process.env.Ananta_CONSOLE_LOG_LATEST || null;
const Ananta_CONSOLE_ARCHIVE = process.env.Ananta_CONSOLE_LOG_ARCHIVE || null;
function appendUnifiedConsole(line) {
  for (const file of [Ananta_CONSOLE_LATEST, Ananta_CONSOLE_ARCHIVE]) {
    if (!file) continue;
    try { fs.mkdirSync(path.dirname(file), { recursive: true }); fs.appendFileSync(file, `${line}\n`, "utf8"); } catch { }
  }
}
const originalConsoleLog = console.log.bind(console);
const originalConsoleWarn = console.warn.bind(console);
const originalConsoleError = console.error.bind(console);
console.log = (...args) => { const line = util.format(...args); appendUnifiedConsole(line); originalConsoleLog(...args); };
console.warn = (...args) => { const line = util.format(...args); appendUnifiedConsole(line); originalConsoleWarn(...args); };
console.error = (...args) => { const line = util.format(...args); appendUnifiedConsole(line); originalConsoleError(...args); };
const { config } = require("./private_server_config");
// v12: schema-driven serializer (mirrors client RPCSerializeBase.lua)
const { RpcSerializer } = require("./rpc_serializer");
const { Writer } = require("./rpc_serializer");
const RPC = new RpcSerializer(path.join(__dirname, "rpc_schema.json"));
// REAL client serializer (RPCSerializeAuto.lua executed verbatim in a Lua VM).
// This is the single source of truth for packet bytes - identical to what the
// official server's generated serializer produces. No hand-built schema.
const LuaWriter = require("./lua_writer");

// SyncPlayerAllTask notify (0x03D48AF5) - 4229938 client layout, verified
// against UXRPCMethodArgs64260853.Read and TypeSerializer.ReadEventPanelInfo
// in the 4229938 GameAssembly:
//   taskInfos        nullable list (flag + 7-bit count) — empty
//   submitTaskList   nullable list — empty
//   currentTask      u32
//   eventPanelInfo   nullable complex { EventsInfo, SubmitEventList,
//                     SubmitReplayEventList, EventViewInfoList } — each a
//                     nullable list with 7-bit count; no inner object marker
//   loginGameServer  bool
// The 4229938 stream (0xFF + Int32 counts, extra submitEventList arg-level
// field, EventViewInfoList outside the complex) desyncs this reader and kills
// the client with DeserializeRpcStreamBufferNotEnoughException.
function buildSyncPlayerAllTask() {
  const w = new Writer();
  const emptyList = [0x01, 0x00]; // present flag + 7-bit count 0
  // taskInfos: List<TaskViewData> -> empty
  w.WriteRawBuffer(Buffer.from(emptyList));
  // submitTaskList: List<u32> -> empty
  w.WriteRawBuffer(Buffer.from(emptyList));
  // currentTask: u32
  w.WriteUInt32(0);
  // eventPanelInfo: present, then its four nullable lists
  w.WriteByte(0x01);
  w.WriteRawBuffer(Buffer.from(emptyList)); // EventsInfo
  w.WriteRawBuffer(Buffer.from(emptyList)); // SubmitEventList
  w.WriteRawBuffer(Buffer.from(emptyList)); // SubmitReplayEventList
  w.WriteRawBuffer(Buffer.from(emptyList)); // EventViewInfoList
  // loginGameServer: bool = true
  w.WriteBoolean(true);
  return w.toBuffer();
}

const HOST = config.network.proxy.updateHost;
const PORT = config.network.proxy.httpsPort;
const HTTP_CAPTURE_PORT = config.network.proxy.httpPort;
const LOGIN_LIST_PORT = config.network.proxy.loginListPort;
const LOCAL_LOGIN_HOST = config.network.advertisedHost;
const LOCAL_LOGIN_TCP_BIND_HOST = config.network.bindHost;
const LOCAL_LOGIN_TCP_PORT = config.network.proxy.loginTcpPort;
const LOCAL_GAME_TCP_PORT = config.network.proxy.gameTcpPort;
const ROOT = __dirname;
const CERT_DIR = path.join(ROOT, "certs");
const LOG_DIR = path.join(ROOT, "logs");
const VERSION_JSON = path.join(ROOT, "public", "pc_netease_version.json");
const PFX_PATH = path.join(CERT_DIR, `${HOST}.pfx`);
const PFX_PASSPHRASE = config.network.proxy.certificatePassphrase;
const CAPTURE_BODY_LIMIT = 16 * 1024;

fs.mkdirSync(LOG_DIR, { recursive: true });

function getLanIpv4() {
  for (const entries of Object.values(os.networkInterfaces())) {
    for (const entry of entries || []) {
      if (entry.family === "IPv4" && !entry.internal) {
        return entry.address;
      }
    }
  }
  return null;
}

const LOCAL_LOGIN_TCP_HOSTS = Array.from(
  new Set([LOCAL_LOGIN_HOST, getLanIpv4()].filter(Boolean)),
);

const RPC_PACKET_NOTIFY = 3;
const RPC_PACKET_INVOKE = 1;
const RPC_PACKET_RETURN = 2;
const RPC_ERR_NO_MORE_HOTFIX_PATCH = config.client.noMoreHotfixPatchError;
const CLIENT_VERSION = String(config.client.version);
const CLIENT_ARTIFACT_VERSION = String(config.client.artifactVersion);
const LOCAL_SERVER_ID = config.client.serverId;
const LOCAL_AID = config.client.aid;
const LOCAL_PLAYER_PID = config.player.pid;
const LOCAL_ACCOUNT_ID = config.player.accountId;
const LOCAL_USERNAME = config.player.userName;
const LOCAL_DISPLAY_NAME = config.player.displayName;
const LOCAL_LOGIN_TOKEN = config.player.loginToken;
const LOCAL_PLAYER_TOKEN = config.player.gameToken;
const LOCAL_SHARE_TOKEN = config.player.shareToken;
const LOCAL_FP_PASS_TOKEN = config.player.fpPassToken;
const LOCAL_SKEY = config.player.skey;
// Server identity and RPC MD5 come from config/private-server.json.
const CLIENT_RPC_MD5 = process.env.Ananta_RPC_MD5 || config.client.rpcMd5;
const RPC_METHODS = Object.freeze({
  Login_RequestCreateRoleEx: 34383517,
  Login_CheckVersion: 34700853,
  Login_AskNewHotFixPatchLogin: 34692559,
  Login_RequestPatchesCheckDataFromLogin: 34601301,
  Login_AskUniSdkShareToken_Login: 34110053,
  Login_CheckAccount: 34339919,
  Login_CheckAccountPassBy: 34163006,
  Login_CheckAccountOpenId: 34381554,
  Login_TryLogin: 34529582,
  Login_HasOnlinePlayer: 34822236,
  Login_RequestPatchesFromLogin: 34022227,
  Login_RequestEnterGame: 34566515,
  Login_DebugRequestEnterGame: 34478273,
  Login_RequestFpPassToken: 34828770,
  Gate_AskUniSdkShareToken: 52152686,
  Gate_AskCloseConnection: 52140059,
  Gate_GetServerTime: 52951195,
  Gate_Login: 52023760,
  Game_AskCloseConnection: 63990036,
  Game_AskChangeHackerName: 63975191,
  Game_AskRemainChangeNameCount: 63980351,
  Game_GetServerTime: 63266454,
  Game_AskChangeNameByItem: 63087020,
  Game_RequestGameSceneData: 63427902,
  // This RPC is absent from the 4229938 table. Kept for older fallback clients.
  Game_AskStartGame: 63820182,
  Game_LoginGame: 63142082,
  Game_AskPanelBrowsingTime: 63927330,
});
const RPC_NOTIFIES = Object.freeze({
  Login_SyncRoleList: 35167428,
  Login_SyncGameModeInfo: 35892717,
  Gate_SendServerTime: 53477227,
  Avatar_SyncPlayerGameServerInfo: 154693736,
  Game_SendServerTimeGame: 64114176,
  Game_SyncPlayerAllTask: 64260853,
  Game_SyncPlayerInfo: 64682159,
  Game_SyncEnterScene: 64406364,
  GameScene_SyncWorldReady: 68490276,
  GameScene_SyncPlayerLoadRate: 68547190,
  GameScene_SyncPlayerCurrentSpirit: 68830687,
});
const RPC_METHOD_NAMES = new Map(
  Object.entries(RPC_METHODS).map(([name, methodId]) => [methodId, name]),
);

function rpcMethodName(methodId) {
  return RPC_METHOD_NAMES.get(methodId) || `Unknown_${methodId}`;
}

let loginListRequestCount = 0;

function loginListCandidates() {
  const candidates = [];
  candidates.push({
    name: "csharp-login-first",
    body: `${LOCAL_LOGIN_HOST}:${config.network.loginPorts[0]}\n${LOCAL_LOGIN_HOST}:${config.network.loginPorts[1]}\n`,
  });
  for (const host of LOCAL_LOGIN_TCP_HOSTS) {
    // V1-proven simple format `host:port\n` is what worked.
    candidates.push({ name: `colon-${host}`, body: `${host}:${LOCAL_LOGIN_TCP_PORT}\n` });
    candidates.push({ name: `csv-ip-port-${host}`, body: `${host},${LOCAL_LOGIN_TCP_PORT}\n` });
    candidates.push({ name: `csv-index-ip-port-${host}`, body: `0,${host},${LOCAL_LOGIN_TCP_PORT}\n` });
    candidates.push({ name: `csv-two-index-ip-port-${host}`, body: `0,0,${host},${LOCAL_LOGIN_TCP_PORT}\n` });
    candidates.push({ name: `csv-server-ip-port-${host}`, body: `${LOCAL_SERVER_ID},${host},${LOCAL_LOGIN_TCP_PORT}\n` });
    candidates.push({ name: `pipe-ip-port-${host}`, body: `${host}|${LOCAL_LOGIN_TCP_PORT}\n` });
    candidates.push({ name: `space-ip-port-${host}`, body: `${host} ${LOCAL_LOGIN_TCP_PORT}\n` });
    candidates.push({
      name: `json-array-${host}`,
      body: JSON.stringify([{ ip: host, port: LOCAL_LOGIN_TCP_PORT }]) + "\n",
    });
    candidates.push({
      name: `json-data-${host}`,
      body:
        JSON.stringify({
          code: 0,
          data: [{ ip: host, port: LOCAL_LOGIN_TCP_PORT }],
        }) + "\n",
    });
  }
  return candidates;
}

const COMPACT_LOG = process.env.Ananta_COMPACT_LOG === "1";
const HIDE_BOOT_LOG = process.env.Ananta_HIDE_BOOT_LOG === "1";

function log(message) {
  const iso = new Date().toISOString();
  const line = `[${iso}] ${message}`;
  fs.appendFileSync(path.join(LOG_DIR, "proxy.log"), `${line}\n`);

  if (!COMPACT_LOG) {
    console.log(line);
    return;
  }

  // Listener announcements are bootstrap-only noise. Keep them in both log files,
  // but do not print them into the interactive startup window.
  if (HIDE_BOOT_LOG && message.startsWith("listening on ")) {
    const bootTime = new Date().toLocaleTimeString("en-GB", { hour12: false });
    appendUnifiedConsole(`[${bootTime}] [PX] ${message}`);
    return;
  }

  // Full request bodies remain in proxy/logs/proxy.log. The console only shows
  // milestones that are useful while bringing the client online.
  const noisy =
    message.startsWith("unisdk-capture ") ||
    message.startsWith("local-gray-release ") ||
    message.startsWith("local-music ") ||
    message.startsWith("proxy GET ") ||
    message.startsWith("proxy POST ");
  if (noisy) return;

  const keep =
    message.startsWith("listening on ") ||
    message.startsWith("local-serverlist") ||
    message.startsWith("local-loginlist") ||
    message.startsWith("local-outertest-config") ||
    message.startsWith("local-fastpatch") ||
    message.startsWith("local-resource-patch-info") ||
    message.startsWith("local-startup-patch") ||
    message.startsWith("local-device-check") ||
    message.startsWith("local-uni-sauth") ||
    message.startsWith("local-check-enter") ||
    message.includes("error") ||
    message.includes("fatal") ||
    message.includes("404");
  if (!keep) return;

  // Console time is local, matching the C# server logger. Full proxy.log keeps ISO UTC.
  const time = new Date().toLocaleTimeString("en-GB", { hour12: false });
  console.log(`[${time}] [PX] ${message}`);
}

const upstreamCache = new Map();
const UPSTREAM_IP_OVERRIDES = Object.freeze({
  // Akamai addresses returned for the 4229938 resource CDN. This fallback is
  // needed on machines where the local hosts redirect makes resolve4 time out.
  "l50.gdl.netease.com": ["104.109.143.24", "104.109.143.10"],
});

function isPublicIpv4(ip) {
  return !(
    ip.startsWith("127.") ||
    ip.startsWith("10.") ||
    ip.startsWith("192.168.") ||
    ip.startsWith("172.16.") ||
    ip.startsWith("172.17.") ||
    ip.startsWith("172.18.") ||
    ip.startsWith("172.19.") ||
    ip.startsWith("172.2") ||
    ip.startsWith("172.30.") ||
    ip.startsWith("172.31.") ||
    ip === "0.0.0.0"
  );
}

async function resolveUpstream(host = HOST) {
  const normalizedHost = String(host || HOST).split(":")[0].toLowerCase();
  const now = Date.now();
  const cached = upstreamCache.get(normalizedHost);
  if (cached && cached.until > now) {
    return cached.address;
  }

  let addresses;
  try {
    addresses = await dns.resolve4(normalizedHost);
  } catch (error) {
    addresses = UPSTREAM_IP_OVERRIDES[normalizedHost];
    if (!addresses) {
      throw error;
    }
    log(`using upstream IP fallback for ${normalizedHost}: ${addresses.join(", ")}`);
  }
  const publicAddress = addresses.find(isPublicIpv4);
  if (!publicAddress) {
    throw new Error(`No public DNS address for ${normalizedHost}: ${addresses.join(", ")}`);
  }

  upstreamCache.set(normalizedHost, { address: publicAddress, until: now + 60_000 });
  return publicAddress;
}

function serveLocalVersion(res) {
  // Trunk resource stream 20260805061659654p0.  The client's local download
  // history still says 20260707064825384p0 (the trunk build ships 0707-based
  // resources), so the client runs the LARGE_PATCH flow: it fetches the real
  // CDN Patch.info (md5 must equal resC) and then downloads the delta packages
  // through this proxy.  The real manifest for this stream is deployed at
  // public/Patch_20260805061659654p0.info (md5 b5481abf8e882801b424fe2c0bf0adfe,
  // verified against the official CDN).
  const resourceVersion = String(
    process.env.Ananta_PROXY_RESOURCE_VERSION || "20260805061659654p0"
  );
  const resourceChecksum = String(
    process.env.Ananta_PROXY_RESOURCE_CHECKSUM || "b5481abf8e882801b424fe2c0bf0adfe"
  );
  const body = Buffer.from(JSON.stringify({
    resUpdate: [{
      minV: "0",
      maxV: "18446744073709551615",
      resV: resourceVersion,
      resC: resourceChecksum,
      soResC: "",
      enableDlc: "False",
      triggerWarmupBelowVersion: "",
      codeV: CLIENT_VERSION,
      artifactV: CLIENT_ARTIFACT_VERSION,
      enableIBT: "False",
      enableIBTOneInN: "1",
    }],
  }));
  res.writeHead(200, {
    "content-type": "application/json; charset=utf-8",
    "content-length": body.length,
    "cache-control": "no-store",
  });
  res.end(body);
}

function serveLocalDeviceCheck(res) {
  serveJson(res, {
    checkInGame: false,
    minimumRequirements: {
      minCPUScore: 0,
      minGPUScore: 0,
      minRAM: 0,
      minGraphicsMemory: 0,
      minOSVersion: 0,
      ssdRequired: false,
    },
    cpuRequirements: [],
    gpuRequirements: [],
    cpuBlacklist: [],
    gpuBlacklist: [],
    gpuDriverBlacklist: [],
    cpuWhitelist: [],
    gpuWhitelist: [],
  });
}

function serveText(res, body, contentType = "text/plain; charset=utf-8") {
  const buffer = Buffer.from(body, "utf8");
  res.writeHead(200, {
    "content-type": contentType,
    "content-length": buffer.length,
    "cache-control": "no-store",
    "connection": "close",
  });
  res.end(buffer);
}

function serveJson(res, value) {
  serveText(res, JSON.stringify(value), "application/json; charset=utf-8");
}

function serveHtml(res, body) {
  serveText(res, body, "text/html; charset=utf-8");
}

function collectRequestBody(req) {
  return new Promise((resolve) => {
    const chunks = [];
    let size = 0;

    req.on("data", (chunk) => {
      size += chunk.length;
      if (size <= CAPTURE_BODY_LIMIT) {
        chunks.push(chunk);
      }
    });

    req.on("end", () => {
      const buffer = Buffer.concat(chunks);
      resolve({
        size,
        text: buffer.toString("utf8").replace(/[\r\n]+/g, " ").slice(0, CAPTURE_BODY_LIMIT),
      });
    });

    req.on("error", () => {
      resolve({ size, text: "" });
    });
  });
}

function serveEmptyStartupPatchInfo(res) {
  serveText(res, "");
}

// =============================================================================
// IFix startup patch routes
// =============================================================================
// The client fetches GET /trunk-client_startup_patch_info.txt to discover
// which IFix hot-patches must be loaded at boot. The body lists patch IDs
// pointing at .bytes.standalone files. Loading the listed stage0 IFix
// patch registers iFix-slot method patches like
// LoginManager.LoginGameServer's iFix dispatcher slot, which is what
// makes the post-Gate_Login SyncPlayerAllTask -> ConnectGame chain fire.
//
// Files served:
//   /trunk-client_startup_patch_info.txt
//     -> public/trunk-client_startup_patch_info.txt (loader manifest)
//   /2724864/2724864-20260116021030-Assembly-CSharp.stage0.patch.bytes.standalone
//     -> public/stage0_patch.bytes.standalone (IFix magic 3d 57 5d e8 ...)

function serveBinaryFile(res, relPath, contentType, extraHeaders = {}) {
  const fs = require("fs");
  const filePath = path.join(ROOT, "public", relPath);
  try {
    const data = fs.readFileSync(filePath);
    res.writeHead(200, {
      "content-type": contentType || "application/octet-stream",
      "content-length": data.length,
      "connection": "close",
      ...extraHeaders,
    });
    res.end(data);
    return true;
  } catch (e) {
    return false;
  }
}

function streamBinaryFile(res, relPath, contentType) {
  const filePath = path.join(ROOT, "public", relPath);
  try {
    const stat = fs.statSync(filePath);
    res.writeHead(200, {
      "content-type": contentType || "application/octet-stream",
      "content-length": stat.size,
      "connection": "close",
    });
    const stream = fs.createReadStream(filePath);
    stream.on("error", (error) => {
      log(`local file stream error ${relPath}: ${error.message}`);
      res.destroy(error);
    });
    stream.pipe(res);
    return true;
  } catch (e) {
    return false;
  }
}

function serveStartupPatchInfo(res) {
  // The old stage-0 blob targets client 2758041 and is binary-incompatible with
  // 4229938. The official endpoint also has no startup patch for this build.
  res.writeHead(404, { "content-type": "text/plain; charset=utf-8", "connection": "close" });
  res.end(`no startup patch for client ${CLIENT_VERSION}`);
}

function serveStage0Patch(res) {
  if (!serveBinaryFile(res, "stage0_patch.bytes.standalone", "application/octet-stream")) {
    res.writeHead(404, { "content-type": "text/plain", "connection": "close" });
    res.end("stage0 patch not present");
  }
}

function serveOuterTestConfig(res) {
  if (!serveBinaryFile(res, "OuterTest1_ConstConfig.cfg", "application/octet-stream")) {
    res.writeHead(404, { "content-type": "text/plain", "connection": "close" });
    res.end("OuterTest1 config not present");
  }
}

function serveFastPatchClient(res) {
  const zipName = `fastpatch_${config.client.version}.zip`;
  if (!serveBinaryFile(res, zipName, "application/zip", {
    "cache-control": "no-store, no-cache, must-revalidate, max-age=0",
    "pragma": "no-cache",
    "expires": "0",
  })) {
    res.writeHead(404, { "content-type": "text/plain; charset=utf-8", "connection": "close" });
    res.end(`fastpatch for client ${config.client.version} not present`);
  }
}

function serveResourcePatchInfo(res, requestedVersion, isHead = false) {
  // Serve the manifest whose md5 equals the advertised resC.  The file name
  // follows resV from serveLocalVersion, so both stay in sync (patch info and
  // version entry come from the same resource stream).
  const resourceVersion = String(
    requestedVersion || process.env.Ananta_PROXY_RESOURCE_VERSION || "20260805061659654p0"
  );
  const filePath = path.join(ROOT, "public", `Patch_${resourceVersion}.info`);
  if (!fs.existsSync(filePath)) {
    res.writeHead(404, { "content-type": "text/plain; charset=utf-8", "connection": "close" });
    res.end(`resource Patch.info for ${resourceVersion} not present`);
    return;
  }
  const stat = fs.statSync(filePath);
  res.writeHead(200, {
    "content-type": "application/x-info",
    "content-length": stat.size,
    "connection": "close",
  });
  if (isHead) {
    res.end();
    return;
  }
  const stream = fs.createReadStream(filePath);
  stream.on("error", (error) => {
    log(`local file stream error Patch_${resourceVersion}.info: ${error.message}`);
    res.destroy(error);
  });
  stream.pipe(res);
}

function serveLocalServerList(res) {
  // The row format matches the REAL captured official serverlist
  // (public/OuterTest1_serverlist.upstream.txt): exactly 7 columns, with no
  // version/rpcMd5/artifact columns.  LoginManager.CheckVersion in build
  // 4229938 compares RpcMd5/Branch/Tag/ArtifactVersion only when non-empty;
  // the official row omits them entirely and so must we.  Sending the legacy
  // 6905aaa9... md5 made CheckVersion reject every row (the trunk client
  // computes its expected contract md5 at runtime), which surfaced as
  // "Server is under maintenance" after server-list retries.
  const loginListUrl = `http://${LOCAL_LOGIN_HOST}:${LOGIN_LIST_PORT}/LoginList`;
  const body = [[
    "*",
    String(LOCAL_SERVER_ID),
    "QA101",
    "Outer",
    loginListUrl,
    "1",
    "14",
  ].join(",")].join("\n") + "\n";
  log(`local-serverlist-body config client=${CLIENT_VERSION} serverId=${LOCAL_SERVER_ID} rpcMd5=<empty, CheckVersion bypass>`);
  serveText(res, body);
}

function serveLocalAudit(res) {
  serveText(
    res,
    [
      "8000000",
      "local private server compatibility stub",
      "ok",
      "",
    ].join("\n"),
  );
}

function serveLocalGameNotice(res) {
  // The /game_notice/Login.bin endpoint is consumed by
  // LX6.Manager.LoginManager.OnLoginLuaUpdate which decrypts the body
  // (AES-256-CBC + PKCS#7, key="Iwgt7nczyaxtZ2jcY9jxvVz6xorrsczf",
  // iv="G5EcEeO5SmFXFAR4") and runs it as a Lua text chunk
  // (load(content, nil, "t") + xpcall). If we have a pre-built Login.bin
  // in public/ we serve that, otherwise an empty body so the game just
  // skips the patch step.
  if (!serveBinaryFile(res, "Login.bin", "application/octet-stream")) {
    serveText(res, "");
  }
}

function isUpdateHost(req) {
  const host = (req.headers.host || "").split(":")[0].toLowerCase();
  // Treat the IFix patch CDN host (l50.gph.netease.com) as "local" too:
  // the manifest at /trunk-client_startup_patch_info.txt points the client
  // at this host for the stage0 .bytes.standalone download. We serve that
  // file from public/ via the /...stage0.patch.bytes.standalone route.
  return (
    host === HOST ||
    host === "serverlist-test.l50.leihuo.netease.com" ||
    host === "l50.gdl.netease.com" ||
    host === "l50.gph.netease.com" ||
    host === "l50.gsgph.netease.com" ||
    host === "127.0.0.1" ||
    host === "localhost"
  );
}

const DEFAULT_DEVICE_ID = crypto
  .createHash("md5")
  .update(`Ananta:${LOCAL_ACCOUNT_ID}:${LOCAL_PLAYER_PID}`)
  .digest("hex")
  .toUpperCase();

let lastClientDeviceIdentity = {
  deviceid: DEFAULT_DEVICE_ID,
  udid: DEFAULT_DEVICE_ID,
};

function normalizeDeviceIdentityValue(value) {
  if (value === null || value === undefined) return "";
  const text = String(value).trim();
  if (!text || text === "null" || text === "undefined") return "";
  return text.slice(0, 256);
}

function extractDeviceIdentityFromObject(value, out = {}) {
  if (!value || typeof value !== "object") return out;
  const keys = Object.keys(value);
  for (const key of keys) {
    const lower = key.toLowerCase().replace(/[-_]/g, "");
    const raw = value[key];
    if (lower === "deviceid" || lower === "unisdkdeviceid") {
      const v = normalizeDeviceIdentityValue(raw);
      if (v) out.deviceid = v;
    } else if (lower === "udid") {
      const v = normalizeDeviceIdentityValue(raw);
      if (v) out.udid = v;
    } else if (raw && typeof raw === "object") {
      extractDeviceIdentityFromObject(raw, out);
    }
  }
  return out;
}

function parseMaybeJson(text) {
  if (!text) return null;
  try { return JSON.parse(text); } catch { return null; }
}

function rememberClientDeviceIdentity(req, bodyText = "") {
  const found = {};
  try {
    const url = new URL(req.url || "/", "https://localhost");
    for (const [key, value] of url.searchParams.entries()) {
      extractDeviceIdentityFromObject({ [key]: value }, found);
    }
  } catch {}

  const contentType = String(req.headers["content-type"] || "").toLowerCase();
  const json = parseMaybeJson(bodyText);
  if (json) extractDeviceIdentityFromObject(json, found);

  if (bodyText && (!json || contentType.includes("application/x-www-form-urlencoded"))) {
    try {
      const params = new URLSearchParams(bodyText);
      for (const [key, value] of params.entries()) {
        extractDeviceIdentityFromObject({ [key]: value }, found);
        const nested = parseMaybeJson(value);
        if (nested) extractDeviceIdentityFromObject(nested, found);
      }
    } catch {}
  }

  for (const [key, value] of Object.entries(req.headers || {})) {
    extractDeviceIdentityFromObject({ [key]: Array.isArray(value) ? value[0] : value }, found);
  }

  if (found.deviceid || found.udid) {
    const next = {
      deviceid: found.deviceid || found.udid || lastClientDeviceIdentity.deviceid || DEFAULT_DEVICE_ID,
      udid: found.udid || found.deviceid || lastClientDeviceIdentity.udid || DEFAULT_DEVICE_ID,
    };
    if (next.deviceid !== lastClientDeviceIdentity.deviceid || next.udid !== lastClientDeviceIdentity.udid) {
      log(`unisdk-device captured deviceid=${JSON.stringify(next.deviceid)} udid=${JSON.stringify(next.udid)}`);
    }
    lastClientDeviceIdentity = next;
  }

  return lastClientDeviceIdentity;
}

function deviceIdentityFields() {
  const identity = lastClientDeviceIdentity || {};
  const deviceid = normalizeDeviceIdentityValue(identity.deviceid || identity.udid) || DEFAULT_DEVICE_ID;
  const udid = normalizeDeviceIdentityValue(identity.udid || identity.deviceid) || deviceid;
  const deviceInfo = {
    deviceid,
    device_id: deviceid,
    deviceId: deviceid,
    udid,
    UDID: udid,
    unisdk_device_id: deviceid,
    unisdkDeviceId: deviceid,
    UnisdkDeviceId: deviceid,
  };
  return {
    ...deviceInfo,
    device: { ...deviceInfo },
    device_info: { ...deviceInfo },
    deviceInfo: { ...deviceInfo },
  };
}

function localSauthPayload() {
  const pid = String(LOCAL_PLAYER_PID);
  const device = deviceIdentityFields();
  return {
    ...device,
    code: 200,
    subcode: 0,
    msg: "ok",
    uid: LOCAL_ACCOUNT_ID,
    sdkuid: LOCAL_ACCOUNT_ID,
    user_id: LOCAL_ACCOUNT_ID,
    aid: LOCAL_AID,
    pid: LOCAL_PLAYER_PID,
    player_id: pid,
    playerId: pid,
    role_id: pid,
    roleid: pid,
    roleId: pid,
    role_name: LOCAL_ACCOUNT_ID,
    roleName: LOCAL_ACCOUNT_ID,
    server_id: String(LOCAL_SERVER_ID),
    serverId: String(LOCAL_SERVER_ID),
    host_id: LOCAL_SERVER_ID,
    hostId: LOCAL_SERVER_ID,
    username: LOCAL_USERNAME,
    account: LOCAL_ACCOUNT_ID,
    login_channel: "netease",
    app_channel: "a50_sdk_cn",
    account_channel: "netease",
    pay_channel: "netease",
    platform: "pc",
    token: LOCAL_LOGIN_TOKEN,
    access_token: LOCAL_LOGIN_TOKEN,
    ext_access_token: LOCAL_LOGIN_TOKEN,
    sessionid: LOCAL_LOGIN_TOKEN,
    login_ticket: LOCAL_LOGIN_TOKEN,
    realname_status: 1,
    realname_verify_status: 1,
    mobile_bind_status: 1,
    related_login_status: 0,
  };
}

function localUniSdkLoginJson() {
  const sauth = localSauthPayload();
  const device = deviceIdentityFields();
  return {
    ...device,
    code: 200,
    subcode: 0,
    msg: "ok",
    uid: sauth.uid,
    sdkuid: sauth.sdkuid,
    aid: sauth.aid,
    pid: sauth.pid,
    player_id: sauth.player_id,
    playerId: sauth.playerId,
    role_id: sauth.role_id,
    roleid: sauth.roleid,
    roleId: sauth.roleId,
    role_name: sauth.role_name,
    roleName: sauth.roleName,
    server_id: sauth.server_id,
    serverId: sauth.serverId,
    host_id: sauth.host_id,
    hostId: sauth.hostId,
    username: sauth.username,
    account: sauth.account,
    login_channel: sauth.login_channel,
    account_channel: sauth.account_channel,
    app_channel: sauth.app_channel,
    pay_channel: sauth.pay_channel,
    platform: sauth.platform,
    token: sauth.token,
    access_token: sauth.access_token,
    ext_access_token: sauth.ext_access_token,
    sessionid: sauth.sessionid,
    login_ticket: sauth.login_ticket,
    sauth: JSON.stringify(sauth),
    sauth_json: JSON.stringify(sauth),
    realname_status: sauth.realname_status,
    mobile_bind_status: sauth.mobile_bind_status,
    related_login_status: sauth.related_login_status,
  };
}

function localLoginDataJsonString() {
  const sauth = localSauthPayload();
  const device = deviceIdentityFields();
  const uniSdkLogin = localUniSdkLoginJson();
  return JSON.stringify({
    ...device,
    code: 200,
    subcode: 0,
    msg: "ok",
    uid: sauth.uid,
    sdkuid: sauth.sdkuid,
    user_id: sauth.user_id,
    aid: sauth.aid,
    pid: sauth.pid,
    player_id: sauth.player_id,
    playerId: sauth.playerId,
    role_id: sauth.role_id,
    roleid: sauth.roleid,
    roleId: sauth.roleId,
    role_name: sauth.role_name,
    roleName: sauth.roleName,
    server_id: sauth.server_id,
    serverId: sauth.serverId,
    host_id: sauth.host_id,
    hostId: sauth.hostId,
    username: sauth.username,
    account: sauth.account,
    token: sauth.token,
    access_token: sauth.access_token,
    ext_access_token: sauth.ext_access_token,
    sessionid: sauth.sessionid,
    login_ticket: sauth.login_ticket,
    login_channel: sauth.login_channel,
    account_channel: sauth.account_channel,
    app_channel: sauth.app_channel,
    pay_channel: sauth.pay_channel,
    platform: sauth.platform,
    realname_status: sauth.realname_status,
    realname_verify_status: sauth.realname_verify_status,
    mobile_bind_status: sauth.mobile_bind_status,
    related_login_status: sauth.related_login_status,
    sauth: JSON.stringify(sauth),
    sauth_json: JSON.stringify(sauth),
    SAUTH_JSON: JSON.stringify(sauth),
    SAUTH_STR: JSON.stringify(sauth),
    NT_SAUTH_STR: JSON.stringify(sauth),
    UNISDK_LOGIN_JSON: JSON.stringify(uniSdkLogin),
    unisdk_login_json: JSON.stringify(uniSdkLogin),
  });
}

function localAccountPayload() {
  const sauth = localSauthPayload();
  const device = deviceIdentityFields();
  const uniSdkLogin = localUniSdkLoginJson();
  const sauthJson = JSON.stringify(sauth);
  const uniSdkLoginJson = JSON.stringify(uniSdkLogin);
  const extraUniSdkData = {
    ...device,
    NT_SAUTH_STR: sauthJson,
    SAUTH_STR: sauthJson,
    SAUTH_JSON: sauthJson,
    UNISDK_LOGIN_JSON: uniSdkLoginJson,
    unisdk_login_json: uniSdkLoginJson,
    EXT_ACCESS_TOKEN: sauth.ext_access_token,
    CHANNEL_ACCESS_TOKEN: sauth.access_token,
  };

  return {
    ...device,
    id: LOCAL_ACCOUNT_ID,
    accountId: LOCAL_ACCOUNT_ID,
    account_id: LOCAL_ACCOUNT_ID,
    uid: LOCAL_ACCOUNT_ID,
    user_id: LOCAL_ACCOUNT_ID,
    userid: LOCAL_ACCOUNT_ID,
    sdkuid: LOCAL_ACCOUNT_ID,
    aid: LOCAL_AID,
    pid: LOCAL_PLAYER_PID,
    player_id: String(LOCAL_PLAYER_PID),
    playerId: String(LOCAL_PLAYER_PID),
    role_id: String(LOCAL_PLAYER_PID),
    roleid: String(LOCAL_PLAYER_PID),
    roleId: String(LOCAL_PLAYER_PID),
    role_name: LOCAL_ACCOUNT_ID,
    roleName: LOCAL_ACCOUNT_ID,
    server_id: String(LOCAL_SERVER_ID),
    serverId: String(LOCAL_SERVER_ID),
    host_id: LOCAL_SERVER_ID,
    hostId: LOCAL_SERVER_ID,
    account: LOCAL_ACCOUNT_ID,
    un: LOCAL_ACCOUNT_ID,
    username: LOCAL_USERNAME,
    client_username: LOCAL_USERNAME,
    display_username: LOCAL_ACCOUNT_ID,
    nickname: LOCAL_ACCOUNT_ID,
    idType: "netease",
    icon: "",
    inGame: false,
    rankScore: 0,
    rank: 0,
    remark: "",
    login_channel: "netease",
    account_channel: "netease",
    app_channel: "a50_sdk_cn",
    pay_channel: "netease",
    platform: "pc",
    token: LOCAL_LOGIN_TOKEN,
    access_token: LOCAL_LOGIN_TOKEN,
    ext_access_token: LOCAL_LOGIN_TOKEN,
    login_ticket: LOCAL_LOGIN_TOKEN,
    urs_token: LOCAL_LOGIN_TOKEN,
    urs_login_ticket: LOCAL_LOGIN_TOKEN,
    sessionid: LOCAL_LOGIN_TOKEN,
    sauth: sauthJson,
    sauth_json: sauthJson,
    NT_SAUTH_STR: sauthJson,
    SAUTH_STR: sauthJson,
    SAUTH_JSON: sauthJson,
    UNISDK_LOGIN_JSON: uniSdkLoginJson,
    unisdk_login_json: uniSdkLoginJson,
    extra_unisdk_data: extraUniSdkData,
    pc_ext_info: {
      ...device,
      extra_unisdk_data: extraUniSdkData,
      SAUTH_STR: sauthJson,
      SAUTH_JSON: sauthJson,
    },
    pc_ext_info_json: JSON.stringify({
      ...device,
      extra_unisdk_data: extraUniSdkData,
      SAUTH_STR: sauthJson,
      SAUTH_JSON: sauthJson,
    }),
    realname_status: 1,
    realname_verify_status: 1,
    need_aas: 0,
    need_real_name: 0,
    need_passwd: 0,
    need_email: 0,
    need_sms: 0,
    mobile_bind_status: 1,
    mask_related_mobile: "",
    related_login_status: 0,
    result: 0,
    code: 0,
  };
}

function localUniSauthResponse() {
  const sauth = localSauthPayload();
  const account = localAccountPayload();
  const device = deviceIdentityFields();
  const sauthJson = JSON.stringify(sauth);
  const uniSdkLoginJson = JSON.stringify(localUniSdkLoginJson());
  return {
    ...device,
    code: 200,
    subcode: 0,
    ret: 0,
    result: 0,
    errno: 0,
    status: 0,
    success: true,
    msg: "ok",
    message: "ok",
    uid: sauth.uid,
    sdkuid: sauth.sdkuid,
    user_id: sauth.user_id,
    aid: sauth.aid,
    username: sauth.username,
    account: sauth.account,
    login_channel: sauth.login_channel,
    account_channel: sauth.account_channel,
    app_channel: sauth.app_channel,
    pay_channel: sauth.pay_channel,
    platform: sauth.platform,
    token: sauth.token,
    access_token: sauth.access_token,
    ext_access_token: sauth.ext_access_token,
    sessionid: sauth.sessionid,
    login_ticket: sauth.login_ticket,
    gas_token: sauth.token,
    SAUTH_JSON: sauthJson,
    SAUTH_STR: sauthJson,
    NT_SAUTH_STR: sauthJson,
    UNISDK_LOGIN_JSON: uniSdkLoginJson,
    sauth: sauthJson,
    sauth_json: sauthJson,
    data: sauth,
    user: account,
    account_info: account,
  };
}

function localCheckEnterResponse() {
  const sauth = localSauthPayload();
  const account = localAccountPayload();
  const device = deviceIdentityFields();
  return {
    ...device,
    code: 200,
    subcode: 0,
    ret: 0,
    result: 0,
    errno: 0,
    status: 0,
    success: true,
    msg: "ok",
    message: "ok",
    uid: sauth.uid,
    sdkuid: sauth.sdkuid,
    user_id: sauth.user_id,
    aid: sauth.aid,
    pid: sauth.pid,
    player_id: sauth.player_id,
    playerId: sauth.playerId,
    role_id: sauth.role_id,
    roleid: sauth.roleid,
    roleId: sauth.roleId,
    token: sauth.token,
    access_token: sauth.access_token,
    ext_access_token: sauth.ext_access_token,
    sessionid: sauth.sessionid,
    login_ticket: sauth.login_ticket,
    realname_status: 1,
    realname_verify_status: 1,
    mobile_bind_status: 1,
    need_real_name: 0,
    need_aas: 0,
    can_enter: true,
    allow_enter: true,
    is_can_enter: true,
    data: {
      ...device,
      code: 200,
      subcode: 0,
      msg: "ok",
      enable: true,
      uid: sauth.uid,
      sdkuid: sauth.sdkuid,
      user_id: sauth.user_id,
      aid: sauth.aid,
      pid: sauth.pid,
      player_id: sauth.player_id,
      playerId: sauth.playerId,
      role_id: sauth.role_id,
      roleid: sauth.roleid,
      roleId: sauth.roleId,
      token: sauth.token,
      access_token: sauth.access_token,
      ext_access_token: sauth.ext_access_token,
      sessionid: sauth.sessionid,
      login_ticket: sauth.login_ticket,
      realname_status: 1,
      realname_verify_status: 1,
      mobile_bind_status: 1,
      need_real_name: 0,
      need_aas: 0,
      can_enter: true,
      allow_enter: true,
      is_can_enter: true,
      account,
      user: account,
    },
  };
}

function localGrayReleaseInfoResponse() {
  return {
    code: 200,
    subcode: 0,
    ret: 0,
    result: 0,
    errno: 0,
    status: 0,
    success: true,
    msg: "ok",
    message: "ok",
    enable: false,
    enabled: false,
    data: {
      enable: false,
      enabled: false,
    },
  };
}

function localProtocolResponse() {
  const data = {
    protocol_id: 0,
    protocol_version: 0,
    version: 0,
    need_show: false,
    need_accept: false,
    show: false,
    accept: true,
    accepted: true,
    latest: false,
    force: false,
    list: [],
    templates: [],
    agreements: [],
    content: "",
  };
  return {
    code: 0,
    subcode: 0,
    ret: 0,
    result: 0,
    errno: 0,
    status: 0,
    success: true,
    msg: "ok",
    message: "ok",
    need_show: false,
    need_accept: false,
    show: false,
    accept: true,
    accepted: true,
    protocol_id: 0,
    protocol_version: 0,
    version: 0,
    latest: data,
    data,
  };
}

function mpayOk(data, extra = {}) {
  return {
    code: 0,
    subCode: "OK",
    subcode: 0,
    ret: 0,
    result: 0,
    errno: 0,
    status: 0,
    success: true,
    msg: "ok",
    message: "ok",
    data,
    ...extra,
  };
}

function localMpayLoginUrl(host) {
  const safeHost = (host || "service.mkey.163.com").split(":")[0];
  // Real MPay URLs carry both names. 4229938/MPay webview reads these
  // directly from the login URL, not only from the JSON user object.
  const device = deviceIdentityFields();
  const params = new URLSearchParams({
    game_id: "l50",
    app_type: "games",
    app_channel: "netease",
    udid: device.udid,
    device_id: device.device_id,
    deviceid: device.deviceid,
  });
  return `https://${safeHost}/local-mpay-login?${params.toString()}`;
}

function localMpayEmptyUrl(host) {
  const safeHost = (host || "service.mkey.163.com").split(":")[0];
  return `https://${safeHost}/local-empty`;
}

function localLoginMethodList(host) {
  const loginUrl = localMpayLoginUrl(host);
  return [
    {
      id: "urs_mobile_mail",
      method: "urs_mobile_mail",
      methodId: "urs_mobile_mail",
      type: "urs_mobile_mail",
      name: "netease",
      title: "netease",
      enabled: true,
      enable: true,
      login_url: loginUrl,
      url: loginUrl,
    },
    {
      id: "mobile",
      method: "mobile",
      methodId: "mobile",
      type: "mobile",
      name: "mobile",
      enabled: true,
      enable: true,
      login_url: loginUrl,
      url: loginUrl,
    },
    {
      id: "qrcode",
      method: "qrcode",
      methodId: "qrcode",
      type: "qrcode",
      name: "qrcode",
      enabled: false,
      enable: false,
    },
  ];
}

function localMpayConfig(host) {
  const loginUrl = localMpayLoginUrl(host);
  const emptyUrl = localMpayEmptyUrl(host);
  const methods = localLoginMethodList(host);
  return {
    app_mode: 2,
    pc_mode: 1,
    auto_login: false,
    web_token_persist: false,
    qrcode_enabled: false,
    qrcode_scanners: [],
    qrcode_extern_links: [emptyUrl],
    only_qrcode_pay: false,
    qrcode_select_platform: false,
    enable_2fa: false,
    support_2fa: false,
    support_2FA: false,
    login_url: loginUrl,
    url: loginUrl,
    icon_url: emptyUrl,
    user_icon_url: emptyUrl,
    welcome_icon_url: emptyUrl,
    qrcode_icon_url: emptyUrl,
    url_info: {
      login_url: loginUrl,
      login: loginUrl,
      register: emptyUrl,
      service: emptyUrl,
      privacy: emptyUrl,
      realname: emptyUrl,
    },
    global: {
      login_url: loginUrl,
      url: loginUrl,
      service_url: emptyUrl,
      privacy_url: emptyUrl,
      enable_2fa: false,
      support_2fa: false,
      support_2FA: false,
    },
    login_methods: methods,
    methods,
    list: methods,
    country_codes_hash: "",
    country_codes: [],
    select_platforms: [
      { id: "netease", name: "netease", enabled: true, enable: true },
    ],
    reg_agreement: emptyUrl,
    yd_reg_agreement: emptyUrl,
    privacy_rule: emptyUrl,
    privacy_url: emptyUrl,
    service_rule: emptyUrl,
    service_url: emptyUrl,
    realname_service_url: emptyUrl,
    age_tips_intro_url: emptyUrl,
    age_tips_icon_url: emptyUrl,
    oversea_review_url: emptyUrl,
    scanner_download_guide_link: emptyUrl,
    mobile_related_login: {
      enable: false,
      enabled: false,
    },
    aas: {
      enable: false,
      enabled: false,
    },
  };
}

function localLoginMethodsResponse(host) {
  const loginUrl = localMpayLoginUrl(host);
  const emptyUrl = localMpayEmptyUrl(host);
  const entrance = [
    [
      { type: 1, name: "netease", hot: false, login_url: "", icon_url: "" },
      { type: 7, name: "guest", hot: false, login_url: "", icon_url: "" },
      { type: 14, name: "quick", hot: false, login_url: "", icon_url: "" },
    ],
  ];
  const baseConfig = {
    bind_guest: false,
    binding: false,
    select_platforms: [],
    user_icon_url: "",
    mobile_related_login: false,
    welcome_icon_url: "",
  };

  return {
    entrance,
    expire_time: 3600,
    select_platform: false,
    scheme: 0,
    account_login: true,
    token_login: true,
    qrcode_login: false,
    login_url: loginUrl,
    config: {
      "1": {
        ...baseConfig,
        bind_guest: true,
        register: true,
        login_url: loginUrl,
        url: loginUrl,
        url_info: {
          login_url: loginUrl,
          login: loginUrl,
          register: emptyUrl,
        },
      },
      "3": baseConfig,
      "33": baseConfig,
      "7": {
        bind_guest: true,
        one_click_login_new_ui: false,
        one_click_login: false,
        global: true,
        binding: false,
        country_codes: {
          list: [
            [86, "China Mainland"],
            [1, "United States"],
            [49, "Germany"],
          ],
          hash: "cc2dda9a7f49de91d23166f9d7140252",
        },
        select_platforms: [],
        user_icon_url: "",
        welcome_icon_url: "",
        login_url: loginUrl,
        url: loginUrl,
      },
      "9": baseConfig,
      "10": baseConfig,
      "14": {
        bind_guest: true,
        user_icon_url: "",
        select_platforms: [],
        welcome_icon_url: "",
        login_url: loginUrl,
        url: loginUrl,
        url_info: {
          privacy_agreement: "",
          reg_agreement: "",
          login_url: loginUrl,
          login: loginUrl,
        },
      },
      "17": {
        user_icon_url: "",
        select_platforms: [],
        welcome_icon_url: "",
      },
      "18": {
        bind_guest: false,
        binding: false,
        token_url_pattern: "http://localhost:0/\\?ST=.*",
        select_platforms: [],
        user_icon_url: "",
        oauth_url: emptyUrl,
        welcome_icon_url: "",
      },
      "29": baseConfig,
    },
    list_scheme: 0,
    qrcode_select_platform: false,
  };
}

function localPcConfigResponse(host) {
  const emptyUrl = localMpayEmptyUrl(host);
  return {
    game: {
      config: {
        ios_checkstand: 0,
        channel_pay_method: 0,
        qrcode_pay_allow_all: 0,
        only_qrcode_pay: true,
        allow_update_pay_method: false,
        privacy_default: false,
        encrypt: { switch: false },
        hm_checkstand: 0,
        cv_review_status: 1,
        app_mode: 2,
        pc_pay_channel_mode: 0,
        pay_cashier_type: 0,
        version_id: 83122,
        web_token_persist: false,
        pay_confirm: {
          game_url: "",
          qrcode_enabled: 0,
        },
        guide_animation: false,
        privacy: {
          title: "User Agreement and Privacy Policy",
          default: false,
          url: emptyUrl,
          title2: "User Agreement and Privacy Policy",
          agree_style: 2,
          usercenter_custom: false,
        },
        auto_login: false,
        aas: {
          aas_rollback: 0,
          realname_service_url: emptyUrl,
          oversea_review_enabled: false,
          show_countdown: 0,
          oversea_review_url: emptyUrl,
          oversea_realname_guide: 0,
          show_detail: 0,
          type: 0,
          unrealname_guide: 0,
        },
        mobile_related_login: {
          guide_related_mobile: false,
          force_related_login: false,
          allow_update_rl_status: true,
        },
        login: {
          logout_style: 1,
          logout_ban: false,
          switch_platform_ban: false,
        },
        age_tips_enable: 0,
        limit_device_send_sms_enabled: false,
        reuse_migrate: {
          reuse_mobile: false,
          reuse_guest: false,
          reuse_urs: false,
          guide_page_type: 0,
        },
      },
    },
  };
}

function serveLocalMpayLoginPage(res) {
  const user = localAccountPayload();
  const serializedUser = JSON.stringify(user);
  serveHtml(
    res,
    `<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <title>Local MPay Login</title>
  <style>
    html, body {
      margin: 0;
      width: 100%;
      height: 100%;
      display: grid;
      place-items: center;
      background: #f7f7f7;
      color: #333;
      font-family: system-ui, "Segoe UI", sans-serif;
    }
    main { text-align: center; }
    button {
      border: 0;
      background: #f5a623;
      color: #111;
      padding: 12px 22px;
      font-weight: 700;
      cursor: pointer;
    }
  </style>
</head>
<body>
  <main>
    <h1>Local login</h1>
    <p>Sending local test account to UniSDK...</p>
    <button onclick="sendLogin()">Continue</button>
  </main>
  <script>
    const user = ${serializedUser};
    const payload = {
      methodId: "ngwebview_notify_native",
      reqData: {
        methodId: "onUserLogin",
        device_id: user.device_id,
        deviceid: user.deviceid,
        udid: user.udid,
        user
      }
    };

    function sendLogin() {
      try {
        if (window.NeteaseMpayJSBridge &&
            window.NeteaseMpayJSBridge.Common &&
            typeof window.NeteaseMpayJSBridge.Common.onUserLogin === "function") {
          window.NeteaseMpayJSBridge.Common.onUserLogin(user);
        }
      } catch (error) {}

      try {
        if (window.UniSDKJSBridge && typeof window.UniSDKJSBridge.postMsgToNative === "function") {
          window.UniSDKJSBridge.postMsgToNative(payload);
        }
      } catch (error) {}

      try {
        if (typeof window.mwsInvoke === "function") {
          window.mwsInvoke({
            request: "unisdk_js_native_call:" + JSON.stringify(payload),
            onSuccess: function () {},
            onFailure: function () {}
          });
        }
      } catch (error) {}
    }

    window.addEventListener("NeteaseMpayJSBridgeReady", sendLogin);
    setTimeout(sendLogin, 200);
    setTimeout(sendLogin, 1000);
  </script>
</body>
</html>`,
  );
}

function serveHttpDns(res) {
  const hosts = [
    "service.mkey.163.com",
    "qatest.g.mkey.163.com",
    "qatest-1.g.mkey.163.com",
    "qatest-2.g.mkey.163.com",
    "qatest-3.g.mkey.163.com",
    "qatest-4.g.mkey.163.com",
    "qatest-5.g.mkey.163.com",
    "qatest-6.g.mkey.163.com",
    "qatest-7.g.mkey.163.com",
    "qatest-8.g.mkey.163.com",
    "mpay-common-server.g.mkey.163.com",
    "bind-mobile.g.mkey.163.com",
    "mgbsdk.matrix.netease.com",
    "openapi.music.163.com",
  ];
  const records = hosts.map((host) => ({
    host,
    domain: host,
    ip: "127.0.0.1",
    ips: ["127.0.0.1"],
    ttl: 3600,
  }));

  serveJson(res, {
    code: 0,
    result: 0,
    ret: 0,
    dns: records,
    data: records,
    servers: records,
    mapping: Object.fromEntries(hosts.map((host) => [host, ["127.0.0.1"]])),
  });
}

function serveLocalMusicApi(res, pathname) {
  const token = {
    accessToken: "codex-local-music-token",
    refreshToken: "codex-local-music-refresh",
    // The 4229938 client model declares expireTime as Int32. A year-2100
    // timestamp overflows Newtonsoft.Json's ReadAsInt32 and aborts this API.
    expireTime: 2147483647,
  };

  const ok = (data) => ({
    code: 200,
    subCode: "OK",
    message: "ok",
    data,
  });

  if (pathname.includes("/oauth2/login/anonymous")) {
    serveJson(res, ok(token));
    return;
  }

  if (pathname.includes("/oauth2/device/login/qrcode/get")) {
    serveJson(res, ok({ accessToken: token, status: 803, msg: "ok" }));
    return;
  }

  if (pathname.includes("/oauth2/qrcodekey/get")) {
    serveJson(res, ok({ qrCodeUrl: "https://openapi.music.163.com/local-empty", uniKey: "codex-local" }));
    return;
  }

  if (pathname.includes("/song/playurl/get")) {
    serveJson(res, ok([]));
    return;
  }

  if (
    pathname.includes("/playlist/song/list/get") ||
    pathname.includes("/playlist/star/get") ||
    pathname.includes("/recommend/songlist/get")
  ) {
    serveJson(res, ok([]));
    return;
  }

  if (pathname.includes("/play/data/record") || pathname.includes("/resource/encrypt")) {
    serveJson(res, ok({}));
    return;
  }

  serveJson(res, ok({}));
}

function serveLocalQrcodeApi(res, pathname) {
  const account = localAccountPayload();
  const qrcode = {
    uuid: "codex-local-qrcode",
    data_id: "codex-local-qrcode",
    qrcode_uid: "codex-local-qrcode",
    qrcode_status: 2,
    status: 2,
    query_interval: 1,
    qrcode_url: "https://service.mkey.163.com/local-empty",
    qrcode_img_url: "https://service.mkey.163.com/local-empty",
    token: account.token,
    access_token: account.access_token,
    login_ticket: account.login_ticket,
    user: account,
    account,
  };

  if (pathname.includes("/api/qrcode/image")) {
    const png = Buffer.from(
      "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAFgwJ/l6KxWQAAAABJRU5ErkJggg==",
      "base64",
    );
    res.writeHead(200, {
      "content-type": "image/png",
      "content-length": png.length,
      "cache-control": "no-store",
      "connection": "close",
    });
    res.end(png);
    return;
  }

  serveJson(res, mpayOk(qrcode, qrcode));
}

async function captureUniSdkRequest(req, res) {
  const host = req.headers.host || "unknown-host";

  // Crash-dump capture: the client's CrashHunter POSTs the full native crash
  // bundle (multipart with mymaindump_*.native.dmp + crashHunterParam_*.txt)
  // to l50.appdump.nie.netease.com/upload. We save the RAW bytes to disk so we
  // can extract the real crash reason instead of letting it get truncated in
  // the text log. This is read-only diagnostics of our own client run.
  const hostnameEarly = host.split(":")[0].toLowerCase();
  const pathnameEarly = req.url.split("?")[0].toLowerCase();
  if (req.method === "POST" && (hostnameEarly.includes("appdump") || pathnameEarly.includes("/upload"))) {
    const chunks = [];
    let total = 0;
    await new Promise((resolve) => {
      req.on("data", (c) => { chunks.push(c); total += c.length; });
      req.on("end", resolve);
      req.on("error", resolve);
    });
    try {
      const crashDir = path.join(ROOT, "crash_uploads");
      fs.mkdirSync(crashDir, { recursive: true });
      const stamp = new Date().toISOString().replace(/[:.]/g, "-");
      const kind = total > 4096 ? "crash" : "appdump";
      const outPath = path.join(crashDir, `${kind}_${stamp}_${total}.bin`);
      fs.writeFileSync(outPath, Buffer.concat(chunks));
      log(`${kind}-upload-saved ${host}${req.url} bytes=${total} small=${total <= 4096} -> ${outPath}`);
    } catch (e) {
      log(`appdump-upload-save-error ${e.message}`);
    }
    serveJson(res, { code: 0, result: 0, msg: "ok" });
    return;
  }

  const body = await collectRequestBody(req);
  rememberClientDeviceIdentity(req, body.text);
  log(`unisdk-capture ${req.method} https://${host}${req.url} bodyBytes=${body.size} body=${JSON.stringify(body.text)}`);

  const pathname = req.url.split("?")[0].toLowerCase();
  const hostname = host.split(":")[0].toLowerCase();
  if (hostname === "openapi.music.163.com" || pathname.includes("/openapi/music/")) {
    log(`local-music ${req.method} https://${host}${req.url}`);
    serveLocalMusicApi(res, pathname);
    return;
  }

  if (pathname === "/local-mpay-login") {
    log(`local-mpay-login ${req.method} https://${host}${req.url}`);
    serveLocalMpayLoginPage(res);
    return;
  }

  if (pathname === "/local-empty") {
    log(`local-empty-unisdk ${req.method} https://${host}${req.url}`);
    const accept = (req.headers.accept || "").toLowerCase();
    if (accept.includes("text/html")) {
      serveHtml(res, "<!doctype html><meta charset=\"utf-8\"><title>ok</title>");
    } else {
      const device = deviceIdentityFields();
      serveJson(res, { code: 0, ret: 0, result: 0, errno: 0, msg: "ok", ...device, data: device });
    }
    return;
  }

  if (pathname.includes("hdserver")) {
    serveHttpDns(res);
    return;
  }

  // The production SDK build talks to mgbsdk.matrix.netease.com (the older test
  // build used mgbsdktest.matrix.netease.com); both must hit the local mock,
  // otherwise uni_sauth goes to the real server and fails with 401 -> login 220.
  const isMgbsdkHost =
    hostname === "mgbsdktest.matrix.netease.com" || hostname === "mgbsdk.matrix.netease.com";

  if (isMgbsdkHost && pathname.includes("/sdk/check_enter")) {
    log(`local-check-enter ${req.method} https://${host}${req.url}`);
    serveJson(res, localCheckEnterResponse());
    return;
  }

  if (isMgbsdkHost && pathname.includes("/sdk/get_gray_release_info")) {
    log(`local-gray-release ${req.method} https://${host}${req.url}`);
    serveJson(res, localGrayReleaseInfoResponse());
    return;
  }

  if (pathname.endsWith("/sdk/uni_sauth") || pathname.includes("/sdk/uni_sauth")) {
    log(`local-uni-sauth ${req.method} https://${host}${req.url}`);
    serveJson(res, localUniSauthResponse());
    return;
  }

  if (isMgbsdkHost) {
    log(`local-mgbsdk-generic ${req.method} https://${host}${req.url}`);
    const device = deviceIdentityFields();
    serveJson(res, {
      ...device,
      code: 200,
      subcode: 0,
      ret: 0,
      result: 0,
      errno: 0,
      status: 0,
      success: true,
      msg: "ok",
      message: "ok",
      data: device,
    });
    return;
  }

  if (
    pathname.includes("clientlog") ||
    pathname.includes("open_log") ||
    pathname.includes("ff_log") ||
    pathname.includes("feature2") ||
    pathname.includes("/class/upload")
  ) {
    serveJson(res, { code: 0, result: 0, msg: "ok" });
    return;
  }

  if (pathname.includes("/api/template/") || pathname.includes("/tpsl/")) {
    serveJson(res, {
      code: 0,
      result: 0,
      data: {},
      msg: "ok",
    });
    return;
  }

  if (pathname.includes("/api/qrcode/")) {
    serveLocalQrcodeApi(res, pathname);
    return;
  }

  if (pathname.endsWith("/mpay/config/common.json") || pathname.endsWith("/config/common.json")) {
    const config = localMpayConfig(host);
    serveJson(res, mpayOk(config, config));
    return;
  }

  if (pathname.endsWith("/mpay/games/pc_config") || pathname.endsWith("/games/pc_config")) {
    serveJson(res, localPcConfigResponse(host));
    return;
  }

  if (pathname.endsWith("/login_methods")) {
    serveJson(res, localLoginMethodsResponse(host));
    return;
  }

  if (pathname.includes("/login/mobile/guide")) {
    const account = localAccountPayload();
    serveJson(
      res,
      mpayOk(
        {
          need_guide: false,
          guide: false,
          show_guide: false,
          guide_related_mobile: false,
          force_related_login: false,
          mobile_related_login: {
            enable: false,
            enabled: false,
            guide_related_mobile: false,
            force_related_login: false,
          },
          account,
          user: account,
        },
        {
          need_guide: false,
          guide: false,
          show_guide: false,
          account,
          user: account,
        },
      ),
    );
    return;
  }

  if (
    pathname.includes("/api/config") ||
    pathname.includes("/api/devices/upload") ||
    pathname.includes("/api/users/create_ticket") ||
    pathname.includes("/api/users/check_token") ||
    pathname.includes("/api/users/login/ticket") ||
    pathname.includes("/api/users/login/battle_net/auth") ||
    pathname.includes("/api/users/get_urs_login_ticket_by_token") ||
    pathname.includes("/api/users/login/qrcode/exchange_token") ||
    pathname.includes("/api/users/login/pc/oauth") ||
    pathname.includes("/api/users/realname/update_by_token")
  ) {
    const account = localAccountPayload();
    serveJson(res, mpayOk(account, { user: account, account, session: account }));
    return;
  }

  const account = localAccountPayload();
  const device = deviceIdentityFields();
  serveJson(res, {
    ...device,
    code: 0,
    ret: 0,
    result: 0,
    errno: 0,
    msg: "ok",
    message: "ok",
    data: account,
    user: account,
    account,
    session: account,
  });
}

async function proxyRequest(req, res) {
  const requestedHost = (req.headers.host || HOST).split(":")[0].toLowerCase();
  const upstreamHost = requestedHost === "127.0.0.1" || requestedHost === "localhost"
    ? HOST
    : requestedHost;
  const upstreamIp = await resolveUpstream(upstreamHost);
  const headers = { ...req.headers, host: upstreamHost };

  const upstreamReq = https.request(
    {
      host: upstreamIp,
      servername: upstreamHost,
      port: 443,
      method: req.method,
      path: req.url,
      headers,
    },
    (upstreamRes) => {
      res.writeHead(upstreamRes.statusCode || 502, upstreamRes.headers);
      upstreamRes.pipe(res);
    },
  );

  upstreamReq.on("error", (error) => {
    log(`proxy error ${req.method} ${req.url}: ${error.message}`);
    if (!res.headersSent) {
      res.writeHead(502, { "content-type": "text/plain; charset=utf-8" });
    }
    res.end(`proxy error: ${error.message}`);
  });

  req.pipe(upstreamReq);
}

const server = https.createServer(
  {
    pfx: fs.readFileSync(PFX_PATH),
    passphrase: PFX_PASSPHRASE,
  },
  async (req, res) => {
    try {
      // Some 4229938 environment URLs are assembled with a trailing slash and
      // arrive as //OuterTest1/.... Normalize them before local route matching.
      const pathname = (`/${req.url.split("?")[0]}`).replace(/\/{2,}/g, "/");

      if (req.method === "GET" && pathname.endsWith("/serverlist.txt")) {
        log(`local-serverlist ${req.method} ${req.url}`);
        serveLocalServerList(res);
        return;
      }

      if (req.method === "GET" && pathname.endsWith("/serverlist_review.txt")) {
        log(`local-serverlist-review ${req.method} ${req.url}`);
        serveLocalServerList(res);
        return;
      }

      if (req.method === "GET" && pathname === "/audit.txt") {
        log(`local-audit ${req.method} ${req.url}`);
        serveLocalAudit(res);
        return;
      }

      if (req.method === "GET" && pathname === "/game_notice/Login.bin") {
        log(`local-notice ${req.method} ${req.url}`);
        serveLocalGameNotice(res);
        return;
      }

      if (pathname === "/local-mpay-login" || pathname === "/local-empty") {
        await captureUniSdkRequest(req, res);
        return;
      }

      if (!isUpdateHost(req)) {
        await captureUniSdkRequest(req, res);
        return;
      }

      if (req.method === "GET" && pathname.endsWith("/ConstConfig.cfg")) {
        log(`local-outertest-config ${req.method} ${req.url}`);
        serveOuterTestConfig(res);
        return;
      }

      if (req.method === "GET" && pathname.endsWith("/pc_boot.config")) {
        log(`local-pc-boot-config ${req.method} ${req.url}`);
        const body = Buffer.from("enable-cs-warmup=0\nenable-ecs-shader-warmup=0\n");
        res.writeHead(200, {
          "content-type": "text/plain; charset=utf-8",
          "content-length": body.length,
          "cache-control": "no-store",
        });
        res.end(body);
        return;
      }

      if (req.method === "GET" && pathname.endsWith("/pc_netease_version.json")) {
        log(`local ${req.method} ${req.url}`);
        serveLocalVersion(res);
        return;
      }

      if (req.method === "GET" && pathname.endsWith("/device_check_pc.json")) {
        log(`local-device-check ${req.method} ${req.url}`);
        serveLocalDeviceCheck(res);
        return;
      }

      if (req.method === "GET" && pathname.endsWith("/trunk-client_startup_patch_info.txt")) {
        log(`local-startup-patch-info ${req.method} ${req.url}`);
        serveStartupPatchInfo(res);
        return;
      }

      // Any fastpatch zip request for the configured client version. The URL
      // pattern is /fastpatch/trunk/<clientVersion>/fastpatch.zip; matching
      // the tail keeps this working across client version bumps.
      if (req.method === "GET" && pathname.startsWith("/fastpatch/") && pathname.endsWith("/fastpatch.zip")) {
        log(`local-fastpatch ${req.method} ${req.url}`);
        serveFastPatchClient(res);
        return;
      }

      const patchInfoMatch = (req.method === "GET" || req.method === "HEAD") && pathname.match(/^\/pc\/([^/]+)\/Patch\.info$/);
      if (patchInfoMatch) {
        log(`local-resource-patch-info ${req.method} ${req.url}`);
        serveResourcePatchInfo(res, patchInfoMatch[1], req.method === "HEAD");
        return;
      }

      if ((req.method === "GET" || req.method === "HEAD") && pathname.includes("vfs_res_version")) {
        log(`local-vfs-res-version ${req.method} ${req.url}`);
        const vfsPath = path.join(ROOT, "public", "vfs_res_version");
        if (fs.existsSync(vfsPath)) {
          const data = fs.readFileSync(vfsPath);
          res.writeHead(200, {
            "content-type": "application/octet-stream",
            "content-length": data.length,
            "cache-control": "no-store",
          });
          if (req.method === "HEAD") { res.end(); return; }
          res.end(data);
          return;
        }
      }

      if ((req.method === "GET" || req.method === "HEAD") && pathname.includes("download_header.ehd")) {
        log(`local-download-header ${req.method} ${req.url}`);
        const ehdPath = path.join(ROOT, "public", "Blocks", "download_header.ehd");
        if (fs.existsSync(ehdPath)) {
          const data = fs.readFileSync(ehdPath);
          res.writeHead(200, {
            "content-type": "application/octet-stream",
            "content-length": data.length,
            "cache-control": "no-store",
          });
          if (req.method === "HEAD") { res.end(); return; }
          res.end(data);
          return;
        }
      }

      // IFix stage0 .bytes.standalone (loaded after the manifest above).
      // The manifest references the path
      //   2724864/2724864-20260116021030-Assembly-CSharp.stage0.patch.bytes.standalone
      // We accept any URL ending in stage0.patch.bytes.standalone so that
      // a future patch-id rotation still works without code changes.
      if (req.method === "GET" && pathname.endsWith(".stage0.patch.bytes.standalone")) {
        log(`local-stage0-patch ${req.method} ${req.url}`);
        serveStage0Patch(res);
        return;
      }

      // The same manifest also points at a wrapper ZIP:
      //   2724864/2724864-20260116021030-client_startup_patch.zip
      // We don't have the original (8638-byte standalone is all the contact
      // shared), so we rebuild a ZIP locally that contains only the
      // .standalone entry. If the client validates the MD5 against the
      // manifest hash (9dd906c1...), this will fail and we'll see that in
      // the next log; otherwise the client extracts the standalone from
      // here and feeds it to IFix the same way as the direct fetch.
      if (req.method === "GET" && pathname.endsWith("client_startup_patch.zip")) {
        log(`local-startup-patch-zip ${req.method} ${req.url}`);
        if (!serveBinaryFile(res, "client_startup_patch.zip", "application/zip")) {
          res.writeHead(404, { "content-type": "text/plain", "connection": "close" });
          res.end("startup patch zip not present");
        }
        return;
      }

      if (req.method === "GET" && req.url === "/__health") {
        res.writeHead(200, { "content-type": "text/plain; charset=utf-8" });
        res.end("ok");
        return;
      }

      log(`proxy ${req.method} ${req.url}`);
      await proxyRequest(req, res);
    } catch (error) {
      log(`fatal request error ${req.method} ${req.url}: ${error.stack || error.message}`);
      if (!res.headersSent) {
        res.writeHead(500, { "content-type": "text/plain; charset=utf-8" });
      }
      res.end(`local proxy error: ${error.message}`);
    }
  },
);

server.on("tlsClientError", (error, socket) => {
  log(
    `tls-client-error ${socket.remoteAddress}:${socket.remotePort} ` +
      `sni=${JSON.stringify(socket.servername || "")}: ${error.message}`,
  );
});

server.listen(PORT, "0.0.0.0", () => {
  log(`listening on https://0.0.0.0:${PORT} for ${HOST} and UniSDK capture hosts`);
});

const httpCaptureServer = http.createServer(async (req, res) => {
  await captureUniSdkRequest(req, res);
});

httpCaptureServer.listen(HTTP_CAPTURE_PORT, "0.0.0.0", () => {
  log(`listening on http://0.0.0.0:${HTTP_CAPTURE_PORT} for UniSDK capture hosts`);
});

const loginListServer = http.createServer((req, res) => {
  if (req.method === "GET" && req.url.split("?")[0] === "/LoginList") {
    const candidates = loginListCandidates();
    const candidate = candidates[0];
    loginListRequestCount += 1;
    const body = candidate.body;

    log(`local-loginlist ${req.method} ${req.url} #${loginListRequestCount} ${candidate.name} -> ${JSON.stringify(body)}`);
    serveText(res, body);
    return;
  }

  log(`local-loginlist-404 ${req.method} ${req.url}`);
  res.writeHead(404, { "content-type": "text/plain; charset=utf-8" });
  res.end("not found");
});

loginListServer.listen(LOGIN_LIST_PORT, LOCAL_LOGIN_HOST, () => {
  log(`listening on http://${LOCAL_LOGIN_HOST}:${LOGIN_LIST_PORT}/LoginList`);
});

const loginTcpServer = net.createServer((socket) => {
  const remote = `${socket.remoteAddress}:${socket.remotePort}`;
  let pending = Buffer.alloc(0);
  let handshaked = false;
  log(`login-tcp connect ${remote}`);

  function uxFrame(mode, payload) {
    const body = Buffer.isBuffer(payload) ? payload : Buffer.from(payload || []);
    const frame = Buffer.alloc(5 + body.length);
    frame.writeInt32LE(body.length, 0);
    frame.writeUInt8(mode, 4);
    body.copy(frame, 5);
    return frame;
  }

  function sendS2CHandshake(clientPayload) {
    const clientMagic = clientPayload.readInt32LE(0);
    const aesKey = clientPayload.subarray(4, 20);
    const nonce = crypto.randomBytes(12);
    const chaChaHead = crypto.randomBytes(76);
    const aes = crypto.createCipheriv("aes-128-gcm", aesKey, nonce);
    const encryptedHead = Buffer.concat([aes.update(chaChaHead), aes.final(), aes.getAuthTag()]);
    const payload = Buffer.alloc(368);
    payload.writeInt32LE(1, 0); // SessionId
    payload.writeInt32LE(10, 4); // HeartbeatInterval
    nonce.copy(payload, 8);
    encryptedHead.copy(payload, 20);
    // bytes 112..367 are the fixed RSA-2048 signature field. The matching
    // private-client patch accepts the local unsigned handshake.

    const frame = uxFrame(1, payload);
    socket.write(frame);
    handshaked = true;
    log(
      `login-tcp send-handshake ${remote} clientMagic=${clientMagic} ` +
        `${frame.length} bytes ${frame.toString("hex")}`,
    );
  }

  function sendRpcReturn(methodId, invokeId, err = 0, resultPayload = Buffer.alloc(0)) {
    const body = Buffer.alloc(13 + resultPayload.length);
    body.writeUInt8(RPC_PACKET_RETURN, 0);
    body.writeInt32LE(methodId, 1);
    body.writeInt32LE(invokeId, 5);
    body.writeUInt32LE(err >>> 0, 9);
    resultPayload.copy(body, 13);

    const frame = uxFrame(9, body);
    socket.write(frame);
    log(
      `login-tcp send-rpc-return ${remote} method=${methodId} name=${rpcMethodName(methodId)} invoke=${invokeId} ` +
        `err=${err} ${frame.length} bytes ${frame.toString("hex")}`,
    );
  }

  function uxI32(value) {
    const buffer = Buffer.alloc(4);
    buffer.writeInt32LE(value, 0);
    return buffer;
  }

  function uxU32(value) {
    const buffer = Buffer.alloc(4);
    buffer.writeUInt32LE(value >>> 0, 0);
    return buffer;
  }

  function uxU64(value) {
    const buffer = Buffer.alloc(8);
    buffer.writeBigUInt64LE(BigInt(value), 0);
    return buffer;
  }

  function uxBool(value) {
    return Buffer.from([value ? 1 : 0]);
  }

  function ux7BitEncodedInt(value) {
    const bytes = [];
    let remaining = value >>> 0;
    while (remaining >= 0x80) {
      bytes.push((remaining & 0x7f) | 0x80);
      remaining >>>= 7;
    }
    bytes.push(remaining);
    return Buffer.from(bytes);
  }

  function uxString(value) {
    if (value === null || value === undefined) {
      return Buffer.from([0]);
    }

    const text = Buffer.from(String(value), "utf8");
    return Buffer.concat([ux7BitEncodedInt(text.length + 1), text]);
  }

  function uxBuffer(value) {
    if (value === null || value === undefined) {
      return Buffer.from([0]);
    }

    const buffer = Buffer.isBuffer(value) ? value : Buffer.from(value);
    return Buffer.concat([Buffer.from([1]), uxI32(buffer.length), buffer]);
  }

  function uxList(values, writeItem) {
    if (values === null || values === undefined) {
      // SerializeObjectMark.IsNull (0) = null list
      return Buffer.from([0x00]);
    }

    // SerializeObjectMark.Common (255) = non-null list, then int32 count + items
    const items = Array.from(values, writeItem);
    return Buffer.concat([Buffer.from([0xff]), uxI32(items.length), ...items]);
  }

  function uxListString(values) {
    return uxList(values, uxString);
  }

  function uxListBytes(values) {
    return uxList(values, (value) => Buffer.from([Number(value) & 0xff]));
  }

  function uxList7Bit(values, writeItem) {
    if (values === null || values === undefined) return Buffer.from([0x00]);
    const items = Array.from(values, writeItem);
    // ux7BitEncodedInt is the raw varint helper; UX logical count N is wire N+1.
    return Buffer.concat([Buffer.from([0xff]), ux7BitEncodedInt(items.length + 1), ...items]);
  }

  function uxListString7Bit(values) {
    return uxList7Bit(values, uxString);
  }

  function uxListBytes7Bit(values) {
    return uxList7Bit(values, (value) => Buffer.from([Number(value) & 0xff]));
  }

  function tryRead7BitEncodedInt(payload, offset) {
    let result = 0;
    let shift = 0;

    for (let i = 0; i < 5; i += 1) {
      if (offset + i >= payload.length) {
        return null;
      }

      const byte = payload.readUInt8(offset + i);
      result |= (byte & 0x7f) << shift;
      if ((byte & 0x80) === 0) {
        return { value: result, next: offset + i + 1 };
      }
      shift += 7;
    }

    return null;
  }

  function tryReadUxString(payload, offset) {
    const encodedLen = tryRead7BitEncodedInt(payload, offset);
    if (!encodedLen) {
      return null;
    }

    if (encodedLen.value === 0) {
      return {
        value: null,
        next: encodedLen.next,
      };
    }

    const stringLen = encodedLen.value - 1;
    const start = encodedLen.next;
    const end = start + stringLen;
    if (end > payload.length) {
      return null;
    }

    return {
      value: payload.subarray(start, end).toString("utf8"),
      next: end,
    };
  }

  function checkAccountResultPayload() {
    // NeedRoleEnter=false tells the client a character already exists.
    // Combined with SyncRoleList(pid=100001) sent after TryLogin +
    // CanRequestEnterGame=always-true patch, the client goes directly
    // to RequestEnterGame without showing the Create Character panel.
    return Buffer.concat([
      uxBool(true), // non-null CheckAccountResult object
      uxString(localLoginDataJsonString()),
      uxString(LOCAL_LOGIN_TOKEN),
      uxString(LOCAL_USERNAME),
      uxI32(LOCAL_AID),
      uxBool(false), // NeedRealNameTip
      uxBool(false), // NeedRoleEnter: false = role exists, skip creation.
      uxBool(true), // RealNameVerified
      uxI32(LOCAL_SERVER_ID),
      uxString(""),
      uxI32(200),
      uxI32(0),
      uxString("ok"),
    ]);
  }

  function parseCreateRoleArgs(args) {
    for (let offset = 0; offset < Math.min(args.length, 12); offset += 1) {
      const parsed = tryReadUxString(args, offset);
      if (
        parsed &&
        parsed.value &&
        parsed.value.length > 0 &&
        parsed.value.length <= 64 &&
        /^[\x20-\x7e]+$/.test(parsed.value)
      ) {
        return { name: parsed.value, nameOffset: offset };
      }
    }

    return { raw: args.toString("hex") };
  }

  function enterGameDataPayload() {
    // EnterGameData wire format (RPCSerializeAuto.lua line 2163):
    //   Aid:Int32, Pid:UInt64, Token:Complex(TokenInfo)
    // TokenInfo.Write (line 5199): Aid:Int32, Pid:UInt64, Ip:String, Port:Int32,
    //   Token:String, RC4Key:String, GateServerId:Int32, AccountId:String
    // Complex marker: 0xff (SerializeObjectMarkCommon, NOT 0x01).
    const pid = BigInt(LOCAL_PLAYER_PID);
    const tokenInfo = Buffer.concat([
      Buffer.from([0xff]), // non-null TokenInfo marker (SerializeObjectMarkCommon)
      uxI32(LOCAL_AID),                   // Aid
      uxU64(pid),                         // Pid
      uxString(LOCAL_LOGIN_HOST),         // Ip = 127.0.0.1
      uxI32(LOCAL_LOGIN_TCP_PORT),        // Port = 5803 (gate)
      uxString(LOCAL_PLAYER_TOKEN),          // Token
      uxString(""),                       // RC4Key
      uxI32(LOCAL_SERVER_ID),                         // GateServerId
      uxString(LOCAL_ACCOUNT_ID),          // AccountId
    ]);

    return Buffer.concat([
      uxI32(LOCAL_AID),
      uxU64(pid),
      tokenInfo,
    ]);
  }

  function hotfixPatchCheckPayload() {
    return Buffer.concat([
      uxI32(0), // remain
      // The callback metadata marks md5Infos as a non-null List<string>.
      // Send an empty list to mean "no hotfix patches", not a null list.
      uxListString7Bit([]),
    ]);
  }

  function newHotfixPatchDataPayload() {
    return Buffer.concat([
      uxI32(-1), // Version: no hotfix patch available.
      uxListBytes7Bit([]), // Content
      uxString(""), // Md5
    ]);
  }

  function patchEntryListPayload() {
    return uxList7Bit([], (entry) =>
      Buffer.concat([
        Buffer.from([0xff]),
        uxI32(entry.Version || 0),
        uxListBytes7Bit(entry.Content || []),
        uxString(entry.Md5 || ""),
      ]),
    );
  }

  function parseTryLoginArgs(args) {
    let offset = 0;
    if (offset + 4 > args.length) {
      return null;
    }

    const aid = args.readInt32LE(offset);
    offset += 4;
    const token = tryReadUxString(args, offset);
    if (!token) {
      return null;
    }
    offset = token.next;

    if (offset + 2 > args.length) {
      return { aid, token: token.value, truncated: true };
    }

    const updateAasInfo = !!args.readUInt8(offset);
    offset += 1;
    const kick = !!args.readUInt8(offset);
    offset += 1;
    const deviceId = tryReadUxString(args, offset);
    if (!deviceId) {
      return { aid, token: token.value, updateAasInfo, kick, truncated: true };
    }
    offset = deviceId.next;

    if (offset + 2 > args.length) {
      return { aid, token: token.value, updateAasInfo, kick, deviceId: deviceId.value, truncated: true };
    }

    const strictOnlineMode = !!args.readUInt8(offset);
    offset += 1;
    const confirmBindDevice = !!args.readUInt8(offset);

    return {
      aid,
      token: token.value,
      updateAasInfo,
      kick,
      deviceId: deviceId.value,
      strictOnlineMode,
      confirmBindDevice,
    };
  }

  function tryReadU64(payload, offset) {
    if (offset + 8 > payload.length) {
      return null;
    }

    return {
      value: payload.readBigUInt64LE(offset).toString(),
      next: offset + 8,
    };
  }

  function tryReadBool(payload, offset) {
    if (offset + 1 > payload.length) {
      return null;
    }

    return {
      value: !!payload.readUInt8(offset),
      next: offset + 1,
    };
  }

  function tryReadDouble(payload, offset) {
    if (offset + 8 > payload.length) {
      return null;
    }

    return {
      value: payload.readDoubleLE(offset),
      next: offset + 8,
    };
  }

  function parseSingleStringArg(args) {
    const value = tryReadUxString(args, 0);
    if (!value) {
      return null;
    }

    return {
      value: value.value,
      trailingBytes: args.length - value.next,
    };
  }

  function parsePidTokenArgs(args) {
    const pid = tryReadU64(args, 0);
    if (!pid) {
      return null;
    }

    const token = tryReadUxString(args, pid.next);
    if (!token) {
      return { pid: pid.value, truncated: true };
    }

    return {
      pid: pid.value,
      token: token.value,
      trailingBytes: args.length - token.next,
    };
  }

  function parseGateLoginArgs(args) {
    const parsed = parsePidTokenArgs(args);
    if (!parsed || parsed.truncated) {
      return parsed;
    }

    let offset = args.length - parsed.trailingBytes;
    const isReconnect = tryReadBool(args, offset);
    if (!isReconnect) {
      return { ...parsed, truncated: true };
    }
    offset = isReconnect.next;

    const deviceInfo = tryReadUxString(args, offset);
    if (!deviceInfo) {
      return {
        ...parsed,
        isReconnect: isReconnect.value,
        remainingHex: args.subarray(offset).toString("hex"),
      };
    }
    offset = deviceInfo.next;

    const debug = tryReadBool(args, offset);
    if (!debug) {
      return {
        ...parsed,
        isReconnect: isReconnect.value,
        deviceInfo: deviceInfo.value,
        remainingHex: args.subarray(offset).toString("hex"),
      };
    }

    return {
      ...parsed,
      isReconnect: isReconnect.value,
      deviceInfo: deviceInfo.value,
      debug: debug.value,
      trailingBytes: args.length - debug.next,
    };
  }

  function parseClientUnixTimeArgs(args) {
    const clientUnixTime = tryReadDouble(args, 0);
    if (!clientUnixTime) {
      return null;
    }

    return {
      clientUnixTime: clientUnixTime.value,
      trailingBytes: args.length - clientUnixTime.next,
    };
  }

  function handleRpcNotify(methodId, args) {
    if (methodId === RPC_METHODS.Gate_GetServerTime || methodId === RPC_METHODS.Game_GetServerTime) {
      log(
        `login-tcp rpc-notify ${remote} method=${methodId} name=${rpcMethodName(methodId)} ` +
          `${JSON.stringify(parseClientUnixTimeArgs(args))}`,
      );
      return true;
    }

    if (methodId === RPC_METHODS.Game_LoginGame) {
      log(
        `login-tcp rpc-notify ${remote} method=${methodId} name=${rpcMethodName(methodId)} ` +
          `${JSON.stringify(parsePidTokenArgs(args))}`,
      );
      return true;
    }

    if (methodId === RPC_METHODS.Game_RequestGameSceneData) {
      log(`login-tcp rpc-notify ${remote} method=${methodId} name=${rpcMethodName(methodId)}`);
      return true;
    }

    log(`login-tcp rpc-notify-unhandled ${remote} method=${methodId} name=${rpcMethodName(methodId)} args=${args.toString("hex")}`);
    return false;
  }

  function handleRawRpc(payload) {
    if (payload.length < 5) {
      log(`login-tcp rpc-short ${remote} payload=${payload.toString("hex")}`);
      return false;
    }

    const rpcMode = payload.readUInt8(0);
    const methodId = payload.readInt32LE(1);

    if (rpcMode === RPC_PACKET_NOTIFY) {
      return handleRpcNotify(methodId, payload.subarray(5));
    }

    if (payload.length < 9) {
      log(
        `login-tcp rpc-short ${remote} rpcMode=${rpcMode} method=${methodId} ` +
          `name=${rpcMethodName(methodId)} payload=${payload.toString("hex")}`,
      );
      return false;
    }

    const invokeId = payload.readInt32LE(5);
    const args = payload.subarray(9);

    log(
      `login-tcp rpc ${remote} rpcMode=${rpcMode} method=${methodId} name=${rpcMethodName(methodId)} ` +
        `invoke=${invokeId} args=${args.toString("hex")}`,
    );

    if (rpcMode !== RPC_PACKET_INVOKE) {
      return false;
    }

    if (methodId === RPC_METHODS.Login_CheckVersion) {
      const codeMd5 = tryReadUxString(args, 0);
      const clientVersion =
        codeMd5 && codeMd5.next + 4 <= args.length ? args.readInt32LE(codeMd5.next) : null;
      log(
        `login-tcp CheckVersion ${remote} codeMd5=${JSON.stringify(codeMd5 && codeMd5.value)} ` +
          `clientVersion=${clientVersion}`,
      );
      sendRpcReturn(methodId, invokeId, 0);
      return true;
    }

    if (methodId === RPC_METHODS.Login_AskNewHotFixPatchLogin) {
      const version = args.length >= 4 ? args.readInt32LE(0) : null;
      const md5 = version !== null ? tryReadUxString(args, 4) : null;
      const clientVersion =
        md5 && md5.next + 4 <= args.length ? args.readInt32LE(md5.next) : null;
      // Confirmed by Player.log: the client downloads startup hotfix patches over HTTP
      // (trunk-client_startup_patch_info.txt -> stage0). This RPC is not the Stage1
      // loading trigger. Returning err=20903 (NoMoreHotFixPatch) lets the client continue
      // to the menu; returning err=0 with a struct breaks menu initialization.
      log(
        `login-tcp AskNewHotFixPatchLogin ${remote} version=${version} ` +
          `md5=${JSON.stringify(md5 && md5.value)} clientVersion=${clientVersion} ` +
          `reply=NoMoreHotFixPatch(${RPC_ERR_NO_MORE_HOTFIX_PATCH})`,
      );
      sendRpcReturn(methodId, invokeId, RPC_ERR_NO_MORE_HOTFIX_PATCH);
      return true;
    }

    if (methodId === RPC_METHODS.Login_RequestPatchesCheckDataFromLogin) {
      const clientVersion = args.length >= 4 ? args.readInt32LE(0) : null;
      const patchVersion = args.length >= 8 ? args.readInt32LE(4) : null;
      log(
        `login-tcp RequestPatchesCheckDataFromLogin ${remote} ` +
          `clientVersion=${clientVersion} patchVersion=${patchVersion}`,
      );
      sendRpcReturn(methodId, invokeId, 0, hotfixPatchCheckPayload());
      return true;
    }

    if (methodId === RPC_METHODS.Login_RequestCreateRoleEx) {
      log(`login-tcp RequestCreateRoleEx ${remote} ${JSON.stringify(parseCreateRoleArgs(args))}`);
      // Response: new pid (UXRPCTask<ulong>).
      sendRpcReturn(methodId, invokeId, 0, uxU64(BigInt(LOCAL_PLAYER_PID)));
      // After CreateRole, send SyncRoleList again with the newly created pid so
      // loginRolePid points to the new character and RequestEnterGame can continue.
      try {
        const rolePayload = uxU64(BigInt(LOCAL_PLAYER_PID));
        const body = Buffer.alloc(5 + rolePayload.length);
        body.writeUInt8(RPC_PACKET_NOTIFY, 0);
        body.writeInt32LE(RPC_NOTIFIES.Login_SyncRoleList, 1);
        rolePayload.copy(body, 5);
        socket.write(uxFrame(9, body));
        log(`login-tcp send-SyncRoleList ${remote} roleId=${LOCAL_PLAYER_PID} [after-CreateRole]`);
      } catch (e) {
        log(`login-tcp post-CreateRole SyncRoleList error: ${e.message}`);
      }
      return true;
    }

    if (methodId === RPC_METHODS.Login_AskUniSdkShareToken_Login) {
      log(`login-tcp AskUniSdkShareToken_Login ${remote}`);
      sendRpcReturn(methodId, invokeId, 0, uxString(LOCAL_SHARE_TOKEN));
      return true;
    }

    if (
      methodId === RPC_METHODS.Login_CheckAccount ||
      methodId === RPC_METHODS.Login_CheckAccountPassBy ||
      methodId === RPC_METHODS.Login_CheckAccountOpenId
    ) {
      const value = tryReadUxString(args, 0);
      log(
        `login-tcp CheckAccount ${remote} method=${methodId} ` +
          `value=${JSON.stringify(value && value.value)}`,
      );
      sendRpcReturn(methodId, invokeId, 0, checkAccountResultPayload());
      return true;
    }

    if (methodId === RPC_METHODS.Login_TryLogin) {
      const parsed = parseTryLoginArgs(args);
      log(`login-tcp TryLogin ${remote} ${JSON.stringify(parsed)}`);
      sendRpcReturn(methodId, invokeId, 0);

      // After TryLogin, server pushes SyncRoleList(roleId) as Notify.
      // SyncRoleList reader = ReadUInt64() -> a single pid, not a list.
      //
      // Confirmed by LoginManager.lua OnLogin: the client decides:
      //   loginRolePid == 0      -> RequestEnterGame() (character exists, enter directly)
      //   loginRolePid != 0      -> CheckShow(CREATE_CHARACTER_PANEL) (name prompt)
      // Previously this sent 100001 (!=0). Ananta_ROLE_PID controls the value:
      //   "0"      -> enter the existing character directly, without a prompt
      //   otherwise -> that value (for example 100001) -> character creation/popup
      const rolePidEnv = (process.env.Ananta_ROLE_PID ?? process.env.Ananta_ROLE_PID);
      const rolePidValue = rolePidEnv !== undefined ? BigInt(rolePidEnv) : 0n;
      if ((process.env.Ananta_NO_ROLELIST ?? process.env.Ananta_NO_ROLELIST) === "1") {
        log(`login-tcp SKIP SyncRoleList (Ananta_NO_ROLELIST=1) -> waiting for character creation`);
      } else {
        try {
          const rolePayload = uxU64(rolePidValue);
          const body = Buffer.alloc(5 + rolePayload.length);
          body.writeUInt8(RPC_PACKET_NOTIFY, 0);
          body.writeInt32LE(RPC_NOTIFIES.Login_SyncRoleList, 1);
          rolePayload.copy(body, 5);
          socket.write(uxFrame(9, body));
          log(`login-tcp send-SyncRoleList ${remote} roleId=${rolePidValue} mode=notify(existing-role signal) [reply-to-TryLogin]`);
        } catch (e) {
          log(`login-tcp SyncRoleList error: ${e.message}`);
        }
      }

      return true;
    }

    if (methodId === RPC_METHODS.Login_HasOnlinePlayer) {
      log(`login-tcp HasOnlinePlayer ${remote} ${JSON.stringify(parseTryLoginArgs(args))}`);
      sendRpcReturn(methodId, invokeId, 0);
      return true;
    }

    if (methodId === RPC_METHODS.Login_RequestPatchesFromLogin) {
      log(`login-tcp RequestPatchesFromLogin ${remote} args=${args.toString("hex")}`);
      sendRpcReturn(methodId, invokeId, 0, patchEntryListPayload());
      return true;
    }

    if (
      methodId === RPC_METHODS.Login_RequestEnterGame ||
      methodId === RPC_METHODS.Login_DebugRequestEnterGame
    ) {
      log(`login-tcp RequestEnterGame ${remote} method=${methodId}`);
      sendRpcReturn(methodId, invokeId, 0, enterGameDataPayload());
      return true;
    }

    if (methodId === RPC_METHODS.Login_RequestFpPassToken) {
      log(`login-tcp RequestFpPassToken ${remote} args=${args.toString("hex")}`);
      sendRpcReturn(methodId, invokeId, 0, uxString(LOCAL_FP_PASS_TOKEN));
      return true;
    }

    if (methodId === RPC_METHODS.Gate_Login) {
      log(`login-tcp Gate_Login ${remote} ${JSON.stringify(parseGateLoginArgs(args))}`);

      // Reply to Gate_Login immediately; no timer is required.
      sendRpcReturn(methodId, invokeId, 0);
      log(`login-tcp Gate_Login response sent ${remote}`);

      // Routing (per RPCDeserializeBase.lua: ctx.sidToImpl[mid/1000000][midToName[mid]]):
      //   SID 53 = GateToClientImpl  -> this Gate connection (5803)
      //   SID 64 = GameToClientImpl  -> game-tcp/5804
      //   SID 154 = AvatarToClientImpl -> RouteWithPid=Gate -> this Gate connection
      // Immediately after Gate_Login, send these responses sequentially:
      //   1. SendServerTime (SID 53) sets the server Unix time.
      //   2. SyncPlayerGameServerInfo (SID 154) tells the client
      //      where the game server is available (host:port + token).
      // 1) SendServerTime (2x f64 LE = unix sec).
      try {
          const nowSec = Date.now() / 1000.0;
          const stPayload = Buffer.alloc(16);
          stPayload.writeDoubleLE(nowSec, 0);   // clientTime
          stPayload.writeDoubleLE(nowSec, 8);   // serverTime
          const stBody = Buffer.alloc(5 + stPayload.length);
          stBody.writeUInt8(RPC_PACKET_NOTIFY, 0); // rpcMode = Notify
          stBody.writeInt32LE(RPC_NOTIFIES.Gate_SendServerTime, 1);
          stPayload.copy(stBody, 5);
          const stFrame = uxFrame(9, stBody);
          socket.write(stFrame);
          log(`login-tcp send-SendServerTime ${remote} t=${nowSec.toFixed(3)} [reply-to-Gate_Login]`);
        } catch (e) {
          log(`login-tcp SendServerTime error ${remote}: ${e.message}`);
        }

        // 2) SyncPlayerGameServerInfo so the client knows where
        //    the Game-Server lives. SID 154 = AvatarToClientImpl, routed via Gate.
        //    GameServerInfo wire format = 0xff(marker) + uxString(IP) + uxI32(Port) + uxString(Token)
        try {
          const gameServerInfoPayload = Buffer.concat([
            Buffer.from([0xff]),                      // common marker (struct present)
            uxString(LOCAL_LOGIN_HOST),               // ClientListenIp = 127.0.0.1
            uxI32(LOCAL_GAME_TCP_PORT),               // ClientListenPort = 5804
            uxString(LOCAL_PLAYER_TOKEN),       // Token
          ]);
          const gsBody = Buffer.alloc(5 + gameServerInfoPayload.length);
          gsBody.writeUInt8(RPC_PACKET_NOTIFY, 0);    // rpcMode = Notify
          gsBody.writeInt32LE(RPC_NOTIFIES.Avatar_SyncPlayerGameServerInfo, 1);
          gameServerInfoPayload.copy(gsBody, 5);
          const gsFrame = uxFrame(9, gsBody);
          socket.write(gsFrame);
          log(`login-tcp send-SyncPlayerGameServerInfo ${remote} mode=notify(3) port=${LOCAL_GAME_TCP_PORT} [reply-to-Gate_Login]`);
        } catch (e) {
          log(`login-tcp SyncPlayerGameServerInfo error ${remote}: ${e.message}`);
        }

      return true;
    }

    if (methodId === RPC_METHODS.Gate_AskUniSdkShareToken) {
      log(`login-tcp Gate_AskUniSdkShareToken ${remote}`);
      sendRpcReturn(methodId, invokeId, 0, uxString(LOCAL_SHARE_TOKEN));
      return true;
    }

    if (
      methodId === RPC_METHODS.Gate_AskCloseConnection ||
      methodId === RPC_METHODS.Game_AskCloseConnection
    ) {
      log(
        `login-tcp AskCloseConnection ${remote} method=${methodId} ` +
          `${JSON.stringify(parseSingleStringArg(args))}`,
      );
      sendRpcReturn(methodId, invokeId, 0, uxU32(0));
      return true;
    }

    if (methodId === RPC_METHODS.Game_AskRemainChangeNameCount) {
      log(`login-tcp Game_AskRemainChangeNameCount ${remote}`);
      sendRpcReturn(methodId, invokeId, 0, uxU32(99));
      return true;
    }

    if (
      methodId === RPC_METHODS.Game_AskChangeNameByItem ||
      methodId === RPC_METHODS.Game_AskChangeHackerName
    ) {
      log(
        `login-tcp ${rpcMethodName(methodId)} ${remote} ` +
          `${JSON.stringify(parseSingleStringArg(args))}`,
      );
      sendRpcReturn(methodId, invokeId, 0);
      return true;
    }

    if (methodId === RPC_METHODS.Game_AskStartGame) {
      log(`login-tcp Game_AskStartGame ${remote}`);
      sendRpcReturn(methodId, invokeId, 0);
      return true;
    }
    if (methodId === RPC_METHODS.Game_LoginGame) {
      log(`login-tcp Game_LoginGame ${remote} ${JSON.stringify(parsePidTokenArgs(args))}`);
      sendRpcReturn(methodId, invokeId, 0);
      return true;
    }

    if (methodId === RPC_METHODS.Game_RequestGameSceneData) {
      log(`login-tcp Game_RequestGameSceneData ${remote}`);
      // Return empty scene data - the client will load a default/empty scene
      sendRpcReturn(methodId, invokeId, 0);
      return true;
    }

    log(`login-tcp rpc-unhandled ${remote} method=${methodId} name=${rpcMethodName(methodId)} invoke=${invokeId} args=${args.toString("hex")}`);
    return false;
  }

  function handleUxMessage(mode, payload) {
    log(`login-tcp msg ${remote} mode=${mode} size=${payload.length} payload=${payload.toString("hex")}`);

    if (mode === 2 && payload.length >= 20) {
      sendS2CHandshake(payload);
      return;
    }

    if (mode === 4) {
      // The captured working server replies to heartbeat frames with eight zero
      // bytes. Echoing the client timestamp keeps the socket alive briefly, but
      // the client later resets the login connection before Play can send RPCs.
      const heartbeatAck = Buffer.alloc(8);
      const frame = uxFrame(3, heartbeatAck);
      socket.write(frame);
      log(`login-tcp send-heartbeat ${remote} ${frame.length} bytes ${frame.toString("hex")}`);
      return;
    }

    if (mode === 9) {
      handleRawRpc(payload);
      return;
    }

    if (!handshaked) {
      log(`login-tcp unexpected-before-handshake ${remote} mode=${mode}`);
    }
  }

  socket.on("data", (chunk) => {
    log(`login-tcp recv ${remote} ${chunk.length} bytes ${chunk.toString("hex")}`);
    pending = Buffer.concat([pending, chunk]);

    while (pending.length >= 5) {
      const size = pending.readInt32LE(0);
      const mode = pending.readUInt8(4);

      if (size < 0 || size > 8 * 1024 * 1024) {
        log(`login-tcp invalid-frame ${remote} mode=${mode} size=${size} buffer=${pending.toString("hex")}`);
        socket.destroy();
        return;
      }

      if (pending.length < 5 + size) {
        return;
      }

      const payload = pending.subarray(5, 5 + size);
      pending = pending.subarray(5 + size);
      handleUxMessage(mode, payload);
    }
  });

  socket.on("error", (error) => {
    log(`login-tcp error ${remote}: ${error.message}`);
  });

  socket.on("close", () => {
    log(`login-tcp close ${remote}`);
  });
});

loginTcpServer.listen(LOCAL_LOGIN_TCP_PORT, LOCAL_LOGIN_TCP_BIND_HOST, () => {
  log(
    `listening on tcp://${LOCAL_LOGIN_TCP_BIND_HOST}:${LOCAL_LOGIN_TCP_PORT} for login handshake capture; advertising ${LOCAL_LOGIN_TCP_HOSTS.join(", ")}`,
  );
});

// =============================================================================
// Phase 1 Game-TCP listener (port 5804) - capture-only, no business logic yet.
// We respond with the same handshake (mode=1, SessionId+HeartbeatInterval+Encryption=false)
// so the client moves past the handshake and starts emitting Game RPC frames.
// Every frame is hex-logged so we can see the actual Game RPC sequence.
// =============================================================================
const gameTcpServer = net.createServer((socket) => {
  const remote = `${socket.remoteAddress}:${socket.remotePort}`;
  let pending = Buffer.alloc(0);
  let handshaked = false;
  log(`game-tcp connect ${remote}`);

  function uxFrameGame(mode, payload) {
    const body = Buffer.isBuffer(payload) ? payload : Buffer.from(payload || []);
    const frame = Buffer.alloc(5 + body.length);
    frame.writeInt32LE(body.length, 0);
    frame.writeUInt8(mode, 4);
    body.copy(frame, 5);
    return frame;
  }

  function sendGameHandshake(clientPayload) {
    const aesKey = clientPayload.subarray(4, 20);
    const nonce = crypto.randomBytes(12);
    const chaChaHead = crypto.randomBytes(76);
    const aes = crypto.createCipheriv("aes-128-gcm", aesKey, nonce);
    const encryptedHead = Buffer.concat([aes.update(chaChaHead), aes.final(), aes.getAuthTag()]);
    const payload = Buffer.alloc(368);
    // SessionId can be overridden through the environment (default 1).
    // Ananta_GAME_SESSIONID=100001 can be used to test session-matching behavior.
    const sessionId = Number((process.env.Ananta_GAME_SESSIONID ?? process.env.Ananta_GAME_SESSIONID) || 1);
    payload.writeInt32LE(sessionId, 0);   // SessionId
    payload.writeInt32LE(10, 4);  // HeartbeatInterval seconds
    nonce.copy(payload, 8);
    encryptedHead.copy(payload, 20);
    const frame = uxFrameGame(1, payload);
    socket.write(frame);
    handshaked = true;
    log(`game-tcp send-handshake ${remote} SessionId=${sessionId} ${frame.length} bytes ${frame.toString("hex")}`);
  }

  socket.on("data", (chunk) => {
    log(`game-tcp recv ${remote} ${chunk.length} bytes ${chunk.toString("hex")}`);
    pending = Buffer.concat([pending, chunk]);

    while (pending.length >= 5) {
      const size = pending.readInt32LE(0);
      const mode = pending.readUInt8(4);

      if (size < 0 || size > 8 * 1024 * 1024) {
        log(`game-tcp invalid-frame ${remote} mode=${mode} size=${size}`);
        socket.destroy();
        return;
      }

      if (pending.length < 5 + size) {
        return;
      }

      const payload = pending.subarray(5, 5 + size);
      pending = pending.subarray(5 + size);

      log(`game-tcp frame ${remote} mode=${mode} size=${size} payload=${payload.toString("hex")}`);

      // The Game-Server handshake is identical to Login: client sends a Notify
      // frame (mode=2) with ClientMagic + local AES key, server responds with a
      // mode=1 S2C handshake (SessionId + HeartbeatInterval + Encryption=false).
      if (!handshaked && mode === 2 && size >= 20) {
        const clientMagic = payload.readUInt32LE(0);
        log(`game-tcp client-magic ${remote} 0x${clientMagic.toString(16)}`);
        sendGameHandshake(payload);
        continue;
      }

      // Legacy fallback: some flows might send mode=1 directly.
      // For RPCBegin (mode=8), we currently don't know the protocol semantics.
      // Reply with a neutral RpcReturn so the client doesn't time out.
      if (mode === 8 && payload.length >= 9) {
        const methodId = payload.readInt32LE(1);
        const invokeId = payload.readInt32LE(5);
        const ret = Buffer.alloc(13);
        ret.writeUInt8(RPC_PACKET_RETURN, 0);
        ret.writeInt32LE(methodId, 1);
        ret.writeInt32LE(invokeId, 5);
        ret.writeUInt32LE(0, 9);               // err = 0
        const frame = uxFrameGame(9, ret);
        socket.write(frame);
        log(`game-tcp send-rpc-return ${remote} method=${methodId} invoke=${invokeId} (stub) ${frame.toString("hex")}`);
      }

      // Mode=9 with RPC_PACKET sub-mode: parse rpcMode + methodId + ...
      // LoginGame notify contains uint64 pid + string token.
      // We do NOT close the socket. We log and let the client's heartbeat keep the
      // connection open. Phase 2 will send proper Init-Notifies in response.
      if (mode === 9 && payload.length >= 5) {
        const rpcMode = payload.readUInt8(0);
        const methodId = payload.readInt32LE(1);
        if (rpcMode === RPC_PACKET_NOTIFY) {
          const args = payload.subarray(5);
          log(`game-tcp client-NOTIFY ${remote} method=${methodId} args=${args.toString("hex")}`);
          if (methodId === RPC_METHODS.Game_LoginGame) {
            // Bisection switch (env Ananta_SEND), to isolate which post-LoginGame
            // packet is toxic vs. which the client actually waits for:
            //   none  -> send ONLY server time; expect the client to TIME OUT (like
            //            the reference implementations) and NOT crash. Proves the
            //            crash is caused by one of our data packets, not the flow.
            //   login -> server time + SyncPlayerInfo with InfoLogin only
            //   info-item/info-spirit/info-achievement/info-minor -> cumulative
            //            SyncPlayerInfo bisection up to that top-level Info block
            //   info  -> server time + full autoDefault SyncPlayerInfo
            //   task  -> server time + SyncPlayerInfo + SyncPlayerAllTask
            //   all   -> legacy everything with empty InfoSpirit
            //   world-solo -> automatic default: real player + one real spirit,
            //            without the extra world-kick nudges.
            const SEND = ((process.env.Ananta_SEND ?? process.env.Ananta_SEND) || "world-solo").toLowerCase();
            const infoModes = new Set([
              "login", "info-login",
              "info-item", "item",
              "info-spirit", "spirit",
              "info-achievement", "achievement",
              "info-minor", "minor",
              "info", "task", "all", "world", "world-solo", "solo-world", "world-fresh", "world-min", "world-null",
            ]);
            const worldModes = new Set(["world", "world-solo", "solo-world", "world-fresh", "world-min"]);
            const sendInfo = infoModes.has(SEND);
            const sendTask = SEND === "task" || SEND === "all" || worldModes.has(SEND);
            const sendScene = SEND === "all" || worldModes.has(SEND);
            // world-fresh: new character WITHOUT a spirit (no fabricated spirit IDs).
            // Testet ob der L50Game-Bau an den konstruierten Spirit-Daten scheitert.
            const useWorldSpirit = worldModes.has(SEND) && SEND !== "world-fresh" && SEND !== "world-min";
            const useWorldLoadingType = SEND === "world";
            const useWorldKick = SEND === "world";
            const postLoginDelayMs = Math.max(0, Number((process.env.Ananta_POST_LOGIN_DELAY_MS ?? process.env.Ananta_POST_LOGIN_DELAY_MS) || 350));
            log(`game-tcp client-NOTIFY ${remote} = LoginGame(pid+token) - bundle mode=${SEND} (info=${sendInfo} task=${sendTask} scene=${sendScene} loadingType=${useWorldLoadingType} kick=${useWorldKick} delay=${postLoginDelayMs}ms)`);
            // 2026-06-06 v12: All payloads built via the schema-driven serializer
            // (rpc_serializer.js) that mirrors the client's RPCSerializeBase.lua.
            // We fill plain objects; the serializer produces correct bytes.
            const PID_VALUE = LOCAL_PLAYER_PID;
            const DEFAULT_SPIRIT_TEMPLATE_ID = config.player.initialSpiritTemplateId;
            const DEFAULT_SPIRIT_INSTANCE_ID = PID_VALUE;
            const DEFAULT_WEAPON_TEMPLATE_ID = 0;
            const nowSec = Date.now() / 1000.0;

            const notify = (mid, payload) => {
              const body = Buffer.concat([Buffer.from([RPC_PACKET_NOTIFY]), int32le(mid), payload]);
              return uxFrameGame(9, body);
            };
            // Experiment: send SyncPlayerInfo as INVOKE (rpcMode=1) instead of Notify
            // to bypass Lua notify routing and exercise the native dispatcher.
            // Invoke-Frame: [rpcMode=1][int32 mid][int32 invokeId][payload]
            const FORCE_INVOKE = ((process.env.Ananta_PLAYERINFO_INVOKE ?? process.env.Ananta_PLAYERINFO_INVOKE) === "1");
            const invoke = (mid, invokeId, payload) => {
              const body = Buffer.concat([Buffer.from([RPC_PACKET_INVOKE]), int32le(mid), int32le(invokeId), payload]);
              return uxFrameGame(9, body);
            };
            function int32le(n){ const b=Buffer.alloc(4); b.writeInt32LE(n,0); return b; }
            function uint32le(n){ const b=Buffer.alloc(4); b.writeUInt32LE(n >>> 0,0); return b; }
            function uint64le(n){ const b=Buffer.alloc(8); b.writeBigUInt64LE(BigInt(n),0); return b; }
            function boolByte(v){ return Buffer.from([v ? 1 : 0]); }
            function doublele(n){ const b=Buffer.alloc(8); b.writeDoubleLE(Number(n),0); return b; }

            // (1) SendServerTimeGame - two doubles, no nesting
            const stPayload = Buffer.alloc(16);
            stPayload.writeDoubleLE(nowSec, 0);
            stPayload.writeDoubleLE(nowSec, 8);
            try {
              socket.write(notify(RPC_NOTIFIES.Game_SendServerTimeGame, stPayload));
              log(`game-tcp send-SendServerTimeGame ${remote} t=${nowSec.toFixed(3)}`);
            } catch (e) { log(`game-tcp SendServerTimeGame error: ${e.message}`); }

            // (2) SyncPlayerInfo -> PlayerClientInfo
            //  A real server NEVER sends a player with null sub-structs. The client
            //  (InitPlayerInfo + many PlayerData modules) immediately dereferences
            //  fields like InfoMinor.InfoNpcProfile.NpcProfiles right after this
            //  notify - a null there is a hard nil-deref that crashes the Lua VM
            //  (tolua.dll access violation; isolated via bisection 2026-06-07).
            //
            //  So we build the ENTIRE PlayerClientInfo fully-present via the
            //  schema-driven autoDefault(): every complex sub-object exists, every
            //  list/dict is present-empty, every primitive is 0. Then we overlay the
            //  real identity values. This is exactly what a fresh level-1 role looks
            //  like on a real server - zero nulls anywhere.
            //  REAL-WRITER PATH: build the object with the REAL field names from
            //  RPCSerializeAuto.lua and let the actual client serializer (executed
            //  in a Lua VM) produce the bytes. Empty lists are passed as null/omitted;
            //  the real WriteList writes them as present-empty exactly like the
            //  official server. No hand-built schema, no byte guessing.
            const baseInfoLogin = {
              Aid: LOCAL_AID,
              Pid: PID_VALUE,
              AccountId: LOCAL_ACCOUNT_ID,
              Name: LOCAL_DISPLAY_NAME,
              Level: 1,
              Sex: 1,
              PzHeadInfo: { HeadType: 0, SystemHeadId: 0 },
            };
            // Minimal payload experiment: only the three required fields used by the
            // L50Game constructor (AccountId/Pid/Aid). Complex info blocks stay present
            // but empty, with no spirit, to isolate payload compatibility issues.
            const minInfoLogin = {
              Aid: LOCAL_AID,
              Pid: PID_VALUE,
              AccountId: LOCAL_ACCOUNT_ID,
            };
            const infoBisectRank = {
              "info-item": 1, item: 1,
              "info-spirit": 2, spirit: 2,
              "info-achievement": 3, achievement: 3,
              "info-minor": 4, minor: 4,
            }[SEND] || 0;
            let playerInfoVariant = "login-only";
            // A real server sends a fresh player with ALL Info blocks PRESENT
            // (never null). The real writer fills every nested field with its
            // default, exactly like a freshly created level-1 character. Passing
            // {} = present-with-defaults; passing null = absent (which makes the
            // Lua SyncPlayerInfoProxy handlers deref nil and abort).
            let playerInfoObj = { Config: null, InfoLogin: baseInfoLogin, InfoItem: {}, InfoSpirit: {}, InfoMinor: {}, InfoAchievement: {} };
            if (SEND === "world-min") {
              // Minimal payload: required fields only, with all complex blocks present but empty.
              playerInfoVariant = "world-min";
              playerInfoObj = { Config: null, InfoLogin: minInfoLogin, InfoItem: {}, InfoSpirit: {}, InfoMinor: {}, InfoAchievement: {} };
            } else if (SEND === "world-null") {
              // Null-block test: mark complex sub-blocks as absent (null -> 0x00) so the
              // parser does not attempt to read empty present blocks.
              playerInfoVariant = "world-null";
              playerInfoObj = {
                Config: null,
                InfoLogin: { Aid: LOCAL_AID, Pid: PID_VALUE, AccountId: LOCAL_ACCOUNT_ID, Level: 1, Sex: 1 },
                InfoItem: null,
                InfoSpirit: null,
                InfoMinor: null,
                InfoAchievement: null,
              };
            } else if (SEND === "info" || SEND === "task" || SEND === "all" || worldModes.has(SEND)) {
              playerInfoVariant = "real-writer";
              if (useWorldSpirit) {
                playerInfoVariant = "world-spirit-realwriter";
                playerInfoObj.InfoSpirit = {
                  // Spirits: list of SpiritInfo (real field names from WriteSpiritInfo)
                  Spirits: [{
                    Id: DEFAULT_SPIRIT_INSTANCE_ID,
                    TemplateId: DEFAULT_SPIRIT_TEMPLATE_ID,
                    PossessTime: Math.floor(nowSec),
                    HpRate: 1.0,
                    SpiritUrbanSkill: null,
                    SpiritAbilities: null,
                    SpiritJobInfo: null,
                    PermanentAddAttributes: null,
                    InfoBadge: null,
                    MobileSkinInfo: null,
                    WeaponSlots: [],      // present-empty list (Chef-Fix: explizit [] statt null)
                    EverSwitched: true,
                    CurrentJobId: 0,
                    SpiritBattleInfo: null,
                    TalentInfo: null,
                    SpiritFightStyle: null,
                    Blocked: false,
                  }],
                  InfoPokemon: {
                    AllPokemons: null,
                    FastFightSquad: [DEFAULT_SPIRIT_INSTANCE_ID],
                    EnabledBodyIds: [DEFAULT_SPIRIT_TEMPLATE_ID],
                    EnabledCampIds: null,
                    EnabledWeaponIds: DEFAULT_WEAPON_TEMPLATE_ID ? [DEFAULT_WEAPON_TEMPLATE_ID] : null,
                  },
                  AvailableSkinParts: null,
                  InfoArmory: null,
                  ActiveSpirit: DEFAULT_SPIRIT_TEMPLATE_ID,
                  DisableBadgeInfoDict: null,
                  InfoFightStyle: null,
                  CommonSpiritTalentExp: 0,
                };
              }
            } else if (infoBisectRank > 0) {
              playerInfoVariant = ["login-only", "up-to-item", "up-to-spirit", "up-to-achievement", "up-to-minor"][infoBisectRank];
              if (infoBisectRank >= 1) playerInfoObj.InfoItem = {};
              if (infoBisectRank >= 2) playerInfoObj.InfoSpirit = {};
              if (infoBisectRank >= 3) playerInfoObj.InfoAchievement = {};
              if (infoBisectRank >= 4) playerInfoObj.InfoMinor = {};
            }
            // ============================================================
            // REQUEST-DRIVEN FLOW (2026-06-09): SyncPlayerInfo and SyncPlayerAllTask
            // are sent immediately and sequentially after the client's LoginGame notify.
            // The scene bundle is handled by the scene-ready flow below.
            // ============================================================
            // (2) SyncPlayerInfo -> PlayerClientInfo
            if (sendInfo) {
              try {
                const buf = LuaWriter.serializeComplexByRef("78", playerInfoObj);
                if (FORCE_INVOKE) {
                  socket.write(invoke(RPC_NOTIFIES.Game_SyncPlayerInfo, 1, buf));
                  log(`game-tcp send-SyncPlayerInfo(INVOKE rpcMode=1 invokeId=1 ${playerInfoVariant}) ${remote} ${buf.length}b [reply-to-LoginGame]`);
                } else {
                  socket.write(notify(RPC_NOTIFIES.Game_SyncPlayerInfo, buf));
                  log(`game-tcp send-SyncPlayerInfo(realwriter-${playerInfoVariant}) ${remote} ${buf.length}b [reply-to-LoginGame]`);
                }
              } catch (e) { log(`game-tcp SyncPlayerInfo error: ${e.message}`); }
            } else {
              log(`game-tcp SKIP SyncPlayerInfo (bisect mode)`);
            }

            // (3) SyncPlayerAllTask - reader has its own schema
            //  Reader fields: taskInfos[], submitTaskList[], submitEventList[],
            //  currentTask u32, eventPanelInfo complex[39], eventViewInfoList[], loginGameServer bool
            if (sendTask) {
              try {
                const buf = buildSyncPlayerAllTask();
                socket.write(notify(RPC_NOTIFIES.Game_SyncPlayerAllTask, buf));
                log(`game-tcp send-SyncPlayerAllTask(v12) ${remote} loginGameServer=true ${buf.length}b [reply-to-LoginGame]`);
              } catch (e) { log(`game-tcp SyncPlayerAllTask error: ${e.message}`); }
            } else {
              log(`game-tcp SKIP SyncPlayerAllTask (bisect mode)`);
            }

            // (4) SyncEnterScene -> EnterSceneInfo. REAL-WRITER path:
            // real field names from WriteEnterSceneInfo, serialized by the actual
            // client serializer in the Lua VM.
            const WORLD_MAP_RAID_ID = config.world.raidId;
            const enterSceneObj = {
              PlayerSessionId: PID_VALUE,
              RaidId: WORLD_MAP_RAID_ID,
              InstanceId: useWorldSpirit ? PID_VALUE : 0,
              Position: { X: 1346.209, Y: 133.163, Z: 1857.175 },
              Facing: 0,
              SpoonLevels: null,
              SpoonMd5s: null,
              Spirits: useWorldSpirit ? [{
                Id: DEFAULT_SPIRIT_INSTANCE_ID,
                TemplateId: DEFAULT_SPIRIT_TEMPLATE_ID,
                IsActive: true,
                WeaponTemplateId: DEFAULT_WEAPON_TEMPLATE_ID,
                WeaponSkinId: 0,
              }] : null,
              GridInfo: { MinX: 0, MinZ: 0, MaxX: 4096, MaxZ: 4096 },
              MatchGameId: 0,
              SwitchShowId: 0,
              IsSwitchSpiritShow: false,
              SectorControlId: 0,
              LoadingType: useWorldLoadingType ? { Type: 0, Members: [PID_VALUE] } : null,
            };
            socket._pendingEnterScene = enterSceneObj;

            // (4) SyncEnterScene belongs in the direct LoginGame response, sequentially
            // after SyncPlayerAllTask. The client reacts to SyncEnterScene before it can
            // emit RequestGameSceneData, so do not wait on that request first.
            if (sendScene) {
              // Timing hardening: SyncEnterScene may be delayed for compatibility.
              // Delay scene entry long enough for the native game object to be created
              // before the scene-entry gate checks that the game object is available.
              const sceneDelayMs = Math.max(0, Number((process.env.Ananta_SCENE_DELAY_MS ?? process.env.Ananta_SCENE_DELAY_MS) || 1500));
              const sendSceneNow = () => {
                try {
                  const sceneBuf = LuaWriter.serializeComplexByRef("53", enterSceneObj);
                  socket.write(notify(RPC_NOTIFIES.Game_SyncEnterScene, sceneBuf));
                  log(`game-tcp send-SyncEnterScene(realwriter delay=${sceneDelayMs}ms) ${remote} ${sceneBuf.length}b raid=${enterSceneObj.RaidId} [reply-to-LoginGame]`);
                } catch (e) { log(`game-tcp SyncEnterScene error: ${e.message}`); }
                // Observed on 2026-06-10: this client build does not send
                // RequestGameSceneData over the network. Send the required scene follow-up
                // packets proactively after SyncEnterScene so world loading can complete.
                const proactive = (process.env.Ananta_PROACTIVE_FOLLOWUP ?? process.env.Ananta_PROACTIVE_FOLLOWUP) !== "0";
                if (proactive) {
                  const fuDelay = Math.max(0, Number((process.env.Ananta_FOLLOWUP_DELAY_MS ?? process.env.Ananta_FOLLOWUP_DELAY_MS) || 800));
                  setTimeout(() => {
                    if (socket.destroyed) return;
                    if (typeof socket._sendSceneFollowup === "function") {
                      log(`game-tcp PROACTIVE scene-followup (no RequestGameSceneData arrives over RPC) +${fuDelay}ms`);
                      socket._sendSceneFollowup("proactive-after-SyncEnterScene", true);
                    }
                  }, fuDelay);
                }
              };
              if (sceneDelayMs > 0) {
                log(`game-tcp queuing SyncEnterScene with ${sceneDelayMs}ms delay (C# L50Game build window)`);
                setTimeout(() => { if (!socket.destroyed) sendSceneNow(); }, sceneDelayMs);
              } else {
                sendSceneNow();
              }
            } else {
              log(`game-tcp SKIP SyncEnterScene (bisect mode)`);
            }

            // Scene follow-up packets may be sent by the request-driven path when the
            // client emits RequestGameSceneData.
            socket._sceneFollowupSent = false;
            socket._sendSceneFollowup = (trigger, force) => {
              // In world-solo mode, the proactive path uses force=true because the
              // normal world-kick guard would otherwise suppress CurrentSpirit,
              // LoadRate, and WorldReady follow-up packets.
              if (!sendScene) return;
              if (!force && !useWorldKick) return;
              if (socket._sceneFollowupSent) return;
              socket._sceneFollowupSent = true;
              // (5) SyncPlayerCurrentSpirit
              try {
                const currentSpiritBuf = Buffer.concat([
                  uint64le(PID_VALUE),
                  uint32le(DEFAULT_SPIRIT_TEMPLATE_ID),
                  uint64le(DEFAULT_SPIRIT_INSTANCE_ID),
                  boolByte(false),
                ]);
                socket.write(notify(RPC_NOTIFIES.GameScene_SyncPlayerCurrentSpirit, currentSpiritBuf));
                log(`game-tcp send-SyncPlayerCurrentSpirit ${remote} pid=${PID_VALUE} ${currentSpiritBuf.length}b [reply-to-${trigger}]`);
              } catch (e) { log(`game-tcp SyncPlayerCurrentSpirit error: ${e.message}`); }
              // (6) SyncPlayerLoadRate
              try {
                const loadRateBuf = Buffer.concat([
                  uint64le(PID_VALUE),
                  doublele(1.0),
                ]);
                socket.write(notify(RPC_NOTIFIES.GameScene_SyncPlayerLoadRate, loadRateBuf));
                log(`game-tcp send-SyncPlayerLoadRate ${remote} pid=${PID_VALUE} rate=1 ${loadRateBuf.length}b`);
              } catch (e) { log(`game-tcp SyncPlayerLoadRate error: ${e.message}`); }
              // (7) SyncWorldReady (GameScene sid 68) - LuaOnly,
              // empty-reader "world is ready" trigger, sent last.
              try {
                socket.write(notify(RPC_NOTIFIES.GameScene_SyncWorldReady, Buffer.alloc(0)));
                log(`game-tcp send-SyncWorldReady ${remote} 0b-payload`);
              } catch (e) { log(`game-tcp SyncWorldReady error: ${e.message}`); }
            };
          } else if (methodId === RPC_METHODS.Game_RequestGameSceneData) {
            // The client signals that it is ready for scene data after SyncEnterScene.
            // Confirm scene entry again and send the scene follow-up packets.
            log(`game-tcp client-NOTIFY ${remote} = RequestGameSceneData -> scene followup (request-driven)`);
            try {
              const enterSceneObj = socket._pendingEnterScene || {
                PlayerSessionId: LOCAL_PLAYER_PID, RaidId: config.world.raidId, InstanceId: 0,
                Position: { X: 1346.209, Y: 133.163, Z: 1857.175 }, Facing: 0,
                SpoonLevels: null, SpoonMd5s: null, Spirits: null,
                GridInfo: { MinX: 0, MinZ: 0, MaxX: 4096, MaxZ: 4096 },
                MatchGameId: 0, SwitchShowId: 0, IsSwitchSpiritShow: false,
                SectorControlId: 0, LoadingType: null,
              };
              const sceneBuf = LuaWriter.serializeComplexByRef("53", enterSceneObj);
              const midBuf = Buffer.alloc(4); midBuf.writeInt32LE(RPC_NOTIFIES.Game_SyncEnterScene, 0);
              const esBody = Buffer.concat([Buffer.from([RPC_PACKET_NOTIFY]), midBuf, sceneBuf]);
              socket.write(uxFrameGame(9, esBody));
              log(`game-tcp send-SyncEnterScene(on-request realwriter) ${remote} ${sceneBuf.length}b raid=${enterSceneObj.RaidId}`);
            } catch (e) {
              log(`game-tcp SyncEnterScene(on-request) error ${remote}: ${e.message}`);
            }
            // Send CurrentSpirit, LoadRate, and WorldReady as the response to the
            // client's scene-ready signal.
            if (typeof socket._sendSceneFollowup === "function") {
              socket._sendSceneFollowup("RequestGameSceneData");
            }
          } else if (methodId === RPC_METHODS.Game_AskPanelBrowsingTime) {
            const panelId = args.length >= 4 ? args.readUInt32LE(0) : null;
            const logicId = args.length >= 8 ? args.readUInt32LE(4) : null;
            const time = args.length >= 12 ? args.readUInt32LE(8) : null;
            log(`game-tcp client-NOTIFY ${remote} = AskPanelBrowsingTime panelId=${panelId} logicId=${logicId} time=${time} (no reply)`);
          } else {
            // Diagnostic logging for every unknown client notify, including method name
            // and service ID (floor(mid/1e6)), to identify unhandled world-loading traffic.
            const svc = Math.floor(methodId / 1000000);
            log(`game-tcp client-NOTIFY ${remote} method=${methodId} name=${rpcMethodName(methodId)} sid=${svc} args=${args.slice(0,32).toString("hex")} (UNHANDLED-NOTIFY)`);
          }
        } else if (rpcMode === 1 && payload.length >= 9) {
          const invokeId = payload.readInt32LE(5);
          const args = payload.subarray(9);
          log(`game-tcp client-INVOKE ${remote} method=${methodId} invoke=${invokeId} args=${args.toString("hex")}`);
          // Stub-return so the client doesn't time out.
          const ret = Buffer.alloc(13);
          ret.writeUInt8(RPC_PACKET_RETURN, 0);
          ret.writeInt32LE(methodId, 1);
          ret.writeInt32LE(invokeId, 5);
          ret.writeUInt32LE(0, 9);
          const frame = uxFrameGame(9, ret);
          socket.write(frame);
          log(`game-tcp send-rpc-return ${remote} method=${methodId} invoke=${invokeId} (auto-OK) ${frame.toString("hex")}`);
        }
      }

      // 4229938 heartbeat: C2S=4, S2C=3.
      if (mode === 4) {
        const echo = uxFrameGame(3, payload);
        socket.write(echo);
        log(`game-tcp heartbeat-echo ${remote} ${echo.toString("hex")}`);
      }
    }
  });

  socket.on("error", (error) => {
    log(`game-tcp error ${remote}: ${error.message}`);
  });

  socket.on("close", () => {
    log(`game-tcp close ${remote}`);
  });
});

gameTcpServer.listen(LOCAL_GAME_TCP_PORT, LOCAL_LOGIN_TCP_BIND_HOST, () => {
  log(
    `listening on tcp://${LOCAL_LOGIN_TCP_BIND_HOST}:${LOCAL_GAME_TCP_PORT} for game-server handshake capture (Phase 1)`,
  );
});

// =============================================================================
// GameScene compatibility sub-server. The listening port comes from private-server.json.
// After L50Game is built, the client connection is redirected to this local listener. We answer the same UX
// 4229938 handshake (mode=2 -> mode=1) and RPC Raw mode=9.
// and log every frame to learn the GameScene (sid 68) protocol.
// =============================================================================
const SCENE_SUB_PORT = config.network.proxy.sceneSubPort;
// The client sends HTTP-style /roadsign requests on this compatibility listener.
// Das ist ein NetEase AOI/Scene-Routing-Dienst ("roadsign"). Wir antworten als
// HTTP server. Keep responses minimal (empty JSON/OK) until the expected
// Format aus der vollen Anfrage kennen.
const sceneSubServer = net.createServer((socket) => {
  const remote = `${socket.remoteAddress}:${socket.remotePort}`;
  let pending = Buffer.alloc(0);
  log(`scene-sub connect ${remote}`);

  socket.on("data", (chunk) => {
    pending = Buffer.concat([pending, chunk]);
    const text = pending.toString("utf8");
    log(`scene-sub recv ${remote} ${chunk.length}b FULL=${JSON.stringify(text.slice(0, 400))}`);
    // Warte auf Ende der HTTP-Header (\r\n\r\n)
    const headerEnd = text.indexOf("\r\n\r\n");
    if (headerEnd === -1) return;
    const reqLine = text.split("\r\n")[0];
    log(`scene-sub HTTP request: ${reqLine}`);
    // roadsign = In-Game-Schilder-System (LX6.RoadSign.RoadSignManager). Der
    // the native C# parser expects a LIST of signs. An empty object {}
    // wirft InvalidCast -> Scene-Load-Coroutine stirbt lautlos -> ANR.
    // Daher: data als leeres ARRAY liefern. Per ENV umstellbar fuer Varianten.
    const variant = (process.env.Ananta_ROADSIGN ?? process.env.Ananta_ROADSIGN) || "array";
    let bodyObj;
    if (variant === "listobj") bodyObj = { code: 0, ret: 0, errno: 0, msg: "ok", data: { list: [], signs: [] } };
    else bodyObj = { code: 0, ret: 0, errno: 0, msg: "ok", data: [] };
    const body = Buffer.from(JSON.stringify(bodyObj), "utf8");
    const resp = Buffer.concat([
      Buffer.from(
        `HTTP/1.1 200 OK\r\n` +
        `Content-Type: application/json\r\n` +
        `Content-Length: ${body.length}\r\n` +
        `Connection: close\r\n\r\n`, "utf8"),
      body,
    ]);
    socket.write(resp);
    log(`scene-sub HTTP 200 sent ${remote} ${body.length}b body`);
    pending = Buffer.alloc(0);
  });
  socket.on("error", (e) => log(`scene-sub error ${remote}: ${e.message}`));
  socket.on("close", () => log(`scene-sub close ${remote}`));
});
sceneSubServer.listen(SCENE_SUB_PORT, LOCAL_LOGIN_TCP_BIND_HOST, () => {
  log(`listening on tcp://${LOCAL_LOGIN_TCP_BIND_HOST}:${SCENE_SUB_PORT} for GameScene compatibility sub-server`);
});
