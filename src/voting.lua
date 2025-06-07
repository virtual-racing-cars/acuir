local cui = require("src.ui.cui")

local voting = {
        lastVoteDetails = nil,
}

local voteYesButton = ac.ControlButton("__CM_ONLINE_POLL_YES")
local voteNoButton = ac.ControlButton("__CM_ONLINE_POLL_NO")

voteYesButton:onPressed(function()
        local voteDetails = ac.getCurrentVoteDetails()

        if not voteDetails then
                ac.log("No vote active")
                return
        elseif voteDetails.voted then
                ac.log("Vote already cast")
                return
        elseif voteDetails.type == "unknown" then
                ac.log("Can't cast vote, unknown")
                return
        end

        if ac.castVote(tostring(voteDetails.type), true, voteDetails.targetIndex) then
                ac.log("Voted YES")
        else
                ac.error("Vote error")
        end
end)

voteNoButton:onPressed(function()
        local voteDetails = ac.getCurrentVoteDetails()

        if not voteDetails then
                ac.log("No vote active")
                return
        elseif voteDetails.voted then
                ac.log("Vote already cast")
                return
        elseif voteDetails.type == "unknown" then
                ac.log("Can't cast vote, unknown")
                return
        end

        if ac.castVote(tostring(voteDetails.type), false, voteDetails.targetIndex) then
                ac.log("Voted NO")
        else
                ac.error("Vote error")
        end
end)

function voting:step()
        local voteDetails = ac.getCurrentVoteDetails()

        if voteDetails and voteDetails.type ~= "unknown" then
                voting.lastVoteDetails = voteDetails

                local voteTypeString = voteDetails.type == "kick" and ac.getDriverName(voteDetails.targetIndex)
                        or "Session"
                local voteCastString =
                        string.format("Yes [%s] No [%s]", voteYesButton:boundTo(), voteNoButton:boundTo())
                local voteCastedString = string.format("Yes [%s] No [%s]", voteDetails.voteYes, voteDetails.voteNo)

                cui.menuBanner(
                        string.upper(
                                string.format(
                                        "Vote %s %s %s",
                                        voteDetails.type,
                                        voteTypeString,
                                        voteDetails.voted and voteCastedString or voteCastString
                                )
                        ),
                        voteDetails.timeLeft,
                        rgbm.colors.red,
                        true,
                        "vote"
                )
        end
end

return voting
