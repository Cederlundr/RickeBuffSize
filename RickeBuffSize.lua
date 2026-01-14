-- Defaults
local DEFAULT_BUFF_SIZE   = 24
local DEFAULT_DEBUFF_SIZE = 24
local DEFAULT_PLAYER_DEBUFF_SIZE = 24

-- SavedVariables table
RickeBuffSizeDB = RickeBuffSizeDB or {}

local buffSize
local debuffSize
local playerDebuffSize

-- Frame for events
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_TARGET_CHANGED")
f:RegisterEvent("UNIT_AURA")

-- Resize function
local function ResizeTargetAuras()
    -- Buffs (ALL buffs forced above everything)
    for i = 1, MAX_TARGET_BUFFS do
        local b = _G["TargetFrameBuff"..i]
        if b then
            -- Size
            if b:GetWidth() ~= buffSize then
                b:SetSize(buffSize, buffSize)
            end

            -- Layering (do this once)
            if not b.__buffRaised then
                b:SetFrameStrata("HIGH")
                b:SetFrameLevel(1000)
                b.__buffRaised = true
            end
        end
    end

    -- Debuffs (unchanged behavior)
    for i = 1, MAX_TARGET_DEBUFFS do
        local _, _, _, _, _, _, caster = UnitAura("target", i, "HARMFUL")
        local d = _G["TargetFrameDebuff"..i]
        if d then
            if caster == "player" then
                if d:GetWidth() ~= playerDebuffSize then
                    d:SetSize(playerDebuffSize, playerDebuffSize)
                end
            else
                if d:GetWidth() ~= debuffSize then
                    d:SetSize(debuffSize, debuffSize)
                end
            end
        end
    end
end

-- OnUpdate watcher (optimized)
local updateFrame = CreateFrame("Frame")
local elapsedSinceUpdate = 0
updateFrame:SetScript("OnUpdate", function(self, elapsed)
    elapsedSinceUpdate = elapsedSinceUpdate + elapsed
    if elapsedSinceUpdate >= 0.1 then
        ResizeTargetAuras()
        elapsedSinceUpdate = 0
    end
end)

-- Event handler
f:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "RickeBuffSize" then
        -- Load saved values or defaults
        buffSize         = RickeBuffSizeDB.buffSize or DEFAULT_BUFF_SIZE
        debuffSize       = RickeBuffSizeDB.debuffSize or DEFAULT_DEBUFF_SIZE
        playerDebuffSize = RickeBuffSizeDB.playerDebuffSize or DEFAULT_PLAYER_DEBUFF_SIZE

        ResizeTargetAuras()
        return
    end

    if event == "UNIT_AURA" and arg1 ~= "target" then return end
    ResizeTargetAuras()
end)

-- Buff size command
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

-- Debuff size command (non-player debuffs)
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
    print("|cff55ff55Target enemy debuffs (not cast by you) size set to|r", n)
end

-- Player-only debuff size command
SLASH_DEBUFFSIZEPLAYER1 = "/debuffsizeplayer"
SlashCmdList.DEBUFFSIZEPLAYER = function(msg)
    local n = tonumber(msg)
    if not n or n < 10 or n > 60 then
        print("|cffff5555Usage: /debuffsizeplayer <10-60>|r")
        return
    end
    playerDebuffSize = n
    RickeBuffSizeDB.playerDebuffSize = n
    ResizeTargetAuras()
    print("|cff55ff55Target debuffs cast by you (player) size set to|r", n)
end
