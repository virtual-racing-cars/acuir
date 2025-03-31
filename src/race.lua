local app = require("app")

local sim = ac.getSim()

local session = {
        lapMarkers = {},
        lapTimes = {},
        leaderboardGaps = {},
        trackGaps = {},
        intervals = {},
        timingGates = {},
        timingGateTimes = {},
        timingGateIndexes = {},
}

local trackLegnth = 1 / sim.trackLengthM * 50

local timingGateCount = 0
for i = 0, 1, trackLegnth do
        timingGateCount = timingGateCount + 1
        session.timingGates[timingGateCount] = i
end

--
function session:step()
        local carAheadIndex = -1

        for pos, car in ac.iterateCars.leaderboard() do
                if not session.lapMarkers[car.index] then session.lapMarkers[car.index] = {} end
                if not session.lapTimes[car.index] then session.lapTimes[car.index] = {} end
                if not session.timingGateIndexes[car.index] then session.timingGateIndexes[car.index] = 1 end
                if not session.timingGateTimes["trackPos"] then session.timingGateTimes["trackPos"] = {} end
                if not session.timingGateTimes[car.index] then session.timingGateTimes[car.index] = {} end
                if not session.timingGateTimes[carAheadIndex] then session.timingGateTimes[carAheadIndex] = {} end

                if not session.lapTimes[car.index][car.lapCount] then
                        session.lapTimes[car.index][car.lapCount] = car.previousLapTimeMs
                        session.lapMarkers[car.index][car.lapCount] = sim.replayCurrentFrame
                        session.timingGateIndexes[car.index] = 1
                end

                for gate = session.timingGateIndexes[car.index], timingGateCount do
                        if car.splinePosition >= session.timingGates[gate] then
                                session.timingGateIndexes[car.index] = gate < timingGateCount and gate + 1 or 1
                                local time = sim.currentSessionTime
                                local lastLeaderboardTime = session.timingGateTimes[carAheadIndex][gate] or time
                                local lastTime = session.timingGateTimes.trackPos[gate] or time
                                local leaderboardGap = time - lastLeaderboardTime
                                local gap = time - lastTime
                                local prevInterval = session.intervals[carAheadIndex] or 0
                                session.leaderboardGaps[car.index] = leaderboardGap
                                session.trackGaps[car.index] = gap
                                session.intervals[car.index] = prevInterval + leaderboardGap
                                session.timingGateTimes.trackPos[gate] = time
                                session.timingGateTimes[car.index][gate] = time
                                goto continue
                        end
                end

                ::continue::

                if pos == 1 then
                        session.intervals[car.index] = 0
                        session.leaderboardGaps[car.index] = 0
                end

                carAheadIndex = car.index
        end
end

return session
