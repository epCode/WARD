

local function calculate_max_mana(player)
  if ward_func.get_all_player_castables(player) then
    return #ward_func.get_all_player_castables(player) * 3 + 25
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
  ward_mana.mana[player] = ward_mana.mana[player] or maxmana
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
      position = {x = 0.97, y = 0.80},
      scale = {x = 0, y = 0},
      z_index = 1,
    })
    ward_mana.hud[player][2] = player:hud_add({
      hud_elem_type = "image",
      text = "ward_ui_mana.png^[colorize:#111111:255",
      position = {x = 0.97, y = 0.81},
      scale = {x = 0, y = 0},
      z_index = 0,
    })
    ward_mana.hud[player][3] = player:hud_add({
      hud_elem_type = "text",
      text = "",
      position = {x = 0.97, y = 0.83},
      scale = {x = 3, y = 3},
      z_index = 3,
    })
    ward_mana.hud[player][4] = player:hud_add({
      hud_elem_type = "image",
      text = "ward_ui_mana.png",
      position = {x = 0.97, y = 0.85},
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

function ward_func.use_mana(player, amount, dont_use)
  ward_mana.mana[player] = ward_mana.mana[player] or 0
  if amount > ward_mana.mana[player] then
    return false
  else
    if not dont_use then
      ward_mana.mana[player] = ward_mana.mana[player] - amount
    end
    return true
  end
end
