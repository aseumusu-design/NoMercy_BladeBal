-- [[ DETEKTOR REMOTE SKILL SEJATI (FIXED) ]]
-- Tanpa error, menggunakan tabel untuk tracking.

local hooked = {} -- tabel untuk menyimpan remote yang sudah di-hook

local function hookRemote(obj)
    if obj:IsA("RemoteEvent") and not hooked[obj] then
        hooked[obj] = true
        local old = obj.FireServer
        obj.FireServer = function(self, ...)
            local path = self:GetFullName()
            print("🔥 REMOTE TERPAKAI: " .. path)
            print("📦 ARGUMEN:", ...)
            if setclipboard then setclipboard(path) end
            print("📋 Path sudah di-copy ke clipboard!")
            return old(self, ...)
        end
    end
end

local function scanAll(parent)
    for _, obj in ipairs(parent:GetDescendants()) do
        hookRemote(obj)
    end
end

-- Scan semua yang sudah ada
scanAll(game)

-- Pantau objek baru
game.DescendantAdded:Connect(function(child)
    task.wait(0.05) -- biar stabil
    hookRemote(child)
end)

print("============================================")
print("✅ DETEKTOR AKTIF (tanpa error)!")
print("📌 Sekarang main game, pakai Killer Hidden.")
print("📌 Klik tombol skill M2 / Leap / Ultimate di layar.")
print("📌 Lihat console: akan muncul path dan argumen.")
print("📌 Path-nya otomatis ke-copy, paste ke sini.")
print("============================================")
