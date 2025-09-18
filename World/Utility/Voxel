--!strict

-- Encapsulates cluster generation & keeps track of the part count

local Voxel = {}

local totalBlocksGenerated: number = 0

function Voxel.Create(
	position: Vector3,
	size: Vector3,
	color: BrickColor,
	material: Enum.Material,
	transparency: number?,
	parent: Instance
): Part
	local part = Instance.new("Part")
	part.Size = size
	part.Anchored = true
	part.Position = position
	part.BrickColor = color
	part.Material = material
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.CastShadow = false
	if transparency then
		part.Transparency = transparency
	end
	part.Parent = parent

	totalBlocksGenerated += 1
	return part
end

function Voxel.GetTotalCount(): number
	return totalBlocksGenerated
end

function Voxel.ResetCount()
	totalBlocksGenerated = 0
end

return Voxel
