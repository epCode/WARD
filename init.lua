ward = {
  castable_combo_pressed_timer = {}, --recorded time when a castable combo was pressed (player indexed)
  wands = {}, --a name list of all wands
  castables = {}, --a name list of all castables
  castabledescs = {}, --a list of all castables full description
  ferre_obj = {}, --player indexed objectref info for when the player casts adducere_ferre on a non player obj
  manauseage = {}, --the amount of mana each castablename uses, castablename indexed
  affected_objects = {},
  findable_castables = {},
  selfcastablescastables = {},
  castable_class = {},
}
ward_func = {} --public functions

ward_mana = {
  hud = {},
  mana = {},
}

ward_ui = {
  theselectedcastable = {},
  book_of_knowledge_page = {},
}

dofile(minetest.get_modpath("ward").."/mana.lua")




--Amount of time a castable can be held after combo pressed
castableHOLDTIME = 2

local castablecastablehud_hud = {}

function ward_func.has_learned(player, castable) -- see if player has the ability to wield said spell
  local meta = player:get_meta():get_string("castables")
  if meta ~= "" then
    for _,V in ipairs(minetest.deserialize(meta)) do
      if V == castable then
        return true
      end
    end
    return false
  end
end

function ward_func.learn(player, castable) -- give the player the ability to wield said spell
  local meta = player:get_meta():get_string("castables")
  if meta == '' then
    player:get_meta():set_string("castables", minetest.serialize({}))
    meta = player:get_meta():get_string("castables")
  end
  local castable_list = minetest.deserialize(meta)
  table.insert(castable_list, castable)
  player:get_meta():set_string("castables", minetest.serialize(castable_list))
end

local wand_on_use = function(itemstack, user, pointed_thing) -- what to do when rightclick or leftclick is pressed while wielding a wand
  local castable = ward.castable_combo_pressed_timer[user:get_player_name()]
  if user and user:is_player() and ward_func[castable[1]] then
    if ward_func.has_learned(user, castable[1]) and ward_func.use_mana(user, ward.manauseage[castable[1]]) then
      ward.castable_combo_pressed_timer[user:get_player_name()] = {"", 0}
      ward_func[castable[1]](user, itemstack, pointed_thing)
      if user:is_player() and castablecastablehud_hud[user] then
        user:hud_remove(castablecastablehud_hud[user][1])
        castablecastablehud_hud[user] = nil
      end

      minetest.sound_play("ward_"..castable[1]..".ogg", {
        pos = user:get_pos(),
        max_hear_distance = 16,
        gain = 1.0,
      }, true)
    end
  end
end

function ward.register_wand(name, def) -- creates a new wand
  minetest.register_tool(name, def)
  ward.wands[name] = def
end
for i=1, 15 do
  ward.register_wand("ward:basic_wand_"..i, {
    description = "Power "..i,
    inventory_image = "ward_dark_oak.png",
    on_use = wand_on_use,
    on_secondary_use = wand_on_use,
    range = 0,
    groups = {wand_power=i}
  })
end
--[[
ward.register_wand("ward:intermediate_wand", {
  description = "Intermediate",
  inventory_image = "ward_dark_oak.png",
  on_use = wand_on_use,
  on_secondary_use = wand_on_use,
  range = 0,
  groups = {wand_power=10}
})]]
--[[
ward.register_wand("ward:elder_wand", { -- admin wand
  description = "Advanced",
  inventory_image = "ward_elder.png",
  on_use = wand_on_use,
  on_secondary_use = wand_on_use,
  range = 0,
  groups = {wand_power=20}
})]]

if minetest.get_modpath("wielded_light") then -- for light castable
  for k,v in pairs(ward.wands) do
    deff=table.copy(v)
    deff.groups.lit_wand = 1
    deff.groups.not_in_creative_inventory = 1
    deff.inventory_image = deff.inventory_image.."^ward_lux_add.png"
    minetest.register_tool(k.."_lit", deff)
    wielded_light.register_item_light(k.."_lit", 14)
  end
end

local function dtrandom(min, max) --a random number with 2 dicimal points
  return math.random(min*100, max*100)/100
end


