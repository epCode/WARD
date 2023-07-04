local castable_class = "neutral"

ward_func.register_castable("exarmare", castable_class, 25, {{'up', 'up'}}, ward.alldescs["exarmare"], function(player, fire_stick)
  local fire_stick_power = minetest.get_item_group(fire_stick:get_name(), 'fire_stick_power')
  ward_func.send_blast(player, {castablename = "exarmare", speed = 25, range = 25, color = "#16ff31", fire_stick = fire_stick, on_hit_object = function(self, target)
    ward_func.object_particlespawn_effect(target, {
      amount = 100,
      time = 0.01,
      minsize = 2,
      maxsize = 4,
      minexptime = 0.2,
      maxexptime = 0.7,
      minacc = vector.new(0,1,0),
      maxacc = vector.new(0,7,0),
      minvel = vector.new(1,1,1),
      maxvel = vector.new(-1,-0.2,-1),
      texture = {
        name = "ward_star.png^[colorize:"..self.hex_color..":210^ward_star_core.png",
        scale_tween = {1.3, 0.1},
        blend = "screen",
      }
    })
    if target:is_player() and math.random(20/fire_stick_power) < 4 then
      witem = target:get_wielded_item()
      local item = minetest.add_item(vector.add(target:get_pos(), vector.new(0,1.3,0)), witem)
      if item then
        item:set_velocity(vector.multiply(target:get_look_dir(), 7))
        witem:take_item()
        player:set_wielded_item(witem)
      end
    end
  end})
end, 10, true)


ward_func.register_castable("avolare", castable_class, 10, {{'sneak', 'down', 'up'}}, ward.alldescs["avolare"], function(player, fire_stick)
  ward_func.send_blast(player, {castablename = "avolare", speed = 25, range = 35, color = "#ff1616", fire_stick = fire_stick, on_hit_object = function(self, target)
    local speed = 0.8
    if self._cast_on_caster then
      speed = 0.5
    end
    if math.random(3) == 1 and target:is_player() then
      target:get_meta():set_string("to_pos", "")
    end
    local move_speed = vector.add(vector.multiply(self.object:get_velocity(), speed/2.2), vector.new(0,5*speed,0))
    ward_func.object_particlespawn_effect(target, {
      amount = 100,
      time = 0.01,
      minsize = 2,
      maxsize = 4,
      minexptime = 0.2,
      maxexptime = 0.7,
      minacc = vector.new(0,1,0),
      maxacc = vector.new(0,7,0),
      minvel = vector.new(1,1,1),
      maxvel = vector.new(-1,-0.2,-1),
      texture = {
        name = "ward_star.png^[colorize:"..self.hex_color..":210^ward_star_core.png",
        scale_tween = {1.3, 0.1},
        blend = "screen",
      }
    })
    target:add_velocity(move_speed)
  end})
end, 6)


ward_func.register_castable("adducere", castable_class, 22, {{'sneak', 'down', 'down'}}, ward.alldescs["adducere"], function(player, fire_stick)
  if player:get_meta():get_string("to_pos") ~= '' then return end
  local fire_stick_power = minetest.get_item_group(fire_stick:get_name(), 'fire_stick_power')

  ward_func.send_blast( player, {castablename = "adducere", speed = 25, range = 35, color = "#63f9ff", fire_stick = fire_stick, on_hit_object = function(self, target)
    local go_dir = vector.direction(target:get_pos(), player:get_pos())
    go_dir = vector.rotate_around_axis(vector.multiply(go_dir, 90) or vector.zero(), vector.new(0,1,0), (target:get_look_horizontal() or target:get_yaw())*-1)
    ward_func.object_particlespawn_effect(target, {
      amount = 100,
      time = 0.1,
      minsize = 2,
      maxsize = 4,
      minexptime = 0.2,
      maxexptime = 1,
      minacc = go_dir,
      maxacc = vector.multiply(go_dir, 0.7),

      minvel = vector.new(0,0,0),
      maxvel = vector.new(-0,-0,-0),
      texture = {
        name = "ward_star.png^[colorize:"..self.hex_color..":210^ward_star_core.png",
        scale_tween = {1.3, 0.1},
        blend = "screen",
      }
    })
    if target:is_player() then
      target:get_meta():set_string("to_pos", minetest.serialize({vector.add(player:get_pos(), vector.multiply(player:get_look_dir(), 3)), minetest.get_gametime()+fire_stick_power/2, fire_stick_power}))
    else
      target:set_velocity(vector.multiply(vector.direction(target:get_pos(), player:get_pos()), fire_stick_power*2))
    end
  end})
end, 2)


