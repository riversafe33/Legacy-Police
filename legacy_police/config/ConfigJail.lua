ConfigJail = {}

-- true if the prisoner moves away from the prison beyond the EscapeDistance
-- they will automatically return to the prison and the time specified in EscapePenaltyTime will be added
-- false the prisoner can escape without anything happening

ConfigJail.EscapeConfig = {
    EnableEscapePenalty = true,
    EscapeDistance = 50.0,  -- distance at which the prisoner is returned to prison and EscapePenaltyTime is applied
    EscapePenaltyTime = 120 -- time in seconds
}

-- coordinates of the cleaning points that will appear
-- each time the prisoner cleans, their sentence time will be reduced
-- modify the amount of time to reduce in timeReduction, this time is in seconds
ConfigJail.jailchores = {
    { x = 3343.25, y = -692.97, z = 43.84, timeReduction = 10 },
    { x = 3353.74, y = -656.57, z = 45.3,  timeReduction = 10 },
    { x = 3367.22, y = -664.77, z = 46.27, timeReduction = 10 },
    { x = 3381.74, y = -675.51, z = 46.27, timeReduction = 10 },
    { x = 3360.21, y = -698.08, z = 45.13, timeReduction = 10 },
}

ConfigJail.Jails = {
     sisika = {
          entrance = { x = 3359.64, y = -668.57, z = 45.78 },
          exit = { x = 2670.49, y = -1545.06, z = 45.97 },
          Commisary = {
               enable = true, -- true enables a point in Sisika where the prisoner can collect water and food, they can only collect it once -- false there will be no point to collect water and food
               coords = { x = 3371.04, y = -658.16, z = 46.29 },
               Items = {
                   { name = "consumable_salmon_can", label = "Salmón en lata", amount = 1 },
                   { name = "water", label = "Agua", amount = 1 },
                   { name = "bread", label = "Pan", amount = 2 },
               }
          },
     },

     blackwater = {
          entrance = { x = -766.87, y = -1262.36, z = 44.02 },
          exit = { x = -755.13, y = -1269.58, z = 44.02 }
     },

     valentine = {
          entrance = { x = -273.05, y = 810.97, z = 119.37 },
          exit = { x = -276.76, y = 815.19, z = 119.21 }
     },

     armadillo = {
          entrance = { x = -3619.05, y = -2600.14, z = -13.34 },
          exit = { x = -3629.63, y = -2606.69, z = -13.73 }
     },

     tumbleweed = {
          entrance = { x = -5528.43, y = -2926.27, z = -1.36 },
          exit = { x = -5525.88, y = -2930.76, z = -2.01 }
     },

     strawberry = {
          entrance = { x = -1810.91, y = -351.38, z = 161.43 },
          exit = { x = -1806.98, y = -353.38, z = 164.15 }
     },

     rhodes = {
          entrance = { x = 1356.05, y = -1301.87, z = 77.76 },
          exit = { x = 1356.59, y = -1297.34, z = 76.81 }
     },

     stdenis = {
          entrance = { x = 2502.75, y = -1310.78, z = 48.95 },
          exit = { x = 2490.69, y = -1315.26, z = 48.87 }
     },

     annesburg = {
          entrance = { x = 2901.57, y = 1310.95, z = 44.93 },
          exit = { x = 2911.99, y = 1307.32, z = 44.66 }
     },
}