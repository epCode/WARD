ward.alldescs = {
  ["exarmare"] = {
    [==[This disarms a player (flings away thier wield item). Fail chance is 80%. This decreases with fire stick power.
    ]==],
    "▲ > ▲"
  },
  ["avolare"] = {
    [==[Launches target away while damaging them a small bit. It increases speed and damage with fire stick power.
    ]==],
    "Sneak > ▼ > ▲"
  },
  ["praesidium"] = {
    [==[Creates a temporary sh- ield around caster for blocking attacks. Fail and duration decreases with fire stick power.
    ]==],
    "◀ > Use > ▲"
  },
  ["adducere"] = {
    [==[Pulls the target towards the caster. Speed incr- eases with power. Pull can be broken by target if praesidium is cast.
    ]==],
    "Sneak > ▼ > ▼"
  },
  ["adducere_ferre"] = {
    [==[Carries the target in front of the caster. duration and speed. increase with power. tip:(RMB+LMB)
    ]==],
    "Sneak > ▼ > (◀ + ▶)"
  },
  ["tollere"] = {
    [==[Levitates target in the air. Can be broken by caster by defending with praesidium.
    ]==],
    "Sneak > Jump > (◀ + ▶)"
  },
  ["deprimere"] = {
    [==[Sends the target down to earth.. quickly.
    ]==],
    [==[ Sends multiple targetsdown quickly downwards.
    ]==],
    "Sneak > Aux"
  },
  ["igneum_carmen"] = {
    [==[Burns the target and sets them on fire. if  a node is hit, fire is created in increasing size with power.
    ]==],
    "(◀ + ▲ + ▶) > ▼ > Sneak"
  },
  ["lux"] = {
    [==[makes the fire stick a wielded light.
    ]==],
    "Use + Use"
  },
  ["delustro"] = {
    [==[removes the effects of all castables on the target
    ]==],
    "Sneak > ◀ > ▲ > ▶"
  },
  ["portarum"] = {
    [==[Gives the ability to jump to set teleport spots at a moments notice. Has a dedicated book.
    ]==],
    "▲ > ▶ > ▼ > ◀ > Aux1 > ▲"
  },
  ["occasu_portarum"] = {
    [==[Is paired with portarum. gives the ability to set teleport spots.
    ]==],
    "▲ > ▶ > ▼ > ◀ > Aux1 > Sneak"
  },
  ["obscurum"] = {
    [==[Creates smoke around the caster.
    ]==],
    "Sneak > ▼ > Sneak > ▲"
  },
  ["cogo"] = {
    [==[Pulls in all surrounding objects when the bolt hits the ground.
    ]==],
    "◀ > ▶ > ▼ > ▲"
  },
  ["luminum"] = {
    [==[Casts a bolt to place a torch from your inventory.
    ]==],
    "◀ > Use > ▶"
  },
  ["afflicto"] = {
    [==[Damages the target over a certain amount of time.
    ]==],
    "▲ > ▶ > Use > ◀"
  },
  ["regenero"] = {
    [==[Regenerates the targets health over a certain pertiod of time
    ]==],
    "◀ > ▼ > ▶ > ◀ > ▼ > ▶"
  },
  ["ignis_proiecto"] = {
    [==[Burns most projectiles within a certain raduis of caster.
    ]==],
    "◀ > ▼ > ▶ > ◀ > ▼ > ▶"
  },
}

dofile(minetest.get_modpath("ward").."/dark_register.lua")
dofile(minetest.get_modpath("ward").."/light_register.lua")
dofile(minetest.get_modpath("ward").."/neutral_register.lua")









minetest.register_on_dieplayer(function(player, reason)
  if reason.object and reason.object:is_player() then
    if math.random(6) == 1 then
      --minetest.add_item(vector.add(player:get_pos(), vector.new(0,1.3,0)), ItemStack("ward:damage_stone"))
      --minetest.chat_send_player(reason.object:get_player_name(), "Your anger towards the slain man conjures a "..minetest.colorize("#3333ff", "special").." object")
    end
  end
  player:get_meta():set_string("to_pos", "")
  ward_func.remove_protection(player)
  ward.affected_objects[player] = nil
end)







