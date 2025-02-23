local OBSTACLE_CONFIG = {
    ["Checkpoint"] = {
        orientation = {
            y = {-90, 90},
        }
    },
    ["Three Lanes Obstacle"] = {
        
        orientation = {
            y = {-50, 50},
            x = {-30, 0}
            
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
    },
    ["Hanged Platforms"] = {
        orientation = {
            y = {0, 30},
            x = {-30,  0}
        },
    },
    ["Zig Zag Tight Rope1"] = {
        orientation = {
            y = {-30, 30},
            --x = {-30, 30},
            z  = {0, 30}
        }
    },
    ["Squares"] = {
        orientation = {
            y = {-30, 30},
            x = {-30, 0},
            --z  = {0, 30}
        }
    }
}

return OBSTACLE_CONFIG