--[[
  * ReaScript Name: Select media tracks with at least one online FX
  * About:
      Selects all media tracks, from the entire project, that have at least one FX online.
      It ignores tracks' FX bypass, and individual FX bypass.
      It deselects all items before execution.
  * Instructions:
      No special action needs to be taken.
  * Author: ca-vlad
  * Repository: GitHub > ca-vlad > reaper_scripts
  * Repository URI: https://github.com/ca-vlad/reaper_scripts
  * Licence: GPL v3
  * Version: 1.0
  * Version Date: 2022-05-20
  * REAPER: 6.56
  * Extensions:
--]]

--[[
* Changelog:
* v1.0 (2022-05-20)
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
        local track_has_any_online_fx = has_track_any_fx_online(track, track_fx_count)
        if track_has_any_online_fx == true then
          reaper.SetMediaTrackInfo_Value(track, "I_SELECTED", 1)

        end
      end
    end

    i = i + 1
  end

  reaper.UpdateArrange()

  reaper.Undo_EndBlock("Select media tracks with at least one online FX", -1)

end

-- UTILITIES -------------------------------------------------------------

function msg(s) if msg_flag then reaper.ShowConsoleMsg(s .. '\n') end end

function has_track_any_fx_online(track, track_fx_count)
  -- msg("Track online FX count is " .. track_fx_count)

  local j = 0
  while j < track_fx_count do
    local track_fx_online = not reaper.TrackFX_GetOffline(track, j)

    if track_fx_online ~= false then
      -- msg("Online FX number is" .. j)

      return track_fx_online
    end
    j = j + 1
  end

  return false

end

--------------------------------------------------------- END OF UTILITIES

main()
