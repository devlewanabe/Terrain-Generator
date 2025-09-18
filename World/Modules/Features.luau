--!strict

local Types = require(script.Parent.Parent.Types)
local Voxel = require(script.Parent.Parent.Utility.Voxel)

type WorldParameters = Types.WorldParameters
type Folders = Types.Folders
type HeightMap = Types.HeightMap
type OccupancyGrid = Types.OccupancyGrid

local Features = {}

-- ROCKS
local function spawnCluster(position: Vector3, blockSize: number, rockFolder: Folder, stoneColor: BrickColor)
	for _ = 1, math.random(2, 4) do
		local offset = Vector3.new(
			math.random(-blockSize, blockSize),
			math.random(0, blockSize), -- sit on terrain level
			math.random(-blockSize, blockSize)
		)
		local rockSize = Vector3.new(
			blockSize * math.random(1, 2),
			blockSize * math.random(1, 2),
			blockSize * math.random(1, 2)
		)
		Voxel.Create(position + offset, rockSize, stoneColor, Enum.Material.SmoothPlastic, nil, rockFolder)
	end
end

-- TREES
local function greedyMeshCanopy(yPos: number, x: number, z: number, blockSize: number, leafColor: BrickColor, parent: Model)
	local visited = {}
	for i = -1, 1 do visited[i] = {} end

	for dx = -1, 1 do
		for dz = -1, 1 do
			if not visited[dx][dz] and math.random() < 0.8 then -- lower than one to determine the shape
				local w = 1
				--[[
				starts at dx[-1..1] and expands along width
				stops if we reach the canopy's edge, if we've already visited the next cell or the math.random fails
				]]
				while dx + w <= 1 and not visited[dx + w][dz] and math.random() < 0.8 do -- >> >>
					w += 1
				end

				local d = 1
				local done = false
				
				--[[
				
				checks every cell along the width
				if the cell is already visited or the math.random fails, it stops
				
				]]
				while dz + d <= 1 and not done do
					for i = dx, dx + w - 1 do
						if visited[i][dz + d] or math.random() >= 0.8 then
							done = true
							break
						end
					end
					if not done then d += 1 end
				end

				for i = dx, dx + w - 1 do
					for j = dz, dz + d - 1 do
						visited[i][j] = true
					end
				end

				-- size, pos to determine the attributes of the greedy-meshed canopy
				local partSize = Vector3.new(w * blockSize, blockSize, d * blockSize)
				--[[ 
					partPos where: 
					
					dx is the merged's start relative to the center
					w/2 - 0.5 centers along x
					
					dz >> >>
				]]
				local partPos = Vector3.new(
					x + (dx + (w/2) - 0.5) * blockSize,
					yPos,
					z + (dz + (d/2) - 0.5) * blockSize
				)
				Voxel.Create(partPos, partSize, leafColor, Enum.Material.SmoothPlastic, nil, parent)
			end
		end
	end
end

local function spawnTree(x: number, y: number, z: number, blockSize: number, treeFolder: Folder, woodColor: BrickColor, leafColor: BrickColor, useGreedy: boolean)
	local treeModel = Instance.new("Model", treeFolder)
	treeModel.Name = "Tree"

	local trunkHeight = math.random(3, 5)

	if useGreedy then
		local trunkSize = Vector3.new(blockSize, trunkHeight * blockSize, blockSize)
		local trunkPos = Vector3.new(x, y + (trunkHeight * blockSize) / 2, z) -- center vertically
		Voxel.Create(trunkPos, trunkSize, woodColor, Enum.Material.SmoothPlastic, nil, treeModel)

		local topY = y + trunkHeight * blockSize
		for dy = -1, 1 do
			greedyMeshCanopy(topY + dy * blockSize, x, z, blockSize, leafColor, treeModel)
		end
	else
		for i = 1, trunkHeight do
			local trunkPos = Vector3.new(x, y + (i - 1) * blockSize, z)
			Voxel.Create(trunkPos, Vector3.one * blockSize, woodColor, Enum.Material.SmoothPlastic, nil, treeModel)
		end
		--dx, dy, dz ∈ {-1,0,1}
		local topY = y + trunkHeight * blockSize
		for dx = -1, 1 do
			for dy = -1, 1 do
				for dz = -1, 1 do
					if math.random() < 0.8 then
						local leafPos = Vector3.new(x + dx * blockSize, topY + dy * blockSize, z + dz * blockSize)
						Voxel.Create(leafPos, Vector3.one * blockSize, leafColor, Enum.Material.SmoothPlastic, nil, treeModel)
					end
				end
			end
		end
	end