local function blast_explode(pos, color, dur, vel) --a particle effect
  dur = dur or 1
  vel = vel or 1
  ward_func.object_particlespawn_effect(pos, {
    posize = -0.2,
    time = 0.01,
    minacc = vector.new(0,0,0),
    maxacc = vector.new(0,0,0),
    minvel = vector.new(4,4,4),
    maxvel = vector.new(-4,-4,-4),

    amount = 110,
    minsize = 2,
    maxsize = 4,
    minexptime = 0.2,
    maxexptime = 0.5,
    glow = 14,
    texture = {
      name = "ward_star.png^[colorize:"..color..":210^ward_star_core.png",
      alpha_tween = {1,0.1},
      scale_tween = {1, 0.01},
      blend = "screen",
      animation = {
        type = "vertical_frames",
        aspect_w = 8,
        aspect_h = 8,
        length = 5,
      },
    },
  })
end

function ward_func.object_particlespawn_effect(player, def)
  thispos = vector.zero()
  if not player then return end
  if player and player["x"] then
    thispos = player
    player = nil
  end
  def.posize = def.posize or 0
  local collbox = {-0.3, 0.0, -0.3, 0.3, 1.6, 0.3}
  if player and not player:is_player() and player:get_luaentity() then
    collbox = player:get_properties().collisionbox
  end
  if not def.extra_posmax then
    def.extra_posmax = vector.new(0,0,0)
    def.extra_posmin = vector.new(0,0,0)
  end
  def.minacc = def.minacc or vector.zero()
  def.maxacc = def.maxacc or vector.zero()
  return minetest.add_particlespawner({
    amount = def.amount or 6000,
    time = def.time or 20,
    minpos = {x=collbox[1]-def.posize+thispos.x+(def.extra_posmin.x or 0), y=collbox[2]-def.posize+thispos.y+(def.extra_posmin.y or 0), z=collbox[3]-def.posize+thispos.z+(def.extra_posmin.z or 0)},
    maxpos = {x=collbox[4]+def.posize+thispos.x+(def.extra_posmax.x or 0), y=collbox[5]+def.posize+thispos.y+(def.extra_posmax.y or 0), z=collbox[6]+def.posize+thispos.z+(def.extra_posmax.z or 0)},
    minvel = def.minvel or {x=-0.2, y=-0.2, z=-0.2},
    maxvel = def.maxvel or {x=0.2, y=0.2, z=0.2},
    minacc = def.minacc or vector.zero(),
    maxacc = def.maxacc or vector.zero(),
    minexptime = def.minexptime or 0.1,
    maxexptime = def.maxexptime or 0.2,
    minsize = def.minsize or 0.1,
    maxsize = def.maxsize or 0.7,
    collisiondetection = false,
    attached = player,
    vertical = false,
    texture = def.texture or "ward_star.png",
    glow = def.glow or 14,
  })
end


function ward_func.remove_protection(player) --remove protection effects on certain player
  local praesidium = minetest.deserialize(player:get_meta():get_string("praesidium"))
  local p2
  if praesidium and #praesidium then
    if praesidium[1] then
      p2 = praesidium[1]
    else
      for k,v in pairs(praesidium) do
        p2 = k
      end
    end
    if tonumber(p2) then
      minetest.delete_particlespawner(p2)
    end
  end
  player:get_meta():set_string("praesidium", "")
end


function ward_func.remove_to_pos(player) --remove protection effects on certain player
  player:get_meta():set_string("to_pos", "")
end


minetest.register_node("ward:light", {
	drawtype = "airlike",
	paramtype = "light",
	sunlight_propagates = true,
	--tiles = {"ward_empty.png"},
	light_source = 10,
	selection_box = {
		type = "fixed",
		fixed = {
			{0,0,0,0,0,0}
		}
	},
  walkable = false,
	groups = {not_in_creative_inventory=1}
})

