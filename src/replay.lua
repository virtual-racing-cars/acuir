local app = require("app")

local sim = ac.getSim()

local replay = {
        direction = 1,
        rate = 1,
        counter = 0,
        frame = 0,
        audioVolume = ac.getAudioVolume(ac.AudioChannel.Main),
        minFrame = 0,
        maxFrame = 0,
        forwardAvailable = false,
        rewindAvailable = false,
}

function replay:setPause(pause)
        if pause then
                replay.rate = 0
                replay.audioVolume = ac.getAudioVolume(ac.AudioChannel.Main)
                ac.setAudioVolume(ac.AudioChannel.Main, 0, 0)
        else
                if replay.rate == 0 then
                        replay.direction = 1
                        replay.rate = 1
                end
                ac.setAudioVolume(ac.AudioChannel.Main, replay.audioVolume)
        end
end

function replay:setPlayback(direction, rate)
        replay:setPause(false)
        replay.frame = math.clamp(replay.frame, 1, sim.replayFrames - 1)

        if direction ~= replay.direction then rate = 1 end

        replay.direction = direction
        replay.rate = math.clamp(rate, 0.25, 5) or 1
end

function replay:jumpToStart()
        replay.frame = 2
        ac.setReplayPosition(replay.frame, 1)
end

function replay:jumpToEnd()
        replay.frame = sim.replayFrames - 2
        ac.setReplayPosition(replay.frame, 1)
end
--
function replay:step(dt)
        ac.debug("rff", replay.frame)
        ac.debug("rf", sim.replayCurrentFrame)
        ac.debug("isActive", sim.isReplayActive)

        if not sim.isReplayActive then
                replay.frame = sim.replayFrames
                replay.audioVolume = ac.getAudioVolume(ac.AudioChannel.Main)
                return
        end

        replay.minFrame = 5
        replay.maxFrame = sim.replayFrames - replay.minFrame

        if replay.frame <= replay.minFrame then
                replay.rewindAvailable = false
        else
                replay.rewindAvailable = true
        end

        if replay.frame >= replay.maxFrame then
                replay.forwardAvailable = false
        else
                replay.forwardAvailable = true
        end

        if replay.rate <= 0 then
                ac.setReplayPosition(replay.frame, 1)
                return
        end

        replay.counter = replay.counter + dt * 1000 * replay.rate
        if replay.counter < sim.replayFrameMs then return end
        replay.counter = 0

        replay.frame = math.clamp(replay.frame + replay.direction, replay.minFrame, replay.maxFrame)
        ac.setReplayPosition(replay.frame, 1)

        if replay.frame <= replay.minFrame or replay.frame >= replay.maxFrame then replay:setPause(true) end
end

return replay
