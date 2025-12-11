-- gtfo if u don't know how to use this

function AddToShared(val)
    shared.DEV = (shared.DEV or "") .. tostring(val) .. "\n"
end

return AddToShared
