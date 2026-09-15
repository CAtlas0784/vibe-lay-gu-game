// lua_writer.js
// Executes the REAL client serializer (RPCSerializeBase.lua + RPCSerializeAuto.lua)
// verbatim inside a Lua 5.3 VM (fengari). No hand-written schema, no byte
// guessing: the exact same write code the official server's generated
// serializer uses. We only provide the low-level binary writer (string.pack)
// which matches the verified wire format (LE primitives; strings use UX 7-bit
// encoded length+1, buffers use the matching Buffer/Buffer7Bit length encoding).

const fs = require("fs");
const path = require("path");
const fengari = require("fengari");
const { lua, lauxlib, lualib, to_luastring } = fengari;
const lua_tojsstring = lua.lua_tojsstring;

const LUA_DIR = path.join(__dirname, "lua");
const SERIALIZE_BASE = path.join(LUA_DIR, "RPCSerializeBase.lua");
const SERIALIZE_AUTO = path.join(LUA_DIR, "RPCSerializeAuto.lua");

function stripBom(s) { return s.replace(/^\uFEFF/, "").replace(/^\xEF\xBB\xBF/, ""); }
let baseSrc = stripBom(fs.readFileSync(SERIALIZE_BASE, "latin1"));
let autoSrc = stripBom(fs.readFileSync(SERIALIZE_AUTO, "latin1"));

// FIX a known bad-decompile in game Lua source RPCSerializeBase.lua: the limit
// guard was decompiled as `not (limit > 0) and not (limit < num)` which throws
// on empty lists/dicts. The real client logic (verified vs 5_clean_mk dump) is
// `limit > 0 and limit < num`. Patch both List and Dict guards.
baseSrc = baseSrc.replace(/not \(limit > 0\) and not \(limit < num\)/g, "limit > 0 and limit < num");
baseSrc = baseSrc.replace(/not \(limit > 0\) and not \(limit < count\)/g, "limit > 0 and limit < count");
// Also fix the badly-decompiled counter() max-key logic:
// `count = not (count < n) and n or count` -> `count = count < n and n or count`
baseSrc = baseSrc.replace(/count = not \(count < n\) and n or count/g, "count = count < n and n or count");
// Il2Cpp Lua decompiler leaves upvalue placeholders (uv0) in standalone chunks.
// In the real client these are pre-bound tables; recreate them when executing
// the serializer outside the game.
baseSrc = baseSrc.replace(/local Serializer = uv0/, "local Serializer = {}");
autoSrc = autoSrc.replace(/local Auto = uv0/, "local Auto = {}");
// EnumCheck is another injected client upvalue. Validation is irrelevant for
// offline packet generation; preserve the supplied value or the generated
// default exactly.
baseSrc = baseSrc.replace(/function Serializer\.CheckEnum\(value, typeName, defaultVal\)[\s\S]*?\nend\n\nreturn Serializer/,
  "function Serializer.CheckEnum(value, typeName, defaultVal) if value == nil then return defaultVal end return value end\n\nreturn Serializer");

