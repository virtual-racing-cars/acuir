local sim = ac.getSim()

local session = {
        lapMarkers = {},
        laps = {},
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

function session:getLeaderboardPosition(index) return session.leaderboardPositions[index] end

function session:step()
        for i = 0, #ac.getSession(sim.currentSessionIndex).leaderboard - 1 do
                local leaderboardSlot = ac.getSession(sim.currentSessionIndex).leaderboard[i]
                session.leaderboard[i + 1] = leaderboardSlot
                session.leaderboardPositions[leaderboardSlot.car.index] = i + 1
        end

        if sim.raceSessionType == ac.SessionType.Race then
                table.sort(session.leaderboard, function(a, b)
                        if b == nil then return false end
                        if a == nil then return false end
                        if a.car.isRetired then return false end
                        if b.car.isRetired then return true end
                        if not a.car.isConnected then return false end
                        if not b.car.isConnected then return true end

                        if not sim.isSessionStarted then
                                return ac.getDriverName(a.car.index) < ac.getDriverName(b.car.index)
                        end

                        if a.hasCompletedLastLap and b.hasCompletedLastLap then
                                return session.leaderboardPositions[a.car.index]
                                        < session.leaderboardPositions[b.car.index]
                        end

                        if a.laps <= b.laps then
                                if a.car.isInPitlane then return false end
                                if b.car.isInPitlane then return true end
                        end

                        return a.laps + a.car.splinePosition > b.laps + b.car.splinePosition
                end)
        end

        local carAheadIndex = -1

        for pos, slot in ipairs(session.leaderboard) do
                local car = slot.car

                session.leaderboardPositions[car.index] = pos

                if pos > 1 and sim.raceSessionType ~= ac.SessionType.Race then
                        if slot.bestLapTimeMs > 0 then
                                session.intervals[car.index] = slot.bestLapTimeMs - session.leaderboard[1].bestLapTimeMs
                                session.leaderboardGaps[car.index] = slot.bestLapTimeMs
                                        - session.leaderboard[pos - 1].bestLapTimeMs
                        end

                        goto continue
                end

                if not session.lapMarkers[car.index] then session.lapMarkers[car.index] = {} end
                if not session.laps[car.index] then session.laps[car.index] = {} end
                if not session.timingGateIndexes[car.index] then session.timingGateIndexes[car.index] = 1 end
                if not session.timingGateTimes["trackPos"] then session.timingGateTimes["trackPos"] = {} end
                if not session.timingGateTimes[car.index] then session.timingGateTimes[car.index] = {} end
                if not session.timingGateTimes[carAheadIndex] then session.timingGateTimes[carAheadIndex] = {} end

                if not session.laps[car.index][car.lapCount] and car.lapCount > 0 then
                        session.laps[car.index][car.lapCount] = {
                                car.lapCount,
                                car.isLastLapValid,
                                ac.getTyresName(car.index, car.compoundIndex),
                                car.previousLapTimeMs or -1,
                                car.lastSplits[0] or -1,
                                car.lastSplits[1] or -1,
                                car.lastSplits[2] or -1,
                                car.previousLapTimeMs - car.bestLapTimeMs,
                        }
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