end

-- CLOUDS
local function spawnCloud(position: Vector3, cloudFolder: Folder)
	local cloudModel = Instance.new("Model", cloudFolder)
	cloudModel.Name = "Cloud"

	for _ = 1, math.random(3, 6) do
		local size = Vector3.new(math.random(15, 25), math.random(2, 4), math.random(15, 25))
		local offset = Vector3.new(math.random(-10, 10), math.random(-2, 2), math.random(-10, 10))
		Voxel.Create(position + offset, size, BrickColor.new("Institutional white"), Enum.Material.SmoothPlastic, 0.5, cloudModel)
	end
end

function Features.GenerateTreesAndRocks(params: WorldParameters, folders: Folders, heights: HeightMap)
	local occupancyGrid: OccupancyGrid = {}
	for i = 1, params.gridSize do occupancyGrid[i] = {} end

	local halfGrid = params.gridSize / 2

	for gx = 1, params.gridSize do
		for gz = 1, params.gridSize do
			local colHeight = heights[gx][gz]
			local worldX = (gx - halfGrid) * params.blockSize
			local worldZ = (gz - halfGrid) * params.blockSize

			-- Rocks
			if colHeight > params.waterLevel + 2 and math.random() < params.rockProbability and not occupancyGrid[gx][gz] then
				local rockPos = Vector3.new(worldX, (colHeight + 0.5) * params.blockSize, worldZ)
				spawnCluster(rockPos, params.blockSize, folders.Rocks, params.stoneColor)
			end

			-- Trees
			
			--spawn tree within [waterLevel+1, waterLevel+6]
			if colHeight > params.waterLevel + 1 and colHeight <= params.waterLevel + 6 and math.random() < params.treeProbability then
				local spawnX, spawnZ = gx, gz

				-- ensure no trees have been spawned within (2r+1)^2 cells
				local isCellFree = function(x: number, z: number, r: number): boolean
					for i = x - r, x + r do
						for j = z - r, z + r do
							if occupancyGrid[i] and occupancyGrid[i][j] then return false end
						end
					end
					return true
				end

				-- to prevent overlap, we check if within an area of (2r+1)^2 cells around (gx, gz) there is another tree before generating a new one
				if not isCellFree(gx, gz, 1) then
					local found = false
					for r = 1, 2 do
						for dx = -r, r do
							for dz = -r, r do
								-- only check around the perimeter where |dx| ∨ |dz| = r
								if math.abs(dx) ~= r and math.abs(dz) ~= r then continue end
								local nx, nz = gx + dx, gz + dz
								-- coordinates (nx, nz) must stay within grid bounds of 1 <= nx, nz <= gridSize
								if nx >= 1 and nx <= params.gridSize and nz >= 1 and nz <= params.gridSize and isCellFree(nx, nz, 1) then
									spawnX, spawnZ = nx, nz
									found = true
									break
								end
							end
							if found then break end
						end
						if found then break end
					end
					if not found then continue end
				end

				--mark the 3x3 grid centered at (spawnX, spawnZ) as occupied to prevent spawning more trees
				for i = spawnX - 1, spawnX + 1 do
					for j = spawnZ - 1, spawnZ + 1 do
						if occupancyGrid[i] then occupancyGrid[i][j] = true end
					end
				end

				local newWorldX = (spawnX - halfGrid) * params.blockSize
				local newWorldZ = (spawnZ - halfGrid) * params.blockSize
				local newColHeight = heights[spawnX][spawnZ]
				local treeBaseY = (newColHeight - 0.5) * params.blockSize
				spawnTree(newWorldX, treeBaseY, newWorldZ, params.blockSize, folders.Trees, params.dirtColor, params.leafColor, params.greedyMeshingTrees)
			end
		end
	end
end

function Features.GenerateClouds(params: WorldParameters, folders: Folders)
	for _ = 1, params.cloudCount do
		local cloudPos = Vector3.new(
			math.random(-params.gridSize * params.blockSize, params.gridSize * params.blockSize),
			math.random(80, 100),
			math.random(-params.gridSize * params.blockSize, params.gridSize * params.blockSize)
		)
		spawnCloud(cloudPos, folders.Clouds)
	end
end

return Features
