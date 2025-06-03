local sim = ac.getSim()
local Car = require("src.classes.Car")

local session = {
        leaderboard = table.new(sim.carsCount, 0),
        leaderboardPositions = table.new(sim.carsCount, 0),
        currentLeader = 0,
        timingGates = {},
        fastestLapTimeMs = math.huge,
        fastestSplits = {},
        cars = {},
}

local trackLength = 1 / sim.trackLengthM * 50

for i = 0, #sim.lapSplits - 1 do
        session.fastestSplits[i] = math.huge
end

for i = 0, sim.carsCount - 1 do
        session.cars[i] = Car(i)
end

local gateCount = 0
for trackPos = 0, 1, trackLength do
        gateCount = gateCount + 1
        session.timingGates[gateCount] = {}
        session.timingGates[gateCount].pos = trackPos
        session.timingGates[gateCount].lastCrossedTime = 0
end

local function gateCrossed(gateIndex, car, time)
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

        car.gapToLeader = gapToLeader
        car.gapToCarAheadLeaderboard = gapToCarAheadLeaderboard
        car.gapToCarAheadTrack = gapToCarAheadTrack

        session.timingGates[gateIndex][car.index] = time
        session.timingGates[gateIndex].last = time
end

ac.onSessionStart(function(sessionIndex, restarted)
        session.fastestLapTimeMs = math.huge
        for i = 0, #sim.lapSplits do
                session.fastestSplits[i] = math.huge
        end
end)

local function sortLeaderboard(a, b)
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

function session:step()
        for i = 0, #ac.getSession(sim.currentSessionIndex).leaderboard - 1 do
                local leaderboardSlot = ac.getSession(sim.currentSessionIndex).leaderboard[i]
                session.leaderboard[i + 1] = leaderboardSlot
                session.leaderboardPositions[leaderboardSlot.car.index] = i + 1
        end

        if sim.raceSessionType == ac.SessionType.Race then table.sort(session.leaderboard, sortLeaderboard) end

        local carAheadIndex = -1
        for pos, slot in ipairs(session.leaderboard) do
                local car = session.cars[slot.car.index]
                car.carAheadIndex = carAheadIndex
                car.leaderboardPosition = pos
                session.leaderboardPositions[car.index] = pos

                if pos == 1 then session.currentLeader = car.index end

                ac.debug(ac.getDriverName(slot.car.index), ac.lapTimeToString(slot.car.bestLapTimeMs))

                session.fastestLapTimeMs = updateBestTime(session.fastestLapTimeMs, car.status.bestLapTimeMs)

                for i = 0, #sim.lapSplits - 1 do
                        session.fastestSplits[i] = updateBestTime(session.fastestSplits[i], car.status.lastSplits[i])
                        session.fastestSplits[i] = updateBestTime(session.fastestSplits[i], car.status.bestSplits[i])
                        session.fastestSplits[i] = updateBestTime(session.fastestSplits[i], car.status.currentSplits[i])
                end

                local time = sim.currentSessionTime

                local gateIndex = math.floor(car.status.splinePosition / trackLength) + 1
                local gate = session.timingGates[gateIndex]

                if car.status.splinePosition >= gate.pos and car.splinePositionLast < gate.pos then
                        gateCrossed(gateIndex, car, time)
                end

                car.splinePositionLast = car.status.splinePosition

                carAheadIndex = car.index
        end
end

return session
