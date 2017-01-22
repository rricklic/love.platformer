#!/usr/bin/lua

--module setup
local World = {}

world = bump.newWorld()
sprites = {}
objects = {}

--constants
World.gravity = 1000
World.bottom = 1000

--import section
bump = require 'lib/bump'

--preven external access
--_ENV = nil

--constructor
--function World:new() 
--   local o = 
--   {
--   }
--
--   setmetatable(o, self)
--   self.__index = self
--   return o
--end

--------------------------------------------------------------------------
World.load = function(level)
   --TODO: implement a level loading function
end

--------------------------------------------------------------------------
--World.addObject = function(x, y, w, h, drawLambda)
--  local t = {draw = drawLambda}
--  world:add(t, x, y, w, h)
--  table.insert(objects, t)
--end

--------------------------------------------------------------------------
World.add = function(object)
  world:add(object, object.x, object.y, object.w, object.h)
  if(object.isSprite) then
    table.insert(sprites, object)
  else
    table.insert(objects, object)
  end
end

--------------------------------------------------------------------------
World.add2 = function(sprite)
  world:add(sprite, sprite.x, sprite.y, sprite.w, sprite.h)
  --table.insert(sprites, sprite)
end

--------------------------------------------------------------------------
World.remove = function(sprite)
   world:remove(sprite)

   --TODO: improve
   for i, v in pairs(sprites) do
      if(v == sprite) then
         table.remove(sprites, i)
      end
   end
end

--------------------------------------------------------------------------
World.draw = function()
   for _, v in pairs(objects) do
     v:draw(world:getRect(v))
   end

   for _, v in pairs(sprites) do
     v:draw(world:getRect(v))
   end
end

--------------------------------------------------------------------------
World.update = function(dt)
   for _, v in pairs(sprites) do
     v:update(dt)
   end
end

--------------------------------------------------------------------------
World.move = function(sprite, x, y, colFunc)
   return world:move(sprite, x, y, colFunc)
end

--------------------------------------------------------------------------
World.isVisible = function(sprite)
  local x, y, _, _ = world:getRect(sprite)
  return ((x < (xScreenPos + xScreenSize-25)) and (x > xScreenPos + 25))
end

--------------------------------------------------------------------------
World.displayDebug = function()
--  love.graphics.print("FPS: "..love.timer.getFPS(), 10, 20)
--  love.graphics.print("DATA: " .. math.floor(player1.x) .. ":" .. math.floor(player1.y) .. ":" .. player1.len, 10, 30)
--  if player1.len > 0 then
--    love.graphics.print("COLLISION: " .. player1.cols[1].normal.x .. "," .. player1.cols[1].normal.y, 10, 40)
--  end
--
--  love.graphics.print("xScreenPos: " .. xScreenPos, 400, 20)
--  love.graphics.print("yScreenPos: " .. yScreenPos, 400, 30)
--  love.graphics.print("player1.x: " .. player1.x, 400, 40)
--  love.graphics.print("player1.y: " .. player1.y, 400, 50)
--  love.graphics.print("score: " .. score, 400, 60)
end

--------------------------------------------------------------------------
World.handleCollision = function(cols, len)
--   self.cols = cols
--   self.len = len
--   
--   --collision with ground and wall to reset jump count
--   if self.len > 0 and (self.cols[1].normal.y == -1 or (self.isWallJump == 1 and self.cols[1].normal.x ~= 0)) then
--      self.jumpCount = 0
--   end
end

return World
