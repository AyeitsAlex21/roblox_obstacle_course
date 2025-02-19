local OBSTACLE_CONFIG = {
    ["Three Lanes Obstacle"] = {
        orientation = {
            x = {0, 1},
            y = {-30, 0},
            z = {-20, 20}
        },
        size = {
            x = {1, 2},
            y = {1, 2},
            z = {1, 2}
        },
        position = {
            x = {5, -5},
            y = {-2, 5},
            z = {-5, 5}
        },
        groups = {
            ["Group1"] = {
                orientation = {
                    x = {-90, 90},
                }
            },
            ["Group2"] = {
                orientation = {
                    x = {-90, 90},
                }
            },
            ["Group3"] = {
                orientation = {
                    x = {-90, 90},
                }
            },
        }
    }
}

return OBSTACLE_CONFIG