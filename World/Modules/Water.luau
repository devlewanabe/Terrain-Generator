--!strict
--!native
--!optimize 2

local Types = require(script.Parent.Parent.Types)
local Voxel = require(script.Parent.Parent.Utility.Voxel)

type WorldParameters = Types.WorldParameters
type Folders = Types.Folders
type HeightMap = Types.HeightMap

type GridCoord = {x: number, z: number}

local Water = {}

--[[

- gx, gz ∈ {1..gridSize}
- y ∈ {height+1..waterLevel}

]]
local function generateFullDepth(params: WorldParameters, folders: Folders, heights: HeightMap)
	local halfGrid = params.gridSize / 2
	for gx = 1, params.gridSize do
		for gz = 1, params.gridSize do
			local height = heights[gx][gz]
			if height < params.waterLevel then
				local worldX = (gx - halfGrid) * params.blockSize
				local worldZ = (gz - halfGrid) * params.blockSize
				for y = height + 1, params.waterLevel do
					-- shift by -0.5 * blockSize to center vertically
					local worldY = (y - 0.5) * params.blockSize
					Voxel.Create(
						Vector3.new(worldX, worldY, worldZ),
						Vector3.one * params.blockSize,
						params.waterColor,
						Enum.Material.Water,
						0.5,
						folders.Water
					)
				end
			end
		end
	end
end

--[[

- x,z ∈ {1..gridSize}
- y ∈ {1..waterLevel}

]]
local function generatePondSpecificPlanes(params: WorldParameters, folders: Folders, heights: HeightMap)
	local gridSize = params.gridSize
	local waterLevel = params.waterLevel
	
	-- V(g), g ∈ G
	local visited: {[number]: {[number]: boolean}} = {}
	for i = 1, gridSize do
		visited[i] = {}
	end

	for gx = 1, gridSize do
		for gz = 1, gridSize do
			if not visited[gx][gz] and heights[gx][gz] < waterLevel then
				
				
				-- BFS for g' ∈ C and AABB
				local queue: {GridCoord} = {{x = gx, z = gz}}
				visited[gx][gz] = true

				local minPondX, maxPondX = gx, gx
				local minPondZ, maxPondZ = gz, gz

				while #queue > 0 do
					local current = (table.remove(queue, 1) :: GridCoord)

					minPondX = math.min(minPondX, current.x)
					maxPondX = math.max(maxPondX, current.x)
					minPondZ = math.min(minPondZ, current.z)
					maxPondZ = math.max(maxPondZ, current.z)

					-- check cardinal neighbouring blocks
					for dx = -1, 1, 2 do
						local nx, nz = current.x + dx, current.z
						if nx > 0 and nx <= gridSize and not visited[nx][nz] and heights[nx][nz] < waterLevel then
							visited[nx][nz] = true
							table.insert(queue, {x = nx, z = nz})
						end
					end
					for dz = -1, 1, 2 do
						local nx, nz = current.x, current.z + dz
						if nz > 0 and nz <= gridSize and not visited[nx][nz] and heights[nx][nz] < waterLevel then
							visited[nx][nz] = true
							table.insert(queue, {x = nx, z = nz})
						end
					end
				end

				local halfGrid = params.gridSize / 2
				local blockSize = params.blockSize

				local planeSizeX = (maxPondX - minPondX + 1) * blockSize
				local planeSizeZ = (maxPondZ - minPondZ + 1) * blockSize
				local planeHeight = 0.2 * blockSize

				local planePosX = ((minPondX + maxPondX) / 2 - halfGrid) * blockSize
				local planePosZ = ((minPondZ + maxPondZ) / 2 - halfGrid) * blockSize
				local planePosY = (params.waterLevel * blockSize) - (planeHeight / 2)

				Voxel.Create(
					Vector3.new(planePosX, planePosY, planePosZ),
					Vector3.new(planeSizeX, planeHeight, planeSizeZ),
					params.waterColor,
					Enum.Material.Water,
					0.5,
					folders.Water
				)
			end
		end
	end
end


function Water.Generate(params: WorldParameters, folders: Folders, heights: HeightMap)
	if params.fillDepth then
		generateFullDepth(params, folders, heights)
	else
		generatePondSpecificPlanes(params, folders, heights)
	end
end

return Water
