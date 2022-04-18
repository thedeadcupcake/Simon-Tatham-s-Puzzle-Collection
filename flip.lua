local puzzle = {}

local EMPTY_COLOR = Color3.fromRGB(255, 255, 255)
local ACTIVATED_COLOR = Color3.fromRGB(28, 28, 28)

local grid, width, height, statusLabel, moves
local win = false

local function mapNeighbors(x, y, callback)
	for yOffset = -1, 1 do
		for xOffset = -1, 1 do
			if math.abs(yOffset) == 1 and math.abs(xOffset) == 1 then continue end
			local newX = x + xOffset
			local newY = y + yOffset
			if newX >= 1 and newX <= width and newY >= 1 and newY <= height then
				callback(newX, newY, xOffset, yOffset)
			end
		end
	end
end

local function flip(x, y)
	mapNeighbors(x, y, function(newX, newY, xOffset, yOffset)
		local cell = grid[newY][newX]
		if cell.BackgroundColor3 == ACTIVATED_COLOR then
			cell.BackgroundColor3 = EMPTY_COLOR
			cell.BorderColor3 = ACTIVATED_COLOR
		else
			cell.BackgroundColor3 = ACTIVATED_COLOR
			cell.BorderColor3 = EMPTY_COLOR
		end
	end)
end

local function checkWin()
	for y = 1, height do
		for x = 1, width do
			if grid[y][x].BackgroundColor3 ~= EMPTY_COLOR then
				return false
			end
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
	width = options.Width
	height = options.Height
	grid = table.create(height)
	moves = 0
	
	local cellSize = container.AbsoluteSize.X / width
	local minicellSize = cellSize / 6
	
	for y = 1, height do
		grid[y] = table.create(width)
		for x = 1, width do
			local cell = Instance.new("TextButton")
			cell.Position = UDim2.new(0, (x - 1) * cellSize, 0, (y - 1) * cellSize)
			cell.Size = UDim2.new(0, cellSize, 0, cellSize)
			cell.Text = ""
			cell.BackgroundColor3 = EMPTY_COLOR
			cell.BorderColor3 = ACTIVATED_COLOR
			cell.Parent = container
			
			local cellInsideContainer = Instance.new("Frame")
			cellInsideContainer.Size = UDim2.new(0, cellSize * 0.5, 0, cellSize * 0.5)
			cellInsideContainer.AnchorPoint = Vector2.new(0.5, 0.5)
			cellInsideContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
			cellInsideContainer.BackgroundTransparency = 1
			cellInsideContainer.Parent = cell
			
			mapNeighbors(x, y, function(newX, newY, xOffset, yOffset)
				local minicell = Instance.new("Frame")
				minicell.BackgroundColor3 = Color3.fromRGB(127, 127, 127)
				minicell.Position = UDim2.new(0, (xOffset + 1) * minicellSize, 0, (yOffset + 1) * minicellSize)
				minicell.Size = UDim2.new(0, minicellSize, 0, minicellSize)
				minicell.Parent = cellInsideContainer
			end)
			
			cell.Activated:Connect(function()
				flip(x, y)
				moves = moves + 1
				updateStatusLabel()
			end)
			
			grid[y][x] = cell
		end
	end
	
	for i = 1, 10 do
		flip(math.random(1, width), math.random(1, height))
	end
	
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

function puzzle:clear()
	for y = 1, height do
		for x = 1, width do
			grid[y][x]:Destroy()
		end
	end
	statusLabel:Destroy()
	grid = nil
	height = nil
	width = nil
	win = false
	moves = nil
end

puzzle.info = {
	name = "Flip",
	description = "Flip groups of squares to light them all up at once.",
	image = "rbxassetid://9392699036",
	instructions = [[
Try to light up all the squares in the grid by flipping combinations of them.

Click in a square to flip it and some of its neighbours. The diagram in each square indicates which other squares will flip.

Select one of the 'Random' settings from the Type menu for more varied puzzles. (not implemented yet)]],
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
		name = "3x3 Crosses",
		info = {
			Width = 3,
			Height = 3,
		},
	},
	{
		name = "4x4 Crosses",
		info = {
			Width = 4,
			Height = 4,
		},
	},
	{
		name = "5x5 Crosses",
		info = {
			Width = 5,
			Height = 5,
		},
	},
}

puzzle.defaultPreset = 2

return puzzle
