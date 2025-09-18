--!strict

local Types = require(script.Parent.Parent.Types)
type Folders = Types.Folders

local Hierarchy = {}

function Hierarchy.Create(): Folders
	local worldFolder = Instance.new("Folder")
	worldFolder.Name = "World"
	worldFolder.Parent = workspace

	local folders: Folders = {
		World = worldFolder,
		Terrain = Instance.new("Folder", worldFolder),
		Water = Instance.new("Folder", worldFolder),
		Trees = Instance.new("Folder", worldFolder),
		Rocks = Instance.new("Folder", worldFolder),
		Clouds = Instance.new("Folder", worldFolder),
	}

	folders.Terrain.Name = "Terrain"
	folders.Water.Name = "Water"
	folders.Trees.Name = "Trees"
	folders.Rocks.Name = "Rocks"
	folders.Clouds.Name = "Clouds"

	return folders
end

return Hierarchy
