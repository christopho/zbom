local enemy = ...

-- Big Poe: Larger ghost boss composed of smaller Poes

local going_hero = false
local timer

function enemy:on_created()
  self:set_life(8)
  self:set_damage(3)
  self:create_sprite("enemies/poe_big")
  self:set_hurt_style("boss")
  self:set_pushed_back_when_hurt(false)
  self:set_push_hero_on_sword(false)
  self:set_obstacle_behavior("flying")
  self:set_size(32, 40)
  self:set_origin(16, 37)
end

function enemy:on_movement_changed(movement)
  local direction4 = movement:get_direction4()
  local sprite = self:get_sprite()
  sprite:set_direction(direction4)
end

function enemy:on_obstacle_reached(movement)
  if not going_hero then
    self:go_random()
    self:check_hero()
  end
end

function enemy:on_restarted()
  self:go_random()
  self:check_hero()
end

function enemy:on_hurt()
  if timer ~= nil then
    timer:stop()
    timer = nil
  end
end

function enemy:check_hero()
  local hero = self:get_map():get_entity("hero")
  local _, _, layer = self:get_position()
  local _, _, hero_layer = hero:get_position()
  local near_hero = layer == hero_layer
    and self:get_distance(hero) < 100

  if near_hero and not going_hero then
    self:go_hero()
  elseif not near_hero and going_hero then
    self:go_random()
  end
  timer = sol.timer.start(self, 2000, function() self:check_hero() end)
end

function enemy:go_random()
  self:get_sprite():set_animation("walking")
  local m = sol.movement.create("random_path")
  m:set_speed(40)
  m:start(self)
  going_hero = false
end

function enemy:go_hero()
  self:get_sprite():set_animation("walking")
  local m = sol.movement.create("path_finding")
  m:set_speed(56)
  m:start(self)
  going_hero = true
end