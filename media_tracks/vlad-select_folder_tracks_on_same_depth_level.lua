--[[
  * ReaScript Name: Select folder tracks on same depth level
  * About:
      Adds all folder tracks on the same depth level, from the entire current project, to the selection.
  * Instructions:
      Select one single folder track and run the script.

  * Author: ca-vlad
  * Repository: GitHub > ca-vlad > reaper_scripts
  * Repository URI: https://github.com/ca-vlad/reaper_scripts
  * Licence: GPL v3
  * Version: 1.0
  * Version Date: 2022-05-09
  * REAPER: 6.56
  * Extensions:
--]]

--[[
* Changelog:
* v1.0 (2022-05-09)
+ Initial Release
--]]


msg_flag=false  -- flag for debugging messages

function main()

  reaper.Undo_BeginBlock()


  -- User input

  local count_selected_tracks = reaper.CountSelectedTracks(0)
  if count_selected_tracks ~= 1 then
    reaper.ShowMessageBox("Error: Please select one folder track", "Error", 0)
    return
  end

  local original_track = reaper.GetSelectedTrack(0, 0)
  local original_track_depth = reaper.GetTrackDepth(original_track)
  local original_track_folder_depth = reaper.GetMediaTrackInfo_Value(original_track, 'I_FOLDERDEPTH')

  if original_track_folder_depth ~= 1.0 then
    reaper.ShowMessageBox("Error: Please select one folder track", "Error", 0)
    return
  end

  -- msg("Track depth is " .. original_track_depth .. " folder depth is " .. original_track_folder_depth)

  local i = 0
  while i < reaper.CountTracks(0) do
    local track = reaper.GetTrack(0, i)

    local track_depth = reaper.GetTrackDepth(track)
    local track_folder_depth = reaper.GetMediaTrackInfo_Value(track, 'I_FOLDERDEPTH')
    if track_depth == original_track_depth and track_folder_depth == 1 then
      reaper.SetMediaTrackInfo_Value(track, "I_SELECTED", 1)
    end
    i = i + 1
  end

  reaper.UpdateArrange()

  reaper.Undo_EndBlock("Select folder tracks on same depth level", -1)

end

-- UTILITIES -------------------------------------------------------------

function msg(s) if msg_flag then reaper.ShowConsoleMsg(s .. '\n') end end

--------------------------------------------------------- END OF UTILITIES

main()
