--!strict
--!native
--!optimize 2

local Types = require(script.Parent.Parent.Types)
local Voxel = require(script.Parent.Parent.Utility.Voxel)
local GreedyMesher = require(script.Parent.Parent.Utility.GreedyMesher)

type WorldParameters = Types.WorldParameters
type Folders = Types.Folders
type HeightMap = Types.HeightMap
type VoxelVolume = Types.VoxelVolume

local Terrain = {}

--[[

	- Checks at the 3x3 grid of the blocks around (gx, gz)
	- Samples the noise at each of them and returns the average to smooth the result

]]
local function getSmoothedNoise(gx: number, gz: number, noiseScale: number, noiseOffset: number): number
	local total = 0
	for dx = -1, 1 do
		for dz = -1, 1 do
			--[[
			
			- (gx + dx + noiseOffset) * noiseScale maps the grid's coordinates
			- offset to eliminate duplicates
			
			]]
			total += math.noise((gx + dx + noiseOffset) * noiseScale, (gz + dz + noiseOffset) * noiseScale)
		end
	end
	return total / 9
end


--[[

	- Fetches a smooth noise for each (gx, gz) cell
	- Normalizes said noise between 0-1 and multiplies by the amplitude we defined
	- Based on flatProbabilit, generates plateaus
	- Returns the mapped table

]]
local function generateHeightMap(params: WorldParameters): HeightMap
	local heights: HeightMap = {}
	for gx = 1, params.gridSize do
		heights[gx] = {}
		for gz = 1, params.gridSize do
			local n = getSmoothedNoise(gx, gz, params.noiseScale, params.noiseOffset)
			local normalized = (n + 1) / 2 -- non-negative
			local height = math.floor(normalized * params.amplitude)
			if height < 1 then height = 1 end
			if math.random() < params.flatProbability then
				height = params.waterLevel + math.random(2, 4)
			end
			heights[gx][gz] = height
		end
	end
	return heights
end


--[[

	- Fills all blocks from y = 1 up to the height
	- Based on height and inner/outer layer, applies grass/stone/sand colors
	
]]
local function generateFullDepth(params: WorldParameters, folders: Folders, heights: HeightMap)
	local halfGrid = params.gridSize / 2
	for gx = 1, params.gridSize do
		for gz = 1, params.gridSize do
			-- to center around (0, 0)
			local worldX = (gx - halfGrid) * params.blockSize
			local worldZ = (gz - halfGrid) * params.blockSize
			
			local height = heights[gx][gz]

			for y = 1, height do
				local worldY = (y - 0.5) * params.blockSize -- offset by size/2 to make all blocks stack evenly
				local color: BrickColor
				if y == height then
					if height <= params.waterLevel + 1 then color = params.sandColor
					elseif height <= params.waterLevel + 6 then color = params.grassColor
					else color = params.stoneColor
					end
				else
					color = params.dirtColor -- default
				end
				Voxel.Create(
					Vector3.new(worldX, worldY, worldZ),
					Vector3.new(params.blockSize, params.blockSize, params.blockSize),
					color,
					Enum.Material.SmoothPlastic,
					nil,
					folders.Terrain
				)
			end
		end
	end
end


--[[

	- Determines max height
	- Ignores hidden voxels outside the surface, not visible to anyone
	- Assigns colors based on height
	- If toggled, uses greedy meshing[as defined in Generate, won't work if fillDepth is enabled]

]]
local function generateSurface(params: WorldParameters, folders: Folders, heights: HeightMap)
	local maxHeight = 0
	for gx = 1, params.gridSize do
		for gz = 1, params.gridSize do
			if heights[gx][gz] > maxHeight then
				maxHeight = heights[gx][gz]
			end
		end
	end

	local volume: VoxelVolume = {}
	for x = 1, params.gridSize do
		volume[x] = {}
		for y = 1, maxHeight do
			volume[x][y] = {}
			for z = 1, params.gridSize do
				local h = heights[x][z]
				if y <= h then
					local isVisible = (y == 1) or (y == h) -- surface or bottom layer
					if not isVisible then
						-- dx = -1 | 1 to look left or right in various x+dx at the same z
						for dx = -1, 1, 2 do
							local nheight = heights[x+dx] and heights[x+dx][z] or 0
							if y > nheight then isVisible = true; break end
						end
						if not isVisible then
							-- dz = -1 | 1 to look front or back in various z+dz at the same x
							for dz = -1, 1, 2 do
								local nheight = heights[x][z+dz] or 0
								if y > nheight then isVisible = true; break end
							end
						end
					end

					if isVisible then
						local col: BrickColor
						if y == h then
							if h <= params.waterLevel + 1 then col = params.sandColor
							elseif h <= params.waterLevel + 6 then col = params.grassColor
							else col = params.stoneColor
							end
						else
							col = params.dirtColor -- >> >>
						end
						volume[x][y][z] = col
					end
				end
			end
		end
	end

	-- center terrain at (0, 0, 0)
	local halfGrid = params.gridSize / 2
	local terrainOffset = Vector3.new(
		(-halfGrid + 0.5) * params.blockSize,
		params.blockSize / 2,
		(-halfGrid + 0.5) * params.blockSize
	)

	if params.greedyMeshing then
		GreedyMesher.MeshVolume(volume, params.gridSize, maxHeight, params.gridSize, folders.Terrain, terrainOffset, params.blockSize, Enum.Material.SmoothPlastic, nil)
	else
		-- fallback
		for x = 1, params.gridSize do
			for y = 1, maxHeight do
				for z = 1, params.gridSize do
					if volume[x][y][z] then
						local worldPos = Vector3.new(
							terrainOffset.X + (x - 1) * params.blockSize,
							terrainOffset.Y + (y - 1) * params.blockSize,
							terrainOffset.Z + (z - 1) * params.blockSize
						)
						Voxel.Create(worldPos, Vector3.one * params.blockSize, volume[x][y][z] :: BrickColor, Enum.Material.SmoothPlastic, nil, folders.Terrain)
					end
				end
			end
		end
	end
end

function Terrain.Generate(params: WorldParameters, folders: Folders): HeightMap
	local heights = generateHeightMap(params)

	if params.fillDepth then
		generateFullDepth(params, folders, heights)
	else
		generateSurface(params, folders, heights)
	end

	return heights
end

return Terrain
