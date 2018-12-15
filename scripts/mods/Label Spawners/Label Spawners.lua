local mod = get_mod("Label Spawners")

mod.spawners = {}
function mod.toggle()
	mod.draw = not mod.draw;
	if mod.draw then mod:info("Enabled") else mod:info("Disabled") end

	mod.spawners = {}
	local spawner_system = Managers.state.entity:system("spawner_system")
	for k, v in pairs(spawner_system._raw_id_lookup) do 
		local pos = Unit.world_position(spawner_system:get_raw_spawner_unit(k), 0)
		mod.spawners[k] = { pos[1], pos[2], pos[3] }
	end
end

--[===[

--[[
	Hooks
--]]

-- If you simply want to call a function after SomeObject.some_function has been executed
-- Arguments for SomeObject.some_function will be passed to my_function as well
mod:hook_safe(SomeObject, "some_function", my_function)

-- If you want to do something more involved
mod:hook(SomeObject, "some_function", function (func, ...)

	-- Your code here

	-- Don't forget to call the original function
	-- If you're not planning to call it, use mod:hook_origin instead
	local result1, result2, etc = func(...)    

	-- Your code here
	
	-- Don't forget to return the return values
	return result1, result2, etc 
end)
---]===]


--[[
	Callbacks
--]]

mod.gui = nil
mod.font = nil
mod.font_size = nil
mod.create_gui = function(self)
	local top_world = Managers.world:world("top_ingame_view")
	self.gui = World.create_screen_gui(Managers.world:world("top_ingame_view"), "material", "materials/fonts/gw_fonts", "immediate")

	local _FONT_TYPE = "hell_shark_arial"
	local _FONT_SIZE = 22
    self.font, self.font_size = UIFontByResolution({font_type = _FONT_TYPE, font_size = _FONT_SIZE})
end
mod.destroy_gui = function(self)
	World.destroy_gui(Managers.world:world("top_ingame_view"), self.gui)
	self.gui = nil
end


-- All callbacks are called even when the mod is disabled
-- Use mod:is_enabled() to check that the mod is enabled
-- Called on every update to mods
-- dt - time in milliseconds since last update
mod.update = function(dt)
	if (not mod.draw) then return end

	if not mod.gui and Managers.world:world("top_ingame_view") then
		mod:create_gui()
	end

	if not mod.gui then return end

	local world = Managers.world:world("level_world")
	local viewport = ScriptWorld.viewport(world, "player_1")
	local camera = ScriptViewport.camera(viewport)

	local spawner_system = Managers.state.entity:system("spawner_system")
	local keys = ""
	mod:info("update")
	for sp, p in pairs(mod.spawners) do 
		local position = Vector3(p[1], p[2], p[3])
		local camera_pos = Camera.world_position(camera)
		local cam_to_unit_dir = Vector3.normalize(position - camera_pos)
		local cam_dir = Quaternion.forward(Camera.world_rotation(camera))
		local forward_dot = Vector3.dot(cam_dir, cam_to_unit_dir)
		local infront = forward_dot >= 0 and forward_dot <= 1

		if infront and sp ~= "boss_spawn" then
			local position2d, depth = Camera.world_to_screen(camera, position)
			Gui.text(mod.gui, sp, mod.font[1], mod.font_size, mod.font[3], Vector2(position2d[1], position2d[2]), Color(255, 255, 255, 255))
--			mod:info("Drawing " .. sp .. " world: " .. "(" .. position[1] .. ", " .. position[2] .. ", " .. position[3] .. ") / screen (" .. position2d[1] .. ", " .. position2d[2] .. ") " .. depth)
		end
	end
end

-- Called when all mods are being unloaded
-- exit_game - if true, game will close after unloading
mod.on_unload = function(exit_game)
	if mod.gui and Managers.world:world("top_ingame_view") then
		mod:destroy_gui()
	end	
end

-- Called when game state changes (e.g. StateLoading -> StateIngame)
-- status - "enter" or "exit"
-- state  - "StateLoading", "StateIngame" etc.
mod.on_game_state_changed = function(status, state)
	
end

-- Called when a setting is changed in mod settings
-- Use mod:get(setting_name) to get the changed value
mod.on_setting_changed = function(setting_name)
	
end

-- Called when the checkbox for this mod is unchecked
-- is_first_call - true if called right after mod initialization
mod.on_disabled = function(is_first_call)

end

-- Called when the checkbox for this is checked
-- is_first_call - true if called right after mod initialization
mod.on_enabled = function(is_first_call)

end
