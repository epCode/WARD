minetest.register_craftitem("ward:damage_stone", {
  description = ("A Stone of Damage"),
  inventory_image = "ward_stone_1.png^[screen:#550000^[contrast:100:-50",
  stack_max = 4,
  on_use = function(itemstack, user, pointed_thing)
    --ward_func.compatible_explode(user:get_pos())
  end
})