// Bootstrap: only ASCII shims + the binary writer factory.
const BOOTSTRAP = `
function print_error(...) end
function print_warn(...) end
function print_notice(...) end
function print_debug(...) end
RpcLengthLimits = setmetatable({}, { __index = function() return 0 end })

local function new_writer()
  local w = { _chunks = {} }
  function w:_emit(s) self._chunks[#self._chunks+1] = s end
  function w:WriteByte(v)   self:_emit(string.pack("<B", (v or 0) & 0xff)) end
  function w:WriteBoolean(v) self:_emit(string.pack("<B", (v and 1 or 0))) end
  function w:WriteInt16(v)  self:_emit(string.pack("<i2", v or 0)) end
  function w:WriteUInt16(v) self:_emit(string.pack("<I2", (v or 0) & 0xffff)) end
  function w:WriteInt32(v)  self:_emit(string.pack("<i4", v or 0)) end
  function w:WriteUInt32(v) self:_emit(string.pack("<I4", (v or 0) & 0xffffffff)) end
  function w:WriteInt64(v)
    local n = tonumber(v or 0)
    if n < 0 then n = n + 18446744073709551616.0 end
    for _=1,8 do local b=n % 256; self:WriteByte(b); n=math.floor(n/256) end
  end
  function w:WriteUInt64(v)
    local n = tonumber(v or 0)
    for _=1,8 do local b=n % 256; self:WriteByte(b); n=math.floor(n/256) end
  end
  function w:WriteSingle(v) self:_emit(string.pack("<f", v or 0.0)) end
  function w:WriteDouble(v) self:_emit(string.pack("<d", v or 0.0)) end
  function w:Write7BitEncodedInt(value)
    -- Client UXBinaryWriter increments the logical value before emitting it.
    -- Reader decodes and subtracts one. So count=0 is wire 0x01.
    local v = math.floor(value or 0) + 1
    repeat
      local b = v & 0x7f
      v = math.floor(v / 128)
      if v ~= 0 then b = b | 0x80 end
      self:WriteByte(b)
    until v == 0
  end
  function w:WriteString(val, nullable, name, limit)
    -- Strings use 0x00 for null and UX 7-bit length for non-null data.
    -- Since Write7BitEncodedInt itself adds one, pass the raw UTF-8 length.
    if val == nil then self:WriteByte(0); return end
    local s = tostring(val)
    self:Write7BitEncodedInt(#s)
    self:_emit(s)
  end
  local function normalize_buffer(val)
    local s = val or ""
    if type(s) == "table" then
      local t = {}
      for i=1,#s do t[i] = string.char((s[i] or 0) & 0xff) end
      s = table.concat(t)
    end
    return s
  end
  function w:WriteBuffer(val, length, limit)
    local s = normalize_buffer(val)
    self:WriteInt32(#s)
    self:_emit(s)
  end
  function w:WriteBuffer7Bit(val, length, limit)
    local s = normalize_buffer(val)
    self:Write7BitEncodedInt(#s)
    self:_emit(s)
  end
  function w:tostring() return table.concat(self._chunks) end
  return w
end
_G.__new_writer = new_writer

function require(name)
  if name == "LX6/Service/RPCSerializeBase" then return _G.__BaseSerializer end
  return nil
end
`;

let _L = null;

function runBuffer(L, buf, chunkname) {
  const arr = Uint8Array.from(buf);
  const st = lauxlib.luaL_loadbuffer(L, arr, arr.length, to_luastring(chunkname));
  if (st !== lua.LUA_OK) { const e = lua_tojsstring(L, -1); throw new Error("load " + chunkname + ": " + e); }
  if (lua.lua_pcall(L, 0, 1, 0) !== lua.LUA_OK) { const e = lua_tojsstring(L, -1); throw new Error("run " + chunkname + ": " + e); }
}

function getState() {
  if (_L) return _L;
  const L = lauxlib.luaL_newstate();
  lualib.luaL_openlibs(L);

  if (lauxlib.luaL_dostring(L, to_luastring(BOOTSTRAP)) !== lua.LUA_OK) {
    throw new Error("bootstrap: " + lua_tojsstring(L, -1));
  }

  // RPCSerializeBase.lua returns the Serializer table -> store as global.
  runBuffer(L, Buffer.from(baseSrc, "latin1"), "RPCSerializeBase.lua");
  lua.lua_setglobal(L, to_luastring("__BaseSerializer"));

  // RPCSerializeAuto.lua declares local Auto and ends with `return Auto`.
  runBuffer(L, Buffer.from(autoSrc, "latin1"), "RPCSerializeAuto.lua");
  lua.lua_setglobal(L, to_luastring("__Auto"));

  _L = L;
  return L;
}

