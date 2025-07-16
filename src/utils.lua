function isempty(str) return str == nil or str == "" end

function toCapitalCase(str)
        return (str:gsub("(%a)([%w_']*)", function(first, rest) return first:upper() .. rest:lower() end))
end

ac.lapTimeToString = function(time, allowHours)
        allowHours = allowHours == true
        time = tonumber(time)

        if not time or time <= 0 or math.abs(time) == math.huge then return "--:--.---" end

        local totalSeconds = math.floor(time / 1000)
        local ms = time % 1000
        local seconds = totalSeconds % 60
        local minutes = math.floor(totalSeconds / 60)
        local hours = math.floor(minutes / 60)
        minutes = minutes % 60

        if allowHours and hours > 0 then
                local centiseconds = math.floor(ms / 10 + 0.5)
                return string.format("%d:%d:%02d.%02d", hours, minutes, seconds, centiseconds)
        elseif allowHours then
                local centiseconds = math.floor(ms / 10 + 0.5)
                return string.format("%d:%02d.%02d", minutes, seconds, centiseconds)
        else
                return string.format("%d:%02d.%03d", math.floor(totalSeconds / 60), seconds, ms)
        end
end
