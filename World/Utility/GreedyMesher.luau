--!strict
--!native

local Voxel = require(script.Parent.Voxel)
local Types = require(script.Parent.Parent.Types)

type VoxelVolume = Types.VoxelVolume

local GreedyMesher = {}

function GreedyMesher.MeshVolume(
	volume: VoxelVolume,
	sizeX: number,
	sizeY: number,
	sizeZ: number,
	parent: Instance,
	offset: Vector3,
	blockSize: number,
	material: Enum.Material,
	transparency: number?
)
	local visited: {[number]: {[number]: {[number]: boolean}}} = {}
	for x = 1, sizeX do
		visited[x] = {}
		for y = 1, sizeY do
			visited[x][y] = {}
		end
	end

	for x = 1, sizeX do
		for y = 1, sizeY do
			for z = 1, sizeZ do
				if not visited[x][y][z] and volume[x] and volume[x][y] and volume[x][y][z] then
					local color = volume[x][y][z] :: BrickColor

					--[[
					
					Expand X: maximal 'stretch' along the X axis for unvisited cells with the same color
					w ∈ Ν, stops if out of bounds or color mismatch or visited already
					
					]]
					local w = 1
					while x + w <= sizeX and not visited[x + w][y][z] and volume[x + w] and volume[x + w][y] and volume[x + w][y][z] == color do
						w += 1
					end

					-- Expand Y: for current 'stretch' [x, x+w-1], extend upward
					local h = 1
					local yDone = false
					while y + h <= sizeY and not yDone do
						for xi = x, x + w - 1 do
							-- if any column in the X-stretch is already visited or has a different color, stop
							if visited[xi][y + h][z] or not (volume[xi] and volume[xi][y + h] and volume[xi][y + h][z] == color) then
								yDone = true
								break
							end
						end
						if not yDone then h += 1 end
					end

					--[[
					
					Expand Z: for current rectangle [x, x+w-1]*[y, y+h-1], extend along Z
					-- d ∈ N, stops if any voxel along the rectangle is visited or has a different color

					]]
					local d = 1
					local zDone = false
					while z + d <= sizeZ and not zDone do
						for xi = x, x + w - 1 do
							for yi = y, y + h - 1 do
								-- check all the voxels in the XY rectangle at Z layer
								if visited[xi][yi][z + d] or not (volume[xi] and volume[xi][yi] and volume[xi][yi][z + d] == color) then
									zDone = true
									break
								end
							end
							if zDone then break end
						end
						if not zDone then d += 1 end
					end

					-- Mark visited and create part
					for xi = x, x + w - 1 do
						for yi = y, y + h - 1 do
							for zi = z, z + d - 1 do
								visited[xi][yi][zi] = true
							end
						end
					end

					local partSize = Vector3.new(w * blockSize, h * blockSize, d * blockSize)
					local partPos = Vector3.new(
						offset.X + ((x - 1) + w / 2) * blockSize,
						offset.Y + ((y - 1) + h / 2) * blockSize,
						offset.Z + ((z - 1) + d / 2) * blockSize
					)

					Voxel.Create(partPos, partSize, color, material, transparency, parent)
				end
			end
		end
	end
end

return GreedyMesher
