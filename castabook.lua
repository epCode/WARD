ward_ui = {
  theselectedcastable = {},
  book_of_knowledge_page = {},
}

book_of_knowledge = {
  [==[
  In my day it had been said often by some
  queer elderly folks (a poem I imagine),
  'There in the world lay things of power,
  Where pools and mists the land devour,
  To learn; a journey you must begin
  To wield and hone till your last hour'

  This was the main portion of the rhyme,
  though the rest is unimportant to what
  I have to explain in this brief novel.
  I have done a great deal of exploration
  for your sake and mine, and in my travels
  I have discovered many curious things.
  First I will disclose that the old rhyme
  is (for the most part) truthful. I speak only
  of one thing in all of this, Magic.
  The 'Things of power' from the
  forementioned poem usually appear in the
  form of small polished and shaped switches
  of varying power and use. Once used by
  someone, it will forever be bound to him and]==],


  [==[
  will answer to no other. From these switches
  comes the most curious and amazing disco-
  very; when paired with the right spoken word
  or thought it can create supernatual effects
  unacheivable otherwise.

  After much searching I procured for myself
  one such of these things of power and studied
  it as thoroughly as possible. Thus I learned
  that it was almost entirely useless without the
  proper knowledge required to activate its
  abilities. However, this knowledge can be gain-
  ed through "books of castables", as I call them.
  if written to full detail you can easily learn
  these skills through the books. and the more
  you use these castables, the better you will
  get at using them, and you will be able to
  write the things you have learned for others to
  read and learn themselves.

  To use a castable, you must be carrying a]==],

  [==[
  thing of power and press the correct
  combonation of controls to activate the
  castable, once you do this you must wave
  it in the direction you wish the bolt, or
  whatever is produced to be cast.]==]
}

local function get_keys(t)
  local keyset={}
  local n=0
  for k,v in pairs(t) do
    n=n+1
    keyset[n]=k
  end
  return keyset
end

local function set_formspec(itemstack, user, pointed_thing, formextra)
  local meta = itemstack:get_meta()
  if meta:get_string("owner") == "" then
    meta:set_string("owner", user:get_player_name())
  end
  owner = meta:get_string("owner")
  local slist = ""

  if itemstack:get_meta():get_string("castables") ~= "" then
    local book_castables_table = minetest.deserialize(meta:get_string("castables"))
    local book_castables = {}
    if book_castables_table then
      book_castables = get_keys(book_castables_table)
    end
    if book_castables then
      print(minetest.serialize(book_castables))
      for i,k in ipairs(book_castables) do
        book_castables[i] = k:gsub("_", ' ')
      end
      slist = "textlist[0.5,1.5;7,7;castables;"..table.concat(book_castables,",")..";nil;true]"
    end
  end

	local formspec =
    "formspec_version[4]"..
    "size[8,13]"..

    "background[-0.5,-0;9,13;ward_bg.png]"..
    slist..

    "image[0.2,11.6;4.2,1.2;ward_black.png]"..
    "image_button[0.3,11.7;4,1;ward_button.png;add_castables;Write Knowledge]"..

    "image[4.7,11.6;3.2,1.2;ward_black.png]"..
    "vertlabel[7.7,1;"..owner.."]"..
    "image_button_exit[4.8,11.7;3,1;ward_button.png;close;Close]"..(formextra or "")
	minetest.show_formspec(user:get_player_name(), "ward:castabook", formspec)
end

local function item_in_list(list, item)
  local inlist = false
  for _,k in ipairs(list) do
    if k == item then
      inlist = true
    end
  end
  return inlist
end


