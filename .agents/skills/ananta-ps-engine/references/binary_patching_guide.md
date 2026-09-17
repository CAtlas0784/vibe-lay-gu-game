# GameAssembly.dll (Il2Cpp) Binary Patching Reference

This document outlines the standard binary patch patterns for NetEase Il2Cpp Unity clients to allow offline private server analysis.

---

## 1. Unity TLS / Certificate Validation Bypass

### Target:
`UnityEngine.Networking.CertificateHandler.ValidateCertificate`

### Patch:
Replace function prologue with immediate return `true` / `0`:
```assembly
xor eax, eax
ret
```
Opcode: `31 C0 C3` (or `B0 01 C3` for `mov al, 1; ret`).
This allows `UnityWebRequest` to communicate with custom local HTTPS proxies without certificate verification failures.

---

## 2. PSO Warmup / Shader Compiling Stub

### Target:
`UnityEngine.PSOWarmupAsyncOperation..ctor`

### Patch:
```assembly
ret
```
Opcode: `C3 CC CC CC`
Stubs out the engine-level warmup operation if boot configuration or remote JSON flags fail to suppress it.

---

## 3. NetEase Anti-Cheat (NEAC) Stubbing

### Target:
`NeacUtils.Initialize` or `AntiCheat` initialization routines.

### Patch:
```assembly
xor eax, eax
ret
```
Opcode: `31 C0 C3`
Prevents NEAC background thread monitoring and process termination during local debugging.