minetest.register_entity("ward:magic_entity", { -- castable entity
  textures = {"ward_star_thin.png"},
  _original_vel = vector.new(0,0,0),
  _range_timer = 5,
  hex_color = "#ff1616",
  _is_magic = true,
  visual_size = {
    x=0.3,
    y=0.3,
  },
  on_activate = function(self)
    minetest.after(0.05, function()
      if self and self.object and self.object:get_velocity() then
        self.object:set_properties({
          textures = {"ward_star.png^[colorize:"..self.hex_color..":210^ward_star_core.png"},
        })
      end
    end)
  end,
  on_step = function(self, dtime, moveresult)

    local obvel = self.object:get_velocity()
    if math.abs(obvel.x)+math.abs(obvel.x)+math.abs(obvel.x) < 0.1 then
      self.object:remove()
      return
    end
    local nopos = self.object:get_pos()
    local node = minetest.get_node(nopos)
    if node and node.name and node.name == "air" then
      minetest.set_node(nopos,{name="ward:light"})
      minetest.after(0.4, function()
        minetest.remove_node(nopos)
      end)
    end

    if self._cast_on_caster and self._shooter and self._on_hit_object then
      self._on_hit_object(self, self._shooter)
      self.object:remove()
      return
    end
    local vel = self.object:get_velocity()
    self._range_timer = self._range_timer-(dtime*(math.abs(vel.x)+math.abs(vel.y)+math.abs(vel.z)))
    if self._range_timer < 0 then
      self.object:remove()
      return
    end

    self.object:set_velocity(vector.rotate_around_axis(vel, self._original_vel, 32.3))

    local closest_object, closest_distance
    local pos = self.object:get_pos()
    local raycast = minetest.raycast(pos, vector.add(pos, vector.multiply(self.object:get_velocity(), 0.1)), true, false)
    for hitpoint in raycast do
      if hitpoint.type == "object" and self._on_hit_object and hitpoint.ref ~= self._shooter and hitpoint.ref ~= self.object then
        if not (not hitpoint.ref:is_player() and hitpoint.ref:get_luaentity() and hitpoint.ref:get_luaentity()._is_magic) then
          if hitpoint.ref:is_player() and hitpoint.ref:get_meta():get_string("praesidium") == "" or not hitpoint.ref:is_player() then

            if hitpoint.ref:is_player() and hitpoint.ref:get_player_control().RMB and math.random(5) ~= 1 and minetest.get_item_group(hitpoint.ref:get_wielded_item():get_name(), "wand_power") ~= 0 then
              minetest.chat_send_all(hitpoint.ref:get_player_name().." BLOCKED "..self._shooter:get_player_name().."'s shot!!")
              blast_explode(self.object:get_pos(), "#ffffff", 3, 0.3)
              self.object:remove()
              return
            else
              self._on_hit_object(self, hitpoint.ref)
              self.object:remove()
              return
            end
          else
            if hitpoint.ref:is_player() and math.random(2) == 1 then
              ward_func.remove_protection(hitpoint.ref)
            end
            blast_explode(hitpoint.above, self.hex_color)
          end
          self.object:remove()
          return
        end
      elseif hitpoint.type == "node" then
        if self._on_hit_node then
          self._on_hit_node(self, hitpoint.under, hitpoint.above)
        end
        blast_explode(hitpoint.above, self.hex_color)
        self.object:remove()
        return
      end
    end



  end,
  on_deactivate = function(self)
    if self._particles then
      minetest.delete_particlespawner(self._particles)
    end
  end,
  glow = 14
})


