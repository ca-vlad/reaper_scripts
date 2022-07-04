--[[
  * ReaScript Name: Toggle hide filtered tracks in Track Manager
  * About:
      Toggles the `Hide filtered-out tracks in TCP` and `Hide filtered-out tracks in mixer`
      in the Track Manager (regardless of whether the Track Manager is opened).
  * Instructions:
      No special action needs to be taken.
  * Author: ca-vlad
  * Repository: GitHub > ca-vlad > reaper_scripts
  * Repository URI: https://github.com/ca-vlad/reaper_scripts
  * Licence: GPL v3
  * Version: 1.0
  * Version Date: 2022-07-04
  * REAPER: 6.61
  * Extensions:
    js_ReaScriptAPI
--]]

--[[
* Changelog:
* v1.0 (2022-07-04)
+ Initial Release
--]]


msg_flag=false  -- flag for debugging messages

function main()

  reaper.Undo_BeginBlock()

  local track_manager = reaper.JS_Window_Find('Track Manager', true)

  if track_manager then
    reaper.JS_Window_OnCommand(track_manager, 41734)
    reaper.JS_Window_OnCommand(track_manager, 41735)
  else

    reaper.Main_OnCommand(40906, 0) -- View: Show track manager window

    local track_manager = reaper.JS_Window_Find('Track Manager', true)
    reaper.JS_Window_OnCommand(track_manager, 41734)
    reaper.JS_Window_OnCommand(track_manager, 41735)

    reaper.Main_OnCommand(40906, 0) -- View: Show track manager window
  end

  reaper.UpdateArrange()

  reaper.Undo_EndBlock("TODO:", -1)

end

-- UTILITIES -------------------------------------------------------------

function msg(s) if msg_flag then reaper.ShowConsoleMsg(s .. '\n') end end

--------------------------------------------------------- END OF UTILITIES

main()