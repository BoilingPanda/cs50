WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

Class = require 'class'
push = require 'push'

require 'Ball'
require 'Paddle'


function love.load()
  math.randomseed(os.time())
  love.graphics.setDefaultFilter('nearest','nearest')

  love.window.setTitle('Pong')
  
  -- setting title and score fonts respectively
  smallFont = love.graphics.newFont('font.ttf',8)
  scoreFont = love.graphics.newFont('font.ttf',32)
  victoryFont = love.graphics.newFont('font.ttf',24)

  sounds = {
      ['paddle_hit'] = love.audio.newSource('pedalhit.wav','static'),
      ['point_scored'] = love.audio.newSource('pointscored.wav', 'static'),
      ['wall_hit'] = love.audio.newSource('wallhit.wav', 'static')
  }

  --initializing scores at start
  player1Score = 0
  player2Score = 0
  servingPlayer = math.random(2) == 1 and 1 or 2

  winningPlayer = 0
  followBall = true


  --paddles' first location at start
  paddle1 = Paddle(5, 20, 5, 20)
  paddle2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5 , 20)
  ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4 , 4)

  if servingPlayer == 1 then
        ball.dx = 100
  else
        ball.dx = -100
  end

  gameState = 'start'

  --screen resolution at start
  push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT,{
      fullscreen = false,
      vsync = true,
      resizable = true
  })
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)  

    if gameState == 'play' then

        if ball.x < 0 then
            player2Score = player2Score + 1
            servingPlayer = 1

            sounds['point_scored']:play()
            
            ball.dx = 100
            if player2Score >= 10 then
                gameState = 'victory'
                winningPlayer = 2
            else
                gameState = 'serve'
                ball:reset()
            end
        end

        if ball.x >= VIRTUAL_WIDTH - 4 then
            player1Score = player1Score + 1
            servingPlayer = 2
            sounds['point_scored']:play()
            
            ball.dx = -100

            if player1Score >= 10 then
                gameState = 'victory'
                winningPlayer = 1
            else
                gameState = 'serve'
                ball:reset()
            end
        end
        
        if ball:collides(paddle1) then
            ball.dx = -ball.dx * 1.03
            ball.x = paddle1.x + 4
            
            sounds['paddle_hit']:play()

            if ball.dy < 0 then
                ball.dy = -math.random(10,150)
            else
                ball.dy = math.random(10,150)
            end           
        end
    
        if ball:collides(paddle2) then
            ball.dx = -ball.dx * 1.03
            ball.x = paddle2.x - 4

            sounds['paddle_hit']:play()
            
            if ball.dy < 0 then
                ball.dy = -math.random(10,150)
            else
                ball.dy = math.random(10,150)
            end           
        end
    
        if ball.y <= 0 then
            ball.dy = -ball.dy
            ball.y = 0

            sounds['wall_hit']:play()
        end
    
        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.dy = -ball.dy
            ball.y = VIRTUAL_HEIGHT - 4
            sounds['wall_hit']:play()
        end        
        
        paddle1:update(dt)
        paddle2:update(dt)
    
        --player1 paddle movement
        if love.keyboard.isDown('w') then
    
            paddle1.dy = -PADDLE_SPEED
        elseif love.keyboard.isDown('s') then
    
            paddle1.dy = PADDLE_SPEED
        else
            paddle1.dy = 0
        end
    
        --player2 paddle movement
        if ball:collides(paddle1) then
            followBall = true
        elseif ball:collides(paddle2) or ball.x >= VIRTUAL_WIDTH - 4 then
            followBall = false
            paddle2.dy = 0
        end

        if followBall == true then
            if ball.y > math.random(paddle2.y - 5,paddle2.y + 5) then
                paddle2.dy = 0.8 * PADDLE_SPEED
            elseif ball.y < math.random(paddle2.y - 5,paddle2.y + 5) then
                paddle2.dy = -0.8 * PADDLE_SPEED 
            elseif (ball.y - paddle2.y < 3 or paddle2.y - ball.y < -3) then
            --and ball.y - paddle2.y 3 -10) or (paddle2.y - ball3y < 10 and paddle2.y - ball.y > -10) then
                paddle2.dy = 0.5 * PADDLE_SPEED
            elseif (paddle2.y - ball.y < 3 or ball.y - paddle2.y < -3) then 
                paddle2.dy = -0.5 * PADDLE_SPEED
            else
                paddle2.dy = 0
            end
        end
 --[[]
        if love.keyboard.isDown('up') then
    
            paddle2.dy = -PADDLE_SPEED
        elseif love.keyboard.isDown('down') then
    
            paddle2.dy = PADDLE_SPEED
        else
            paddle2.dy = 0
        end
    ]]
        ball:update(dt)
    end
end

function love.keypressed(key)
    
  --quitting the game
    if key == 'escape' then
      love.event.quit() 
      --starting the game 
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'victory' then
            gameState = 'start'
            player2Score = 0
            player1Score = 0
        end
    end    
end

function love.draw()
  push:apply('start')

  --background color
  love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 255 / 255)
  
  if gameState == 'start' then
    love.graphics.setFont(smallFont)
    love.graphics.printf("Welcome to Pong!", 0, 20, VIRTUAL_WIDTH, 'center')
    love.graphics.printf("Press Enter to Play!", 0, 32, VIRTUAL_WIDTH, 'center')
  elseif gameState == 'serve' then
    love.graphics.setFont(smallFont)
    love.graphics.printf("Player " .. tostring(servingPlayer) .. "'s turn", 0, 20, VIRTUAL_WIDTH, 'center')
    love.graphics.printf("Press Enter to Serve!", 0, 32, VIRTUAL_WIDTH, 'center')
  elseif gameState == 'victory' then
    love.graphics.setFont(victoryFont)
    love.graphics.printf("Player " .. tostring(winningPlayer) .. " wins!", 0, 10, VIRTUAL_WIDTH, 'center')
    love.graphics.setFont(smallFont)
    love.graphics.printf("Press Enter to Play!", 0, 42, VIRTUAL_WIDTH, 'center')
  end
    
  ball:render()
  paddle1:render()
  paddle2:render()

  displayScore()
  displayFPS()
  
  push:apply('end')
end

function displayFPS()
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.setFont(smallFont)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 40, 20)
    love.graphics.setColor(1, 1, 1, 1)
end

function displayScore()
      --score drawing on screen
  love.graphics.setFont(scoreFont)
  love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
  love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)
end