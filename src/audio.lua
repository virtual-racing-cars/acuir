local audio = {}

local delayTimer = 0
local delayTime = 0.125

local function playAudio(file)
        if delayTimer > os.clock() then return end
        local audioEvent =
                ac.AudioEvent.fromFile({ filename = "assets\\sfx\\%s.mp3" % file, use3D = false, loop = false }, false)

        audioEvent.volume = 0.125
        audioEvent:resume()
        delayTimer = os.clock() + delayTime
end

function audio:driver(dt)
        if ui.anyItemHovered() and ui.mouseClicked(ui.MouseButton.Left) then playAudio("gui_click") end
end

function audio:trigger()
        if ui.anyItemHovered() and ui.mouseClicked(ui.MouseButton.Left) then
                playAudio("gui_click")
                return
        end

        playAudio("gui_nav")
end

return audio
