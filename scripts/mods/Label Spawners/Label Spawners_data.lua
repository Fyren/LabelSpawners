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
				setting_id = "toggle_label_spawners",
				type = "keybind",
				title = "Toggle",
				tooltip = "Toggles showing spawners",
				default_value = {},
				keybind_type = "function_call",
				keybind_trigger = "pressed",
				function_name = "toggle"
			}
		}
	}
}
