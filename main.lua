--[[

This app runs a game in which you must draw lines to direct three balls into a bucket. Then, the bucket moves, and you must
do it again. However, the lines never go away: they simply add up, making it more and more difficult.

@author Jonathan Lane-Smith

]]

-- This function runs the entire program
function Program()

	-- Hides status bar
	display.setStatusBar( display.HiddenStatusBar )

	-- Enables widgets
	widget = require("widget")

	-- Enables physics
	physics = require("physics")

	-- Creates white background
	background = display.newRect(display.contentCenterX, display.contentCenterY, display.contentWidth + 100, display.contentHeight + 100)
	background:setFillColor(1,1,1)

	-- Table containing the lines that the user draws
	lines = {}

	-- This function plays the game
	function Game()

		-- Starts physics
		physics.start()

		linenumber = 0 -- Number of drawn lines
		start = 1 	-- Variable for lines: 1 is first point the user touches, 2 is all others 

		-- This function creates lines
		function CreateLine( event )

			-- If the user touches or moves their finger on the screen
			if ("began" == event.phase or "moved" == event.phase) then

					-- If where they touched is out of bounds
				if (event.y > 470 or event.y < 80) then 
					start = 1	
				else	
					-- If this is the first point the user touches
					if start == 1 then
						x1 = event.x -- X-value of first point
						y1 = event.y -- Y-value of first point
						start = 2

					-- If this is the next point the user touches	
					elseif start == 2 then
						x2 = event.x -- X-value of next point
						y2 = event.y -- Y-value of next point
						linenumber = linenumber + 1 -- Adds one of number of lines
						lines[linenumber] = display.newLine(x1,y1,x2,y2) -- Creates new line
						lines[linenumber]:setStrokeColor(0,0,0)	-- Colours line
						physics.addBody(lines[linenumber], "static", {bounce = 0.4}) -- Adds physics to line

						-- The second point becomes the first point of the next line			   	
						x1 = event.x
						y1 = event.y  

					end -- end of elseif loop
				end -- end of else loop
			end -- end of if loop

			-- If the user takes their finger off the screen
			if ("ended" == event.phase) then
				start = 1			
			end	

		end -- end of CreateLine

		-- Event listener to create lines
		Runtime:addEventListener( "touch", CreateLine )

		-- This function occurs if the user fails
		function Failure()
		
			-- This function removes the elements of the failure menu
			function RemoveFailure()
			
				-- Removes every line
				for i=1, linenumber do
					lines[i]:removeSelf()
				end	

				-- For each ball, if the ball exists, removes it
				for i=1,3 do
					if ball[i][2] == true then
						ball[i][1]:removeSelf()
					end
				end	

				-- Removes words and buttons
				display.remove(myGO1)
				display.remove(myGO2)
				homebutton:removeSelf()
				playbutton:removeSelf( )

				-- Moves bucket and its sides back to the center
				position = display.contentCenterX
				transition.to(side1, {time=0, x=position-33})
				transition.to(side2, {time=0, x=position+33, } )
				transition.to(bucket, {x=position, time=100})

				-- If the user chooses to play again
				if choice == "game" then
					score = 0
					myscore.text = score
					Game()	

				-- If the user chooses to go to the home screen				
				else

					-- Removes game elements
					entrance1:removeSelf()
					entrance2:removeSelf()
					myscore:removeSelf()
					side1:removeSelf()
					side2:removeSelf()
					bucket:removeSelf()

					TitleMenu()
				
				end -- end of else loop
			
			end -- end of RemoveFailure

			-- This function fades the elements of the failure menu
			function FadeFailure()

				-- Fades every line
				for i=1, linenumber do
					transition.to(lines[i], {time=100, alpha=0.0})
				end	

				-- For each ball, if the ball exists, removes it
				for i=1,3 do
					if ball[i][2] == true then
						transition.to(ball[i][1], {time=100, alpha=0.0})
					end
				end	

				-- Fades words and buttons
				transition.to(myGO1, {time=100, alpha=0.0})
				transition.to(myGO2, {time=100, alpha=0.0})
				transition.to(homebutton, {time=100, alpha=0.0})
				transition.to(playbutton, {time=100, alpha=0.0, onComplete=RemoveFailure})

			end -- end of FadeFailure

			-- Stops physics
			physics.stop()

			-- Records that the game has ended
			itbegins = false

			-- Removes all event listeners
			Runtime:removeEventListener( "enterFrame", CheckComplete )
			Runtime:removeEventListener( "enterFrame", CheckFailure )
			Runtime:removeEventListener( "touch", CreateLine )

			-- Creates first part of "game over" title
			myGO1 = display.newText("GAME", display.contentCenterX, 140, native.systemFont, 70)
			myGO1:setFillColor(1, 0,0)
			
			-- Creates second part of "game over" title
			myGO2 = display.newText("OVER", display.contentCenterX, 210, native.systemFont, 70)
			myGO2:setFillColor(1, 0,0)

			-- This function occurs if the play button is clicked
			function PlayClick( event )

				-- If the play button is released
				if ("ended" == event.phase) then

					choice = "game"	-- User wants to play again
					FadeFailure() -- Fades failure menu elements

				end -- end of if loop

			end -- end of PlayClick

			-- Creates the play button
			playbutton = widget.newButton
			{
				width = 240,
				height = 70,
				defaultFile = "Images/play.png",
				overFile = "Images/play-over.png",
				onEvent = PlayClick
			}
			-- Positions the play button
			playbutton.x = display.contentCenterX
			playbutton.y = 300
			
			-- This function occurs when the home button is clicked
			function HomeClick( event )
	
				-- If the home button is released
				if ("ended" == event.phase ) then

					choice = "home" -- User wants to go to the home menu
					FadeFailure()	-- Fades failure menu elements
				end

			end -- end of HomeClick

			-- Creates the home button
			homebutton = widget.newButton
			{
				width = 240,
				height = 70,
				defaultFile = "Images/home.png",
				overFile = "Images/home-over.png",
				onEvent = HomeClick
			}
			-- Positions the home button
			homebutton.x = display.contentCenterX
			homebutton.y = 400

		end	-- end of Failure

		-- This function occurs for each round of the game
		function Round()
				
			-- Adds physics to each ball
			physics.addBody(ball[1][1], {radius=10})
			physics.addBody(ball[2][1], {radius=10})
			physics.addBody(ball[3][1], {radius=10})

			-- Records that the round has begun
			itbegins = true

			-- Records that each ball exists
			for i=1,3 do
				ball[i][2] = true
			end

			movingbucket = false -- The bucket is not moving
			stillmoments = 0	-- The balls have been not moving for 0 moments

			-- This function performs the countdowns for the game (but not the first countdown)
			function NextCountDown()

				number2:removeSelf() -- Removes current number
				timeleft = timeleft - 1 -- Subtracts one to time left
				
				-- If the amount of time left is above 0
				if timeleft > 0 then
					number2 = display.newText(timeleft, display.contentCenterX, display.contentCenterY, native.systemFont, 50)	-- Displays number
					number2:setFillColor( 0,0,0 )	-- Colours number
					timer.performWithDelay( 1000, NextCountDown)	-- Goes to next number after 1 second
				else
					Round()	-- Once countdown finishes, starts round
				end	

			end -- end of Next CountDown

			-- This function prepares each round (but not the first round)
			function PrepareNextRound()
			
				-- Starts physics
				physics.start()

				-- Records that the round hasn't started yet
				itbegins = false

				-- Removes event listeners
				Runtime:removeEventListener( "enterFrame", CheckComplete )
				Runtime:removeEventListener( "enterFrame", CheckFailure )

				-- Creates the three balls
				ball[1][1] = display.newCircle(display.contentCenterX - 50, 0, 10)
				ball[2][1] = display.newCircle(display.contentCenterX + 50, 0, 10)
				ball[3][1] = display.newCircle(display.contentCenterX, 0, 10)

				-- Puts bucket in front of balls
				bucket:toFront()

				-- Colours each ball
				for i=1,3 do 
					ball[i][1]:setFillColor(0,0,0)
				end

				timeleft=3 -- Three seconds left before round begins

				-- Creates and colours number
				number2 = display.newText(timeleft, display.contentCenterX, display.contentCenterY, native.systemFont, 50)
				number2:setFillColor( 0,0,0 )
				timer.performWithDelay(1000, NextCountDown) -- Begins countdown after 1 second

			end	-- end of PrepareNextRound


			-- This function checks to see if all three balls have landed in the bucket
			function CheckComplete( event )

				-- For each ball
				for i=1,3 do

					-- If the ball exists
					if ball[i][2] == true then

						-- If the ball is in the bucket
						if (ball[i][1].x < position + 23 and ball[i][1].x > position - 23) and (ball[i][1].y > 490) then					
							ball[i][1]:removeSelf() -- Removes ball
							ball[i][2] = false -- Records that the ball no longer exists
						end
					end	
				end -- end of for loop

				-- If no balls exist anymore, and the bucket isn't moving
				if (ball[1][2] == false and ball[2][2] == false and ball[3][2] == false and movingbucket == false) then
					itbegins = false -- Ends round
					movingbucket = true -- Records that the bucket is now moving
					score = score + 1 -- Adds one to score
					myscore.text = score -- Updates score

					-- Moves bucket to random location
					position = math.random(33, display.contentWidth - 33)
					transition.to(side1, {time=0, x=position-33})
					transition.to(side2, {time=0, x=position+33, } )
					transition.to(bucket, {x=position, time=100, onComplete=PrepareNextRound})
					
				end	-- end of if loop

			end -- end of CheckComplete

			-- Event listener to check if the round is completed
			Runtime:addEventListener( "enterFrame", CheckComplete ) 	

			-- This function checks to see if the user has failed: either if a ball is out of bounds, or all the exisiting balls are motionless
			function CheckFailure( event )

				-- For each ball
				for i=1,3 do

					-- If the ball exists and the round has begun
					if ball[i][2] == true and itbegins == true then

						-- If the ball is out of bounds
						if (ball[i][1].x > display.contentWidth + 10 or ball[i][1].x < -10) or (ball[i][1].y > 540) then
							Failure() -- Ends game
						end
					end

				end -- end of for loop

				-- If one or more balls exist and the round has begun
				if (ball[1][2] == true or ball[2][2] == true or ball[3][2] == true) and itbegins == true then
					allstill = true -- Assumes no balls are moving

					-- For each ball
					for i=1,3 do

						-- If the ball exists
						if ball[i][2] == true then
							velocities[i][1], velocities[i][2] = ball[i][1]:getLinearVelocity()	-- Get velocity of ball

							-- If the ball is moving
							if velocities[i][1] > 1 or velocities[i][1] < -1 or velocities[i][2] > 1 or velocities[i][2] < -1 then
								allstill = false -- The balls are not all still
							end	
						end		

					end	-- end of for loop

					-- If no balls are moving
					if allstill == true then
						stillmoments = stillmoments + 1 -- Add one to the number of still moments
					end

					-- If there have been 20 still moments
					if stillmoments == 20 then
						stillmoments = 0
						Failure() -- Ends game
					end

				end	-- end of if loop

			end	-- end of CheckFailure

			--Event listener to check if the user has failed
			Runtime:addEventListener( "enterFrame", CheckFailure ) 

		end -- end of Round	
		
		-- This function performs the first countdown for the game
		function CountDown()

			number:removeSelf() -- Removes current number
			timeleft = timeleft - 1 -- Subtracts one to time left
			
			-- If the amount of time left is above 0
			if timeleft > 0 then
				number = display.newText(timeleft, display.contentCenterX, display.contentCenterY, native.systemFont, 50) -- Displays number
				number:setFillColor( 0,0,0 ) -- Colours number	
				timer.performWithDelay( 1000, CountDown) -- Goes to next number after 1 second
			else
				Round() -- Once countdown finishes, starts round
			end	

		end -- end of CountDown

		-- This function prepares the first round
		function PrepareRound()

			-- Starts physics
			physics.start()

			-- Adds physics to the two entrances and two sides of the bucket
			physics.addBody(entrance1, "static", {})
			physics.addBody(entrance2, "static", {})
			physics.addBody(side1, "static", {})
			physics.addBody(side2, "static", {})
				
			-- Creates 3x2 array - one column for balls, and one column for whether that ball exists	
			ball= {}
			for i = 1,3 do
				ball[i] = {}
				ball[i][2] = true -- Records that each ball exists
			end	

			-- Creates the three balls
			ball[1][1] = display.newCircle(display.contentCenterX - 50, 0, 10)
			ball[2][1] = display.newCircle(display.contentCenterX + 50, 0, 10)
			ball[3][1] = display.newCircle(display.contentCenterX, 0, 10)

			-- Puts bucket in front of balls
			bucket:toFront()

			-- Colours each ball
			for i = 1,3 do 
				ball[i][1]:setFillColor(0,0,0)
			end

			timeleft = 3 -- Three seconds left before round begins
			number = display.newText(timeleft, display.contentCenterX, display.contentCenterY, native.systemFont, 50) -- Displays number
			number:setFillColor( 0,0,0 ) -- Colours number
			timer.performWithDelay(1000, CountDown) -- Starts countdown after one second

		end	-- end of PrepareRound

		-- Prepares Round
		PrepareRound()

	end	-- end of Game

	-- This function prepares the game
	function PrepareGame()

		-- Starts physics
		physics.start()

		-- Creates score, colours it, and sets it to 0
		score = 0
		myscore = display.newText(score, 300, 0, native.systemFont, 18)
		myscore:setFillColor(0,0,0)
		
		-- Creates first entrance, colours it, and adds physics to it
		entrance1 = display.newPolygon(display.contentWidth/4 - 30, 45, {-display.contentWidth/4-20,-35, display.contentWidth/4, 35, -display.contentWidth/4-20, 35})
		entrance1:setFillColor(0,0,0)
		physics.addBody(entrance1, "static", {})

		-- Creates second entrance, colours it, and adds physics to it
		entrance2 = display.newPolygon(display.contentWidth/4*3 + 20, 50, {-display.contentWidth/4 + 20,30, display.contentWidth/4 + 20, -30, display.contentWidth/4 + 20, 30})
		entrance2:setFillColor(0,0,0)
		physics.addBody(entrance2, "static", {})

		-- Position of bucket (right in the middle of the screen for the first round)
		position = display.contentCenterX

		-- Creates first side of bucket, and adds physics to it
		side1 = display.newLine(position-33, 470, position-23, 530)
		physics.addBody(side1, "static", {})

		-- Creates second side of bucket, and adds physics to it
		side2 = display.newLine(position+33, 470, position+23, 530)
		physics.addBody(side2, "static", {})

		-- Creates bucket
		bucket = display.newImage("Images/Bucket.png", position, 500)

		-- Creates table to record the velocities of the balls
		velocities = {}
		for i=1,3 do
			velocities[i] = {}
		end

		-- Begins game
		Game()

	end	-- end of PrepareGame
	
	-- This function removes the title menu elements
	function RemoveTitleMenu()
	
		-- Removes title menu elements
		title:removeSelf()
		playbutton:removeSelf()
	
		-- Prepares Game
		PrepareGame()
	
	end -- end of RemoveTitleMenu

	-- This function displays the title menu
	function TitleMenu()
	
		-- Displays game title and copyright
		title = display.newImage( "Images/title.png", display.contentCenterX, 150 ) 
		copyright = display.newImage("Images/copyright.png", display.contentCenterX, 440)

		-- This function occurs if the play button is clicked
		local function PlayClick(event)

			-- If the play button is released
		    if ("ended" == event.phase) then

		    	-- Fades the elements of the title menu
		    	transition.to(title, {time=100, alpha=0.0})
		    	transition.to(copyright, {time=100, alpha=0.0})
		    	transition.to(playbutton, {time=100, alpha=0.0, onComplete = RemoveTitleMenu})			
		    end

		end -- end of PlayClick

		-- Creates the play button
		playbutton = widget.newButton
		{
		    width = 240,
		    height = 70,
		    defaultFile = "Images/play.png",
		    overFile = "Images/play-over.png",
		    onEvent = PlayClick
		}
		-- Positions the play button
		playbutton.x = display.contentCenterX
		playbutton.y = 340

	end -- end of TitleMenu
	
	TitleMenu()
	
end

Program()