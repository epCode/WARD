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

ward.forged_items = {}

minetest.register_craft({
  output = 'ward:chiping_table',
  recipe = {
    {ward.items.iron.name, "", ward.items.iron.name},
    {ward.items.wood.name, ward.items.wood.name, ward.items.wood.name},
    {ward.items.stick.name, "", ward.items.stick.name},
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


minetest.register_craft({
  output = 'ward:double_stick',
  recipe = {
    {ward.items.stick.name, ward.items.stick.name},
  },
})


function ward.register_forged_item(def)
  ward.forged_items[def.output] = def
end

function ward.get_forge_result(def)
  for k,v in pairs(ward.forged_items) do
    if v.recipe[1] == def.items[1] or v.recipe[1] == def.items[2] then
      if v.recipe[2] == def.items[1] or v.recipe[2] == def.items[2] then
        return {item = ItemStack(v.output), time = v.cooktime, double_heat = v.double_heat}
      end
    end
  end
  return {item = ItemStack(""), time = 0}
end



ward.register_forged_item({
	cooktime = 2,
	output = "ward:double_stick_burnt",
	recipe = {'ward:double_stick', ''}
})

ward.register_forged_item({
	cooktime = 25,
	output = "ward:double_stick_reinforced",
	recipe = {'ward:double_stick', ward.items.iron.name}
})
