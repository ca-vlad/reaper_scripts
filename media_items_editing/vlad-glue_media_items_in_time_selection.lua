--[[
  * ReaScript Name: Glue media items in time selection
  * About:
      Glues a chosen number of adjacent Media Items from the selected tracks within a time selection.
      It will glue overlapping Media Items in the same track. It will also use the active take, when applicable.
  * Instructions:
      1. Make a time selection, and select tracks on which you wish to glue Media Items.
      2. Run the script, and choose the number of adjacent Media Items you wish to glue. Choosing 0 will glue all Media Items within the time selection.
  * Author: ca-vlad
  * Repository: GitHub > ca-vlad > reaper_scripts
  * Repository URI: https://github.com/ca-vlad/reaper_scripts
  * Licence: GPL v3
  * Version: 1.2
  * Version Date: 2022-03-02
  * REAPER: 6.43
  * Extensions:
--]]

--[[
* Changelog:
* v1.2 (2022-03-08)
  # Fix a bug where the last media item is glued even if it's the only remaining unglued item in the time selection
* v1.1 (2022-03-02)
  # Fix a bug in the get_items_in_time_selection_on_track related to loop indexing
  # Add more debugging messages
  # Comment out all debugging messages
* v1.0 (2022-01-25)
+ Initial Release
--]]


msg_flag=true  -- flag for debugging messages

function main()

  reaper.Undo_BeginBlock()

  msg("____________")

  -- User input
  local retval, retvals_csv = reaper.GetUserInputs("Glue groups of adjacent Media Items", 1, "Number of adjacent Media Items", "2")
  if retval == false then
    return
  end

  local number_of_items_to_glue = tonumber(retvals_csv)
  if number_of_items_to_glue == 1 then
    reaper.ShowMessageBox("Error: Please choose the number of adjacent items to glue \nChoose:\n 2 or more \n 0 for all Media Items within the time selection", "Error", 0)
    return
  end


  local count_selected_tracks = reaper.CountSelectedTracks(0)
  if count_selected_tracks < 1 then
    reaper.ShowMessageBox("Error: Please select at least one track", "Error", 0)
    return
  end

  local time_start, time_end = reaper.GetSet_LoopTimeRange(false, false, 1, 1, false)
  if time_start == time_end then
    reaper.ShowMessageBox("Error: Please select a time range", "Error", 0)
    return
  end

  -- Loop through all tracks
  for i=0, count_selected_tracks-1 do

  -- Deselect Media Items, to not interfere with the glue command
    reaper.Main_OnCommand(40289, 0, 0)

    local track = reaper.GetSelectedTrack(0, i)

    local tracknumber = reaper.GetMediaTrackInfo_Value(track, 'IP_TRACKNUMBER')

    local retval, stringNeedBig = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", 0)
    -- msg("Track number for " .. stringNeedBig .. " is " .. tracknumber)

    local items_on_track = get_items_in_time_selection_on_track(time_start, time_end, track)

    -- Loop through items within the time selection on track
    -- The iteration number is used to select groups of adjacent Media Items
    local iteration_number = 1
    for _, item in pairs(items_on_track) do

      msg("Iteration number is " .. iteration_number)
      msg(_ .. "    " .. reaper.GetTakeName(reaper.GetActiveTake(item)))

      ok = reaper.SetMediaItemInfo_Value(item, "B_UISEL", 1)

      if iteration_number == number_of_items_to_glue then

        iteration_number = 1 -- Reset iteration number
        reaper.Main_OnCommand(40362, 0, 0) -- Glue selected MediaItems
        reaper.Main_OnCommand(40289, 0, 0) -- Deselect MediaItems
        -- msg("Resetting iteration number")

      else

        iteration_number = iteration_number + 1

      end

    end

    -- Glue remaining selected MediaItems on track
    if iteration_number > 2 then
      reaper.Main_OnCommand(40362, 0, 0) -- Glue selected MediaItems
      reaper.Main_OnCommand(40289, 0, 0) -- Deselect MediaItems
    end

  end

  reaper.UpdateArrange()

  reaper.Undo_EndBlock("Glue items within time selection", -1)

end


-- UTILITIES -------------------------------------------------------------

function msg(s) if msg_flag then reaper.ShowConsoleMsg(s .. '\n') end end


function get_items_in_time_selection_on_track(time_start, time_end, track)

  local items = {}

  local items_on_track = reaper.CountTrackMediaItems(track)
  -- msg("    Number of items on track is " .. items_on_track)
  -- msg("    Time start and time end are " .. time_start .. " " .. time_end)

  for i=1, items_on_track do

      local item = reaper.GetTrackMediaItem(track, i-1)
    --  msg("    " .. reaper.GetTakeName(reaper.GetActiveTake(item)))

      local item_start = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
      local item_length = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
      local item_end = item_start + item_length
    --  msg("    Loop " .. i .. ": " .. item_start .. " " .. item_length .. " " .. item_end)

      if item_start >= time_start and item_end <= time_end then
        items[i] = item
      end

  end

  reaper.Main_OnCommand(40289, 0, 0) -- Deselect MediaItems

  return items

end


--------------------------------------------------------- END OF UTILITIES

main()
