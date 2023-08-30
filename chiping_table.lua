local gems = {
  diamond = minetest.registered_items["default:diamond"],
}

TABLEITEMOFFSET = vector.new(0,1,0)

local mineclone = minetest.get_modpath("mcl_core")

local nodebox = {
  { -0.5 , -0.5 , -0.5 , -0.37 , 0.13 , -0.37}, -- legs
  { 0.37 , -0.5 , -0.5 , 0.5 , 0.13 , -0.37},
  { 0.37 , -0.5 , 0.37 , 0.5 , 0.13 , 0.5},
  { 0.37 , -0.5 , -0.5 , 0.5 , 0.13 , -0.37},

  { -0.5 , 0.13 , -0.5 , 0.5 , 0.25 , 0.5}, -- top
}

gems.diamond =
  minetest.registered_items["mcl_core:diamond"] or
  gems.diamond

ward.register_forged_item({ --
	cooktime = 32,
  double_heat = true,
	output = "ward:double_stick_diamond",
	recipe = {'ward:double_stick_reinforced', "ward:diamond_chip_med"}
})


local function get_ct_item(pos, table)
  obj = minetest.get_objects_inside_radius(pos, 0.01)
  if #obj and #obj < 1 or not obj then return end
  if table and obj[1]:get_luaentity() and obj[1]:get_luaentity()._is_ct then
    return obj[1]
  end
  obj = minetest.get_objects_inside_radius(vector.add(pos, TABLEITEMOFFSET), 0.01)
  if #obj and #obj < 1 or not obj then return end
  if obj[1]:get_luaentity() and obj[1]:get_luaentity()._is_ct_item then

    return obj[1]
  end
end

minetest.register_node("ward:chiping_table", {
  description = "Chipping Table",
  drawtype = "mesh",
  mesh = "ward_chiping_table.obj",
  selection_box = {
    type = "fixed",
    fixed = nodebox,
  },
  collision_box = {
    type = "fixed",
    fixed = nodebox,
  },
  --[[
  node_box = {
    type = "fixed",
    fixed = nodebox,
  },]]
  inventory_image = "ward_chiping_table_inv.png",
  tiles = {"ward_chiping_table.png"},
  on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
    local witem = clicker:get_wielded_item()
    if witem:get_name() == gems.diamond.name and minetest.get_meta(pos):get_string("gem") == "" then
      local obj = minetest.add_entity(vector.add(pos, TABLEITEMOFFSET), "ward:chiping_table_item_entity")
      local TOTALHITS = math.random(2, 7)
      local diamond = {witem:get_name(), TOTALHITS}
      obj:get_luaentity().TOTALHITS = TOTALHITS
      itemstack:take_item()
      minetest.get_meta(pos):set_string("gem", minetest.serialize(diamond))
      return itemstack
    end
  end,
  _mcl_hardness = 1.5,
  is_ground_content = true,
  groups = {choppy=1, oddly_breakable_by_hand=1, axey=1, tree=1, flammable=2, building_block=1, material_wood=1, fire_encouragement=5, fire_flammability=5},
})

minetest.register_on_dignode(function(pos, oldnode, digger) -- remove table and gem when dug
  if oldnode.name ~= "ward:chiping_table" then return end
  local gem = get_ct_item(pos)
  if gem then
    --minetest.chat_send_all("sawd")
    gem:remove()
  end
end)


local function set_chipped_tex(luaentity, texture, gemeta)
  local chipped_texture = "[combine:16x16:0,0=blank:0,"..16-((16/luaentity.TOTALHITS)*gemeta[2]).."="..texture
  luaentity.object:set_properties({
    textures={texture=chipped_texture}
  })
end

