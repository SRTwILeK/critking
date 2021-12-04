
CRITKINGPREFIX = "CK"
CRITKINGVERSION = "0.5"

CritKing = {} -- critking class :)
CritKing.__index = CritKing

CritKingDisplay = CritKingDisplay or "on" -- saved variable, per character
CritKingResetOnNormalHit = CritKingResetOnNormalHit or "on" -- reset crit statistic when hit normal
CritKingSoundKill = CritKingSoundKill or "on" -- saved variable to play sound or not when kill monster
CritKingSoundCrit = CritKingSoundCrit or "on" -- saved variable to play sound or not when crit hit
CritKingAllCrit = CritKingAllCrit or 0

CritKing.VariablesLoaded = false

CritKing.PlayerGUID = ""  -- the player's character GUID

CritKing.MaxDamage = 0        -- The maximum damage
CritKing.MaxCritNum = 0       -- The maximum crit number
CritKing.Damage = 0           -- The actual damage
CritKing.CritNum = 0          -- The actual critical number
CritKing.KillNum = 0          -- The actual killing blow number
CritKing.MaxKillNum = 0       -- The maximum killing blow number
CritKing.CritMessages =
{
    "Head shot!"        -- 1
  , "Oh, Yeah!"         -- 2
  , "Unstoppable!"      -- 3
  , "Killing Spree!"    -- 4
  , "Dominating!"       -- 5
  , "Ultra Kill!"       -- 6
  , "Wicked Sick!"      -- 7
  , "God Like!"         -- 8
  , "God Like!"         -- 9
  , "Holy Shit!"        -- 10
  , "Holy Shit!"        -- 11
  , "Holy Shit!"        -- 12
  , "Holy Shit!"        -- 13
  , "Holy Shit!"        -- 14
  , "Monster Kill!"     -- 15
  , "Monster Kill!"     -- 16
  , "Monster Kill!"     -- 17
  , "Monster Kill!"     -- 18
  , "Monster Kill!"     -- 19
  , "Ludicrous Kill!"   -- 20
  , "Ludicrous Kill!"   -- 21
  , "Ownage!"           -- 22
}

CritKing.Critsounds = 
{
    "Interface\\Addons\\CritKing\\sounds\\head_shot.ogg"                -- 1
  , "Interface\\Addons\\CritKing\\sounds\\ohyeah.ogg"                   -- 2
  , "Interface\\Addons\\CritKing\\sounds\\unstoppable.ogg"              -- 3
  , "Interface\\Addons\\CritKing\\sounds\\killer.ogg"                   -- 4
  , "Interface\\Addons\\CritKing\\sounds\\dominating.ogg"               -- 5
  , "Interface\\Addons\\CritKing\\sounds\\ultrakill.ogg"                -- 6
  , "Interface\\Addons\\CritKing\\sounds\\wickedsick.ogg"               -- 7
  , "Interface\\Addons\\CritKing\\sounds\\godlike.ogg"                  -- 8
  , "Interface\\Addons\\CritKing\\sounds\\godlike.ogg"                  -- 9
  , "Interface\\Addons\\CritKing\\sounds\\holyshit.ogg"                 -- 10
  , "Interface\\Addons\\CritKing\\sounds\\holyshit.ogg"                 -- 11
  , "Interface\\Addons\\CritKing\\sounds\\holyshit.ogg"                 -- 12
  , "Interface\\Addons\\CritKing\\sounds\\holyshit.ogg"                 -- 13
  , "Interface\\Addons\\CritKing\\sounds\\holyshit.ogg"                 -- 14
  , "Interface\\Addons\\CritKing\\sounds\\monsterkill.ogg"              -- 15
  , "Interface\\Addons\\CritKing\\sounds\\monsterkill.ogg"              -- 16
  , "Interface\\Addons\\CritKing\\sounds\\monsterkill.ogg"              -- 17
  , "Interface\\Addons\\CritKing\\sounds\\monsterkill.ogg"              -- 18
  , "Interface\\Addons\\CritKing\\sounds\\monsterkill.ogg"              -- 19
  , "Interface\\Addons\\CritKing\\sounds\\ludicrouskill.ogg"            -- 20
  , "Interface\\Addons\\CritKing\\sounds\\ludicrouskill.ogg"            -- 21
  , "Interface\\Addons\\CritKing\\sounds\\ownage.ogg"                   -- 22
}

