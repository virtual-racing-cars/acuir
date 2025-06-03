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

        self.laps = {}
        self.replayLapMarkers = {}
        self.timingGateTimes = {}

        self.leaderboardPosition = 0
        self.gapToCarAhead = 0
        self.gapToLeader = 0
        self.carAheadIndex = 0
        self.splinePositionLast = self.status.splinePosition

        -- if not session.laps[car.index][car.lapCount] and car.lapCount > 0 then
        --         session.laps[car.index][car.lapCount] = {
        --                 car.lapCount,
        --                 car.isLastLapValid,
        --                 ac.getTyresName(car.index, car.compoundIndex),
        --                 car.previousLapTimeMs or -1,
        --                 car.lastSplits[0] or -1,
        --                 car.lastSplits[1] or -1,
        --                 car.lastSplits[2] or -1,
        --                 car.previousLapTimeMs - car.bestLapTimeMs,
        --         }
        --         session.lapMarkers[car.index][car.lapCount] = sim.replayCurrentFrame
        --         session.timingGateIndexes[car.index] = 1
        -- end

        -- ac.onLapCompleted(self.index, function(carIndex, lapTime, valid, cuts, lapCount)
        --         self.laps[1][lapCount] =
        --                 lap(lapTime, valid, cuts, ac.getTyresName(self.index, self.status.compoundIndex))
        --         self.replayLapMarkers[1][lapCount] = sim.replayCurrentFrame
        -- end)

        return true
end

return Car