// Convert a JS value into a Lua value on the stack.
function pushValue(L, v) {
  if (v === null || v === undefined) { lua.lua_pushnil(L); return; }
  const t = typeof v;
  if (t === "boolean") { lua.lua_pushboolean(L, v ? 1 : 0); return; }
  if (t === "number") {
    // Fengari's lua_Integer is 32-bit. Preserve exact larger integer values (our 64-bit
    // entity IDs are still safely below JS 2^53) as Lua numbers; WriteUInt64 serializes
    // them byte-by-byte and never truncates through a 32-bit integer API.
    if (Number.isInteger(v) && v >= -2147483648 && v <= 2147483647) lua.lua_pushinteger(L, v);
    else lua.lua_pushnumber(L, v);
    return;
  }
  if (t === "bigint") {
    const n = Number(v);
    if (!Number.isSafeInteger(n)) throw new Error("BigInt exceeds exact JS safe-integer range");
    if (n >= -2147483648 && n <= 2147483647) lua.lua_pushinteger(L, n); else lua.lua_pushnumber(L, n);
    return;
  }
  if (t === "string") { lua.lua_pushstring(L, to_luastring(v)); return; }
  if (Array.isArray(v)) {
    lua.lua_createtable(L, v.length, 1);
    for (let i = 0; i < v.length; i++) {
      pushValue(L, v[i]);
      lua.lua_rawseti(L, -2, i + 1); // 1-based array
    }
    // Set explicit .Count so WriteList uses `val.Count` and never the fragile
    // (badly-decompiled) counter() fallback. WriteList does:
    //   local num = length or val.Count or counter(val)
    lua.lua_pushstring(L, to_luastring("Count"));
    lua.lua_pushinteger(L, v.length);
    lua.lua_rawset(L, -3);
    return;
  }
  if (t === "object") {
    lua.lua_createtable(L, 0, 0);
    for (const k of Object.keys(v)) {
      // numeric dict keys -> integer keys
      const nk = Number(k);
      if (k !== "" && Number.isInteger(nk) && String(nk) === k) {
        pushValue(L, v[k]);
        lua.lua_rawseti(L, -2, nk);
      } else {
        lua.lua_pushstring(L, to_luastring(k));
        pushValue(L, v[k]);
        lua.lua_rawset(L, -3);
      }
    }
    return;
  }
  lua.lua_pushnil(L);
}

// Serialize: call Auto.<writeFnName>(writer, obj) and return Buffer.
// Mode "complex": wrap with present marker via Base.WriteComplex semantics?
// The RPC payload for a notify is the raw struct WITHOUT outer marker? We test
// both; default writes the object via the Auto fn directly (fields only) which
// is what a top-level Write<Type> produces.
function serialize(writeFnName, obj) {
  const L = getState();
  const top = lua.lua_gettop(L);
  // build: local w = __new_writer(); __Auto.<fn>(w, obj); return w:tostring()
  // We'll do it via stack ops.
  lua.lua_getglobal(L, to_luastring("__new_writer"));
  if (lua.lua_pcall(L, 0, 1, 0) !== lua.LUA_OK) {
    const e = lua_tojsstring(L, -1); lua.lua_settop(L, top); throw new Error("new_writer: " + e);
  }
  // writer at -1; keep a copy
  const writerIdx = lua.lua_gettop(L);

  lua.lua_getglobal(L, to_luastring("__Auto"));
  lua.lua_getfield(L, -1, to_luastring(writeFnName));
  if (lua.lua_isnil(L, -1)) { lua.lua_settop(L, top); throw new Error("no Auto." + writeFnName); }
  // stack: writer, Auto, fn  -> need fn(writer, obj)
  lua.lua_pushvalue(L, writerIdx); // writer
  pushValue(L, obj);               // obj
  if (lua.lua_pcall(L, 2, 0, 0) !== lua.LUA_OK) {
    const e = lua_tojsstring(L, -1); lua.lua_settop(L, top); throw new Error(writeFnName + ": " + e);
  }
  // call writer:tostring()
  lua.lua_pushvalue(L, writerIdx);
  lua.lua_getfield(L, -1, to_luastring("tostring"));
  lua.lua_pushvalue(L, writerIdx);
  if (lua.lua_pcall(L, 1, 1, 0) !== lua.LUA_OK) {
    const e = lua_tojsstring(L, -1); lua.lua_settop(L, top); throw new Error("tostring: " + e);
  }
  // result is a lua string (bytes). Read raw.
  const len = { value: 0 };
  const ptr = lua.lua_tolstring(L, -1, len);
  // fengari returns a Uint8Array via lua_tolstring? Use luaL helper
  let bytes;
  const s = lua.lua_tolstring(L, -1);
  bytes = Buffer.from(s); // s is Uint8Array of bytes
  lua.lua_settop(L, top);
  return bytes;
}

