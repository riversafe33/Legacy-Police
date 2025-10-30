ConfigMain = {}

ConfigMain.ondutycommand = "onduty"      -- Command to go on duty
ConfigMain.offdutycommand = "offduty"    -- Command to go off duty
ConfigMain.openpolicemenu = "pmenu"      -- Can only be used if you're an admin or have a job listed in ConfigMain.allowedJobs
ConfigMain.delwagoncommand = "delwagon"  -- Command to delete the spawned wagon

ConfigMain.Keys = {
    up = 0x6319DB71,           -- UP
    down = 0x05CA7C52,         -- DOWN
    left = 0xA65EBAB4,         -- LEFT
    right = 0xDEB34313,        -- RIGHT
    int = 0xE6F612E4,          -- IN
    out = 0x1CE6D9EB,          -- OUT
    rotateleft = 0x4F49CC4C,   -- ROTATE LEFT
    rotateright = 0x8F9F9E58,  -- ROTATE RIGHT
    finistadjust = 0xC7B5340A, -- Finist
}

ConfigMain.ControlsPanel = {
    title = "Adjust Badge",
    controls = {
        "[← ↑ ↓ →] - Move Badge",
        "[1]       - IN",
        "[2]       - OUT",
        "[3]       - Rotate left",
        "[4]       - Rotate right",
        "[ENTER]   - Confirm Adjust",
    }
}

ConfigMain.Text = {
    jailTimerLabel = "Time in Jail",
    comisaryMessage = "Press G to get food",
    taskMessage = "Press G to sweep",
    wagonMessage = "Press G to take a service wagon",
    cabinetnui = "Press G to open the Armory",
    storage = "Press G to open Storage",
    searchplayer  = "Press G to frisk",
    cabinet = "Cabinet",
    opencabinet = "Open Cabinet",
    inventorytitle = "Citizen's Bag",
    jailchoreblip = "Jail Chore",
    Menu = {
        gradeRequired = "Required Rank: ",
        togglebadge = "Toggle Badge",
        idmenu = "ID Menu",
        cufftoggle = "Cuff/Uncuff Citizen",
        escort = "Escort Handcuffed Player",
        putinoutvehicle = "Put In/Out of Vehicle",
        jailplayer = "Send Player to Jail",
        unjailplayer = "Release Player from Jail",
        lawmenu = "Law Menu",
        none = "None",
        vartrue = "true",
        varfalse = "false",
        wagonmenutitle = "Service Wagons",
        wagonmenusub = "Location: ",
        playerid = "Player ID: ",
        jailamount = "Jail Time: ",
        autotele = "Auto Teleport: ",
        autoteledesc = "Should the Citizen be teleported automatically or manually?",
        jaillocaiton = "Jail Location: ",
        jail = "Send Citizen to Jail",
        jaildesc = "If Auto Jail is false, you must transport the Citizen manually; otherwise, locals will do it",
        jailmenu = "Jail Menu",
        unjail = "Release Citizen with previous ID",
        unjaildesc = "You will release the Citizen from jail and they will be free",
        grabweapons = "Grab Weapons",
        grabammo = "Ammo and Items",
        cabinet = "Cabinet",
        citizenid = "Get Citizen ID",
        horseowner = "Get Horse Owner",
        horseownerdesc = "Get the horse owner; if the owner is not nearby, it will return ownerless",
        playermoney = "Money: ",
        checkitems = "Check Items",
        valjail = "Valentine",
        bwjail = "Blackwater",
        sdjail = "Saint Denis",
        rhjail = "Rhodes",
        stjail = "Strawberry",
        arjail = "Armadillo",
        tujail = "Tumbleweed",
        anjail = "Annesburg",
        sisika = "Sisika",
    },
    Input = {
        inputconfirm = "Confirm",
        playerid = "Player ID: ",
        numberonly = "Numbers Only",
        jailamount = "Jail Time: ",
    },
    Notify = {
        id = "Identification",
        playernearby = "Another player is too close to open the storage",
        titlebadge = "Badge",
        service = "Service",
        handcuff = "Cuff",
        lockpick = "Lockpick",
        prison = "Prison",
        wagon = "Wagon",
        job = "Job",
        escort = "Escort",
        canteen = "Canteen",
        inventory = "Inventory",
        grade = "Rank",
        armory = "Armory",
        nocoords = "No coordinates for this city",
        jailed = "You have been jailed for ",
        minutes = " minutes",
        leave = "You have been released",
        leaveprison = "You tried to escape! Time added to your sentence.",
        notwagon = "No wagon nearby to remove",
        notjob = "You don't have the required job",
        notcloseenough = "You are not close enough to a citizen",
        badgeon = "Badge equipped",
        badgeoff = "Badge removed",
        onduty = "You are already on duty",
        notcloseenoughtowagon = "You are not close enough to a wagon",
        goonduty = "You are now on duty",
        gooffduty = "You are now off duty",
        lockpickbroke = "Damn! The lockpick broke!",
        idcheck = "ID Check",
        notowned = "Not the horse's property",
        took = " took ",
        from = " from ",
        nojob = "you don't have the required job",
        jobok = "Job: ",
        horse = " - Horse: ",
        name = "Name: ",
        idinvalid = "You must enter a valid ID",
        idincorret = "Invalid player ID.",
        inprison = "The player is already in jail.",
        noprison = "The player is not in jail.",
        wagonok = "Wagon spawned successfully",
        nograde = "You don't have the required rank",
        succes = "You have already collected your food.",
        collect = "You collected ",
        collect1 = "You received: ",
        notaccess = "You are not authorized to open this storage.",
        storage = "Storage",
        notjoborservice = "You don't have the required job or you're not on duty",
    }
}

