local order = 1
for name, desc in pairs{
	quality = "Levels",
	modules = "Modules",
	technology = "Technologies",
	tips = "Tips & Tricks",
	achievements = "Achievements"} do
	data:extend{{
		type = "bool-setting",
		name = "unquality-" .. name,
		setting_type = "startup",
		order = tostring(order),
		localised_name = "Remove Quality " .. desc,
		default_value = true}}
	order = order + 1 end

data:extend{{
	type = "bool-setting",
	name = "unquality-feature",
	setting_type = "startup",
	order = "6",
	localised_name = "Check that the Quality feature flag is disabled",
	default_value = false}}