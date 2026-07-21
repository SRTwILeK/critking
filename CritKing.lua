
CRITKINGPREFIX = "CK"

-- Read the version straight from the .toc (## Version) so it lives in one place.
-- C_AddOns.GetAddOnMetadata on newer clients, the global on TBC Classic (2.5.x).
local GetMeta = ( C_AddOns and C_AddOns.GetAddOnMetadata ) or GetAddOnMetadata
CRITKINGVERSION = ( GetMeta and GetMeta( "CritKing", "Version" ) ) or "1.0"

CritKing = {} -- critking class :)
CritKing.__index = CritKing

CritKingVarsDefault = {
    Display = true,
    ResetOnNormalHit = true,
    Sound = {
        Kill = true,
        Crit = true,
        Ach = {
            Crit = true
        }
    },
    Stat = {
        Sum = {
            Crit = 0,
            Kill = 0
        }
    }
}

function CritKingLoadVar( objSrc, objDst )
    if ( objDst == nil ) then
        objDst = {}
    end
    for key, value in pairs( objSrc ) do
        if ( type( value ) == 'table' ) then
            if ( type( objDst[ key ] ) ~= 'table' ) then
                objDst[ key ] = {}
            end
            CritKingLoadVar( value, objDst[ key ] )
        elseif ( objDst[ key ] == nil ) then
            objDst[ key ] = value
        end
    end

    return objDst
end


--CritKingDisplay = CritKingDisplay or "on" -- saved variable, per character
--CritKingResetOnNormalHit = CritKingResetOnNormalHit or "on" -- reset crit statistic when hit normal
--CritKingSoundKill = CritKingSoundKill or "on" -- saved variable to play sound or not when kill monster
--CritKingSoundCrit = CritKingSoundCrit or "on" -- saved variable to play sound or not when crit hit
--CritKingAllCrit = CritKingAllCrit or 0

CritKing.VariablesLoaded = false

CritKing.PlayerGUID = ""  -- the player's character GUID

CritKing.MaxDamage = 0        -- The maximum damage
CritKing.MaxCritNum = 0       -- The maximum crit number
CritKing.Damage = 0           -- The actual damage
CritKing.CritNum = 0          -- The actual critical number
CritKing.KillNum = 0          -- The actual killing blow number
CritKing.MaxKillNum = 0       -- The maximum killing blow number
CritKing.SumCritDmg = 0       -- Sum of crit damage in the current combat
CritKing.SumCritCount = 0     -- Number of crits in the current combat
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
  , "Triple Kill!"          -- 3
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
  , "I am INVINCIBLE!"-- 16
  , "I am INVINCIBLE!"-- 17
  , "I am INVINCIBLE!"-- 18
  , "I am INVINCIBLE!"-- 19
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
  , "Interface\\Addons\\CritKing\\sounds\\invincible.ogg"
  , "Interface\\Addons\\CritKing\\sounds\\invincible.ogg"
  , "Interface\\Addons\\CritKing\\sounds\\invincible.ogg"
  , "Interface\\Addons\\CritKing\\sounds\\invincible.ogg"
  , "Interface\\Addons\\CritKing\\sounds\\god.ogg"
}

CritKing.Sum = {
    Crit = {
        ['10'] = {
            sound = "Interface\\Addons\\CritKing\\sounds\\ohyeah.ogg",
            msg = "10 critical hits!!! Ohhh yeah!!!"
        },
        ['1000'] = {
            sound = "Interface\\Addons\\CritKing\\sounds\\ohyeah.ogg",
            msg = "1000 critical hits!!! Ohhh yeah!!! Great job!"
        },
        ['5000'] = {
            sound = "Interface\\Addons\\CritKing\\sounds\\killer.ogg",
            msg = "5000 critical hits!!! You are a killing machine!"
        },
        ['10000'] = {
            sound = "Interface\\Addons\\CritKing\\sounds\\holyshit.ogg",
            msg = "10000 critical hits!!! Holy shit! You are awesome!!"
        },
        ['13200'] = {
            sound = "Interface\\Addons\\CritKing\\sounds\\monsterkill.ogg",
            msg = "13200 critical hits!!! Critter killer!"
        },
        ['18000'] = {
            sound = "Interface\\Addons\\CritKing\\sounds\\monsterkill.ogg",
            msg = "18000 critical hits!!! Killing machine! You are the best!"
        },
        ['20000'] = {
            sound = "Interface\\Addons\\CritKing\\sounds\\ownage.ogg",
            msg = "20000 critical hits!!! Ohhhh mmmmmyyyy goooooooodddddd!!!"
        }
    }
}

