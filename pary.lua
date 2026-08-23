-- [[ SPAM LEAP + M2 HIDDEN - TANPA JEDA ]]
-- Copas ke executor, Execute, lalu main.

local RS = game:GetService("ReplicatedStorage")
local leap = RS.Remotes.Killers.Hidden.Leap
local m2 = RS.Remotes.Killers.Hidden.M2

-- Fungsi reset cooldown di semua tabel memory
local function resetCD()
    local count = 0
    for _, v in pairs(getgc(true)) do
        if type(v) == "table" then
            -- Cari properti yang mirip cooldown
            if rawget(v, "Cooldown") ~= nil then
                rawset(v, "Cooldown", 0)
                count = count + 1
            end
            if rawget(v, "cooldown") ~= nil then
                rawset(v, "cooldown", 0)
                count = count + 1
            end
            if rawget(v, "CD") ~= nil then
                rawset(v, "CD", 0)
                count = count + 1
            end
            if rawget(v, "LastUsed") ~= nil then
                rawset(v, "LastUsed", 0)
                count = count + 1
            end
            if rawget(v, "lastUsed") ~= nil then
                rawset(v, "lastUsed", 0)
                count = count + 1
            end
        end
    end
    if count > 0 then
        -- print("✅ CD reset: " .. count .. " nilai diubah.")
    end
end

-- Jalankan reset CD setiap 0.5 detik (biar selalu 0)
task.spawn(function()
    while task.wait(0.5) do
        resetCD()
    end
end)

print("🔁 CD Auto-Reset aktif!")

-- Spam Leap + M2 setiap 0.01 detik (sangat cepat)
print("🚀 Mulai spam Leap + M2 tanpa henti...")
while task.wait(0.01) do
    pcall(leap.FireServer, leap)
    pcall(m2.FireServer, m2)
    -- Tambahkan skill lain jika mau:
    -- local m2Hit = RS.Remotes.Killers.Hidden.m2HitVM
    -- pcall(m2Hit.FireServer, m2Hit)
end
