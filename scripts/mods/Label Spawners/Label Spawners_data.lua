local mod = get_mod("Label Spawners")

mod.draw = false

-- Everything here is optional. You can remove unused parts.
return {
	name = "Label Spawners",                               -- Readable mod name
	description = mod:localize("mod_description"),  -- Mod description
	is_togglable = false,                            -- If the mod can be enabled/disabled
	options = {                             -- Widget settings for the mod options menu
		widgets = {
			{
				setting_id = "toggle_show_all",
				type = "keybind",
				title = "Toggle Display All Spawners",
				tooltip = "Toggles displaying all spawners.",
				default_value = {},
				keybind_type = "function_call",
				keybind_trigger = "pressed",
				function_name = "toggle_show_all"
			},
			{
				setting_id = "toggle_show_on_spawn",
				type = "keybind",
				title = "Toggle Display Spawned Enemy on Spawn",
				tooltip = "Toggles displaying the name of a spawned enemy in the place where it spawns when it spawns. Will not work if Display All is on.",
				default_value = {},
				keybind_type = "function_call",
				keybind_trigger = "pressed",
				function_name = "toggle_show_on_spawn"
			},
			{
			  setting_id      = "labels_lifespan",
			  type            = "numeric",
				title 					= "Number of seconds for labels to appear when enemies spawn.",
			  default_value   = 5,
			  range           = {0, 60}
			}
		}
	}
}
