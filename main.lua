bump = require 'lib/bump'

World = require 'World'
Player = require 'Player'
Ground = require 'Ground'
Enemy1 = require 'Enemy1'


local player1 = Player:new(0, 300, 20, 30, nil, nil, 'q', 'w', 'e', 'r', 't', 400, 350, {0,255,0}, "p1")
local player2 = Player:new(50, 50, 20, 30, nil, nil, 'a', 's', 'd', nil, 'f', 500, 1000, {0,0,255}, "p2")
local player3 = Player:new(100, 50, 20, 30, nil, nil, 'z', 'x', 'c', nil, 'v', 400, 400, {255,0,255}, "p3")
local player4 = Player:new(150, 50, 20, 30, nil, nil, 'u', 'i', 'o', nil, 'p', 500, 500, {255,255,0}, "p4")
local e1 = Enemy1:new(1000, 470, 20, 20, 100, {255,0,0}, "e1.1")

--pan tests
xScreenPos = 0
yScreenPos = 0
xScreenSize = 800
yScreenSize = 600
maxPlayer1X = xScreenPos + xScreenSize - 100
minPlayer1X = xScreenPos + 100
maxPlayer1Y = yScreenPos + yScreenSize - 100
minPlayer1Y = yScreenPos + 100
score = 0

--------------------------------------------------------------------------
function love.load()
  love.graphics.setBackgroundColor(100, 100, 100)

  World.add(player1)
  World.add(player2)
  World.add(player3)
  World.add(player4)

  --WORLD GROUND
  World.add(Ground:new(0, 500, 500, 100, {255,255,0}))
  World.add(Ground:new(600, 500, 2000, 100, {255,255,0}))

  --WORLD PLATFORMS
  World.add(Ground:new(200, 450, 100, 20, {255,255,0}))
  World.add(Ground:new(400, 450, 300, 20, {255,255,0}))
  World.add(Ground:new(0, 400, 50, 20, {255,255,0}))
  World.add(Ground:new(100, 400, 100, 20, {255,255,0}))
  World.add(Ground:new(500, 400, 100, 20, {255,255,0}))
  World.add(Ground:new(150, 350, 75, 20, {255,255,0}))
  World.add(Ground:new(450, 350, 75, 20, {255,255,0}))
  World.add(Ground:new(600, 350, 75, 20, {255,255,0}))
  World.add(Ground:new(200, 100, 150, 150, {255,255,0}))

  --WORLD SIDES
  World.add(Ground:new(-50, -50, 50, 1000, {255,255,0}))
  World.add(Ground:new(2000, -50, 50, 1000, {255,255,0}))

  --WORLD TOP
  World.add(Ground:new(-50, -100, 900, 50, {255,255,0}))

  --ENEMIES
  World.add(e1)
end

--------------------------------------------------------------------------
function love.draw()

  love.graphics.push()
  love.graphics.translate(-xScreenPos, -yScreenPos)
  --love.graphics.rectangle('line', xScreenPos+25, yScreenPos+25, xScreenSize-50, yScreenSize-50);
  World.draw()
  love.graphics.pop()

  love.graphics.setColor(255, 255, 255)
  love.graphics.print(player1:getDetails(), 500, 20)
  love.graphics.print(player2:getDetails(), 500, 30)
  love.graphics.print(player3:getDetails(), 500, 40)
  love.graphics.print(player4:getDetails(), 500, 50)
  love.graphics.print(e1:getDetails(), 500, 60)

  World.displayDebug()
end

--------------------------------------------------------------------------
function love.keypressed(key)
    player1:keypressed(key)
    player2:keypressed(key)
    player3:keypressed(key)
    player4:keypressed(key)
end

--------------------------------------------------------------------------
function love.keyreleased(key)
    player1:keyreleased(key)
    player2:keyreleased(key)
    player3:keyreleased(key)
    player4:keyreleased(key)
end

--------------------------------------------------------------------------
function love.update(dt)

  World.update(dt)

  --scrolling
  if (player1.x + player1.w > maxPlayer1X) then
     xScreenPos = xScreenPos + (player1.x + player1.w - maxPlayer1X)
  end
  if (player1.x < minPlayer1X) then
     xScreenPos = xScreenPos - (minPlayer1X - player1.x)
  end
  if (player1.y + player1.h > maxPlayer1Y) then
     yScreenPos = yScreenPos + (player1.y + player1.h - maxPlayer1Y)
  end
  if (player1.y < minPlayer1Y) then
     yScreenPos = yScreenPos - (minPlayer1Y - player1.y)
  end

  maxPlayer1X = xScreenPos + xScreenSize - 100
  minPlayer1X = xScreenPos + 100
  maxPlayer1Y = yScreenPos + yScreenSize - 100
  minPlayer1Y = yScreenPos + 100
end
