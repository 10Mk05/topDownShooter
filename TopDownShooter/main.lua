function love.load()
    sprites = {}
    sprites.background = love.graphics.newImage('sprites/background.jpg')
    sprites.zombie = love.graphics.newImage('sprites/zombie.png')
    sprites.bullet = love.graphics.newImage('sprites/bullet.png')
    sprites.player = love.graphics.newImage('sprites/player.png')
    sprites.lobby = love.graphics.newImage('sprites/lobby.jpg')

    font = love.graphics.newFont("who asks satan.ttf", 40)

    player = {}
    player.x = love.graphics.getWidth()/2
    player.y = love.graphics.getHeight()/2
    player.speed = 200
    
    zombies = {}
    bullet = {}
    bullets = {}


    sounds = {}
    sounds.background = love.audio.newSource("sound/spookyscaryskeleton.mp3", "stream")
    sounds.oof = love.audio.newSource("sound/Mario-64-Oof-Sound-Effect.mp3", "stream")


    sounds.background:setVolume(0.3)
    sounds.background:setLooping(true)
    sounds.oof:setLooping(false)
    sounds.oof:setVolume(1)




    FPS = love.timer.getFPS()
  

    score = 0
    timePos = 1
    timeNeg = 10
    timer = 60
    gameState = 1
    life = 3
    timer2 = 0.5
    timer3 = 3
    timer4 = 1

    love.mouse.setVisible(true)

    sounds.background:play()  
end

function love.update(dt)
    if gameState == 2 then
        if love.keyboard.isDown("d") and player.x < love.graphics.getWidth() then
            player.x = player.x + player.speed * dt
        end
        if love.keyboard.isDown("w") and player.y > 0 then
            player.y = player.y - player.speed * dt
        end
        if love.keyboard.isDown("a") and player.x > 0 then
            player.x = player.x - player.speed * dt
        end
        if love.keyboard.isDown("s") and player.y < love.graphics.getHeight() then
            player.y = player. y + player.speed * dt
        end
    end
    for i,z in ipairs(zombies) do
        z.x = z.x + (math.cos(zombiePlayerAngle(z)) * z.speed * dt)
        z.y = z.y + (math.sin(zombiePlayerAngle(z)) * z.speed * dt)

        if distanceBetween(z.x, z.y, player.x, player.y) < 10 then
            life = life - 1
            timer = timer - 10
            sounds.oof:play()
            for i,z in ipairs(zombies) do
                zombies[i] = nil
            end
        end
    end
    for i,b in ipairs(bullets) do
        b.x = b.x + (math.cos(b.direction)*b.speed * dt)
        b.y = b.y + (math.sin(b.direction)*b.speed * dt)
    end
    for i,z in pairs(zombies) do
        for j,b in ipairs(bullets) do
            if distanceBetween(z.x, z.y, b.x, b.y) < 20 then
                z.dead = true
                b.dead = true
            end
        end
    end
    for  i=#zombies,1,-1 do
        local z = zombies[i]
        if z.dead == true then
            score = score + 1
            table.remove(zombies,i)
            timer = timer + timePos
        end
    end
    for  i=#bullets,1,-1 do
        local b = bullets[i]
        if b.dead == true then
            table.remove(bullets,i)
        end
    end
    
    if gameState == 2 then
        timer = timer - dt
        timer4 = timer4 - dt
        if timer4 <= 0 then
           for i=0,1 do
                spawnZombies()
           end
           timer4 = 1
        end
        if timer <= 0 or life == 0 then
            timer = 60
            life = 3
            gameState = 1
        end
        
    end
end

function love.draw()
    if gameState == 2 then
        love.graphics.draw(sprites.background, 0, 0)
        love.graphics.draw(sprites.player, player.x, player.y, playerMouseAngle(), nil, nil, sprites.player:getWidth()/2, sprites.player:getHeight()/2 )
        for i,z in ipairs(zombies) do
            love.graphics.draw(sprites.zombie, z.x, z.y, zombiePlayerAngle(z), nil, nil, sprites.zombie:getWidth()/2, sprites.zombie:getHeight()/2)
        end
        for i,b in ipairs(bullets) do
            love.graphics.draw(sprites.bullet, b.x, b.y, nil, 0.5, 0.5, sprites.bullet:getWidth()/2 , sprites.bullet:getHeight()/2)
        end
        -- cose scritte nello schermo
        love.graphics.setColor(1, 0, 0, 0)
        love.graphics.setColor(1, 1, 1) --bianco
        love.graphics.setFont(font)
        love.graphics.print("Score "..score, 0, 0)
        love.graphics.print("Time "..math.ceil(timer), 320, 0)
        love.graphics.print("FPS "..tostring(love.timer.getFPS()), 650, 0)
        love.graphics.print("Life " .. life, 650, 550)
    end
    if gameState == 1 then
        love.graphics.draw(sprites.lobby,0,0)
        love.graphics.setColor(1, 1, 1) --bianco
        love.graphics.setFont(font)
        love.graphics.printf("Premi un tasto per continuare", 0, love.graphics.getHeight()/2, love.graphics.getWidth(), "center")
    end
end

function love.keypressed(key)
    if key == "p" then
        spawnZombies()
    end
    if key == "space" and gameState == 2 then
        spawnBullet()
    end
end



function playerMouseAngle()
    return math.atan2(player.y - love.mouse.getY() , player.x - love.mouse.getX() ) + math.pi
end

function zombiePlayerAngle(enemy)
    return math.atan2(player.y - enemy.y , player.x - enemy.x )
end

function spawnZombies ()
    local zombie = {}
    zombie.x = 0
    zombie.y = 0
    zombie.speed = 200
    zombie.dead = false
    local side = math.random(1,4)
    if side == 1 then
        zombie.x = -30
        zombie.y = math.random(0, love.graphics.getHeight())
    elseif side == 2 then
        zombie.x = love.graphics.getWidth() +30
        zombie.y = math.random(0, love.graphics.getHeight())
    elseif side == 3 then
        zombie.x = math.random(0, love.graphics.getWidth())
        zombie.y = -30
    elseif side == 4 then
        zombie.x = math.random(0, love.graphics.getWidth())
        zombie.y = love.graphics.getHeight() +30
    end
    table.insert(zombies, zombie)
end

function love.mousepressed(x,y,button)
    if gameState == 2 and button == 1  then
        spawnBullet()
    end
    if button == 1 and gameState == 1 then
        gameState = 2
    end
end

function spawnBullet()
    local bullet = {}
    bullet.x = player.x
    bullet.y = player.y
    bullet.speed = 500
    bullet.dead = false
    bullet.direction = playerMouseAngle()
    table.insert(bullets,bullet)
end

function distanceBetween(x1,y1, x2,y2, x3,y3)
    return math.sqrt((x2-x1)^2 + (y2-y1)^2)
end