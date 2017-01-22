#!/usr/bin/lua

--module setup
local Enemy1 = {}
local filter = function(item, other)
  if other.isAttack == 1 then 
    return 'cross' 
  else 
    return 'slide' 
  end
end

--import section
World = require 'World'
Bullet = require 'Bullet'
Melee = require 'Melee'

--prevent external access
_ENV = nil

--constructor
function Enemy1:new(x, y, w, h, walkVel, color, name)
   local o = 
   {
      --attributes
      x = x,
      y = y,
      w = w,
      h = h,
      walkVel = walkVel,
      color = color,
      name = name,
      touchDamage = 5,
      touchPushBack = 100,
      --state
      xVel = walkVel,
      yVel = 0,
      xDir = 1,
      life = 20,
      action = 1,
      actionTimer = 0,
      totalDt = 0,
      --collions data
      cols = {},
      len = 0,
      --config
      isEnemy = 1,
      isSprite = 1,
      damageCoolOffDuration = 0.5,
      friction = 10000
   }

   setmetatable(o, self)
   self.__index = self
   return o
end

--------------------------------------------------------------------------
function Enemy1:draw()
  love.graphics.setColor(self.color[1], self.color[2], self.color[3])

  if(self.action >= 4) then
    local frame = math.floor(self.actionTimer / 0.025) + 1
    if(frame >= 20) then self:dead() return end
    love.graphics.rectangle('fill', self.x+(frame*(self.w/40)), self.y+(frame*(self.h/40)), self.w-(frame*(self.w/20)), self.h-(frame*self.h/20)) 
    return
  elseif(self.action == 2) then
    local colorAdj = math.floor(self.actionTimer/0.025)%2
    if(colorAdj == 1) then love.graphics.setColor(255, 255, 255) end
  end

  love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
end

--------------------------------------------------------------------------
function Enemy1:update(dt)
  self.x, self.y, self.cols, self.len = World.move(self, self.x + (self.xVel*dt), self.y + (self.yVel*dt), filter)
  self:handleCollision()

   self.actionTimer = self.actionTimer + dt
   self.totalDt = self.totalDt + dt

   if self.totalDt > 1 then
      self.totalDt = self.totalDt -1
      self.xVel = self.xVel * -1   
   end



  --handle gravity
  if self.yVel >= 0 and self.len > 0 and self.cols[1].normal.x ~= 0 and self.isWallSlide == 1 then
    self.yVel = 100
  elseif self.len == 0 or self.cols[1].normal.y == 0 or self.cols[1].other.isAttack == 1 then
    self.yVel = self.yVel + World.gravity*dt
  else
    self.yVel = 0.0000000001 --nonzero for ground contact
  end

--[[
  --handle friction if not walking
  if self.walkaction == 0 then
    if self.xVel ~= 0 and self.len > 0 and self.cols[1].normal.y == -1 and self.cols[1].normal.x == 0 then
      --on ground; friction de-acceleration
      local sign
      if self.xVel < 0 then sign = 1 else sign = -1 end
      local adj = (sign*self.friction*dt) 
      if math.abs(adj) > math.abs(self.xVel) then self.xVel = 0 else self.xVel = self.xVel + adj end
    elseif self.len > 0 and self.cols[1].other.isAttack ~= 1 and self.cols[1].normal.x ~= 0 then
      --hit wall; zero out acceleration
      self.xVel = 0
    end
  end  
--]]
  --taking damage cool off
  if(self.action == 2) then
     if(self.actionTimer > self.damageCoolOffDuration) then
        self.action = 0
        self.actionTimer = 0
        self.friction = 10000
     end
  end

--[[
  --fell into bottom
  if(self.y > World.bottom and self.life > 0) then self:takeDamage(0, self.life, 0) end

  self.actionTimer = self.actionTimer + dt
--]]

   if(self.y > World.bottom and self.life > 0) then self:takeDamage(0, self.life, 0) end
end

--------------------------------------------------------------------------
function Enemy1:handleCollision()
  for i=1, self.len do
    --collision with player
    if(self.cols[i].other.isPlayer == 1) then
       self.cols[i].other:takeDamage(self.cols[1].normal.x, self.touchDamage, self.touchPushBack)
    end 

    --collision with player attack
    if(self.cols[i].other.isAttack == 1) then
       self:takeDamage(self.cols[1].normal.x, self.cols[i].other.damage, self.cols[i].other.pushBack)
    end    
  end

end

--------------------------------------------------------------------------
function Enemy1:takeDamage(side, damage, pushBack)
   if(self.action == 2 or self.action == 4) then return end

   self.actionTimer = 0
   self.action = 2
   self.life = self.life - damage
   --self.xVel = side * pushBack
   self.friction = 2000
   self.walkaction = 0

   if(self.life <= 0) then self:die() end
end

--------------------------------------------------------------------------
function Enemy1:isAlive()
   return self.life > 0
end

--------------------------------------------------------------------------
function Enemy1:die()
   self.action = 4
   self.xVel = 0;
   self.yVel = 0;
end

--------------------------------------------------------------------------
function Enemy1:dead()
   self.action = 5
   World.remove(self)
end

--------------------------------------------------------------------------
function Enemy1:getDetails()
  return self.name .. ": " .. self.life .. " " .. self.action .. " (" .. self.x .. "," .. self.y .. ") " .. self.xVel
end

return Enemy1
