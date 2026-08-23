-- [[ AUTO 100x SKILL SAAT KAMU KLIK SKILL ]]
-- Buat Killer Hidden (Violence District)

local RS = game:GetService("ReplicatedStorage")

-- Ambil remote skill yang udah kita temukan
local m2Remote = RS.Remotes.Killers.Hidden.M2
local leapRemote = RS.Remotes.Killers.Hidden.Leap

-- Simpan fungsi asli biar ga error
local originalM2 = m2Remote.FireServer
local originalLeap = leapRemote.FireServer

-- === OVERRIDE FUNGSI M2 ===
m2Remote.FireServer = function(self, ...)
    print("🔪 [M2] Terdeteksi! Langsung spam 100x...")
    for i = 1, 100 do
        originalM2(self, ...)  -- Panggil skill asli
        task.wait(0.05)        -- Jeda 0.05 detik biar ga lag
    end
    print("✅ [M2] 100x selesai!")
end

-- === OVERRIDE FUNGSI LEAP ===
leapRemote.FireServer = function(self, ...)
    print("🦘 [Leap] Terdeteksi! Langsung spam 100x...")
    for i = 1, 100 do
        originalLeap(self, ...)
        task.wait(0.08)
    end
    print("✅ [Leap] 100x selesai!")
end

print("======================================")
print("✅ SCRIPT AKTIF!")
print("Sekarang setiap kamu klik skill M2 / Leap,")
print("otomatis bakal kepakai 100 KALI LANGSUNG!")
print("======================================")
