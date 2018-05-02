{-
waymonad A wayland compositor in the spirit of xmonad
Copyright (C) 2018  Markus Ongyerth

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

Reach us at https://github.com/ongy/waymonad
-}
{-# LANGUAGE ExistentialQuantification #-}
{-# LANGUAGE ScopedTypeVariables #-}
module Waymonad.Types.Core
where

import Control.Monad.IO.Class (MonadIO)
import Data.Bits ((.|.), shiftL)
import Data.IORef (IORef)
import Data.Set (Set)
import Data.Text (Text)
import Data.Typeable (Typeable)
import Data.Word (Word32)
import Foreign.Ptr (Ptr)

import Graphics.Pixman
import Graphics.Wayland.Signal (ListenerToken)
import Graphics.Wayland.WlRoots.Box (WlrBox, Point)
import Graphics.Wayland.WlRoots.Input.Keyboard (WlrKeyboard)
import Graphics.Wayland.WlRoots.Output (WlrOutput)
import Graphics.Wayland.WlRoots.Render.Color (Color)
import Graphics.Wayland.WlRoots.Surface (WlrSurface)

import Waymonad.Input.Cursor.Type
import Waymonad.Utility.HaskellSignal

import qualified Graphics.Wayland.WlRoots.Seat as R

-- | Sumtype to switch between pointer or keyboard
data SeatEvent
    = SeatKeyboard
    | SeatPointer
    deriving (Eq, Show)

data WayKeyState = WayKeyState
    { keyStateMods :: {-# UNPACK #-} !Word32
    , keyStateKey  :: {-# UNPACK #-} !Word32
    }

keystateAsInt :: WayKeyState -> Int
keystateAsInt (WayKeyState mods key) =
    fromIntegral key .|. (fromIntegral mods `shiftL` 32)

data Seat = Seat
    { seatRoots          :: Ptr R.WlrSeat
    , seatPointer        :: IORef (Maybe View)
    , seatKeyboard       :: IORef (Maybe View)
    , seatName           :: String
    , seatRequestDefault :: IO ()
    , seatLoadScale      :: Float -> IO ()
    , seatCursor         :: Cursor
    , seatColor          :: Color
    , seatKeyboards      :: IORef (Set (Ptr WlrKeyboard))
    , seatKeymap         :: IORef (WayKeyState -> IO Bool)
    }

class Typeable a => ShellSurface a where
    getSurface :: MonadIO m => a -> m (Maybe (Ptr WlrSurface))
    getSize :: MonadIO m => a -> m (Double, Double)
    resize :: MonadIO m => a -> Word32 -> Word32 -> m ()
    activate :: MonadIO m => a -> Bool -> m ()
    close :: MonadIO m => a -> m ()
    renderAdditional :: (Ptr WlrSurface -> WlrBox -> IO ()) -> a -> IO ()
    renderAdditional _ _ = pure ()
    getEventSurface :: MonadIO m => a -> Double -> Double -> m (Maybe (Ptr WlrSurface, Double, Double))
    setPosition :: MonadIO m => a -> Double -> Double -> m ()
    setPosition _ _ _ = pure ()
    getID :: a -> Int
    getTitle :: MonadIO m => a -> m (Maybe Text)
    getAppId :: MonadIO m => a -> m (Maybe Text)

    setViewHidden :: MonadIO m => a -> m ()
    setViewHidden _ = pure ()
    setViewVisible :: MonadIO m => a -> m ()
    setViewVisible _ = pure ()
    hasCSD         :: MonadIO m => a -> m Bool
    takesFocus :: MonadIO m => a -> SeatEvent -> m Bool
    takesFocus _ _ = pure True

data ManagerData = ManagerData
    { managerRemove      :: View -> IO ()
    , managerFocus       :: Seat -> View -> IO ()
    , managerApplyDamage :: View -> PixmanRegion32 -> IO ()
    , managerGetPosition :: View -> IO [(Ptr WlrOutput, Point)]
    }

data View = forall a. ShellSurface a => View
    { viewSurface  :: a
    , viewBox      :: IORef WlrBox
    , viewPosition :: IORef WlrBox
    , viewScaling  :: IORef Float
    , viewDestroy  :: HaskellSignal View IO
    , viewResize   :: HaskellSignal View IO
    , viewID       :: Int

    , viewManager  :: IORef (Maybe ManagerData)
    }

instance Show Seat where
    show = seatName

instance Eq Seat where
    l == r = seatRoots l == seatRoots r

instance Ord Seat where
    l `compare` r = seatRoots l `compare` seatRoots r


instance Show View where
    show v = show $ viewID v

instance Ord View where
    compare left right = compare (viewID left) (viewID right)

instance Eq View where
    left == right = viewID left == viewID right

