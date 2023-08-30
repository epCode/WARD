

-- List of sound handles for active forge
local forge_fire_sounds = {}

--
-- Formspecs
--

function ward.get_forge_active_formspec(fuel_percent, item_percent)
	return "size[8,8.5]"..
		"background[-0.7,-0.25;9.41,9.49;ward_forge_bg.png]"..
		"list[context;src;2.75,0.5;1,1;]"..
		"list[context;src2;1.2,0.5;1,1;]"..
		"list[context;fuel;2.75,2.5;1,1;]"..
		"image[2.75,1.5;1,1;ward_forge_fire_bg.png^[lowpart:"..
		(fuel_percent)..":ward_forge_fire_fg.png]"..
		"image[3.75,1.5;1,1;gui_forge_arrow_bg.png^[lowpart:"..
		(item_percent)..":gui_forge_arrow_fg.png^[transformR270]"..
		"list[context;dst;4.75,0.96;2,2;]"..
		"list[current_player;main;0,4.25;8,1;]"..
		"list[current_player;main;0,5.5;8,3;8]"..
		"listring[context;dst]"..
		"listring[current_player;main]"..
		"listring[context;src]"..
		"listring[context;src2]"..
		"listring[current_player;main]"..
		"listring[context;fuel]"..
		"listring[current_player;main]"
end

function ward.get_forge_inactive_formspec()
	return "size[8,8.5]"..
		"background[-0.7,-0.25;9.41,9.49;ward_forge_bg.png]"..
		"list[context;src;2.75,0.5;1,1;]"..
		"list[context;src2;1.2,0.5;1,1;]"..
		"list[context;fuel;2.75,2.5;1,1;]"..
		"image[2.75,1.5;1,1;ward_forge_fire_bg.png]"..
		"image[3.75,1.5;1,1;gui_forge_arrow_bg.png^[transformR270]"..
		"list[context;dst;4.75,0.96;2,2;]"..
		"list[current_player;main;0,4.25;8,1;]"..
		"list[current_player;main;0,5.5;8,3;8]"..
		"listring[context;dst]"..
		"listring[current_player;main]"..
		"listring[context;src]"..
		"listring[context;src2]"..
		"listring[current_player;main]"..
		"listring[context;fuel]"..
		"listring[current_player;main]"
		--ward.get_hotbar_bg(0, 4.25)
end

--
-- Node callback functions that are the same for active and inactive forge
--

local function can_dig(pos, player)
	local meta = minetest.get_meta(pos);
	local inv = meta:get_inventory()
	return inv:is_empty("fuel") and inv:is_empty("dst") and inv:is_empty("src") and inv:is_empty("src2")
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	if listname == "fuel" then
		if minetest.get_craft_result({method="fuel", width=1, items={stack}}).time ~= 0 then
			if inv:is_empty("src") and inv:is_empty("src2") then
				meta:set_string("infotext", "Forge is empty")
			end
			return stack:get_count()
		else
			return 0
		end
	elseif listname == "src" or listname == "src2" then
		return stack:get_count()
	elseif listname == "dst" then
		return 0
	end
end

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local stack = inv:get_stack(from_list, from_index)
	return allow_metadata_inventory_put(pos, to_list, to_index, stack, player)
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	return stack:get_count()
end

local function stop_forge_sound(pos, fadeout_step)
	local hash = minetest.hash_node_position(pos)
	local sound_ids = forge_fire_sounds[hash]
	if sound_ids then
		for _, sound_id in ipairs(sound_ids) do
			minetest.sound_fade(sound_id, -1, 0)
		end
		forge_fire_sounds[hash] = nil
	end
end

