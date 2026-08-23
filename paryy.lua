-- [[ SPAM SKILL 100x DENGAN ARGUMEN ASLI ]]
-- Saat kamu klik tombol skill di HUD, otomatis di-spam 100x.

local RS = game:GetService("ReplicatedStorage")

-- Ambil remote skill yang sudah kita ketahui
local m2Remote = RS.Remotes.Killers.Hidden.M2
local leapRemote = RS.Remotes.Killers.Hidden.Leap

-- Fungsi untuk meng-override FireServer dengan aman
local function overrideRemote(remote)
    if not remote then return end
    
    -- Simpan fungsi asli
    local originalFire = remote.FireServer
    
    -- Override
    remote.FireServer = function(self, ...)
        -- Argumen asli dari game (misal posisi, target, dll)
        local args = {...}
        print("🔥 Skill " .. self.Name .. " dipakai dengan argumen:", args)
        
        -- Jalankan 100 kali
        for i = 1, 100 do
            pcall(originalFire, self, unpack(args))
            task.wait(0.015) -- delay 15ms biar ga overload
        end
        print("✅ Selesai spam " .. self.Name .. " 100x!")
    end
end

-- Override kedua remote
overrideRemote(m2Remote)
overrideRemote(leapRemote)

print("==========================================")
print("✅ SCRIPT AKTIF!")
print("📌 Sekarang main game, pilih Killer Hidden.")
print("📌 Klik tombol M2 atau Leap di HUD (seperti biasa).")
print("📌 Skill akan otomatis kepakai 100 KALI setiap kali kamu klik!")
print("==========================================")
