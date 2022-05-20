--[[
  * ReaScript Name: Select media tracks with at least one enabled FX
  * About:
      Selects all media tracks, from the entire project, that have at least one FX enabled.
      It ignores tracks' global FX toggle.
      It deselects all items.
  * Instructions:
      No special action needs to be taken.
  * Author: ca-vlad
  * Repository: GitHub > ca-vlad > reaper_scripts
  * Repository URI: https://github.com/ca-vlad/reaper_scripts
  * Licence: GPL v3
  * Version: 1.0
  * Version Date: 2022-05-19
  * REAPER: 6.56
  * Extensions:
--]]

--[[
* Changelog:
* v1.0 (2022-05-19)
+ Initial Release
--]]


msg_flag=false  -- flag for debugging messages

function main()

  reaper.Undo_BeginBlock()

  -- Deselect all items
  reaper.Main_OnCommand(40769, 0, 0)

  local i = 0
  while i < reaper.CountTracks(0) do
    local track = reaper.GetTrack(0, i)

    local track_folder_depth = reaper.GetMediaTrackInfo_Value(track, 'I_FOLDERDEPTH')
    -- msg("Track folder depth is " .. track_folder_depth)

    if track_folder_depth < 1 then
      local track_fx_count = reaper.TrackFX_GetCount(track)

      if track_fx_count > 0 then
        local track_has_any_enabled_fx = has_track_any_fx_enabled(track, track_fx_count)
        if track_has_any_enabled_fx == true then
          reaper.SetMediaTrackInfo_Value(track, "I_SELECTED", 1)

        end
      end
    end

    i = i + 1
  end

  reaper.UpdateArrange()

  reaper.Undo_EndBlock("Select media tracks with at least one enabled FX", -1)

end

-- UTILITIES -------------------------------------------------------------

function msg(s) if msg_flag then reaper.ShowConsoleMsg(s .. '\n') end end

function has_track_any_fx_enabled(track, track_fx_count)
  -- msg("Track enabled FX count is " .. track_fx_count)

  local j = 0
  while j < track_fx_count do
    local track_fx_enabled = reaper.TrackFX_GetEnabled(track, j)

    if track_fx_enabled == true then
      -- msg("Enabled FX number is" .. j)

      return track_fx_enabled
    end
    j = j + 1
  end

  return false

end

--------------------------------------------------------- END OF UTILITIES

main()