function ward_func.send_blast(player, options)
  local wand_power = minetest.get_item_group(options.wand:get_name(), 'wand_power')
  local eye_pos = vector.add(player:get_pos(), vector.add(vector.new(0,player:get_properties().eye_height,0), vector.multiply(player:get_look_dir(), 0.2)))
  local blast = minetest.add_entity(eye_pos, "ward:magic_entity")
  if player:get_player_control().RMB and not player:get_player_control().LMB and ward.selfcastablescastables[options.castablename] then
    blast:get_luaentity()._cast_on_caster = true
  end
  blast:get_luaentity()._particles = minetest.add_particlespawner({
    amount = 2000,
    time = 10,
    minpos = {x=-0.03, y=-0.03, z=-0.03},
    maxpos = {x=0.03, y=0.03, z=0.03},
    minvel = {x=0.2, y=0.2, z=0.2},
    maxvel = {x=0, y=0, z=0},
    minacc = {x=0, y=-0, z=0},
    maxacc = {x=0, y=-0, z=0},
    minexptime = 0.2,
    maxexptime = 0.4,
    minsize = 02,
    maxsize = 02,
    collisiondetection = false,
    attached = blast:get_luaentity().object,
    vertical = false,
    texture = {
      name = "ward_star.png^[colorize:"..options.color..":255^ward_star_core.png",
      scale_tween = {2, 0},
      blend = "screen",
    },
    glow = 14,

  })

  blast:set_velocity(vector.multiply(player:get_look_dir(), options.speed+wand_power*2))
  blast:get_luaentity()._original_vel = blast:get_velocity()
  blast:get_luaentity()._range_timer = (options.range or 30) * (wand_power/5+1)
  blast:get_luaentity().hex_color = options.color or "#ffffff"
  blast:get_luaentity()._on_hit_object = options.on_hit_object
  blast:get_luaentity()._on_hit_node = options.on_hit_node
  blast:get_luaentity()._shooter = player
  blast:add_velocity(vector.new(dtrandom(-0.4*(wand_power-20), 0.4*(wand_power-20)),dtrandom(-0.4*(wand_power-20), 0.4*math.abs(wand_power-20)),dtrandom(-0.4*(wand_power-20), 0.4*(wand_power-20))))
end

function ward.learn_castable(player, castable)
  local learned_castables = minetest.deserialize(player:get_meta():get_string("castables")) or {}
  for k,v in pairs(learned_castables) do
    if v == castable then
      return false
    end
  end
  table.insert(learned_castables, castable)
  player:get_meta():set_string("castables", minetest.serialize(learned_castables))
end

minetest.register_on_joinplayer(function(player)
	local player_name = player:get_player_name()
	ward.castable_combo_pressed_timer[player_name] = {"", 0}
end)



local function show_castablecastablehud_hud(player, castablename)
  if not ward_func.has_learned(player, castablename) then return end
  local effect = ""
  if not ward_func.use_mana(player, ward.manauseage[castablename] or 30, true) then
    effect = "^ward_not_enough_mana.png"
  end
  if castablecastablehud_hud[player] and ward.castable_combo_pressed_timer[player:get_player_name()][2] < minetest.get_gametime() then
    ward.castable_combo_pressed_timer[player:get_player_name()] = {"", 0}
    player:hud_remove(castablecastablehud_hud[player][1])
    castablecastablehud_hud[player] = nil
    return
  elseif castablecastablehud_hud[player] then
    player:hud_change(castablecastablehud_hud[player][1], "text", "ward_"..castablename..".png"..effect)
    return
  end
  if not castablecastablehud_hud[player] then
    local random_int = math.random(1000)
    castablecastablehud_hud[player] = {player:hud_add({
      hud_elem_type = "image",
      text = "ward_"..castablename..".png"..effect,
      position = {x = 0.97, y = 0.90},
      scale = {x = 4, y = 4},
      z_index = 100,
    }), random_int}
  end
end

function ward_func.register_castable(castablename, castable_class, manauseage, combos, desc, func, finable, notcastableonself)
  ward.castable_class[castablename] = castable_class
  ward.castabledescs[castablename] = desc
  ward.manauseage[castablename] = manauseage
  if not notcastableonself then
    ward.selfcastablescastables[castablename] = true
  end
  if finable then
    for i=1, finable do
      table.insert(ward.findable_castables, castablename)
    end
  end
  table.insert(ward.castables, castablename)
  key_combos.register_key_combo(castablename, combos, function(player)
    if minetest.get_item_group(player:get_wielded_item():get_name(), "wand_power") ~= 0 then
    	ward.castable_combo_pressed_timer[player:get_player_name()] = {castablename, minetest.get_gametime() + castableHOLDTIME}
    end
  end)
  ward_func[castablename] = func
end

local tp_hud = {}