local function swap_node(pos, name)
	local node = minetest.get_node(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
end

local function detect_double_heat(pos, meta)
	local upnode = minetest.get_node(vector.add(pos, vector.new(0,1,0)))
	if upnode and upnode.name == ward.items.lava.name then
		meta:set_string("double_heat", minetest.serialize(true))
	else
		meta:set_string("double_heat", "")
	end
end

local function forge_node_timer(pos, elapsed)
	--
	-- Initialize metadata
	--
	local meta = minetest.get_meta(pos)
	local fuel_time = meta:get_float("fuel_time") or 0
	local src_time = meta:get_float("src_time") or 0
	local fuel_totaltime = meta:get_float("fuel_totaltime") or 0

	local inv = meta:get_inventory()
	local srclist, fuellist
	local dst_full = false




	local timer_elapsed = meta:get_int("timer_elapsed") or 0
	meta:set_int("timer_elapsed", timer_elapsed + 1)

	local cookable, cooked
	local fuel

	local update = true
	while elapsed > 0 and update do
		update = false

		srclist = {inv:get_list("src"), inv:get_list("src2")}
		fuellist = inv:get_list("fuel")

		--
		-- Cooking
		--

		-- Check if we have cookable content
    local itemsnames = {  srclist[1][1]:get_name(), srclist[2][1]:get_name(),  }
    cooked = ward.get_forge_result({items = itemsnames})
		cookable = cooked.time ~= 0

		doubleheat = minetest.deserialize(meta:get_string("double_heat"))
		if cooked.double_heat and not doubleheat then
			cookable = false
		end

		local el = math.min(elapsed, fuel_totaltime - fuel_time)
		if cookable then -- fuel lasts long enough, adjust el to cooking duration
			el = math.min(el, cooked.time - src_time)
		end

		-- Check if we have enough fuel to burn
		if fuel_time < fuel_totaltime then
			local dest = inv:get_list("dst")
			for _i,v in ipairs(dest) do
				if not v:is_empty() then
					if (minetest.get_item_group(v:get_name(), "ward_burning") ~= 0 or minetest.get_item_group(v:get_name(), "ward_burntable") ~= 0) and math.random(4) == 1 then
						v:set_name(string.sub(v:get_name(), 1, -9).."_burnt")
						inv:set_stack("dst", _i, v)
					end
					if minetest.get_item_group(v:get_name(), "ward_burnable") ~= 0 and math.random(4) == 1 then
						v:set_name(v:get_name().."_burning")
						inv:set_stack("dst", _i, v)
					end
				end
			end
			-- The forge is currently active and has enough fuel
			fuel_time = fuel_time + el
			-- If there is a cookable item then check if it is ready yet
			if cookable then
				src_time = src_time + el
				if src_time >= cooked.time then
					-- Place result in dst list if possible
					if inv:room_for_item("dst", cooked.item) then

						srclist[1][1]:take_item()
						srclist[2][1]:take_item()

						inv:add_item("dst", cooked.item)
						inv:set_stack("src", 1, srclist[1][1])
						inv:set_stack("src2", 1, srclist[2][1])
						src_time = src_time - cooked.time
						update = true
					else
						dst_full = true
					end
				else
					-- Item could not be cooked: probably missing fuel
					update = true
				end
			end
		else
			-- Forge ran out of fuel
			if cookable then
				-- We need to get new fuel
				local afterfuel
				fuel, afterfuel = minetest.get_craft_result({method = "fuel", width = 1, items = fuellist})

				if fuel.time == 0 then
					-- No valid fuel in fuel list
					fuel_totaltime = 0
					src_time = 0
				else
					-- prevent blocking of fuel inventory (for automatization mods)
					local is_fuel = minetest.get_craft_result({method = "fuel", width = 1, items = {afterfuel.items[1]:to_string()}})
					if is_fuel.time == 0 then
						table.insert(fuel.replacements, afterfuel.items[1])
						inv:set_stack("fuel", 1, "")
					else
						-- Take fuel from fuel list
						inv:set_stack("fuel", 1, afterfuel.items[1])
					end
					-- Put replacements in dst list or drop them on the forge.
					local replacements = fuel.replacements
					if replacements[1] then
						local leftover = inv:add_item("dst", replacements[1])
						if not leftover:is_empty() then
							local above = vector.new(pos.x, pos.y + 1, pos.z)
							local drop_pos = minetest.find_node_near(above, 1, {"air"}) or above
							minetest.item_drop(replacements[1], nil, drop_pos)
						end
					end
					update = true
					fuel_totaltime = fuel.time + (fuel_totaltime - fuel_time)
				end
			else
				-- We don't need to get new fuel since there is no cookable item
				fuel_totaltime = 0
				src_time = 0
			end
			fuel_time = 0
		end

		elapsed = elapsed - el
	end

	if fuel and fuel_totaltime > fuel.time then
		fuel_totaltime = fuel.time
	end
	if srclist and (srclist[1][1]:is_empty() and srclist[2][1]:is_empty()) then
		src_time = 0
	end

	--
	-- Update formspec, infotext and node
	--
	local formspec
	local item_state
	local item_percent = 0
	if cookable then
		item_percent = math.floor(src_time / cooked.time * 100)
		if dst_full then
			item_state = "100% (output full)"
		else
			item_state = "1%", item_percent
		end
	else
		if srclist and (not srclist[1][1]:is_empty() and not srclist[2][1]:is_empty()) then
			item_state = "Not cookable"
		else
			item_state = "Empty"
		end
	end

	local fuel_state = "Empty"
	local active = false
	local result = false

	if fuel_totaltime ~= 0 then
		active = true
		local fuel_percent = 100 - math.floor(fuel_time / fuel_totaltime * 100)
		fuel_state = "1%", fuel_percent
		formspec = ward.get_forge_active_formspec(fuel_percent, item_percent)

		-- make sure timer restarts automatically
		result = true

		-- Play sound every 5 seconds while the forge is active
		if timer_elapsed == 0 or (timer_elapsed + 1) % 5 == 0 then
			local sound_id = minetest.sound_play("ward_forge_active",
				{pos = pos, max_hear_distance = 16, gain = 0.25})
			local hash = minetest.hash_node_position(pos)
			forge_fire_sounds[hash] = forge_fire_sounds[hash] or {}
			table.insert(forge_fire_sounds[hash], sound_id)
			-- Only remember the 3 last sound handles
			if #forge_fire_sounds[hash] > 3 then
				table.remove(forge_fire_sounds[hash], 1)
			end
			-- Remove the sound ID automatically from table after 11 seconds
			minetest.after(11, function()
				if not forge_fire_sounds[hash] then
					return
				end
				for f=#forge_fire_sounds[hash], 1, -1 do
					if forge_fire_sounds[hash][f] == sound_id then
						table.remove(forge_fire_sounds[hash], f)
					end
				end
				if #forge_fire_sounds[hash] == 0 then
					forge_fire_sounds[hash] = nil
				end
			end)
		end
	else
		if fuellist and not fuellist[1]:is_empty() then
			fuel_state = "1%", 0
		end
		formspec = ward.get_forge_inactive_formspec()

		-- stop timer on the inactive forge
		minetest.get_node_timer(pos):stop()
		meta:set_int("timer_elapsed", 0)

		stop_forge_sound(pos)
	end


	local infotext
	if active then
		infotext = "Forge active"

		detect_double_heat(pos, meta)
		local double_heat = ""
		if minetest.deserialize(meta:get_string("double_heat")) then
			double_heat = "_double_heat"
		end
		swap_node(pos, "ward:forge_active"..double_heat)
	else
		infotext = "Forge inactive"

		detect_double_heat(pos, meta)
		local double_heat = ""
		if minetest.deserialize(meta:get_string("double_heat")) then
			double_heat = "_double_heat"
		end
		swap_node(pos, "ward:forge"..double_heat)
	end
	--infotext = infotext .. "\n" .. "(Item: 1; Fuel: 2)", item_state, fuel_state

	--
	-- Set meta values
	--
	meta:set_float("fuel_totaltime", fuel_totaltime)
	meta:set_float("fuel_time", fuel_time)
	meta:set_float("src_time", src_time)
	meta:set_string("formspec", formspec)
	meta:set_string("infotext", infotext)

	return result
end

--
-- Node definitions
--
for idx,id in pairs({"", "_double_heat"}) do
	print("ward:forge"..id)
	local nici = idx-1
	minetest.register_node("ward:forge"..id, {
		description = "Forge",
		tiles = {
			"ward_forge_top.png", "ward_forge_top.png",
			"ward_forge_side.png", "ward_forge_side.png",
			"ward_forge_side.png", "ward_forge_front"..id..".png"
		},
		paramtype2 = "facedir",
		groups = {cracky=2, pickaxey=1, not_in_creative_inventory=nici},
		legacy_facedir_simple = true,
		is_ground_content = false,

		can_dig = can_dig,

		on_timer = forge_node_timer,

		on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			inv:set_size('src', 1)
			inv:set_size('src2', 1)
			inv:set_size('fuel', 1)
			inv:set_size('dst', 4)
			forge_node_timer(pos, 0)
		end,

		on_metadata_inventory_move = function(pos)
			minetest.get_node_timer(pos):start(1.0)
		end,
		on_metadata_inventory_put = function(pos)
			-- start timer function, it will sort out whether forge can burn or not.
			minetest.get_node_timer(pos):start(1.0)
		end,
		on_metadata_inventory_take = function(pos, listname, index, stack, player)

			if minetest.get_item_group(stack:get_name(), "ward_burning") ~= 0 then
				stack:set_name(string.sub(v:get_name(), 1, -8))
			end
			-- check whether the forge is empty or not.
			minetest.get_node_timer(pos):start(1.0)
			return stack
		end,

		allow_metadata_inventory_put = allow_metadata_inventory_put,
		allow_metadata_inventory_move = allow_metadata_inventory_move,
		allow_metadata_inventory_take = allow_metadata_inventory_take,
	})

	minetest.register_node("ward:forge_active"..id, {
		description = "Forge",
		tiles = {
			"ward_forge_top.png", "ward_forge_top.png",
			"ward_forge_side.png", "ward_forge_side.png",
			"ward_forge_side.png",
			{
				image = "ward_forge_front_active"..id..".png",
				backface_culling = false,
				animation = {
					type = "vertical_frames",
					aspect_w = 16,
					aspect_h = 16,
					length = 1.5
				},
			}
		},
		paramtype2 = "facedir",
		light_source = 8,
		drop = "ward:forge",
		groups = {cracky=2, pickaxey=1, not_in_creative_inventory=1},
		legacy_facedir_simple = true,
		is_ground_content = false,
		on_timer = forge_node_timer,
		on_destruct = function(pos)
			stop_forge_sound(pos)
		end,

		can_dig = can_dig,

		allow_metadata_inventory_put = allow_metadata_inventory_put,
		allow_metadata_inventory_move = allow_metadata_inventory_move,
		allow_metadata_inventory_take = allow_metadata_inventory_take,
	})
end

minetest.register_craft({
	output = "ward:forge",
	recipe = {
		{"group:stone", "group:stone", "group:stone"},
		{"group:stone", ward.items.iron["name"], "group:stone"},
		{"group:stone", "group:stone", "group:stone"},
	}
})
