local OBSTACLE_CONFIG = {
    ["Checkpoint"] = {
        orientation = {
            y = {-90, 90},
        },
        event_info = {
            event_name = "Checkpoint",
            apply_to = "Middle",
            event_trigger = "Touched"
        }
    },
    ["Three Lanes Obstacle"] = {
        size = {
            x = {1, 3},
            y = {1, 3},
            z = {1, 3},
        },
        orientation = {
            y = {-50, 50},
            x = {-30, 0}
            
        },
        groups = {
            ["Group1"] = {
                position = {
                    x = {-2, 2},
                    y = {-2, 2},
                    z = {-2, 2},
                },
                orientation = {
                    x = {-90, 90},
                },
                size = {
                    x = {0.5, 1},
                    y = {0.5, 1}
                }
            },
            ["Group2"] = {
                orientation = {
                    x = {-90, 90},
                },
                size = {
                    x = {1, 1},
                    y = {1, 1},
                    z = {1, 1},
                }
            },
            ["Group3"] = {
                orientation = {
                    x = {-90, 90},
                },
                size = {
                    x = {1, 3},
                    y = {1, 3},
                    z = {1, 3},
                }
            },
        }
    },
    ["Zig Zag Tight Rope1"] = {
        orientation = {
            y = {-30, 30},
            --x = {-30, 30},
            z  = {0, 30}
        }
    },
    ["Squares"] = {
        position = {
            x = {-4, 4},
            y = {-2, 2},
            z = {-2, 2},
        },
        orientation = {
            y = {-30, 30},
            x = {0, 30},
            --z  = {0, 30}
        },
        size = {
            x = {1, 1.5},
            y = {1, 1.5},
            z = {1, 1.5},
        }
    }
}

return OBSTACLE_CONFIG