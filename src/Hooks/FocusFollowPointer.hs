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
module Hooks.FocusFollowPointer
where

import Control.Monad (void)

import Utility (These (..), doJust)
import ViewSet (FocusCore, WSTag)
import Waymonad.Types (SeatFocusChange (..), Way)
import WayUtil (setSeatOutput)
import WayUtil.Focus (focusView)
import WayUtil.Current (getPointerOutputS)


focusFollowPointer :: (WSTag ws, FocusCore vs ws) => SeatFocusChange -> Way vs ws ()
focusFollowPointer (PointerFocusChange  seat _ (Just view)) =
    doJust (getPointerOutputS seat) $ \output -> do
        setSeatOutput seat (That output)
        focusView view
focusFollowPointer _ = pure ()
