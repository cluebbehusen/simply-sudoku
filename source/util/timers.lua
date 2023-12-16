local pd <const> = playdate

--- Removes all timers
function removeAllTimers()
    local allTimers = pd.timer.allTimers()
    if not allTimers then return end

    for _, timer in ipairs(allTimers) do
        timer:remove()
    end
end
