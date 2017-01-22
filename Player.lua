#!/usr/bin/lua

--TODO: states: {stading, walking, jumping, dying, hit, attacking, firing}

--module setup
local Player = {}
local filter = function(item, other)
  if other == item.melee then
     return nil
  elseif other.isAttack == 1 then 
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
function Player:new(x, y, w, h, upKey, downKey, leftKey, rightKey, jumpKey, meleeKey, shootKey, walkVel, jumpVel, color, name)
   local o = 
   {
      --attributes
      x = x,
      y = y,
      w = w,
      h = h,
      upKey = downKey,
      leftKey = leftKey,
      rightKey = rightKey,
      jumpKey = jumpKey,
      meleeKey = meleeKey,
      shootKey = shootKey,
      walkVel = walkVel,
      jumpVel = jumpVel,
      color = color,
      name = name,
      --state
      xVel = 0,
      yVel = 0,
      xDir = 1,
      jumpCount = 0,
      walkaction = 0,
      action = 0, --0=standing, 1=walking, 2=hit
      actionTimer = 0,
      lastMeleeTimer = 0,
      life = 100,
      --attacks
      bullets = {},
      melee = nil,
      --collions data
      cols = {},
      len = 0,
      --config
      isPlayer = 1,
      isSprite = 1,
      isDoubleJump = 1,
      isWallSlide = 1,
      isWallJump = 1,
      maxBullets = 30,
      bulletType = 2, --1=single, 2=triple, 3=sine wave, 4=big, 5=???, 6=triple sine wave
      damageCoolOffDuration = 0.5,
      meleeCoolOffDuration = 0.25,
      friction = 10000
   }

   setmetatable(o, self)
   self.__index = self
   return o
end

--------------------------------------------------------------------------
function Player:draw()
  self:drawPlayer()
  self:drawBullets()
end

--------------------------------------------------------------------------
function Player:keypressed(key)
    if key == self.leftKey and self.action ~=2 then
        self.xVel = self.xVel - self.walkVel
        self.walkaction = self.walkaction + 1
        self.xDir = -1
    end

    if key == self.rightKey and self.action ~= 2 then
        self.xVel = self.xVel + self.walkVel
        self.walkaction = self.walkaction + 1
        self.xDir = 1
    end

    if key == self.jumpKey and self.action ~= 2 and self.yVel >= 0 and
          ((self.jumpCount == 0 and self.len ~= 0 and (self.cols[1].normal.y == -1 or self.isWallJump == 1)) or
          (self.isDoubleJump == 1 and self.jumpCount == 1)) then
       self.yVel = -self.jumpVel
       self.jumpCount = self.jumpCount + 1
    end

    --create bullet
    if key == self.shootKey and self.action ~= 2 and table.getn(self.bullets) < self.maxBullets then
      local xbuf
      if self.xDir == -1 then xbuf = -5 else xbuf = self.w end

      local sineDelta
      if self.bulletType == 3 or self.bulletType == 6 then sineDelta = 10 else sineDelta = 0 end

      local bullet = Bullet:new(self.x+xbuf, self.y, 5, 5, 300*self.xDir, 0, sineDelta, self.color)
      World.add2(bullet)
      table.insert(self.bullets, bullet)

      if(self.bulletType == 2 or self.bulletType == 6) then
        local bullet2 = Bullet:new(self.x+xbuf, self.y, 5, 5, 300*self.xDir, 50, sineDelta, self.color)
        World.add2(bullet2)
        table.insert(self.bullets, bullet2)

        local bullet3 = Bullet:new(self.x+xbuf, self.y, 5, 5, 300*self.xDir, -50, sineDelta, self.color)
        World.add2(bullet3)
        table.insert(self.bullets, bullet3)
      end
    end

    --create melee
    if key == self.meleeKey and self.action ~= 2 and self.melee == nil and self.lastMeleeTimer > self.meleeCoolOffDuration then
       self.melee = Melee:new(self, self.x+(self.w*self.xDir), self.y, self.w-1, self.h/2, 0.25, {255,0,0})
       self.lastMeleeTimer = 0
       World.add(self.melee)
    end 
end

--------------------------------------------------------------------------
function Player:keyreleased(key)
    if self.action == 2 then return end

    if key == self.leftKey then
        self.xVel = self.xVel + self.walkVel
        self.walkaction = self.walkaction - 1
    end
   
    if key == self.rightKey then
        self.xVel = self.xVel - self.walkVel
        self.walkaction = self.walkaction - 1
    end
end

