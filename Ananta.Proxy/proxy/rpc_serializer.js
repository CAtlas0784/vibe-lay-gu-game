// rpc_serializer.js
// Schema-driven serializer that mirrors the client's RPCSerializeBase.lua
// exactly. The offline server fills plain JS objects; this turns them into
// the wire bytes the client expects. No hand-built byte buffers.
//
// Marker convention (from RPCSerializeBase.lua):
//   SerializeObjectMarkNull   = 0x00
//   SerializeObjectMarkCommon = 0xFF
//   WriteComplex(null,nullable) -> writes 0x00 ; present -> 0xFF + fields
//   WriteList(null,nullable)    -> 0x00 ; present -> 0xFF + int32 count + items
//   WriteStruct                 -> NO marker, fields written directly
//   WriteBuffer(null,nullable)  -> 0x00 ; present -> 0xFF + buffer
//
// A "schema" is the field list extracted from the client's Reader[N].
// Each field: {name, kind, op?, ref?, item?}
//   kind: prim | struct | complex | buffer | list | dict

const fs = require("fs");

class Writer {
  constructor() { this.chunks = []; }
  _push(b) { this.chunks.push(b); }
  WriteByte(v) { const b = Buffer.alloc(1); b.writeUInt8(v & 0xff, 0); this._push(b); }
  WriteBoolean(v) { this.WriteByte(v ? 1 : 0); }
  WriteInt16(v) { const b = Buffer.alloc(2); b.writeInt16LE(v | 0, 0); this._push(b); }
  WriteUInt16(v) { const b = Buffer.alloc(2); b.writeUInt16LE(v & 0xffff, 0); this._push(b); }
  WriteInt32(v) { const b = Buffer.alloc(4); b.writeInt32LE(v | 0, 0); this._push(b); }
  WriteUInt32(v) { const b = Buffer.alloc(4); b.writeUInt32LE(v >>> 0, 0); this._push(b); }
  WriteInt64(v) { const b = Buffer.alloc(8); b.writeBigInt64LE(BigInt(v || 0), 0); this._push(b); }
  WriteUInt64(v) { const b = Buffer.alloc(8); b.writeBigUInt64LE(BigInt(v || 0), 0); this._push(b); }
  WriteSingle(v) { const b = Buffer.alloc(4); b.writeFloatLE(v || 0, 0); this._push(b); }
  WriteDouble(v) { const b = Buffer.alloc(8); b.writeDoubleLE(v || 0, 0); this._push(b); }
  WriteString(v) {
    // client string format: byte present-marker + int32 length + utf8 bytes
    if (v === null || v === undefined) { this.WriteByte(0x00); return; }
    const s = Buffer.from(String(v), "utf8");
    this.WriteByte(0xFF);
    this.WriteInt32(s.length);
    this._push(s);
  }
  WriteRawBuffer(buf) { this._push(Buffer.from(buf)); }
  toBuffer() { return Buffer.concat(this.chunks); }
}

const PRIM = {
  ReadByte: "WriteByte", ReadBoolean: "WriteBoolean",
  ReadInt16: "WriteInt16", ReadUInt16: "WriteUInt16",
  ReadInt32: "WriteInt32", ReadUInt32: "WriteUInt32",
  ReadInt64: "WriteInt64", ReadUInt64: "WriteUInt64",
  ReadSingle: "WriteSingle", ReadDouble: "WriteDouble",
  ReadString: "WriteString",
};

const PRIM_DEFAULT = {
  WriteByte: 0, WriteBoolean: false, WriteInt16: 0, WriteUInt16: 0,
  WriteInt32: 0, WriteUInt32: 0, WriteInt64: 0, WriteUInt64: 0,
  WriteSingle: 0, WriteDouble: 0, WriteString: null,
};

class RpcSerializer {
  constructor(schemaPath) {
    const j = JSON.parse(fs.readFileSync(schemaPath, "utf8"));
    this.schemas = j.schemas;
    this.midToReader = j.midToReader;
    this.midToName = j.midToName;
  }

  // write one primitive
  _writePrim(w, op, val) {
    const fn = PRIM[op];
    if (!fn) throw new Error("unknown prim op " + op);
    if (val === undefined) val = PRIM_DEFAULT[fn];
    w[fn](val);
  }

