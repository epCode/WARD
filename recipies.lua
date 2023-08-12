--[[
praesidium,
regenero,
ignis_proiecto,
ascensio,
deprimere,
igneum_carmen,
obscurum,
exarmare,
avolare,
adducere,
adducere_ferre,
lux,
delustro,
portarum,
occasu_portarum,
cogo,
luminum
]]

local items = {
  fire_item = minetest.registered_items["fire:flint_and_steel"],
  stick = minetest.registered_items["default:stick"],
}

local descs = {

}


items.fire_item =
  minetest.registered_items["fire:flint_and_steel"] or
  minetest.registered_items["mcl_fire:fire_charge"] or
  minetest.registered_items["bucket:bucket_lava"] or
  items.fire_item


items.stick =
  minetest.registered_items["default:stick"] or
  minetest.registered_items["mcl_core:stick"] or
  items.stick


minetest.register_craft({
  output = 'ward:basic_wand_1',
  recipe = {
    {'', items.fire_item.name, ''},
    {items.fire_item.name, items.stick.name, items.fire_item.name},
    {items.fire_item.name, items.stick.name, items.fire_item.name}
  },
})

minetest.register_craft({
  output = 'ward:learnbook_igneum_carmen',
  recipe = {
    {'ward:basic_wand_8', 'ward:learnbook_luminum', 'ward:learnbook_afflicto'},
  },
})

minetest.register_craft({
  output = 'ward:learnbook_afflicto',
  recipe = {
    {'ward:learnbook_deprimere', 'ward:learnbook_exarmare', 'ward:damage_stone'},
  },
})