--------------------------------------------------------------------------
function Player:update(dt)
  self.x, self.y, self.cols, self.len = World.move(self, self.x + (self.xVel*dt), self.y + (self.yVel*dt), filter)
  self:handleCollision()

  --handle gravity
  if self.yVel >= 0 and self.len > 0 and self.cols[1].normal.x ~= 0 and self.isWallSlide == 1 then
    self.yVel = 100
  elseif self.len == 0 or self.cols[1].normal.y == 0 or self.cols[1].other.isAttack == 1 then
    self.yVel = self.yVel + World.gravity*dt
  else
    self.yVel = 0.0000000001 --nonzero for ground contact
  end

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

  --update melee
  if(self.melee ~= nil) then
     --self.melee:update(dt)
     
     --detect melee collision with other player
     if(self.melee.len > 0) then
        for i=1, self.melee.len do  
          if(self.melee.cols[i].other.isPlayer == 1 and self.melee.cols[i].other ~= self) then


             local attackX
             if self.xDir == 1 then attackX = self.melee.x else attackX = self.melee.x + self.melee.w end

             --local side = self.melee.cols[i].normal.x
             local side
             if(attackX <= self.melee.cols[i].other.x) then side = 1 else side = -1 end
             self.melee.cols[i].other:takeDamage(side, 10, 500)
          end
        end
     end

     --melee finished
     if(self.melee:isDone()) then
        World.remove(self.melee)
        self.melee = nil   
     end
  else 
     self.lastMeleeTimer = self.lastMeleeTimer + dt
  end

  --update bullets
  for i, v in pairs(self.bullets) do
     v:update(dt)

     --detect bullet collision with other player
     for i=1, table.getn(self.bullets) do  
       local bullet = self.bullets[i]
       for j=1, bullet.len do
         if(bullet.cols[j].other.isPlayer == 1 and bullet.cols[j].other ~= self) then
            local side = bullet.cols[j].normal.x
            bullet.cols[j].other:takeDamage(-side, 5, 250)
         end
       end
     end

     --remove bullets that fly off screen
     if(World.isVisible(v) == false or v.len > 0) then
        World.remove(v)
        table.remove(self.bullets, i)
     end
  end

  --taking damage cool off
  if(self.action == 2) then
     if(self.actionTimer > self.damageCoolOffDuration) then
        self.action = 0
        self.actionTimer = 0
        self.friction = 10000
     end
  end

  --fell into bottom
  if(self.y > World.bottom and self.life > 0) then self:takeDamage(0, self.life, 0) end

  self.actionTimer = self.actionTimer + dt
end

--------------------------------------------------------------------------
function Player:handleCollision()
   --collision with ground and wall to reset jump count
   if self.len > 0 and (self.cols[1].normal.y == -1 or (self.isWallJump == 1 and self.cols[1].normal.x ~= 0)) then
      self.jumpCount = 0
   end

  for i=1, self.len do
    --player push player  
    --TODO: only allow pushing if touching ground
    if(self.cols[i].other.isPlayer == 1 and self.cols[i].other ~= self and self.cols[1].normal.x ~= 0) then
      self.cols[i].other.xVel = self.xVel * 0.25
    end

    --collision with enemy
    if(self.cols[i].other.isEnemy == 1) then
       self:takeDamage(self.cols[1].normal.x, self.cols[i].other.touchDamage, self.cols[i].other.touchPushBack)
    end    
  end
end

--------------------------------------------------------------------------
function Player:takeDamage(side, damage, pushBack)
   if(self.action == 2 or self.action == 4) then return end

   self.actionTimer = 0
   self.action = 2
   self.life = self.life - damage
   self.xVel = side * pushBack
   self.yVel = damage * 2
   self.friction = 2000
   self.walkaction = 0

   if(self.life <= 0) then self:die() end
end

--------------------------------------------------------------------------
function Player:isAlive()
   return self.life > 0
end

--------------------------------------------------------------------------
function Player:die()
   self.action = 4
   self.xVel = 0;
   self.yVel = 0;
end

--------------------------------------------------------------------------
function Player:dead()
   self.action = 5
   World.remove(self)
end

--------------------------------------------------------------------------
function Player:drawPlayer()
  love.graphics.setColor(self.color[1], self.color[2], self.color[3])

  if(self.isDying == 1) then self:drawPlayerDying()
  elseif(self.isHit == 1) then self:drawPlayerHit()
  elseif(self.isJumping == 1) then self:drawPlayerJumping()
  elseif(self.isWalking == 1) then self:drawPlayerWalking()
  elseif(self.isAttacking == 1) then self:drawPlayerAttacking()
  elseif(self.isFiring == 1) then self:drawPlayerFiring()
  elseif(self.isStanding == 1) then self:drawPlayerStanding()
  end
  
  if(self.action >= 4) then
    local frame = math.floor(self.actionTimer / 0.025) + 1
    if(frame >= 20) then self:dead() return end
    love.graphics.rectangle('fill', self.x+(frame*(self.w/40)), self.y+(frame*(self.h/40)), self.w-(frame*(self.w/20)), self.h-(frame*self.h/20)) 
  elseif(self.action == 2) then
    local colorAdj = math.floor(self.actionTimer/0.025)%2
    if(colorAdj == 1) then love.graphics.setColor(255, 255, 255) end
    love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
  else
    love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
  end
end

--------------------------------------------------------------------------
function Player:drawBullets()
  for _, bullet in pairs(self.bullets) do
     bullet:draw()
  end 
end



--------------------------------------------------------------------------
function Player:getDetails()
  return self.name .. ": " .. self.life .. "/100 " .. self.action .. " (" .. self.x .. "," .. self.y .. ") " .. self.xVel
end

return Player