ward_func.register_castable("adducere_ferre", castable_class, 35, {{'sneak', 'down', 'left', 'right'}, {'sneak', 'down', 'right', 'left'}}, ward.alldescs["adducere_ferre"], function(player, fire_stick)
  if player:get_meta():get_string("to_pos") ~= '' then return end
  local fire_stick_power = minetest.get_item_group(fire_stick:get_name(), 'fire_stick_power')
  ward_func.send_blast( player, {castablename = "adducere_ferre", speed = 25, range = 35, color = "#a3ce63", fire_stick = fire_stick, on_hit_object = function(self, target)
    if target:is_player() then
      target:get_meta():set_string("to_pos", minetest.serialize({{"player", player:get_player_name()}, minetest.get_gametime()+fire_stick_power/2, fire_stick_power}))
    else
      ward.ferre_obj[player] = {target, minetest.get_gametime()+fire_stick_power/2}
    end
  end})
end)

ward_func.register_castable("tollere", castable_class, 17, {{'sneak', 'jump', 'left', 'right'}, {'sneak', 'jump', 'right', 'left'}}, ward.alldescs["tollere"], function(player, fire_stick)
  if player:get_meta():get_string("to_pos") ~= '' then return end
  local fire_stick_power = minetest.get_item_group(fire_stick:get_name(), 'fire_stick_power')
  ward_func.send_blast(player, {castablename = "tollere", speed = 25, range = 35, color = "#ffffff", fire_stick = fire_stick, on_hit_object = function(self, target)
    if target:is_player() then
      target:get_meta():set_string("to_pos", minetest.serialize({vector.add(target:get_pos(), vector.new(0,3,0)), minetest.get_gametime()+fire_stick_power/2, fire_stick_power}))
    else
      target:set_velocity(vector.new(0,fire_stick_power/3+7,0))
    end
  end})
end, 5)


if minetest.get_modpath("wielded_light") then
  wielded_light.register_item_light('default:dirt', 14)
  ward_func.register_castable("lux", castable_class, 10,
    {
    {'aux1', 'aux1'},
    }, ward.alldescs["lux"],
    function(player, fire_stick, pointed_thing)
      witem = player:get_wielded_item()
      if minetest.get_item_group(witem:get_name(), 'lit_fire_stick') ~= 1 then
        witem:set_name(witem:get_name().."_lit")
        player:set_wielded_item(witem)
        ward_func.object_particlespawn_effect(player, {
          amount = 50,
          time = 0.01,
          minsize = 2,
          maxsize = 4,
          minexptime = 0.2,
          maxexptime = 1,
          texture = {
            name = "ward_star.png^[colorize:#f6ff65:210^ward_star_core.png",
            scale_tween = {1.3, 0.1},
            blend = "screen",
          }
        })

      else
        witem:set_name(witem:get_name():sub(1, -5))
        player:set_wielded_item(witem)
      end
    end, 15)
end

ward_func.register_castable("delustro", castable_class, 8,
{
  {'sneak', 'left', 'up', 'right'},
}, ward.alldescs["delustro"],
function(player, fire_stick, pointed_thing)
  ward_func.send_blast(player, {castablename = "delustro", speed = 25, range = 35, color = "#ffffff", fire_stick = fire_stick, on_hit_object = function(self, target)
    if target:is_player() then
      target:get_meta():set_string("to_pos", "")
      ward_func.remove_protection(target)
    else
      target:set_velocity(vector.new(0,fire_stick_power/3+7,0))
    end
  end})
end, 25)

local function set_occasu_portarum(player, tspots, formspec_extra, ts) -- to set teleport
  pos_tostringtspots = {}
  for k,v in pairs(tspots) do
    --table.insert(pos_tostringtspots, minetest.pos_to_string(v, 0))
    table.insert(pos_tostringtspots, k)
  end
  local fullspots = false
  if #pos_tostringtspots and #pos_tostringtspots > 2 then
    fullspots = true
  end
  local string_poss = ""
  if #pos_tostringtspots > 0 then
    string_poss = table.concat(pos_tostringtspots, ":"):gsub(",", ' | ')
    string_poss = string_poss:gsub(":", ',')
  end
  local thebutton = "image_button[2.25,10.55;3.4,1.2;ward_button_learnfull.png;learn_button_pos_full;Full]"
  if not ts then
    if not formspec_extra then
      formspec_extra = ""
    end
  end
  if not fullspots then
    thebutton = "image_button_exit[2.25,10.55;3.4,1.2;ward_button.png;learn_button_pos;Confirm name]"
    if not ts then
      if not formspec_extra then
        formspec_extra = ""
      end
      thebutton = "image_button[2.25,10.55;3.4,1.2;ward_button.png;learn_button;Learn Position]"
    end
  end
  local formspec =
    "formspec_version[4]"..
    "size[8,13]"..

    "background[-0.5,-0;9,13;ward_bg.png]"..
    thebutton..
    "textlist[0.5,1.5;7,7;tspots;"..string_poss..";nil;true]"..formspec_extra
  minetest.show_formspec(player:get_player_name(), "ward:occasu_portarum", formspec)