CritKing.KillingMessages =
{
    "First Blood!"          -- 1
  , "Double Kill!"          -- 2
  , "Tripple Kill!"         -- 3
  , "Multi Kill!"           -- 4
  , "Ultra Kill!"           -- 5
  , "Mega Kill!"            -- 6
  , "Monster Kill!"         -- 7
  , "Ludicrous Kill!"       -- 8
  , "Wicked Sick!"          -- 9
  , "Holy Shit!"            -- 10
  , "God Like!"             -- 11
  , "Ownage!"               -- 12
  , "Ownage!"               -- 13
  , "Ownage!"               -- 14
  , "Ownage!"               -- 14
  , "Ownage!"               -- 15
  , "I am INVICIBLE!"       -- 16
  , "I am INVICIBLE!"       -- 17
  , "I am INVICIBLE!"       -- 18
  , "I am INVICIBLE!"       -- 19
  , "YES! I'm a GOD!"       -- 20
}

CritKing.Killingsounds =
{
    "Interface\\Addons\\CritKing\\sounds\\firstblood.ogg"
  , "Interface\\Addons\\CritKing\\sounds\\doublekill.ogg"
  , "Interface\\Addons\\CritKing\\sounds\\tripplekill.ogg"
  , "Interface\\Addons\\CritKing\\sounds\\multikill.ogg"
  , "Interface\\Addons\\CritKing\\sounds\\ultrakill.ogg"
  , "Interface\\Addons\\CritKing\\sounds\\megakill.ogg"
  , "Interface\\Addons\\CritKing\\sounds\\monsterkill.ogg"
  , "Interface\\Addons\\CritKing\\sounds\\ludicrouskill.ogg"
  , "Interface\\Addons\\CritKing\\sounds\\wickedsick.ogg"
  , "Interface\\Addons\\CritKing\\sounds\\holyshit.ogg"
  , "Interface\\Addons\\CritKing\\sounds\\godlike.ogg"
  , "Interface\\Addons\\CritKing\\sounds\\ownage.ogg"
  , "Interface\\Addons\\CritKing\\sounds\\ownage.ogg"
  , "Interface\\Addons\\CritKing\\sounds\\ownage.ogg"
  , "Interface\\Addons\\CritKing\\sounds\\ownage.ogg"
  , "Interface\\Addons\\CritKing\\sounds\\invicible.ogg"
  , "Interface\\Addons\\CritKing\\sounds\\invicible.ogg"
  , "Interface\\Addons\\CritKing\\sounds\\invicible.ogg"
  , "Interface\\Addons\\CritKing\\sounds\\invicible.ogg"
  , "Interface\\Addons\\CritKing\\sounds\\god.ogg"
}

CritKing.MaxCrit = 23
CritKing.MaxKill = 21

-- Simple message function, to the default chat frame
function CritKing.SendMsg( msg )
    DEFAULT_CHAT_FRAME:AddMessage( CRITKINGPREFIX .. ": " .. msg, 0.598, 0.835, 0.89 )
end

