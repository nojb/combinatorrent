-- Haskell Torrent
-- Copyright (c) 2009, Jesper Louis Andersen,
-- All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are
-- met:
--
--  * Redistributions of source code must retain the above copyright
--    notice, this list of conditions and the following disclaimer.
--  * Redistributions in binary form must reproduce the above copyright
--    notice, this list of conditions and the following disclaimer in the
--    documentation and/or other materials provided with the distribution.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
-- IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
-- CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
-- EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
-- PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
-- PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
-- LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
-- NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

-- | The timer module is responsible for timing in the project. With
--   the timer system, we can register timers in the future and then
--   we can get a tick triggered at the point in time where we need to
--   act. This allows us to postpone events into the future at a
--   designated time.
--
--   The timer keeps a queue of ticks and when to send them out. It
--   keeps the amount of work it needs to do down to a minimum to
--   keeping a delta-time for each queue element and in earliest first
--   order. This is the same way most operating systems handles time
--   tracking and jlouis first heard about it as used in the BSD4.4
--   Unix implementation.
--
--   TODO: Get the timing code to work.
module TimerP (Tick(..),
               register,

               timer)

where

import Control.Concurrent.CHP

-- | A Tick is a single timer tick. It contains a version concept,
--   wherein an Integer defines what version we are currently waiting
--   for. The versioning allows silent cancel of future timer events
--   since a process can just ignore old ticks.
data Tick = Tick Integer

-- The internal type of timer channels.
type TimerChannel = Shared Chanout (Integer, Integer, Chanout Tick)

data State = MkState { timerQueue :: [(Integer, (Integer, Chanout Tick))] }

-- | Registers a timer tick on a channel in a number of seconds with
--   an annotated version.
register :: TimerChannel -> Integer -> Integer -> Chanout Tick -> CHP ()
register timerChannel secs version chan = do
  claim timerChannel (flip writeChannel (secs, version, chan))

-- | A timer process.
timer :: Shared Chanin (Integer, Integer, Chanout Tick) -> CHP ()
timer chan = lp (MkState [])
  where seconds x = x * 1000000
        lp s = do s' <- (waitFor (seconds 10) >> processTick s) <-> (processRegister s chan)
                  lp s'

processTick :: State -> CHP State
processTick s = do
  let q = timerQueue s
  case q of
    [] -> return s
    (_, (version, outC)) : t -> do writeChannel outC (Tick version)
                                   return $ s { timerQueue = t }

processRegister :: State -> Shared Chanin (Integer, Integer, Chanout Tick) -> CHP State
processRegister s inC = do (secs, version, outC) <- claim inC readChannel
                           return $ insertTick secs version outC
  where insertTick secs version outC = s {timerQueue = merge secs (version, outC) (timerQueue s)}
        merge secs tsk [] = [(secs, tsk)]
        merge secs tsk ((secs', tsk') : rest) | secs > secs' = (secs', tsk') : merge (secs - secs') tsk rest
                                              | otherwise =
                                                  (secs, tsk) : map (\(s', tsk'') -> (s' - secs, tsk'')) rest
