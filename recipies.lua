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
