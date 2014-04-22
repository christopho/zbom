local map = ...
local game = map:get_game()

--------------------------------------
-- Dungeon 4: Mountaintop Mausoleum --
--------------------------------------

if game:has_item("lamp") then
 lantern_overlay = sol.surface.create("entities/dark.png")
else
  game:start_dialog("_cannot_see_need_lamp")
  lantern_overlay = sol.surface.create(640,480)
  lantern_overlay:set_opacity(0.96 * 255)
  lantern_overlay:fill_color{0, 0, 0}
end

function map:on_started(destination)
  if game:get_value("i1029") > 5 then
    npc_dampeh:remove()
  end
  miniboss_arrghus:set_enabled(false)
  map:set_doors_open("door_miniboss")
  chest_big_key:set_enabled(false)
  chest_book:set_enabled(false)
  -- Lantern slowly drains magic here so you're forced to find ways to refill magic
  magic_deplete = sol.timer.start(map, 5000, function()
    if game:get_magic() > 1 then game:remove_magic(1) end
    return true
  end)
end

function npc_dampeh:on_interaction()
  if game:get_value("i1029") == 5 then
    game:start_dialog("dampeh.1.mausoleum", function()
      npc_dampeh:get_sprite():set_animation("walking")
      local m = sol.movement.create("target")
      m:set_target(232, 1712)
      m:set_speed(16)
      m:start(npc_dampeh, function()
	npc_dampeh:remove()
        game:set_value("i1029", 6)
        game:start_dialog("osgor.2.mausoleum")
      end)
    end)
  else
    game:start_dialog("dampeh.0.mausoleum")
  end
end

function sensor_miniboss:on_activated()
  if miniboss_arrghus ~= nil then
    map:close_doors("door_miniboss")
    miniboss_arrghus:set_enabled(true)
    sol.audio.play_music("boss")
  end
end

if miniboss_arrghus ~= nil then
 function miniboss_arrghus:on_dead()
  map:open_doors("door_miniboss")
  sol.audio.play_sound("boss_killed")
  sol.timer.start(2000, function()
    chest_big_key:set_enabled(true)
    sol.audio.play_sound("chest_appears")
  end)
  sol.audio.play_music("temple_mausoleum")
 end
end

function door_key2_1:on_opened()
  -- If the key 2 door is opened before the key 1 door, open
  -- the shutter to the other key so the player's not trapped!
  map:set_doors_open("door_shutter_key2")
end
function chest_item:on_opened()
  map:set_doors_open("door_shutter_key2")
end

function map:on_update()
  if lantern_overlay and game:get_magic() <= 0 then
    lantern_overlay = nil
  end
end

function game:on_map_changed(map)
  function map:on_draw(dst_surface)
    local screen_width, screen_height = dst_surface:get_size()
    local camera_x, camera_y = map:get_camera_position()

    -- Draw the lights eminating from the statues
    --local s1x, s1y, s1l = statue_1:get_position()
    --light_overlay = sol.surface.create("entities/light.png")
    --local x = 320 - s1x + camera_x
    --local y = 240 - s1y + camera_y
    --light_overlay:draw_region(x, y, screen_width, screen_height, dst_surface)

    -- Draw the lantern light that follows the hero
    if lantern_overlay then
      local hero = map:get_entity("hero")
      local hero_x, hero_y = hero:get_center_position()
      local x = 320 - hero_x + camera_x
      local y = 240 - hero_y + camera_y
      lantern_overlay:draw_region(x, y, screen_width, screen_height, dst_surface)
    else
      lantern_overlay = sol.surface.create(640,480)
      lantern_overlay:set_opacity(0.9 * 255)
      lantern_overlay:fill_color{0, 0, 0}
      local hero = map:get_entity("hero")
      local hero_x, hero_y = hero:get_center_position()
      local camera_x, camera_y = map:get_camera_position()
      local x = 320 - hero_x + camera_x
      local y = 240 - hero_y + camera_y
      lantern_overlay:draw_region(x, y, screen_width, screen_height, dst_surface)
    end
  end
end
