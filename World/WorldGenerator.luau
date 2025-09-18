--!strict

--[[

The main orchestratos, initiates with defaults or overrides with customs if provided

- Preps the seed RNG
- Creates the folders for each feature
- Generates terrain, height and then water
- Decorates with clusters, trees and clouds

]]

local Types = require(script.Parent.Types)
local Hierarchy = require(script.Parent.Modules.Hierarchy)
local Terrain = require(script.Parent.Modules.Terrain)
local Water = require(script.Parent.Modules.Water)
local Features = require(script.Parent.Modules.Features)
local Voxel = require(script.Parent.Utility.Voxel)

type WorldParameters = Types.WorldParameters

local WorldGenerator = {}

function WorldGenerator.Generate(user_Params: {string: any}?)
	local params: WorldParameters = Types.GetDefaultParameters()
	if user_Params then
		for key, value in pairs(user_Params :: any) do
			(params :: any)[key] = value
		end
	end

	math.randomseed(params.seed)
	params.noiseOffset = params.seed / 1000
	Voxel.ResetCount()

	local folders = Hierarchy.Create()

	local heightMap = Terrain.Generate(params, folders)
	Water.Generate(params, folders, heightMap)

	Features.GenerateTreesAndRocks(params, folders, heightMap)
	Features.GenerateClouds(params, folders)

	print(`World generation complete. Seed used: {params.seed}`)
	print(`Total blocks generated: {Voxel.GetTotalCount()}`)
end

return WorldGenerator