local function spawn_book_entity(pos, respawn) -- ripped from mcl2
	if respawn then
		-- Check if we already have a book
		local objs = minetest.get_objects_inside_radius(pos, 1)
		for o=1, #objs do
			local obj = objs[o]
			local lua = obj:get_luaentity()
			if lua and lua.name == "ward:learn_book_entity" then
				if lua._learnpoolpos and vector.equals(pos, lua._learnpoolpos) then
					return
				end
			end
		end
	end
	local obj = minetest.add_entity(vector.add(pos, vector.new(0,0,0)), "ward:learn_book_entity")
	if obj then
		local lua = obj:get_luaentity()
		if lua then
			lua._learnpoolpos = table.copy(pos)
		end
	end
end








local function place_castable_block(pos, v)
	minetest.set_node(pos, {name = "ward:learn_node"})
	local meta = minetest.get_meta(pos)

	meta:set_string("castable", v or ward.findable_castables[math.random(#ward.findable_castables)])
end




for k,v in pairs(ward.castables) do
  minetest.register_craftitem("ward:learnbook_"..v, {
    description = ("Book of Learn "..v),
    inventory_image = "ward_"..ward.castable_class[v][1].."_series_learnbook.png^ward_"..v.."_learnbook_ol.png",
    stack_max = 1,
    groups = { castabook=1, book=1 },
    on_place = function(itemstack, placer, pointed_thing)
      local node = minetest.get_node(pointed_thing.above)
      if node and node.name == "air" then
        place_castable_block(pointed_thing.above, v)
        spawn_book_entity(pointed_thing.above)
        local witem = placer:get_wielded_item()
        witem:take_item()
        placer:set_wielded_item(witem)
      end
    end,
    on_use = function(itemstack, user, pointed_thing)
      local not_learned = false
      if not ward_func.has_learned(user, v) then
        not_learned = true
      end
      if ward_func.learn(user, v) then
        if not_learned then
          minetest.chat_send_player(user:get_player_name(), "You learned "..minetest.colorize("#e9d700",v).."!")
        else
          minetest.chat_send_player(user:get_player_name(), "You have improved your use of "..minetest.colorize("#e9d700",v)..".")
        end
        ward_func.object_particlespawn_effect(user, {
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
        itemstack:take_item()
        return itemstack
      else
        minetest.chat_send_player(user:get_player_name(), "You already fully grasp full understanding of "..minetest.colorize("#e9d700",v)..".")
      end
    end
  })
end




minetest.register_node("ward:learn_node", {
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

minetest.register_abm({
	nodenames = {"ward:learn_node"},
	interval = 1,
	chance = 1,
	action = function(pos, node)
    if minetest.get_meta(pos):get_string("castable") == "" then return end
    local colorize = {light = "267b97", neutral = "8f9726", dark = "671900"}
    spawn_book_entity(pos, true)
    ward_func.object_particlespawn_effect(pos, {
      time = 1,
      minacc = vector.new(0,2,0),
      maxacc = vector.new(0,7,0),
      minvel = vector.new(0.1,0.1,0.1),
      maxvel = vector.new(-0.1,-0.1,-0.1),
      extra_posmin = vector.new(-0.1,0.1,-0.1),
      extra_posmax = vector.new(0.1,-1.3,0.1),

      amount = 50,
      minsize = 0.2,
      maxsize = 3,
      minexptime = 0.2,
      maxexptime = 0.5,
      glow = 14,
      texture = {
        name = "ward_star.png^[colorize:#"..colorize[ward.castable_class[minetest.get_meta(pos):get_string("castable")][1]]..":255^ward_star_core.png",
        alpha_tween = {1,0.1},
        scale_tween = {1, 0.01},
        blend = "screen",
      },
    })
	end
})