end

local function set_portarum(player, tspots) -- to teleport
  pos_tostringtspots = {}
  for k,v in pairs(tspots) do
    --table.insert(pos_tostringtspots, minetest.pos_to_string(v, 0))
    table.insert(pos_tostringtspots, k)
  end
  local string_poss = ""
  if #pos_tostringtspots > 0 then
    string_poss = table.concat(pos_tostringtspots, ":"):gsub(",", ' | ')
    string_poss = string_poss:gsub(":", ',')
  end
  local formspec =
    "formspec_version[4]"..
    "size[8,13]"..

    "background[-0.5,-0;9,13;ward_bg.png]"..
    "textlist[0.5,1.5;7,7;tspots;"..string_poss..";nil;true]"
  minetest.show_formspec(player:get_player_name(), "ward:portarum", formspec)
end

ward_func.register_castable("portarum", castable_class, 50,
{
  {'up', 'right', 'down', 'left', 'aux1', 'down'},
}, ward.alldescs["portarum"],
function(player, fire_stick, pointed_thing)
  local player_spots = minetest.deserialize(player:get_meta():get_string("ward_tspots"))
  if not player_spots then
    player_spots = {}
  end
  set_portarum(player, player_spots)
end)

ward_func.register_castable("occasu_portarum", castable_class, 30,
{
  {'up', 'right', 'down', 'left', 'aux1', 'sneak'},
}, ward.alldescs["occasu_portarum"],
function(player, fire_stick, pointed_thing)
  local player_spots = minetest.deserialize(player:get_meta():get_string("ward_tspots"))
  if not player_spots then
    player_spots = {}
  end
  set_occasu_portarum(player, player_spots)
end)

