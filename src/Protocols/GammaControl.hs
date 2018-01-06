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
module Protocols.GammaControl
    ( getGammaBracket
    )
where

import Control.Monad.IO.Class (liftIO)
import Foreign.Ptr (Ptr)

import Graphics.Wayland.Server (DisplayServer)
import Graphics.Wayland.WlRoots.GammaControl

import Shared (Bracketed (..))
import Waymonad (makeCallback)
import Waymonad.Types (Way)

makeManager :: DisplayServer -> Way a (Ptr WlrGammaManager)
makeManager = liftIO . createGammaManager

getGammaBracket :: Way a (Bracketed (DisplayServer))
getGammaBracket = do
    cb <- makeCallback makeManager
    pure $ Bracketed cb destroyGammaManager
