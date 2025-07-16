local sim = ac.getSim()

local laps = {}

ac.onLapCompleted(0, function(carIndex, lapTime, valid, cuts, lapCount)
        if not laps[sim.raceSessionType] then laps[sim.raceSessionType] = {} end

        local car = ac.getCar(carIndex)

        table.insert(laps[sim.raceSessionType], {
                time = lapTime,
                valid = valid,
                cuts = cuts,
                number = #laps[sim.raceSessionType] + 1,
                splits = { [0] = car.lastSplits[0], [1] = car.lastSplits[1], [2] = car.lastSplits[2] },
                tyres = ac.getTyresName(0, car.compoundIndex),
                delta = #laps[sim.raceSessionType] >= 1
                                and lapTime - laps[sim.raceSessionType][#laps[sim.raceSessionType]].time
                        or nil,
        })
end)

ac.onSessionStart(function(sessionIndex, restarted) laps[sim.raceSessionType] = {} end)

return laps