minetest.register_on_player_receive_fields(function(player, formname, fields) -- Teleportation UI
  if formname == "ward:occasu_portarum" then
    local pos = player:get_pos()
    local player_spots = minetest.deserialize(player:get_meta():get_string("ward_tspots"))
    if not player_spots then
      player_spots = {}
    end
    local numindexed = {}
    for k,v in pairs(player_spots) do
      table.insert(numindexed, v)
    end
    local numindexed_names = {}
    for k,v in pairs(player_spots) do
      table.insert(numindexed_names, k)
    end
    if fields['learn_button'] then
      local formspec2 =
        "textarea[2.5,9.8;3,0.6;textarea;   Position Name;]"
      set_occasu_portarum(player, player_spots, formspec2, true)
    elseif fields['learn_button_pos'] then
      player_spots[fields['textarea']] = pos
      player:get_meta():set_string("ward_tspots", minetest.serialize(player_spots))
    elseif fields["tspots"] then
      local formspec2 =
        "image_button[2.25,11.9;2.3,0.7;ward_button.png;delete_pos;Delete Pos]"..
        "image[2.25,9.68;3.4,0.6;ward_black.png]"..
        "label[2.4,10;"..minetest.pos_to_string(numindexed[tonumber(fields['tspots']:sub(5,-1))], 0).."]"

      theselectedthing = tonumber(fields['tspots']:sub(5,-1))
      ward_ui.theselectedcastable[player:get_player_name()] = numindexed_names[theselectedthing]
      set_occasu_portarum(player, player_spots, formspec2)
    elseif fields["delete_pos"] then
      local selected_thing = ward_ui.theselectedcastable[player:get_player_name()]
      if selected_thing then
        player_spots[selected_thing] = nil
        set_occasu_portarum(player, player_spots)
      end

      player:get_meta():set_string("ward_tspots", minetest.serialize(player_spots))
    end
  elseif formname == "ward:portarum" then
    local pos = player:get_pos()
    local player_spots = minetest.deserialize(player:get_meta():get_string("ward_tspots"))
    if not player_spots then
      player_spots = {}
    end
    local numindexed = {}
    for k,v in pairs(player_spots) do
      table.insert(numindexed, v)
    end
    if fields['tspots'] then
      local tpos = numindexed[tonumber(fields['tspots']:sub(5,-1))]

      minetest.forceload_block(tpos)
      minetest.close_formspec(player:get_player_name(), formname)
      player:get_meta():set_string("teleporting", minetest.serialize({vector.add(tpos, vector.new(0,0.5,0)), minetest.get_gametime()+3})) -- start teleporting to selected teleport
      local dsdsdsdsd = minetest.get_gametime()+3
      minetest.after(1, function()
        if not player or player and not player:get_velocity() then return end
        local tpstuff3 = minetest.deserialize(player:get_meta():get_string("teleporting"))
        tpstuff3 = tpstuff3[3] or 0
        local possible_spots = minetest.find_nodes_in_area_under_air(vector.add(tpos, vector.new(-0, -3, -0)), vector.add(tpos, vector.new(7, 7, 7)), {"group:cracky", "group:crumbly", "group:oddly_breakable_by_hand", "group:choppy", "group:snappy", "group:pickaxey", "group:handy", "group:shovely", "group:axey", "group:swordy"})
        possible_spots = possible_spots[1] or nil
        if possible_spots then
          tpos = possible_spots
          player:get_meta():set_string("teleporting", minetest.serialize({vector.add(tpos, vector.new(0,0.5,0)), dsdsdsdsd, tpstuff3})) -- start teleporting to selected teleport
        else
          ward_func.set_teleport_hud(player, true)
          player:get_meta():set_string("teleporting", "") -- start teleporting to selected teleport
          --TODO run Fail Command
          minetest.chat_send_player(player:get_player_name(), "Teleportation foiled! (something may be obscuring the spot)")
          return
        end


        local particles = ward_func.object_particlespawn_effect(player, {
          time = 2,
          amount = 300,
          minsize = 0.7,
          maxsize = 0.7,
          texture = {
            name = "ward_portatarum_particles.png",
            scale_tween = {2, 0.01},
            blend = "screen",
          },
        })
        ward_func.object_particlespawn_effect(tpos, {
          time = 5,
          amount = 1000,
          minsize = 0.7,
          maxsize = 0.7,
          texture = {
            name = "ward_portatarum_particles.png",
            scale_tween = {2, 0.01},
            blend = "screen",
          },
        })
      end)

    end
  end
end)


ward_func.register_castable("cogo", castable_class, 25,
{
  {'left', 'right', 'down', 'up'},
}, ward.alldescs["cogo"],
function(player, fire_stick, pointed_thing)
  ward_func.send_blast(player, {castablename = "cogo",
    speed = 25,
    range = 25,
    color = "#9999ff",
    fire_stick = fire_stick,
    on_hit_node = function(self, under, above)
      fire_stick_power = minetest.get_item_group(fire_stick:get_name(), "fire_stick_power")
      local pos1 = vector.add(under, vector.new(fire_stick_power/1.5,fire_stick_power/1.5,fire_stick_power/1.5))
      local pos2 = vector.add(under, vector.new(-fire_stick_power/1.5,-fire_stick_power/1.5,-fire_stick_power/1.5))
      for _,obj in ipairs(minetest.get_objects_in_area(pos1, pos2)) do
        obj:add_velocity(vector.multiply(vector.direction(obj:get_pos(), under), fire_stick_power*1.5+3))
      end
    end
  })
end, 6)

local function take_torch(player)
	local inv = player:get_inventory()
	local torch_stack, torch_stack_id
	for i=1, inv:get_size("main") do
		local it = inv:get_stack("main", i)
		if not it:is_empty() and minetest.get_item_group(it:get_name(), "torch") ~= 0 then
			torch_stack = it
			torch_stack_id = i
			break
		end
	end
  if torch_stack then
    torch_stack:take_item()
    inv:set_stack("main", torch_stack_id, torch_stack)
  end
	return torch_stack, torch_stack_id
end

ward_func.register_castable("luminum", castable_class, 8,
{
  {'left', 'aux1', 'right'},
}, ward.alldescs["luminum"],
function(player, fire_stick, pointed_thing)
  local torchitem, id = take_torch(player)
  if not torchitem then return end
  ward_func.send_blast(player, {castablename = "luminum",
    speed = 10,
    range = 35,
    color = "#ddba34",
    fire_stick = fire_stick,
    on_hit_node = function(self, under, above)
      if minetest.registered_nodes[torchitem:get_name()] then
        minetest.place_node(above, {name=torchitem:get_name()})
      end
    end
  })
end, 12)
