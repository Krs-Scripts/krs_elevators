local function getPlayerData()
    ESX = exports.es_extended:getSharedObject()
    
    PlayerData = ESX.GetPlayerData()

    while not PlayerData or not PlayerData.job do
        Wait(100)
        PlayerData = ESX.GetPlayerData()
    end

    RegisterNetEvent('esx:setJob', function(job)
        PlayerData.job = job
    end)
end

CreateThread(getPlayerData)

local function notAccess()
    lib.notify({title = 'Not Access', description = 'You do not have access to this floor', type = 'error'})
end

local function goToFloor(data)
    local elevator, floor = data.elevator, data.floor
    local coords = cfg.elevators[elevator][floor].coords
    local heading = cfg.elevators[elevator][floor].heading
    local ped = cache.ped
    DoScreenFadeOut(1500)
    while not IsScreenFadedOut() do Wait(10) end
    RequestCollisionAtCoord(coords.x, coords.y, coords.z)
    while not HasCollisionLoadedAroundEntity(ped) do Wait() end
    SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
    SetEntityHeading(ped, heading or 0.0)
    Wait(3000)
    DoScreenFadeIn(1500)
end

local function openElevatoMenu(data)
    local elevator = data.elevator
    local floor = data.floor
    local elevatorData = cfg.elevators[elevator]
    local Options = {}
    -- print(json.encode(data, {indent = true}))
    for k, v in pairs(elevatorData) do
        local option = {
            title = v.title,
            description = v.description,
            event = '',
            icon = v.icon or '', 
        }

        if k == floor then
            option.title = option.title .. ' ' 
        elseif v.groups then
            local found = false
            for _, group in ipairs(v.groups) do
                if PlayerData.job.name == group then
                    found = true
                    break
                end
            end
            if found then
                option.event = goToFloor
                option.args = { elevator = elevator, floor = k }
            else
                option.event = notAccess
            end
        else
            option.event = goToFloor
            option.args = { elevator = elevator, floor = k }
        end

        table.insert(Options, option)
    end

    lib.registerContext({
        id = 'elevators_menu',
        title = 'Krs Elevator Menu',
        options = Options
    })

    lib.showContext('elevators_menu')
end

for k, elevator in pairs(cfg.elevators) do
    for floor, data in pairs(elevator) do
        if data.groups then
            lib.zones.sphere({
                coords = data.coords,
                size = vec3(1.6, 1.4, 3.2),
                rotation = 346.25,
                debug = false,
                onExit = function()
                    lib.hideTextUI()
                end,
                onEnter = function()
                    lib.showTextUI('[E] Open Elevator Menu')
                end,
                inside = function()
                    if IsControlJustReleased(0, 38) then
                        openElevatoMenu({ elevator = k, floor = floor })
                    end
                end,
            })
        end
    end
end