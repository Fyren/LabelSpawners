local mod = get_mod("Label Spawners")
local ConflictDirector = ConflictDirector

mod.spawners = {}
mod.gui = nil
mod.font = nil
mod.font_size = nil

function mod.toggle_show_all()
	mod.draw_all = not mod.draw_all
	if mod.draw_all then
		 mod:echo("[LABEL SPAWNER] Enabling display all spawners")
		 mod:_get_spawners()
	 else
		 mod:echo("[LABEL SPAWNER] Disabling display all spawners")
		 mod.spawners = {}
	 end
end

function mod.toggle_show_on_spawn()
	if mod.draw_all then
		mod:echo("[LABEL SPAWNER] Draw on spawn does not work while displaying all spawners")
		return
	end
	mod.draw_on_spawn = not mod.draw_on_spawn
	mod:_hook_to_spawner()

end

function mod._get_spawners(self)
	local spawner_system = Managers.state.entity:system("spawner_system")
	if not spawner_system then return end
	mod.spawners = {}
	for k, v in pairs(spawner_system._raw_id_lookup) do
		local pos = Unit.world_position(spawner_system:get_raw_spawner_unit(k), 0)
		mod.spawners[k] = { pos[1], pos[2], pos[3], k, nil}
	end
end

function mod._hook_to_spawner()
	if mod.draw_on_spawn then
		mod:echo("[LABEL SPAWNER] Enabling draw on spawn")
		mod:hook_enable(ConflictDirector, "spawn_at_raw_spawner")
	else
		mod:echo("[LABEL SPAWNER] Disabling draw on spawn")
		mod:hook_disable(ConflictDirector, "spawn_at_raw_spawner")
	end
end

function mod.spawn_at_raw_spawner_hook(self, breed, spawner_id)
	if mod.draw_all then return end

	local spawner_system = Managers.state.entity:system("spawner_system")
	if not spawner_system then return end

	local spawn_time = mod:get_time()
	local pos = Unit.world_position(spawner_system:get_raw_spawner_unit(spawner_id), 0)

	if mod.spawners == nil then
		mod.spawners = {}
	end
	mod.spawners[spawner_id] = { pos[1], pos[2], pos[3], breed.name, spawn_time}
end

function mod.draw_text_on_spawner(self, spawner, p)
	if not mod.gui and Managers.world:world("top_ingame_view") then
		mod:create_gui()
	end
	if not mod.gui then return end

	local world = Managers.world:world("level_world")
	local viewport = ScriptWorld.viewport(world, "player_1")
	local camera = ScriptViewport.camera(viewport)

	local position = Vector3(p[1], p[2], p[3])
	local camera_pos = Camera.world_position(camera)
	local cam_to_unit_dir = Vector3.normalize(position - camera_pos)
	local cam_dir = Quaternion.forward(Camera.world_rotation(camera))
	local forward_dot = Vector3.dot(cam_dir, cam_to_unit_dir)
	local infront = forward_dot >= 0 and forward_dot <= 1

	if infront and spawner ~= "boss_spawn" then
		local position2d, depth = Camera.world_to_screen(camera, position)
		local camera_distance_to_spawner = Vector3.distance(position, camera_pos)
		local font_size = 36 * (1 / (camera_distance_to_spawner / 20))
		local text = p[4]
		local alpha = mod:calculate_alpha(p[5])
		Gui.text(self.gui, text, self.font[1], font_size, self.font[3], Vector2(position2d[1], position2d[2]), Color(alpha, 255, 255, 255))
--			mod:info("Drawing " .. sp .. " world: " .. "(" .. position[1] .. ", " .. position[2] .. ", " .. position[3] .. ") / screen (" .. position2d[1] .. ", " .. position2d[2] .. ") " .. depth)
	end
end

function mod.calculate_alpha(self, spawn_time)
	if spawn_time == nil then
		return 255
	end
	local current_time = mod:get_time()
	local time_alive = current_time - spawn_time
	local percentage_of_life_lived = time_alive / mod:get("labels_lifespan")
	return 255 * (1 - percentage_of_life_lived)
end

function mod.remove_dead_labels(self, spawner, p)
	if p[5] == nil then return end

	local current_time = mod:get_time()
	local spawn_time = p[5]
	if current_time - spawn_time > mod:get("labels_lifespan") then
		self.spawners[spawner] = nil
	end
end

function mod.get_time()
	return Managers.time and Managers.time:time("game") or 0
end

function mod.handle_tspawn(spawner)
	local conflict_director = Managers.state.conflict
	if not conflict_director then return end
	conflict_director:spawn_at_raw_spawner(Breeds["critter_pig"], spawner, nil)
end

mod.create_gui = function(self)
	local top_world = Managers.world:world("top_ingame_view")
	self.gui = World.create_screen_gui(Managers.world:world("top_ingame_view"), "material", "materials/fonts/gw_fonts", "immediate")

	local _FONT_TYPE = "hell_shark_arial"
	local _FONT_SIZE = 36
  self.font, self.font_size = UIFontByResolution({font_type = _FONT_TYPE, font_size = _FONT_SIZE})
end

mod.destroy_gui = function(self)
	World.destroy_gui(Managers.world:world("top_ingame_view"), self.gui)
	self.gui = nil
end

mod:command("tspawn", "test label spawner", mod.handle_tspawn)
mod:hook_safe(ConflictDirector, "spawn_at_raw_spawner", mod.spawn_at_raw_spawner_hook)
mod:hook_disable(ConflictDirector, "spawn_at_raw_spawner")

-- All callbacks are called even when the mod is disabled
-- Use mod:is_enabled() to check that the mod is enabled
-- Called on every update to mods
-- dt - time in milliseconds since last update
mod.update = function(dt)
	if (not mod.draw_all) and (not mod.draw_on_spawn) then return end

	for sp, p in pairs(mod.spawners) do
		mod:draw_text_on_spawner(sp, p)
		mod:remove_dead_labels(sp, p)
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
	if mod.gui and Managers.world:world("top_ingame_view") then
		mod:destroy_gui()
	end
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
