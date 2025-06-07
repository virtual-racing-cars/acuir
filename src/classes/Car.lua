local lap = require("src.classes.Lap")
local sim = ac.getSim()

local trackLegnth = 1 / sim.trackLengthM * 50

-- local timingGateCount = 0
-- for i = 0, 1, trackLegnth do
--         timingGateCount = timingGateCount + 1
--         session.timingGates[timingGateCount] = i
-- end

local Car = class("Car")

function Car:initialize(carIndex)
        self.index = carIndex
        self.status = ac.getCar(self.index)

        if not self.status then return false end

        self.slot = nil
        self.laps = {}
        self.replayLapMarkers = {}
        self.timingGateTimes = {}

        self.leaderboardPosition = 0
        self.gapToLeader = 0
        self.gapToCarAheadLeaderboard = 0
        self.gapToCarAheadTrack = 0

        self.lapsToLeader = 0
        self.lapsToCarAheadLeaderboard = 0

        self.carAheadIndex = 0
        self.splinePositionLast = self.status.splinePosition

        self.previousLapDelta = 0
        self.bestLapDelta = 0

        self.bestLapTimeMs = 0

        self.isDisconnected = true

        return true
end

return Car
