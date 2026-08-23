-- ============================================================
-- 🔥 REMOTE HUNTER + AUTO COPY (UNIVERSAL)
-- Menangkap SEMUA remote event yang dipanggil oleh script apapun
-- ============================================================

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Clipboard = setclipboard or set_clipboard or writeclipboard or function() end
local Output = warn or print

print("🔍 [REMOTE HUNTER] Aktif. Menunggu remote call dari script...")

-- ============================================================
-- HOOK SEMUA REMOTE EVENT & FUNCTION
-- ============================================================

local function hookAllRemotes()
    local mt = getrawmetatable(game)
    if not mt then
        print("❌ Gagal hook! Executor gak support getrawmetatable.")
        return
    end

    local oldNamecall = mt.__namecall
    local oldIndex = mt.__index
    
    setreadonly(mt, false)

    -- Daftar method yang mau di-hook
    local remoteMethods = {
        RemoteEvent = {"FireServer", "FireClient"},
        RemoteFunction = {"InvokeServer", "InvokeClient"},
        UnreliableRemoteEvent = {"FireServer", "FireClient"},
    }

    -- Simpan method asli
    local originalMethods = {}
    for class, methods in pairs(remoteMethods) do
        for _, method in ipairs(methods) do
            local inst = Instance.new(class)
            originalMethods[method] = inst[method]
            inst:Destroy()
        end
    end

    -- Hook __namecall
    mt.__namecall = function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        local isRemote = false
        
        -- Cek apakah ini remote call
        if self:IsA("RemoteEvent") or self:IsA("RemoteFunction") or self:IsA("UnreliableRemoteEvent") then
            if method == "FireServer" or method == "InvokeServer" then
                isRemote = true
            end
        end

        if isRemote then
            -- Format argumen
            local argsStr = ""
            for i, v in ipairs(args) do
                argsStr = argsStr .. tostring(v) .. " "
            end

            -- Copy ke clipboard
            local remotePath = self:GetFullName()
            local logMsg = string.format(
                "\n🔥 [REMOTE CAPTURED]\nPath: %s\nMethod: %s\nArgs: %s\n",
                remotePath, method, argsStr
            )
            Output(logMsg)

            -- Copy ke clipboard (langsung path + method + args)
            local clipboardContent = string.format(
                "Path: %s\nMethod: %s\nArgs: %s",
                remotePath, method, argsStr
            )
            pcall(function() Clipboard(clipboardContent) end)
            print("✅ Remote path sudah di-copy ke clipboard!")

            -- Simpan ke tabel global biar bisa diakses dari console
            _G.LAST_REMOTE = {
                Path = remotePath,
                Method = method,
                Args = args
            }
        end

        -- Panggil method asli
        return oldNamecall(self, ...)
    end

    -- Hook __index buat jaga-jaga
    mt.__index = function(self, key)
        return oldIndex(self, key)
    end

    setreadonly(mt, true)
    print("✅ Remote Hunter berhasil dipasang!")
end

-- Jalankan hook
pcall(hookAllRemotes)

-- ============================================================
-- LOAD SCRIPT KILLER KAMU DI SINI
-- ============================================================

-- [[ GANTI BARIS INI DENGAN LOADER SCRIPT KILLER ASLI KAMU ]]
-- Contoh:
loadstring(game:HttpGet("https://pastebin.com/raw/ABC12345"))()   -- <-- GANTI INI

print("✅ Script Killer berhasil dijalankan. Remote Hunter tetap aktif di background.")
print("📋 Setiap remote call akan otomatis di-copy ke clipboard.")
print("📌 Cek _G.LAST_REMOTE untuk remote terakhir.")

-- ============================================================
-- KONSOLE COMMAND (opsional) buat nampilin remote terakhir
-- ============================================================
task.spawn(function()
    while task.wait(5) do
        if _G.LAST_REMOTE then
            local r = _G.LAST_REMOTE
            print(string.format("📌 Remote terakhir: %s (%s) args: %s", r.Path, r.Method, table.concat(r.Args, ", ")))
        end
    end
end)
