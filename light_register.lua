local castable_class = "light"

ward_func.register_castable("praesidium", castable_class, 40, {{'left', 'aux1', 'up'}}, ward.alldescs["praesidium"], function(player, fire_stick)
  local fire_stick_power = minetest.get_item_group(fire_stick:get_name(), 'fire_stick_power')
  if player:get_meta():get_string("praesidium") ~= "" then
    return
  end
  local particles = ward_func.object_particlespawn_effect(player, {
    time = 20,
    amount = 9000,
    texture = {
      name = "ward_star.png^[colorize:#16b2ff:120",
      scale_tween = {4, 0.01},
      blend = "screen",
    },
  })
  player:get_meta():set_string("praesidium", minetest.serialize({particles, minetest.get_gametime()+2+(fire_stick_power/2)}))
end, 1)


ward_func.register_castable("regenero", castable_class, 30,
{
  {'left', 'down', 'right', 'left', 'down', 'right'},
}, ward.alldescs["regenero"],
function(player, fire_stick, pointed_thing)
  ward_func.send_blast(player, {castablename = "regenero",
    speed = 25,
    range = 35,
    color = "#00834a",
    fire_stick = fire_stick,
    on_hit_object = function(self, target)
      fire_stick_power = minetest.get_item_group(fire_stick:get_name(), "fire_stick_power")
      ward_func.add_persistant_effect({object = target, duration = fire_stick_power/3+1.5, persistance = 7/fire_stick_power, effect = function(target)
        target:set_hp(target:get_hp()+1)
        ward_func.object_particlespawn_effect(target, {
          amount = 30,
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
      end})
    end
  })
end)
