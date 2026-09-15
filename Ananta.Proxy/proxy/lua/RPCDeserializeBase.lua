-- Original chunk: @Lua\LuaFiles\LX6\Service\RPCDeserializeBase.lua
-- Decompiled from: 02186_RPCDeserializeBase.lua_49bd54ceeac5.luajit

local MidToName = require("LuaGen/AutoGen/RPCMethodIdToName")
local LogUtils = LX6.Utils.LogUtilsLua
local Serializer = uv0
local SerializeObjectMarkNull = 0

function Serializer.Dispatcher(ctx, br, mid)
	local reader = ctx.midToReader[mid]

	if not reader then
		return false
	end

	local handler = ctx.sidToImpl[math.floor(mid / 1000000)][ctx.midToName[mid]]

	if handler then
		local autoQaFunctions = L50.Gm.AutoQaFunctions

		if autoQaFunctions and (autoQaFunctions.IsRpcPrinting or autoQaFunctions.IsProtocolRpcTest or autoQaFunctions.IsRPCCollect) then
			local args = uv3
			args[MULTRES] = reader(br)

			if autoQaFunctions.IsRPCCollect then
				autoQaFunctions.SendRpcName(MidToName[mid], 1)
			end

			if autoQaFunctions.IsRpcPrinting and LX6.Engine.DebugRpcMgr.FilterRpc(MidToName[mid]) then
				local serviceName = UX.RPC.LuaRpcProcessor.GetMethodServiceName(mid)

				print_warn(gString.Format("[Lua rpc: %s->c] [%s] ", serviceName, MidToName[mid]), args)
				LogUtils.RecordRPC(gString.Format("[s->c] [%s].[%s] %s", serviceName, MidToName[mid], args))
			end

			if autoQaFunctions.IsProtocolRpcTest then
				local tmpArgs = MidToName

				for i = 1, #args do
					local v = args[i]

					if v == nil then
						tmpArgs[i] = "nil"
					elseif type(v) == "table" then
						tmpArgs[i] = table.tostring(v, false)
					else
						tmpArgs[i] = args[i]
					end
				end

				autoQaFunctions.OnSendProtocolLuaRPC(false, MidToName[mid], tmpArgs)
			end

			handler(unpack(args, 1, table.maxn(args)))

			return true
		end

		handler(reader(br))

		return true
	else
		return false
	end
end

function Serializer.ReturnMessageDeserializer(ctx, br, mid)
	local reader = ctx.midToReturnMessageReader[mid]

	if not reader then
		return
	end

	slot4 = uv3
	slot4[MULTRES] = reader(br)

	return slot4
end

function Serializer.ReadBuffer(reader)
	if reader:ReadByte() ~= SerializeObjectMarkNull then
		return reader:ReadBuffer()
	else
		return nil
	end
end

function Serializer.ReadBuffer7Bit(reader)
	if reader:ReadByte() ~= SerializeObjectMarkNull then
		return reader:ReadBuffer7Bit()
	else
		return nil
	end
end

function Serializer.ReadComplex(reader, nontrivial)
	local obj = SerializeObjectMarkNull
	local byte = reader:ReadByte()

	if byte ~= SerializeObjectMarkNull then
		nontrivial(reader, obj)
	else
		return nil
	end

	return obj
end

function Serializer.ReadStruct(reader, nontrivial)
	local obj = uv0

	nontrivial(reader, obj)

	return obj
end

function Serializer.ReadList(reader, itemReader)
	local byte = reader:ReadByte()

	if byte == SerializeObjectMarkNull then
		return nil
	end

	local size = reader:ReadInt32()
	local list = {
		Count = size,
		Length = size
	}

	for i = 1, size do
		list[i] = itemReader(reader)
	end

	return list
end

function Serializer.ReadList7Bit(reader, itemReader)
	local byte = reader:ReadByte()

	if byte == SerializeObjectMarkNull then
		return nil
	end

	local size = reader:ReadInt7Bit()
	local list = {
		Count = size,
		Length = size
	}

	for i = 1, size do
		list[i] = itemReader(reader)
	end

	return list
end

function Serializer.ReadDict(reader, keyReader, itemReader)
	if reader:ReadByte() == SerializeObjectMarkNull then
		return nil
	end

	local size = reader:ReadInt32()
	local dict = SerializeObjectMarkNull

	for i = 1, size do
		local key = keyReader(reader)
		dict[key] = itemReader(reader)
	end

	return dict
end

function Serializer.ReadDict7Bit(reader, keyReader, itemReader)
	if reader:ReadByte() == SerializeObjectMarkNull then
		return nil
	end

	local size = reader:ReadInt7Bit()
	local dict = SerializeObjectMarkNull

	for i = 1, size do
		local key = keyReader(reader)
		dict[key] = itemReader(reader)
	end

	return dict
end

return Serializer