  // write a struct (NO marker) by schema ref
  _writeStruct(w, ref, val) {
    const fields = this.schemas[ref] || [];
    const obj = val || {};
    for (const f of fields) this._writeField(w, f, obj[f.name]);
  }

  // write a complex (nullable, has marker) by schema ref
  _writeComplex(w, ref, val) {
    if (val === null || val === undefined) { w.WriteByte(0x00); return; }
    w.WriteByte(0xFF);
    const fields = this.schemas[ref] || [];
    for (const f of fields) this._writeField(w, f, val[f.name]);
  }

  _writeList(w, item, val) {
    if (val === null || val === undefined) { w.WriteByte(0x00); return; }
    w.WriteByte(0xFF);
    const arr = Array.isArray(val) ? val : [];
    w.WriteInt32(arr.length);
    for (const el of arr) this._writeItem(w, item, el);
  }

  _writeItem(w, item, val) {
    if (item.kind === "prim") this._writePrim(w, item.op, val);
    else if (item.kind === "struct") this._writeStruct(w, item.ref, val);
    else if (item.kind === "complex") this._writeComplex(w, item.ref, val);
    else throw new Error("unknown list item kind " + item.kind);
  }

  _writeField(w, f, val) {
    switch (f.kind) {
      case "prim":    this._writePrim(w, f.op, val); break;
      case "struct":  this._writeStruct(w, f.ref, val); break;
      case "complex": this._writeComplex(w, f.ref, val); break;
      case "buffer":
        if (val === null || val === undefined) { w.WriteByte(0x00); }
        else { w.WriteByte(0xFF); w.WriteInt32(val.length); w.WriteRawBuffer(val); }
        break;
      case "list":    this._writeList(w, f.item, val); break;
      case "dict":
        // dict serialized like list: null=0x00 ; present=0xFF + int32 count + pairs
        if (val === null || val === undefined) { w.WriteByte(0x00); }
        else { w.WriteByte(0xFF); w.WriteInt32(0); } // empty dict baseline
        break;
      default: throw new Error("unknown field kind " + f.kind);
    }
  }

  // Serialize a top-level struct (by reader ref) into a complex payload
  // (with the leading present marker), e.g. EnterSceneInfo = ref "53".
  serializeComplex(ref, obj) {
    const w = new Writer();
    this._writeComplex(w, ref, obj);
    return w.toBuffer();
  }

  // Build a fully-PRESENT default object for a complex schema ref. Every field
  // is materialised so the client never dereferences a nil:
  //   prim   -> 0 / false / "" default
  //   struct -> recurse
  //   complex-> recurse (present, never null)
  //   list   -> [] (present empty list, NOT null)
  //   dict   -> {} (present empty dict, NOT null)
  //   buffer -> null (ReadBuffer tolerates absent)
  // A real server sends a fresh player exactly like this - no null sub-objects.
  // `overrides` lets callers set real values on specific top-level fields.
  // `_depth` guards against cyclic schemas.
  autoDefault(ref, overrides, _depth) {
    _depth = _depth || 0;
    const fields = this.schemas[ref];
    if (!fields || _depth > 24) return {};
    const out = {};
    for (const f of fields) {
      if (overrides && Object.prototype.hasOwnProperty.call(overrides, f.name)) {
        out[f.name] = overrides[f.name];
        continue;
      }
      switch (f.kind) {
        case "prim":
          out[f.name] = (f.op === "ReadBoolean") ? false
                       : (f.op === "ReadString") ? null
                       : 0;
          break;
        case "struct":  out[f.name] = this.autoDefault(f.ref, null, _depth + 1); break;
        case "complex": out[f.name] = this.autoDefault(f.ref, null, _depth + 1); break;
        case "list":    out[f.name] = []; break;
        case "dict":    out[f.name] = {}; break;
        case "buffer":  out[f.name] = null; break;
        default:        out[f.name] = null;
      }
    }
    return out;
  }

  // Serialize a struct without the outer marker.
  serializeStruct(ref, obj) {
    const w = new Writer();
    this._writeStruct(w, ref, obj);
    return w.toBuffer();
  }
}

module.exports = { RpcSerializer, Writer };
