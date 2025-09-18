--!strict

local Types = {}

-- Shared

export type Folders = {
	World: Folder,
	Terrain: Folder,
	Water: Folder,
	Trees: Folder,
	Rocks: Folder,
	Clouds: Folder,
}

export type WorldParameters = {
	seed: number,
	gridSize: number,
	blockSize: number,
	amplitude: number,
	waterLevel: number,
	noiseScale: number,
	noiseOffset: number,
	rockProbability: number,
	flatProbability: number,
	treeProbability: number,
	cloudCount: number,
	fillDepth: boolean,
	greedyMeshing: boolean,
	greedyMeshingPonds: boolean,
	greedyMeshingTrees: boolean,
	grassColor: BrickColor,
	dirtColor: BrickColor,
	sandColor: BrickColor,
	stoneColor: BrickColor,
	waterColor: BrickColor,
	leafColor: BrickColor,
}

export type VoxelVolume = {[number]: {[number]: {[number]: BrickColor?}}}

export type HeightMap = {[number]: {[number]: number}}

export type OccupancyGrid = {[number]: {[number]: boolean}}


function Types.GetDefaultParameters(): WorldParameters
	return {
		seed = os.time(),
		gridSize = 75,
		blockSize = 4,
		amplitude = 20,
		waterLevel = 7,
		noiseScale = 0.1,
		noiseOffset = 0,
		rockProbability = 0.0005,
		flatProbability = 0.1,
		treeProbability = 0.007,
		cloudCount = 10,
		fillDepth = false,
		greedyMeshing = false,
		greedyMeshingPonds = false,
		greedyMeshingTrees = false,
		grassColor = BrickColor.new("Earth green"),
		dirtColor = BrickColor.new("Reddish brown"),
		sandColor = BrickColor.new("Sand yellow"),
		stoneColor = BrickColor.new("Dark stone grey"),
		waterColor = BrickColor.new("Bright blue"),
		leafColor = BrickColor.new("Parsley green"),
	}
end

return Types
