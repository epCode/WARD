minetest.register_craftitem("ward:damage_stone", {
  description = ("A Stone of Damage"),
  inventory_image = "ward_stone_1.png^[screen:#550000^[contrast:100:-50",
  stack_max = 4,
  on_use = function(itemstack, user, pointed_thing)
    --ward_func.compatible_explode(user:get_pos())
  end
})

--------------------------
-- Stick Crafting
--------------------------

minetest.register_craftitem("ward:double_stick", { -- base large stick
  description = ("Large Stick"),
  inventory_image = "ward_stick_double.png",
  stack_max = 32,
  wield_scale = {x = 2, y = 2, z = 2},
  groups = {ward_burnable = 1},
  on_use = function(itemstack, user, pointed_thing)
    if math.random(3) == 1 then
      itemstack:set_name("ward:double_stick_broke")
      return itemstack
    end
  end
})

minetest.register_craftitem("ward:double_stick_burnt", { -- the base stick burnt
  description = ("Large Burnt Stick"),
  groups = {not_in_creative_inventory=1},
  inventory_image = "ward_stick_double_burnt.png",
  stack_max = 32,
  wield_scale = {x = 2, y = 2, z = 2},
  on_use = function(itemstack, user, pointed_thing)
    if math.random(1) == 1 then
      itemstack:set_name("ward:double_stick_burnt_broke")
      return itemstack
    end
  end
})


minetest.register_craftitem("ward:double_stick_broke", { -- the large stick broken
  description = ("Large Broken Stick"),
  groups = {not_in_creative_inventory=1},
  inventory_image = "ward_stick_double_broke.png",
  stack_max = 32,
  wield_scale = {x = 2, y = 2, z = 2},
})

minetest.register_craftitem("ward:double_stick_burnt_broke", { -- the large stick burnt and broken
  description = ("Large Burnt and Broken Stick"),
  groups = {not_in_creative_inventory=1},
  inventory_image = "ward_stick_double_burnt_broke.png",
  stack_max = 12,
  wield_scale = {x = 2, y = 2, z = 2},
})


minetest.register_craftitem("ward:double_stick_reinforced", { -- the large stick after forged with steel
  description = ("Large Reinforced Stick"),
  inventory_image = "ward_double_stick_reinforced.png",
  groups = {ward_burnable = 1},
  stack_max = 1,
  wield_scale = {x = 2, y = 2, z = 2},
})

minetest.register_craftitem("ward:double_stick_reinforced_burning", { -- the large forged stick burning
  description = ("Large Burning Reinforced Stick"),
  groups = {not_in_creative_inventory=1},
  inventory_image = "ward_double_stick_reinforced_burning.png",
  groups = {ward_burning = 1},
  stack_max = 1,
  wield_scale = {x = 2, y = 2, z = 2},
})



minetest.register_craftitem("ward:double_stick_reinforced_burnt", { -- the large forged stick burnt
  description = ("Large Burnt Reinforced Stick"),
  groups = {not_in_creative_inventory=1},
  inventory_image = "ward_stick_double_burnt.png",
  stack_max = 1,
  wield_scale = {x = 2, y = 2, z = 2},
})

minetest.register_craftitem("ward:double_stick_diamond", { -- the large forged stick burnt
  description = ("Large Stick with a Diamond"),
  inventory_image = "ward_double_stick_diamond.png",
  stack_max = 1,
  wield_scale = {x = 2, y = 2, z = 2},
})



--------------------------
-- Gem Crafting
--------------------------

minetest.register_craftitem("ward:chisel", {
  description = ("A Chisel"),
  inventory_image = "ward_chisel.png",
  wield_scale = {x = 1.5, y = 1.5, z = 1.5},
})

for _,size in ipairs({"tiny", "small", "med"}) do
  minetest.register_craftitem("ward:diamond_chip_"..size, {
    description = ("A Tiny Diamond Chip"),
    inventory_image = "ward_diamond_chip_"..size..".png",
    wield_scale = {x = 2, y = 2, z = 2},
  })
  minetest.register_craftitem("ward:diamond_chip_rough_"..size, {
    description = ("A Tiny Diamond Chip"),
    inventory_image = "ward_diamond_chip_rough_"..size..".png",
    wield_scale = {x = 2, y = 2, z = 2},
  })
  minetest.register_craft({
  	type = "shapeless",
  	output = "ward:diamond_chip_"..size,
  	recipe = {"ward:diamond_chip_rough_"..size, "ward:chisel"},
  })
end

minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
	if string.find(itemstack:get_name(), "diamond_chip_") then
		for i, stack in pairs(old_craft_grid) do
			if stack:get_name() == "ward:chisel" then
				stack:add_wear(65535/34)
				craft_inv:set_stack("craft", i, stack)
				break
			end
		end
		if math.random(4) > 1 then
			itemstack:take_item()
			return itemstack
		end
	end
end)
