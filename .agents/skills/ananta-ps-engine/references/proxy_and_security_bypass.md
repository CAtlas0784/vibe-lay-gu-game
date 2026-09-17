# Proxy, SSL, UniSDK Auth, and Shader Warmup Bypass Reference

This document details the exact mechanisms required to intercept, authenticate, and run NetEase Unity (il2cpp) clients (specifically Project Mugen / Ananta CBT 4229938 and similar NetEase titles) without modifying client binaries or using brittle fake DLLs.

---

## 1. Two-Tier PKI Certificate Architecture

Unity's modern HTTP/TLS stack rejects self-signed server certificates that have `CA=TRUE` directly on the leaf certificate. The correct solution is a clean two-tier PKI:

1. **Root CA (`DRMK Local Proxy Root`)**:
   - `Subject`: `CN=DRMK Local Proxy Root`
   - `Basic Constraints`: `critical, CA=TRUE, pathlength=1`
   - `Key Usage`: `CertSign, CRLSign, DigitalSignature`
   - Installed into `Cert:\LocalMachine\Root` (Windows Trusted Root Certification Authorities).
2. **Leaf Certificate (`l50.update.netease.com`)**:
   - `Subject`: `CN=l50.update.netease.com`
   - `Basic Constraints`: `critical, CA=FALSE`
   - `Enhanced Key Usage`: `1.3.6.1.5.5.7.3.1` (Server Authentication)
   - Signed by the Root CA above.
   - Includes full SAN (Subject Alternative Name) list for all NetEase update/auth domains.

### Required Redirect Domains in `hosts`:
```text
127.0.0.1 l50.update.netease.com
127.0.0.1 serverlist-test.l50.leihuo.netease.com
127.0.0.1 l50.gdl.netease.com
127.0.0.1 l50.gph.netease.com
127.0.0.1 l50.gsgph.netease.com
127.0.0.1 service.mkey.163.com
127.0.0.1 qatest.g.mkey.163.com
127.0.0.1 bind-mobile.g.mkey.163.com
127.0.0.1 mpay-common-server.g.mkey.163.com
127.0.0.1 whoami.nie.netease.com
127.0.0.1 protocol.unisdk.netease.com
127.0.0.1 tpsl.nie.netease.com
127.0.0.1 applog.matrix.netease.com
127.0.0.1 mgbsdk.matrix.netease.com
127.0.0.1 mgbsdktest.matrix.netease.com
127.0.0.1 dns.update.netease.com
127.0.0.1 openapi.music.163.com
```

---

## 2. Authentic `NtUniSdkBase.dll` WebView Bridge Auth Bypass

Do **NOT** replace `NtUniSdkBase.dll` with a fake stub DLL. Use the authentic NetEase DLL (6.16 MB) and intercept the WebView login request:

1. In the HTTPS proxy (port 443), intercept:
   - `GET /local-mpay-login`
   - `GET /sdk/uni_sauth`
   - `POST /sdk/check_enter`
2. When UniSDK requests `service.mkey.163.com/local-mpay-login`, return a lightweight HTML payload containing a client-side JavaScript bridge trigger:
   ```javascript
   const user = { /* account payload */ };
   const payload = {
     methodId: "ngwebview_notify_native",
     reqData: {
       methodId: "onUserLogin",
       device_id: user.device_id,
       deviceid: user.deviceid,
       udid: user.udid,
       user: user
     }
   };

   function sendLogin() {
     try {
       if (window.NeteaseMpayJSBridge?.Common?.onUserLogin) {
         window.NeteaseMpayJSBridge.Common.onUserLogin(user);
       }
     } catch (e) {}
     try {
       if (window.UniSDKJSBridge?.postMsgToNative) {
         window.UniSDKJSBridge.postMsgToNative(payload);
       }
     } catch (e) {}
   }
   window.addEventListener("NeteaseMpayJSBridgeReady", sendLogin);
   setTimeout(sendLogin, 200);
   ```
3. This delivers the login callback straight into `NtUniSdkBase.dll` natively.

---

## 3. Shader Warmup OOM & RAM 100% Suppression

When `triggerWarmupBelowVersion` in `pc_netease_version.json` contains a version string, the engine triggers warmup for all 11,384 shaders simultaneously across all CPU threads at full speed (`d3d12-pso-warmup-full-speed=true`), causing a 19+ GB memory surge and a `CreateCommittedResource (8007000e)` crash.

**Fix**:
In `pc_netease_version.json`:
```json
{
  "resUpdate": [{
    "minV": "0",
    "maxV": "18446744073709551615",
    "resV": "20260805061659654p0",
    "resC": "b5481abf8e882801b424fe2c0bf0adfe",
    "soResC": "",
    "enableDlc": "False",
    "triggerWarmupBelowVersion": "",
    "codeV": "4229938",
    "artifactV": "4221361",
    "enableIBT": "False",
    "enableIBTOneInN": "1"
  }]
}
```
Setting `triggerWarmupBelowVersion: ""` (empty string) completely skips full PSO shader compilation!

---

## 4. ServerList Contract MD5 Bypass

Client 4229938 calculates its runtime Contract MD5. If `serverlist.txt` includes extra columns (hash, artifact, branch), `LoginManager.CheckVersion` checks the hash and rejects the server with *"Server is under maintenance"*.

**Fix**:
Serve exactly 7 basic columns:
```text
*,801,QA101,Outer,http://127.0.0.1:5801/LoginList,1,14
```
Omitting the hash/version columns causes `CheckVersion` to skip validation entirely.

---

## 5. System.Text.Json Case-Insensitive Collision Fix

In C# .NET 8, building an anonymous object with both `deviceid` and `deviceId` throws:
```text
System.ArgumentException: An item with the same key has already been added. Key: deviceid
```
This causes `CheckAccount` to fail silently and send an empty response, trapping the client at the start menu.

**Fix**:
Use `Dictionary<string, object?>` instead of anonymous objects:
```csharp
var loginJson = JsonSerializer.Serialize(new Dictionary<string, object?>
{
    ["deviceid"] = deviceId,
    ["device_id"] = deviceId,
    ["udid"] = deviceId,
    ["unisdk_device_id"] = deviceId,
    ["code"] = 200,
    ["subcode"] = 0,
    ["msg"] = "ok",
    ["uid"] = Profile.AccountId,
    ["pid"] = Profile.PlayerPid
});
```
