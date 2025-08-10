local QBCore = exports['qb-core']:GetCoreObject()

local checkedVictims = {}  -- victimNetId -> lastTime

local function Notify(msg, typ, time)
    if Config.Notify == 'ox' then
        lib.notify({ title = 'DNA', description = msg, type = typ or 'inform', duration = time or 4000 })
    else
        QBCore.Functions.Notify(msg, typ or 'primary', time or 4000)
    end
end

local function IsAllowedJob()
    local p = QBCore.Functions.GetPlayerData()
    return p and p.job and Config.PoliceJobs[p.job.name] == true
end

local function IsEntityDeadPed(ent)
    if not DoesEntityExist(ent) then return false end
    if not IsEntityAPed(ent) then return false end
    if IsPedAPlayer(ent) then return false end
    if not IsPedHuman(ent) then return false end
    if not IsPedFatallyInjured(ent) and GetEntityHealth(ent) > Config.DeadHealthThreshold then
        return false
    end
    return true
end

-- Find killer server id if killer was a player, including vehicle impacts driven by a player.
local function ResolveKillerServerId(victimPed)
    local killerEntity, killerWeapon = GetPedSourceOfDeath(victimPed), GetPedCauseOfDeath(victimPed)

    if killerEntity ~= 0 and DoesEntityExist(killerEntity) then
        if IsEntityAPed(killerEntity) and IsPedAPlayer(killerEntity) then
            local idx = NetworkGetPlayerIndexFromPed(killerEntity)
            if idx ~= -1 then
                return GetPlayerServerId(idx), killerWeapon
            end
        end

        if IsEntityAVehicle(killerEntity) then
            local driver = GetPedInVehicleSeat(killerEntity, -1)
            if driver ~= 0 and DoesEntityExist(driver) and IsPedAPlayer(driver) then
                local idx = NetworkGetPlayerIndexFromPed(driver)
                if idx ~= -1 then
                    return GetPlayerServerId(idx), killerWeapon
                end
            end
        end
    end

    return nil, killerWeapon
end

-- Add a global qb-target option for any dead NPC ped
CreateThread(function()
    exports['qb-target']:AddGlobalPed({
        options = {
            {
                icon = 'fa-solid fa-vial',
                label = 'Check DNA',
                action = function(entity)
                    local ped = entity
                    if not IsAllowedJob() then
                        Notify('Not authorized.', 'error')
                        return
                    end
                    if not IsEntityDeadPed(ped) then
                        Notify('Subject is not suitable for DNA.', 'error')
                        return
                    end

                    local victimNet = NetworkGetNetworkIdFromEntity(ped)
                    if victimNet and victimNet ~= 0 then
                        local now = GetGameTimer()
                        if checkedVictims[victimNet] and (now - checkedVictims[victimNet]) < (Config.PerVictimCooldown * 1000) then
                            Notify('Recent DNA already collected.', 'inform', 2500)
                            return
                        end
                        checkedVictims[victimNet] = now
                    end

                    -- local client-side inference to speed up result
                    local killerServerId, killerWeapon = ResolveKillerServerId(ped)

                    -- Send to server to validate and fetch identity
                    local coords = GetEntityCoords(ped)
                    TriggerServerEvent('qb-dna:checkVictim', victimNet or -1, killerServerId or -1, killerWeapon or 0, coords)
                end,
                canInteract = function(entity, distance, data)
                    if distance > Config.MaxDistance then return false end
                    if not IsAllowedJob() then return false end
                    return IsEntityDeadPed(entity)
                end,
            }
        },
        distance = Config.MaxDistance
    })
end)

-- Receive server result
RegisterNetEvent('qb-dna:result', function(found, info)
    if not found then
        if info and info.weapon then
            Notify(('No DNA match. Cause: %s'):format(info.weapon), 'error')
        else
            Notify('No DNA match.', 'error')
        end
        return
    end

    local t = info or {}
    local name = (t.firstname and t.lastname) and (t.firstname .. ' ' .. t.lastname) or (t.charname or 'Unknown')
    local line1 = ('DNA match: %s'):format(name)
    local line2 = t.citizenid and ('CID: ' .. t.citizenid) or nil
    local line3 = t.weapon and ('Cause: ' .. t.weapon) or nil

    local msg = line1
    if line2 then msg = msg .. '\n' .. line2 end
    if line3 then msg = msg .. '\n' .. line3 end

    Notify(msg, 'success', 7000)
end)
