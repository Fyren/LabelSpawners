return {
	run = function()
		fassert(rawget(_G, "new_mod"), "Label Spawners must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("Label Spawners", {
			mod_script       = "scripts/mods/Label Spawners/Label Spawners",
			mod_data         = "scripts/mods/Label Spawners/Label Spawners_data",
			mod_localization = "scripts/mods/Label Spawners/Label Spawners_localization"
		})
	end,
	packages = {
		"resource_packages/Label Spawners/Label Spawners"
	}
}
