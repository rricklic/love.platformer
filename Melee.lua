#!/usr/bin/lua

--module setup
local Melee = {}
crossfunc = function(item, other) return 'cross' end

--import section

--prevent external access
_ENV = nil

--constructor
function Melee:new(player, x, y, w, h, duration, color)
   local o = 
   {
      --attributes
      player = player,
      x = x,
      y = y,
      w = w,
      h = h,
      duration = duration,
      color = color,
      elapse = 0,
      --attack attibutes
      isAttack = 1,
      isSprite = 1,
      damage = 10,
      pushBack = 500,
      --collions data
      cols = {},
      len = 0
   }

   setmetatable(o, self)
   self.__index = self
   return o
end

--------------------------------------------------------------------------
function Melee:draw()
   love.graphics.setColor(self.color[1], self.color[2], self.color[3])
   love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
end

--------------------------------------------------------------------------
function Melee:update(dt)
  self.x, self.y, self.cols, self.len = World.move(self, self.player.x+(self.w*self.player.xDir), self.player.y, crossfunc)
  self:handleCollision()

  self.elapse = self.elapse + dt
end

--------------------------------------------------------------------------
function Melee:isDone()
   return self.elapse > self.duration
end

--------------------------------------------------------------------------
function Melee:handleCollision()
end

return Melee
