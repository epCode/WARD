

local function calculate_max_mana(player)
  if minetest.deserialize(player:get_meta():get_string("castables")) then
    return #minetest.deserialize(player:get_meta():get_string("castables")) * 3 + 25
  else
    return 0
  end
end

function ward_func.remove_mana_hud(player)
  for k,v in ipairs(ward_mana.hud[player]) do
    player:hud_remove(v)
  end
end

function ward_func.set_mana(player, amount)
  local maxmana = calculate_max_mana(player)
  ward_mana.mana[player] = ward_mana.mana[player] or 0
  if ward_mana.mana[player] < maxmana then
    ward_mana.mana[player] = ward_mana.mana[player] + 0.1
    if ward_mana.mana[player] > maxmana then
      ward_mana.mana[player] = maxmana
    end
  end
  if ward_mana.hud[player] and ward_mana.mana[player] then
    player:hud_change(ward_mana.hud[player][1], "scale", {x = 3, y = amount})
    player:hud_change(ward_mana.hud[player][2], "scale", {x = 4.5, y = maxmana+3})
    player:hud_change(ward_mana.hud[player][3], "text", math.floor(ward_mana.mana[player]+0.5))
  else
    ward_mana.hud[player] = {}
    ward_mana.hud[player][1] = player:hud_add({
      hud_elem_type = "image",
      text = "ward_ui_mana.png",
      position = {x = 0.97, y = 0.85},
      scale = {x = 0, y = 0},
      z_index = 1,
    })
    ward_mana.hud[player][2] = player:hud_add({
      hud_elem_type = "image",
      text = "ward_ui_mana.png^[colorize:#111111:255",
      position = {x = 0.97, y = 0.86},
      scale = {x = 0, y = 0},
      z_index = 0,
    })
    ward_mana.hud[player][3] = player:hud_add({
      hud_elem_type = "text",
      text = "",
      position = {x = 0.97, y = 0.88},
      scale = {x = 3, y = 3},
      z_index = 3,
    })
    ward_mana.hud[player][4] = player:hud_add({
      hud_elem_type = "image",
      text = "ward_ui_mana.png",
      position = {x = 0.97, y = 0.9},
      scale = {x = 7, y = 7.5},
      z_index = 2,
    })

  end
end

minetest.register_globalstep(function(dtime)
  for _,player in pairs(minetest.get_connected_players()) do
    ward_func.set_mana(player, ward_mana.mana[player])
  end
end)

function ward_func.use_mana(player, amount)
  ward_mana.mana[player] = ward_mana.mana[player] or 0
  if amount > ward_mana.mana[player] then
    return false
  else
    ward_mana.mana[player] = ward_mana.mana[player] - amount
    return true
  end
end
