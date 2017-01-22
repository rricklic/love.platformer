#!/usr/bin/lua

--module setup
local Ground = {}

--import section

--prevent external access
_ENV = nil

--constructor
function Ground:new(x, y, w, h, color)
   local o = 
   {
      --attributes
      x = x,
      y = y,
      w = w,
      h = h,
      color = color,
      isGround = 1,
   }

   setmetatable(o, self)
   self.__index = self
   return o
end

--------------------------------------------------------------------------
function Ground:draw()
   love.graphics.setColor(self.color[1], self.color[2], self.color[3])
   love.graphics.rectangle('line', self.x, self.y, self.w, self.h)
end

return Ground
