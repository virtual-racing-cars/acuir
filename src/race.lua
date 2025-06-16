local sim = ac.getSim()
local Car = require("src.classes.Car")

local session = {
        leaderboard = table.new(sim.carsCount, 0),
        leaderboardPositions = table.new(sim.carsCount, 0),
        currentLeader = 0,
        timingGates = {},
        fastestLapTimeMs = math.huge,
        fastestSplits = {},
        averageLapTimeMs = 0,
        cars = {},
}

local timingGateGapLengthM = 1 / sim.trackLengthM * 50

for i = 0, sim.carsCount - 1 do
        session.cars[i] = Car(i)
end

local function resetFastestTimes()
        session.fastestLapTimeMs = math.huge
        session.averageLapTimeMs = 0

        for i = 0, #sim.lapSplits - 1 do
                session.fastestSplits[i] = math.huge
        end
end

local function resetTimingGates()
        local gateCount = 0
        for trackPos = 0, 1, timingGateGapLengthM do
                gateCount = gateCount + 1
                session.timingGates[gateCount] = {}
                session.timingGates[gateCount].pos = trackPos
                session.timingGates[gateCount].lastCrossedTime = 0
        end
end

local function gateCrossed(gateIndex, car)
        local time = sim.currentSessionTime

        local gapToLeader = 0
        local gapToCarAheadLeaderboard = 0
        local gapToCarAheadTrack = 0

        if sim.raceSessionType ~= ac.SessionType.Race then
                local bestLapTime = session.leaderboard[car.leaderboardPosition].bestLapTimeMs

                gapToLeader = bestLapTime - (session.leaderboard[1].bestLapTimeMs or bestLapTime)
                gapToCarAheadLeaderboard = bestLapTime
                        - (session.leaderboard[math.max(car.leaderboardPosition - 1, 1)].bestLapTimeMs or bestLapTime)
        else
                gapToLeader = time - (session.timingGates[gateIndex][session.currentLeader] or time)
                gapToCarAheadLeaderboard = time - (session.timingGates[gateIndex][car.carAheadIndex] or time)
        end

        gapToCarAheadTrack = time - (session.timingGates[gateIndex].lastCrossedTime or time)

        car.gapToLeader = math.max(gapToLeader, 0)
        car.gapToCarAheadLeaderboard = math.max(gapToCarAheadLeaderboard, 0)
        car.gapToCarAheadTrack = math.max(gapToCarAheadTrack, 0)

        car.previousLapDelta = car.status.estimatedLapTimeMs - car.status.previousLapTimeMs
        car.bestLapDelta = car.status.estimatedLapTimeMs - car.status.bestLapTimeMs

        session.timingGates[gateIndex][car.index] = time
        session.timingGates[gateIndex].last = time
end

ac.onSessionStart(function(sessionIndex, restarted)
        resetFastestTimes()
        resetTimingGates()
end)

ac.onClientDisconnected(function(connectedCarIndex, connectedSessionID)
        setTimeout(
                function() session.cars[connectedCarIndex].isDisconnected = true end,
                30,
                "acuir_disconnect_car_%s" % connectedCarIndex
        )
end)

ac.onClientConnected(
        function(connectedCarIndex, connectedSessionID) clearTimeout("acuir_disconnect_car_%s" % connectedCarIndex) end
)

local function sortRaceLeaderboard(a, b)
        if b == nil then return false end
        if a == nil then return false end
        if a.car.isRetired then return false end
        if b.car.isRetired then return true end
        if not a.car.isConnected then return false end
        if not b.car.isConnected then return true end
        if not sim.isSessionStarted then return ac.getDriverName(a.car.index) < ac.getDriverName(b.car.index) end

        if
                (a.hasCompletedLastLap and b.hasCompletedLastLap)
                or (a.laps > 0 and a.car.splinePosition < 0.1)
                or (b.laps > 0 and b.car.splinePosition < 0.1)
        then
                return session.leaderboardPositions[a.car.index] < session.leaderboardPositions[b.car.index]
        end

        if a.laps == 0 and b.laps == 0 then
                if a.car.isInPitlane then return false end
                if b.car.isInPitlane then return true end
        end

        return a.laps + a.car.splinePosition > b.laps + b.car.splinePosition
end

local function updateBestTime(time1, time2)
        if time2 and time2 > 0 and time2 < time1 then return time2 end

        return time1
end

function session:getLeaderboardPosition(index) return session.leaderboardPositions[index] end

resetFastestTimes()
resetTimingGates()

function session:step()
        for i = 0, #ac.getSession(sim.currentSessionIndex).leaderboard - 1 do
                local leaderboardSlot = ac.getSession(sim.currentSessionIndex).leaderboard[i]
                session.leaderboard[i + 1] = leaderboardSlot
                session.leaderboardPositions[leaderboardSlot.car.index] = i + 1
        end

        if sim.raceSessionType == ac.SessionType.Race then table.sort(session.leaderboard, sortRaceLeaderboard) end

        local carAheadIndex = -1
        for pos, slot in ipairs(session.leaderboard) do
                local car = session.cars[slot.car.index]
                car.slot = slot
                car.carAheadIndex = carAheadIndex
                car.leaderboardPosition = pos
                session.leaderboardPositions[car.index] = pos
                session.averageLapTimeMs = (session.averageLapTimeMs + car.status.previousLapTimeMs) * 0.5

                if car.status.isConnected then car.isDisconnected = false end

                if pos == 1 then
                        session.currentLeader = car.index
                elseif session.leaderboard[1].laps > 0 then
                        if
                                session.leaderboard[1].laps + session.leaderboard[1].car.splinePosition
                                > slot.laps + slot.car.splinePosition + 1
                        then
                                car.lapsToLeader = math.max(session.leaderboard[1].laps - slot.laps, 0)
                        else
                                car.lapsToLeader = 0
                        end

                        if
                                session.leaderboard[pos - 1].laps
                                        + session.leaderboard[pos - 1].car.splinePosition
                                > slot.laps + slot.car.splinePosition + 1
                        then
                                car.lapsToCarAheadLeaderboard =
                                        math.max(session.leaderboard[pos - 1].laps - slot.laps, 0)
                        else
                                car.lapsToCarAheadLeaderboard = 0
                        end
                else
                        car.lapsToLeader = 0
                        car.lapsToCarAheadLeaderboard = 0
                end

                car.bestLapTimeMs = sim.raceSessionType ~= ac.SessionType.Race and slot.bestLapTimeMs
                        or car.status.bestLapTimeMs
                session.fastestLapTimeMs = updateBestTime(session.fastestLapTimeMs, car.bestLapTimeMs)

                for i = 0, #sim.lapSplits - 1 do
                        session.fastestSplits[i] = updateBestTime(session.fastestSplits[i], car.status.lastSplits[i])
                        session.fastestSplits[i] = updateBestTime(session.fastestSplits[i], car.status.bestSplits[i])
                        session.fastestSplits[i] = updateBestTime(session.fastestSplits[i], car.status.currentSplits[i])
                end

                local gateIndex = math.floor(car.status.splinePosition / timingGateGapLengthM) + 1
                local gate = session.timingGates[gateIndex]

                if car.status.splinePosition >= gate.pos and car.splinePositionLast < gate.pos then
                        gateCrossed(gateIndex, car)
                end

                car.splinePositionLast = car.status.splinePosition

                carAheadIndex = car.index
        end
end

return session
