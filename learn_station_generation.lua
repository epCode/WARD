
minetest.register_entity("ward:learn_book_entity", {
	initial_properties = {
		visual = "mesh",
		mesh = "ward_learn_book_entity.b3d",
		visual_size = {x = 4, y = 4},
		collisionbox = {-0.3, -0.1, -0.3, 0.3, 0.1, 0.3},
		--pointable = false,
		physical = false,
		textures = {"ward_book_entity.png"},
    static_save = false,
	},
	_learnpoolpos = nil,
	on_activate = function(self, staticdata)
		self.object:set_armor_groups({immortal = 1, fleshy = 0})
	end,
	on_step = function(self, dtime)
    if self._going then
      self.object:set_properties({automatic_rotate = self.object:get_properties().automatic_rotate+0.4})
      self.object:add_velocity(vector.new(0,0.000001+(self.object:get_velocity().y/3),0))
    else
      local selfpos = self.object:get_pos()
      local objs = minetest.get_objects_inside_radius(selfpos, 5)
      local closest_object = {nil, 10}
      for _,obj in ipairs(objs) do
        if not obj:is_player() then break end
        local dist = vector.distance(obj:get_pos(), selfpos)
        if not closest_object or dist < closest_object[2] then
          closest_object = {obj, dist}
        end
      end
      if closest_object[1] ~= nil then
        self.object:set_rotation(vector.new(0, minetest.dir_to_yaw(vector.direction(selfpos, closest_object[1]:get_pos())), 0))

      end
    end
	end,
  on_rightclick = function(self,clicker)
    if not clicker:is_player() then return end
    local castable_name = minetest.get_meta(self.object:get_pos()):get_string("castable")

    self.object:set_animation({x=1, y=10}, 20, 0, false)
    minetest.remove_node(self.object:get_pos())
    self._going = true
    if ward_func.has_learned(clicker, castable_name) then
      minetest.after(1, function()
        if self and self.object and self.object:get_velocity() then
          minetest.add_item(vector.add(self.object:get_pos(), vector.new(0,0,0)), ItemStack("ward:learnbook_"..castable_name))
          minetest.chat_send_player(clicker:get_player_name(), "You have found a book entitled "..minetest.colorize("#e9d700",castable_name)..".")
          self.object:remove()
          return
        end
      end)
    end
    minetest.after(2, function()
      if self and self.object and self.object:get_velocity() then
        self.object:remove()



        ward_func.object_particlespawn_effect(clicker, {
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
            name = "ward_star.png^[colorize:#e9d700:255^ward_star_core.png",
            scale_tween = {1.3, 0.1},
            blend = "screen",
          }
        })
        ward_func.learn(clicker, castable_name)
        minetest.chat_send_player(clicker:get_player_name(), "You learned the castable "..minetest.colorize("#e9d700",castable_name).."!")
      end
    end)
  end,
})

local function place_castable_block(pos)
	minetest.set_node(pos, {name = "ward:learn_node"})
	local meta = minetest.get_meta(pos)

	meta:set_string("castable", ward.special.findable_castables[math.random(#ward.special.findable_castables)])
end


minetest.register_on_generated(function(minp, maxp, blockseed)
  local random_place = blockseed%20


  if random_place == 1 then
    local area = vector.subtract(maxp, minp)
    local seededblock = {x=(blockseed%(math.abs(area.x)))+minp.x, y=minp.y, z=(blockseed%(math.abs(area.z)))+minp.z}
    local under_airs = minetest.find_nodes_in_area_under_air(seededblock, vector.new(seededblock.x, maxp.y, seededblock.z), {"group:cracky", "group:crumbly", "group:oddly_breakable_by_hand", "group:choppy", "group:snappy", "group:pickaxey", "group:handy", "group:shovely", "group:axey", "group:swordy"})
    if under_airs and #under_airs > 0 then
      local thepos = vector.add(under_airs[1], vector.new(0,1,0))
			if thepos.y < -10 then
				place_castable_block(thepos, "magyar_védelem")
			else
				place_castable_block(thepos)
			end
    end
  end
  --minetest.chat_send_all(tostring(blockseed))
end)
