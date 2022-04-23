local puzzle = {}
local events = {}

local square = script.arrow

local grid, width, height, moves, statusLabel
local win = false

local cellsizeX, cellsizeY
local originalSize, originalContainer
local arrows = {}

-- translates rotation to direction
local rotationTable = {
	[0] = Vector2.new(0, -1),
	[90] = Vector2.new(1, 0),
	[180] = Vector2.new(0, 1),
	[270] = Vector2.new(-1, 0),
}

local function wrap(x, x_min, x_max)
	x_max+=1
	return (((x - x_min) % (x_max - x_min)) + (x_max - x_min)) % (x_max - x_min) + x_min;
end

local function getKeys(t)
	local s = {}
	for k, v in pairs(t) do
		table.insert(s, k)
	end
	return s
end

local function getLen(t)
	local x = 0
	
	for _, _ in pairs(t) do
		x += 1
	end
	
	return x
end

local function checkWin()
	local i = 1

	for y = 1, height do
		for x = 1, width do
			if tonumber(grid[y][x].TextLabel.Text) ~= i then
				return false
			end

			i += 1
		end
	end
	return true
end

local function updateGrid()
	for y = 1, height do
		for x = 1, width do
			grid[y][x] = originalContainer.inset:FindFirstChild(x.."_"..y)
		end
	end
end

local function updateStatusLabel()
	win = win or checkWin() -- variable will lock to true once game is won
	statusLabel.Text = "Moves: " .. moves
	if win then
		statusLabel.Text = "COMPLETED " .. statusLabel.Text
	end
end

local function generateArrow(pos, rotation, parent)
	local x = pos.X
	local y = pos.Y
	
	local square = Instance.new("ImageButton")
	square.Position = UDim2.fromOffset(x*cellsizeX, y*cellsizeY)
	square.Size = UDim2.fromOffset(cellsizeX, cellsizeY)
	square.Name = x.."_"..y
	square.BackgroundTransparency = 1
	square.ImageTransparency = 1
	square.AnchorPoint = Vector2.new(1, 1)

	local label = Instance.new("ImageLabel")
	label.Size = UDim2.fromScale(.6, .6)
	label.Position = UDim2.fromScale(.5, .5)
	label.BackgroundTransparency = 1
	label.AnchorPoint = Vector2.new(.5, .5)
	label.Image = "rbxassetid://9400617409"
	label.Parent = square
	label.Rotation = rotation
	
	square.Parent = parent
	
	return square
end

function puzzle:Move(pos, direction)
	local final = (Vector2.new(width, height) * direction) + pos + direction
	final = Vector2.new(wrap(final.X, 1, width) - 1, wrap(final.Y, 1,  height) - 1)
	
	local current = final
	local wrapped = final
	
	local timeout = 0
	
	repeat
		local square = puzzle:getSquare(wrapped)
		
		current += direction
		wrapped = Vector2.new(wrap(current.X, 1, width), wrap(current.Y, 1,  height))
		
		if square then
			square.Position = UDim2.fromOffset((wrapped.X-1) * cellsizeX, (wrapped.Y-1) * cellsizeY - 1)
			square.Name = wrapped.X.."_"..wrapped.Y
		end
		
		timeout += 1
	until wrapped == final or timeout >=  width * height -- dont change the timeout because it fixes the last row and column
	
	updateGrid()
	moves += 1
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
	
	cellsizeX = originalContainer.AbsoluteSize.X/(width+2)
	cellsizeY = originalContainer.AbsoluteSize.Y/(height+2)
	
	local inset = Instance.new("Frame")
	inset.Size = UDim2.fromOffset((cellsizeX*width)-(cellsizeX*2), (cellsizeY*height)-(cellsizeY*2))
	inset.Position = UDim2.fromScale(.5, .5)
	inset.AnchorPoint = Vector2.new(.5, .5)
	inset.Name = "inset"
	inset.BackgroundTransparency = 1
	inset.ZIndex = 2
	inset.Parent = container
	
	for y = 1, height do 
		grid[y] = table.create(width)
		for x = 1, width do 
			local square = Instance.new("ImageLabel")
			square.Position = UDim2.fromOffset((x-1)*cellsizeX, (y-1)*cellsizeY)
			square.Size = UDim2.fromOffset(cellsizeX, cellsizeY)
			square.Name = x.."_"..y
			square.BackgroundTransparency = 1
			square.Image = "rbxassetid://9391056416"
			square.ScaleType = Enum.ScaleType.Slice
			square.SliceCenter = Rect.new(256, 256, 256, 256)
			square.SliceScale = 0.3
			square.ImageColor3 = Color3.fromRGB(232, 232, 232)
			square.AnchorPoint = Vector2.new(1, 1)
			square.Parent = inset
			
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
		end
	end
	
	arrows.directions = {}
	arrows.arrows = {}
	for i = 1, width do
		local a = Vector2.new(i+1, height)
		local b = Vector2.new(i+1, 1)
		
		arrows.arrows[a] = generateArrow(a + Vector2.new(0, 2), 0, originalContainer)
		arrows.arrows[b] = generateArrow(b, 180, originalContainer)
		
		arrows.directions[a] = rotationTable[0]
		arrows.directions[b] = rotationTable[180]
	end
	
	for i = 1, height do
		local a = Vector2.new(1, i+1)
		local b = Vector2.new(width, i+1)
		
		arrows.arrows[a] = generateArrow(a, 90, originalContainer)
		arrows.arrows[b] = generateArrow(b + Vector2.new(2, 0), 270, originalContainer)
		
		arrows.directions[a] = rotationTable[90]
		arrows.directions[b] = rotationTable[270]
	end
	
	for pos, arrow in pairs(arrows.arrows) do
		arrow.MouseButton1Down:Connect(function()
			puzzle:Move(pos, arrows.directions[pos])
			updateStatusLabel()
		end)
	end
	
	arrows.positions = getKeys(arrows.arrows)
	for i = 1, (height * width)^1.5 do
		local pos = arrows.positions[math.random(1, getLen(arrows.positions))]
		puzzle:Move(pos, arrows.directions[pos])
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
	originalContainer:ClearAllChildren()
	originalContainer.Size = originalSize
	grid = nil
	height = nil
	width = nil
	win = false
	moves = nil
end

-- for finding a square using vector2 values
function puzzle:getSquare(pos)
	if not grid[pos.Y] then return end
	return grid[pos.Y][pos.X]
end

puzzle.info = {
	name = "Sixteen",
	description = "Slide a row at a time to arrange the tiles into order.",
	image = "rbxassetid://9400137795",
	instructions = [[Slide the grid squares around so that the numbers end up in consecutive order from the top left corner.

Click on the arrows at the edges of the grid to move a row or column left, right, up or down. The square that falls off the end of the row comes back on the other end.]],
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
}

puzzle.defaultPreset = 2

return puzzle
