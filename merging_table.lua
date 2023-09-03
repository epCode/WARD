TABLEITEMOFFSET = vector.new(0,1,0)

local mineclone = minetest.get_modpath("mcl_core")

local nodebox = {
  -- legs
  { 0.37 , -0.5 , 0.37 , 0.5 , 0.13 , 0.5}, --z-
  { -0.37 , -0.5 , 0.5 , -0.5 , 0.13 , 0.37}, --z-
  { -0.5 , -0.5 , -0.566 , -0.37 , 0.13 , -0.433}, --z+
  { 0.37 , -0.5 , -0.566 , 0.5 , 0.13 , -0.433}, --z+
  { -0.5 , -0.5 , -1.5 , -0.37 , 0.13 , -1.37}, --z++
  { 0.37 , -0.5 , -1.5 , 0.5 , 0.13 , -1.37}, --z++

  { -0.5 , 0.13 , -1.5 , 0.5 , 0.25 , 0.5}, -- top
}

minetest.register_node("ward:placeholder", {
	description = "Why... Just why",
	drawtype = "glasslike",
	tiles = {"ward_blank.png"},
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {not_in_creative_inventory = 1},
  pointable = false,
  walkable = false,
})

local function get_ct_item(pos)
  obj = minetest.get_objects_inside_radius(vector.add(pos, TABLEITEMOFFSET), 0.01)
  if #obj and #obj < 1 or not obj then return end
  if obj[1]:get_luaentity() and obj[1]:get_luaentity()._is_ct_item then
    return obj[1]
  end
end

minetest.register_node("ward:merging_table", {
  description = "Merging Table",
  drawtype = "mesh",
  mesh = "ward_merging_table.obj",
  selection_box = {
    type = "fixed",
    fixed = nodebox,
  },
  collision_box = {
    type = "fixed",
    fixed = nodebox,
  },
  after_place_node = function(pos, placer, itemstack, pointed_thing)
    --local pos = pointed_thing.above
    local othernode = minetest.get_node(vector.add(pos, vector.new(0,0,-1)))
    if not othernode or othernode.name == "air" or othernode.name == "ignore" or minetest.registered_nodes[othernode.name].buildable_to then
      minetest.set_node(vector.add(pos, vector.new(0,0,-1)), {name="ward:placeholder"})
    else
      minetest.remove_node(pos)
      return itemstack
    end
  end,

  inventory_image = "ward_merging_table_inv.png",
  tiles = {"ward_merging_table.png"},
  on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
    local metadata = minetest.get_meta(pos)

    if metadata:get_string("firestick") ~= "" and not string.find(metadata:get_string("firestick"), "_burn") then
      if itemstack:get_name() == ward.items.fire_item.name then
        minetest.chat_send_all(ward.items.fire_item.name)
        metadata:set_string("firestick", metadata:get_string("firestick").."_burn")
        local stick = get_ct_item(pos)
        if stick then
          stick:get_luaentity()._on_fire = 1
        end
      end
    elseif metadata:get_string("firestick") == "" then
      local witem = clicker:get_wielded_item()
      if witem:get_name() == "ward:double_stick_diamond" then
        metadata:set_string("firestick", itemstack:get_name())
        itemstack:take_item()
        local obj = minetest.add_entity(vector.add(pos, TABLEITEMOFFSET), "ward:merging_table_item_entity")
        return itemstack
      end
    end
  end,
  after_dig_node = function(pos, oldnode, oldmetadata, digger)
    local item = oldmetadata.fields["firestick"]
    if item ~= "" then
      minetest.add_item(pos, ItemStack(item))
    end
  end,
  _mcl_hardness = 1.5,
  is_ground_content = true,
  groups = {choppy=1, oddly_breakable_by_hand=1, axey=1, tree=1, flammable=2, building_block=1, material_wood=1, fire_encouragement=5, fire_flammability=5},
})

minetest.register_on_dignode(function(pos, oldnode, digger) -- remove stick dug
  if oldnode.name ~= "ward:merging_table" then return end

  local stick = get_ct_item(pos)
  if stick then
    stick:remove()
  end
  minetest.remove_node(vector.add(pos, vector.new(0,0,-1)))
end)




minetest.register_entity("ward:merging_table_item_entity", {
	visual = "mesh",
	mesh = "ward_merging_table_item.obj",
	visual_size = {x = 10, y = 10},
  hp_max = 100,
	collisionbox = {-0.15, -0.75, -1.25, 0.15, -0.65, 0.25},
	selectionbox = {-0.15, -0.75, -1.25, 0.15, -0.65, 0.25},
	physical = false,
  _is_ct_item = true,
  textures = {
    minetest.registered_items["ward:double_stick_diamond"].inventory_image,
    "ward_blank.png",
  },
  --static_save = false,
  damage_texture_modifier = "",
  _angular_vel = 0,
  _on_fire = false,
  _timer = 0,
  _new_thing_timer = 0,
  on_activate = function(self)
    local meta = minetest.get_meta(vector.subtract(self.object:get_pos(), TABLEITEMOFFSET))

    local def_meta = minetest.registered_items[meta:get_string("firestick")]
    if def_meta then
      self.textures[1] = def_meta.inventory_image or def_meta.wield_image
    end
    if not self._on_fire then
      self.textures[2] = "ward_blank.png"
    else
      self.textures[2] = "firestick_3dburn."..self._on_fire..".png"
    end
    self.object:set_properties({textures=self.textures})
  end,
  on_rightclick=function(self, clicker)

  end,
  on_step = function(self, dtime, moveresult)
    local pos = self.object:get_pos()
    local meta = minetest.get_meta(vector.subtract(pos, TABLEITEMOFFSET))
    if self._on_fire ~= false then


      self._timer = self._timer+dtime
      if self._timer > 0.25 then
        self._new_thing_timer = self._new_thing_timer + 1
        if meta:get_string("firestick") == "ward:basic_wand_1" and self._new_thing_timer > 10 then
          self._new_thing_timer = 0
          meta:set_string("firestick", "ward:double_stick_reinforced_burnt")
        elseif meta:get_string("firestick") == "ward:double_stick_reinforced_burnt" and self._new_thing_timer > 4 then
          self._new_thing_timer = 0
          self._on_fire = false
          self.textures[2] = "ward_blank.png"
          self.object:set_properties({textures=self.textures})
          return
        elseif self._new_thing_timer > 18 then -- firestickify
          self._new_thing_timer = 0
          meta:set_string("firestick", "ward:basic_wand_1")
        end
        self._timer = 0
        self._on_fire = ((self._on_fire + 1)%5)+1
        local def_meta = minetest.registered_items[meta:get_string("firestick")]
        if def_meta then
          self.textures[1] = def_meta.inventory_image or def_meta.wield_image or "blank.png"
        end
        self.textures[2] = "firestick_3dburn."..self._on_fire..".png"
        self.object:set_properties({textures=self.textures})
      end
    end
  end,
  on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, direction, damage)
    local pos = self.object:get_pos()
    local meta = minetest.get_meta(vector.subtract(self.object:get_pos(), TABLEITEMOFFSET))

    local inv = puncher:get_inventory()
    local item = inv:add_item("main", ItemStack(meta:get_string("firestick")))
    self.object:remove()
    if tostring(item) ~= 'ItemStack("")' then
      --minetest.chat_send_all(tostring(item))

      local item = minetest.add_item(pos, item)
    end
    meta:set_string("firestick", "")
  end,
})