ConfigMain.CheckHorse = false
-- To see if the horse is the property of the Rider, he must be mounted on the horse.
-- Select the table you want to use: if ConfigMain.CheckHorse is true
-- sirevlc      -- V3 -- "sirevlc_horses_v3" / -- V1 V2 -- "sirevlc_horses" 
-- rsd_stable   -- "rsd_horses" 
-- vorp_stables -- "stables"
-- bcc-stables  -- "player_horses"
ConfigMain.SQLTable = "player_horses"

ConfigMain.jobRequired = true
ConfigMain.allowedJobs = {
    "police",
    "marshal",
    "lawmen",
}

OffDutyJobs = {
    "offpolice",
    "offmarshal",
    "offlawmen",
}

ConfigMain.Wagons = { 
    [1] = { wagon = "gatchuck_2", label = "Gatling Wagon", allowedGrade = 4 },
    [2] = { wagon = "policeWagongatling01x", label = "Gatling Wagon 2", allowedGrade = 4 },
    [3] = { wagon = "ArmySupplyWagon", label = "Army Supply Wagon", allowedGrade = 1 },
    [4] = { wagon = "wagonarmoured01x", label = "Armoured Wagon", allowedGrade = 2 },
    [5] = { wagon = "wagonPrison01x", label = "Prison Wagon", allowedGrade = 3 },
    [6] = { wagon = "warwagon2", label = "War Wagon", allowedGrade = 3 }   
}

ConfigMain.Stations = { -- Point where the wagon can be taken out at each police station
    vector3(-278.21, 802.74, 119.38),       -- Valentine
    vector3(2907.88, 1308.68, 44.94),       -- Annesburg
    vector3(-762.62, -1270.75, 44.05),      -- Blackwater
    vector3(2508.31, -1315.81, 48.95),      -- Saint Denis
    vector3(1359.26, -1299.75, 77.76),      -- Rhodes
    vector3(-1812.33, -355.65, 164.65)      -- Strawberry
}

-- Point where the wagon appears when spawned
ConfigMain.SpawnCoords = { -- if you wish you can also add ["Tumbleweed"] and ["Armadillo"]
    ["Valentine"]    = { x = -281.59, y = 828.47, z = 119.6, h = 281.61 },
    ["Annesburg"]    = { x = 2912.09, y = 1301.52, z = 44.45, h = 156.25 },
    ["Blackwater"]   = { x = -756.03, y = -1255.74, z = 43.4, h = 285.06 },
    ["Rhodes"]       = { x = 1356.29, y = -1313.94, z = 76.81, h = 59.07 },
    ["Saint Denis"]  = { x = 2497.99, y = -1321.53, z = 48.81, h = 275.72},
    ["Strawberry"]   = { x = -1800.1, y = -350.19, z = 164.12, h = 198.11 },
}

ConfigMain.ShowBlip = true
ConfigMain.PoliceStationblip = {
    {coords = vector3(-277.0, 810.92, 119.38),   blips = 1047294027, blipsName = "Valentine Sheriff Station"},
    {coords = vector3(-1811.8, -353.6, 164.65),  blips = 1047294027, blipsName = "Strawberry Sheriff Station"},
    {coords = vector3(2494.49, -1313.47, 48.95), blips = 1047294027, blipsName = "Saint Denis Sheriff Station"},
    {coords = vector3(1362.04, -1302.08, 77.77), blips = 1047294027, blipsName = "Rhodes Sheriff Station"},
    {coords = vector3(-768.04, -1266.44, 44.05), blips = 1047294027, blipsName = "Blackwater Sheriff Station"},
    {coords = vector3(2904.22, 1309.81, 44.94),  blips = 1047294027, blipsName = "Annesburg Sheriff Station"},
}

-- Configuration of warehouses with optional minimum grade
ConfigMain.Storage = {

    Valentine = {
        Name = "Storage", 
        Limit = 1000,
        Coords = vector3(-277.0, 810.92, 119.38),
        MinGrade = false, --false = only job needed, number = minimum grade
    },

    Strawberry = {
        Name = "Storage", 
        Limit = 1000,
        Coords = vector3(-1811.8, -353.6, 164.65),
        MinGrade = 2, -- Requires grade 2 or higher
    },

    SaintDenis = {
        Name = "Storage", 
        Limit = 1000,
        Coords = vector3(2494.49, -1313.47, 48.95),
        MinGrade = false,
    },

    Rhodes = {
        Name = "Storage", 
        Limit = 1000,
        Coords = vector3(1362.04, -1302.08, 77.77),
        MinGrade = false,
    },

    Blackwater = {
        Name = "Storage", 
        Limit = 1000,
        Coords = vector3(-768.04, -1266.44, 44.05),
        MinGrade = false,
    },

    Annesburg = {
        Name = "Storage", 
        Limit = 1000,
        Coords = vector3(2904.22, 1309.81, 44.94),
        MinGrade = false,
    },
}
