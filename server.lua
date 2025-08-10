local QBCore = exports['qb-core']:GetCoreObject()

local weaponNames = {
    [`WEAPON_UNARMED`] = 'Unarmed',
    [`WEAPON_KNIFE`] = 'Knife',
    [`WEAPON_NIGHTSTICK`] = 'Nightstick',
    [`WEAPON_HAMMER`] = 'Hammer',
    [`WEAPON_BAT`] = 'Bat',
    [`WEAPON_GOLFCLUB`] = 'Golf Club',
    [`WEAPON_CROWBAR`] = 'Crowbar',
    [`WEAPON_PISTOL`] = 'Pistol',
    [`WEAPON_COMBATPISTOL`] = 'Combat Pistol',
    [`WEAPON_APPISTOL`] = 'AP Pistol',
    [`WEAPON_PISTOL50`] = 'Pistol .50',
    [`WEAPON_MICROSMG`] = 'Micro SMG',
    [`WEAPON_SMG`] = 'SMG',
    [`WEAPON_ASSAULTSMG`] = 'Assault SMG',
    [`WEAPON_ASSAULTRIFLE`] = 'Assault Rifle',
    [`WEAPON_CARBINERIFLE`] = 'Carbine Rifle',
    [`WEAPON_ADVANCEDRIFLE`] = 'Advanced Rifle',
    [`WEAPON_MG`] = 'MG',
    [`WEAPON_COMBATMG`] = 'Combat MG',
    [`WEAPON_PUMPSHOTGUN`] = 'Pump Shotgun',
    [`WEAPON_SAWNOFFSHOTGUN`] = 'Sawed-off Shotgun',
    [`WEAPON_ASSAULTSHOTGUN`] = 'Assault Shotgun',
    [`WEAPON_BULLPUPSHOTGUN`] = 'Bullpup Shotgun',
    [`WEAPON_STUNGUN`] = 'Stun Gun',
    [`WEAPON_SNIPERRIFLE`] = 'Sniper Rifle',
    [`WEAPON_HEAVYSNIPER`] = 'Heavy Sniper',
    [`WEAPON_REMOTESNIPER`] = 'Remote Sniper',
    [`WEAPON_GRENADELAUNCHER`] = 'Grenade Launcher',
    [`WEAPON_RPG`] = 'RPG',
    [`WEAPON_MINIGUN`] = 'Minigun',
    [`WEAPON_GRENADE`] = 'Grenade',
    [`WEAPON_STICKYBOMB`] = 'Sticky Bomb',
    [`WEAPON_SMOKEGRENADE`] = 'Smoke',
    [`WEAPON_BZGAS`] = 'BZ Gas',
    [`WEAPON_MOLOTOV`] = 'Molotov',
    [`WEAPON_FIREEXTINGUISHER`] = 'Fire Extinguisher',
    [`WEAPON_PETROLCAN`] = 'Petrol Can',
    [`WEAPON_FLARE`] = 'Flare',
    [`WEAPON_SNSPISTOL`] = 'SNS Pistol',
    [`WEAPON_SPECIALCARBINE`] = 'Special Carbine',
    [`WEAPON_HEAVYPISTOL`] = 'Heavy Pistol',
    [`WEAPON_BULLPUPRIFLE`] = 'Bullpup Rifle',
    [`WEAPON_HOMINGLAUNCHER`] = 'Homing Launcher',
    [`WEAPON_PROXMINE`] = 'Proximity Mine',
    [`WEAPON_SNOWBALL`] = 'Snowball',
    [`WEAPON_VINTAGEPISTOL`] = 'Vintage Pistol',
    [`WEAPON_DAGGER`] = 'Dagger',
    [`WEAPON_MUSKET`] = 'Musket',
    [`WEAPON_FIREWORK`] = 'Firework',
    [`WEAPON_MARKSMANRIFLE`] = 'Marksman Rifle',
    [`WEAPON_HEAVYSHOTGUN`] = 'Heavy Shotgun',
    [`WEAPON_GUSENBERG`] = 'Gusenberg',
    [`WEAPON_HATCHET`] = 'Hatchet',
    [`WEAPON_RAILGUN`] = 'Railgun',
    [`WEAPON_MACHETE`] = 'Machete',
    [`WEAPON_MACHINEPISTOL`] = 'Machine Pistol',
    [`WEAPON_SWITCHBLADE`] = 'Switchblade',
    [`WEAPON_REVOLVER`] = 'Heavy Revolver',
    [`WEAPON_POOLCUE`] = 'Pool Cue',
    [`WEAPON_WRENCH`] = 'Wrench',
    [`WEAPON_BATTLEAXE`] = 'Battle Axe',
    [`WEAPON_PIPEWRENCH`] = 'Pipe Wrench',
    [`WEAPON_PISTOL_MK2`] = 'Pistol Mk II',
    [`WEAPON_CARBINERIFLE_MK2`] = 'Carbine Mk II',
    [`WEAPON_COMBATMG_MK2`] = 'Combat MG Mk II',
    [`WEAPON_HEAVYSNIPER_MK2`] = 'Heavy Sniper Mk II',
    [`WEAPON_SMG_MK2`] = 'SMG Mk II',
}

local function weaponLabel(hash)
    return weaponNames[hash] or ('Weapon ' .. tostring(hash))
end

RegisterNetEvent('qb-dna:checkVictim', function(victimNetId, killerServerId, killerWeaponHash, victimCoords)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local job = Player.PlayerData.job and Player.PlayerData.job.name or 'unemployed'
    if not Config.PoliceJobs[job] then
        return
    end

    -- Optionally validate proximity server-side if entity exists on this host
    if type(victimCoords) == 'vector3' then
        local ped = NetworkGetEntityFromNetworkId(victimNetId)
        if ped ~= 0 then
            local pedCoords = GetEntityCoords(ped)
            if #(pedCoords - vector3(victimCoords.x, victimCoords.y, victimCoords.z)) > 5.0 then
                -- ignore; probably migrated, but not critical
            end
        end
    end

    -- If client thinks killer is a player, try to resolve identity
    if killerServerId and killerServerId > 0 then
        local Killer = QBCore.Functions.GetPlayer(killerServerId)
        if Killer then
            local charinfo = Killer.PlayerData.charinfo or {}
            local info = {
                firstname = charinfo.firstname or 'Unknown',
                lastname  = charinfo.lastname or '',
                citizenid = Killer.PlayerData.citizenid or 'N/A',
                weapon    = weaponLabel(killerWeaponHash or 0)
            }
            TriggerClientEvent('qb-dna:result', src, true, info)
            return
        end
    end

    -- No matching online player
    TriggerClientEvent('qb-dna:result', src, false, { weapon = weaponLabel(killerWeaponHash or 0) })
end)
