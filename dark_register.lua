local castable_class = "dark"

ward_func.register_castable("afflicto", {castable_class, {"afflicto", 1}}, 30,
{
  {'up', 'right', 'aux1', 'left'},
}, ward.alldescs["afflicto"],
function(player, fire_stick, pointed_thing, sp)
  ward_func.send_blast(player, {castablename = "afflicto",
    speed = 25,
    range = 35,
    color = "#830000",
    fire_stick = fire_stick,
    on_hit_object = function(self, target)
      fire_stick_power = minetest.get_item_group(fire_stick:get_name(), "fire_stick_power")
      ward_func.add_persistant_effect({name = "afflicto", object = target, duration = (fire_stick_power/3+1.5), persistance = 7/fire_stick_power, effect = function(target)
        target:punch((self._shooter or self.object), 1.0, {
          full_punch_interval = 1.0,
          damage_groups = {fleshy = 1},
        })
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

ward_func.register_castable("deprimere", {castable_class, {"deprimere", 2}}, 15, {{'sneak', 'aux1'}}, ward.alldescs["deprimere"], function(player, fire_stick, pointed_thing, sp)
  local fire_stick_power = minetest.get_item_group(fire_stick:get_name(), 'fire_stick_power')
  ward_func.send_blast( player, {castablename = "deprimere", speed = 25, range = 35, color = "#be4d0a", fire_stick = fire_stick, on_hit_object = function(self, target)
    local targets = {target}
    if sp > 1 then
      for _,obj in ipairs(minetest.get_objects_inside_radius(self.object:get_pos(), 2.5*sp)) do
        table.insert(targets, obj)
      end
    end
    for _,targ in ipairs(targets) do
      ward_func.object_particlespawn_effect(targ, {
        amount = 100,
        time = 0.1,
        minsize = 2,
        maxsize = 4,
        minexptime = 0.2,
        maxexptime = 1,
        --minacc = go_dir,
        --maxacc = vector.multiply(go_dir, 0.7),
        minvel = vector.new(0,-2,0),
        maxvel = vector.new(0,-200,0),

        texture = {
          name = "ward_star.png^[colorize:"..self.hex_color..":210^ward_star_core.png",
          scale_tween = {1.3, 0.1},
          blend = "screen",
        }
      })
      targ:add_velocity(vector.new(0,-(fire_stick_power/2+10),0))
    end
  end})
end, 20)

if minetest.get_modpath("fire") or minetest.get_modpath("mcl_fire") then
  ward_func.register_castable("igneum_carmen", {castable_class, {"igneum_carmen", 1}}, 55,
    {
    {'up', 'left', 'right', 'down', 'sneak'},
    {'up', 'right', 'left', 'down', 'sneak'},
    {'right', 'left', 'up', 'down', 'sneak'},
    {'right', 'up', 'left', 'down', 'sneak'},
    {'left', 'up', 'right', 'down', 'sneak'},
    {'left', 'right', 'up', 'down', 'sneak'},
    }, ward.alldescs["igneum_carmen"],
    function(player, fire_stick, pointed_thing)
      local fire_stick_power = minetest.get_item_group(fire_stick:get_name(), 'fire_stick_power')

      local deff = {castablename = "igneum_carmen",
        speed = 25,
        range = 35,
        color = "#ff420f",
        fire_stick = fire_stick,
        on_hit_node = function(self, under, above)
          local mtb = minetest.get_modpath("fire")
          local fire_stick_power = minetest.get_item_group(fire_stick:get_name(), 'fire_stick_power')
          if fire_stick_power < 5 then
            if mtb then
              minetest.set_node(above, {name = "fire:basic_flame"})
            else
              minetest.set_node(above, {name = "mcl_fire:fire"})
            end
          else
            local nval = minetest.find_nodes_in_area_under_air(vector.add(under, vector.new(-fire_stick_power/3, -fire_stick_power/3, -fire_stick_power/3)), vector.add(under, vector.new(fire_stick_power/3, fire_stick_power/3, fire_stick_power/3)), {"group:cracky", "group:crumbly", "group:oddly_breakable_by_hand", "group:choppy", "group:snappy", "group:pickaxey", "group:handy", "group:shovely", "group:axey", "group:swordy"})
            for k,v in pairs(nval) do
              if math.random(5) < 3 and vector.distance(v, under) < fire_stick_power/3 then
                if mtb then
                  minetest.set_node(vector.add(v, vector.new(0,1,0)), {name = "fire:basic_flame"})
                else
                  minetest.set_node(vector.add(v, vector.new(0,1,0)), {name = "mcl_fire:fire"})
                end
              end
            end
          end
        end,
        on_hit_object = function(self, target)

          ward_func.object_particlespawn_effect(target, {
            time = 1*(fire_stick_power/2),
            minacc = vector.new(0,2,0),
            maxacc = vector.new(0,2,0),
            minvel = vector.new(0.2,1,0.2),
            maxvel = vector.new(-0.2,-0.2,-0.2),
            posize = 0.2,

            amount = 150*(fire_stick_power/2),
            minsize = 0,
            maxsize = 10,
            minexptime = 0.2,
            maxexptime = 3.2,
            glow = 0,
            texture = {
              name = "ward_smoke_anim.png^[colorize:#6a6a6a:255",
              alpha_tween = {0.7,0.1},
              scale_tween = {0.1, 2},
              animation = {
                type = "vertical_frames",
                aspect_w = 8,
                aspect_h = 8,
                length = 5,
              },
            }
          })
          ward_func.object_particlespawn_effect(target, {
            time = 1*(fire_stick_power/2),
            minacc = vector.new(0,1,0),
            maxacc = vector.new(0,4,0),
            minvel = vector.new(0.3,0.3,0.3),
            maxvel = vector.new(-0.3,-0.2,-0.3),

            amount = 100*(fire_stick_power/2*(fire_stick_power/2)),
            minsize = 3,
            maxsize = 5,
            minexptime = 0.2,
            maxexptime = 0.7,
            texture = {
              name = "ward_smoke_anim.png^[colorize:#e7d925:255",
              alpha_tween = {0.7,0.1},
              scale_tween = {0.4, 0.1},
              blend = "screen",
              animation = {
                type = "vertical_frames",
                aspect_w = 8,
                aspect_h = 8,
                length = 5,
              },
            }
          })
          ward_func.object_particlespawn_effect(target, {
            time = 1*(fire_stick_power/2),
            minacc = vector.new(0,1,0),
            maxacc = vector.new(0,4,0),
            minvel = vector.new(0.1,1,0.1),
            maxvel = vector.new(-0.1,-0.2,-0.1),

            amount = 30*(fire_stick_power/2),
            minsize = 3,
            maxsize = 7,
            minexptime = 0.2,
            maxexptime = 0.5,
            glow = 5,
            texture = {
              name = "ward_smoke_anim.png^[colorize:#e72525:255",
              alpha_tween = {0.7,0.1},
              scale_tween = {0.1, 2},
              blend = "screen",
              animation = {
                type = "vertical_frames",
                aspect_w = 8,
                aspect_h = 8,
                length = 5,
            },
            }
          })
          local fire_stick_power = minetest.get_item_group(fire_stick:get_name(), 'fire_stick_power')
          target:punch((self._shooter or self.object), 1.0, {
      			full_punch_interval = 1.0,
      			damage_groups = {fleshy = fire_stick_power},
      		}, self.object:get_velocity())
          if minetest.get_modpath("fire_plus") and target:is_player() then
            fire_plus.burn_player(target, fire_stick_power, 2)
            self.object:remove()
            return
          elseif minetest.get_modpath("mcl_burning") then
            mcl_burning.set_on_fire(target, fire_stick_power)
            self.object:remove()
            return
          end
          self.object:remove()
        end,
      }
      ward_func.send_blast(player, deff)
      deff.color = "#feff37"
      ward_func.send_blast(player, deff)
    end, 1)
end



ward_func.register_castable("obscurum", {castable_class, {"obscurum", 1}}, 25,
{
  {'sneak', 'down', 'sneak', 'up'},
}, ward.alldescs["obscurum"],
function(player, fire_stick, pointed_thing)
  ward_func.send_blast(player, {castablename = "obscurum",
    speed = 25,
    range = 25,
    color = "#111111",
    fire_stick = fire_stick,
    on_hit_object = function(self, target)
      local fire_stick_power = minetest.get_item_group(fire_stick:get_name(), 'fire_stick_power')
      local thedef = {
        posize = 5,
        time = fire_stick_power,
        minacc = vector.new(0,0,0),
        maxacc = vector.new(0,0,0),
        minvel = vector.new(0.01,0.01,0.01),
        maxvel = vector.new(-0.01,-0.01,-0.01),

        amount = 100*fire_stick_power,
        minsize = 3,
        maxsize = 7,
        minexptime = 0.2,
        maxexptime = 0.5,
        glow = 5,
        texture = {
          name = "ward_smoke_anim.png^[colorize:#8b8b8b:255",
          alpha_tween = {1,0.1},
          scale_tween = {6, 9},
          animation = {
            type = "vertical_frames",
            aspect_w = 8,
            aspect_h = 8,
            length = 5,
          },
        },
      }
      ward_func.object_particlespawn_effect(target,thedef)
      thedef.texture.name = "ward_smoke_anim.png^[colorize:#4a4a4a:255"
      ward_func.object_particlespawn_effect(target,thedef)
      thedef.texture.name = "ward_smoke_anim.png^[colorize:#5a5a5a:255"
      ward_func.object_particlespawn_effect(target,thedef)
    end})
end, 36)