CritKing.MaxCrit = 23
CritKing.MaxKill = 21

function CritKing.AchCrit( critNum )
    local ach = CritKing.Sum.Crit[ tostring(critNum ) ]
    if ( ach ~= nil ) then
        if ( CritKingVars.Display ) then
            UIErrorsFrame:AddMessage( ach.msg )
            CritKing.SendMsg( ach.msg )
        end
    
        if ( CritKingVars.Sound.Ach.Crit ) then
            PlaySoundFile( ach.sound )
        end
    
    end
end

-- Simple message function, to the default chat frame
function CritKing.SendMsg( msg )
    DEFAULT_CHAT_FRAME:AddMessage( CRITKINGPREFIX .. ": " .. msg, 0.598, 0.835, 0.89 )
end

function CritKing.ShowSettings()
    local msg = 'Display: ' .. tostring( CritKingVars.Display ) .. ', Reset after normal hit: ' .. tostring( CritKingVars.ResetOnNormalHit )
            .. ', Kill sound: ' .. tostring( CritKingVars.Sound.Kill ) .. ', Crit sound: ' .. tostring( CritKingVars.Sound.Crit )
            .. ', Achievement crit sound: ' .. tostring( CritKingVars.Sound.Ach.Crit )
            .. ', Total crits: ' .. tostring( CritKingVars.Stat.Sum.Crit ) .. ', Total kills: ' .. tostring( CritKingVars.Stat.Sum.Kill )

    CritKing.SendMsg( "Settings: " .. msg )
end

-- Command handler
function CritKing.OnCommand( args )

    if ( ( args ~= nil      )
     and ( string.len( args ) > 0 ) )
    then
        if ( string.lower( args ) == "help" )
        then
            CritKing.SendMsg( "/ck display on  - enable on-screen messages" )
            CritKing.SendMsg( "/ck display off - disable on-screen messages" )

            CritKing.SendMsg( "/ck normal on - reset the crit streak on a normal hit and at the end of a fight" )
            CritKing.SendMsg( "/ck normal off - reset the crit streak only at the end of a fight" )

            CritKing.SendMsg( "/ck critsound on - enable the sound when you land a critical hit" )
            CritKing.SendMsg( "/ck critsound off - disable the sound when you land a critical hit" )
            CritKing.SendMsg( "/ck killsound on - enable the sound when you kill an enemy" )
            CritKing.SendMsg( "/ck killsound off - disable the sound when you kill an enemy" )
            CritKing.SendMsg( "/ck sound on - enable the sound for both critical hits and kills" )
            CritKing.SendMsg( "/ck sound off - disable the sound for both critical hits and kills" )

            CritKing.SendMsg( "/ck ach critsound on - enable the sound when you reach a crit achievement" )
            CritKing.SendMsg( "/ck ach critsound off - disable the sound when you reach a crit achievement" )

            CritKing.SendMsg( "/ck show settings - show the current settings" )
            CritKing.SendMsg( "/ck help - show this text" )

            CritKing.SendMsg( "/ck fullreset - reset all statistics" )

            CritKing.SendMsg( "/ck - show max damage, critical-hit and killing-blow statistics" )
            return
        end

        if ( string.lower( args ) == "display on" )
        then
            CritKingVars.Display = true
            --CritKingDisplay = "on"
            CritKing.SendMsg( "On-screen messages enabled." )
            return
        end

        if ( string.lower( args ) == "display off" )
        then
            CritKingVars.Display = false
            --CritKingDisplay = "off"
            CritKing.SendMsg( "On-screen messages disabled." )
            return
        end

        if ( string.lower( args ) == "normal on" )
        then
            CritKingVars.ResetOnNormalHit = true
            CritKing.SendMsg( "The crit streak will now reset on a normal hit." )
            return
        end

        if ( string.lower( args ) == "normal off" )
        then
            CritKingVars.ResetOnNormalHit = false
            CritKing.SendMsg( "The crit streak will no longer reset on a normal hit." )
            return
        end

        if ( string.lower( args ) == "critsound on" )
        then
            CritKingVars.Sound.Crit = true
            CritKing.SendMsg( "Sound enabled for critical hits." )
            return
        end

        if ( string.lower( args ) == "critsound off" )
        then
            CritKingVars.Sound.Crit = false
            CritKing.SendMsg( "Sound disabled for critical hits." )
            return
        end

        if ( string.lower( args ) == "killsound on" )
        then
            CritKingVars.Sound.Kill = true
            CritKing.SendMsg( "Sound enabled for kills." )
            return
        end

        if ( string.lower( args ) == "killsound off" )
        then
            CritKingVars.Sound.Kill = false
            CritKing.SendMsg( "Sound disabled for kills." )
            return
        end

        if ( string.lower( args ) == "sound on" )
        then
            CritKingVars.Sound.Crit = true
            CritKingVars.Sound.Kill = true
            CritKing.SendMsg( "Sound enabled for critical hits and kills." )
            return
        end

        if ( string.lower( args ) == "sound off" )
        then
            CritKingVars.Sound.Crit = false
            CritKingVars.Sound.Kill = false
            CritKing.SendMsg( "Sound disabled for critical hits and kills." )
            return
        end

        if ( string.lower( args ) == "ach critsound on" )
        then
            CritKingVars.Sound.Ach.Crit = true
            CritKing.SendMsg( "Sound enabled for crit achievements." )
            return
        end

        if ( string.lower( args ) == "ach critsound off" )
        then
            CritKingVars.Sound.Ach.Crit = false
            CritKing.SendMsg( "Sound disabled for crit achievements." )
            return
        end

        if ( string.lower( args ) == "show settings" )
        then
            CritKing.ShowSettings()
            return
        end

        if ( string.lower( args ) == "fullreset" )
        then
            CritKingVars.Stat.Sum.Crit = 0
            CritKingVars.Stat.Sum.Kill = 0
            CritKing.ResetStat()
            return
        end
    end

    local avgCritDmg = 0
    if ( CritKing.SumCritCount > 0 ) then
        avgCritDmg = math.floor( CritKing.SumCritDmg / CritKing.SumCritCount )
    end

    -- no parameters given, show the infos
    CritKing.SendMsg( " - Max damage: " .. CritKing.MaxDamage )
    CritKing.SendMsg( " - Highest crit streak: " .. CritKing.MaxCritNum )
    CritKing.SendMsg( " - Highest kill streak: " .. CritKing.MaxKillNum )
    CritKing.SendMsg( " - Average crit damage: " .. avgCritDmg )
    CritKing.SendMsg( " - Total critical hits: " .. CritKingVars.Stat.Sum.Crit )
    CritKing.SendMsg( " - Total kills: " .. CritKingVars.Stat.Sum.Kill )
