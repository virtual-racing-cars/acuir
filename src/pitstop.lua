local car = ac.getCar(0)
local sim = ac.getSim()
local carINI = ac.INIConfig.carData(0, "car.ini")
local setupINI = ac.INIConfig.carData(0, "setup.ini")
local pitstopsINI =
        ac.INIConfig.load(string.format("%s\\%s", ac.getFolder(ac.FolderID.Root), "system\\cfg\\pitstop.ini"))

local pitstop = {
        windowName = "pitstopWindow",
        presetsCount = pitstopsINI:get("SETTINGS", "PRESETS_COUNT", 1),
        autoAppPitlane = pitstopsINI:get("SETTINGS", "AUTO_APP_ON_PITLANE", 1) == 1,
        visibilityMaxTime = pitstopsINI:get("SETTINGS", "VISIBILITY_MAX_TIME", 3),
        visibilityTimer = 0,
}

local pitstopTimes = {
        FUEL = {
                stepTime = carINI:get("PIT_STOP", "FUEL_LITER_TIME_SEC", 0),
                time = function(addFuel, stepTime)
                        return (addFuel + math.min(car.maxFuel - (car.fuel + addFuel), 0)) * stepTime
                end,
        },
        COMPOUND = {
                stepTime = carINI:get("PIT_STOP", "TYRE_CHANGE_TIME_SEC", 0),
                time = function(compound, stepTime) return compound >= 0 and stepTime or 0 end,
        },
        WING_1 = {
                stepTime = setupINI:get("WING_1", "PITSTOP", 0),
                time = function(offset, stepTime) return offset ~= 0 and stepTime or 0 end,
        },
        WING_2 = {
                stepTime = setupINI:get("WING_2", "PITSTOP", 0),
                time = function(offset, stepTime) return offset ~= 0 and stepTime or 0 end,
        },
        REPAIR_BODY = {
                stepTime = carINI:get("PIT_STOP", "BODY_REPAIR_TIME_SEC", 0),
                time = function(repair, stepTime)
                        if repair == 0 then return 0 end

                        local totalBodyDamage = 0
                        for i = 0, 3 do
                                totalBodyDamage = totalBodyDamage + car.damage[i] * 100
                        end

                        return totalBodyDamage / 10 * stepTime
                end,
        },
        REPAIR_ENGINE = {
                stepTime = carINI:get("PIT_STOP", "ENGINE_REPAIR_TIME_SEC", 0),
                time = function(repair, stepTime)
                        return repair == 1 and (1000 - car.engineLifeLeft) / 1000 * stepTime or 0
                end,
        },
        REPAIR_SUSPENSION = {
                stepTime = carINI:get("PIT_STOP", "SUSP_REPAIR_TIME_SEC", 0),
                time = function(repair, stepTime)
                        if repair == 0 then return 0 end

                        local totalSuspensionDamage = 0
                        for i = 0, 3 do
                                totalSuspensionDamage = totalSuspensionDamage + car.wheels[i].suspensionDamage * 100
                        end

                        return totalSuspensionDamage / 10 * stepTime
                end,
        },
}

function pitstop:getEstimatedTime()
        local timeEstimate = 0

        for i, v in ipairs(ac.getPitstopSpinners()) do
                local timeSlot = pitstopTimes[v.name]

                if timeSlot then timeEstimate = timeEstimate + timeSlot.time(v.value, timeSlot.stepTime) end
        end

        return timeEstimate
end

function pitstop:windowIsOpen() return ac.isWindowOpen(pitstop.windowName) end

function pitstop:resetVisibilityTimer() pitstop.visibilityTimer = os.clock() + pitstop.visibilityMaxTime end

function pitstop:clearVisibilityTimer() pitstop.visibilityTimer = 0 end

function pitstop:setWindowOpen(opened)
        if opened then
                pitstop:resetVisibilityTimer()
                ac.setWindowOpen(pitstop.windowName, true)
        else
                pitstop:clearVisibilityTimer()
                ac.setWindowOpen(pitstop.windowName, false)
        end
end

function pitstop:toggleWindowOpen() return pitstop:setWindowOpen(not pitstop:windowIsOpen()) end

function pitstop:isVisible() return pitstop.visibilityTimer - os.clock() > 0 end

local isInPitlane = false
function pitstop:step(dt)
        if isInPitlane ~= car.isInPitlane then isInPitlane = car.isInPitlane end

        if car.justJumped or not sim.isLive or sim.isInMainMenu then
                pitstop:setWindowOpen(false)
                return
        end

        if pitstop.autoAppPitlane and isInPitlane then
                pitstop:resetVisibilityTimer()
                ac.setWindowOpen(pitstop.windowName, true)
        end

        ac.setWindowOpen(pitstop.windowName, pitstop:isVisible())
end

return pitstop
