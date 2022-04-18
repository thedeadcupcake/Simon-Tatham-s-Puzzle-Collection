local puzzle = {}
local template = script.square
local events = {}

local currentSpace = Vector2.new(1, 1)

local grid, width, height, moves, statusLabel
local win = false

local originalSize, originalContainer

local function checkWin()
	local i = 1
	
	for y = 1, height do
		for x = 1, width do		
			if not grid[y][x] then return false end
			
			if tonumber(grid[y][x].TextLabel.Text) ~= i then
				return false
			end
			
			i += 1
			if i == height*width then break end
		end
	end
	return true
end

local function updateStatusLabel()
	win = win or checkWin() -- variable will lock to true once game is won
	statusLabel.Text = "Moves: " .. moves
	if win then
		statusLabel.Text = "COMPLETED " .. statusLabel.Text
	end
end

function puzzle:begin(container, options)
	originalSize = container.Size
	originalContainer = container
	width = options.Width
	height = options.Height
	grid = table.create(height)
	moves = 0
	
	if height > width then -- if the box is taller then resize the height, else resize the width
		container.Size = UDim2.fromOffset(container.Size.X.Offset / (height/width), container.Size.Y.Offset)
	else
		container.Size = UDim2.fromOffset(container.Size.X.Offset, container.Size.Y.Offset / (width/height))
	end
	
	local i = 1
	
	for y = 1, height do 
		grid[y] = table.create(width)
		for x = 1, width do 
			local square = Instance.new("ImageButton")
			square.Position = UDim2.fromScale(x*(1/width), y*(1/height))
			square.Size = UDim2.fromScale(1/width, 1/height)
			square.Name = x.."_"..y
			square.BackgroundTransparency = 1
			square.Image = "rbxassetid://9391056416"
			square.ScaleType = Enum.ScaleType.Slice
			square.SliceCenter = Rect.new(256, 256, 256, 256)
			square.SliceScale = 0.3
			square.ImageColor3 = Color3.fromRGB(232, 232, 232)
			square.AnchorPoint = Vector2.new(1, 1)
			square.Parent = container
			local label = Instance.new("TextLabel")
			label.Text = i
			label.Size = UDim2.fromScale(.6, .6)
			label.Position = UDim2.fromScale(.5, .5)
			label.BackgroundTransparency = 1
			label.TextScaled = true
			label.Font = Enum.Font.Arial
			label.AnchorPoint = Vector2.new(.5, .5)
			label.Parent = square
			
			grid[y][x] = square
			
			i += 1 -- count up for the text
			
			square.MouseButton1Down:Connect(function()
				currentSpace = puzzle:moveSpaceTo(currentSpace, square.Name)
				updateStatusLabel()
			end)
		end
	end
	
	grid[height][width]:Destroy() -- remove the last square
	currentSpace = width.."_"..height
	
	for i = 1, (height * width)^1.5 do
		local x, y = table.unpack(string.split(currentSpace, "_"))
		currentSpace = puzzle:moveSpaceTo(currentSpace, x.."_"..math.random(1, height))
		
		x, y = table.unpack(string.split(currentSpace, "_"))
		currentSpace = puzzle:moveSpaceTo(currentSpace, math.random(1, width).."_"..y)
	end
	
	moves = 0
	
	statusLabel = Instance.new("TextLabel")
	statusLabel.BackgroundTransparency = 1
	statusLabel.Font = Enum.Font.JosefinSans
	statusLabel.TextSize = 16
	statusLabel.TextXAlignment = Enum.TextXAlignment.Left
	statusLabel.Position = UDim2.new(1, 4, 0, 0)
	statusLabel.Size = UDim2.new(0, 0, 0, 20)
	statusLabel.Parent = container
	updateStatusLabel()
end

-- true for win, false for lose, nil for in progress
function puzzle:status()
	
end

function puzzle:clear()
	for y = 1, height do
		for x = 1, width do
			if grid[y][x] then
				grid[y][x]:Destroy()
			end
		end
	end
	originalContainer.Size = originalSize
	grid = nil
	height = nil
	width = nil
	win = false
	moves = nil
	statusLabel:Destroy()
end

-- for finding a square using vector2 values
function puzzle:getSquare(pos)
	return grid[pos.Y][pos.X]
end

local function updateGrid()
	for y = 1, height do
		for x = 1, width do
			grid[y][x] = originalContainer:FindFirstChild(x.."_"..y)
		end
	end
end

-- attempt to move the empty space. pos should be a string laid out as x_y. returns the new position. returns nil if unsuccessful
function puzzle:moveSpaceTo(current, pos)
	local x, y = table.unpack(string.split(pos, "_")) -- get x and y
	local currentX, currentY = table.unpack(string.split(current, "_"))
	
	if not x or not y then return current end
	
	if x ~= currentX and y ~= currentY then return current end 
	
	local moveDir -- the direction that squares will be shifted
	local magnitude -- distance away from new space position
	local endMagnitude -- magnitude to end at
	
	-- get the moving direction as well as other stuff
	if x < currentX then 
		moveDir = Vector2.new(1, 0)
		magnitude = x
		endMagnitude = width
	elseif x > currentX then
		moveDir = Vector2.new(-1, 0)
		magnitude = x
		endMagnitude = 1
	end
	
	if y < currentY then 
		moveDir = Vector2.new(0, 1)
		magnitude = y
		endMagnitude = height
	elseif y > currentY then
		moveDir = Vector2.new(0, -1)
		magnitude = y
		endMagnitude = 1
	end
	
	local moving = Vector2.new(x, y) -- the square being currently moved
	
	if not moveDir then return current end
	
	-- move the squares out of the way
	repeat 
		local moveSquare = puzzle:getSquare(moving)
		if not moveSquare then break end
		
		moving = moving + moveDir
		
		moveSquare.Position = UDim2.fromScale(moving.X * (1/width), moving.Y * (1/height))
		moveSquare.Name = moving.X.."_"..moving.Y
	until math.abs((moving*moveDir).Magnitude) == endMagnitude
	
	updateGrid()
	moves += 1
	
	return pos
end

puzzle.info = {
	name = "Fifteen",
	description = "Slide the tiles around to arrange them into order.",
	image = "rbxassetid://9398819305",
	instructions = [[Slide the tiles around the box until they appear in numerical order from the top left, with the hole in the bottom right corner.

	Click on a tile to slide it towards the hole.]],
}

puzzle.options = {
	{
		name = "Width",
		valueType = "integer",
		min = 1,
		max = 20,
	},
	{
		name = "Height",
		valueType = "integer",
		min = 1,
		max = 20,
	},
}

puzzle.presets = {
	{
		name = "3x3",
		info = {
			Width = 3,
			Height = 3,
		},
	},
	{
		name = "4x4",
		info = {
			Width = 4,
			Height = 4,
		},
	},
	{
		name = "5x5",
		info = {
			Width = 5,
			Height = 5,
		},
	},
	{
		name = "6x6",
		info = {
			Width = 6,
			Height = 6,
		},
	},
	{
		name = "7x7",
		info = {
			Width = 7,
			Height = 7,
		},
	},
	{
		name = "4x2",
		info = {
			Width = 4,
			Height = 2,
		},
	},
	{
		name = "3x4",
		info = {
			Width = 3,
			Height = 4,
		},
	},
}

puzzle.defaultPreset = 2

return puzzle
