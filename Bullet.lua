#!/usr/bin/lua

--module setup
local Bullet = {}
local filter = function(item, other)
  if other.isAttack == 1 then
     return nil
  else 
    return 'cross' 
  end
end

--import section

--prevent external access
_ENV = nil

--constructor
function Bullet:new(x, y, w, h, xVel, yVel, sineDelta, color)
   local o = 
   {
      --attributes
      x = x,
      y = y,
      w = w,
      h = h,
      xVel = xVel,
      yVel = yVel,
      sineDelta = sineDelta,
      sineApplied = 0,
      color = color,
      duration = 0,
      --attack attributes
      isAttack = 1,
      damage = 5,
      pushBack = 250,
      --collions data
      cols = {},
      len = 0,
   }

   setmetatable(o, self)
   self.__index = self
   return o
end

--------------------------------------------------------------------------
function Bullet:draw()
   love.graphics.setColor(self.color[1], self.color[2], self.color[3])
   love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
end

--------------------------------------------------------------------------
function Bullet:update(dt)
  local sine = math.sin(self.duration*20) * self.sineDelta
  local sineAdj = sine - self.sineApplied
  self.sineApplied = self.sineApplied + sineAdj

  self.x, self.y, self.cols, self.len = World.move(self, self.x + (self.xVel*dt), self.y + (self.yVel*dt) + (sineAdj), filter)
  self:handleCollision()

  self.duration = self.duration + dt
end

--------------------------------------------------------------------------
function Bullet:handleCollision()
  for i=1, self.len do
    --collision with enemy
    if(self.cols[i].other.isEnemy == 1) then
       self.cols[i].other:takeDamage(self.cols[1].normal.x, self.damage, self.pushBack)
    end 
  end
end

return Bullet
