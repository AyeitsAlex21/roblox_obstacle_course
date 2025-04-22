local MIDNIGHT_JOBS_CONFIG = {
    days_ahead = 14, -- Number of days ahead to generate obstacle courses from current date
    overwrite_existing = false, -- overwrite already existing stages
    skip_today = true -- in the loop to create stages skip today
}

return MIDNIGHT_JOBS_CONFIG