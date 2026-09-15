-- Original chunk: @Lua\LuaFiles\LX6\Service\RPCSerializeBase.lua
-- Decompiled from: 00065_RPCSerializeBase.lua_87fc20cbb21f.luajit

local Serializer = uv0
local SerializeObjectMarkNull = 0
local SerializeObjectMarkCommon = 255

function Serializer.WritePrimitive(writer, val, nontrivial, default)
	if not val then
		nontrivial(writer, default)
	else
		nontrivial(writer, val)
	end
end

function Serializer.WriteStringWrap(nullable, name, limit)
	return function (writer, val)
		writer:WriteString(val, nullable, name, limit)
	end
end

function Serializer.WriteStruct(writer, val, nontrivial, name)
	if not val then
		print_error("[RPC] WriteStruct '" .. name .. "' = nil")
		nontrivial(writer, uv0)
	else
		nontrivial(writer, val)
	end
end

function Serializer.WriteStructWrap(nontrivial, name)
	return function (writer, val)
		Serializer.WriteStruct(writer, val, nontrivial, name)
	end
end

function Serializer.WriteBuffer(writer, val, name, nullable, limit, length)
	if not val then
		if nullable then
			writer:WriteByte(SerializeObjectMarkNull)
		else
			print_error("[RPC] WriteBuffer '" .. name .. "' = nil")
			writer:WriteByte(SerializeObjectMarkCommon)
			writer:WriteInt32(0)
		end

		return
	else
		writer:WriteByte(SerializeObjectMarkCommon)
		writer:WriteBuffer(val, length or -1, limit)
	end
end

function Serializer.WriteBuffer7Bit(writer, val, name, nullable, limit, length)
	if not val then
		if nullable then
			writer:WriteByte(SerializeObjectMarkNull)
		else
			print_error("[RPC] WriteBuffer '" .. name .. "' = nil")
			writer:WriteByte(SerializeObjectMarkCommon)
			writer:Write7BitEncodedInt(0)
		end

		return
	else
		writer:WriteByte(SerializeObjectMarkCommon)
		writer:WriteBuffer7Bit(val, length or -1, limit)
	end
end

function Serializer.WriteComplexWrap(nontrivial, name, nullable)
	return function (writer, val)
		Serializer.WriteComplex(writer, val, nontrivial, name, nullable)
	end
end

function Serializer.WriteComplex(writer, val, nontrivial, name, nullable)
	if not val then
		if nullable then
			writer:WriteByte(SerializeObjectMarkNull)
		else
			print_error("[RPC] WriteComplex '" .. name .. "' = nil")
			writer:WriteByte(SerializeObjectMarkCommon)
			nontrivial(writer, SerializeObjectMarkNull)
		end

		return
	else
		if type(val) == "userdata" then
			writer:WriteByte(SerializeObjectMarkCommon)
			nontrivial(writer, val)

			return
		end

		if not val._tp then
			writer:WriteByte(SerializeObjectMarkCommon)
		else
			writer:WriteByte(val._tp)
		end

		nontrivial(writer, val)
	end
end

function Serializer.WriteList(writer, val, itemWriter, default, name, nullable, limit, length)
	if not val then
		if nullable then
			writer:WriteByte(SerializeObjectMarkNull)
		else
			print_error("[RPC] WriteList '" .. name .. "' = nil")
			writer:WriteByte(SerializeObjectMarkCommon)
			writer:WriteInt32(0)
		end

		return
	else
		writer:WriteByte(SerializeObjectMarkCommon)
	end

	local function counter(val)
		local count = 0

		for n in pairs(val) do
			if count < n then
				count = n or count
			end
		end

		return count
	end

	local num = length or val.Count or counter(val)

	if limit > 0 and limit < num then
		error("[RPC] WriteList '" .. name .. "' exceed count=" .. num .. " limit=" .. limit)
	end

	writer:WriteInt32(num)

	if val.get_Item then
		for i = 0, num - 1 do
			local item = val:get_Item(i)

			if not item then
				itemWriter(writer, default)
			else
				itemWriter(writer, item)
			end
		end
	else
		for i = 1, num do
			local item = val[i]

			if not item then
				itemWriter(writer, default)
			else
				itemWriter(writer, item)
			end
		end
	end
end

function Serializer.WriteList7Bit(writer, val, itemWriter, default, name, nullable, limit, length)
	if not val then
		if nullable then
			writer:WriteByte(SerializeObjectMarkNull)
		else
			print_error("[RPC] WriteList '" .. name .. "' = nil")
			writer:WriteByte(SerializeObjectMarkCommon)
			writer:Write7BitEncodedInt(0)
		end

		return
	else
		writer:WriteByte(SerializeObjectMarkCommon)
	end

	local function counter(val)
		local count = 0

		for n in pairs(val) do
			if count < n then
				count = n or count
			end
		end

		return count
	end

	local num = length or val.Count or counter(val)

	if limit > 0 and limit < num then
		error("[RPC] WriteList '" .. name .. "' exceed count=" .. num .. " limit=" .. limit)
	end

	writer:Write7BitEncodedInt(num)

	if val.get_Item then
		for i = 0, num - 1 do
			local item = val:get_Item(i)

			if not item then
				itemWriter(writer, default)
			else
				itemWriter(writer, item)
			end
		end
	else
		for i = 1, num do
			local item = val[i]

			if not item then
				itemWriter(writer, default)
			else
				itemWriter(writer, item)
			end
		end
	end
end

function Serializer.WriteDict(writer, val, keyWriter, itemWriter, default, name, nullable, limit)
	if not val then
		if nullable then
			writer:WriteByte(SerializeObjectMarkNull)
		else
			print_error("[RPC] WriteDict '" .. name .. "' = nil")
			writer:WriteByte(SerializeObjectMarkCommon)
			writer:WriteInt32(0)
		end

		return
	else
		writer:WriteByte(SerializeObjectMarkCommon)
	end

	local count = 0

	for n in pairs(val) do
		count = count + 1
	end

	if limit > 0 and limit < count then
		error("[RPC] WriteDict '" .. name .. "' exceed count=" .. count .. " limit=" .. limit)
	end

	writer:WriteInt32(count)

	for k, v in pairs(val) do
		keyWriter(writer, k)

		if not v then
			itemWriter(writer, default)
		else
			itemWriter(writer, v)
		end
	end
end

function Serializer.WriteDict7Bit(writer, val, keyWriter, itemWriter, default, name, nullable, limit)
	if not val then
		if nullable then
			writer:WriteByte(SerializeObjectMarkNull)
		else
			print_error("[RPC] WriteDict '" .. name .. "' = nil")
			writer:WriteByte(SerializeObjectMarkCommon)
			writer:Write7BitEncodedInt(0)
		end

		return
	else
		writer:WriteByte(SerializeObjectMarkCommon)
	end

	local count = 0

	for n in pairs(val) do
		count = count + 1
	end

	if limit > 0 and limit < count then
		error("[RPC] WriteDict '" .. name .. "' exceed count=" .. count .. " limit=" .. limit)
	end

	writer:Write7BitEncodedInt(count)

	for k, v in pairs(val) do
		keyWriter(writer, k)

		if not v then
			itemWriter(writer, default)
		else
			itemWriter(writer, v)
		end
	end
end

function Serializer.CheckEnum(value, typeName, defaultVal)
	local enumDef = EnumCheck[typeName]

	for _, v in pairs(enumDef) do
		if v == value then
			return value
		end
	end

	print_error("[RPC] enum out of range " .. enumDef .. "=" .. value)

	return defaultVal
end

return Serializer