// ---- ref -> Write<TypeName> map, built from RPCDeserializeAuto.lua Meta tables ----
// Auto.Meta[ref] = { _type_name = "PlayerClientInfo" } -> writer fn "WritePlayerClientInfo".
const DESERIALIZE_AUTO = path.join(LUA_DIR, "RPCDeserializeAuto.lua");
const refToType = {};
{
  const dsrc = fs.readFileSync(DESERIALIZE_AUTO, "latin1");
  const re = /Auto\.Meta\[(\d+)\]\s*=\s*\{\s*_type_name\s*=\s*"([^"]+)"/g;
  let m; while ((m = re.exec(dsrc)) !== null) refToType[m[1]] = m[2];
}

// Serialize by reader-ref number (drop-in replacement for old RPC.serializeComplex).
function serializeComplexByRef(ref, obj) {
  const type = refToType[String(ref)];
  if (!type) throw new Error("no _type_name for ref " + ref);
  return serializeComplex("Write" + type, obj, type);
}

module.exports = { serialize, serializeComplex, serializeComplexByRef, refToType };

// Serialize WITH the outer present-marker, exactly as a real notify payload:
// Base.WriteComplex(writer, obj, Auto.<writeFnName>, name, false).
// The receiving reader does Base.ReadComplex(reader, Auto.Reader[N]) which reads
// that leading marker first, so this is the byte-accurate on-wire form.
function serializeComplex(writeFnName, obj, name) {
  const L = getState();
  const top = lua.lua_gettop(L);
  lua.lua_getglobal(L, to_luastring("__new_writer"));
  if (lua.lua_pcall(L, 0, 1, 0) !== lua.LUA_OK) { const e = lua_tojsstring(L, -1); lua.lua_settop(L, top); throw new Error("new_writer: " + e); }
  const writerIdx = lua.lua_gettop(L);

  // __BaseSerializer.WriteComplex(writer, obj, Auto.fn, name, false)
  lua.lua_getglobal(L, to_luastring("__BaseSerializer"));
  lua.lua_getfield(L, -1, to_luastring("WriteComplex"));
  if (lua.lua_isnil(L, -1)) { lua.lua_settop(L, top); throw new Error("no Base.WriteComplex"); }
  lua.lua_pushvalue(L, writerIdx);          // writer
  pushValue(L, obj);                        // val
  lua.lua_getglobal(L, to_luastring("__Auto"));
  lua.lua_getfield(L, -1, to_luastring(writeFnName));
  lua.lua_remove(L, -2);                    // drop __Auto, keep fn
  if (lua.lua_isnil(L, -1)) { lua.lua_settop(L, top); throw new Error("no Auto." + writeFnName); }
  lua.lua_pushstring(L, to_luastring(name || writeFnName)); // name
  lua.lua_pushboolean(L, 0);                // nullable=false
  if (lua.lua_pcall(L, 5, 0, 0) !== lua.LUA_OK) { const e = lua_tojsstring(L, -1); lua.lua_settop(L, top); throw new Error(writeFnName + ": " + e); }

  lua.lua_pushvalue(L, writerIdx);
  lua.lua_getfield(L, -1, to_luastring("tostring"));
  lua.lua_pushvalue(L, writerIdx);
  if (lua.lua_pcall(L, 1, 1, 0) !== lua.LUA_OK) { const e = lua_tojsstring(L, -1); lua.lua_settop(L, top); throw new Error("tostring: " + e); }
  const s = lua.lua_tolstring(L, -1);
  const bytes = Buffer.from(s);
  lua.lua_settop(L, top);
  return bytes;
}
