-- Defaults
local DEFAULT_BUFF_SIZE   = 24
local DEFAULT_DEBUFF_SIZE = 24

-- SavedVariables table
RickeBuffSizeDB = RickeBuffSizeDB or {}

local buffSize
local debuffSize

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_TARGET_CHANGED")
f:RegisterEvent("UNIT_AURA")

local function ResizeTargetAuras()
    -- Buffs
    for i = 1, MAX_TARGET_BUFFS do
        local b = _G["TargetFrameBuff"..i]
        if b then
            b:SetSize(buffSize, buffSize)
        end
    end

    -- Debuffs
    for i = 1, MAX_TARGET_DEBUFFS do
        local d = _G["TargetFrameDebuff"..i]
        if d then
            d:SetSize(debuffSize, debuffSize)
        end
    end
end

f:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "RickeBuffSize" then
        -- Load saved values or defaults
        buffSize   = RickeBuffSizeDB.buffSize   or DEFAULT_BUFF_SIZE
        debuffSize = RickeBuffSizeDB.debuffSize or DEFAULT_DEBUFF_SIZE

        -- Apply once after login
        C_Timer.After(0, ResizeTargetAuras)
        return
    end

    if event == "UNIT_AURA" and arg1 ~= "target" then return end
    C_Timer.After(0, ResizeTargetAuras)
end)

-- Slash commands
SLASH_BUFFSIZE1 = "/buffsize"
SlashCmdList.BUFFSIZE = function(msg)
    local n = tonumber(msg)
    if not n or n < 10 or n > 60 then
        print("|cffff5555Usage: /buffsize <10-60>|r")
        return
    end
    buffSize = n
    RickeBuffSizeDB.buffSize = n
    ResizeTargetAuras()
    print("|cff55ff55Target buff size set to|r", n)
end

SLASH_DEBUFFSIZE1 = "/debuffsize"
SlashCmdList.DEBUFFSIZE = function(msg)
    local n = tonumber(msg)
    if not n or n < 10 or n > 60 then
        print("|cffff5555Usage: /debuffsize <10-60>|r")
        return
    end
    debuffSize = n
    RickeBuffSizeDB.debuffSize = n
    ResizeTargetAuras()
    print("|cff55ff55Target debuff size set to|r", n)
end
