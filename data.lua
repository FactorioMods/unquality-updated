function setting(name)
	return settings.startup["unquality-" .. name].value end

if setting("feature") and feature_flags["quality"] then
		error([[
The quality feature flag was enabled!
(Make sure to remove the "quality_required": true, line from data/quality/info.json, data/space-age/info.json, and any other mod's info.json) ]]) end

if not feature_flags["quality"] then
	settings.startup["unquality-quality"].value = true end -- Must delete the quality levels, or the game won't load!

local function delete(kind, ...) -- deletes prototypes of the given type
	for _, name in pairs{...} do
		data.raw[kind][name] = nil end end

local util = require("util")
local function substitute_simulation(kind, name, ...)
	local simulation = data.raw[kind][name].simulation
	for _, sub in pairs{...} do
		simulation.init = util.string_replace(simulation.init, sub[1], sub[2]) end end

local quality_sub = {}
for _, quality in pairs{"uncommon", "rare", "epic", "legendary"} do
	table.insert(quality_sub, {quality, "normal"}) end
local function remove_simulation_quality(kind, ...)
	for _, name in pairs{...} do
		substitute_simulation(kind, name, unpack(quality_sub)) end end
local function change_description(kind, name)
	data.raw[kind][name].localised_description = { kind .. "-description.unquality-" .. name } end
if setting("quality") then
	-- Revert changes made by __core__.prototypes.utility-sprites
	data.raw.sprite["quality_info"].scale = 0 -- Make it invisible

	-- Revert changes made by __base__.prototypes.categories.quality
	data.raw.quality.normal.icons = {{icon = data.raw.quality.normal.icon, scale = 0}} -- Make the icon invisible if it ever has reason to show up (e.g. when hovering over the quality_info diamond)

	-- Revert changes made by __quality__.data-updates
	data.raw.quality.normal.hidden = true
	
	-- Revert changes made by __quality__.prototypes.base-data-updates
	data.raw.quality.normal.next = nil

	-- Revert changes made by __quality__.prototypes.quality
	delete("quality", "uncommon", "rare", "epic", "legendary")

	-- Revert changes made by __quality__.prototypes.signal
	delete("virtual-signal", "signal-any-quality")

	if mods["space-age"] then
		-- Revert changes made by __space-age__.prototypes.tips-and-tricks-simulations
		remove_simulation_quality("tips-and-tricks-item", "orbital-logistics") end end

if setting("modules") then
	-- Revert changes made by __quality__.prototypes.item
	delete("module", "quality-module", "quality-module-2", "quality-module-3")

	-- Revert changes made by __quality__.prototypes.module-category
	delete("module-category", "quality") 

	-- Revert changes made by __quality__.prototypes.recipe
	delete("recipe", "quality-module", "quality-module-2", "quality-module-3")

	-- Revert changes made by __quality__.data-updates
	delete("recipe", "quality-module-recycling", "quality-module-2-recycling", "quality-module-3-recycling") end

if setting("technology") then
	-- Revert changes made by __quality__.prototypes.base-data-updates
	data.raw.technology["modules"].icon = "__base__/graphics/technology/module.png" 

	-- Revert changes made by __quality__.prototypes.technology
	delete("technology", "quality-module", "quality-module-2", "quality-module-3", "epic-quality", "legendary-quality")
else
	-- Revert changes made by the effects of the technologies that are problematic
	local quality_module = data.raw.technology["quality-module"]
	if setting("modules") then
		quality_module.effects = {quality_module.effects[2], quality_module.effects[3]} -- remove first element
		data.raw.technology["quality-module-2"].effects = {}
		data.raw.technology["quality-module-3"].effects = {} end

	if setting("quality") then
		-- Little bit tricky, as the original quality_module.effects[1] may or may not have been deleted above
		quality_module.effects[#quality_module.effects] = nil --Remove last element, which unlocks rare
		quality_module.effects[#quality_module.effects] = nil --Remove new last element, which unlocks uncommon
		data.raw.technology["epic-quality"].effects = {} 
		data.raw.technology["legendary-quality"].effects = {} end end

if setting("tips") then
	-- Revert changes made by __quality__.prototypes.tips-and-tricks
	delete("tips-and-tricks-item-category", "quality")
	delete("tips-and-tricks-item", "quality", "quality-factoriopedia", "quality-modules", "quality-probabilities")
else
	if setting("modules") then
		data.raw["tips-and-tricks-item"]["quality"].trigger = nil -- as it depends on the quality-module recipe
		data.raw["tips-and-tricks-item"]["quality-modules"].skip_trigger = nil -- as it depends on the quality-module item
		data.raw["tips-and-tricks-item"]["quality-modules"].tag = nil -- was "[item=quality-module]"
		change_description("tips-and-tricks-item", "quality-modules")

		data.raw["tips-and-tricks-item"]["quality-probabilities"].tag = nil -- was "[item=quality-module][item=quality-module-3]"
		change_description("tips-and-tricks-item", "quality-probabilities")
		substitute_simulation("tips-and-tricks-item", "quality-probabilities", 
			{'prototypes.item["quality-module-3"].module_effects["quality"]', "0"},
			{'string.rep("[item=quality-module-3]", 4)', '""'})  end
	if setting("quality") then
		data.raw["tips-and-tricks-item"]["quality"].skip_trigger = nil  -- as it depends on the uncommon quality
		if mods["space-age"] then
			change_description("tips-and-tricks-item", "spoilables") end
		remove_simulation_quality("tips-and-tricks-item", "quality", "quality-modules") end end

if setting("achievements") and mods["space-age"] then
	-- Revert changes made by __space-age__.prototypes.achievements
	delete("produce-achievement", "crafting-with-quality", "my-modules-are-legendary")
	delete("module-transfer-achievement", "make-it-better")
	delete("use-item-achievement", "todays-fish-is-trout-a-la-creme")
	delete("equip-armor-achievement", "look-at-my-shiny-rare-armor")
	delete("place-equipment-achievement", "no-room-for-more") 
elseif mods["space-age"] then
	if setting("modules") then
		data.raw["produce-achievement"]["crafting-with-quality"].item_product = "productivity-module-3" -- was quality-module-3
		data.raw["produce-achievement"]["my-modules-are-legendary"].item_product.name = "productivity-module-3" -- was quality-module-3
		data.raw["module-transfer-achievement"]["make-it-better"].module = {"productivity-module", "productivity-module-2", "productivity-module-3"} end -- were quality-modules
	if setting("quality") then
		data.raw["produce-achievement"]["my-modules-are-legendary"].item_product.quality = nil -- Was "legendary"
		data.raw["equip-armor-achievement"]["look-at-my-shiny-rare-armor"].limit_quality = "normal" -- Was "rare"
		data.raw["use-item-achievement"]["todays-fish-is-trout-a-la-creme"].limit_quality = "normal" -- Was "legendary"
		data.raw["place-equipment-achievement"]["no-room-for-more"].limit_quality = "normal" -- Was "legendary"
		data.raw["place-equipment-achievement"]["no-room-for-more"].limit_equip_quality = "normal" end end -- Was "legendary"