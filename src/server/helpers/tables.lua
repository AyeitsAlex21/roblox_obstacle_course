local tableHelper = {}

function tableHelper.deepCopy(original)
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then
            copy[k] = tableHelper.deepCopy(v) -- Recursively copy nested tables
        else
            copy[k] = v
        end
    end
    return copy
end


return tableHelper