end

-- Fired when the player hit critical
function CritKing.OnCrit( action, num )

    CritKingVars.Stat.Sum.Crit = CritKingVars.Stat.Sum.Crit + 1

    CritKing.AchCrit( CritKingVars.Stat.Sum.Crit )

    if ( CritKingVars.Display ) then
        local msg = CritKing.CritMessages[ num ]
        local fullMsg = msg .. " (x" .. CritKing.CritNum .. ") Damage: " .. CritKing.Damage .. " with: " .. action
        UIErrorsFrame:AddMessage( fullMsg )
        CritKing.SendMsg( fullMsg )
    end

    if ( CritKingVars.Sound.Crit ) then
        local sound = CritKing.Critsounds[ num ]
        PlaySoundFile( sound )
    end
end

-- Fired when the player kill an enemy
function CritKing.OnKill()

    CritKingVars.Stat.Sum.Kill = CritKingVars.Stat.Sum.Kill + 1

    if ( CritKingVars.Display ) then
        local msg = CritKing.KillingMessages[ CritKing.KillNum ]
        local fullMsg = msg .. " (x" .. CritKing.KillNum .. ")" 
        UIErrorsFrame:AddMessage( fullMsg )
        CritKing.SendMsg( fullMsg )
    end

    if ( CritKingVars.Sound.Kill ) then
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
    CritKing.SumCritCount = 0
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
    local isDamage = false

    if subevent == "SWING_DAMAGE" then
        amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = select(12, ...)
        isDamage = true
    elseif ( subevent == "SPELL_DAMAGE" ) or ( subevent == "RANGE_DAMAGE" ) then
        spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = select(12, ...)
        isDamage = true
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

    if ( not isDamage ) -- only damage events affect the crit streak
    then
        return
    end

    if critical
    then
        local action = spellId and GetSpellLink( spellId ) or MELEE
        CritKing.CritNum = CritKing.CritNum + 1
        CritKing.Damage = amount
        CritKing.SumCritDmg = CritKing.SumCritDmg + amount
        CritKing.SumCritCount = CritKing.SumCritCount + 1

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
        if ( CritKingVars.ResetOnNormalHit )
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
        CritKing.SendMsg( "Loaded! Version " .. CRITKINGVERSION )
		CritKingVars = CritKingLoadVar( CritKingVarsDefault, CritKingVars )

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