-- Command handler
function CritKing.OnCommand( args )

    if ( ( args ~= nil      )
     and ( string.len( args ) > 0 ) )
    then
        if ( string.lower( args ) == "help" )
        then
            CritKing.SendMsg( "/ck display on  - enable error frame messages" )
            CritKing.SendMsg( "/ck display off - disable error frame messages" )
            CritKing.SendMsg( "/ck normal on - reset critical statistic when hit normal and end of fight" )
            CritKing.SendMsg( "/ck normal off - reset critical statistic just when end of fight" )
            CritKing.SendMsg( "/ck critsound on - enable sound when hit critical" )
            CritKing.SendMsg( "/ck critsound off - disable sound when hit critical" )
            CritKing.SendMsg( "/ck killsound on - enable sound when hit critical" )
            CritKing.SendMsg( "/ck killsound off - disable sound when hit critical" )
            CritKing.SendMsg( "/ck help - display this text" )
            CritKing.SendMsg( "/ck - display max damage, critical number, killing blow statistic" )
            return
        end

        if ( string.lower( args ) == "display on" )
        then
            CritKingDisplay = "on"
            CritKing.SendMsg( "set display on" )
            return
        end

        if ( string.lower( args ) == "display off" )
        then
            CritKingDisplay = "off"
            CritKing.SendMsg( "set display off" )
            return
        end

        if ( string.lower( args ) == "normal on" )
        then
            CritKingResetOnNormalHit = "on"
            CritKing.SendMsg( "reset critical statistic when hit normal" )
            return
        end

        if ( string.lower( args ) == "normal off" )
        then
            CritKingResetOnNormalHit = "off"
            CritKing.SendMsg( "no reset critical statistic when hit normal" )
            return
        end

        if ( string.lower( args ) == "critsound on" )
        then
            CritKingSoundCrit = "on"
            CritKing.SendMsg( "enable sound when hit critical" )
            return
        end

        if ( string.lower( args ) == "critsound off" )
        then
            CritKingSoundCrit = "off"
            CritKing.SendMsg( "disable sound when hit critical" )
            return
        end

        if ( string.lower( args ) == "killsound on" )
        then
            CritKingSoundKill = "on"
            CritKing.SendMsg( "enable sound when kill enemy" )
            return
        end

        if ( string.lower( args ) == "killsound off" )
        then
            CritKingSoundKill = "off"
            CritKing.SendMsg( "disable sound when kill enemy" )
            return
        end

        if ( string.lower( args ) == "sound on" )
        then
            CritKingSoundCrit = "on"
            CritKingSoundKill = "on"
            CritKing.SendMsg( "enable sound when hit critical and when kill enemy" )
            return
        end

        if ( string.lower( args ) == "sound off" )
        then
            CritKingSoundCrit = "off"
            CritKingSoundKill = "off"
            CritKing.SendMsg( "disable sound when hit critical and when kill enemy" )
            return
        end
    end

    local avgCritDmg = CritKing.SumCritDmg or 0 / CritKing.CritNum or 0
    if ( tostring( avgCritDmg ) == "-nan(ind)" ) then
        avgCritDmg = 0
    end

    -- no parameters given, show the infos
    CritKing.SendMsg( " - Max damage: " .. CritKing.MaxDamage )
    CritKing.SendMsg( " - Max crit num: " .. CritKing.MaxCritNum )
    CritKing.SendMsg( " - Max kill num: " .. CritKing.MaxKillNum )
    CritKing.SendMsg( " - Avg crit damage: " .. avgCritDmg )
    CritKing.SendMsg( " - All crit num: " .. CritKingAllCrit )
end

-- Fired when the player hit critical
function CritKing.OnCrit( action, num )

    CritKingAllCrit = CritKingAllCrit + 1

    if ( CritKingDisplay == "on" ) then
        local msg = CritKing.CritMessages[ num ]
        local fullMsg = msg .. " (x" .. CrtiKing.CritNum .. ") Damage: " .. CritKing.Damage .. " with: " .. action
        UIErrorsFrame:AddMessage( fullMsg )
        CrtiKing.SendMsg( fullMsg )
    end

    if ( CritKingSoundCrit == "on" ) then
        local sound = CritKing.Critsounds[ num ]
        PlaySoundFile( sound )
    end
end

