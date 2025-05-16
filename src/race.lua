local sim = ac.getSim()

local session = {
        lapMarkers = {},
        lapTimes = {},
        leaderboard = table.new(sim.carsCount, 0),
        leaderboardPositions = table.new(sim.carsCount, 0),
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
        for i = 0, #ac.getSession(sim.currentSessionIndex).leaderboard - 1 do
                local leaderboardSlot = ac.getSession(sim.currentSessionIndex).leaderboard[i]
                session.leaderboard[i + 1] = leaderboardSlot
                session.leaderboardPositions[leaderboardSlot.car.index] = i + 1
        end

        local carAheadIndex = -1

        for pos, slot in ipairs(session.leaderboard) do
                local car = slot.car

                if pos > 1 and sim.raceSessionType ~= ac.SessionType.Race then
                        if slot.bestLapTimeMs > 0 then
                                session.intervals[car.index] = slot.bestLapTimeMs - session.leaderboard[1].bestLapTimeMs
                                session.leaderboardGaps[car.index] = slot.bestLapTimeMs
                                        - session.leaderboard[pos - 1].bestLapTimeMs
                        end

                        goto continue
                end

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
