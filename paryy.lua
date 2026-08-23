-- Memuat VoidUI dari GitHub repository
local VoidUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/raphaelmaboi/ui-libraries/refs/heads/main/VoidUi/source.lua"))()

-- 1. Membuat Window Utama
local Window = VoidUI:CreateWindow({
    Name = "Panel Mandiri - VoidUI",
    LoadingTitle = "Memuat VoidUI...",
    LoadingSubtitle = "by Kamu",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "VoidUIConfigs",
        FileName = "MyConfig"
    }
})

-- 2. Membuat Tab Utama
local Tab = Window:CreateTab({
    Name = "Utama",
    Icon = "rbxassetid://6023426915" -- Contoh ikon info/menu
})

-- 3. Membuat Section / Bagian di dalam Tab
local Section = Tab:CreateSection({
    Name = "Fitur Utama"
})

-- 4. Menambahkan Tombol (Button)
Section:CreateButton({
    Name = "Tombol Aksi",
    Callback = function()
        print("Tombol VoidUI berhasil diklik!")
    end
})

-- 5. Menambahkan Tombol Geser (Toggle)
Section:CreateToggle({
    Name = "Auto Farm Aktif",
    CurrentValue = false,
    Flag = "Toggle1",
    Callback = function(Value)
        print("Status Toggle:", Value)
    end
})
