local app = require("app")

local sim = ac.getSim()

local replay = {
        isPlaying = false,
        direction = 1,
        rate = 1,
        counter = 0,
        frame = 0,
}

function replay:setPlayback(direction, rate)
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
                return
        end

        if not replay.isPlaying then
                replay.rate = 0
                ac.setReplayPosition(replay.frame, 1)

                return
        end

        replay.counter = replay.counter + dt * 1000 * replay.rate
        if replay.counter < sim.replayFrameMs then return end
        replay.counter = 0

        replay.frame = replay.frame + replay.direction
        if replay.frame <= 1 or replay.frame >= sim.replayFrames - 1 then return end

        ac.setReplayPosition(math.clamp(replay.frame, 1, sim.replayFrames - 1), 1)
end

return replay
