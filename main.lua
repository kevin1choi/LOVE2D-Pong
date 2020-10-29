Class = require 'class'
push = require 'push'

require 'Ball'
require 'Paddle'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

function love.load()
    love.window.setTitle('Pong')

    math.randomseed(os.time())

    love.graphics.setDefaultFilter('nearest', 'nearest')

    smallFont = love.graphics.newFont('bitFont.ttf', 8)
    largeFont = love.graphics.newFont('bitFont.ttf', 32)
    -- love.graphics.setFont(smallFont)

    -- love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
        --     fullscreen = false,
        --     vsync = true,
        --     resizable = false
        -- })
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true
    })

    player1Score = 0
    player2Score = 0
    winningPLayer = 0

    paddle1 = Paddle(5, 20, 5, 20) -- player1Y = 30
    paddle2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20) -- player2Y = VIRTUAL_HEIGHT - 40
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 5, 5)
    -- ballX = VIRTUAL_WIDTH / 2 - 2
    -- ballY = VIRTUAL_HEIGHT / 2 - 2
    -- ballDX = math.random(2) == 1 and -100 or 100  -- == 1 ? -100 : 100
    -- ballDY = math.random(-50, 50)

    servingPlayer = math.random(2) == 1 and 1 or 2
    if servingPlayer == 1 then
        ball.dx = 100
    elseif servingPlayer == 2 then
        ball.dx = -100
    end

    sounds = {
        ['blip'] = love.audio.newSource('blip.wav', 'static'),
        ['hurt'] = love.audio.newSource('hurt.wav', 'static'),
        ['end'] = love.audio.newSource('end.wav', 'static'),
    }

    gameState = 'start'
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)
    if gameState == 'play' then
        if ball:collides(paddle1) then
            ball.dx = -ball.dx -- deflect ball
            sounds['blip']:play()
        end

        if ball:collides(paddle2) then
            ball.dx = -ball.dx -- deflect ball
            sounds['blip']:play()
        end

        if ball.x <= 0 then
            player2Score = player2Score + 1
            servingPlayer = 1
            ball:reset()
            ball.dx = 100
            sounds['hurt']:play()
            
            if player2Score >= 5 then
                sounds['end']:play()
                winningPLayer = 2
                gameState = 'victory'
            else
                gameState = 'serve'
            end
        end

        if ball.x >= VIRTUAL_WIDTH - 4 then
            player1Score = player1Score + 1
            servingPlayer = 2
            ball:reset()
            ball.dx = -100
            sounds['hurt']:play()

            if player1Score >= 5 then
                sounds['end']:play()
                winningPLayer = 1
                gameState = 'victory'
            else
                gameState = 'serve'
            end
        end

        if ball.y <= 0 then
            sounds['blip']:play()
            ball.dy = -ball.dy
            ball.y = 0
        end

        if ball.y >= VIRTUAL_HEIGHT - 4 then
            sounds['blip']:play()
            ball.dy = -ball.dy
            ball.y = VIRTUAL_HEIGHT - 4
        end

        -- ballX = ballX + ballDX * dt
        -- ballY = ballY + ballDY * dt
        ball:update(dt)
    end

    if love.keyboard.isDown('w') then
        -- player1Y = math.max(0, player1Y - PADDLE_SPEED * dt)
        paddle1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        -- player1Y = math.min(VIRTUAL_HEIGHT - 20, player1Y + PADDLE_SPEED * dt)
        paddle1.dy = PADDLE_SPEED
    else
        paddle1.dy = 0
    end

    if love.keyboard.isDown('up') then
        -- player2Y = math.max(0, player2Y - PADDLE_SPEED * dt)
        paddle2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        -- player2Y = math.min(VIRTUAL_HEIGHT - 20, player2Y + PADDLE_SPEED * dt)
        paddle2.dy = PADDLE_SPEED
    else
        paddle2.dy = 0
    end

    paddle1:update(dt)
    paddle2:update(dt)

end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'victory' then
            gameState = 'start'
            player1Score = 0
            player2Score = 0
        end
    end
end

function love.draw()
    push:apply('start') -- begin rendering at virtual resolution

    love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 255 / 255)

    love.graphics.setFont(smallFont)

    if gameState == 'start' then
        love.graphics.printf("Welcome to Pong!", 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press Enter to Play!", 0, 32, VIRTUAL_WIDTH, 'center')
        displayScore()
    elseif gameState == 'serve' then
        love.graphics.printf("Player" .. tostring(servingPlayer) .. " serving...", 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press Enter to Serve!", 0, 32, VIRTUAL_WIDTH, 'center')
        displayScore()
    elseif gameState == 'victory' then
        love.graphics.setFont(smallFont)
        love.graphics.printf("Player" .. tostring(winningPLayer) .. " wins!", 0, 30, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press Enter to Restart!", 0, 42, VIRTUAL_WIDTH, 'center')
        displayScore()
    elseif gameState == 'play' then

    end

    -- if gameState == 'start' then
    --     love.graphics.printf(
    --         "Press Enter to Start",
    --         0,
    --         20, -- VIRTUAL_HEIGHT / 2 - 6, -- changed from WINDOW_HEIGHT / 2 - 6,
    --         VIRTUAL_WIDTH, -- changed from WINDOW_WIDTH,
    --         'center'
    --     )
    -- elseif gameState == 'play' then
    --     love.graphics.printf(
    --         "Pong!",
    --         0,
    --         20, -- VIRTUAL_HEIGHT / 2 - 6, -- changed from WINDOW_HEIGHT / 2 - 6,
    --         VIRTUAL_WIDTH, -- changed from WINDOW_WIDTH,
    --         'center'
    --     )
    -- end

    ball:render() -- love.graphics.rectangle('fill', ballX, ballY, 5, 5)
    
    paddle1:render() -- love.graphics.rectangle('fill', 5, player1Y, 5, 20)
    paddle2:render() -- love.graphics.rectangle('fill', VIRTUAL_WIDTH - 10, player2Y, 5, 20)

    displayFPS();

    push:apply('end')
end

function displayFPS() 
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.setFont(smallFont)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), VIRTUAL_WIDTH / 2 - 15, 0) -- .. = string concat
    love.graphics.setColor(1, 1, 1, 1) -- reset color
end

function displayScore()
    love.graphics.setFont(largeFont)
    love.graphics.print(player1Score, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(player2Score, VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)
end