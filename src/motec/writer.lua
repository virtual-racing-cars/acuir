local car = ac.getCar(0)
local sim = ac.getSim()

local sqlite3 = require("shared/utils/sqlite")
require("src\\motec\\ld")
require("src\\motec\\ldx")

local args = { ... } -- Command line arguments

-- Define the output path
local out_path = "logs/ams2"

-- Define session states
local sessionstates = {
	[1] = "Practice",
	[2] = "Test",
	[3] = "Qualify",
	[4] = "Race",
	[5] = "Race",
	[6] = "Time Trial",
}

-- Define channel information
local channels = {
	gear = {
		id = 50078,
		datatype = 3,
		datasize = 2,
		freq = 20,
		shift = 0,
		multiplier = 1,
		scale = 1,
		decplaces = 0,
		name = "Gear",
		shortname = "Gear",
		units = "",
	},
	throttle = {
		id = 50014,
		datatype = 3,
		datasize = 2,
		freq = 20,
		shift = 0,
		multiplier = 1,
		scale = 1,
		decplaces = 0,
		name = "Throttle Pos",
		shortname = "Thr Pos",
		units = "%",
	},
	brake = {
		id = 10001,
		datatype = 3,
		datasize = 2,
		freq = 20,
		shift = 0,
		multiplier = 1,
		scale = 1,
		decplaces = 0,
		name = "Brake Pos",
		shortname = "Brk Pos",
		units = "%",
	},
	steer = {
		id = 50018,
		datatype = 3,
		datasize = 2,
		freq = 20,
		shift = 0,
		multiplier = 1,
		scale = 1,
		decplaces = 2,
		name = "Steered Angle",
		shortname = "Str Ang",
		units = "deg",
	},
	speed = {
		id = 10000,
		datatype = 3,
		datasize = 2,
		freq = 20,
		shift = 0,
		multiplier = 1,
		scale = 1,
		decplaces = 0,
		name = "Ground Speed",
		shortname = "Gnd Spd",
		units = "mph",
	},
	z = {
		id = 10002,
		datatype = 7,
		datasize = 4,
		freq = 20,
		shift = 0,
		multiplier = 1,
		scale = 1,
		decplaces = 0,
		name = "GPS Latitude",
		shortname = "GPSLat",
		units = "deg",
	},
	x = {
		id = 10003,
		datatype = 7,
		datasize = 4,
		freq = 20,
		shift = 0,
		multiplier = 1,
		scale = 1,
		decplaces = 0,
		name = "GPS Longitude",
		shortname = "GPSLong",
		units = "deg",
	},
}

-- Connect to the SQLite database
local db = sqlite3.open(args[1])
local stmt = db:prepare("SELECT * FROM samples")
local row = stmt:step()

-- Initialize variables
local lastlap = nil
local freq = 1 / 20
local lap_samples = 0
local started = false

local log = nil
local logx = MotecLogExtra()

-- Iterate through database records
while row == sqlite3.ROW do
	if not log then
		-- Create the log files
		local now = os.date("%Y-%m-%d %H:%M:%S")
		local past = os.date("%Y-%m-%d %H:%M:%S")

		local session = sessionstates[p.mSessionState] or past

		local event = MotecEvent({
			name = args[2],
			session = session,
			comment = "converted by ams2dump-to-motec at " .. now,
			venuepos = 0,
		})

		log = MotecLog({
			date = past,
			time = past,
			car = ac.getCarName(0),
			vehicle = ac.getCarID(0),
			venue = ac.getTrackName(),
			comment = "converted by ams2dump-to-motec at " .. now,
			event = event,
		})

		for _, c in pairs(channels) do
			print("Creating channel: " .. c.name)
			log:add_channel(c)
		end
	end

	if lastlap == nil then
		lastlap = car.lapCount
	end

	if car.lapCount ~= lastlap then
		-- Figure out the lap times
		local sampletime = lap_samples * freq
		local laptime = (car.previousLapTimeMs > 0) and car.previousLapTimeMs or sampletime

		logx:add_lap(laptime)
		print(
			"Adding lap "
				.. lastlap
				.. ", laptime: "
				.. laptime
				.. ", samples: "
				.. lap_samples
				.. ", sampletime: "
				.. sampletime
		)
		lap_samples = 0
	else
		lap_samples = lap_samples + 1
	end

	lastlap = car.lapCount

	-- Do some conversions
	local lat, long = 0, 0

	log:add_samples({
		car.gear,
		car.gas * 100,
		car.brake * 100,
		car.steer,
		car.speedKmh,
		lat,
		long,
	})

	::continue::
	row = stmt:step()
end

db:close()

os.execute("mkdir -p " .. out_path)

-- Write the ldx file
local ldxfilename = out_path .. "/" .. args[2] .. ".ldx"
print("Writing laptimes to " .. ldxfilename)
local ldxfile = io.open(ldxfilename, "w")
ldxfile:write(logx:to_string())
ldxfile:close()

-- Write the log file
local ldfilename = out_path .. "/" .. args[2] .. ".ld"
print("Writing MoTeC log to " .. ldfilename)
local ldfile = io.open(ldfilename, "wb")
ldfile:write(log:to_string())
ldfile:close()