minetest.register_entity("ward:chiping_table_item_entity", {
	visual = "mesh",
	mesh = "ward_chiping_table_item.obj",
	visual_size = {x = 10, y = 10},
  hp_max = 100,
	collisionbox = {-0.25, -0.75, -0.25, 0.25, 0.1, 0.25},
	selectionbox = {-0.25, -0.75, -0.25, 0.25, -0.69, 0.25},
	physical = false,
  _is_ct_item = true,
  textures = {gems.diamond.inventory_image},
  --static_save = false,
  damage_texture_modifier = "",
  on_activate = function(self, staticdata, dtime_s)
    local pos = vector.add(self.object:get_pos(), vector.new(0,-1,0))
    if bench_node and bench_node.name and bench_node.name ~= "ward:chiping_table" then
      self.object:remove()
      return
    end
    local gemeta = minetest.get_meta(pos):get_string("gem")
    local bench_node = minetest.get_node(pos)
    gemeta = minetest.deserialize(gemeta)
    self.TOTALHITS = self.TOTALHITS or 5
    if gemeta then
      set_chipped_tex(self, gems.diamond.inventory_image, gemeta)
    end
  end,
  _angular_vel = 0,
  on_step = function(self)
    if self._angular_vel > 0.1 then
      --self.object:set_yaw(self.object:get_yaw()+self._angular_vel)
      self.object:set_properties({automatic_rotate=(self._angular_vel*3)})
      self._angular_vel = self._angular_vel / 2
    elseif self._angular_vel ~= 0 then
      self._angular_vel = 0
      self.object:set_properties({automatic_rotate=0})
    end
  end,
  on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, direction, damage)
    if not puncher then return true end
    self.object:set_hp(100)
    local pos = vector.add(self.object:get_pos(), vector.new(0,-1,0))
    local witem = puncher:get_wielded_item()
    if minetest.get_item_group(witem:get_name(), "axe") == 0 then return true end -- make sure a player is hitting the table with and axe
    local gemeta = minetest.get_meta(pos):get_string("gem")
    gemeta = minetest.deserialize(gemeta)
    if not gemeta then return true end -- make sure there is a gem in the table to hit


    gemeta[2] = gemeta[2]-1

    self.TOTALHITS = self.TOTALHITS or 5
    set_chipped_tex(self, gems.diamond.inventory_image, gemeta)
    minetest.get_meta(pos):set_string("gem", minetest.serialize(gemeta))
    if gemeta[2] < 1 then
      minetest.get_meta(pos):set_string("gem", "")
      self.object:remove()
    else-- if the diamond didn't break
      local go_dir = puncher:get_look_dir() -- the direction the particles and the chip will fly when gem is struck
      local chip_types = {"med", "small", "tiny"}
      if mineclone then -- If we're playing Mineclone2 then add these chips as items: otherwise just add straight to inventory
        local item = minetest.add_item(pos, ItemStack("ward:diamond_chip_rough_"..chip_types[math.random(#chip_types)]))
        item:set_velocity(vector.add(vector.multiply(go_dir, math.random(2, 7)), vector.new(math.random(-20, 20)/10,math.random(3, 10),math.random(-20, 20)/10)))
      else
        local inv = puncher:get_inventory()
        if inv then
          local item = inv:add_item("main", ItemStack("ward:diamond_chip_rough_"..chip_types[math.random(#chip_types)]))
          item = minetest.add_item(pos, item)
          if item then
            item:set_velocity(vector.add(vector.multiply(go_dir, math.random(2, 7)), vector.new(math.random(-20, 20)/10,math.random(3, 10),math.random(-20, 20)/10)))
          end
        end
      end

      ward_func.object_particlespawn_effect(self.object, {
        amount = 4,
        time = 0.1,
        minsize = 0,
        maxsize = 1,
        minexptime = 0.2,
        maxexptime = 1,
        minacc = vector.new(0,-9,0),
        maxacc = vector.new(0,-9,0),
        minvel = vector.add(vector.multiply(go_dir, 2), vector.new(0,2,0)),
        maxvel = vector.add(vector.multiply(go_dir, 6), vector.new(0,10,0)),
        --maxvel = (vector.new(0,-200,0)),
        collisiondetection = true,

        texture = {
          name = "ward_diamond_chip_small.png^[colorize:#a3ce63:210^ward_star_core.png",
          scale_tween = {1.3, 0.1},
          blend = "screen",
        }
      })

      self._angular_vel = 10
    end
    return true

  end,
})