minetest.register_on_player_receive_fields(function(player, formname, fields)
  if formname == "ward:castabook" then
    local witem = player:get_wielded_item()
    local book_castables_table = minetest.deserialize(witem:get_meta():get_string("castables"))
    local book_castables = {}
    if book_castables_table then
      book_castables = get_keys(book_castables_table)
    end
    if fields['castables'] and book_castables_table and book_castables and #book_castables > 0 then
      castable_index = fields['castables']:sub(5,-1)
      print(book_castables[tonumber(castable_index)])
      theselectedcastable = book_castables[tonumber(castable_index)]:gsub(" ", "_")
      local castabledescs = ""
      for _,vv in pairs(ward.castabledescs[theselectedcastable][1]) do
        castabledescs = castabledescs..vv.."\n"
      end
      local learn_button = ""
      if not ward_func.has_learned(player, theselectedcastable) then
        learn_button = "image_button_exit[0.7,10.55;2.4,0.75;ward_button.png;learn_button;Learn]"
      end

      set_formspec(player:get_wielded_item(), player, nil,
      "image[0.5,8.7;2.8,2.8;ward_"..theselectedcastable..".png]"..
      "label[3.5,9;"..castabledescs.."]"..
      "label[0.5,0.35;"..ward.castabledescs[theselectedcastable][2].."]"..
      "image[0.6,0.7;6.85,0.8;ward_black.png]"..
      "image_button[0.3,11.7;4,1;ward_button.png;add_castables;Write Knowledge]"..
      "image[0.7,0.8;"..tostring(book_castables_table[theselectedcastable]*0.3325)..",0.6;ward_black.png^[colorize:#35ff37:190]"..
      learn_button
      )
      ward_ui.theselectedcastable[player:get_player_name()] = theselectedcastable
    elseif fields['add_castables'] then
      if book_castables_table == nil then
        book_castables_table = {}
      end
      player_vocab = player:get_meta():get_string("castables")
      if player_vocab ~= '' then
        for i,k in ipairs(minetest.deserialize(player_vocab)) do
          if not book_castables_table[k] then
            book_castables_table[k] = 1
          elseif book_castables_table[k] < 20 then
            book_castables_table[k] = book_castables_table[k] + 1
          end
        end
        witem:get_meta():set_string("castables", minetest.serialize(book_castables_table))
        player:set_wielded_item(witem)
        set_formspec(witem, player, nil)
      end
    elseif fields["learn_button"] and ward_ui.theselectedcastable[player:get_player_name()] then
      ward_func.learn(player, ward_ui.theselectedcastable[player:get_player_name()])
    end
  end
end)

minetest.register_craftitem("ward:castabook", {
	description = ("Book of Castables"),
	inventory_image = "default_book.png",
	stack_max = 1,
	groups = { castabook=1, book=1 },
	_mcl_enchanting_enchanted_tool = "mcl_enchanting:book_enchanted",
  on_use = set_formspec,
})

local function show_lorebook(itemstack, player, pointed_thing)
  local formspec =
    "formspec_version[4]"..
    "size[9,13]"..

    "background[-0.5,-0;10,13;ward_bg_paper.png]"..
    "label[0.2,1;"..minetest.formspec_escape(minetest.colorize("#333333", book_of_knowledge[ward_ui.book_of_knowledge_page[player] or 1])).."]"..
    "label[4,0.4;"..minetest.formspec_escape(minetest.colorize("#333333", tostring(ward_ui.book_of_knowledge_page[player] or 1))).."]"..
    "image_button[2,11.7;2,1;ward_button_left.png;page_left;]"..
    "image_button[4,11.7;2,1;ward_button_right.png;page_right;]"


	minetest.show_formspec(player:get_player_name(), "ward:lorebook", formspec)
end


minetest.register_on_player_receive_fields(function(player, formname, fields)
  if formname == "ward:lorebook" then
    if not ward_ui.book_of_knowledge_page[player] then
      ward_ui.book_of_knowledge_page[player] = 1
    end
    if fields['page_left'] and ward_ui.book_of_knowledge_page[player] > 1 then
      ward_ui.book_of_knowledge_page[player] = ward_ui.book_of_knowledge_page[player]-1
      show_lorebook(nil, player)
    elseif fields['page_right'] and ward_ui.book_of_knowledge_page[player] < #book_of_knowledge then
      ward_ui.book_of_knowledge_page[player] = ward_ui.book_of_knowledge_page[player]+1
      show_lorebook(nil, player)
    end
  end
end)

minetest.register_craftitem("ward:lorebook", {
	description = ("Book of Lore"),
	inventory_image = "default_book.png",
	stack_max = 1,
	groups = { castabook=1, book=1 },
	_mcl_enchanting_enchanted_tool = "mcl_enchanting:book_enchanted",
  on_use = show_lorebook,
})