function ward_func.set_teleport_hud(player, remove, ratiod)
  if remove and tp_hud[player] then
    player:hud_remove(tp_hud[player])
    tp_hud[player] = nil
    return
  end
  if tp_hud[player] then
    player:hud_change(tp_hud[player], "text", "ward_tpimage.png^[opacity:"..ratiod+math.random(-20,20).."")
  else
    tp_hud[player] = player:hud_add({
      hud_elem_type = "image",
      text = "ward_tpimage.png^[opacity:0",
      position = {x = 0.5, y = 0.5},
      scale = {x = 100, y = 100},
      z_index = 0,
    })
  end
end





minetest.register_globalstep(function(dtime)
	for _,player in pairs(minetest.get_connected_players()) do
    local meta = player:get_meta()
    local witem = player:get_wielded_item()
    local name = player:get_player_name()
    if minetest.get_item_group(witem:get_name(), "wand_power") ~= 0 and ward.castable_combo_pressed_timer[name] then

      show_castablecastablehud_hud(player, ward.castable_combo_pressed_timer[name][1])
    end
    if meta:get_string("to_pos") == '' then
      playerphysics.remove_physics_factor(player, "gravity", "ward:to_pos_pys")
    end
    local teleporting = meta:get_string("teleporting")
    if teleporting ~= "" then
      teleporting = minetest.deserialize(teleporting)
      if teleporting[2] < minetest.get_gametime() then
        player:set_pos(teleporting[1])
        meta:set_string("teleporting", "")
        ward_func.set_teleport_hud(player, true)
      else
        teleporting[3] = teleporting[3] or 0.01
        teleporting[3] = teleporting[3] + 0.007
        player:set_look_horizontal(player:get_look_horizontal()-teleporting[3])
        ward_func.set_teleport_hud(player, false, teleporting[3]*400)
        meta:set_string("teleporting", minetest.serialize(teleporting))
      end

    end
    if meta:get_string("praesidium") ~= "" and minetest.deserialize(meta:get_string("praesidium"))[2] < minetest.get_gametime() then
      ward_func.remove_protection(player)
    end
    if player:get_player_control().RMB and string.find(witem:get_name(), "ward") and string.find(witem:get_name(), "wand") then
      playerphysics.add_physics_factor(player, "jump", "ward:wand_pys", 0)
      playerphysics.add_physics_factor(player, "speed", "ward:wand_pys", 0.3)
    else
      playerphysics.remove_physics_factor(player, "jump", "ward:wand_pys")
      playerphysics.remove_physics_factor(player, "speed", "ward:wand_pys")
    end
    local to_pos = meta:get_string("to_pos")

    local ferre_obj = ward.ferre_obj[player] -- This code block checks if a specific object exists and meets certain conditions before computing and updating its movement velocity towards a target position while dampening its velocity over time.
    if ferre_obj and ferre_obj[1]:get_velocity() and ferre_obj[2] > minetest.get_gametime() and minetest.get_item_group(witem:get_name(), "wand_power") ~= 0 then
      local obcol = ferre_obj[1]:get_properties().collisionbox or ferre_obj[1]:get_luaentity().collision_box or ferre_obj[1]:get_luaentity().collisionbox or {0.5, 0.5, 0.5, 0.5, 0.5, 0.5}
      local object_volume = math.abs(obcol[1]) + math.abs(obcol[2]) + math.abs(obcol[3]) + math.abs(obcol[4]) + math.abs(obcol[5]) + math.abs(obcol[6])
      local go_to_this_pos = player:get_pos() + vector.new(0, 1.3, 0) + player:get_look_dir() * 2
      ferre_obj[1]:add_velocity(vector.direction(ferre_obj[1]:get_pos(), go_to_this_pos) * (vector.distance(ferre_obj[1]:get_pos(), go_to_this_pos) / object_volume))
      ferre_obj[1]:set_velocity(ferre_obj[1]:get_velocity() * 0.83)
    else
      ward.ferre_obj[player] = nil
    end

    if player:get_velocity() and player and to_pos and minetest.deserialize(to_pos) and to_pos ~= '' then -- this code allows the player to move towards a specified position

      to_pos = minetest.deserialize(to_pos)


      local vel, pos = player:get_velocity(), player:get_pos()
      if to_pos[2] and to_pos[2] < minetest.get_gametime() then
        ward_func.remove_to_pos(player)
      elseif meta:get_string("to_pos") ~= '' and pos and to_pos[1] then
        local go_to_pos = to_pos[1]
        local is_to_pos = true
        if to_pos[1][1] then
          if to_pos[1][1] == "player" and minetest.get_player_by_name(to_pos[1][2]) then
            local the_player = minetest.get_player_by_name(to_pos[1][2])
            if the_player:get_velocity() and the_player:get_pos() then
              if minetest.get_item_group(the_player:get_wielded_item():get_name(), "wand_power") == 0 then
                ward_func.remove_to_pos(player)
                is_to_pos = false
              end
              go_to_pos = vector.add(the_player:get_pos(), vector.multiply(the_player:get_look_dir(), 2.5))
              if the_player:get_player_control().LMB and the_player:get_player_control().RMB then
                player:add_velocity(vector.multiply(the_player:get_look_dir(), to_pos[3]))
                ward_func.remove_to_pos(player)
                is_to_pos = false
              end
            else
              ward_func.remove_to_pos(player)
              is_to_pos = false
            end
          else
            ward_func.remove_to_pos(player)
            is_to_pos = false
          end
        end
        if (to_pos[1][1] and go_to_pos ~= "player" or to_pos[1]['x']) and is_to_pos then
          local dir = vector.direction(pos, go_to_pos)
          local distance = vector.distance(pos, go_to_pos)
          playerphysics.add_physics_factor(player, "gravity", "ward:to_pos_pys", 0)

          local go_dir = vector.rotate_around_axis(vector.multiply(dir, 90) or vector.zero(), vector.new(0,1,0), player:get_look_horizontal()*-1)
          go_dir = vector.multiply(go_dir, distance/5)
          dir = vector.multiply(dir, vector.new(2,1,2))
          player:add_velocity(vector.multiply(vel, -0.1))
          player:add_velocity(vector.multiply(dir, (to_pos[3]/7+0.3)*(distance/5))*(to_pos[3]/10))

          ward_func.object_particlespawn_effect(player, {
            amount = 4,
            time = 0.01,
            minsize = 2,
            maxsize = 4,
            minexptime = 0.2,
            maxexptime = 1,
            minacc = go_dir,
            maxacc = vector.multiply(go_dir, 0.7),
            --minvel = vector.new(0,-2,0),
            --maxvel = vector.new(0,-200,0),

            texture = {
              name = "ward_star.png^[colorize:#a3ce63:210^ward_star_core.png",
              scale_tween = {1.3, 0.1},
              blend = "screen",
            }
          })

        end
      end
    end


    for object,def in pairs(ward.affected_objects) do
      if def.duration < minetest.get_gametime() then
        ward.affected_objects[object] = nil
      else
        def.persistance[2] = def.persistance[2] + dtime
        if def.persistance[2] > def.persistance[1] then
          def.effect(object)
          def.persistance[2] = 0
        end
      end
    end

  end
end)

dofile(minetest.get_modpath("ward").."/learn_station_generation.lua")
dofile(minetest.get_modpath("ward").."/castables.lua")
dofile(minetest.get_modpath("ward").."/castabook.lua")

minetest.register_chatcommand("gspellme", {
	params = "castable",
  description = "Grant player castable",
	privs = {give=true, interact=true},
	func = function(name, param)
    if param == "all" then
      for k,v in pairs(ward.castables) do
        ward.learn_castable(minetest.get_player_by_name(name), v)
      end
      return true
    end
    for k,v in pairs(ward.castables) do
      if v == param then
        ward.learn_castable(minetest.get_player_by_name(name), v)
        return true, "Learned castables: "..table.concat(minetest.deserialize(minetest.get_player_by_name(name):get_meta():get_string("castables")), ', ')..""
      end
    end
		return false, "Invalid castable (see /help gspellme)"
	end,
})

minetest.register_abm({
	nodenames = {"ward:light"},
	interval = 10,
	chance = 1,
	action = function(pos, node)
		minetest.remove_node(pos)
	end
})

function ward_func.add_persistant_effect(def)
  ward.affected_objects[def.object] = {duration = minetest.get_gametime()+def.duration, persistance = {def.persistance, 0}, effect = def.effect}
end
