:set -fno-warn-orphans -Wno-type-defaults -XMultiParamTypeClasses -XOverloadedStrings
:set prompt ""

-- Import all the boot functions and aliases.
import Sound.Tidal.Boot

default (Rational, Integer, Double, Pattern String)

-- Create a Tidal Stream with the default settings.
-- To customize these settings, use 'mkTidalWith' instead
tidalInst <- mkTidal

-- tidalInst <- mkTidalWith [(superdirtTarget { oLatency = 0.01 }, [superdirtShape])] (defaultConfig {cFrameTimespan = 1/50, cProcessAhead = 1/20})

-- # START TIDAL CONNECTED TO SuperCollider AND Processing (removing above and adding processing target)
-- # !not tested with new installation...
-- processingTarget = Target { oName = "processing", oAddress = "127.0.0.1", oPort = 3333, oBusPort = Nothing, oLatency = 0.01, oWindow = Nothing, oSchedule = Live, oHandshake = False }
-- tidal <- startStream (defaultConfig {cFrameTimespan = 1/20}) [(superdirtTarget, [superdirtShape]), (processingTarget, [superdirtShape])]


-- This orphan instance makes the boot aliases work!
-- It has to go after you define 'tidalInst'.
instance Tidally where tidal = tidalInst

-- `enableLink` and `disableLink` can be used to toggle synchronisation using the Link protocol.
-- Uncomment the next line to enable Link on startup.
-- enableLink


-- CLOCK
-- sends tick pattern to supercollider which will then display basic clock information
let hush = do streamHush tidal; p "tick" $ "0*4" # s "tick"
p "tick" $ "0*4" # s "tick"


-- ALIASES

bpm b = setcps (b/4/60)

sidechain = pI "sidechain"
sidechain_thresh = pF "sidechain_thresh"
sidechain_compression = pF "sidechain_compression"
sidechain_attack = pF "sidechain_attack"
sidechain_release = pF "sidechain_release"

adsr a d s r = attack a # decay d # sustain s # release r
rvb r s      = room r # size s
tremolo r d  = tremolorate r # tremolodepth d
phaser  r d  = phaserrate r # phaserdepth d

sc o t       = sidechain o # sidechain_thresh (t/100) # sidechain_compression ("10"/100) # sidechain_attack ("1"/1000) # sidechain_release ("20"/100)

-- fibonacci sequence, gives nth term
:{
fib:: (Eq a, Num a, Num p) => a -> p
fib 0 = 0
fib 1 = 1
fib n = fib (n-1)+ fib (n-2)
:}


--

:set prompt "tidal> "
:set prompt-cont ""
