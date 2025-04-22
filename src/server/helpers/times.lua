local timeHelper = {}

function timeHelper.getTimeUntilMidnightPST()
    local now = os.time()
    local utcDate = os.date("!*t", now) -- Get UTC time
    local pstOffset = -8 * 3600 -- PST is UTC-8

    -- Adjust for daylight savings (PDT)
    local isDST = os.date("*t").isdst
    if isDST then
        pstOffset = -7 * 3600 -- PDT (UTC-7)
    end

    -- Convert UTC time to PST/PDT
    local pstTime = os.time(utcDate) + pstOffset
    local pstDate = os.date("*t", pstTime)

    -- Calculate seconds until next midnight
    local midnightPST = os.time({
        year = pstDate.year,
        month = pstDate.month,
        day = pstDate.day,
        hour = 24, -- Midnight next day
        min = 0,
        sec = 0
    }) - pstOffset -- Convert back to UTC timestamp

    return midnightPST - now
end

function timeHelper.getDatesSeed(dateStr: string) -- ex. MM/DD/YYYY
    -- Validate the input format (optional)
    if not dateStr:match("^%d%d/%d%d/%d%d%d%d$") then
        error("Invalid date format. Expected MM/DD/YYYY")
    end

    -- Remove the slashes to create a clean number for the seed
    local dateStrNoSlashes = dateStr:gsub("/", "")
    -- Convert the cleaned date string into a number
    local seed = tonumber(dateStrNoSlashes)
    return seed
end

return timeHelper