-- Fired when the player kill an enemy
function CritKing.OnKill()
    if ( CritKingDisplay == "on" ) then
        local msg = CritKing.KillingMessages[ CritKing.KillNum ]
        local fullMsg = msg .. " (x" .. CritKing.KillNum .. ")" 
        UIErrorsFrame:AddMessage( fullMsg )
        CritKing.SendMsg( fullMsg )
    end

    if ( CritKingSoundKill == "on" ) then
        local sound = CritKing.Killingsounds[ CritKing.KillNum ]
        PlaySoundFile( sound )
    end
end

-- Reset critical statistric
function CritKing.ResetCrit()
    CritKing.CritNum = 0
--	CritKing.MaxDamage = 0
--	CritKing.MaxCrit = 0
end

-- Reset killing blow statistic
function CritKing.ResetKill()
    CritKing.KillNum = 0
--	CritKing.MaxKillNum = 0
end

-- Reset all statistic
function CritKing.ResetStat()
    CritKing.ResetCrit()
    CritKing.ResetKill()
    CritKing.SumCritDmg = 0
end

function CritKing.OnCombatLog( ... )
    local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...

    if ( sourceGUID == nil )
    then
        return
    end

    if ( sourceGUID ~= CritKing.PlayerGUID ) -- if the sender not equal with the player, just return
    then
        return
    end
    
    local spellId, spellName, spellSchool
    local amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand

    if subevent == "SWING_DAMAGE" then
        amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = select(12, ...)
    elseif subevent == "SPELL_DAMAGE" then
        spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = select(12, ...)
    end

    if ( subevent == "PARTY_KILL" )
    then
        CritKing.KillNum = CritKing.KillNum + 1
        if ( CritKing.MaxKillNum < CritKing.KillNum )
        then
            CritKing.MaxKillNum = CritKing.KillNum
        end

        if ( CritKing.KillNum < CritKing.MaxKill )
        then
            CritKing.OnKill()
        end

        return
    end

    if critical
    then
        local action = spellId and GetSpellLink( spellId ) or MELEE
        CritKing.CritNum = CritKing.CritNum + 1
        CritKing.Damage = amount
        CritKing.SumCritDmg = CritKing.SumCritDmg + amount

        if ( amount > CritKing.MaxDamage )
        then
            CritKing.MaxDamage = amount
        end
        
        if ( CritKing.CritNum > CritKing.MaxCritNum )
        then
            CritKing.MaxCritNum = CritKing.CritNum
        end
        
        local critNum = CritKing.CritNum
        if ( CritKing.CritNum >= CritKing.MaxCrit )
        then
            critNum = CritKing.MaxCrit - 1
        end

        CritKing.OnCrit( action, critNum )
    else
        if ( CritKingResetOnNormalHit == "on" )
        then
            CritKing.ResetCrit()
        end
    end

    return
end

-- Event handler
function CritKing.OnEvent(self, event, ...)
    if ( event == "VARIABLES_LOADED" ) -- loading saved variables, and player name
    then
        CritKing.VariablesLoaded = true
        CritKing.PlayerGUID = UnitGUID( "player" )
        CritKing.SendMsg( "variables loaded! " .. CRITKINGVERSION )
        return
    end

    if ( CritKing.VariablesLoaded == false ) -- no event handling, while saved variables not loaded ...
    then
        return
    end

    if ( event == "COMBAT_LOG_EVENT_UNFILTERED" ) -- new event from combatlog
    then
        CritKing.OnCombatLog( CombatLogGetCurrentEventInfo() )
    end
    
    if ( ( event == "PLAYER_REGEN_ENABLED" )   -- player enter, or leave from combat
      or ( event == "PLAYER_REGEN_DISABLED" ) )
    then
        CritKing.ResetStat()
        return
    end
end

local f = CreateFrame("Frame")
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
f:RegisterEvent("PLAYER_REGEN_DISABLED")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:RegisterEvent("VARIABLES_LOADED")
f:SetScript("OnEvent", CritKing.OnEvent)

SlashCmdList[ "CRK_CMD" ] = CritKing.OnCommand
SLASH_CRK_CMD1 = "/ck"
