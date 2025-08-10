Config = {}

-- Jobs allowed to run DNA checks
Config.PoliceJobs = {
    ['police'] = true,
    ['sahp'] = true, -- add/remove as needed
}

-- Minimum ped health to consider "dead"
Config.DeadHealthThreshold = 0

-- Max distance to interact
Config.MaxDistance = 2.0

-- Cooldown per victim ped (seconds) to avoid spam
Config.PerVictimCooldown = 20

-- Notification helper: 'qb' or 'ox'
Config.Notify = 'qb'
