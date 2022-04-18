local puzzle = {}

local COLORS = {
	[1] = Color3.fromRGB(255, 0, 0),
	[2] = Color3.fromRGB(255, 255, 0),
	[3] = Color3.fromRGB(0, 255, 0),
	[4] = Color3.fromRGB(51, 77, 255),
	[5] = Color3.fromRGB(255, 128, 0),
	[6] = Color3.fromRGB(128, 0, 179),
	[7] = Color3.fromRGB(128,77,77),
	[8] = Color3.fromRGB(102,204,255),
	[9] = Color3.fromRGB(179,255,179),
	[10] = Color3.fromRGB(255,153,255),
}

local width, height, grid, statusLabel, moves, maxMoves, failed

-- true: completed, false: failed, nil: ongoing
local function checkStatus()
	if failed then return false end
	local movesRemaining
	if moves < maxMoves then
		movesRemaining = nil
	else
		movesRemaining = false
	end
	local color = grid[1][1].BackgroundColor3
	for y = 1, height do
		for x = 1, width do
			if grid[y][x].BackgroundColor3 ~= color then
				return movesRemaining
			end
		end
	end
	return true
end

local function updateStatusLabel()
	local status = checkStatus()
	statusLabel.Text = string.format("%d/%d moves", moves, maxMoves)
	if status == true then
		statusLabel.Text = "COMPLETED " .. statusLabel.Text
	elseif status == false then
		statusLabel.Text = "FAILED " .. statusLabel.Text
		failed = true
	else
		assert(status == nil)
	end
end

local function floodRegion(x, y, color)
	local originalColor = grid[y][x].BackgroundColor3
	if originalColor == color then return end
	grid[y][x].BackgroundColor3 = color
	for yOffset = -1, 1 do
		for xOffset = -1, 1 do
			if math.abs(xOffset) == 1 and math.abs(yOffset) == 1 then continue end
			local newX = x + xOffset
			local newY = y + yOffset
			if newX < 1 or newX > width or newY < 1 or newY > height then continue end
			local cell = grid[newY][newX]
			if cell.BackgroundColor3 == originalColor then
				floodRegion(newX, newY, color)
			end
		end
	end
end

local function getBlobSize()
	local oldGrid = table.create(height)
	for y = 1, height do
		oldGrid[y] = table.create(width)
		for x = 1, width do
			oldGrid[y][x] = grid[y][x].BackgroundColor3
		end
	end
	local original = grid[1][1].BackgroundColor3
	floodRegion(1, 1, Color3.fromRGB(1, 2, 3))
	local new = 0
	for y = 1, height do
		for x = 1, width do
			if grid[y][x].BackgroundColor3 ~= oldGrid[y][x] then
				new = new + 1
			end
		end
	end
	floodRegion(1, 1, original)
	return new
end

local function chooseColor(color)
	local old = getBlobSize()
	floodRegion(1, 1, color)
	local new = getBlobSize()
	if new ~= old then
		moves = moves + 1
		updateStatusLabel()
	end
end

function puzzle:begin(container, options)
	width = options.Width
	height = options.Height
	local colors = options.Colors
	local extraMoves = options["Extra moves permitted"]
	
	local cellSize = math.floor(container.AbsoluteSize.X / width)
	
	moves = 0
	maxMoves = 20 + extraMoves -- TODO
	failed = false
	
	grid = table.create(height)
	for y = 1, height do
		grid[y] = table.create(width)
		for x = 1, width do
			local cell = Instance.new("TextButton")
			cell.BackgroundColor3 = COLORS[math.random(1, colors)]
			cell.BorderSizePixel = 0
			cell.Size = UDim2.new(0, cellSize, 0, cellSize)
			cell.Position = UDim2.new(0, cellSize * (x - 1), 0, cellSize * (y - 1))
			cell.Text = ""
			cell.Parent = container
			
			cell.MouseButton1Click:Connect(function()
				chooseColor(cell.BackgroundColor3)
			end)
			
			grid[y][x] = cell
		end
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
	grid = nil
	width = nil
	height = nil
	moves = nil
	failed = nil
	statusLabel:Destroy()
	statusLabel = nil
end

puzzle.info = {
	name = "Flood",
	description = "Turn the grid the same colour in as few flood fills as possible.",
	image = "rbxassetid://9400565801",
	instructions = [[
Try to get the whole grid to be the same colour within the given number of moves, by repeatedly flood-filling the top left corner in different colours.

Click in a square to flood-fill the top left corner with that square's colour.]],
}

puzzle.options = {
	{
		name = "Width",
		valueType = "integer",
		min = 1,
		max = 36,
	},
	{
		name = "Height",
		valueType = "integer",
		min = 1,
		max = 36,
	},
	{
		name = "Colors",
		valueType = "integer",
		min = 3,
		max = 10,
	},
	{
		name = "Extra moves permitted",
		valueType = "integer",
		min = 0,
		max = 100,
	},
}

puzzle.presets = {
	{
		name = "12x12 Easy",
		info = {
			Width = 12,
			Height = 12,
			Colors = 6,
			["Extra moves permitted"] = 5,
		},
	},
	{
		name = "12x12 Medium",
		info = {
			Width = 12,
			Height = 12,
			Colors = 6,
			["Extra moves permitted"] = 2,
		},
	},
	{
		name = "12x12 Hard",
		info = {
			Width = 12,
			Height = 12,
			Colors = 6,
			["Extra moves permitted"] = 0,
		},
	},
	{
		name = "16x16 Medium",
		info = {
			Width = 16,
			Height = 16,
			Colors = 6,
			["Extra moves permitted"] = 2,
		},
	},
	{
		name = "16x16 Hard",
		info = {
			Width = 16,
			Height = 16,
			Colors = 6,
			["Extra moves permitted"] = 0,
		},
	},
	{
		name = "12x12, 3 colours",
		info = {
			Width = 12,
			Height = 12,
			Colors = 3,
			["Extra moves permitted"] = 0,
		},
	},
	{
		name = "12x12, 4 colours",
		info = {
			Width = 12,
			Height = 12,
			Colors = 4,
			["Extra moves permitted"] = 0,
		},
	},
}

puzzle.defaultPreset = 1

return puzzle
