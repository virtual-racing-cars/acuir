-- Import the required struct functions
local struct = require("struct")

-- Define the MotecStruct class
local MotecStruct = {}

function MotecStruct:new(fields)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.fmt = "<" .. table.concat(fields, "")
	o.size = struct.size(o.fmt)
	o.fields = fields
	return o
end

function MotecStruct:unpack(data, pad)
	local tup = { struct.unpack(self.fmt, data) }
	local d = {}

	for idx, val in ipairs(tup) do
		local fmt, key = unpack(self.fields[idx])

		if pad and not key then
			key = "pad" .. idx
			val = struct.pack("H", val)
		elseif key and fmt:sub(-1) == "s" then
			val = val:sub(1, val:find("\0") - 1)
		end

		if key then
			d[key] = val
		end
	end

	return d
end

function MotecStruct:pack(state)
	local values = {}

	for idx, field in ipairs(self.fields) do
		local fmt, key = unpack(field)

		if not key then
			key = "pad" .. idx
			values[#values + 1] = state[key] and struct.pack("H", tonumber(state[key], 16)) or ""
		elseif fmt:sub(-1) == "s" then
			values[#values + 1] = state[key]
		else
			values[#values + 1] = state[key]
		end
	end

	return struct.pack(self.fmt, unpack(values))
end

-- Define the MotecBase class
local MotecBase = {}

function MotecBase:new(state)
	local o = state or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function MotecBase:from_string(data, start, pad)
	local pkt = data:sub(start + 1, start + self.header.size)
	local state = self.header:unpack(pkt, pad)
	state._start = start
	return self:new(state)
end

function MotecBase:to_string()
	return self.header:pack(self)
end

-- Define the MotecEvent class
local MotecEvent = MotecBase:new()

MotecEvent.header = ac.StructItem.struct({
	{ ac.StructItem.string(), "name" },
	{ ac.StructItem.string(), "session" },
	{ ac.StructItem.string(), "comment" },
	{ ac.StructItem.uint16(), "venuepos" },
})

-- Define the MotecSamples class
local MotecSamples = MotecBase:new()

MotecSamples.datatypes = {
	[0x0000] = { [0x0001] = ac.StructItem.byte(), [0x0002] = ac.StructItem.int16(), [0x0004] = ac.StructItem.int32() },
	[0x0003] = { [0x0001] = ac.StructItem.byte(), [0x0002] = ac.StructItem.int16(), [0x0004] = ac.StructItem.int32() },
	[0x0005] = { [0x0001] = ac.StructItem.byte(), [0x0002] = ac.StructItem.int16(), [0x0004] = ac.StructItem.int32() },
	[0x0007] = { [0x0002] = ac.StructItem.float(), [0x0004] = ac.StructItem.float() },
}

MotecSamples.converttypes = {
	[0x0000] = tonumber,
	[0x0003] = tonumber,
	[0x0005] = tonumber,
	[0x0007] = tonumber,
}

function MotecSamples:new(channel, samples)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.samples = samples or {}

	if channel then
		o.channel = channel
		o.fmt = self.datatypes[channel.datatype][channel.datasize]
		o.convert = self.converttypes[channel.datatype]
		o.datasize = struct.size(o.fmt)
		o.multiplier = channel.multiplier
		o.shift = channel.shift
		o.scale = channel.scale
		o.decplaces = channel.decplaces
	end

	return o
end

function MotecSamples:add_sample(sample)
	table.insert(self.samples, sample)
end

function MotecSamples:to_string()
	local data = {}

	for _, v in ipairs(self.samples) do
		local val = ((v / self.multiplier) - self.shift) * self.scale / (10 ^ -self.decplaces)
		val = self.convert(val)
		table.insert(data, struct.pack(self.fmt, val))
	end

	return table.concat(data)
end

-- Define the MotecChannel class
local MotecChannel = MotecBase:new()

MotecChannel.header = ac.StructItem.struct({
	{ ac.StructItem.uint32(), "prevpos" },
	{ ac.StructItem.uint32(), "nextpos" },
	{ ac.StructItem.uint32(), "datapos" },
	{ ac.StructItem.uint32(), "numsamples" },
	{ ac.StructItem.uint16(), "id" },
	{ ac.StructItem.uint16(), "datatype" },
	{ ac.StructItem.uint16(), "datasize" },
	{ ac.StructItem.uint16(), "freq" },
	{ ac.StructItem.int16(), "shift" },
	{ ac.StructItem.int16(), "multiplier" },
	{ ac.StructItem.int16(), "scale" },
	{ ac.StructItem.int16(), "decplaces" },
	{ ac.StructItem.string(), "name" },
	{ ac.StructItem.string(), "shortname" },
	{ ac.StructItem.string(), "units" },
	{ ac.StructItem.string(), nil },
})

function MotecChannel:new(state)
	local o = MotecBase.new(self, state)
	o.samples = MotecSamples:new(o)
	return o
end

function MotecChannel:from_string(data, start, pad)
	local channel = MotecBase.from_string(self, data, start, pad)
	channel.samples = MotecSamples:from_string(data, channel)
	return channel
end

-- Define the MotecLog class
local MotecLog = MotecBase:new()

MotecLog.header = ac.StructItem.struct({
	{ ac.StructItem.uint32(), "id" },
	{ ac.StructItem.char(4), nil },
	{ ac.StructItem.uint32(), "firstchannelpos" },
	{ ac.StructItem.uint32(), "firstchanneldatapos" },
	{ ac.StructItem.char(20), nil },
	{ ac.StructItem.uint32(), "eventpos" },
	{ ac.StructItem.char(26), nil },
	{ ac.StructItem.uint32(), "sig1" },
	{ ac.StructItem.uint32(), "serial" },
	{ ac.StructItem.char(8), "type" },
	{ ac.StructItem.uint16(), "version" },
	{ ac.StructItem.uint16(), "sig2" },
	{ ac.StructItem.uint32(), "numchannels" },
	{ ac.StructItem.char(4), nil },
	{ ac.StructItem.char(16), "date" },
	{ ac.StructItem.char(16), nil },
	{ ac.StructItem.char(16), "time" },
	{ ac.StructItem.char(16), nil },
	{ ac.StructItem.char(64), "driver" },
	{ ac.StructItem.char(64), "vehicle" },
	{ ac.StructItem.char(64), nil },
	{ ac.StructItem.char(64), "venue" },
	{ ac.StructItem.char(1088), nil },
	{ ac.StructItem.char(4), nil },
	{ ac.StructItem.char(66), nil },
	{ ac.StructItem.char(64), "comment" },
	{ ac.StructItem.char(126), nil },
})

function MotecLog:new(state)
	local o = MotecBase.new(self, state)
	o.channels = {}
	o.numchannels = 0
	return o
end

function MotecLog:from_string(data, pad)
	local log = MotecBase.from_string(self, data, 0, pad)

	if log.eventpos > 0 then
		log.event = MotecEvent:from_string(data, log.eventpos, pad)
	end

	log.channels = {}
	local channelpos = log.firstchannelpos

	while channelpos > 0 do
		local channel = MotecChannel:from_string(data, channelpos, pad)
		table.insert(log.channels, channel)
		channelpos = channel.nextpos
	end

	return log
end

function MotecLog:to_string()
	local data = {}

	local eventpos = 0
	local nextpos = self.header.size

	if self.event then
		eventpos = nextpos
		nextpos = nextpos + self.event.header.size
		table.insert(data, self.event:to_string())
	end

	self.eventpos = eventpos
	self.firstchanneldatapos = 0
	self.firstchannelpos = 0

	if self.numchannels > 0 then
		local datapos = nextpos + (#self.channels * MotecChannel.header.size)
		self.firstchannelpos = nextpos
		self.firstchanneldatapos = datapos
		local prevpos = 0
		local thispos = nextpos

		for idx, ci in ipairs(self.channels) do
			if idx < self.numchannels then
				ci.nextpos = thispos + MotecChannel.header.size
			else
				ci.nextpos = 0
			end

			ci.prevpos = prevpos
			ci.datapos = datapos
			table.insert(data, ci:to_string())

			local samples = ci.samples:to_string()
			table.insert(data, samples)

			datapos = datapos + #samples
			prevpos = thispos
			thispos = ci.nextpos
		end
	end

	table.insert(data, 1, self.header:pack(self))
	return table.concat(data)
end

return {
	MotecStruct = MotecStruct,
	MotecBase = MotecBase,
	MotecEvent = MotecEvent,
	MotecSamples = MotecSamples,
	MotecChannel = MotecChannel,
	MotecLog = MotecLog,
}
