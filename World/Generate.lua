local WorldGenerator = require(game.ServerScriptService.World.WorldGenerator)

--[[

	- seed: randomize if you want abstract worlds or keep as is for repeatable environments
	- gridSize: the X, Z grid size the world will be generated into, influenced by blockSize
	- blockSize: the size of each block, affects gridSize[smaller size will result in miniature maps]
	- amplitude: maximum variation for the terrain's height
	- waterLevel: maximum depth of all water bodies
	- noiseScale: frequency of terrain noise[keep low for smoother surfaces, increase for more steep terrain]
	- rockProbability: spawn chance for rocks
	- flatProbability: spawn chance for plateaus across the map, reduce to 0 to avoid any
	- treeProbability: spawn chance for trees
	PS: Odds are per-cell, so tune in accordance to the grid's size if needed
	- cloudCount: the amount of clouds to be spawned
	- fillDepth: must stay false if you aim for performance. When true, it fills the INSIDE of the terrain below water level
	when true, it also disables greedy meshing. Best to keep to false unless you have filtering enabled or every part is modifiable
	- greedyMeshing: whether or not identical parts are merged for maximum performance gain. 
	when coupled with fillDepth, can generate a map with down to 2% of the parts originally required
	- greedyMeshingPonds: merge voxels in ponds[currently only slices on the Z axis, soon enough, more options will be added]
	- greedyMeshingTrees: merge tree voxels in canopies and trunks
	- grassColor, dirtColor, sandColor, stoneColor, waterColor, leafColor: voxel colors

]]


WorldGenerator.Generate({
	seed = 123456,
	gridSize = 200,
	blockSize = 4,
	amplitude = 20,
	waterLevel = 7,
	noiseScale = 0.025,
	rockProbability = 0.0005,
	flatProbability = 0.002,
	treeProbability = 0.007,
	cloudCount = 32,
	fillDepth = false,
	greedyMeshing = true,
	greedyMeshingPonds = true,
	greedyMeshingTrees = true,
	grassColor = BrickColor.new("Black"),
	dirtColor = BrickColor.new("Reddish brown"),
	sandColor = BrickColor.new("Dark orange"),
	stoneColor = BrickColor.new("Really black"),
	waterColor = BrickColor.new("Dark green"),
	leafColor = BrickColor.new("Bright orange")
})
