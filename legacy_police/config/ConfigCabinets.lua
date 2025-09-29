ConfigCabinets = {}

-- allowedGrade = false -- no grade required to take a weapon or items
-- allowedGrade = 2 -- grade 2 or higher to take a weapon or items
ConfigCabinets.WeaponsandAmmo = {
     Weapons = {
          [1] = { weapon = "WEAPON_REVOLVER_LEMAT", label = "Lemat Revolver", allowedGrade = 4 },
          [2] = { weapon = "WEAPON_REPEATER_EVANS", label = "Evans Repeater", allowedGrade = 4 },
          [3] = { weapon = "WEAPON_LASSO_REINFORCED", label = "Reinforced Lasso", allowedGrade = 2 },
          [4] = { weapon = "WEAPON_MELEE_KNIFE", label = "Knife", allowedGrade = 2 }
     },
     Ammo = {
          [1] = { ammo = "ammorevolvernormal", label = "Munición de revólver", allowedGrade = 2 },
          [2] = { ammo = "ammorepeaternormal", label = "Munición de repetidora", allowedGrade = 2 },
          [3] = { ammo = "ammoriflenormal", label = "Munición de rifle", allowedGrade = 2 },
          [4] = { ammo = "ammoshotgunnormal", label = "Munición de escopeta", allowedGrade = 2 },
          [5] = { ammo = "handcuffs", label = "Esposas", allowedGrade = 2 }
     }
}

ConfigCabinets.Guncabinets = {
    [1] = { x = -279.1195, y = 805.1283,  z = 118.4004 },  -- Valentine
    [2] = { x = -1814.174, y = -355.3881, z = 163.6477 },  -- Strawberry
    [3] = { x = 2906.83,   y = 1315.31,   z = 44.94 },     -- Annesburg
    [4] = { x = -764.8386, y = -1273.058, z = 43.04159 },  -- Blackwater
    [5] = { x = 2494.58,   y = -1304.277, z = 47.97145 },  -- Saint Denis
    [6] = { x = 1361.76,   y = -1306.12,  z = 76.75977 },  -- Rhodes

}
