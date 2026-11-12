-- ZenVCExport: the helper add-on that comes with VCF (Voice Commander Forever), by TheZenaxa. Copyright (c) TheZenaxa, all rights reserved.
-- Its code is plain text, viewable by anyone, as Blizzard's add-on policy asks (viewable is not permission to copy it).
-- What it does:
-- * writes this character's spellbook, items and key bindings into WoW's saved-variables file
--   (WTF\Account\...\SavedVariables\ZenVCExport.lua) so the voice commander can read them. WoW writes that file when you
--   reload or log out. Type /zenvc to see what it saved.
-- * gives voice commands their own keys through override bindings: your saved key bindings never change.
-- * when you ask by voice: outlines items in bags and windows and shows their tooltips, uses or destroys an item after you
--   confirm, gives a mail or Auction House box the keyboard for dictation, and moves and sizes pieces of the screen in the
--   game's Edit Mode layouts (LIMITED EDITING: place and size only).
-- * when you say read quest: reads the open quest, what someone says, or the quest picked in your quest log aloud,
--   with WoW's own text-to-speech.
-- * widens the interact range while you fish and puts it back afterward.
-- It cannot send anything off your PC: a WoW add-on has no way to.

ZenVCExportDB = ZenVCExportDB or {}

-- Bump this whenever the addon gains a feature. The voice commander shows it, so you can tell at a glance
-- whether a character's saved data came from the current addon or an older one.
-- v28 _casts is one timeline: each hidden press and every spell event of the player, with the seconds after the last press (so a cast from the person's own button can be told from one made by the key) | v27 each press also records what kind of button it hit (_clicks type/action/spell/macro) | v26 the player's own spell-cast events in the 4 seconds after a hidden button press are kept in _casts | v25 diagnostics: every press of a hidden button is counted and the last red messages the game showed are kept in the saved file (_clicks, _errors) | v24 an ability that sits on a bar but is not in the spellbook list (a profession ability such as Fishing) is pressed from the bar button that holds it instead of cast by name, and the saved file records what the game says about each (probe) | v23 pet abilities are also read from the pet's own action bar, and the saved file records what the game says about pets | v22 the PET spellbook is read too (hunter and warlock pet abilities such as Growl, Dust Cloud, Firebolt), remembered per character, so they get voice commands | v21 /reload runs from a plain button that calls the game's own ReloadUI (a secure macro button does not run it); the record of blocked actions is capped | v20 passes each character's own unique game ID, so a NEW character that reuses an old name is told apart | v19 the game shows this add-on as "VCF Helper" (folder and saved data keep the name ZenVCExport) | v18 emotes use a plain button that calls the game's own emote function (secure buttons ran spells but not emotes); /zenvc click and /zenvc keys help find faults | v17 no question box for the hidden keys (the game blocked an add-on box in controller mode): the voice commander asks, and tells this add-on through ZenVCCommands.lua | v16 hidden-key feature: override bindings (nothing in your saved key bindings changes), records and switches itself off if the game blocks anything | v15 hidden command buttons: emotes and /cast get their own key, so the chat box (and the controller Say: box) never opens | v14 in-game click-to-confirm box offers to place unplaced spells (no typing needed) | v13 /zenvc interact gives Interact With Target (looting, talking) a key | v12 choose ranks per character and spell: /zenvc ranks, /zenvc rank Moonfire 1 max (lower rank is named "Moonfire 1") | v11 placed spells follow your highest known rank automatically (a slot you changed yourself is left alone) | v10 only the highest rank of a spell is placed | v9 keys use WoW's own modifier order ALT-CTRL-SHIFT, and /zenvc fixkeys repairs ones placed in the wrong order | v8 one bad slot no longer stops the 400-slot scan; spells only on controller pages still get a key | v7 scan of all slots 1-400 | v7 /zenvc bars places spells that are on no bar with Ctrl+Alt+Shift keys (and /zenvc undo) | v6 no logout save + never overwrite good bars with empty | v5 action bars read from the button frames and every slot 1-180 | v4 action bar diagnostics | v1 spells + key bindings | v2 + spell-book fallback | v3 + action bars (spells, items, macros and their keys)
-- v42 a plain "/use Item" button no longer runs as a macro (the first real test, Hearthstone, pressed twice and did nothing): it presses the bar slot that holds the item, or else uses the item itself (type "item")
-- v43 "/zvbind ACTION" entries: a game action (Quest Log, Find Foe ...) that has no key of yours gets the voice key bound straight to that action (override binding,
-- your saved bindings untouched). No button is made for them.
-- v44 THE SILENT SECURE BUTTONS: every secure hidden button (/cast, /use, macros) was registered for key-UP clicks only. The game runs a secure action button on the
-- key DOWN when its setting ActionButtonUseKeyDown is on (the default), so the click arrived, PostClick logged the press, and the action itself never ran: no cast, no error.
-- That matches every silent failure (Keggar's combat spells, Rockbiter, Fishing, Hearthstone). Secure buttons now take both; the game itself runs only the matching one.
-- Buttons with their own plain Lua click (emotes, reload, quest, back) stay key-up only, so they still run once.
-- v45 SELECT (the controller's A in an NPC window): a gossip window chooses the line the controller has highlighted (else the first line, which is where the
-- controller starts); a quest window does what the quest button does (accept, continue, complete); a yes/no box says yes. What it saw is written to _select.
-- v46 MOVE / BUY / SELL JUNK / REPAIR ALL: VCF's own marker in an NPC talk window and at a vendor ("move up/down/left/right" moves it, the line or item is
-- lit and named in chat), "select" or "buy" acts on it; "sell junk" sells every grey item, "repair all" repairs. Plain Lua buttons, nothing secure.
-- v47 the marker is a bright outline around the whole item or line (the button's own highlight was too faint to see), and the vendor item's real name is read
-- (GetMerchantItemInfo gave "?" in this game; C_MerchantFrame.GetItemInfo or the name on the item is used)
-- v48 YOUR BAGS: "switch side" moves VCF's outline between the vendor and your bags; in the bags "move ..." walks the slots as they sit on screen and chat names
-- each item; "sell that" (or "select") sells the outlined bag item, only while a vendor is open (outside a vendor that would use or equip it, so it never does).
-- v49 NO ALT + F4, EVER: Windows closes the game on any Alt + F4 (Alt+Shift+F4 shut it on 2026-10-20). The bar key set that used Alt+Ctrl+Shift+F4 now uses
-- Alt+Ctrl+Shift+Insert for that slot, and an Alt+F4 key this add-on bound earlier is taken off at login.
-- v50 the per-character lists (ZENVC_CHAR_BUTTONS, ZENVC_AUTOPLACE) are keyed by the character's unique ID (UnitGUID); the name is only a fallback for an older list
-- v51 (stress test, 2026-10-21) "switch side" OPENED the bags itself when they were closed (OpenAllBags). In controller mode the game forbids an add-on
-- from opening them: every controller move inside those bags then raised the "blocked" box (SetPreferredGamepadInteractTarget), and the guard switched
-- EVERY hidden key off. Now "switch side" never opens bags (it asks you to), and the guard only switches the keys off for a block that is not that one.
-- Interact by voice worked as it was (talk, loot), so it is unchanged. A new version number also clears the old "switched off".
-- v52 (2026-11-05) READ ONLY: records the game's Interact settings (names with "interact" or "softtarget", value and default) in db.interactSettings,
-- to learn which one is the Options tickbox that binds Interact to a key. Changes nothing in the game.
-- Also (read only) the spellbook section of every spell (db.spellSections) and the learned talents (db.talents), so VCF can group spells the way the game does.
-- v53 (2026-11-05) the Interact settings list came back EMPTY in v52 (one failed read stopped it all): each read is now on its own, and a note says how it went.
-- Also (read only) db.itemUses: each bar item with the spell it casts when used ("Food", "Drink", "Refreshment") and its type, for "eat ..." / "drink ..." words.
-- v54 (2026-11-05) READ ONLY: db.passives, the spellbook entries the GAME marks passive (IsSpellBookItemPassive / IsPassiveSpell / isPassive). VCF gives them no key.
-- v55 (2026-11-05, ALPHA TESTING) cast profession abilities (Fishing, Cooking, Basic Campfire, First Aid, Smelting, crafting windows) are found by spell number
-- and offered by /zenvc bars like spells; READ ONLY db.professionSpells, db.professions, db.skillLines (to learn how camp abilities are offered).
-- v56 (2026-11-05) READ ONLY db.bagItems: every usable or wearable item the character carries (bags + equipped), for RENAME AN ITEM in VCF.
local VERSION = "124"

-- ------------------------------------------------------------------------------------------------------------------
-- Ranks. The game casts the rank that is on the button. Default: the HIGHEST rank you know. Per character and per spell
-- you can ask for lower ranks too:  /zenvc ranks   and   /zenvc rank Moonfire 1 max
-- ------------------------------------------------------------------------------------------------------------------
local function charKey() return (UnitName("player") or "?") .. "-" .. (GetRealmName and GetRealmName() or "") end
local petBarRows   -- v41 filled in further down; DECLARED HERE so the export code above it can see it (declared later, it was a different, empty variable and the pet bar always came out empty)

local function rankOf(id)
    local ok, sub = pcall(function() return C_Spell and C_Spell.GetSpellSubtext and C_Spell.GetSpellSubtext(id) end)
    if ok and sub then
        local n = sub:match("(%d+)")
        if n then return tonumber(n) end
    end
    return nil
end

-- every castable spell you know, all ranks: name -> { best = id of the highest rank, ranks = { {rank=, id=}, ... } }
-- v55 the spell numbers (every rank) of the profession abilities that are CAST: Fishing, Cooking, Basic Campfire, First Aid, Smelting, Find Minerals, Find Herbs,
-- Disenchant and the crafting windows. Gathering by Interact (Mining a node, Skinning, Herbalism) is not here: VCF presses the Interact key for those.
local PROFESSION_SPELLS = {
    7620, 7731, 7732, 18248,             -- Fishing
    2550, 3102, 3413, 18260, 818,        -- Cooking, Basic Campfire
    3273, 3274, 7924, 10846,             -- First Aid
    2656, 2580, 2383, 13262,             -- Smelting, Find Minerals, Find Herbs, Disenchant
    2259, 3101, 3464, 11611,             -- Alchemy
    2018, 3100, 3538, 9785,              -- Blacksmithing
    7411, 7412, 7413, 13920,             -- Enchanting
    4036, 4037, 4038, 12656,             -- Engineering
    2108, 3104, 3811, 10662,             -- Leatherworking
    3908, 3909, 3910, 12180,             -- Tailoring
}

local function knownSpells()
    local out = {}
    pcall(function()
        local bank = Enum.SpellBookSpellBank.Player
        for line = 1, C_SpellBook.GetNumSpellBookSkillLines() do
            local info = C_SpellBook.GetSpellBookSkillLineInfo(line)
            if info then
                for i = info.itemIndexOffset + 1, info.itemIndexOffset + info.numSpellBookItems do
                    local item = C_SpellBook.GetSpellBookItemInfo(i, bank)
                    local passive = C_SpellBook.IsSpellBookItemPassive and C_SpellBook.IsSpellBookItemPassive(i, bank)
                    local lowRank = C_SpellBook.IsSpellBookItemLowRank and C_SpellBook.IsSpellBookItemLowRank(i, bank)
                    if item and item.spellID and item.name and not passive and not item.isOffSpec
                       and (item.itemType == nil or item.itemType == Enum.SpellBookItemType.Spell) then
                        local e = out[item.name]
                        if not e then e = { best = 0, ranks = {} } out[item.name] = e end
                        local dup = false
                        for _, r in ipairs(e.ranks) do if r.id == item.spellID then dup = true end end
                        if not dup then e.ranks[#e.ranks + 1] = { rank = rankOf(item.spellID), id = item.spellID, low = lowRank and true or false } end
                        if not lowRank and item.spellID > e.best then e.best = item.spellID end
                    end
                end
            end
        end
    end)
    -- v55 (2026-11-05, ALPHA TESTING) profession abilities that are cast, not "Interact" (Fishing, Cooking, First Aid, Basic Campfire, Smelting, the crafting windows ...).
    -- They are not in the spellbook list the game gives an add-on (the beta save showed Fishing 7731, Cooking 3102, First Aid 3274 on controller pages with no key),
    -- so they are found by their spell numbers: the game says which ones this character knows. Then /zenvc bars can offer them a bar slot with a key like any spell.
    pcall(function()
        for _, id in ipairs(PROFESSION_SPELLS) do
            local known = (IsPlayerSpell and IsPlayerSpell(id)) or (IsSpellKnown and IsSpellKnown(id))
            local name = known and ((C_Spell and C_Spell.GetSpellName and C_Spell.GetSpellName(id)) or (GetSpellInfo and (GetSpellInfo(id))))
            if name and name ~= "" then
                local e = out[name]
                if not e then e = { best = 0, ranks = {}, profession = true } out[name] = e end
                local dup = false
                for _, r in ipairs(e.ranks) do if r.id == id then dup = true end end
                if not dup then e.ranks[#e.ranks + 1] = { rank = rankOf(id), id = id, low = false } end
                if id > e.best then e.best = id end
            end
        end
    end)
    for _, e in pairs(out) do   -- if nothing was flagged as the top rank, take the highest id
        if e.best == 0 then for _, r in ipairs(e.ranks) do if r.id > e.best then e.best = r.id end end end
        table.sort(e.ranks, function(x, y) return (x.rank or 99) < (y.rank or 99) end)
    end
    return out
end

local function bestRanks()
    local b = {}
    for n, e in pairs(knownSpells()) do b[n] = e.best end
    return b
end

local function getPref(spellName)
    local p = ZenVCExportDB._prefs and ZenVCExportDB._prefs[charKey()]
    return (p and p[spellName]) or { "max" }
end



-- ------------------------------------------------------------------------------------------------------------------
-- Hidden command buttons (v15). Typing a slash command through the chat box opens the box (the "Say:" box in controller
-- mode). A hidden secure button runs the slash command itself and a key is bound to that button, so nothing opens.
-- The list comes from ZenVCCommands.lua (written by the voice commander): ZENVC_BUTTONS = { {id=, text=, key=}, ... }
-- ------------------------------------------------------------------------------------------------------------------
-- v30 buttons only ONE character gets (its spells, pet spells, items) come from ZENVC_CHAR_BUTTONS[name]; the player gets those plus the shared list.
-- Only one character is ever in the game, so two characters may use the same key. Without ZENVC_CHAR_BUTTONS this is exactly the old shared list.
local effCache
local function effectiveButtons()
    local name = UnitName and UnitName("player") or nil
    if effCache and effCache.name == name then return effCache.list end
    local list = {}
    local gid = UnitGUID and UnitGUID("player") or nil
    -- v113 (2026-11-10 KEY CLEANUP): a shared command this character freed is not bound for it, so its key can serve this character's own commands
    local skip = ZENVC_CHAR_SKIP and ((gid and ZENVC_CHAR_SKIP[gid]) or (name and ZENVC_CHAR_SKIP[name]))
    for _, b in ipairs(ZENVC_BUTTONS or {}) do if not (skip and b.text and skip[b.text]) then list[#list + 1] = b end end
    local mine = ZENVC_CHAR_BUTTONS and ((gid and ZENVC_CHAR_BUTTONS[gid]) or (name and ZENVC_CHAR_BUTTONS[name]))
    if mine then for _, b in ipairs(mine) do list[#list + 1] = b end end
    if name and name ~= "Unknown" then effCache = { name = name, list = list } end
    return list
end
local BTN_PREFIX = "ZenVCBtn_"
local function clickAction(id) return "CLICK " .. BTN_PREFIX .. id .. ":LeftButton" end
-- v43 the game action a "/zvbind ACTION" entry binds its key to, or nil for an ordinary hidden button
local function bindAction(b) return b and b.text and b.text:match("^/zvbind%s+([%w_]+)%s*$") end

-- what the game says about each button right now, for the voice commander to read: is its key really bound to it?
local function buttonStatus()
    local out = {}
    for _, b in ipairs(effectiveButtons()) do
        if b.id and b.text then
            local bound = false
            if b.key and b.key ~= "" and GetBindingAction then bound = (GetBindingAction(b.key, true) == (bindAction(b) or clickAction(b.id))) end
            out[#out + 1] = { b.id, b.text, b.key or "", bound and "yes" or "no" }
        end
    end
    return out
end

local function collect()
    local db = {}
    db.name = UnitName("player")
    db.keyDownSetting = GetCVar and tostring(GetCVar("ActionButtonUseKeyDown")) or "?"   -- v44 evidence: on = secure buttons run on key down
    db.realm = GetRealmName and GetRealmName() or ""
    local _, class = UnitClass("player")
    db.class = class
    local _, race = UnitRace("player")
    db.race = race
    db.exportedAt = date("%Y-%m-%d %H:%M")
    db.guid = (UnitGUID and UnitGUID("player")) or ""   -- unique per character, never reused, even when a name is
    db.addonVersion = VERSION
    db.build = select(1, GetBuildInfo())

    -- spellbook: every spell this character really knows (old and new client APIs, whichever exists)
    db.spells = {}
    -- v52: which section (spellbook tab) of the game's own spellbook each spell sits in, so the voice commander groups them the way the game does
    db.spellSections = {}
    local seen = {}
    local sectionOf = {}
    -- v54 READ ONLY: the spells the game itself marks PASSIVE (always on, nothing to press). VCF gives them no key. Asked of the game for every
    -- spellbook entry, in both ways a client may offer; one failed question never stops the list.
    db.passives = {}
    local passiveSeen = {}
    local function markPassive(n, isPassive)
        if n and n ~= "" and isPassive and not passiveSeen[n] then
            passiveSeen[n] = true
            db.passives[#db.passives + 1] = n
        end
    end
    local function add(n, section)
        if n and n ~= "" and not seen[n] then
            seen[n] = true
            db.spells[#db.spells + 1] = n
        end
        if n and n ~= "" and section and section ~= "" and not sectionOf[n] then
            sectionOf[n] = section
            db.spellSections[#db.spellSections + 1] = { n, section }
        end
    end
    pcall(function()
        if GetNumSpellTabs and GetSpellTabInfo and (GetSpellBookItemName or GetSpellName) then
            for tab = 1, GetNumSpellTabs() do
                local tabName, _, offset, count = GetSpellTabInfo(tab)
                for i = offset + 1, offset + count do
                    local n
                    if GetSpellBookItemName then n = GetSpellBookItemName(i, "spell") else n = GetSpellName(i, "spell") end
                    add(n, tabName)
                    pcall(function() if IsPassiveSpell then markPassive(n, IsPassiveSpell(i, "spell")) end end)
                end
            end
        end
    end)
    pcall(function()
        if C_SpellBook and C_SpellBook.GetNumSpellBookSkillLines then
            for line = 1, C_SpellBook.GetNumSpellBookSkillLines() do
                local info = C_SpellBook.GetSpellBookSkillLineInfo(line)
                if info then
                    for i = info.itemIndexOffset + 1, info.itemIndexOffset + info.numSpellBookItems do
                        local item = C_SpellBook.GetSpellBookItemInfo(i, Enum.SpellBookSpellBank.Player)
                        add(item and item.name, info.name)
                        pcall(function()
                            if item and C_SpellBook.IsSpellBookItemPassive then markPassive(item.name, C_SpellBook.IsSpellBookItemPassive(i, Enum.SpellBookSpellBank.Player)) end
                        end)
                        pcall(function() if item and item.isPassive ~= nil then markPassive(item.name, item.isPassive) end end)
                    end
                end
            end
        end
    end)
    -- v52 READ ONLY: the talents this character has learned (any rank), so spells that come from a talent can sit in their own Talents section
    db.talents = {}
    pcall(function()
        if GetNumTalentTabs and GetNumTalents and GetTalentInfo then
            for t = 1, (GetNumTalentTabs() or 0) do
                for i = 1, (GetNumTalents(t) or 0) do
                    local name, _, _, _, rank = GetTalentInfo(t, i)
                    if name and name ~= "" and (tonumber(rank) or 0) > 0 then db.talents[#db.talents + 1] = name end
                end
            end
        end
    end)

    -- v22 pet abilities (a hunter pet's Growl or Dust Cloud, a warlock pet's Firebolt or Torment) are in the PET spellbook, and
    -- that book only has anything in it while the pet is out. Every one seen is remembered for this character (by its own
    -- game ID), so a save made while the pet is away still lists them.
    pcall(function()
        ZenVCExportDB._pets = ZenVCExportDB._pets or {}
        local pk = (UnitGUID and UnitGUID("player")) or charKey()
        local mem = ZenVCExportDB._pets[pk]
        if type(mem) ~= "table" then mem = {}; ZenVCExportDB._pets[pk] = mem end
        pcall(function()
            local bank = Enum and Enum.SpellBookSpellBank and Enum.SpellBookSpellBank.Pet
            local count = 0
            if C_SpellBook and C_SpellBook.HasPetSpells then count = C_SpellBook.HasPetSpells() or 0
            elseif HasPetSpells then count = HasPetSpells() or 0 end
            for i = 1, count do
                local name, isSpell, passive
                if C_SpellBook and C_SpellBook.GetSpellBookItemInfo and bank then
                    local item = C_SpellBook.GetSpellBookItemInfo(i, bank)
                    if item then
                        name = item.name
                        isSpell = (item.itemType == nil or item.itemType == Enum.SpellBookItemType.Spell)   -- not Attack / Follow / Stay
                    end
                    passive = C_SpellBook.IsSpellBookItemPassive and C_SpellBook.IsSpellBookItemPassive(i, bank)
                elseif GetSpellBookItemName then
                    name = GetSpellBookItemName(i, "pet"); isSpell = true
                    passive = IsPassiveSpell and IsPassiveSpell(i, "pet")
                end
                if name and name ~= "" and isSpell and not passive then mem[name] = true end
            end
        end)
        -- second way: the pet's own action bar (the row of buttons that appears when the pet is out). Its abilities are listed
        -- there whichever spellbook functions this client has. A "token" is a command (Attack, Follow, Stay), not an ability.
        pcall(function()
            if GetPetActionInfo then
                for i = 1, (NUM_PET_ACTION_SLOTS or 10) do
                    local name, _, isToken, _, _, _, spellID = GetPetActionInfo(i)
                    if spellID and spellID ~= 0 and C_Spell and C_Spell.GetSpellName then name = C_Spell.GetSpellName(spellID) or name end
                    if name and name ~= "" and not isToken then mem[name] = true end
                end
            end
        end)
        -- what the game says about pets right now, so a miss can be understood from the saved file
        local dbgp = {}
        local function d(s) dbgp[#dbgp + 1] = s end
        pcall(function() d("pet out: " .. tostring(UnitExists and UnitExists("pet")) .. " name: " .. tostring(UnitName and UnitName("pet"))) end)
        pcall(function()
            local n, tok = nil, nil
            if C_SpellBook and C_SpellBook.HasPetSpells then n, tok = C_SpellBook.HasPetSpells() end
            d("C_SpellBook.HasPetSpells: " .. type(C_SpellBook and C_SpellBook.HasPetSpells) .. " -> " .. tostring(n) .. " " .. tostring(tok))
        end)
        pcall(function() d("global HasPetSpells: " .. type(HasPetSpells) .. " -> " .. tostring(HasPetSpells and HasPetSpells())) end)
        pcall(function()
            local keys = {}
            for k, v in pairs(Enum.SpellBookSpellBank) do keys[#keys + 1] = tostring(k) .. "=" .. tostring(v) end
            table.sort(keys); d("SpellBookSpellBank: " .. table.concat(keys, ", "))
        end)
        pcall(function()
            d("GetPetActionInfo: " .. type(GetPetActionInfo))
            for i = 1, (NUM_PET_ACTION_SLOTS or 10) do
                local name, _, isToken, _, _, _, spellID = GetPetActionInfo(i)
                if name then d("  pet bar " .. i .. ": " .. tostring(name) .. " token=" .. tostring(isToken) .. " spell=" .. tostring(spellID)) end
            end
        end)
        db.petDebug = dbgp
        local list = {}
        for nm in pairs(mem) do list[#list + 1] = nm end
        table.sort(list)
        for _, nm in ipairs(list) do add(nm) end
        db.petSpells = list   -- the pet ones, so the voice commander can file them under Pet
    end)

    -- fallback 3: walk numbered spell slots with the plain spell API (works on most older-style clients)
    if #db.spells == 0 then
        pcall(function()
            for i = 1, 1500 do
                local n
                if GetSpellBookItemName then n = GetSpellBookItemName(i, "spell") end
                if not n and GetSpellName then n = GetSpellName(i, "spell") end
                if not n and C_SpellBook and C_SpellBook.GetSpellBookItemName then n = C_SpellBook.GetSpellBookItemName(i, Enum.SpellBookSpellBank.Player) end
                if not n then break end
                add(n)
            end
        end)
    end
    -- which spell functions this client really has, so we can tell what to use if the list is still empty
    db.apis = {}
    for _, k in ipairs({"GetNumSpellTabs","GetSpellTabInfo","GetSpellBookItemName","GetSpellName","GetSpellInfo","IsSpellKnown"}) do
        db.apis[#db.apis + 1] = k .. "=" .. tostring(_G[k] ~= nil)
    end
    if C_SpellBook then
        for k in pairs(C_SpellBook) do
            if type(k) == "string" and k:find("SpellBook") then db.apis[#db.apis + 1] = "C_SpellBook." .. k end
        end
    end
    -- action bars: which spell (or item or macro) sits on which button, and the key that presses it.
    -- Two ways, because clients number their bars differently: (A) read the on-screen button frames, which know their own
    -- slot and key; (B) scan every slot and use the standard binding names for the ones we recognise.
    db.actions = {}
    db.actionDebug = {}
    local function dbg(s) if #db.actionDebug < 90 then db.actionDebug[#db.actionDebug + 1] = s end end
    local function nameOf(kind, id)
        local name
        if not id or id == 0 then return nil end
        if kind == "spell" and id then
            if C_Spell and C_Spell.GetSpellName then name = C_Spell.GetSpellName(id) end
            if not name and GetSpellInfo then name = GetSpellInfo(id) end
        elseif kind == "item" and id then
            if C_Item and C_Item.GetItemNameByID then name = C_Item.GetItemNameByID(id) end
            if not name and GetItemInfo then name = GetItemInfo(id) end
        elseif kind == "macro" and id then
            name = GetMacroInfo and GetMacroInfo(id)
        end
        return name
    end
    local seenAction = {}
    local rawActions = {}
    local function record(name, kind, k1, k2, id)
        if name and k1 then rawActions[#rawActions + 1] = { name = name, kind = kind, k1 = k1, k2 = k2, id = id } end
    end
    pcall(function()
        -- (A) button frames
        local bars = { "ActionButton", "MultiBarBottomLeftButton", "MultiBarBottomRightButton", "MultiBarRightButton",
                       "MultiBarLeftButton", "MultiBar5Button", "MultiBar6Button", "MultiBar7Button", "MultiBar8Button" }
        local framesFound, occupied = 0, 0
        for _, prefix in ipairs(bars) do
            for n = 1, 12 do
                local f = _G[prefix .. n]
                if f then
                    framesFound = framesFound + 1
                    local action = f.action or (f.GetAttribute and f:GetAttribute("action"))
                    if action then
                        local kind, id = GetActionInfo(action)
                        if kind then
                            occupied = occupied + 1
                            local cmd = f.commandName or f.buttonType
                            local k1, k2
                            if f.commandName then k1, k2 = GetBindingKey(f.commandName) end
                            if not k1 and f.buttonType then k1, k2 = GetBindingKey(f.buttonType .. n) end
                            dbg("frame " .. prefix .. n .. " action=" .. tostring(action) .. " " .. tostring(kind) .. ":" .. tostring(id) .. " cmd=" .. tostring(cmd) .. " key=" .. tostring(k1))
                            record(nameOf(kind, id), kind, k1, k2, id)
                        end
                    end
                end
            end
        end
        dbg("frames found=" .. framesFound .. " occupied=" .. occupied)
        -- (B) every slot
        local occupiedSlots = 0
        local ranges = {}
        for slot = 1, 400 do
          pcall(function()
            local kind, id = GetActionInfo(slot)
            if kind then
                occupiedSlots = occupiedSlots + 1
                local rk = math.floor((slot - 1) / 12) * 12 + 1
                ranges[rk] = (ranges[rk] or 0) + 1
                local cmd
                if slot <= 12 then cmd = "ACTIONBUTTON" .. slot
                elseif slot >= 25 and slot <= 36 then cmd = "MULTIACTIONBAR3BUTTON" .. (slot - 24)
                elseif slot >= 37 and slot <= 48 then cmd = "MULTIACTIONBAR4BUTTON" .. (slot - 36)
                elseif slot >= 49 and slot <= 60 then cmd = "MULTIACTIONBAR2BUTTON" .. (slot - 48)
                elseif slot >= 61 and slot <= 72 then cmd = "MULTIACTIONBAR1BUTTON" .. (slot - 60)
                elseif slot >= 145 and slot <= 156 then cmd = "MULTIACTIONBAR5BUTTON" .. (slot - 144)
                elseif slot >= 157 and slot <= 168 then cmd = "MULTIACTIONBAR6BUTTON" .. (slot - 156)
                elseif slot >= 169 and slot <= 180 then cmd = "MULTIACTIONBAR7BUTTON" .. (slot - 168) end
                local k1, k2
                if cmd then k1, k2 = GetBindingKey(cmd) end
                dbg("slot " .. slot .. " " .. tostring(kind) .. ":" .. tostring(id) .. " " .. tostring(nameOf(kind, id)) .. " cmd=" .. tostring(cmd) .. " key=" .. tostring(k1))
                record(nameOf(kind, id), kind, k1, k2, id)
            end
          end)
        end
        dbg("occupied slots 1-400 = " .. occupiedSlots)
        local keys = {}
        for k in pairs(ranges) do keys[#keys + 1] = k end
        table.sort(keys)
        for _, k in ipairs(keys) do dbg("slots " .. k .. "-" .. (k + 11) .. " have " .. ranges[k] .. " filled") end
    end)
    -- Name them. A spell with several ranks on keyed buttons: the highest keeps the plain name ("Moonfire"), a lower rank
    -- becomes "Moonfire 1" so the voice commander can tell them apart. A lone lower rank keeps the plain name.
    pcall(function()
        local best = bestRanks()
        local bestOnBar = {}
        for _, r in ipairs(rawActions) do
            if r.kind == "spell" and best[r.name] == r.id then bestOnBar[r.name] = true end
        end
        for _, r in ipairs(rawActions) do
            local name = r.name
            if r.kind == "spell" and best[name] and r.id ~= best[name] and bestOnBar[name] then
                local rk = rankOf(r.id)
                if rk then name = name .. " " .. rk end
            end
            local sig = name .. "|" .. tostring(r.k1)
            if not seenAction[sig] then
                seenAction[sig] = true
                db.actions[#db.actions + 1] = { name, r.kind, r.k1, r.k2 }
            end
        end
    end)
    if #db.actions == 0 then   -- the naming step failed: fall back to the plain names so nothing is lost
        for _, r in ipairs(rawActions) do db.actions[#db.actions + 1] = { r.name, r.kind, r.k1, r.k2 } end
    end
    -- the controller: is it on, which one, and what the game says about it (so controller schemes can be understood)
    db.gamepad = {}
    pcall(function()
        if C_GamePad then
            local function add(label, fn, ...) local ok, v = pcall(fn, ...) db.gamepad[#db.gamepad + 1] = label .. "=" .. tostring(ok and v or "n/a") end
            if C_GamePad.IsEnabled then add("enabled", C_GamePad.IsEnabled) end
            if C_GamePad.GetActiveDeviceID then add("activeDevice", C_GamePad.GetActiveDeviceID) end
            if C_GamePad.GetDeviceIDs then
                local ok, ids = pcall(C_GamePad.GetDeviceIDs)
                if ok and ids then for _, id in ipairs(ids) do db.gamepad[#db.gamepad + 1] = "device " .. tostring(id) end end
            end
        end
        if GetCVar then
            for _, cv in ipairs({"GamePadEnable", "GamePadEmulateShift", "GamePadEmulateCtrl", "GamePadEmulateAlt", "GamePadCursorLeftClick", "GamePadCursorRightClick", "GamePadTurnWithCamera"}) do
                local ok, v = pcall(GetCVar, cv)
                if ok and v then db.gamepad[#db.gamepad + 1] = cv .. "=" .. tostring(v) end
            end
        end
    end)
    -- controller bindings: ask the game what every controller button (alone and with the trigger/shoulder held) does.
    -- GetBindingByKey answers for one specific key name, so we try them all.
    db.padBindings = {}
    pcall(function()
        local buttons = { "PADDUP", "PADDDOWN", "PADDLEFT", "PADDRIGHT", "PAD1", "PAD2", "PAD3", "PAD4", "PAD5", "PAD6",
                          "PADLSTICK", "PADRSTICK", "PADLSHOULDER", "PADRSHOULDER", "PADLTRIGGER", "PADRTRIGGER",
                          "PADFORWARD", "PADBACK", "PADSYSTEM", "PADSOCIAL",
                          "PADLSTICKUP", "PADLSTICKDOWN", "PADLSTICKLEFT", "PADLSTICKRIGHT",
                          "PADRSTICKUP", "PADRSTICKDOWN", "PADRSTICKLEFT", "PADRSTICKRIGHT" }
        local mods = { "", "PADLTRIGGER-", "PADRTRIGGER-", "PADLTRIGGER-PADRTRIGGER-", "PADLSHOULDER-", "PADRSHOULDER-",
                       "PADLSHOULDER-PADRSHOULDER-", "PADLTRIGGER-PADLSHOULDER-", "PADRTRIGGER-PADRSHOULDER-" }
        for _, m in ipairs(mods) do
            for _, b in ipairs(buttons) do
                local key = m .. b
                if m == "" or (b ~= "PADLTRIGGER" and b ~= "PADRTRIGGER" and b ~= "PADLSHOULDER" and b ~= "PADRSHOULDER") then
                    local ok, cmd = pcall(GetBindingByKey, key)
                    if ok and cmd then db.padBindings[#db.padBindings + 1] = { key, cmd } end
                end
            end
        end
        -- what the game's controller API offers, so a next version can use it
        db.gamepadApi = {}
        if C_GamePad then
            for k, v in pairs(C_GamePad) do
                if type(v) == "function" then db.gamepadApi[#db.gamepadApi + 1] = k end
            end
            table.sort(db.gamepadApi)
        end
    end)
    -- v24 abilities that sit on a bar but are NOT in the spellbook list (profession abilities such as Fishing): what the game says about each,
    -- so it can be understood why casting one by name does not work when its bar button does. Only reads; nothing is changed.
    db.probe = {}
    pcall(function()
        local function pr(s) if #db.probe < 60 then db.probe[#db.probe + 1] = s end end
        local done = {}
        for slot = 1, 400 do
            local ok, kind, id = pcall(GetActionInfo, slot)
            if ok and kind == "spell" and id and id ~= 0 and not done[id] then
                done[id] = true
                local name
                if C_Spell and C_Spell.GetSpellName then name = C_Spell.GetSpellName(id) end
                if not name and GetSpellInfo then name = GetSpellInfo(id) end
                if name and not seen[name] then
                    local line = "slot " .. slot .. " spell:" .. id .. " " .. tostring(name)
                    pcall(function() line = line .. " | IsSpellKnown=" .. tostring(IsSpellKnown and IsSpellKnown(id)) end)
                    pcall(function() line = line .. " | IsPlayerSpell=" .. tostring(IsPlayerSpell and IsPlayerSpell(id)) end)
                    pcall(function() local u = IsUsableSpell and IsUsableSpell(id); line = line .. " | usable=" .. tostring(u) end)
                    pcall(function() local info = C_Spell and C_Spell.GetSpellInfo and C_Spell.GetSpellInfo(name); line = line .. " | name->spellID=" .. tostring(info and info.spellID) end)
                    pcall(function() local _, _, _, _, _, _, sid = GetSpellInfo(name); line = line .. " | GetSpellInfo(name)->spellID=" .. tostring(sid) end)
                    pcall(function() line = line .. " | mainHandItem=" .. tostring(GetInventoryItemID and GetInventoryItemID("player", 16)) end)
                    pr(line)
                end
            end
        end
    end)
    -- v55 READ ONLY (ALPHA TESTING): the cast profession abilities this character knows (from PROFESSION_SPELLS), so VCF can group them;
    -- plus what the game says about its professions and every spellbook line (camp abilities: how the game offers them is not known yet, this is to find out)
    db.professionSpells = {}
    db.professions = {}
    db.skillLines = {}
    pcall(function()
        local seenP = {}
        for _, id in ipairs(PROFESSION_SPELLS) do
            local known = (IsPlayerSpell and IsPlayerSpell(id)) or (IsSpellKnown and IsSpellKnown(id))
            local name = known and ((C_Spell and C_Spell.GetSpellName and C_Spell.GetSpellName(id)) or (GetSpellInfo and (GetSpellInfo(id))))
            if name and name ~= "" and not seenP[name] then seenP[name] = true; db.professionSpells[#db.professionSpells + 1] = { name, id } end
        end
    end)
    pcall(function()
        if GetProfessions and GetProfessionInfo then
            for _, idx in ipairs({ GetProfessions() }) do
                if idx then
                    local name, _, rank, maxRank, numSpells, spellOffset, skillLine = GetProfessionInfo(idx)
                    db.professions[#db.professions + 1] = { tostring(name), tostring(rank), tostring(maxRank), tostring(numSpells), tostring(spellOffset), tostring(skillLine) }
                end
            end
        end
    end)
    pcall(function()
        if C_SpellBook and C_SpellBook.GetNumSpellBookSkillLines then
            for line = 1, C_SpellBook.GetNumSpellBookSkillLines() do
                local info = C_SpellBook.GetSpellBookSkillLineInfo(line)
                if info then
                    local names = {}
                    for i = info.itemIndexOffset + 1, info.itemIndexOffset + info.numSpellBookItems do
                        local item = C_SpellBook.GetSpellBookItemInfo(i, Enum.SpellBookSpellBank.Player)
                        if item and item.name then names[#names + 1] = item.name .. (item.isOffSpec and " (off)" or "") end
                    end
                    db.skillLines[#db.skillLines + 1] = { tostring(info.name), tostring(info.numSpellBookItems), tostring(info.offSpecID or ""), table.concat(names, ", ") }
                end
            end
        end
    end)
    -- v56 READ ONLY (2026-11-05, RENAME AN ITEM): every item this character carries that can be USED or WORN (bags and what is equipped), so the player can give it
    -- their own words in VCF. Each entry: name, "equip" or "use", "worn" when it is equipped now. Junk (grey) and quest items are left out. Nothing is changed.
    db.bagItems = {}
    pcall(function()
        local seenI = {}
        local function consider(id, link, quality, worn)
            if not id or seenI[id] then return end
            local name
            pcall(function() name = (C_Item and C_Item.GetItemNameByID and C_Item.GetItemNameByID(id)) or (GetItemInfo and (GetItemInfo(id))) end)
            if (not name or name == "") and link then name = link:match("%[(.-)%]") end
            if not name or name == "" then return end
            local classID
            pcall(function() local _, _, _, _, _, c = GetItemInfoInstant(id); classID = c end)
            if classID == 12 then return end   -- quest item
            local equip = false
            pcall(function() equip = (C_Item and C_Item.IsEquippableItem and C_Item.IsEquippableItem(id)) or (IsEquippableItem and IsEquippableItem(id)) or false end)
            local use
            pcall(function() if C_Item and C_Item.GetItemSpell then use = (C_Item.GetItemSpell(id)) elseif GetItemSpell then use = (GetItemSpell(id)) end end)
            local kind = equip and "equip" or (use and "use" or nil)
            if not kind then return end
            -- v60 (2026-11-06, user: RENAME "failed to find my axe"): grey (junk) quality is left out only for things that are not worn or wielded.
            -- A grey weapon or armour piece (the Rusty Hatchet in his hand) is still gear the player uses.
            if quality == 0 and kind ~= "equip" then return end
            seenI[id] = true
            db.bagItems[#db.bagItems + 1] = { name, kind, worn and "worn" or "", tostring(id), tostring(quality or "") }   -- v60: quality, 0 = junk (grey)
        end
        for slot = 1, 19 do
            local id = GetInventoryItemID and GetInventoryItemID("player", slot)
            if id then consider(id, GetInventoryItemLink and GetInventoryItemLink("player", slot), GetInventoryItemQuality and GetInventoryItemQuality("player", slot), true) end
        end
        for bag = 0, 4 do
            local n = (C_Container and C_Container.GetContainerNumSlots and C_Container.GetContainerNumSlots(bag)) or (GetContainerNumSlots and GetContainerNumSlots(bag)) or 0
            for s = 1, n do
                pcall(function()
                    if C_Container and C_Container.GetContainerItemInfo then
                        local info = C_Container.GetContainerItemInfo(bag, s)
                        if info then consider(info.itemID, info.hyperlink, info.quality, false) end
                    elseif GetContainerItemInfo then
                        local _, _, _, quality, _, _, link, _, _, id = GetContainerItemInfo(bag, s)
                        consider(id, link, quality, false)
                    end
                end)
            end
        end
    end)
    -- v53 READ ONLY: what each item on the bars and controller pages does when used, so food gets "eat ..." and drink "drink ..." as its words.
    -- The game itself says it: eating casts the spell "Food", drinking "Drink" (both at once: "Refreshment"). Also the item's type, for later.
    db.itemUses = {}
    pcall(function()
        local done = {}
        for slot = 1, 400 do
            local ok, kind, id = pcall(GetActionInfo, slot)
            if ok and kind == "item" and id and not done[id] then
                done[id] = true
                local name, use, itype, isub
                pcall(function() name = (C_Item and C_Item.GetItemNameByID and C_Item.GetItemNameByID(id)) or (GetItemInfo and (GetItemInfo(id))) end)
                pcall(function() if C_Item and C_Item.GetItemSpell then use = (C_Item.GetItemSpell(id)) elseif GetItemSpell then use = (GetItemSpell(id)) end end)
                pcall(function() local _, t, s = GetItemInfoInstant(id); itype, isub = t, s end)
                if name then db.itemUses[#db.itemUses + 1] = { name, tostring(use or ""), tostring(itype or ""), tostring(isub or "") } end
            end
        end
    end)
    db.interactCmds = {}
    pcall(function()
        for i = 1, (GetNumBindings() or 0) do
            local c = (GetBinding(i))
            if c and tostring(c):find("INTERACT") then db.interactCmds[#db.interactCmds + 1] = c end
        end
    end)
    -- v52 READ ONLY: the game's Interact settings (the Options tickbox that binds Interact to a key is one of them, name not known yet).
    -- Every setting whose name has "interact" or "softtarget" in it, with its value and the game's default. Nothing is changed.
    db.interactSettings = {}
    pcall(function()
        local function val(n)
            local v
            if C_CVar and C_CVar.GetCVar then v = C_CVar.GetCVar(n) elseif GetCVar then v = GetCVar(n) end
            return v
        end
        local function def(n)
            local d
            pcall(function() if C_CVar and C_CVar.GetCVarDefault then d = C_CVar.GetCVarDefault(n) elseif GetCVarDefault then d = GetCVarDefault(n) end end)
            return d
        end
        local seen = {}
        local function add(n)
            if type(n) ~= "string" or seen[n:lower()] then return end
            local ok, v = pcall(val, n)   -- v53: a console COMMAND (not a setting) can make the read fail; that one is skipped, not the whole list
            if not ok or v == nil then return end
            seen[n:lower()] = true
            db.interactSettings[#db.interactSettings + 1] = { n, tostring(v), tostring(def(n)) }
        end
        -- v53: the likely names FIRST, read one by one (in v52 one failure in the full list below stopped everything, so nothing was saved)
        for _, n in ipairs({ "SoftTargetInteract", "SoftTargetInteractArc", "SoftTargetInteractRange", "SoftTargetEnemy", "SoftTargetFriend",
                             "SoftTargetForce", "SoftTargetMatchLocked", "SoftTargetWithLocked", "GamePadEnable", "interactOnLeftClick",
                             "AutoInteract", "enableMouseoverCast" }) do
            pcall(add, n)
        end
        local found, how = 0, "no list offered"
        pcall(function()
            if C_Console and C_Console.GetAllCommands then
                how = "list read"
                for _, c in ipairs(C_Console.GetAllCommands() or {}) do
                    found = found + 1
                    local n = type(c) == "table" and c.command or nil
                    if type(n) == "string" then
                        local l = n:lower()
                        if l:find("interact") or l:find("softtarget") then pcall(add, n) end
                    end
                end
            end
        end)
        -- one line saying how it went, so an empty answer can be understood from the saved file
        db.interactSettingsNote = how .. ", " .. found .. " entries looked at, " .. #db.interactSettings .. " kept"
    end)
    -- real key bindings: command name, first key, second key
    db.bindings = {}
    pcall(function()
        for i = 1, GetNumBindings() do
            -- every key bound to the command (keyboard, mouse AND controller buttons, which can be a 3rd, 4th key)
            local r = { GetBinding(i) }
            if r[3] then
                local entry = { r[1] }
                for k = 3, #r do entry[#entry + 1] = r[k] end
                db.bindings[#db.bindings + 1] = entry
            end
        end
    end)
    db.buttons = {}
    pcall(function() db.buttons = buttonStatus() end)
    db.petBar = {}
    pcall(function() if petBarRows then db.petBar = petBarRows() end end)
    -- v40 why is the pet bar empty? what the game says about each pet bar slot, raw, so it can be read from the saved file
    db.petBarDebug = {}
    pcall(function()
        db.petBarDebug[#db.petBarDebug + 1] = "GetPetActionInfo=" .. type(GetPetActionInfo) .. " pet exists=" .. tostring(UnitExists and UnitExists("pet")) ..
            " HasPetUI=" .. tostring(HasPetUI and HasPetUI()) .. " PetActionButton1=" .. tostring(_G["PetActionButton1"] ~= nil) ..
            " PetActionBar shown=" .. tostring(PetActionBar and PetActionBar.IsShown and PetActionBar:IsShown())
        for i = 1, 12 do
            local ok, a1, a2, a3, a4, a5, a6, a7 = pcall(GetPetActionInfo, i)
            db.petBarDebug[#db.petBarDebug + 1] = i .. ": ok=" .. tostring(ok) .. " name=" .. tostring(a1) .. " token=" .. tostring(a3) .. " spell=" .. tostring(a7)
        end
    end)   -- v39 slot, token or spell name, kind, the chord key bound to that pet button, label
    -- v37 hidden /cast or /use keys that did nothing EVERY time they were pressed (at least twice, never once cast): the voice commander gives these a bar slot instead of a hidden key
    -- v114 (2026-11-10) KEY TEST: is the helper listening for a test (the voice commander starts only then), and the last result
    db.keyTestListening = (ZENVC_KEYTEST and #ZENVC_KEYTEST) or 0
    pcall(function()
        local kt = ZenVCExportDB._keyTest
        if kt then db.keyTestAt, db.keyTestArrived, db.keyTestTotal, db.keyTestMissing, db.keyTestPad = kt.at, kt.arrived, kt.total, kt.missing, kt.pad end
    end)
    db.hiddenFailed = {}
    pcall(function()
        local r = ZenVCExportDB._hiddenResult and ZenVCExportDB._hiddenResult[charKey()]
        if r then for mt, v in pairs(r) do if (v.ok or 0) == 0 and (v.none or 0) >= 2 then db.hiddenFailed[#db.hiddenFailed + 1] = mt end end end
        table.sort(db.hiddenFailed)
    end)
    return db
end

local function save()
    local ok, db = pcall(collect)
    if ok and db and db.name then
        local key = db.name .. "-" .. (db.realm or "")
        local old = ZenVCExportDB[key]
        -- never replace good action-bar data with an empty read (bars are not readable while the UI is loading or closing)
        if #db.actions == 0 and old and old.actions and #old.actions > 0 then
            db.actions = old.actions
            db.actionDebug[#db.actionDebug + 1] = "kept the actions from the " .. tostring(old.exportedAt) .. " save"
        end
        ZenVCExportDB[key] = db
    end
end


-- ===================================================================================================================
-- PLACING SPELLS THAT ARE ON NO BAR (only when YOU ask: /zenvc bars, then /zenvc bars yes). Undo with /zenvc undo.
-- It only fills EMPTY slots on an EMPTY bar, never replaces anything, and only out of combat. Each placed spell gets a
-- Ctrl+Alt+Shift key that nothing else of yours uses, so the voice commander can press it without opening the chat box.
-- ===================================================================================================================
local BAR_FRAMES = { "MultiBar7Button", "MultiBar6Button", "MultiBar5Button", "MultiBarLeftButton", "MultiBarRightButton",
                     "MultiBarBottomRightButton", "MultiBarBottomLeftButton" }
-- v36 FIVE key sets (60 slots), each with its own modifiers (WoW's own order: ALT-CTRL-SHIFT; CTRL-ALT-SHIFT is stored but never fires). Sets 1 and 2 are unchanged. Sets 3 to 5
-- use keys that were all proven to arrive in the game (41 of 41, 2026-10-19). The voice commander reserves every key here so it never hands one out as a hidden key.
local KEYSETS = {
    { mods = "ALT-CTRL-SHIFT-", keys = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=" } },
    { mods = "ALT-CTRL-SHIFT-", keys = { "F1", "F2", "F3", "INSERT", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12" } },   -- v49 INSERT, never F4 (Alt+F4 closes the game)
    { mods = "ALT-CTRL-SHIFT-", keys = { "[", "]", ";", "'", ",", ".", "/", "\\", "`", "HOME", "END", "PAGEUP" } },
    { mods = "ALT-CTRL-",       keys = { "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "-", "=" } },
    { mods = "ALT-CTRL-",       keys = { "[", "]", ";", "'", ",", ".", "/", "\\", "`", "INSERT", "HOME", "END" } },
}
local planned

local function prettyKey(k)
    k = k:gsub("CTRL", "Ctrl"):gsub("ALT", "Alt"):gsub("SHIFT", "Shift")
    return (k:gsub("%-", "+"))
end

-- v37 does this spell have a hidden key button that has not been proven useless? (a button for "/cast Name" exists and its recorded presses are not "never cast")
local function hiddenWorks(name)
    local want = "/cast " .. name:lower()
    local has = false
    for _, b in ipairs(effectiveButtons()) do
        if b.text and b.text:lower() == want then has = true break end
    end
    if not has then return false end
    local r = ZenVCExportDB._hiddenResult and ZenVCExportDB._hiddenResult[charKey()]
    if r then
        for mt, v in pairs(r) do
            if mt:lower() == want and (v.ok or 0) == 0 and (v.none or 0) >= 2 then return false end
        end
    end
    return true
end

local function spellsNotOnBars()
    local onId, onName = {}, {}
    local allBars = { "ActionButton", "MultiBarBottomLeftButton", "MultiBarBottomRightButton", "MultiBarRightButton",
                      "MultiBarLeftButton", "MultiBar5Button", "MultiBar6Button", "MultiBar7Button", "MultiBar8Button" }
    for _, prefix in ipairs(allBars) do
        for n = 1, 12 do
            pcall(function()
                local f = _G[prefix .. n]
                local action = f and (f.action or (f.GetAttribute and f:GetAttribute("action")))
                if action and f.commandName and GetBindingKey(f.commandName) then
                    local kind, id = GetActionInfo(action)
                    if kind == "spell" and id and id ~= 0 then
                        onId[id] = true
                        local nm = C_Spell and C_Spell.GetSpellName and C_Spell.GetSpellName(id)
                        if nm then onName[nm:lower()] = true end   -- v38 a lower RANK of the same spell on a keyed bar counts too (Raptor Strike was offered again)
                    end
                end
            end)
        end
    end
    local known = knownSpells()
    local names = {}
    for n in pairs(known) do names[#names + 1] = n end
    table.sort(names)
    local list, seen = {}, {}
    for _, name in ipairs(names) do
        local e = known[name]
        local function add(id, label, rank)
            -- v37 a spell that already has a hidden key which WORKS is left alone (hidden keys are used wherever they work); one whose hidden key never cast is offered a bar slot
            if id and id ~= 0 and not onId[id] and not seen[label] and (not hiddenWorks(name)) and not onName[name:lower()] then
                seen[label] = true
                list[#list + 1] = { name = label, spell = name, id = id, rank = rank }
            end
        end
        for _, w in ipairs(getPref(name)) do
            if w == "max" then
                add(e.best, name, "max")
            elseif w == "all" then
                for _, r in ipairs(e.ranks) do
                    if r.id == e.best then add(r.id, name, "max") else add(r.id, name .. " " .. tostring(r.rank or "?"), r.rank) end
                end
            elseif type(w) == "number" then
                for _, r in ipairs(e.ranks) do
                    if r.rank == w then
                        if r.id == e.best then add(r.id, name, "max") else add(r.id, name .. " " .. w, w) end
                    end
                end
            end
        end
    end
    return list
end

local function placedSlots()
    local set = {}
    local d = ZenVCExportDB._placed and ZenVCExportDB._placed[charKey()]
    if d then for _, p in ipairs(d) do set[p.slot] = true end end
    return set
end

-- Bars I may use: a bar that is entirely empty, OR one whose only contents are spells I placed myself (so my own bar can
-- grow as you learn more). A bar holding anything of yours is never touched. Free slots are the empty ones.
local function emptyBars()
    local mine = placedSlots()
    local bars = {}
    for _, prefix in ipairs(BAR_FRAMES) do
        local ok, slots, anyFree = true, {}, false
        for n = 1, 12 do
            local f = _G[prefix .. n]
            local action = f and (f.action or (f.GetAttribute and f:GetAttribute("action")))
            if not f or not action or not f.commandName then ok = false break end
            local occupied = GetActionInfo(action)
            if occupied and not mine[action] then ok = false break end
            slots[n] = { slot = action, cmd = f.commandName, free = not occupied }
            if not occupied then anyFree = true end
        end
        if ok and anyFree then bars[#bars + 1] = { prefix = prefix, slots = slots } end
    end
    return bars
end

-- Which key set each bar of mine uses (set 1 = Alt+Ctrl+Shift 1..=, set 2 = Alt+Ctrl+Shift F1..F12). Remembered, so a
-- bar keeps its keys even after another bar fills up.
local function barKeyMap()
    ZenVCExportDB._barkeys = ZenVCExportDB._barkeys or {}
    local k = charKey()
    ZenVCExportDB._barkeys[k] = ZenVCExportDB._barkeys[k] or {}
    return ZenVCExportDB._barkeys[k]
end

local function makePlan()
    local spells, bars = spellsNotOnBars(), emptyBars()
    local map = barKeyMap()
    local used = 0
    for _, v in pairs(map) do if v > used then used = v end end
    for _, bar in ipairs(bars) do
        if map[bar.prefix] then bar.idx = map[bar.prefix] else used = used + 1; bar.idx = used end
    end
    local spots = {}
    for _, bar in ipairs(bars) do
        local ks = KEYSETS[bar.idx]
        if ks then
            for n = 1, 12 do
                local s = bar.slots[n]
                if s and s.free then
                    local key = ks.mods .. ks.keys[n]
                    local inUse = GetBindingAction(key)
                    -- v33 the game's key bindings are shared by every character: a key that is already bound to THIS very bar button (put there when another character was
                    -- given its spells) is exactly what is wanted, so it counts as free. Before, a second character always found "nothing to place".
                    if inUse == nil or inUse == "" or inUse == s.cmd then
                        spots[#spots + 1] = { slot = s.slot, cmd = s.cmd, key = key, prefix = bar.prefix, idx = bar.idx }
                    end
                end
            end
        end
    end
    local plan, skipped = {}, {}
    for i, sp in ipairs(spells) do
        local spot = spots[i]
        if spot then
            plan[#plan + 1] = { name = sp.name, spell = sp.spell, rank = sp.rank, id = sp.id, slot = spot.slot,
                                cmd = spot.cmd, key = spot.key, prefix = spot.prefix, idx = spot.idx }
        else
            skipped[#skipped + 1] = sp.name
        end
    end
    return plan, skipped, #bars
end

local function say(msg) print("VCF Helper: " .. msg) end

local function showPlan()
    if InCombatLockdown() then say("not in combat, please.") return end
    local plan, skipped, nbars = makePlan()
    if nbars == 0 then say("I need a completely empty action bar to use and found none, so I will change nothing.") return end
    if #plan == 0 then say("every spell you know is already on a bar. Nothing to place.") return end
    planned = plan
    say("PLAN (nothing changed yet). Empty slots on an empty bar would get:")
    for _, p in ipairs(plan) do say("  " .. prettyKey(p.key) .. "  =  " .. p.name) end
    if #skipped > 0 then say("No room or no free key for: " .. table.concat(skipped, ", ")) end
    say("To do it, type:  /zenvc bars yes        To undo later:  /zenvc undo")
end

local function doPlace()
    if InCombatLockdown() then say("not in combat, please.") return end
    if not planned then say("type /zenvc bars first to see the plan.") return end
    local plan = makePlan()   -- recompute: only what is STILL empty and free is touched
    local key = (UnitName("player") or "?") .. "-" .. (GetRealmName and GetRealmName() or "")
    ZenVCExportDB._placed = ZenVCExportDB._placed or {}
    local done = ZenVCExportDB._placed[key] or {}
    local count = 0
    for _, p in ipairs(plan) do
        ClearCursor()
        if C_Spell and C_Spell.PickupSpell then C_Spell.PickupSpell(p.id) elseif PickupSpell then PickupSpell(p.id) end
        PlaceAction(p.slot)
        ClearCursor()
        local kind, id = GetActionInfo(p.slot)
        if kind == "spell" and id == p.id then
            if SetBinding(p.key, p.cmd) then
                done[#done + 1] = { name = p.name, spell = p.spell, rank = p.rank, id = p.id, slot = p.slot, key = p.key }
                barKeyMap()[p.prefix] = p.idx
                count = count + 1
            end
        end
    end
    if count > 0 then
        local set = GetCurrentBindingSet and GetCurrentBindingSet() or 1
        SaveBindings(set)
    end
    ZenVCExportDB._placed[key] = done
    planned = nil
    say("placed " .. count .. " spell(s) with keys. Now type /reload, and then /reload a second time, so the voice commander can read them.")
end


-- Keeps the spells I placed at their HIGHEST known rank. Learn a new rank (trainer, level up) and the same slot, with the
-- same key, gets the new rank. It only touches a slot that still holds exactly the spell I placed there, so a lower rank
-- you put there on purpose (to save mana) is never overwritten, and nothing on your own bars is ever touched.
local refreshPending
local function refreshRanks()
    if InCombatLockdown() then refreshPending = true return end
    refreshPending = nil
    local key = (UnitName("player") or "?") .. "-" .. (GetRealmName and GetRealmName() or "")
    local done = ZenVCExportDB._placed and ZenVCExportDB._placed[key]
    if not done or #done == 0 then return end
    local best = bestRanks()
    local names = {}
    for _, p in ipairs(done) do
        local kind, id = GetActionInfo(p.slot)
        local b = best[p.spell or p.name]
        if (p.rank == nil or p.rank == "max") and kind == "spell" and id == p.id and b and b ~= p.id then
            ClearCursor()
            if C_Spell and C_Spell.PickupSpell then C_Spell.PickupSpell(b) elseif PickupSpell then PickupSpell(b) end
            PlaceAction(p.slot)
            ClearCursor()
            local k2, id2 = GetActionInfo(p.slot)
            if k2 == "spell" and id2 == b then
                p.id = b
                names[#names + 1] = p.name
            end
        end
    end
    if #names > 0 then print("VCF Helper: moved to the highest rank you know: " .. table.concat(names, ", ")) end
end

local function showRanks()
    local known = knownSpells()
    local names = {}
    for n, e in pairs(known) do if #e.ranks > 1 then names[#names + 1] = n end end
    table.sort(names)
    if #names == 0 then
        say("none of your spells shows more than one rank in the spellbook, so there is nothing to choose.")
        say("Every spell uses your highest rank.")
        return
    end
    say("Spells you know in more than one rank (and which you have asked for):")
    for _, n in ipairs(names) do
        local rs = {}
        for _, r in ipairs(known[n].ranks) do rs[#rs + 1] = tostring(r.rank or "?") end
        local want = {}
        for _, w in ipairs(getPref(n)) do want[#want + 1] = tostring(w) end
        say("  " .. n .. ":  ranks " .. table.concat(rs, " ") .. "   using: " .. table.concat(want, " "))
    end
    say("Choose with:  /zenvc rank Moonfire 1 max      (1 = rank 1, max = your highest, all = every rank)")
    say("A lower rank is spoken with its number: moonfire one. Then type /zenvc bars to place them.")
end

local function setRank(arg)
    local tokens = {}
    for w in arg:gmatch("%S+") do tokens[#tokens + 1] = w end
    local want = {}
    while #tokens > 0 do
        local last = tokens[#tokens]:lower()
        if last == "max" or last == "all" then
            table.insert(want, 1, last); table.remove(tokens)
        elseif tonumber(last) then
            table.insert(want, 1, tonumber(last)); table.remove(tokens)
        else
            break
        end
    end
    local name = table.concat(tokens, " "):lower()
    local real
    for n in pairs(knownSpells()) do if n:lower() == name then real = n end end
    if not real then say("I do not know a spell called '" .. name .. "'. Type /zenvc ranks to see your spells.") return end
    if #want == 0 then want = { "max" } end
    ZenVCExportDB._prefs = ZenVCExportDB._prefs or {}
    local key = charKey()
    ZenVCExportDB._prefs[key] = ZenVCExportDB._prefs[key] or {}
    ZenVCExportDB._prefs[key][real] = want
    local shown = {}
    for _, w in ipairs(want) do shown[#shown + 1] = tostring(w) end
    say(real .. " will use: " .. table.concat(shown, ", ") .. ".  Type /zenvc bars to see the plan.")
end

local function doFixKeys()
    if InCombatLockdown() then say("not in combat, please.") return end
    local key = (UnitName("player") or "?") .. "-" .. (GetRealmName and GetRealmName() or "")
    local done = ZenVCExportDB._placed and ZenVCExportDB._placed[key]
    if not done or #done == 0 then say("nothing placed by me to fix for this character.") return end
    local allBars = { "ActionButton", "MultiBarBottomLeftButton", "MultiBarBottomRightButton", "MultiBarRightButton",
                      "MultiBarLeftButton", "MultiBar5Button", "MultiBar6Button", "MultiBar7Button", "MultiBar8Button" }
    local cmdForSlot = {}
    for _, prefix in ipairs(allBars) do
        for n = 1, 12 do
            local f = _G[prefix .. n]
            local action = f and (f.action or (f.GetAttribute and f:GetAttribute("action")))
            if action and f.commandName then cmdForSlot[action] = f.commandName end
        end
    end
    local fixed = 0
    for _, p in ipairs(done) do
        local suffix = p.key:match("^CTRL%-ALT%-SHIFT%-(.+)$")
        if suffix then
            local cmd = cmdForSlot[p.slot]
            if cmd then
                SetBinding(p.key)                       -- remove the old, wrong-order key
                if SetBinding("ALT-CTRL-SHIFT-" .. suffix, cmd) then
                    p.key = "ALT-CTRL-SHIFT-" .. suffix
                    fixed = fixed + 1
                end
            end
        end
    end
    if fixed > 0 then SaveBindings(GetCurrentBindingSet and GetCurrentBindingSet() or 1) end
    say("re-bound " .. fixed .. " key(s) in WoW's own order (Alt+Ctrl+Shift). Try one now, then type /reload twice.")
end

-- "Interact With Target" is how a corpse is looted (and how you talk to and shop with someone). The game ships it with NO
-- key, so the voice commander had nothing to press. /zenvc interact gives it a key nothing else uses.
local function doInteract()
    if InCombatLockdown() then say("not in combat, please.") return end
    local found, others = nil, {}
    for i = 1, (GetNumBindings() or 0) do
        local c = (GetBinding(i))
        if c == "INTERACTTARGET" then found = c end
        if c and tostring(c):find("INTERACT") then others[#others + 1] = c end
    end
    if not found then
        say("I could not find 'Interact With Target' in your key bindings, so I changed nothing. Interact-like ones I did find: "
            .. (#others > 0 and table.concat(others, ", ") or "none"))
        return
    end
    local key = "ALT-CTRL-SHIFT-L"
    local cur = GetBindingAction(key)
    if cur ~= nil and cur ~= "" and cur ~= found then
        say(key .. " is already used by " .. cur .. ", so I changed nothing.")
        return
    end
    if SetBinding(key, found) then
        SaveBindings(GetCurrentBindingSet and GetCurrentBindingSet() or 1)
        ZenVCExportDB._extra = ZenVCExportDB._extra or {}
        local k = charKey()
        ZenVCExportDB._extra[k] = ZenVCExportDB._extra[k] or {}
        local have = false
        for _, e in ipairs(ZenVCExportDB._extra[k]) do if e.key == key then have = true end end
        if not have then ZenVCExportDB._extra[k][#ZenVCExportDB._extra[k] + 1] = { key = key, cmd = found } end
        say("Interact With Target is now Alt+Ctrl+Shift+L. Target a corpse, stand next to it and press it to loot. Now type /reload twice so the voice commander can read it.")
    else
        say("the game would not accept that key, so I changed nothing.")
    end
end

local function doUndo()
    if InCombatLockdown() then say("not in combat, please.") return end
    local key = (UnitName("player") or "?") .. "-" .. (GetRealmName and GetRealmName() or "")
    local ex = ZenVCExportDB._extra and ZenVCExportDB._extra[key]
    if ex and #ex > 0 then
        for _, e in ipairs(ex) do SetBinding(e.key) end
        ZenVCExportDB._extra[key] = nil
        SaveBindings(GetCurrentBindingSet and GetCurrentBindingSet() or 1)
        say("removed the Interact key I had added.")
    end
    local done = ZenVCExportDB._placed and ZenVCExportDB._placed[key]
    if not done or #done == 0 then say("nothing placed by me to undo for this character.") return end
    local n = 0
    for _, p in ipairs(done) do
        local kind, id = GetActionInfo(p.slot)
        if kind == "spell" and id == p.id then   -- only if it is still the spell I put there
            ClearCursor(); PickupAction(p.slot); ClearCursor()
            n = n + 1
        end
        SetBinding(p.key)   -- remove my key
    end
    local set = GetCurrentBindingSet and GetCurrentBindingSet() or 1
    SaveBindings(set)
    ZenVCExportDB._placed[key] = nil
    say("removed " .. n .. " spell(s) I had placed, and their keys.")
end

-- ---------------------------------------------------------------------------------------------------------------
-- The click-to-confirm box. A person who has never heard of /zenvc never has to type anything: a short time after
-- login, if some of their spells are on no bar with a key and there is an empty bar to put them on, the game asks.
-- Yes = place them (same as /zenvc bars yes). Not now = ask again next login. Never ask = never again for this character.
-- Nothing is changed unless they click Yes.
-- ---------------------------------------------------------------------------------------------------------------
local offeredThisSession, readyToOffer = false, false
local lastBoxAt = nil   -- when a box of mine was last shown (the guard below reports it if the game blocks something)

StaticPopupDialogs["ZENVC_PLACE"] = {
    text = "Voice Commander: %d of your spells are on no bar with a key, so your voice cannot press them.\n\nPlace them on a spare bar, each with its own key? You can undo this any time by typing /zenvc undo.",
    button1 = "Yes, place them",
    button2 = "Not now",
    button3 = "Never ask",
    OnAccept = function() doPlace() end,
    OnAlt = function()
        ZenVCExportDB._noask = ZenVCExportDB._noask or {}
        ZenVCExportDB._noask[charKey()] = true
        print("VCF Helper: I will not ask again for this character. /zenvc bars still works whenever you want it.")
    end,
    timeout = 0, whileDead = false, hideOnEscape = true, preferredIndex = 3,
}

local function offerPlacement()
    if offeredThisSession or not readyToOffer or InCombatLockdown() or ZenVCExportDB._boxesOff then return end
    if ZenVCExportDB._noask and ZenVCExportDB._noask[charKey()] then return end
    local plan, skipped, nbars = makePlan()
    if nbars == 0 or #plan == 0 then return end
    offeredThisSession = true
    planned = plan
    lastBoxAt = GetTime and GetTime() or nil
    -- v39 a character the voice commander listed in ZENVC_AUTOPLACE gets its spells placed by itself, no typing: only into EMPTY bar slots, only spells with no key a voice
    -- command can use (the plan above), and it says so in the chat. /zenvc undo takes them away.
    if ZENVC_AUTOPLACE and (ZENVC_AUTOPLACE[UnitGUID and UnitGUID("player") or ""] or ZENVC_AUTOPLACE[UnitName("player") or ""]) then
        doPlace()
        return
    end
    -- v34 NO question box. A StaticPopup is blocked by the game in controller mode (ADDON_ACTION_FORBIDDEN SetPreferredGamepadInteractTarget, found 2026-10-13 and again
    -- 2026-10-19 when the new free-key check made the offer appear for a second character) and the guard then switches the hidden keys off. A line in the chat instead.
    say(#plan .. " of your spells have no key a voice command can use. Type  /zenvc bars  to see where they would go.")
end


-- ===================================================================================================================
-- HIDDEN COMMAND BUTTONS: emotes, /cast and /use run from a key with no chat box. Only after YOU say yes (the box, or
-- /zenvc emotes yes). The keys are OVERRIDE bindings: they are not written into your saved key bindings at all, the add-on
-- simply applies them each time you log in. Undo with /zenvc undo. If the game ever blocks one of these steps, the add-on
-- records which one and switches this feature off by itself.
-- ===================================================================================================================
local buttonOwner = CreateFrame("Frame", "ZenVCButtonOwner")
local lastApplied = 0

local function buttonsOff() return ZenVCExportDB._buttonsOff and true or false end

-- v39 THE PET BAR. A pet's abilities (Growl, Cower, Dust Cloud) and its commands (Attack, Follow, Stay, Passive ...) live on the PET bar, and a hidden "/cast Growl" key was proven
-- not to trigger them. So ten chord keys (Alt+Ctrl+Shift + D E F G H I J K M N) are bound to the ten pet bar buttons the way a bar slot key is, as override bindings (nothing is written
-- to the saved key bindings; they are put back at every login). The export lists each pet bar slot with its key (petBar) so the voice commander can give the pet commands and
-- abilities the right key. Out of combat only (the game does not allow binding in combat).
local PET_KEYS = { "D", "E", "F", "G", "H", "I", "J", "K", "M", "N" }
local petOwner = CreateFrame("Frame", "ZenVCPetOwner")
local function petKeyFor(i) return PET_KEYS[i] and ("ALT-CTRL-SHIFT-" .. PET_KEYS[i]) or nil end
local function bindPetBar()
    if InCombatLockdown() or buttonsOff() or not ClearOverrideBindings then return end
    pcall(function()
        ClearOverrideBindings(petOwner)
        for i = 1, #PET_KEYS do
            if _G["PetActionButton" .. i] then SetOverrideBindingClick(petOwner, true, petKeyFor(i), "PetActionButton" .. i, "LeftButton") end
        end
    end)
end
petBarRows = function()
    local rows = {}
    pcall(function()
        for i = 1, #PET_KEYS do
            local name, _, isToken = GetPetActionInfo(i)
            if name then
                local label = (isToken and _G[name]) or name
                rows[#rows + 1] = { tostring(i), tostring(name), (isToken and "token" or "spell"), petKeyFor(i), tostring(label) }
            end
        end
    end)
    return rows
end
local function keysWanted() return (ZENVC_EMOTES_ON == true) or (ZenVCExportDB._emotesOn == true) end

-- the game tells an add-on exactly what it blocked. Keep that, and stop trying.
local guard = CreateFrame("Frame")
guard:RegisterEvent("ADDON_ACTION_FORBIDDEN")
guard:RegisterEvent("ADDON_ACTION_BLOCKED")
guard:SetScript("OnEvent", function(_, ev, addonName, funcName)
    if addonName == "ZenVCExport" then
        local since = lastBoxAt and GetTime and string.format("%.0f s after a box of mine was shown", GetTime() - lastBoxAt) or "no box of mine had been shown"
        ZenVCExportDB._blocked = ZenVCExportDB._blocked or {}
        while #ZenVCExportDB._blocked >= 20 do table.remove(ZenVCExportDB._blocked, 1) end   -- keep the last 20 only
        ZenVCExportDB._blocked[#ZenVCExportDB._blocked + 1] = tostring(ev) .. ": " .. tostring(funcName) .. " (step: " .. tostring(ZenVCExportDB._step) .. "; last window action: " .. tostring(ZenVCExportDB._lastAct) .. "; " .. since .. ") " .. tostring(date("%Y-%m-%d %H:%M"))
        -- v51 the controller's own focus function is refused whenever an add-on touched a window the controller is moving in; that is not a hidden key
        -- going wrong, so the keys stay on (it switched every voice key off in the stress test). Anything else still switches them off.
        if tostring(funcName):find("SetPreferredGamepadInteractTarget") then
            print("VCF Helper: the game refused a controller focus change after one of my window actions. I wrote it down. Your voice keys stay on.")
            return
        end
        -- v74 (2026-11-09): this used to switch EVERY hidden key off until the next add-on version (_buttonsOff). One blocked window action
        -- (use() on 2026-11-07) left the person with no working voice keys for two days. Now only my question boxes go off; the keys stay on.
        ZenVCExportDB._boxesOff = true   -- no question box of mine will be shown again
        print("VCF Helper: the game blocked '" .. tostring(funcName) .. "'. I wrote it down for the voice commander. Your voice keys stay on.")
    end
end)

local function step(name) ZenVCExportDB._step = name end

-- v25 DIAGNOSTICS, so a key that "does nothing" can be understood from the saved file: every time one of my hidden buttons is pressed it is counted (with the time),
-- and the last few red messages the game showed ("Requires a fishing pole", "You cannot do that now"...) are kept. Reads and writes only my own saved data.
local lastClickAt = -100
-- v28 ONE timeline in _casts, newest last (the last 60): each press of a hidden button, and EVERY spell event of the player, each with the time since login and how many
-- seconds after the last hidden press it happened. A cast caused by the key lands within a fraction of a second of its press; one the person made with their own
-- button comes seconds later. (v26 only kept casts within 4 s of a press, which could not tell the two apart.)
local function castNote(text)
    pcall(function()
        ZenVCExportDB._casts = ZenVCExportDB._casts or {}
        while #ZenVCExportDB._casts >= 60 do table.remove(ZenVCExportDB._casts, 1) end
        local now = GetTime and GetTime() or 0
        ZenVCExportDB._casts[#ZenVCExportDB._casts + 1] = date("%H:%M:%S") .. string.format(" t=%.2f  ", now) .. text
    end)
end
-- v38 EVIDENCE for later: every hidden /cast or /use key press is judged 1.5 seconds afterward. For "/cast Name" the game must have started, sent, finished or failed THAT spell
-- (the player's or the pet's: a pet spell like Growl or Cower reports for the pet); for "/use Item" any spell event other than auto attacks counts. Anything else is "none".
-- Matching by name stops an Auto Shot or Attack in the middle of a fight from counting as the key working. Written per character and per command in _hiddenResult
-- {ok, none, at}. This is how we learned Rockbiter Weapon and Fishing cannot be cast from a hidden key; any other command that cannot be shows up here too.
local recentSpellEvents = {}
local IGNORE_EVENT = { ["auto shot"] = true, ["attack"] = true, ["shoot"] = true, ["auto attack"] = true }
local function noteSpellEvent(name)
    recentSpellEvents[#recentSpellEvents + 1] = { at = GetTime and GetTime() or 0, name = (name or ""):lower() }
    while #recentSpellEvents > 60 do table.remove(recentSpellEvents, 1) end
end
local function eventSince(at, want)
    for i = #recentSpellEvents, 1, -1 do
        local e = recentSpellEvents[i]
        if e.at < at then break end
        if want then if e.name == want then return true end
        elseif not IGNORE_EVENT[e.name] then return true end
    end
    return false
end
local function judgeHiddenPress(frame)
    pcall(function()
        if not (frame and frame.GetAttribute and C_Timer and C_Timer.After) then return end
        local mt = frame:GetAttribute("macrotext") or frame.zvText
        if not mt or not (mt:find("^/cast") or mt:find("^/use")) then return end
        local want = mt:match("^/cast%s+(.-)%s*$")
        if want then want = want:gsub("^%[.-%]%s*", ""):gsub("%(.-%)$", ""):lower() end
        local at = GetTime and GetTime() or 0
        C_Timer.After(1.5, function()
            pcall(function()
                ZenVCExportDB._hiddenResult = ZenVCExportDB._hiddenResult or {}
                local k = charKey()
                ZenVCExportDB._hiddenResult[k] = ZenVCExportDB._hiddenResult[k] or {}
                local r = ZenVCExportDB._hiddenResult[k][mt] or { ok = 0, none = 0 }
                if eventSince(at, want) then r.ok = r.ok + 1 else r.none = r.none + 1 end
                r.at = date("%Y-%m-%d %H:%M:%S")
                ZenVCExportDB._hiddenResult[k][mt] = r
            end)
        end)
    end)
end
local function noteClick(id, frame)
    lastClickAt = GetTime and GetTime() or 0
    judgeHiddenPress(frame)
    castNote("PRESS of hidden button " .. tostring(id))
    pcall(function()
        ZenVCExportDB._clicks = ZenVCExportDB._clicks or {}
        local c = ZenVCExportDB._clicks[id]
        if not c then c = { n = 0 }; ZenVCExportDB._clicks[id] = c end
        c.n = c.n + 1
        c.at = date("%Y-%m-%d %H:%M:%S")
        -- v27 what kind of button it was at the moment of the press (macro / action slot N / spell), so a press that did nothing can be explained
        if frame and frame.GetAttribute then
            c.type = tostring(frame:GetAttribute("type"))
            c.action = tostring(frame:GetAttribute("action"))
            c.spell = tostring(frame:GetAttribute("spell"))
            c.macro = tostring(frame:GetAttribute("macrotext") or frame.zvText)
            c.item = tostring(frame:GetAttribute("item"))
        end
    end)
end
-- v26 what the game did with the spell after a hidden button was pressed: the player's own cast events (sent, started, failed, interrupted, stopped...) in the 4 seconds
-- after a press, with the spell number and name. Kept as the last 30 in _casts. Only my own saved data is written.
local castFrame = CreateFrame("Frame")
for _, e in ipairs({ "UNIT_SPELLCAST_SENT", "UNIT_SPELLCAST_START", "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_CHANNEL_STOP",
                     "UNIT_SPELLCAST_FAILED", "UNIT_SPELLCAST_FAILED_QUIET", "UNIT_SPELLCAST_INTERRUPTED", "UNIT_SPELLCAST_SUCCEEDED" }) do
    pcall(function() if castFrame.RegisterUnitEvent then castFrame:RegisterUnitEvent(e, "player", "pet") else castFrame:RegisterEvent(e) end end)
end
castFrame:SetScript("OnEvent", function(_, ev, unit, a, b, c)
    if unit ~= "player" and unit ~= "pet" then return end
    pcall(function()
        local id = (ev == "UNIT_SPELLCAST_SENT") and c or b      -- SENT carries the target first: (unit, target, castGUID, spellID); the others (unit, castGUID, spellID)
        local name
        if id and C_Spell and C_Spell.GetSpellName then name = C_Spell.GetSpellName(id) end
        if id and not name and GetSpellInfo then name = GetSpellInfo(id) end
        noteSpellEvent(name)
        local since = (GetTime and GetTime() or 0) - lastClickAt
        castNote(string.format("%-14s spell %s %s   (%s)", (ev:gsub("^UNIT_SPELLCAST_", "")), tostring(id), tostring(name),
            since < 10 and string.format("+%.2fs after the last hidden press", since) or string.format("%.0fs after the last hidden press, so the key did not cause it", since)))
    end)
end)
local errFrame = CreateFrame("Frame")
pcall(function() errFrame:RegisterEvent("UI_ERROR_MESSAGE") end)
errFrame:SetScript("OnEvent", function(_, ev, a, b)
    if ev ~= "UI_ERROR_MESSAGE" then return end
    pcall(function()
        local msg = (type(b) == "string" and b) or (type(a) == "string" and a) or "?"
        ZenVCExportDB._errors = ZenVCExportDB._errors or {}
        while #ZenVCExportDB._errors >= 12 do table.remove(ZenVCExportDB._errors, 1) end
        ZenVCExportDB._errors[#ZenVCExportDB._errors + 1] = date("%H:%M:%S") .. "  " .. msg
    end)
end)


-- "/dance" -> "DANCE": the game lists every emote with its commands and its token
local NOT_EMOTES = {}
for w in ("cast use castsequence castrandom startattack stopattack stopcasting stopmacro equip equipslot target targetenemy targetfriend focus clearfocus assist cancelaura cancelform dismount userandom petattack petfollow petstay reload console run script click logout quit camp random roll tar assisttarget"):gmatch("%S+") do NOT_EMOTES[w] = true end
local emoteTokens
local function emoteToken(word)
    if not emoteTokens then
        emoteTokens = {}
        for i = 0, 500 do
            local tok = _G["EMOTE" .. i .. "_TOKEN"]
            if tok then
                for c = 1, 4 do
                    local cmd = _G["EMOTE" .. i .. "_CMD" .. c]
                    if cmd then emoteTokens[cmd:lower()] = tok end
                end
            end
        end
    end
    local tok = emoteTokens[(word or ""):lower()]
    if tok then return tok end
    -- the game's emote list could not be read: for a plain word that is clearly not a spell/target/UI command, the emote's
    -- token is that word in capitals (/dance -> DANCE). A wrong guess does nothing.
    local w = (word or ""):lower():gsub("^/", "")
    if next(emoteTokens) == nil and not NOT_EMOTES[w] then return w:upper() end
    return nil
end

-- v24 A profession ability such as Fishing is not in the spellbook list the game gives an add-on, so "/cast Fishing" may not find it by name. The same
-- ability sits on one of the person's own bar buttons, and pressing THAT button's action casts exactly the right thing. So for a plain "/cast Name" whose
-- spell is not in the spellbook list, the hidden key presses the action slot that holds it. Everything else stays a macro, as before.
local zvKnown, zvKnownAt
local function knownCached()
    local t = GetTime and GetTime() or 0
    if not zvKnown or not zvKnownAt or t - zvKnownAt > 2 then zvKnown = knownSpells(); zvKnownAt = t end
    return zvKnown
end

local function slotOfSpell(name)
    local want = name:lower()
    for slot = 1, 400 do
        local ok, kind, id = pcall(GetActionInfo, slot)
        if ok and kind == "spell" and id and id ~= 0 then
            local n
            if C_Spell and C_Spell.GetSpellName then n = C_Spell.GetSpellName(id) end
            if not n and GetSpellInfo then n = GetSpellInfo(id) end
            if n and n:lower() == want then return slot end
        end
    end
    return nil
end

local function slotOfItem(name)
    local want = name:lower()
    for slot = 1, 400 do
        local ok, kind, id = pcall(GetActionInfo, slot)
        if ok and kind == "item" and id and id ~= 0 then
            local n
            if C_Item and C_Item.GetItemNameByID then n = C_Item.GetItemNameByID(id) end
            if not n and GetItemInfo then n = GetItemInfo(id) end
            if n and n:lower() == want then return slot end
        end
    end
    return nil
end

local function setButtonAction(f, b)
    f.zvText = b.text
    -- TESTING (v25): four different ways to cast one ability, named in the button's text ("/vcfslot Fishing"), so the person can say each one and we learn which
    -- way the game accepts. slot = press the bar slot that holds it; id = cast by its spell number; spell = cast by its name as a spell; macro = "/cast Name".
    local tmode, tname = b.text:match("^/vcf(%a+)%s+(.-)%s*$")
    if tmode and tname and tname ~= "" then
        local tslot = slotOfSpell(tname)
        local tid
        if tslot then local _, sid = GetActionInfo(tslot); tid = sid end
        f:SetAttribute("type", "macro"); f:SetAttribute("macrotext", "/cast " .. tname); f:SetAttribute("action", nil); f:SetAttribute("spell", nil)   -- the fallback
        if tmode == "slot" and tslot then f:SetAttribute("type", "action"); f:SetAttribute("action", tslot); f:SetAttribute("macrotext", nil)
        elseif tmode == "id" and tid then f:SetAttribute("type", "spell"); f:SetAttribute("spell", tid); f:SetAttribute("macrotext", nil)
        elseif tmode == "spell" then f:SetAttribute("type", "spell"); f:SetAttribute("spell", tname); f:SetAttribute("macrotext", nil) end
        f.zvSlot = tslot
        return
    end
    -- a plain "/use Item Name" (no brackets, semicolons or numbers): press the bar slot holding the item, else use the item by name
    local useName = b.text:match("^/use%s+(.-)%s*$")
    if useName and useName ~= "" and not useName:find("[%[%];,]") and not useName:find("^%d") then
        local islot = slotOfItem(useName)
        if islot then
            f:SetAttribute("type", "action"); f:SetAttribute("action", islot); f:SetAttribute("macrotext", nil); f:SetAttribute("item", nil)
            f.zvSlot = islot
        else
            f:SetAttribute("type", "item"); f:SetAttribute("item", useName); f:SetAttribute("macrotext", nil); f:SetAttribute("action", nil)
            f.zvSlot = nil
        end
        return
    end
    local castName = b.text:match("^/cast%s+(.-)%s*$")
    if castName and castName:find("[%[%];,]") then castName = nil end   -- only a plain "/cast Name"
    local slot
    if castName and castName ~= "" and not knownCached()[castName] then slot = slotOfSpell(castName) end
    if slot then
        f:SetAttribute("type", "action"); f:SetAttribute("action", slot); f:SetAttribute("macrotext", nil)
        f.zvSlot = slot
    else
        f:SetAttribute("type", "macro"); f:SetAttribute("macrotext", b.text); f:SetAttribute("action", nil)
        f.zvSlot = nil
    end
end

-- v31 THE QUEST BUTTON. With a controller the quest window is answered by the controller's A button, and "/click QuestFrameAcceptButton" found nothing to click
-- (the key arrived and the click ran, the log proved it, yet no quest was accepted). So the key now does what the player means: click whichever quest button is
-- on screen (Accept, Continue, Complete Quest); with the controller those buttons are hidden, so it asks the game itself: hand in the quest (Continue, then the
-- reward when there is nothing to choose) or accept the one on offer. It also writes down which quest and
-- dialog windows were visible and what it did (_quest in the saved data), so that a failure is explained rather than silent.
-- v122 the quest greeting list (its functions are filled in further down, where the outline code is)
local QG = {}
-- 2026-11-11 (user: "the hint of what to say from the users own control panel is a huge help"): this character's own words for a command
-- (written by the voice commander into ZENVC_CHAR_WORDS), else the usual word
function QG.word(text, fallback)
    local gid = UnitGUID and UnitGUID("player")
    local name = UnitName and UnitName("player")
    local w = ZENVC_CHAR_WORDS and ((gid and ZENVC_CHAR_WORDS[gid]) or (name and ZENVC_CHAR_WORDS[name]))
    local v = w and w[text:lower()]
    return (type(v) == "string" and v ~= "") and v or fallback
end
local QUEST_BUTTONS = { "QuestFrameAcceptButton", "QuestFrameCompleteButton", "QuestFrameCompleteQuestButton" }
local function questStep()
    local rec = { at = date("%Y-%m-%d %H:%M:%S"), acted = "nothing", shown = {}, seen = {} }
    pcall(function()
        for _, n in ipairs({ "GossipFrame", "QuestFrame", "QuestFrameDetailPanel", "QuestFrameProgressPanel", "QuestFrameRewardPanel", unpack(QUEST_BUTTONS) }) do
            local fr = _G[n]
            rec.shown[#rec.shown + 1] = n .. "=" .. (fr and ((fr.IsVisible and fr:IsVisible()) and "shown" or "hidden") or "missing")
        end
        -- every window on screen with Quest, Gossip, Dialog or Gamepad in its name, so the real one can be told from the list
        for _, fr in ipairs({ UIParent:GetChildren() }) do
            local nm = fr.GetName and fr:GetName()
            if nm and fr.IsVisible and fr:IsVisible() and (nm:find("Quest") or nm:find("Gossip") or nm:find("Dialog") or nm:find("GamePad") or nm:find("Gamepad")) and #rec.seen < 25 then
                rec.seen[#rec.seen + 1] = nm
            end
        end
    end)
    -- v59 (2026-11-06, user: "can I just get an accept on those loot windows to take the item?"): the game sometimes leaves the loot window open with Auto Loot on
    -- (the v58 notes showed it deciding that by itself, per session). With a loot window open, Accept takes every item in it.
    local nLoot = GetNumLootItems and GetNumLootItems() or 0
    if nLoot > 0 and LootSlot then
        local took = 0
        for i = nLoot, 1, -1 do
            local ok = pcall(LootSlot, i)
            if ok then took = took + 1 end
        end
        rec.acted = "loot window: took " .. took .. " of " .. nLoot
        ZenVCExportDB._quest = rec
        return
    end
    if QG.open and QG.open() then   -- v122 the quest greeting list: accept opens the chosen quest, as select does (QG is filled in further down)
        local e = QG.chosen()
        rec.acted = "quest list: " .. (e and QG.pick(e) or (QG.first() or "no quest lines found"))
        ZenVCExportDB._quest = rec
        return
    end
    for _, n in ipairs(QUEST_BUTTONS) do
        local btn = _G[n]
        if btn and btn.IsVisible and btn:IsVisible() and (not btn.IsEnabled or btn:IsEnabled()) then
            local ok, err = pcall(btn.Click, btn)
            rec.acted = n .. (ok and " clicked" or (" failed: " .. tostring(err)))
            break
        end
    end
    local function up(n) local fr = _G[n]; return fr and fr.IsVisible and fr:IsVisible() end
    if rec.acted == "nothing" and up("QuestFrameRewardPanel") and GetQuestReward then
        -- handing in: the reward is taken only when there is nothing to choose (or one thing); with several rewards the choice is yours, so nothing is done
        local nch = GetNumQuestChoices and GetNumQuestChoices() or 0
        local chosen = QuestInfoFrame and QuestInfoFrame.itemChoice or 0
        if nch > 1 and chosen > 0 then   -- v106: the reward you selected (start move, select)
            local ok, err = pcall(GetQuestReward, chosen)
            rec.acted = "GetQuestReward(" .. chosen .. ") " .. (ok and "called" or ("failed: " .. tostring(err)))
        elseif nch > 1 then
            rec.acted = "reward window with " .. nch .. " rewards to choose from: left for you to choose"
            if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage("|cff2ee6d6VCF:|r choose a reward first: say start move, move to one, say select, then complete") end
        else
            local ok, err = pcall(GetQuestReward, nch == 1 and 1 or nil)
            rec.acted = "GetQuestReward() " .. (ok and "called" or ("failed: " .. tostring(err)))
        end
    elseif rec.acted == "nothing" and up("QuestFrameProgressPanel") and CompleteQuest then
        local ok, err = pcall(CompleteQuest)
        rec.acted = "CompleteQuest() " .. (ok and "called" or ("failed: " .. tostring(err)))
    elseif rec.acted == "nothing" and AcceptQuest then
        local ok, err = pcall(AcceptQuest)
        rec.acted = "AcceptQuest() " .. (ok and "called" or ("failed: " .. tostring(err)))
    end
    ZenVCExportDB._quest = rec
end

-- v32 BACK: what the controller's B button does on the NPC windows (the gossip window and the quest window): close it. Only those two are closed; with neither on
-- screen nothing happens (it never sends Escape, which would open the game menu). What it did is written down as _back in the saved data.
-- v120 EDIT LAYOUT BY VOICE (the functions are below, after the outline)
local EM = { on = false }

local function backStep()
    if EM.on and EM.cancel then EM.cancel() return end   -- v120 while editing, "back" is "cancel editing"
    local rec = { at = date("%Y-%m-%d %H:%M:%S"), acted = "nothing" }
    local function up(n) local fr = _G[n]; return fr and fr.IsVisible and fr:IsVisible() end
    pcall(function()
        if up("QuestFrame") and CloseQuest then
            CloseQuest(); rec.acted = "CloseQuest()"
        elseif up("GossipFrame") then
            if C_GossipInfo and C_GossipInfo.CloseGossip then C_GossipInfo.CloseGossip()
            elseif CloseGossip then CloseGossip() end
            rec.acted = "CloseGossip()"
        end
    end)
    ZenVCExportDB._back = rec
end

-- v46 the marker: which talk line or vendor item VCF points at. Cleared when the window closes.
local mark = { kind = nil, i = 0 }
local function isUp(n) local fr = _G[n]; return fr and fr.IsVisible and fr:IsVisible() end
local function say1(t) if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage("|cff2ee6d6VCF:|r " .. t) end end

local function gossipLines()
    local list = {}
    local box = GossipFrame and GossipFrame.GreetingPanel and GossipFrame.GreetingPanel.ScrollBox
    if box and box.ForEachFrame then
        box:ForEachFrame(function(fr)
            local d = fr.GetElementData and fr:GetElementData() or nil
            local info = d and d.info
            if info and (info.gossipOptionID or info.questID) and fr.Click then
                list[#list + 1] = { fr = fr, name = (fr.GetText and fr:GetText()) or info.name or info.title or "?" }
            end
        end)
    end
    return list
end

-- v122 the QUEST GREETING list (an NPC with several quests): its title buttons, top to bottom. Older windows name them QuestTitleButton1..;
-- newer ones keep them in a pool. Each knows its number in the list and whether it is a quest in progress (isActive).
local function qgreetLines()
    local list = {}
    local panel = _G.QuestFrameGreetingPanel
    if not (panel and panel.IsVisible and panel:IsVisible()) then return list end
    local seen = {}
    local function add(b)
        if b and not seen[b] and b.IsVisible and b:IsVisible() and b.GetText then
            local txt = b:GetText()
            if txt and txt ~= "" then seen[b] = true; list[#list + 1] = { fr = b, name = txt } end
        end
    end
    for i = 1, 40 do add(_G["QuestTitleButton" .. i]) end
    local pool = panel.titleButtonPool
    if pool and pool.EnumerateActive then pcall(function() for b in pool:EnumerateActive() do add(b) end end) end
    table.sort(list, function(a, b) return (a.fr:GetTop() or 0) > (b.fr:GetTop() or 0) end)
    return list
end
-- opens that quest the way its own button does: its number in the list, as a quest to pick up or one in progress
local function qgreetPick(e)
    local b = e.fr
    local id = b.GetID and b:GetID() or 0
    if id and id > 0 and (b.isActive ~= nil) then
        local active = b.isActive == 1 or b.isActive == true
        local fn = active and SelectActiveQuest or SelectAvailableQuest
        if fn then local ok, err = pcall(fn, id); return (active and "quest in progress " or "quest to pick up ") .. tostring(e.name) .. (ok and "" or (" failed: " .. tostring(err))) end
    end
    local ok, err = pcall(b.Click, b)
    return "pressed " .. tostring(e.name) .. (ok and "" or (" failed: " .. tostring(err)))
end
-- the line to open: the one start move points at, else the one the controller (or mouse) has highlighted, else the first
local function qgreetChosen()
    local list = qgreetLines()
    if mark.kind == "qgreet" and list[mark.i] then return list[mark.i] end
    for _, e in ipairs(list) do
        local f = e.fr
        if (f.IsHighlightLocked and f:IsHighlightLocked()) or (f.IsMouseMotionFocus and f:IsMouseMotionFocus()) or (f.IsMouseOver and f:IsMouseOver()) or (f.GetButtonState and f:GetButtonState() == "PUSHED") then return e end
    end
    return list[1]
end
local function qgreetFirstByNumber()
    if GetNumAvailableQuests and SelectAvailableQuest and (GetNumAvailableQuests() or 0) > 0 then SelectAvailableQuest(1) return "first quest to pick up" end
    if GetNumActiveQuests and SelectActiveQuest and (GetNumActiveQuests() or 0) > 0 then SelectActiveQuest(1) return "first quest in progress" end
end
QG.open = function() return isUp("QuestFrameGreetingPanel") end
QG.chosen, QG.pick, QG.first = qgreetChosen, qgreetPick, qgreetFirstByNumber

local function merchantOpen() return isUp("MerchantFrame") and (not MerchantFrame.selectedTab or MerchantFrame.selectedTab == 1) end
local function merchantSlots()
    local list = {}
    local per = MERCHANT_ITEMS_PER_PAGE or 10
    local page = (MerchantFrame and MerchantFrame.page) or 1
    local total = GetMerchantNumItems and GetMerchantNumItems() or 0
    for i = 1, per do
        local idx = (page - 1) * per + i
        local b = _G["MerchantItem" .. i .. "ItemButton"]
        if idx <= total and b and b:IsVisible() then
            local name
            if C_MerchantFrame and C_MerchantFrame.GetItemInfo then
                local info = C_MerchantFrame.GetItemInfo(idx)
                name = info and info.name
            end
            local label = _G["MerchantItem" .. i .. "Name"]
            if (not name or name == "") and label and label.GetText then name = label:GetText() end
            if (not name or name == "") and GetMerchantItemInfo then name = GetMerchantItemInfo(idx) end
            list[#list + 1] = { fr = _G["MerchantItem" .. i] or b, index = idx, name = name or "?" }
        end
    end
    return list
end

-- the marker itself: four bright bars around the chosen item or line, drawn above the window
local markFrame
local function markerOn(target)
    if not markFrame then
        markFrame = CreateFrame("Frame", "ZenVCMarker", UIParent)
        markFrame:SetFrameStrata("TOOLTIP")
        markFrame.bars = {}
        for k = 1, 4 do
            local t = markFrame:CreateTexture(nil, "OVERLAY")
            t:SetColorTexture(1, 0.6, 0.24, 1)   -- the user's orange (#ff993d)
            markFrame.bars[k] = t
        end
        local w = 4
        local b = markFrame.bars
        b[1]:SetPoint("TOPLEFT", markFrame, "TOPLEFT"); b[1]:SetPoint("TOPRIGHT", markFrame, "TOPRIGHT"); b[1]:SetHeight(w)
        b[2]:SetPoint("BOTTOMLEFT", markFrame, "BOTTOMLEFT"); b[2]:SetPoint("BOTTOMRIGHT", markFrame, "BOTTOMRIGHT"); b[2]:SetHeight(w)
        b[3]:SetPoint("TOPLEFT", markFrame, "TOPLEFT"); b[3]:SetPoint("BOTTOMLEFT", markFrame, "BOTTOMLEFT"); b[3]:SetWidth(w)
        b[4]:SetPoint("TOPRIGHT", markFrame, "TOPRIGHT"); b[4]:SetPoint("BOTTOMRIGHT", markFrame, "BOTTOMRIGHT"); b[4]:SetWidth(w)
    end
    markFrame:ClearAllPoints()
    markFrame:SetPoint("TOPLEFT", target, "TOPLEFT", -4, 4)
    markFrame:SetPoint("BOTTOMRIGHT", target, "BOTTOMRIGHT", 4, -4)
    markFrame:Show()
end
-- v61 (2026-11-07, user: "if destroy is the word used, then the highlight should go RED, if USE it should go teal")
local MARK_ORANGE, MARK_RED, MARK_TEAL = { 1, 0.6, 0.24 }, { 0.776, 0.157, 0.157 }, { 0.18, 0.902, 0.839 }   -- #ff993d, #C62828 (GSIV's delete red), #2ee6d6 (VCF teal)
local function markColor(c) if markFrame then for k = 1, 4 do markFrame.bars[k]:SetColorTexture(c[1], c[2], c[3], 1) end end end

-- CREDIT (v120): parts of the block below (reading the layouts, making a preset changeable, telling the gamepad UI from the mouse) follow
-- Improved Forever by markgravity, https://github.com/markgravity/ImprovedForever, used under its MIT license, reproduced here:
--   MIT License
--
--   Copyright (c) 2026 markg
--
--   Permission is hereby granted, free of charge, to any person obtaining a copy
--   of this software and associated documentation files (the "Software"), to deal
--   in the Software without restriction, including without limitation the rights
--   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--   copies of the Software, and to permit persons to whom the Software is
--   furnished to do so, subject to the following conditions:
--
--   The above copyright notice and this permission notice shall be included in all
--   copies or substantial portions of the Software.
--
--   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--   SOFTWARE.
-- The idea of changing the layout instead of the frames is also that of LibEditModeOverride by plusmouse (MIT); none of its code is used.
do   -- v120: its own block, so its names do not count toward the file's 200 (WoW's Lua limit)
-- v120 (2026-11-11, the user's plan, VOICE COMMANDER NOTES\EDIT MODE PLAN.md): EDIT LAYOUT BY VOICE (LIMITED EDITING: place and size only), with ONE new key.
-- "edit layout" turns editing on; while it is on, keys that already exist mean something else: move up/down/left/right nudge the selected piece,
-- move my box = next piece, keypad enter = previous piece (both harmless when not editing; select is never borrowed), box big / box small / box average = bigger / smaller / normal size, back = cancel editing
-- (puts the layout back as it was), stop move = done editing (keeps it). Off, every one of those keys does what it always did.
-- The method, learned from Improved Forever by markgravity (MIT) and LibEditModeOverride: the game's frames are never moved, and its Edit Mode
-- window is never opened, from here (both taint). The LAYOUT is changed (a piece's place, its size setting), saved, and made the active one
-- again, and the game places its own frames from it. A preset layout cannot be changed: the first change copies it into a layout of the
-- player's own, and says so. Out of combat only; combat ends editing. Nothing starts while the game's own Edit Mode window is open.
local EM_STEP = 5   -- pixels moved by one "move" step
local function emSay(msg) if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage("|cff2ee6d6VCF:|r " .. msg) end end
local function emReady()
    return C_EditMode and C_EditMode.GetLayouts and C_EditMode.SaveLayouts and Enum and Enum.EditModeSystem and Enum.EditModeLayoutType
        and EditModePresetLayoutManager and CopyTable and true or false
end
local function emGameEditing()
    local m = _G.EditModeManagerFrame
    return m and m.IsEditModeActive and m:IsEditModeActive() and true or false
end
-- the game's Gamepad UI on (Options > Gamepad); the game keeps the pad's layouts apart from the mouse's
local function emPadUI()
    local util = _G.InputUtil
    if util and util.IsGamepadUIEnabled then
        local ok, on = pcall(util.IsGamepadUIEnabled)
        if ok then return on and true or false end
    end
    local style = GetCVar and GetCVar("InputDeviceInterfaceStyle")
    local gamepad = Enum and Enum.InputDeviceInterfaceType and Enum.InputDeviceInterfaceType.Gamepad
    if style == nil or gamepad == nil then return true end
    return tostring(style) == tostring(gamepad)
end
-- the layouts as the game numbers them: its presets first, then the saved ones
local function emLayouts()
    local info = C_EditMode.GetLayouts()
    if not (info and info.layouts and info.activeLayout) then return end
    local all = EditModePresetLayoutManager:GetCopyOfPresetLayouts()
    for _, layout in ipairs(info.layouts) do all[#all + 1] = layout end
    info.layouts = all
    return info
end
local function emIsPreset(layout) return layout.layoutType == Enum.EditModeLayoutType.Preset end
-- the active layout made changeable: a preset swapped for our copy of it (made now, or already there); second value true when made now
local function emChangeable(info)
    local active = info.layouts[info.activeLayout]
    if not active or not emIsPreset(active) then return active, false end
    local name = emPadUI() and "Voice Commander" or "Voice Commander (Mouse)"
    for i, layout in ipairs(info.layouts) do
        if not emIsPreset(layout) and layout.layoutName == name then info.activeLayout = i; return layout, false end
    end
    local copy = CopyTable(active)
    copy.layoutType = Enum.EditModeLayoutType.Account
    copy.layoutName = name
    info.layouts[#info.layouts + 1] = copy
    info.activeLayout = #info.layouts
    return copy, true
end
local function emFrameFor(sys, idx)
    local m = _G.EditModeManagerFrame
    for _, f in ipairs((m and m.registeredSystemFrames) or {}) do
        if f.system == sys and f.systemIndex == idx then return f end
    end
end
local function emSystemKey(sys) for k, v in pairs(Enum.EditModeSystem) do if v == sys then return k end end end
local function emNameOf(pc)
    local f = emFrameFor(pc.system, pc.systemIndex)
    if f and f.GetSystemName then
        local ok, n = pcall(f.GetSystemName, f)
        if ok and type(n) == "string" and n ~= "" then return n end
    end
    return (emSystemKey(pc.system) or "piece") .. (pc.systemIndex and (" " .. pc.systemIndex) or "")
end
local function emSystem(layout, pc)
    for _, sy in ipairs(layout.systems or {}) do if sy.system == pc.system and sy.systemIndex == pc.systemIndex then return sy end end
end
-- v120 (user: "some things just were not on screen"): a piece counts only when it is really on screen now: its frame found, visible (it and
-- every frame it sits in), with a real size and not see-through. Keyboard and mouse mode shows more pieces than the gamepad UI; this follows that.
local function emOnScreen(f)
    if not (f and f.IsVisible and f:IsVisible()) then return false end
    local w, h = f.GetWidth and f:GetWidth() or 0, f.GetHeight and f:GetHeight() or 0
    if not (w > 2 and h > 2) then return false end
    if f.GetEffectiveAlpha and f:GetEffectiveAlpha() < 0.05 then return false end
    return true
end
local function emPieceOnScreen(pc) return pc ~= nil and emOnScreen(emFrameFor(pc.system, pc.systemIndex)) end
local function emShow()
    local pc = EM.pieces and EM.pieces[EM.i]
    local f = pc and emFrameFor(pc.system, pc.systemIndex)
    if emOnScreen(f) then markerOn(f); markColor(MARK_ORANGE) elseif markFrame then markFrame:Hide() end
end
local function emEnd(msg)
    EM.on = false
    EM.n = (EM.n or 0) + 1   -- a save still waiting is dropped
    if markFrame then markFrame:Hide() end
    if msg then emSay(msg) end
end
local function emOk()
    if not EM.on then return false end
    if InCombatLockdown() then emEnd("LIMITED EDITING ended: you are in combat.") return false end
    if emGameEditing() then emEnd("LIMITED EDITING ended: the game's own Edit Mode is open.") return false end
    return true
end
-- saved and made active: the game places its frames from the layout now
local function emApply()
    if not EM.changed or InCombatLockdown() then return end
    local ok, err = pcall(function()
        C_EditMode.SaveLayouts(EM.info)
        if C_EditMode.SetActiveLayout then C_EditMode.SetActiveLayout(EM.info.activeLayout) end
    end)
    if not ok then emSay("the layout could not be saved: " .. tostring(err)) return end
    if EM.said then emSay(EM.said); EM.said = nil end
    if C_Timer and C_Timer.After then C_Timer.After(0.2, function() if EM.on then emShow() end end) else emShow() end
end
-- a run of steps ("move up 20") is saved once, a moment after the last one
local function emLater(msg)
    EM.changed, EM.said = true, msg
    EM.n = (EM.n or 0) + 1
    local n = EM.n
    if C_Timer and C_Timer.After then C_Timer.After(0.4, function() if EM.n == n and EM.on then emApply() end end) else emApply() end
end
local function emEdit()
    local layout, made = emChangeable(EM.info)
    if made then emSay("the game's own layouts cannot be changed, so your changes go into a copy named \"" .. layout.layoutName .. "\". Say cancel editing to undo them.") end
    return layout
end

function EM.toggle()
    if EM.on then EM.done() return end
    if InCombatLockdown() then emSay("edit layout works out of combat only.") return end
    if not emReady() then emSay("this game has no Edit Mode layouts that the voice commander can reach.") return end
    if emGameEditing() then emSay("close the game's own Edit Mode first, then say edit layout.") return end
    local info = emLayouts()
    local active = info and info.layouts[info.activeLayout]
    if not active then emSay("the game's layouts could not be read.") return end
    local pieces = {}
    for _, sy in ipairs(active.systems or {}) do
        local pc = { system = sy.system, systemIndex = sy.systemIndex }
        if emPieceOnScreen(pc) then pieces[#pieces + 1] = pc end
    end
    if #pieces == 0 then emSay("nothing on screen can be edited right now.") return end
    mark.kind, mark.i = nil, 0
    EM.on, EM.info, EM.original, EM.pieces, EM.i, EM.changed, EM.said = true, info, CopyTable(info), pieces, 1, false, nil
    emShow()
    emSay("LIMITED EDITING on (place and size only). Editing: " .. emNameOf(pieces[1]) .. " (1 of " .. #pieces .. " on screen). Say next piece or previous piece, move up 5 and the other moves, bigger, smaller or normal size. Done editing keeps it; cancel editing puts it all back.")
end
function EM.done()
    if not EM.on then return end
    if EM.changed and not InCombatLockdown() then EM.n = (EM.n or 0) + 1; emApply() end
    emEnd("LIMITED EDITING off. Your changes are kept.")
end
function EM.cancel()
    if not EM.on then return end
    EM.n = (EM.n or 0) + 1
    if EM.changed then
        if InCombatLockdown() then emEnd("LIMITED EDITING ended in combat: the changes already saved stay. Edit again after combat.") return end
        local ok, err = pcall(function()
            C_EditMode.SaveLayouts(EM.original)
            if C_EditMode.SetActiveLayout then C_EditMode.SetActiveLayout(EM.original.activeLayout) end
        end)
        if not ok then emEnd("the layout could not be put back: " .. tostring(err)) return end
    end
    emEnd("LIMITED EDITING cancelled: the layout is back as it was.")
end
function EM.pick(d)
    if not emOk() then return end
    -- the next piece that is still on screen (one that has gone since editing started is skipped)
    local n = #EM.pieces
    for _ = 1, n do
        EM.i = ((EM.i - 1 + d) % n) + 1
        if emPieceOnScreen(EM.pieces[EM.i]) then
            emShow()
            emSay("editing: " .. emNameOf(EM.pieces[EM.i]) .. " (" .. EM.i .. " of " .. n .. ")")
            return
        end
    end
    if markFrame then markFrame:Hide() end
    emSay("nothing on screen can be edited right now.")
end
function EM.nudge(dir)
    if not emOk() then return end
    local pc = EM.pieces[EM.i]
    local sy = pc and emSystem(emEdit(), pc)
    if not (sy and sy.anchorInfo and type(sy.anchorInfo.offsetX) == "number") then emSay("this piece cannot be moved.") return end
    local dx = (dir == "left" and -EM_STEP) or (dir == "right" and EM_STEP) or 0
    local dy = (dir == "up" and EM_STEP) or (dir == "down" and -EM_STEP) or 0
    for _, a in ipairs({ sy.anchorInfo, sy.anchorInfo2 or false }) do
        if a and type(a.offsetX) == "number" and type(a.offsetY) == "number" then a.offsetX = a.offsetX + dx; a.offsetY = a.offsetY + dy end
    end
    sy.isInDefaultPosition = false
    emLater(emNameOf(pc) .. " moved.")
end
-- the piece's size slider (found by its setting's name in the game's own lists, so it does not depend on the game's language)
local function emSizeInfo(pc)
    local mgr = _G.EditModeSettingDisplayInfoManager
    if not mgr then return end
    local list
    if mgr.GetSystemSettingDisplayInfo then local ok, l = pcall(mgr.GetSystemSettingDisplayInfo, mgr, pc.system); if ok then list = l end end
    if type(list) ~= "table" and type(mgr.systemSettingDisplayInfo) == "table" then list = mgr.systemSettingDisplayInfo[pc.system] end
    if type(list) ~= "table" then return end
    local key = emSystemKey(pc.system)
    local enum = key and Enum["EditMode" .. key .. "Setting"]
    local slider = Enum.EditModeSettingDisplayType and Enum.EditModeSettingDisplayType.Slider
    for _, e in ipairs(list) do
        if e.type == slider and type(e.minValue) == "number" and type(e.maxValue) == "number" then
            local name
            if enum then for k, v in pairs(enum) do if v == e.setting then name = k end end end
            if name and (name:find("Size") or name:find("Scale")) then return e end
        end
    end
end
function EM.size(d)   -- +1 bigger, -1 smaller, 0 normal (100%)
    if not emOk() then return end
    local pc = EM.pieces[EM.i]
    local e = pc and emSizeInfo(pc)
    if not e then emSay(emNameOf(pc) .. " has no size to change by voice.") return end
    local sy = emSystem(emEdit(), pc)
    local cur
    for _, st in ipairs((sy and sy.settings) or {}) do if st.setting == e.setting then cur = st end end
    if not (cur and type(cur.value) == "number") then emSay("the size of " .. emNameOf(pc) .. " could not be read.") return end
    local step = (type(e.stepSize) == "number" and e.stepSize > 0) and e.stepSize or 1
    local index = cur.value < e.minValue or cur.value > e.maxValue   -- stored as a step number (0, 1, 2 ...), not as the number shown
    local shown = index and (e.minValue + cur.value * step) or cur.value
    local want = (d == 0) and 100 or (shown + d * step)
    want = math.max(e.minValue, math.min(e.maxValue, want))
    if want == shown then emSay(emNameOf(pc) .. " is already at " .. shown .. ".") return end
    cur.value = index and math.floor((want - e.minValue) / step + 0.5) or want
    emLater(emNameOf(pc) .. " size " .. want .. ".")
end
local emEvents = CreateFrame("Frame")
emEvents:RegisterEvent("PLAYER_REGEN_DISABLED")
emEvents:SetScript("OnEvent", function() if EM.on then emEnd("LIMITED EDITING ended: combat started. Changes already saved are kept.") end end)
end

-- v121 (2026-11-11, user: "IS it possible for this to read quest text?? that would be AMAZING" ... "can we build our own?"): READ QUEST.
-- One key, one word: "read quest" reads aloud what is open (the quest window's page, what an NPC says, or else the quest picked in the quest log)
-- with WoW's own text-to-speech, in the voice, speed and volume the player chose in WoW's own options. Said again, it stops. It never reads by
-- itself. Written for VCF from Blizzard's own functions; no other add-on's code is used, so no other add-on's update can break it.
local RQ = { reading = false }
do   -- its own block: WoW's Lua allows 200 names at the top of a file
local RQ_PIECE = 800   -- long text is read in pieces of up to this many letters, one after another
local function rqSay(msg) if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage("|cff2ee6d6VCF:|r " .. msg) end end
local function rqUp(n) local f = _G[n]; return f and f.IsVisible and f:IsVisible() end
local function rqCall(fn, ...) if type(fn) == "function" then local ok, a, b = pcall(fn, ...); if ok then return a, b end end end
-- the game's colour, picture and link codes are not words
local function rqClean(text)
    local x = tostring(text or "")
    x = x:gsub("|c%x%x%x%x%x%x%x%x", "")
    x = x:gsub("|r", "")
    x = x:gsub("|T.-|t", "")
    x = x:gsub("|A.-|a", "")
    x = x:gsub("|H.-|h(.-)|h", "%1")
    x = x:gsub("|n", " ")
    x = x:gsub("%s+", " ")
    x = x:gsub("^ ", "")
    x = x:gsub(" $", "")
    return x
end
local function rqPieces(text)
    local out = {}
    while #text > RQ_PIECE do
        local head = text:sub(1, RQ_PIECE)
        local cut = head:match("^.*()[%.%!%?]%s") or head:match("^.*()%s") or RQ_PIECE
        out[#out + 1] = text:sub(1, cut)
        text = text:sub(cut + 1)
        text = text:gsub("^%s+", "")
    end
    if #text > 0 then out[#out + 1] = text end
    return out
end
-- what is open, as (title, text, kind)
local function rqText()
    if rqUp("QuestFrame") then
        local title = rqCall(GetTitleText) or ""
        if rqUp("QuestFrameProgressPanel") then return title, rqCall(GetProgressText), "quest" end
        if rqUp("QuestFrameRewardPanel") then return title, rqCall(GetRewardText), "quest" end
        if rqUp("QuestFrameGreetingPanel") then return "", rqCall(GetGreetingText), "talk" end
        return title, (rqCall(GetQuestText) or "") .. " " .. (rqCall(GetObjectiveText) or ""), "quest"
    end
    if rqUp("GossipFrame") then
        local said = (C_GossipInfo and rqCall(C_GossipInfo.GetText)) or rqCall(GetGossipText)
        return "", said, "talk"
    end
    -- the quest picked in the quest log (Forever's quest log works the classic way: pick, then read)
    local i = rqCall(GetQuestLogSelection)
    if type(i) == "number" and i > 0 and GetQuestLogQuestText then
        local title, _, _, header = rqCall(GetQuestLogTitle, i)
        if not header then
            local d, o = rqCall(GetQuestLogQuestText)
            return title or "", (d or "") .. " " .. (o or ""), "log"
        end
    end
    -- newer games keep the log in C_QuestLog
    if C_QuestLog and C_QuestLog.GetSelectedQuest and C_QuestLog.GetLogIndexForQuestID and GetQuestLogQuestText then
        local id = rqCall(C_QuestLog.GetSelectedQuest)
        local idx = type(id) == "number" and id > 0 and rqCall(C_QuestLog.GetLogIndexForQuestID, id)
        if idx then
            local d, o = rqCall(GetQuestLogQuestText, idx)
            return (C_QuestLog.GetTitleForQuestID and rqCall(C_QuestLog.GetTitleForQuestID, id)) or "", (d or "") .. " " .. (o or ""), "log"
        end
    end
end
-- the voice, speed and volume the player chose in WoW's own text-to-speech options
local function rqVoice()
    local id
    if C_TTSSettings and C_TTSSettings.GetVoiceOptionID and Enum and Enum.TtsVoiceType then
        local v = rqCall(C_TTSSettings.GetVoiceOptionID, Enum.TtsVoiceType.Standard)
        if type(v) == "number" then id = v end
    end
    if id == nil then
        local voices = rqCall(C_VoiceChat.GetTtsVoices)
        if type(voices) == "table" and voices[1] then id = voices[1].voiceID end
    end
    local rate = C_TTSSettings and rqCall(C_TTSSettings.GetSpeechRate)
    local vol = C_TTSSettings and rqCall(C_TTSSettings.GetSpeechVolume)
    return id, type(rate) == "number" and rate or 0, type(vol) == "number" and vol or 100
end
local function rqStop() RQ.reading, RQ.pieces = false, nil end
local function rqNext()
    local piece = RQ.pieces and table.remove(RQ.pieces, 1)
    if not piece then rqStop() return end
    local id, rate, vol = rqVoice()
    if id == nil then rqStop(); rqSay("WoW has no text-to-speech voice to read with. Look in the game's options: Accessibility, Text to Speech.") return end
    local text = piece:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
    local ok, err = pcall(C_VoiceChat.SpeakText, id, text, rate, vol, false)   -- the way Forever's game takes it
    if not ok then
        local dest = (Enum and Enum.VoiceTtsDestination and (Enum.VoiceTtsDestination.LocalPlayback or Enum.VoiceTtsDestination.QueuedLocalPlayback)) or 1
        ok, err = pcall(C_VoiceChat.SpeakText, id, text, dest, rate, vol)       -- the older way
    end
    if not ok then rqStop(); rqSay("WoW's text-to-speech did not start: " .. tostring(err)) end
end
function RQ.toggle()
    if not (C_VoiceChat and C_VoiceChat.SpeakText) then rqSay("this game has no text-to-speech that add-ons can use.") return end
    if RQ.reading then
        rqStop()
        if C_VoiceChat.StopSpeakingText then pcall(C_VoiceChat.StopSpeakingText) end
        rqSay("reading stopped.")
        return
    end
    local title, body, kind = rqText()
    title = rqClean(title); body = rqClean(body)
    local text = (title ~= "" and (title .. ". ") or "") .. body
    if body == "" then rqSay("nothing to read: open a quest, talk to someone, or pick a quest in your quest log.") return end
    RQ.pieces, RQ.reading = rqPieces(text), true
    rqSay((kind == "talk" and "reading what they say." or "reading the quest.") .. " Say read quest again to stop.")
    rqNext()
end
local rqEvents = CreateFrame("Frame")
for _, ev in ipairs({ "VOICE_CHAT_TTS_PLAYBACK_FINISHED", "VOICE_CHAT_TTS_PLAYBACK_FAILED" }) do pcall(rqEvents.RegisterEvent, rqEvents, ev) end
rqEvents:SetScript("OnEvent", function(_, ev)
    if not RQ.reading then return end
    if ev == "VOICE_CHAT_TTS_PLAYBACK_FAILED" then rqStop(); rqSay("WoW's text-to-speech could not read that.") return end
    rqNext()   -- the next piece, or the end
end)
end
local armed = { kind = nil, at = 0 }   -- "use" or "destroy" waiting for VCF's yes
-- v74 (2026-11-09): "use that" no longer calls UseContainerItem. That function is PROTECTED in this game: on 2026-11-07 19:57 the game blocked it
-- (ADDON_ACTION_FORBIDDEN use()) and the old guard then switched every hidden key off, which made the game unplayable by voice. Now the first press
-- (out of combat) points the use key at a SECURE button whose macro is "/use <bag> <slot>", like a player's own macro; the second press (after the yes)
-- is the game-approved use. Afterwards, or when cancelled, the key goes back to its ordinary button.
local useSecure, useKey, usePlainId
local function useBindBack()
    if not useKey or not usePlainId or InCombatLockdown() then return end
    pcall(SetOverrideBindingClick, buttonOwner, true, useKey, BTN_PREFIX .. usePlainId, "LeftButton")
    useKey = nil
end
local function disarm() if armed.kind then armed.kind = nil; markColor(MARK_ORANGE) end; useBindBack(); if armed.unaim then local f = armed.unaim; armed.unaim = nil; pcall(f) end end   -- v95 unaim: finish trade
local function useArmSecure(e, key, plainId)
    if InCombatLockdown() or not key or key == "" or not plainId then return false end
    if not useSecure then
        useSecure = CreateFrame("Button", "ZenVCUseSecure", UIParent, "SecureActionButtonTemplate")
        useSecure:RegisterForClicks("AnyUp", "AnyDown")
        useSecure:SetAttribute("type", "macro")
        useSecure:HookScript("PostClick", function(_, _, down)
            local onDown = GetCVar and GetCVar("ActionButtonUseKeyDown") ~= "0"
            if down == nil or down == onDown then
                ZenVCExportDB._useThat = { at = date("%Y-%m-%d %H:%M:%S"), acted = "used " .. tostring(useSecure.zvName) .. " (secure /use)" }
                say1((isUp("TradeFrame") and "put in the trade: " or isUp("SendMailFrame") and "attached to the mail: " or "used ") .. tostring(useSecure.zvName))   -- v95
                armed.kind = nil; markColor(MARK_ORANGE)
                if C_Timer and C_Timer.After then C_Timer.After(0.3, useBindBack) else useBindBack() end
            end
        end)
    end
    useSecure:SetAttribute("macrotext", "/use " .. tostring(e.bag) .. " " .. tostring(e.slot))
    useSecure.zvName = e.name
    useKey, usePlainId = key, plainId
    SetOverrideBindingClick(buttonOwner, true, key, "ZenVCUseSecure", "LeftButton")
    return true
end
-- v64 (2026-11-07): the outline's tooltip is the add-on's OWN tooltip window. Using the game's GameTooltip (v61-v63) was shared with the game's controller code,
-- and the game then blocked SetPreferredGamepadInteractTarget ("ZenVCExport has been blocked...", 13:56 and 14:10). Nothing of the game's is set or called here.
-- v69 (2026-11-07, user: "the billy club I have is stuck on screen"): the tooltip's "Equipped" comparison boxes are the add-on's own too, and close with it.
local zvTip, zvCmp
local function tip()
    if not zvTip then
        zvTip = CreateFrame("GameTooltip", "ZenVCTooltip", UIParent, "GameTooltipTemplate")
        zvCmp = {}
        for k = 1, 2 do
            local ok, f = pcall(CreateFrame, "GameTooltip", "ZenVCCompare" .. k, UIParent, "ShoppingTooltipTemplate")
            if not ok or not f then f = CreateFrame("GameTooltip", "ZenVCCompare" .. k, UIParent, "GameTooltipTemplate") end
            zvCmp[k] = f
        end
        zvTip.shoppingTooltips = zvCmp
        zvTip:HookScript("OnHide", function() for _, f in ipairs(zvCmp) do f:Hide() end end)
    end
    return zvTip
end
local function unhover() pcall(function() if zvTip then zvTip:Hide() end; for _, f in ipairs(zvCmp or {}) do f:Hide() end end) end

-- v72 (2026-11-07, user: "can we introduce our own?" comparison): the game shows its "Equipped" comparison only beside its own controller cursor.
-- Ours: what you have on in the slot the outlined item goes in, in our own boxes. Read only (item links and what is worn); nothing of the game's is set.
local SLOTS = { INVTYPE_HEAD = {1}, INVTYPE_NECK = {2}, INVTYPE_SHOULDER = {3}, INVTYPE_BODY = {4}, INVTYPE_CHEST = {5}, INVTYPE_ROBE = {5},
    INVTYPE_WAIST = {6}, INVTYPE_LEGS = {7}, INVTYPE_FEET = {8}, INVTYPE_WRIST = {9}, INVTYPE_HAND = {10}, INVTYPE_FINGER = {11, 12},
    INVTYPE_TRINKET = {13, 14}, INVTYPE_CLOAK = {15}, INVTYPE_WEAPON = {16, 17}, INVTYPE_SHIELD = {17}, INVTYPE_2HWEAPON = {16},
    INVTYPE_WEAPONMAINHAND = {16}, INVTYPE_WEAPONOFFHAND = {17}, INVTYPE_HOLDABLE = {17}, INVTYPE_RANGED = {18}, INVTYPE_RANGEDRIGHT = {18},
    INVTYPE_THROWN = {18}, INVTYPE_RELIC = {18}, INVTYPE_TABARD = {19} }
local function outlinedLink(e)
    if e.bag ~= nil and e.slot then
        local info = C_Container and C_Container.GetContainerItemInfo and C_Container.GetContainerItemInfo(e.bag, e.slot)
        if info then return info.hyperlink end
        if GetContainerItemLink then return GetContainerItemLink(e.bag, e.slot) end
    elseif e.mailItem and GetSendMailItemLink then return GetSendMailItemLink(e.mailItem)   -- v95
    elseif e.gslot and GetGuildBankItemLink then return GetGuildBankItemLink(e.gtab, e.gslot)   -- v104
    elseif e.qchoice and GetQuestItemLink then return GetQuestItemLink("choice", e.qchoice)   -- v106
    elseif e.inAtt and GetInboxItemLink then return GetInboxItemLink(e.inIdx, e.inAtt)
    elseif e.tradeP and GetTradePlayerItemLink then return GetTradePlayerItemLink(e.tradeP)   -- v95
    elseif e.tradeT and GetTradeTargetItemLink then return GetTradeTargetItemLink(e.tradeT)
    elseif e.index and GetMerchantItemLink then
        return GetMerchantItemLink(e.index)
    elseif e.itemID then
        return (GetItemInfo and select(2, GetItemInfo(e.itemID))) or ("item:" .. e.itemID)   -- v77 an Auction House row
    end
end
-- v73 (2026-11-07): v72 showed no box. The plain GetItemInfoInstant gives nothing in this game (the itemUses list has always saved empty types), so the
-- slot is now found four ways, the first that answers wins: C_Item.GetItemInfoInstant, the old GetItemInfoInstant, GetItemInfo's equip slot, and last
-- (user: "it literally says which part it is for") the slot line our OWN tooltip shows ("Legs", "Chest"...). English words; another game language needs its own.
local SLOT_WORDS = { ["Head"] = "INVTYPE_HEAD", ["Neck"] = "INVTYPE_NECK", ["Shoulder"] = "INVTYPE_SHOULDER", ["Shirt"] = "INVTYPE_BODY",
    ["Chest"] = "INVTYPE_CHEST", ["Waist"] = "INVTYPE_WAIST", ["Legs"] = "INVTYPE_LEGS", ["Feet"] = "INVTYPE_FEET", ["Wrist"] = "INVTYPE_WRIST",
    ["Hands"] = "INVTYPE_HAND", ["Finger"] = "INVTYPE_FINGER", ["Trinket"] = "INVTYPE_TRINKET", ["Back"] = "INVTYPE_CLOAK",
    ["One-Hand"] = "INVTYPE_WEAPON", ["Main Hand"] = "INVTYPE_WEAPONMAINHAND", ["Off Hand"] = "INVTYPE_WEAPONOFFHAND",
    ["Held In Off-hand"] = "INVTYPE_HOLDABLE", ["Two-Hand"] = "INVTYPE_2HWEAPON", ["Ranged"] = "INVTYPE_RANGED", ["Thrown"] = "INVTYPE_THROWN",
    ["Relic"] = "INVTYPE_RELIC", ["Tabard"] = "INVTYPE_TABARD" }
local function slotOf(link)
    local loc, how
    if link then
        pcall(function() if C_Item and C_Item.GetItemInfoInstant then local _, _, _, l = C_Item.GetItemInfoInstant(link); if l and l ~= "" then loc, how = l, "C_Item.GetItemInfoInstant" end end end)
        if not loc then pcall(function() local _, _, _, l = GetItemInfoInstant(link); if l and l ~= "" then loc, how = l, "GetItemInfoInstant" end end) end
        if not loc then pcall(function() local l = select(9, GetItemInfo(link)); if l and l ~= "" then loc, how = l, "GetItemInfo" end end) end
    end
    if not loc then
        pcall(function()
            for i = 2, 6 do
                local fs = _G["ZenVCTooltipTextLeft" .. i]
                local w = fs and fs.GetText and fs:GetText()
                if w and SLOT_WORDS[w] then loc, how = SLOT_WORDS[w], "tooltip line " .. i .. " '" .. w .. "'" return end
            end
        end)
    end
    return loc, how
end
local function equippedFor(link)
    local out = {}
    local loc, how = slotOf(link)
    for _, slot in ipairs((loc and SLOTS[loc]) or {}) do
        -- a game version with no ranged slot compares ranged items with the main hand
        if slot == 18 and not pcall(GetInventorySlotInfo, "RANGEDSLOT") then slot = 16 end
        if GetInventoryItemLink("player", slot) then out[#out + 1] = slot end
    end
    return out
end

-- user: "be mindful of the size that we don't run off screen or block the BAG display nor the vendor menu". Rectangles in UIParent units.
local function uiRect(f)
    if not (f and f.IsVisible and f:IsVisible() and f.GetLeft and f:GetLeft() and f:GetBottom()) then return nil end
    local k = f:GetEffectiveScale() / UIParent:GetEffectiveScale()
    return { l = f:GetLeft() * k, r = f:GetRight() * k, b = f:GetBottom() * k, t = f:GetTop() * k }
end
local function keepClear()
    local list = {}
    local function add(f) local r = uiRect(f); if r then list[#list + 1] = r end end
    add(_G.MerchantFrame); add(_G.ContainerFrameCombinedBags); add(_G.AuctionHouseFrame); add(_G.TaxiFrame); add(_G.FlightMapFrame)   -- v77, v88
    for f = 1, 13 do add(_G["ContainerFrame" .. f]) end
    return list
end
local function covers(x, y, w, h, list)
    for _, r in ipairs(list) do
        if x < r.r and x + w > r.l and y < r.t and y + h > r.b then return true end
    end
    return false
end
-- the left edge for a group w wide at height y..y+h: nearest to the middle of the screen that covers nothing and stays on screen, or nil
local function findX(w, y, h, list)
    local W, H = UIParent:GetWidth(), UIParent:GetHeight()
    if w > W - 16 or y + h > H - 8 then return nil end
    local mid = (W - w) / 2
    local tries = { mid }
    for _, r in ipairs(list) do tries[#tries + 1] = r.r + 8; tries[#tries + 1] = r.l - 8 - w end
    local best
    for _, x in ipairs(tries) do
        if x >= 8 and x + w <= W - 8 and not covers(x, y, w, h, list) and (not best or math.abs(x - mid) < math.abs(best - mid)) then best = x end
    end
    return best
end
-- places our tooltip and its comparison boxes: in a row (ours, then the equipped items to the right), or if a row does not fit clear of the
-- bags and the vendor, the comparison boxes stacked above ours. Last resort: the row in the middle, kept on screen.
local function placeTips(t, shown, scale)
    local list, gap, y = keepClear(), 6, 140
    local boxes = { t }
    for _, f in ipairs(shown) do boxes[#boxes + 1] = f end
    local function size(f) return f:GetWidth() * scale, f:GetHeight() * scale + ((f.CompareHeader and f.CompareHeader:IsShown()) and 22 * scale or 0) end
    local rowW, rowH = 0, 0
    for i, f in ipairs(boxes) do local w, h = size(f); rowW = rowW + w + (i > 1 and gap or 0); rowH = math.max(rowH, h) end
    local function put(f, x, yy) f:ClearAllPoints(); f:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x / scale, yy / scale) end
    local x = findX(rowW, y, rowH, list)
    if x or #shown == 0 then
        x = x or (UIParent:GetWidth() - rowW) / 2
        for _, f in ipairs(boxes) do put(f, x, y); x = x + size(f) + gap end
        return
    end
    local colW, colH = 0, 0
    for i, f in ipairs(boxes) do local w, h = size(f); colW = math.max(colW, w); colH = colH + h + (i > 1 and gap or 0) end
    x = findX(colW, y, colH, list)
    if x then
        for _, f in ipairs(boxes) do local _, h = size(f); put(f, x, y); y = y + h + gap end
        return
    end
    x = (UIParent:GetWidth() - rowW) / 2
    for _, f in ipairs(boxes) do put(f, x, y); x = x + size(f) + gap end
end
local function markerOff() disarm(); unhover(); if markFrame then markFrame:Hide() end end

-- v83 (2026-11-09, user: the Auction House by VOICE only, "select" and "back" first). The add-on never clicks the game's windows itself (that brought
-- the blocked box before). Instead, while the outline is on an Auction House row, the "select" key is pointed at a SECURE button of the game's own
-- "click" kind, aimed at that row: pressing it is the game's own click, like a player's /click macro. "back" is aimed the same way at the Auction
-- House's own Back button whenever one is showing. Only out of combat; when the outline or the Back button is gone the keys go back to normal.
local function keyFor(text)
    for _, b in ipairs(effectiveButtons()) do if b.text and b.text:lower() == text then return b.key, b.id end end
end
local function secureClicker(name)
    local f = _G[name]
    if not f then
        f = CreateFrame("Button", name, UIParent, "SecureActionButtonTemplate")
        f:SetAttribute("type", "click")
    end
    f:RegisterForClicks((GetCVar and GetCVar("ActionButtonUseKeyDown") ~= "0") and "AnyDown" or "AnyUp")   -- one click per press
    return f
end
local function aimKey(text, secName, target)
    if InCombatLockdown() or buttonsOff() then return end
    local key, id = keyFor(text)
    if not key or key == "" or not id then return end
    local want = target and secName or (BTN_PREFIX .. id)
    if target then secureClicker(secName):SetAttribute("clickbutton", target) end
    if GetBindingAction(key, true) ~= "CLICK " .. want .. ":LeftButton" then SetOverrideBindingClick(buttonOwner, true, key, want, "LeftButton") end
end
local ahSelTarget, ahBackAimed
local guildAimed   -- v84
local ahCurFr, ahCurName, ahCurFlags, searchAimed   -- v85
local taxiAimFr   -- v88
local ahBuyAimed   -- v94
local mailSelTarget, mailGetTarget   -- v95
local pad = {}   -- v91 the keypad (filled in further down); declared here so the tooltip box can show what is typed

-- v95 (2026-11-09, user: "FINISH TRADE AS THE COMPLETION OF THE TRADE. SAY IT 2X SO WE CAN SEE THE TERMS OF THE TRADE"; outline on the trade window when it
-- opens: "YES"). The trade window as an outline list: a first line with the whole trade (who, what you give, what you get), your gold, silver and copper
-- boxes (select opens the number pad), what they give in money, and the six item slots of each side. Read only: nothing in the game's window is clicked.
local TM = {}   -- v95 trade and mail, v100 bank: their functions live in ONE table so the add-on stays under the game's 200 top-level names
do
function TM.tradeOpen() return isUp("TradeFrame") end
local function coins(c)
    c = tonumber(c) or 0
    if c <= 0 then return nil end
    -- v99 (2026-11-09 mail test: GetCoinText gave "11|TInterface\MoneyFrame\UI-CopperIcon...|t", picture code instead of words): plain words, made here
    local g, s, k = math.floor(c / 10000), math.floor((c % 10000) / 100), c % 100
    local parts = {}
    if g > 0 then parts[#parts + 1] = g .. " gold" end
    if s > 0 then parts[#parts + 1] = s .. " silver" end
    if k > 0 then parts[#parts + 1] = k .. " copper" end
    return table.concat(parts, " ")
end
function TM.tradeName()
    local n = UnitName and UnitName("NPC")
    if not n or n == "" then local fs = _G.TradeFrameRecipientNameText; n = fs and fs.GetText and fs:GetText() end
    return (n and n ~= "") and n or "the other player"
end
local function tradeSide(getInfo, money)
    local parts = {}
    for i = 1, 6 do
        local name, _, num = getInfo(i)
        if name and name ~= "" then parts[#parts + 1] = name .. (((tonumber(num) or 1) > 1) and (" x" .. num) or "") end
    end
    local m = coins(money)
    if m then parts[#parts + 1] = m end
    return (#parts > 0) and table.concat(parts, ", ") or "nothing"
end
function TM.tradeTerms()
    local give, get = "nothing", "nothing"
    pcall(function() give = tradeSide(GetTradePlayerItemInfo, GetPlayerTradeMoney and GetPlayerTradeMoney()) end)
    pcall(function() get = tradeSide(GetTradeTargetItemInfo, GetTargetTradeMoney and GetTargetTradeMoney()) end)
    return give, get
end
local TRADE_COIN = { { "Gold", "gold" }, { "Silver", "silver" }, { "Copper", "copper" } }
function TM.tradeSlots()
    local list = {}
    if not TM.tradeOpen() then return list end
    pcall(function()
        list[#list + 1] = { fr = TradeFrame, tradeLine = true, tradeHead = true, name = "trade with " .. TM.tradeName(), x = (TradeFrame:GetLeft() or 0) + 1, y = (TradeFrame:GetTop() or 0) + 100 }
        for _, c in ipairs(TRADE_COIN) do
            local box = _G["TradePlayerInputMoneyFrame" .. c[1]]
            if box and box:IsVisible() then
                local v = box:GetText() or ""
                list[#list + 1] = { fr = box, tradeLine = true, tradeBox = box, name = "your " .. c[2] .. ": " .. (v ~= "" and v or "0"), x = box:GetLeft() or 0, y = box:GetTop() or 0 }
            end
        end
        local rm = _G.TradeRecipientMoneyFrame
        if rm and rm:IsVisible() then
            local m = coins(GetTargetTradeMoney and GetTargetTradeMoney())
            list[#list + 1] = { fr = rm, tradeLine = true, name = m and ("they give money: " .. m) or "they give no money", x = rm:GetLeft() or 0, y = rm:GetTop() or 0 }
        end
        for i = 1, 6 do
            for _, side in ipairs({ { "TradePlayerItem", GetTradePlayerItemInfo, "you give: ", "your slot ", "tradeP" }, { "TradeRecipientItem", GetTradeTargetItemInfo, "they give: ", "their slot ", "tradeT" } }) do
                local b = _G[side[1] .. i .. "ItemButton"]
                if b and b:IsVisible() then
                    local name, _, num = side[2](i)
                    local e = { fr = b, tradeLine = true, x = b:GetLeft() or 0, y = b:GetTop() or 0 }
                    if name and name ~= "" then
                        e.name = side[3] .. name .. (((tonumber(num) or 1) > 1) and (" x" .. num) or "")
                        e[side[5]] = i
                    else
                        e.name = side[4] .. i .. ": empty"; e.empty = true
                    end
                    list[#list + 1] = e
                end
            end
        end
    end)
    return list
end
function TM.tradeTip(t, e)
    if e.empty then t:Hide() return false end
    if e.tradeP then t:SetTradePlayerItem(e.tradeP) return true end
    if e.tradeT then t:SetTradeTargetItem(e.tradeT) return true end
    if e.tradeHead then
        local give, get = TM.tradeTerms()
        t:SetText("Trade with " .. TM.tradeName(), 1, 1, 1)
        t:AddLine("You give: " .. give, 1, 1, 1, true)
        t:AddLine("You get: " .. get, 1, 0.82, 0, true)
        t:AddLine("Say finish trade twice to accept. Escape cancels.", 0.6, 0.6, 0.6, true)
    elseif e.tradeBox then
        t:SetText(tostring(e.name), 1, 1, 1)
        t:AddLine("Say select to open the number pad", 0.6, 0.6, 0.6)
    else
        t:SetText(tostring(e.name), 1, 1, 1)
    end
    return true
end
function TM.tradeMoneyApply()
    pcall(function()
        local function n(k) local b = _G["TradePlayerInputMoneyFrame" .. k]; return tonumber(b and b:GetText() or "") or 0 end
        local total = n("Gold") * 10000 + n("Silver") * 100 + n("Copper")
        if SetTradeMoney and (GetPlayerTradeMoney and GetPlayerTradeMoney() or -1) ~= total then SetTradeMoney(total) end
    end)
    if C_Timer and C_Timer.After then C_Timer.After(0.4, function() pcall(function()
        say1("you offer " .. (coins(GetPlayerTradeMoney and GetPlayerTradeMoney()) or "no money"))
    end) end) end
end

-- v95 (2026-11-09, user: "build together", mail with trade): the mailbox's Send Mail tab as an outline list: a first line with the whole mail, the name,
-- subject and letter boxes and the gold, silver and copper boxes (select opens the keypad), the attachment slots, and the mailbox's tabs (select opens
-- a tab: the game's own click, see aimKey). "send mail" said twice sends it, like "finish trade".
function TM.mailOpen() return isUp("MailFrame") end
function TM.mailSendOpen() return isUp("SendMailFrame") end
local function mailItem(i)
    local r = { GetSendMailItem(i) }
    if not r[1] then return nil end
    local count = (type(r[5]) == "number") and r[4] or r[3]   -- v99: this game gives name, itemID, texture, count, quality (r[5] a number); the old one name, texture, count, quality, canUse (2026-11-09: the texture 133910 was read as the count)
    return r[1] .. (((tonumber(count) or 1) > 1) and (" x" .. count) or "")
end
local function mailTermLines()
    local lines = {}
    pcall(function()
        local function tx(n) local b = _G[n]; return b and b.GetText and b:GetText() or "" end
        local to, sub = tx("SendMailNameEditBox"), tx("SendMailSubjectEditBox")
        lines[#lines + 1] = "To: " .. (to ~= "" and to or "(nobody yet)")
        lines[#lines + 1] = "Subject: " .. (sub ~= "" and sub or "(none)")
        local items = {}
        for i = 1, (ATTACHMENTS_MAX_SEND or 12) do local n = mailItem(i); if n then items[#items + 1] = n end end
        lines[#lines + 1] = "Items: " .. (#items > 0 and table.concat(items, ", ") or "none")
        local function n(k) local b = _G["SendMailMoney" .. k]; return tonumber(b and b:GetText() or "") or 0 end
        local m = coins(n("Gold") * 10000 + n("Silver") * 100 + n("Copper"))
        local cod = _G.SendMailCODButton and SendMailCODButton.GetChecked and SendMailCODButton:GetChecked()
        lines[#lines + 1] = (cod and "Cash on delivery: " or "Money: ") .. (m or "none")
    end)
    return lines
end
function TM.mailTerms() return table.concat(mailTermLines(), ". ") end
function TM.mailSlots()
    local list = {}
    if not TM.mailOpen() then return list end
    pcall(function()
        local function at(e, fr) e.fr, e.mailLine, e.x, e.y = fr, true, fr:GetLeft() or 0, fr:GetTop() or 0; list[#list + 1] = e; return e end
        if TM.mailSendOpen() then
            local h = at({ mailHead = true, name = "send mail" }, SendMailFrame); h.y = h.y + 100; h.x = h.x + 1
            for _, b in ipairs({ { "SendMailNameEditBox", "to" }, { "SendMailSubjectEditBox", "subject" }, { "SendMailBodyEditBox", "letter" } }) do
                local box = _G[b[1]]
                if box and box:IsVisible() then local v = box:GetText() or ""; at({ mailBox = box, name = b[2] .. ": " .. (v ~= "" and v or "(empty)") }, box) end
            end
            for _, c in ipairs(TRADE_COIN) do
                local box = _G["SendMailMoney" .. c[1]]
                if box and box:IsVisible() then local v = box:GetText() or ""; at({ mailBox = box, name = c[2] .. " to send: " .. (v ~= "" and v or "0") }, box) end
            end
            for i = 1, (ATTACHMENTS_MAX_SEND or 12) do
                local b = _G["SendMailAttachment" .. i]
                if b and b:IsVisible() then
                    local n = mailItem(i)
                    if n then at({ mailItem = i, name = "attached: " .. n }, b) else at({ empty = true, name = "attachment " .. i .. ": empty" }, b) end
                end
            end
        -- v95 (2026-11-09, user: "I need to be able to GET THAT (like buy that) from the mailbox TO my bags"; said once: "yep")
        elseif isUp("OpenMailFrame") and InboxFrame and InboxFrame.openMailID then   -- an open mail: its items and money
            local idx = InboxFrame.openMailID
            local _, _, sender, subject, money = GetInboxHeaderInfo(idx)
            local h = at({ inHead = idx, name = "mail from " .. tostring(sender or "?") .. ": " .. tostring(subject or "") }, OpenMailFrame); h.y = h.y + 100; h.x = h.x + 1
            for a = 1, (ATTACHMENTS_MAX_RECEIVE or 16) do
                local b = _G["OpenMailAttachmentButton" .. a]
                if b and b:IsVisible() then
                    local r = { GetInboxItem(idx, a) }
                    if r[1] then
                        local count = (type(r[5]) == "number") and r[4] or r[3]   -- v99: this game gives name, itemID, texture, count, quality (r[5] a number); the old one name, texture, count, quality, canUse (2026-11-09: the texture 133910 was read as the count)
                        at({ inIdx = idx, inAtt = a, mailTake = true, name = "attached: " .. r[1] .. (((tonumber(count) or 1) > 1) and (" x" .. count) or "") }, b)
                    end
                end
            end
            local mb = _G.OpenMailMoneyButton
            if mb and mb:IsVisible() and (tonumber(money) or 0) > 0 then at({ inIdx = idx, inMoney = money, mailTake = true, name = "money: " .. tostring(coins(money)) }, mb) end
            local cb = _G.OpenMailCancelButton or _G.OpenMailFrameCloseButton
            if cb and cb:IsVisible() then at({ mailClose = true, name = "close this mail" }, cb) end
        elseif isUp("InboxFrame") then   -- the inbox page: one line per mail
            local per = INBOXITEMS_TO_DISPLAY or 7
            local page = InboxFrame.pageNum or 1
            for i = 1, per do
                local b = _G["MailItem" .. i .. "Button"]
                if b and b:IsVisible() then
                    local idx = (page - 1) * per + i
                    local _, _, sender, subject = GetInboxHeaderInfo(idx)
                    if sender or subject then at({ inRow = idx, name = "mail from " .. tostring(sender or "?") .. ": " .. tostring(subject or "") }, b) end
                end
            end
        end
        for i = 1, 2 do
            local tb = _G["MailFrameTab" .. i]
            if tb and tb:IsVisible() then at({ mailTab = true, name = tostring(tb.GetText and tb:GetText() or ("tab " .. i)) .. " tab" }, tb) end
        end
    end)
    return list
end
function TM.mailFirst(list)   -- the first mail of the inbox, else the Send Mail tab
    if TM.mailSendOpen() or isUp("OpenMailFrame") then return 1 end
    for k, e in ipairs(list) do if e.inRow then return k end end
    for k, e in ipairs(list) do if e.mailTab and e.fr == _G.MailFrameTab2 then return k end end
    return 1
end
-- v98 (2026-11-09, user: the game's list of "my alt characters ... would be a great option, since we have to use last names"): the names the game
-- itself suggests for the To box, read with GetAutoCompleteResults (read only). If it gives none, this account's characters on this realm.
function TM.mailNames()
    local out, seen, raw = {}, {}, 0
    local me = UnitName and UnitName("player")
    local function add(n)
        if type(n) == "string" and n ~= "" and n ~= me and not seen[n:lower()] and #out < 12 then seen[n:lower()] = true; out[#out + 1] = n end
    end
    pcall(function()
        local l = AUTOCOMPLETE_LIST and AUTOCOMPLETE_LIST.MAIL
        local inc = (l and l.include) or AUTOCOMPLETE_FLAG_ALL or 0xffffffff
        local exc = (l and l.exclude) or 0
        local r = { GetAutoCompleteResults("", 12, 0, true, inc, exc) }
        local list = (type(r[1]) == "table" and r[1].name == nil) and r[1] or r   -- one table of results, or several returns
        for _, x in ipairs(list) do raw = raw + 1; add(type(x) == "table" and x.name or x) end
    end)
    local fromGame = #out
    if #out == 0 then
        pcall(function()
            local realm = GetRealmName and GetRealmName()
            for _, v in pairs(ZenVCExportDB) do
                if type(v) == "table" and type(v.name) == "string" and v.realm == realm then add(v.name) end
            end
            table.sort(out)
        end)
    end
    return out
end

-- v100 (2026-11-09, user: the bank "more like tabs, much like the AH ... MOVE DOWN that tab list ... from there it is just MOVE THAT from one spot to
-- another"). START MOVE at the bank outlines its slots and its tabs. Each item slot of the open bank window is found by what it is (a button that
-- knows its bag and slot), and each tab by its name, so the outline follows whatever the game draws. Read only: "select" on a tab is the game's own
-- click on it (see aimKey); "move that" picks up and puts down (PickupContainerItem, as the bags' destroy already does).
function TM.bankOpen() return isUp("BankFrame") end
function TM.bankSlots()
    local list = {}
    if not TM.bankOpen() then return list end
    pcall(function()
        local seen = {}
        local function scan(fr, depth)
            if depth > 8 then return end
            for _, c in ipairs({ fr:GetChildren() }) do
                if c.IsVisible and c:IsVisible() and not seen[c] then
                    seen[c] = true
                    -- v101 (2026-11-09 20:11 bank test: the outline found nothing): this game's bank slots (unnamed buttons inside BankPanel) give their
                    -- place as GetBankTabID / GetContainerSlotID, not GetBagID / GetID like bag slots. A tab button carries its tab data.
                    local td
                    pcall(function() td = c.tabData or (c.GetTabData and c:GetTabData()) end)
                    local bag, slot
                    if not td then
                        pcall(function()
                            bag = (c.GetBankTabID and c:GetBankTabID()) or (c.GetBagID and c:GetBagID())
                            slot = (c.GetContainerSlotID and c:GetContainerSlotID()) or (c.GetID and c:GetID())
                        end)
                    end
                    local dn = (c.GetDebugName and c:GetDebugName()) or (c.GetName and c:GetName()) or ""
                    if bag ~= nil and slot and slot > 0 and c.GetLeft and c:GetLeft() then
                        local name = "empty"
                        local info = C_Container and C_Container.GetContainerItemInfo and C_Container.GetContainerItemInfo(bag, slot)
                        if info and info.itemID then
                            name = (C_Item and C_Item.GetItemNameByID and C_Item.GetItemNameByID(info.itemID)) or (info.hyperlink and info.hyperlink:match("%[(.-)%]")) or "an item"
                            if (info.stackCount or 1) > 1 then name = name .. " x" .. info.stackCount end
                        end
                        list[#list + 1] = { fr = c, bag = bag, slot = slot, name = name, x = c:GetLeft(), y = c:GetTop() or 0 }
                    elseif (td or dn:find("Tab")) and c.GetObjectType and (c:GetObjectType() == "Button" or c:GetObjectType() == "CheckButton") and c.GetLeft and c:GetLeft() then
                        local tn = (type(td) == "table" and td.name) or (c.GetText and c:GetText()) or ""
                        if tn == "" then tn = "tab" end
                        list[#list + 1] = { fr = c, bankTab = true, name = tostring(tn) .. " (tab: say select to open it)", x = c:GetLeft(), y = c:GetTop() or 0 }
                    elseif c.GetObjectType and (c:GetObjectType() == "Button" or c:GetObjectType() == "CheckButton") and c.GetLeft and c:GetLeft()
                        and not dn:find("CopperButton") and not dn:find("SilverButton") and not dn:find("GoldButton") then
                        -- v102 (2026-11-09, user: "there IS a purchase ... I need to be able to get to it"; "the TAB on the right ... I need to be able to"):
                        -- every other button of the bank window (Purchase, the bag slots, a tab on the side, sort, close) is a stop too; select is the
                        -- game's own click on it (the game asks its own question before buying). Its words: its text, else the last part of its name.
                        local tx = c.GetText and c:GetText()
                        local nm = (type(tx) == "string" and tx:find("%a")) and tx or (dn:match("([%a]+)$") or "")
                        if nm:match("^%x+$") then nm = "" end
                        nm = nm:gsub("(%l)(%u)", "%1 %2")
                        if nm == "" then nm = "button" end
                        local bf = BankFrame.GetRight and BankFrame:GetRight()
                        if bf and c:GetLeft() >= bf - 4 then nm = nm .. " (tab on the side)" end
                        if c.IsEnabled and not c:IsEnabled() then nm = nm .. " (not available now)" end
                        list[#list + 1] = { fr = c, bankBtn = true, name = nm .. ": say select to press it", x = c:GetLeft(), y = c:GetTop() or 0 }
                    else
                        scan(c, depth + 1)
                    end
                end
            end
        end
        scan(BankFrame, 0)
        table.sort(list, function(a, b) if math.abs(a.y - b.y) > 6 then return a.y > b.y end return a.x < b.x end)
    end)
    return list
end
-- v104 (2026-11-09, user, agreed order: the bank, then the guild bank, "guild banks work in similar ways"). START MOVE at the guild bank outlines the
-- slots of the tab on show, its tabs and its other buttons (Deposit, Withdraw ...). A slot is a button inside a Column of GuildBankFrame; its slot
-- number is its ID and its tab the one on show. Read only: select is the game's own click on a tab or button; "move that" picks up and puts down
-- (PickupGuildBankItem for a guild slot, like the bank). The guild's own rules (what you may take out) are the game's.
function TM.gbankOpen() return isUp("GuildBankFrame") end
function TM.gbankSlots()
    local list = {}
    if not TM.gbankOpen() then return list end
    pcall(function()
        local tab = GetCurrentGuildBankTab and GetCurrentGuildBankTab() or 1
        local seen = {}
        local function scan(fr, depth, inColumn)
            if depth > 8 then return end
            for _, c in ipairs({ fr:GetChildren() }) do
                if c.IsVisible and c:IsVisible() and not seen[c] then
                    seen[c] = true
                    local dn = (c.GetDebugName and c:GetDebugName()) or (c.GetName and c:GetName()) or ""
                    local ot = c.GetObjectType and c:GetObjectType()
                    local isBtn = ot == "Button" or ot == "CheckButton" or ot == "ItemButton"
                    local col = inColumn or dn:find("Column") ~= nil
                    if isBtn and col and c.GetID and c:GetID() > 0 and c.GetLeft and c:GetLeft() then
                        local slot = c:GetID()
                        local name = "empty"
                        local link = GetGuildBankItemLink and GetGuildBankItemLink(tab, slot)
                        if link then
                            name = link:match("%[(.-)%]") or "an item"
                            local _, count = GetGuildBankItemInfo(tab, slot)
                            if (tonumber(count) or 1) > 1 then name = name .. " x" .. count end
                        end
                        list[#list + 1] = { fr = c, gtab = tab, gslot = slot, name = name, x = c:GetLeft(), y = c:GetTop() or 0 }
                    elseif isBtn and c.GetLeft and c:GetLeft() and not dn:find("CopperButton") and not dn:find("SilverButton") and not dn:find("GoldButton") then
                        local tx = c.GetText and c:GetText()
                        local nm = (type(tx) == "string" and tx:find("%a")) and tx or (dn:match("([%a]+)$") or "")
                        if nm:match("^%x+$") then nm = "" end
                        nm = nm:gsub("(%l)(%u)", "%1 %2")
                        if nm == "" then nm = "button" end
                        if dn:find("Tab") then nm = nm .. " (tab)" end
                        if c.IsEnabled and not c:IsEnabled() then nm = nm .. " (not available now)" end
                        list[#list + 1] = { fr = c, bankBtn = true, name = nm .. ": say select to press it", x = c:GetLeft(), y = c:GetTop() or 0 }
                    else
                        scan(c, depth + 1, col)
                    end
                end
            end
        end
        scan(GuildBankFrame, 0, false)
        table.sort(list, function(a, b) if math.abs(a.y - b.y) > 6 then return a.y > b.y end return a.x < b.x end)
        local n = 0
        for _, e in ipairs(list) do if e.gslot then n = n + 1 end end
        ZenVCExportDB._gbankFound = date("%H:%M:%S") .. " tab " .. tostring(tab) .. ": " .. n .. " slots, " .. (#list - n) .. " buttons"
        local nowT = GetTime and GetTime() or 0
        if n == 0 or nowT - (TM.gbankSurveyT or -999) > 60 then   -- READ ONLY: what the guild bank window is made of, once a minute
            TM.gbankSurveyT = nowT
            local names = {}
            local function look(fr, depth)
                if depth > 5 or #names > 250 then return end
                for _, c in ipairs({ fr:GetChildren() }) do
                    local tx = c.GetText and c:GetText()
                    names[#names + 1] = string.rep(" ", depth) .. tostring((c.GetDebugName and c:GetDebugName()) or "?") .. " " .. tostring(c.GetObjectType and c:GetObjectType())
                        .. (c:IsVisible() and "" or " (hidden)") .. " id " .. tostring(c.GetID and c:GetID())
                        .. (type(tx) == "string" and tx ~= "" and (" '" .. tx .. "'") or "")
                    look(c, depth + 1)
                end
            end
            look(GuildBankFrame, 0)
            ZenVCExportDB._gbankSurvey = { at = date("%Y-%m-%d %H:%M:%S"), parts = names }
        end
    end)
    return list
end
-- v106 (2026-11-09, user: "choosing a quest reward" ... "when there is no selection ... SELECT works just fine"): ONLY when the reward window offers a
-- choice (more than one reward to choose from). START MOVE outlines the rewards you can choose; the tooltip box shows each with your equipped item
-- beside it; select is the game's own click on it (the game marks it as your choice); "complete" then hands the quest in with that reward.
function TM.qrewardOpen() return isUp("QuestFrameRewardPanel") and (GetNumQuestChoices and GetNumQuestChoices() or 0) > 1 end
function TM.qrewardSlots()
    local list = {}
    if not TM.qrewardOpen() then return list end
    pcall(function()
        local chosen = QuestInfoFrame and QuestInfoFrame.itemChoice or 0
        local seen = {}
        local function scan(fr, depth)
            if depth > 6 then return end
            for _, c in ipairs({ fr:GetChildren() }) do
                if c.IsVisible and c:IsVisible() and not seen[c] then
                    seen[c] = true
                    if c.type == "choice" and c.GetID and c:GetID() > 0 and c.GetLeft and c:GetLeft() then
                        local i = c:GetID()
                        local name, _, count = GetQuestItemInfo("choice", i)
                        local nm = tostring(name or "a reward") .. (((tonumber(count) or 1) > 1) and (" x" .. count) or "")
                        if chosen == i then nm = nm .. " (chosen: say complete to hand in)" end
                        list[#list + 1] = { fr = c, qchoice = i, name = nm, x = c:GetLeft(), y = c:GetTop() or 0 }
                    else
                        scan(c, depth + 1)
                    end
                end
            end
        end
        scan(QuestFrameRewardPanel, 0)
        if #list == 0 and QuestInfoRewardsFrame then scan(QuestInfoRewardsFrame, 0) end
        table.sort(list, function(a, b) if math.abs(a.y - b.y) > 6 then return a.y > b.y end return a.x < b.x end)
        ZenVCExportDB._qrewardFound = date("%H:%M:%S") .. " " .. #list .. " of " .. tostring(GetNumQuestChoices()) .. " choices, chosen " .. tostring(chosen)
    end)
    return list
end
function TM.mailTip(t, e)
    if e.empty then t:Hide() return false end
    if e.mailItem then t:SetSendMailItem(e.mailItem) return true end
    if e.inAtt then t:SetInboxItem(e.inIdx, e.inAtt); t:AddLine("Say get that to take it", 0.6, 0.6, 0.6) return true end
    if e.inRow or e.inHead then
        local idx = e.inRow or e.inHead
        local _, _, sender, subject, money, cod, days, items = GetInboxHeaderInfo(idx)
        t:SetText(tostring(subject or ""), 1, 1, 1, true)
        t:AddLine("From: " .. tostring(sender or "?"), 1, 1, 1)
        if coins(money) then t:AddLine("Money: " .. coins(money), 1, 0.82, 0) end
        if coins(cod) then t:AddLine("Cash on delivery: " .. coins(cod), 1, 0.3, 0.3) end
        if (tonumber(items) or 0) > 0 then t:AddLine("Items: " .. items, 1, 1, 1) end
        if tonumber(days) then t:AddLine("Days left: " .. math.floor(tonumber(days)), 0.6, 0.6, 0.6) end
        if e.inHead then
            local body = GetInboxText and GetInboxText(idx)
            if body and body ~= "" then t:AddLine(" "); t:AddLine(body, 1, 1, 1, true) end
        else t:AddLine("Say select to open it", 0.6, 0.6, 0.6) end
        return true
    end
    if e.inMoney then t:SetText(tostring(e.name), 1, 0.82, 0); t:AddLine("Say get that to take it", 0.6, 0.6, 0.6) return true end
    if e.mailClose then t:SetText("Close this mail", 1, 1, 1); t:AddLine("Say select to close it", 0.6, 0.6, 0.6) return true end
    if e.mailHead then
        t:SetText("Send mail", 1, 1, 1)
        for _, l in ipairs(mailTermLines()) do t:AddLine(l, 1, 1, 1, true) end
        t:AddLine("Say send mail twice to send it. Escape closes the mailbox.", 0.6, 0.6, 0.6, true)
    elseif e.mailBox then
        t:SetText(tostring(e.name), 1, 1, 1, true)
        if e.mailBox == _G.SendMailNameEditBox then   -- v98
            local names = TM.mailNames()
            if #names > 0 then
                t:AddLine("Your characters:", 0.6, 0.6, 0.6)
                for _, n in ipairs(names) do t:AddLine("    " .. n, 1, 1, 1) end
            end
            t:AddLine("Say select to choose a name or type one", 0.6, 0.6, 0.6)
        else
            t:AddLine("Say select to open the keypad", 0.6, 0.6, 0.6)
        end
    elseif e.mailTab then
        t:SetText(tostring(e.name), 1, 1, 1)
        t:AddLine("Say select to open it", 0.6, 0.6, 0.6)
    else
        t:SetText(tostring(e.name), 1, 1, 1)
    end
    return true
end
end

-- v124 the map and its quest log, as outline lists
do
function QG.mapOpen() return isUp("WorldMapFrame") end
function QG.qlogOpen() return isUp("WorldMapFrame") and isUp("QuestScrollFrame") end
local function qTitle(qid, fallback)
    local t = qid and C_QuestLog and C_QuestLog.GetTitleForQuestID and C_QuestLog.GetTitleForQuestID(qid)
    return t or fallback or ("quest " .. tostring(qid))
end
-- the quest lines in the quest log side, top to bottom (zone headers are left out: they have no quest)
function QG.qlogLines()
    local list = {}
    pcall(function()
        local c = QuestScrollFrame and QuestScrollFrame.Contents
        if not c then return end
        local function scan(fr, depth)
            if depth > 3 then return end
            for _, ch in ipairs({ fr:GetChildren() }) do
                if ch.IsVisible and ch:IsVisible() then
                    local qid = ch.questID
                    if type(qid) == "number" and qid > 0 then
                        local txt = ch.GetText and ch:GetText()
                        if (not txt or txt == "") and ch.Text and ch.Text.GetText then txt = ch.Text:GetText() end
                        list[#list + 1] = { fr = ch, questID = qid, name = qTitle(qid, txt) }
                    else scan(ch, depth + 1) end
                end
            end
        end
        scan(c, 0)
        table.sort(list, function(a, b) return (a.fr:GetTop() or 0) > (b.fr:GetTop() or 0) end)
    end)
    return list
end
-- the quest markers on the map side, as a list by name (like the flight master)
function QG.mapPins()
    local list = {}
    pcall(function()
        local m = _G.WorldMapFrame
        if not (m and m.EnumeratePinsByTemplate) then return end
        for pin in m:EnumeratePinsByTemplate("QuestPinTemplate") do
            if pin.IsVisible and pin:IsVisible() then
                list[#list + 1] = { fr = pin, questID = pin.questID, name = qTitle(pin.questID, "quest marker"), x = pin:GetLeft() or 0, y = pin:GetTop() or 0 }
            end
        end
        table.sort(list, function(a, b) return tostring(a.name) < tostring(b.name) end)   -- user: "the map should work like the flight master": a list, by name
    end)
    return list
end
-- keeps the outlined quest inside the quest log's window (the list is taller than its window)
function QG.qlogShow(e)
    pcall(function()
        local sf = QuestScrollFrame
        local c = sf and sf.Contents
        if not (c and e and e.fr and sf.GetVerticalScroll and sf.SetVerticalScroll) then return end
        local top = (c:GetTop() or 0) - (e.fr:GetTop() or 0)
        local h = e.fr:GetHeight() or 16
        local view = sf:GetHeight() or 0
        local cur = sf:GetVerticalScroll() or 0
        local range = sf.GetVerticalScrollRange and sf:GetVerticalScrollRange() or 0
        local want = cur
        if top < cur then want = top elseif top + h > cur + view then want = top + h - view end
        want = math.max(0, math.min(range, want))
        if math.abs(want - cur) > 0.5 then sf:SetVerticalScroll(want) end
    end)
end
end

local function lightUp(list)
    disarm()   -- moving to another item cancels a waiting use or destroy
    local e = list[mark.i]
    if e then
        if e.fr then markerOn(e.fr) elseif markFrame then markFrame:Hide() end   -- v88: a flight point may have no button
        if (mark.kind == "qlog" or mark.kind == "qmap") and e.fr then pcall(function()   -- v124
            if mark.kind == "qlog" then QG.qlogShow(e) end
            QG.mapSel = e.fr; aimKey("/click zenvcselect", "ZenVCMapSelect", e.fr)
        end) end
        say1(mark.i .. " of " .. #list .. ": " .. tostring(e.name))
        if mark.kind == "taxi" then pcall(function()   -- v88, v90
            -- v90 (2026-11-09, user: "Flight master works, but I would like a CONFIRM on yes"): only "take off" flies, and VCF asks yes or no
            -- before it presses; select and accept no longer fly
            if e.fr then taxiAimFr = e.fr; aimKey("/click zenvctakeoff", "ZenVCTaxiGo", e.fr)
            else say1("this flight point has no button to press on this map") end
        end) end
        if mark.kind == "ah" then pcall(function()   -- v83
            if e.noClick then aimKey("/click zenvcselect"); ahSelTarget = nil; say1(e.edit and "say select to open the keypad for this box" or "to buy, say buy that")   -- v84, v91, v94
            else ahSelTarget = e.fr; aimKey("/click zenvcselect", "ZenVCAHSelect", e.fr) end
            -- v85 (2026-11-09, user): "accept" works as select while the outline is in the Auction House
            if e.noClick then aimKey("/click questframeacceptbutton") else aimKey("/click questframeacceptbutton", "ZenVCAHAccept", e.fr) end
            -- v85 the bottom / top row on screen: "move down" / "move up" press the list's own scroll arrow while it can still scroll
            if e.isLast and e.fwd and e.fwd.IsEnabled and e.fwd:IsEnabled() then aimKey("/click zenvcmovedown", "ZenVCAHDown", e.fwd) else aimKey("/click zenvcmovedown") end
            if e.isFirst and e.back and e.back.IsEnabled and e.back:IsEnabled() then aimKey("/click zenvcmoveup", "ZenVCAHUp", e.back) else aimKey("/click zenvcmoveup") end
            ahCurFr, ahCurName, ahCurFlags = e.fr, e.name, tostring(e.isFirst) .. tostring(e.isLast)
        end) end
        if mark.kind == "qreward" then pcall(function()   -- v106 select is the game's own click on the reward
            mailSelTarget = e.fr; aimKey("/click zenvcselect", "ZenVCMailSelect", e.fr)
        end) end
        if mark.kind == "bank" or mark.kind == "gbank" then pcall(function()   -- v100 a bank tab: select is the game's own click on it (v104 guild bank too)
            if e.bankTab or e.bankBtn then mailSelTarget = e.fr; aimKey("/click zenvcselect", "ZenVCMailSelect", e.fr)
            elseif mailSelTarget then aimKey("/click zenvcselect"); mailSelTarget = nil end
        end) end
        if mark.kind == "mail" then pcall(function()   -- v95 a mailbox tab: select is the game's own click on it
            if e.mailTab or e.inRow or e.mailClose then mailSelTarget = e.fr; aimKey("/click zenvcselect", "ZenVCMailSelect", e.fr)
            elseif mailSelTarget then aimKey("/click zenvcselect"); mailSelTarget = nil end
            if mailGetTarget then aimKey("/click zenvcgetthat"); mailGetTarget = nil end   -- v97: "get that" is no longer aimed at the button (that took nothing)
        end) end
        -- v61 (2026-11-07, user: "is there any way to trigger the tooltip when hovering?" and "the tooltip needs to be in anything it is around"): the game's own
        -- tooltip for what is outlined. First the button's own mouse-over (works for bag slots, vendor items and other windows' buttons), else the item itself.
        -- v63: NEVER the button's own OnEnter/OnLeave. Calling them from the add-on (v61-v62) tainted the game's controller code: SetPreferredGamepadInteractTarget
        -- was then blocked and the game showed "ZenVCExport has been blocked from an action only available to the Blizzard UI" (2026-11-07 13:56). Only the plain
        -- tooltip calls below, which touch nothing else.
        unhover()
        local okTip, errTip = pcall(function()
            if not e.fr and not e.taxi then return end   -- v88
            local t = tip()
            for _, f in ipairs(zvCmp or {}) do f:Hide() end
            -- v71 (2026-11-07, user): one place for every window, the LOWER MIDDLE of the screen, clear of the game's own controller cursor and tooltip.
            -- Size small / normal / large (half, as is, twice) by the spoken "tooltip small / normal / large"; always kept inside the screen.
            local scale = tonumber(ZenVCExportDB._tipScale) or 1
            t:SetOwner(UIParent, "ANCHOR_NONE")
            t:SetScale(scale)
            for _, f in ipairs(zvCmp or {}) do f:SetScale(scale); f:SetClampedToScreen(true) end
            t:ClearAllPoints()
            t:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 140 / scale)
            t:SetClampedToScreen(true)
            -- v72: placed for real at the end, once every box knows its size (see placeTips)
            if e.tradeLine then   -- v95
                if not TM.tradeTip(t, e) then return end
            elseif e.mailLine then   -- v95
                if not TM.mailTip(t, e) then return end
            elseif e.qchoice then   -- v106 a quest reward to choose
                t:SetQuestItem("choice", e.qchoice)
            elseif e.gslot then   -- v104 a guild bank slot
                if e.name == "empty" then t:Hide() return end
                t:SetGuildBankItem(e.gtab, e.gslot)
            elseif e.bag ~= nil and e.slot then
                if e.name == "empty" then t:Hide() return end
                t:SetBagItem(e.bag, e.slot)
            elseif e.index then
                t:SetMerchantItem(e.index)
            elseif e.spellID then
                t:SetSpellByID(e.spellID)
            elseif e.padKey and pad.names then   -- v98 the names list of the To box: all of it, the outlined one marked
                local cur = pad.box and pad.box.GetText and pad.box:GetText() or ""
                t:SetText("To: " .. (cur ~= "" and cur or "(empty)"), 1, 1, 1)
                for _, k in ipairs(pad.keys) do
                    local on = k.padKey == e.padKey
                    t:AddLine((on and "> " or "    ") .. k.padKey, on and 1 or 0.75, on and 0.82 or 0.75, on and 0 or 0.75)
                end
                t:AddLine("Say enter to choose it", 0.6, 0.6, 0.6)
            elseif e.padKey then   -- v91 a keypad key
                t:SetText("Key: " .. tostring(e.padKey), 1, 1, 1)
                local typed = pad.box and pad.box.GetText and pad.box:GetText() or ""
                t:AddLine("Typed: " .. (typed ~= "" and typed or "(nothing yet)"), 1, 1, 1)
                t:AddLine("Say enter to press it", 0.6, 0.6, 0.6)
            elseif e.questID and (mark.kind == "qlog" or mark.kind == "qmap") then   -- v124 a quest in the quest log or on the map
                t:SetText(tostring(e.name), 1, 1, 1)
                local obj = C_QuestLog and C_QuestLog.GetQuestObjectives and C_QuestLog.GetQuestObjectives(e.questID)
                for _, o in ipairs(type(obj) == "table" and obj or {}) do
                    if o.text and o.text ~= "" then t:AddLine((o.finished and "Done: " or "") .. o.text, o.finished and 0.6 or 1, o.finished and 0.6 or 1, o.finished and 0.6 or 1, true) end
                end
                if C_QuestLog and C_QuestLog.IsComplete and C_QuestLog.IsComplete(e.questID) then t:AddLine("Ready to hand in", 1, 1, 1) end
                t:AddLine("Say " .. QG.word("/click zenvcselect", "select") .. (mark.kind == "qlog" and " to open it, or " or " to show this quest, or ") .. QG.word("/click zenvcswitchside", "move my box") .. (mark.kind == "qlog" and " for the map" or " for the quest log"), 0.6, 0.6, 0.6)
            elseif e.taxi then   -- v88 a flight point
                t:SetText(tostring(e.name), 1, 1, 1)
                if e.cost and e.cost > 0 then
                    t:AddLine("Cost: " .. ((GetMoneyString and GetMoneyString(e.cost, true)) or tostring(e.cost)), 1, 1, 1)
                end
                t:AddLine("Say " .. QG.word("/click zenvctakeoff", "take off") .. " to fly here", 0.6, 0.6, 0.6)   -- v90; 2026-11-11 the player's own words
            elseif e.itemID then
                t:SetItemByID(e.itemID)   -- v77 an Auction House row
                local function money(c) return (GetMoneyString and GetMoneyString(c, true)) or (GetCoinTextureString and GetCoinTextureString(c)) or tostring(c) end
                local own = e.buyout or e.unit
                if own or e.bid then
                    t:AddLine(" ")
                    if own then t:AddLine("This auction: " .. money(own) .. (e.unit and not e.buyout and " each" or ""), 1, 0.82, 0) end
                    if e.bid and e.bid > 0 then t:AddLine("Bid: " .. money(e.bid), 1, 1, 1) end
                    if e.aqty then t:AddLine("Quantity: " .. e.aqty, 1, 1, 1) end
                end
                local low = e.minPrice or (e.itemID and ahLowest[e.itemID])
                if low then
                    if not (own or e.bid) then t:AddLine(" ") end
                    t:AddLine("Lowest auction price: " .. money(low), 1, 1, 1)
                end
                if e.qty then t:AddLine("Available: " .. e.qty, 1, 1, 1) end
            else
                t:SetText(tostring(e.name))
            end
            t:Show()
            -- v72: our own "Equipped" boxes, then everything placed clear of the bags, the vendor and the screen edge
            local shown = {}
            local okCmp, errCmp = pcall(function()
                if e.spellID or e.name == "empty" or e.empty or (e.tradeLine and not (e.tradeP or e.tradeT)) or (e.mailLine and not (e.mailItem or e.inAtt)) then return end   -- v95
                for k, slot in ipairs(equippedFor(outlinedLink(e))) do
                    local f = zvCmp and zvCmp[k]
                    if f then
                        f:SetOwner(UIParent, "ANCHOR_NONE")
                        f:SetInventoryItem("player", slot)
                        if f.CompareHeader then f.CompareHeader:Show() else f:AddLine("Equipped", 0.6, 0.6, 0.6) end
                        f:Show()
                        shown[#shown + 1] = f
                    end
                end
            end)
            local okPlace, errPlace = pcall(placeTips, t, shown, scale)
        end)
    end
end


-- v48 the item slots of every open bag window, each with its bag, slot, position and item name
local function bagSlots()
    local list = {}
    local function add(btn)
        if not (btn and btn.IsVisible and btn:IsVisible()) then return end
        local bag = (btn.GetBagID and btn:GetBagID()) or (btn:GetParent() and btn:GetParent().GetID and btn:GetParent():GetID())
        local slot = btn.GetID and btn:GetID()
        if bag == nil or not slot then return end
        local name = "empty"
        local info = C_Container and C_Container.GetContainerItemInfo and C_Container.GetContainerItemInfo(bag, slot)
        if info and info.itemID then
            name = (C_Item and C_Item.GetItemNameByID and C_Item.GetItemNameByID(info.itemID)) or (info.hyperlink and info.hyperlink:match("%[(.-)%]")) or "an item"
            if (info.stackCount or 1) > 1 then name = name .. " x" .. info.stackCount end
        end
        list[#list + 1] = { fr = btn, bag = bag, slot = slot, name = name, x = btn:GetLeft() or 0, y = btn:GetTop() or 0 }
    end
    local combined = _G.ContainerFrameCombinedBags
    if combined and combined:IsVisible() and combined.EnumerateValidItems then
        for _, btn in combined:EnumerateValidItems() do add(btn) end
    end
    for f = 1, 13 do
        local cf = _G["ContainerFrame" .. f]
        if cf and cf:IsVisible() then
            if cf.EnumerateValidItems then for _, btn in cf:EnumerateValidItems() do add(btn) end
            else for i = 1, 36 do add(_G["ContainerFrame" .. f .. "Item" .. i]) end end
        end
    end
    -- reading order on screen: top row first, left to right
    table.sort(list, function(a, b) if math.abs(a.y - b.y) > 6 then return a.y > b.y end return a.x < b.x end)
    return list
end

local function bagsOpen() return #bagSlots() > 0 end

-- v77 (2026-11-09, user: "Let's do navigation and tooltips first, then do entries"): the Auction House (WoW Forever uses the modern AuctionHouseFrame:
-- survey 11:56). Every visible list in it (the categories on the left, the results on the right, the lists of the Sell and Auctions tabs) is a
-- scrolling list; its rows on screen are read (GetFrames / GetElementData: READ ONLY, nothing is clicked, scrolled or set in the game's window).
-- Each row gets its list number (lists ordered left to right), its name and, for an item, its item ID (for our tooltip and the comparison).
local function ahOpen() return isUp("AuctionHouseFrame") end
-- v88 (2026-11-09, user: "list first, put where the tooltip we show is so I can read it. same rules as the tooltips, just like vendors and ah"):
-- START MOVE on an open flight map: the flight points you can fly to, A to Z. The box (lower middle) shows the name and the cost; "select" or
-- "accept" takes off by pressing that point the game's own way (a secure click, see aimKey). Read only otherwise.
local function taxiOpen() return isUp("TaxiFrame") or isUp("FlightMapFrame") end
local function taxiSlots()
    local list = {}
    pcall(function()
        local pins = {}
        pcall(function()
            local fm = _G.FlightMapFrame
            if fm and fm:IsShown() and fm.EnumerateAllPins then
                for pin in fm:EnumerateAllPins() do
                    local d = pin.taxiNodeData
                    if d and d.slotIndex then pins[d.slotIndex] = pin end
                end
            end
        end)
        for i = 1, (NumTaxiNodes and NumTaxiNodes() or 0) do
            local kind = TaxiNodeGetType and TaxiNodeGetType(i)
            if kind == "REACHABLE" then
                local fr = pins[i] or _G["TaxiButton" .. i]
                list[#list + 1] = { fr = fr, taxi = i, name = TaxiNodeName(i) or ("flight point " .. i), cost = TaxiNodeCost and TaxiNodeCost(i) }
            end
        end
        table.sort(list, function(a, b) return tostring(a.name) < tostring(b.name) end)
    end)
    return list
end
local ahLowest = {}   -- v82: item ID -> lowest price seen in the first results list (read only)
local function ahSlots()
    local list = {}
    pcall(function()
        local boxes = {}
        local function walk(f, depth)
            if not f or depth > 7 then return end
            for _, c in ipairs({ f:GetChildren() }) do
                if c.IsVisible and c:IsVisible() then
                    if c.GetFrames and c.GetDataProvider then boxes[#boxes + 1] = c else walk(c, depth + 1) end
                end
            end
        end
        walk(_G.AuctionHouseFrame, 0)
        -- v84 (2026-11-09, user: "cant get to search to click search"): the search row (favourites, search box, Search, Filter) is line 0, above the lists
        pcall(function()
            local bar = AuctionHouseFrame.SearchBar
            if not (bar and bar:IsVisible()) then return end
            local parts = { { bar.FavoritesSearchButton, "Favourites" }, { bar.SearchBox, "Search box", true }, { bar.SearchButton, "Search" }, { bar.FilterButton, "Filter" } }
            for _, p in ipairs(parts) do
                local f = p[1]
                if f and f.IsVisible and f:IsVisible() and f:GetLeft() then
                    list[#list + 1] = { fr = f, group = 0, name = p[2], noClick = p[3], edit = p[3] and f or nil, x = f:GetLeft(), y = f:GetTop() or 0 }
                end
            end
        end)
        -- v91 (2026-11-09, user: an on-screen keypad for the search and quantity boxes): any other text or number box the Auction House shows
        -- (the quantity box when buying) is a stop on line 0 too
        pcall(function()
            local seen = { [AuctionHouseFrame.SearchBar and AuctionHouseFrame.SearchBar.SearchBox or 0] = true }
            local function scan(f, depth)
                if depth > 9 then return end
                for _, c in ipairs({ f:GetChildren() }) do
                    if c.IsVisible and c:IsVisible() then
                        if c:GetObjectType() == "EditBox" and not seen[c] and c:GetLeft() then
                            seen[c] = true
                            local numeric = c.IsNumeric and c:IsNumeric()
                            list[#list + 1] = { fr = c, group = 0, name = numeric and "Quantity box" or "Text box", noClick = true, edit = c, x = c:GetLeft(), y = c:GetTop() or 0 }
                        else scan(c, depth + 1) end
                    end
                end
            end
            scan(AuctionHouseFrame, 0)
        end)
        table.sort(boxes, function(a, b) return (a:GetLeft() or 0) < (b:GetLeft() or 0) end)
        for g, box in ipairs(boxes) do
            local firstIdx = #list + 1   -- v85
            for _, row in ipairs(box:GetFrames() or {}) do
                if row.IsVisible and row:IsVisible() and row:GetTop() then
                    local data = row.GetElementData and row:GetElementData()
                    -- v80: the results list keeps the item on the row itself
                    local rd = row.rowData
                    if not rd and row.GetRowData then pcall(function() rd = row:GetRowData() end) end
                    if (type(data) ~= "table" or next(data) == nil) and type(rd) == "table" then data = { rowData = rd, itemKey = rd.itemKey } end
                    local itemID, name
                    pcall(function()
                        local key = data and (data.itemKey or (data.rowData and data.rowData.itemKey))
                        if key and key.itemID then
                            itemID = key.itemID
                            local info = C_AuctionHouse and C_AuctionHouse.GetItemKeyInfo and C_AuctionHouse.GetItemKeyInfo(key)
                            name = (info and info.itemName) or (GetItemInfo and GetItemInfo(itemID))
                        elseif data and data.itemID then
                            itemID = data.itemID
                            name = GetItemInfo and GetItemInfo(itemID)
                        end
                        if not name and data and type(data.name) == "string" then name = data.name end
                        if not name then
                            for _, r in ipairs({ row:GetRegions() }) do
                                if r.GetText and r:GetText() and r:GetText() ~= "" then name = r:GetText() break end
                            end
                        end
                        if not name and row.Text and row.Text.GetText then name = row.Text:GetText() end
                        -- v80: the text inside the row's cells (Name, Price, Level ...): the first one with letters in it is the name
                        if not name then
                            local function cells(f, depth)
                                if name or depth > 3 then return end
                                for _, r in ipairs({ f:GetRegions() }) do
                                    local tx = r.GetText and r:GetText()
                                    if type(tx) == "string" and tx:find("%a") then name = tx return end
                                end
                                for _, c in ipairs({ f:GetChildren() }) do cells(c, depth + 1) end
                            end
                            cells(row, 0)
                        end
                    end)
                    local keys = {}
                    pcall(function()
                        for k, v in pairs(data or {}) do keys[#keys + 1] = tostring(k) .. ((type(v) == "table") and "{}" or "") end
                        if data and type(data.rowData) == "table" then for k in pairs(data.rowData) do keys[#keys + 1] = "rowData." .. tostring(k) end end
                    end)
                    local minPrice, qty, buyout, bid, unit, aqty
                    pcall(function()
                        local r = data and (data.rowData or data)
                        if type(r) == "table" then
                            minPrice, qty = tonumber(r.minPrice), tonumber(r.totalQuantity)
                            -- v82 (2026-11-09, user: "I need to see the price of the item being hovered over, not just the lowest, if possible show both"):
                            -- a single auction (the list after an item is selected) carries its own buyout, bid, unit price and quantity
                            buyout, bid, unit, aqty = tonumber(r.buyoutAmount), tonumber(r.bidAmount), tonumber(r.unitPrice), tonumber(r.quantity)
                            if not itemID and r.itemKey and r.itemKey.itemID then itemID = r.itemKey.itemID end
                            if not itemID and type(r.itemLink) == "string" then itemID = tonumber(r.itemLink:match("item:(%d+)")) end   -- not GetItemInfoInstant: it gives nothing in this game
                        end
                    end)
                    if itemID and minPrice then ahLowest[itemID] = minPrice end
                    list[#list + 1] = { fr = row, group = g, itemID = itemID, name = name or "a row", x = row:GetLeft() or 0, y = row:GetTop() or 0,
                        minPrice = minPrice, qty = qty,   -- v81
                        buyout = buyout, bid = bid, unit = unit, aqty = aqty,   -- v82
                        dataKeys = table.concat(keys, ","):sub(1, 300) }   -- v79 note only
                end
            end
            -- v85 (2026-11-09, user: scrolling by voice, "there are no pages in the AH"): the list's own scroll arrows (its ScrollBar's Forward / Back),
            -- and its top and bottom rows on screen. "move down" on the bottom row presses the down arrow, the game's own click (see aimKey).
            local fwd, back
            pcall(function()
                for _, h in ipairs({ box:GetParent(), box:GetParent() and box:GetParent():GetParent() }) do
                    local sb = h and h.ScrollBar
                    if sb and not fwd then fwd, back = sb.Forward or sb.ScrollDownButton, sb.Back or sb.ScrollUpButton end
                end
            end)
            local top, bottom
            for k = firstIdx, #list do
                local e = list[k]; e.fwd, e.back = fwd, back
                if not top or e.y > top.y then top = e end
                if not bottom or e.y < bottom.y then bottom = e end
            end
            if top then top.isFirst = true end
            if bottom then bottom.isLast = true end
        end
        -- v94 (2026-11-09, user: "the move function will not go to the BUY spot ... it should at least let me highlight the button"): the buttons of the
        -- buying screen (Buy Now, Buyout, Bid, Cancel ...) are one more line, to the right of the lists. Read only; pressing Buy is "buy that".
        pcall(function()
            local g = #boxes + 1
            for _, k in ipairs({ "CommoditiesBuyFrame", "ItemBuyFrame" }) do
                local f = AuctionHouseFrame[k]
                if f and f:IsVisible() then
                    local function scan(fr, depth)
                        if depth > 6 then return end
                        for _, c in ipairs({ fr:GetChildren() }) do
                            if c.IsVisible and c:IsVisible() then
                                local tx = c.GetObjectType and c:GetObjectType() == "Button" and c.GetText and c:GetText()
                                if type(tx) == "string" and tx:find("%a") and c:GetLeft() then
                                    local off = c.IsEnabled and not c:IsEnabled()
                                    list[#list + 1] = { fr = c, group = g, name = tx .. (off and " (not available now)" or ""), noClick = true, x = c:GetLeft(), y = c:GetTop() or 0 }
                                else scan(c, depth + 1) end
                            end
                        end
                    end
                    scan(f, 0)
                end
            end
        end)
        table.sort(list, function(a, b)
            if a.group ~= b.group then return a.group < b.group end
            if a.group == 0 then return a.x < b.x end   -- v84 the search row: left to right
            return a.y > b.y
        end)
    end)
    return list
end
-- up/down: the next row in the same list; left/right: the row at about the same height in the next list (categories <-> results)
local function ahNeighbour(list, i, dir)
    local cur = list[i]
    if not cur then return 1 end
    -- v84 the search row (line 0)
    local function nearestIn(g, top)
        local best, bd
        for k, e in ipairs(list) do
            if e.group == g then
                local d = top and -e.y or math.abs(e.x - cur.x)
                if not best or d < bd then best, bd = k, d end
            end
        end
        return best
    end
    if cur.group == 0 then
        if dir == "left" or dir == "right" then
            local k = i + (dir == "right" and 1 or -1)
            if list[k] and list[k].group == 0 then return k end
            return i
        end
        if dir == "down" then return nearestIn(1, true) or i end
        return i
    end
    if dir == "up" and not (list[i - 1] and list[i - 1].group == cur.group) then
        local k = nearestIn(0)
        if k then return k end
    end
    if dir == "up" or dir == "down" then
        local k = i + (dir == "down" and 1 or -1)
        if list[k] and list[k].group == cur.group then return k end
        say1(dir == "down" and "end of this list" or "top of this list")   -- v85: scrolling is done by the list's own arrows (aimed keys)
        return i
    end
    local want = cur.group + (dir == "right" and 1 or -1)
    local best, bestDy
    for k, e in ipairs(list) do
        if e.group == want then
            local dy = math.abs(e.y - cur.y)
            if not best or dy < bestDy then best, bestDy = k, dy end
        end
    end
    if not best then say1(dir == "right" and "no list further right" or "no list further left") end
    return best or i
end

-- the slot one step away on screen: left/right stay in the row, up/down go to the nearest slot in the next row
local function bagNeighbour(list, i, dir)
    local cur = list[i]
    if not cur then return 1 end
    if dir == "left" then return math.max(1, i - 1) end
    if dir == "right" then return math.min(#list, i + 1) end
    local best, bestRowY, bestDx
    for k, e in ipairs(list) do
        local below = cur.y - e.y > 6
        local above = e.y - cur.y > 6
        if (dir == "down" and below) or (dir == "up" and above) then
            local rowDist = math.abs(cur.y - e.y)
            local dx = math.abs(e.x - cur.x)
            if not best or rowDist < bestRowY - 6 or (math.abs(rowDist - bestRowY) <= 6 and dx < bestDx) then best, bestRowY, bestDx = k, rowDist, dx end
        end
    end
    return best or i
end

-- v63 (2026-11-07, user: "READ PANEL should work for these panels that are NOT trade or vendor windows"): the open panel's buttons as an outline list.
-- First the spellbook: each spell on the page, with its position (for up/down/left/right) and its spellbook slot (for its tooltip).
local function panelSlots()
    local list = {}
    pcall(function()
        if isUp("SpellBookFrame") then
            for k = 1, 12 do
                local b = _G["SpellButton" .. k]
                local label = _G["SpellButton" .. k .. "SpellName"]
                local name = label and label.GetText and label:GetText()
                if b and b.IsVisible and b:IsVisible() and name and name ~= "" then
                    local id = GetSpellInfo and select(7, GetSpellInfo(name))
                    list[#list + 1] = { fr = b, spellID = id, name = name, x = b:GetLeft() or 0, y = b:GetTop() or 0 }
                end
            end
        end
    end)
    return list
end

-- v91 (2026-11-09, user: "can we put a number pad on screen for the Quantity or number fields and use the MOVE function within it with a BACKSPACE
-- and DONE key ... and then the same for just letters"; "ENTER works"). "select" on a search or quantity box opens our own keypad: numbers like a
-- phone (1-9, Backspace, 0, Done) or the letters A to Z with Space, Backspace and Done. The move commands walk the outline over its keys; "enter"
-- (or "select") presses the outlined key. The key goes straight into that one box (nothing is typed on the keyboard, so no letter can set off a
-- game shortcut). Done closes the pad and puts the outline back on the box.
pad.frame, pad.keys, pad.box, pad.numeric, pad.back = nil, {}, nil, false, nil   -- declared above lightUp (v91)
local PAD_NUM = { { "1", "2", "3" }, { "4", "5", "6" }, { "7", "8", "9" }, { "Backspace", "0", "Done" } }
-- v92 (2026-11-09, user: "shouldnt letters keys be qwerty" ... "maybe make a choice"): two letter layouts, QWERTY first; the last key of the bottom row
-- switches to the other one and the choice is remembered (saved as _padLayout)
local PAD_ABC = { { "A", "B", "C", "D", "E", "F", "G" }, { "H", "I", "J", "K", "L", "M", "N" }, { "O", "P", "Q", "R", "S", "T", "U" },
    { "V", "W", "X", "Y", "Z" }, { "Space", "Backspace", "Done", "QWERTY" } }
local PAD_QWERTY = { { "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P" }, { "A", "S", "D", "F", "G", "H", "J", "K", "L" },
    { "Z", "X", "C", "V", "B", "N", "M" }, { "Space", "Backspace", "Done", "ABC" } }
local function padLetters() return (ZenVCExportDB._padLayout == "abc") and PAD_ABC or PAD_QWERTY end
local function padBuild(rows)
    if not pad.frame then
        pad.frame = CreateFrame("Frame", "ZenVCKeypad", UIParent)
        pad.frame:SetFrameStrata("DIALOG")
        local bg = pad.frame:CreateTexture(nil, "BACKGROUND"); bg:SetAllPoints(); bg:SetColorTexture(0, 0, 0, 0.85)
    end
    for _, k in ipairs(pad.keys) do k:Hide() end
    pad.keys = {}
    local size, gap = 54, 6
    local cols = 0
    for _, r in ipairs(rows) do cols = math.max(cols, #r) end
    local y = -gap
    for ri, r in ipairs(rows) do
        local x = gap
        for _, label in ipairs(r) do
            local w = pad.names and 300 or ((#label > 1) and (size * 2 + gap) or size)   -- v98 names are wide keys
            local k = CreateFrame("Frame", nil, pad.frame)
            k:SetSize(w, size); k:SetPoint("TOPLEFT", pad.frame, "TOPLEFT", x, y)
            local t = k:CreateTexture(nil, "ARTWORK"); t:SetAllPoints(); t:SetColorTexture(0.18, 0.18, 0.18, 1)
            local fs = k:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge"); fs:SetPoint("CENTER"); fs:SetText(label)
            k.padKey = label
            pad.keys[#pad.keys + 1] = k
            x = x + w + gap
        end
        y = y - size - gap
    end
    pad.frame:SetSize(pad.names and (300 + gap * 2) or (cols * (size + gap) + gap + size), #rows * (size + gap) + gap)
    pad.frame:ClearAllPoints(); pad.frame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 300)
    pad.frame:SetClampedToScreen(true)
    pad.frame:Show()
end
local function padSlots()
    local list = {}
    for _, k in ipairs(pad.keys) do
        list[#list + 1] = { fr = k, padKey = k.padKey, name = k.padKey, x = k:GetLeft() or 0, y = k:GetTop() or 0 }
    end
    return list
end
local function padOpen(box, backI, from, names)
    pad.box, pad.back, pad.from = box, backI, from or "ah"   -- v95 from: "ah" or "trade"
    pad.numeric = box.IsNumeric and box:IsNumeric() and true or false
    pad.names = (names and #names > 0) and true or false   -- v98 the To box of a mail: a list of names first
    if pad.names then
        local rows = { { "Type a name" } }
        for _, n in ipairs(names) do rows[#rows + 1] = { n } end
        rows[#rows + 1] = { "Back" }
        padBuild(rows)
    else
        padBuild(pad.numeric and PAD_NUM or padLetters())
    end
    mark.kind, mark.i = "pad", 1
    say1((pad.names and "names: Type a name opens the letter pad, or move down to one of your characters and say enter") or (pad.numeric and "number pad: move to a number, say enter. Done when finished") or "letter pad: move to a letter, say enter. Done when finished")
end
local function padClose(toBox)
    if pad.frame then pad.frame:Hide() end
    local back = pad.back
    local box0 = pad.box
    pad.box = nil
    -- v118 (2026-11-11, user: "TARGETTED IF THERE IS A TARGET OTHERWISE OUR KEYBOARD FROM MAIL AND AH"): the name spelled on the keypad opens the whisper
    if pad.from == "whisper" then
        local name = box0 and box0.GetText and (box0:GetText() or ""):gsub("%s+", "") or ""
        if box0 and box0.Hide then box0:Hide() end
        mark.kind, mark.i = nil, 0
        markerOff()
        if toBox and name ~= "" then pcall(function() ChatFrame_OpenChat("/w " .. name .. " ") end) end
        return
    end
    if toBox and pad.from == "trade" and TM.tradeOpen() then   -- v95
        TM.tradeMoneyApply()
        mark.kind, mark.i = "trade", back or 1
        lightUp(TM.tradeSlots())
    elseif toBox and pad.from == "mail" and TM.mailOpen() then   -- v95
        mark.kind, mark.i = "mail", back or 1
        lightUp(TM.mailSlots())
    elseif toBox and ahOpen() then
        mark.kind, mark.i = "ah", back or 1
        lightUp(ahSlots())
    else
        mark.kind, mark.i = nil, 0
        markerOff()
    end
end
local function padPress()
    if EM.on then EM.pick(-1) return end   -- v120 edit layout: previous piece
    if mark.kind ~= "pad" or not pad.box then
        say1("open a keypad first: start move, move to the search box or a quantity box, then say select")
        return
    end
    local e = padSlots()[mark.i]
    if not e then return end
    local box, k = pad.box, e.padKey
    pcall(function()
        if pad.names then   -- v98
            if k == "Back" then padClose(true) return end
            if k == "Type a name" then
                pad.names = false
                box:SetText("")
                padBuild(padLetters()); mark.i = 1
                say1("letter pad: move to a letter, say enter. Done when finished")
                lightUp(padSlots())
                return
            end
            box:SetText(k)
            say1("to: " .. k)
            padClose(true)
            return
        end
        if k == "Done" then padClose(true) return end
        if k == "ABC" or k == "QWERTY" then   -- v92 switch the letter layout, keep the outline on the switch key
            ZenVCExportDB._padLayout = (k == "ABC") and "abc" or "qwerty"
            padBuild(padLetters())
            local list = padSlots()
            for i, x in ipairs(list) do if x.padKey == "ABC" or x.padKey == "QWERTY" then mark.i = i end end
            say1((k == "ABC") and "letters in A B C order" or "letters in keyboard order")
            lightUp(list)
            return
        end
        if k == "Backspace" then
            local t = box:GetText() or ""
            box:SetText(t:sub(1, -2))
        elseif k == "Space" then box:Insert(" ")
        else box:Insert(k:lower()) end
        lightUp(padSlots())
    end)
end

-- v63 (2026-11-07, user: "I want a START MOVE command that puts the box IN PLACE. this way STOP MOVE makes sense and SWITCH MOVE can replace the switch command")
-- The outline goes onto what is open: the spellbook (or another panel), else a vendor, else the bags, else a talk window.
-- v123 LOOK ONLY: what the map shows, by name, for building start move on the map and its quest log. Reads only; nothing is pressed or set.
-- v124 "move my box" on the map: the other side, on the same quest when it is there too
function QG.flip()
    local fromLog = mark.kind == "qlog"
    local before = (fromLog and QG.qlogLines() or QG.mapPins())[mark.i]
    local list = fromLog and QG.mapPins() or (QG.qlogOpen() and QG.qlogLines() or {})
    if #list == 0 then say1(fromLog and "there are no quest markers on this map" or "the quest log is not open beside the map") return end
    mark.kind, mark.i = fromLog and "qmap" or "qlog", 1
    if before and before.questID then for k, e in ipairs(list) do if e.questID == before.questID then mark.i = k break end end end
    lightUp(list)
end
local MAPLOOK = {}
function MAPLOOK.run(quiet)
    local rec = { at = date("%Y-%m-%d %H:%M:%S"), frames = {}, pins = {}, api = {} }
    pcall(function()
        local seen, n = {}, 0
        local function nameOf(fr)
            local nm = fr.GetName and fr:GetName()
            if not nm and fr.GetDebugName then local ok, d = pcall(fr.GetDebugName, fr); if ok then nm = d end end
            return nm or "?"
        end
        local function walk(fr, depth)
            if n >= 160 or seen[fr] or depth > 4 then return end
            seen[fr] = true
            if not (fr.IsVisible and fr:IsVisible()) then return end
            local w, h = fr.GetWidth and fr:GetWidth() or 0, fr.GetHeight and fr:GetHeight() or 0
            local txt = fr.GetText and select(2, pcall(fr.GetText, fr)) or nil
            n = n + 1
            rec.frames[n] = string.rep(" ", depth) .. nameOf(fr) .. " | " .. tostring(fr.GetObjectType and fr:GetObjectType()) .. string.format(" | %dx%d", w, h) .. ((type(txt) == "string" and txt ~= "") and (" | " .. txt:sub(1, 40)) or "")
            for _, c in ipairs({ fr:GetChildren() }) do walk(c, depth + 1) end
        end
        for _, nm in ipairs({ "WorldMapFrame", "QuestMapFrame", "QuestLogFrame", "QuestScrollFrame", "QuestLogDetailFrame" }) do
            local fr = _G[nm]
            rec.api[#rec.api + 1] = nm .. "=" .. (fr and ((fr.IsVisible and fr:IsVisible()) and "shown" or "hidden") or "missing")
            if fr and fr.IsVisible and fr:IsVisible() and n < 160 then walk(fr, 0) end
        end
        local qc = _G.QuestScrollFrame and QuestScrollFrame.Contents   -- v124 the quest list's own lines (deeper than the walk above reaches)
        if qc then n = math.min(n, 140); seen[qc] = nil; walk(qc, 0) end
        for _, fn in ipairs({ "GetQuestLogSelection", "SelectQuestLogEntry", "GetNumQuestLogEntries", "QuestLog_SetSelection", "QuestMapFrame_ShowQuestDetails" }) do
            rec.api[#rec.api + 1] = fn .. "=" .. type(_G[fn])
        end
        rec.api[#rec.api + 1] = "C_QuestLog.GetNumQuestLogEntries=" .. type(C_QuestLog and C_QuestLog.GetNumQuestLogEntries)
        rec.api[#rec.api + 1] = "C_QuestLog.SetSelectedQuest=" .. type(C_QuestLog and C_QuestLog.SetSelectedQuest)
        local m = _G.WorldMapFrame
        if m and m.pinPools then
            for template, pool in pairs(m.pinPools) do
                local count = 0
                if pool.EnumerateActive then for _ in pool:EnumerateActive() do count = count + 1 end end
                if count > 0 then rec.pins[#rec.pins + 1] = tostring(template) .. " x" .. count end
            end
        end
        if m and m.GetMapID then rec.api[#rec.api + 1] = "mapID=" .. tostring(m:GetMapID()) end
    end)
    ZenVCExportDB._mapLook = rec
    if not quiet and DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage("|cff2ee6d6VCF:|r the map's windows were noted for the voice commander (nothing was pressed). Close the game as usual to save the note.") end
end

local function startMoveStep()
    if isUp("WorldMapFrame") then   -- v124 the map: its quest log side first, then ("move my box") the quest markers
        MAPLOOK.run(true)   -- the quiet record stays, in case some lines are built differently
        local list, kind = QG.qlogOpen() and QG.qlogLines() or {}, "qlog"
        if #list == 0 then list, kind = QG.mapPins(), "qmap" end
        if #list == 0 then say1("nothing on the map to move to: no quests in the quest log or on this map") return end
        mark.kind, mark.i = kind, 1
        lightUp(list)
        say1((kind == "qlog" and "quest log: " or "map: ") .. QG.word("/click zenvcmoveup", "move up") .. " or " .. QG.word("/click zenvcmovedown", "move down") .. ", " .. QG.word("/click zenvcselect", "select") .. (kind == "qlog" and " opens the quest, " or " shows that quest, ") .. QG.word("/click zenvcswitchside", "move my box") .. (kind == "qlog" and " goes to the map" or " goes back to the quest log"))
        return
    end
    ZenVCExportDB._lastAct = date("%H:%M:%S") .. " start move"
    local tries = {
        { "qreward", function() return TM.qrewardOpen() and TM.qrewardSlots() or {} end },   -- v106
        { "qgreet", qgreetLines },   -- v122 an NPC's list of quests
        { "trade", function() return TM.tradeOpen() and TM.tradeSlots() or {} end },   -- v95
        { "mail", function() return TM.mailOpen() and TM.mailSlots() or {} end },   -- v95
        { "bank", function() return TM.bankOpen() and TM.bankSlots() or {} end },   -- v100
        { "gbank", function() return TM.gbankOpen() and TM.gbankSlots() or {} end },   -- v104
        { "taxi", function() return taxiOpen() and taxiSlots() or {} end },   -- v88
        { "ah", function() return ahOpen() and ahSlots() or {} end },   -- v77
        { "merchant", function() return merchantOpen() and merchantSlots() or {} end },
        { "bags", bagSlots },
        { "gossip", function() return isUp("GossipFrame") and gossipLines() or {} end },
    }
    for _, t in ipairs(tries) do
        local list = t[2]()
        if #list > 0 then
            mark.kind, mark.i = t[1], 1
            if t[1] == "mail" then mark.i = TM.mailFirst(list) end   -- v95
            if t[1] == "ah" then for k, e in ipairs(list) do if e.group >= 1 then mark.i = k break end end end   -- v84: begin on the categories, not the search row
            lightUp(list); return
        end
    end
    say1("open your bags, a vendor, the auction house, a flight map, a talk window or a quest list first, then say start move")
end

-- v68: a quiet check twice a second. Reads only: which window is open and which vendor page shows. Nothing is pressed or set in the game's windows.
local lastPage
local mailLastSend   -- v95
C_Timer.NewTicker(0.5, function()
    pcall(function()
        if armed.kind == "use" and isUp("MerchantFrame") then disarm() end   -- v74: a vendor opened, using would sell it
        if pad.frame and pad.frame:IsShown() and (mark.kind ~= "pad" or not (pad.box and pad.box:IsVisible())) then   -- v91
            pad.frame:Hide(); pad.box = nil
            if mark.kind == "pad" then mark.kind, mark.i = nil, 0; markerOff() end
        end
        -- v83: "select" stays aimed at the outlined Auction House row, "back" at the Auction House's Back button while one shows
        pcall(function()
            if ahSelTarget then
                if mark.kind == "ah" and ahOpen() then aimKey("/click zenvcselect", "ZenVCAHSelect", ahSelTarget)
                else aimKey("/click zenvcselect"); ahSelTarget = nil end
            end
            -- v88: the flight map closed or the outline left it: select and accept go back to normal
            if taxiAimFr and not (mark.kind == "taxi" and taxiOpen()) then aimKey("/click zenvctakeoff"); taxiAimFr = nil end   -- v90
            -- v85: the outline left the Auction House: accept and the move keys go back to normal
            if ahCurFr and not (mark.kind == "ah" and ahOpen()) then
                aimKey("/click questframeacceptbutton"); aimKey("/click zenvcmovedown"); aimKey("/click zenvcmoveup"); ahCurFr = nil
            end
            -- v85: after a scroll the same row on screen holds another item: show it (and re-aim) without a new spoken move
            if ahCurFr and mark.kind == "ah" and ahOpen() then
                local list = ahSlots()
                for k, e in ipairs(list) do
                    if e.fr == ahCurFr then
                        if e.name ~= ahCurName or (tostring(e.isFirst) .. tostring(e.isLast)) ~= ahCurFlags then mark.i = k; lightUp(list) end
                        break
                    end
                end
            end
            -- v94 "buy that" in the Auction House: the buying screen's Buy Now (a stack) or Buyout (one auction), the game's own click;
            -- the game asks its own "are you sure" (user chose this over a VCF box: "if vcf asks ... then the game asks ... it just seems overdone")
            local bbtn
            pcall(function()
                local c = AuctionHouseFrame.CommoditiesBuyFrame
                local i2 = AuctionHouseFrame.ItemBuyFrame
                if c and c:IsVisible() and c.BuyDisplay and c.BuyDisplay.BuyButton and c.BuyDisplay.BuyButton:IsVisible() then bbtn = c.BuyDisplay.BuyButton
                elseif i2 and i2:IsVisible() and i2.BuyoutFrame and i2.BuyoutFrame.BuyoutButton and i2.BuyoutFrame.BuyoutButton:IsVisible() then bbtn = i2.BuyoutFrame.BuyoutButton end
            end)
            if bbtn and ahOpen() then aimKey("/click zenvcbuy", "ZenVCAHBuy", bbtn); ahBuyAimed = true   -- v94: your Buy command ("buy that")
            elseif ahBuyAimed then aimKey("/click zenvcbuy"); ahBuyAimed = nil end
            -- v85 "search now": the Auction House's own Search button, the game's own click, while the Auction House is open
            local sbtn = ahOpen() and AuctionHouseFrame.SearchBar and AuctionHouseFrame.SearchBar.SearchButton
            if sbtn and sbtn:IsVisible() then aimKey("/click zenvcsearchnow", "ZenVCAHSearch", sbtn); searchAimed = true
            elseif searchAimed then aimKey("/click zenvcsearchnow"); searchAimed = nil end
            local bb
            if ahOpen() then
                for _, k in ipairs({ "ItemBuyFrame", "CommoditiesBuyFrame" }) do
                    local fr = AuctionHouseFrame[k]
                    if fr and fr:IsVisible() and fr.BackButton and fr.BackButton:IsVisible() then bb = fr.BackButton end
                end
            end
            -- v84 (2026-11-09, user: "I need a way to accept invite or decline invite", screenshot of a GUILD invite): a guild invite is its own window,
            -- not the game's question box that "accept invite" / "decline invite" press for a party invite. While it shows, the two keys are aimed at
            -- its Join Guild and Decline Invitation buttons (the game's own click); afterwards they go back to the question box.
            local gf = _G.GuildInviteFrame
            if gf and gf:IsVisible() then
                local join = _G.GuildInviteFrameJoinButton or gf.JoinButton or gf.AcceptButton
                local decl = _G.GuildInviteFrameDeclineButton or gf.DeclineButton
                if join then aimKey("/click staticpopup1button1", "ZenVCGuildJoin", join) end
                if decl then aimKey("/click staticpopup1button2", "ZenVCGuildDecline", decl) end
                guildAimed = true
            elseif guildAimed then
                aimKey("/click staticpopup1button1"); aimKey("/click staticpopup1button2"); guildAimed = nil
            end
            if bb then aimKey("/click zenvcback", "ZenVCAHBack", bb); ahBackAimed = true
            elseif ahBackAimed then aimKey("/click zenvcback"); ahBackAimed = nil end
        end)
        -- v95 mail: the outline left the mailbox (select back to normal); a waiting "send mail" is cancelled when the mail changes; the outline
        -- follows a change of tab
        if QG.mapSel and not ((mark.kind == "qlog" and QG.qlogOpen()) or (mark.kind == "qmap" and QG.mapOpen())) then aimKey("/click zenvcselect"); QG.mapSel = nil end   -- v124
        if mailSelTarget and not ((mark.kind == "mail" and TM.mailOpen()) or (mark.kind == "bank" and TM.bankOpen()) or (mark.kind == "gbank" and TM.gbankOpen()) or (mark.kind == "qreward" and TM.qrewardOpen())) then aimKey("/click zenvcselect"); mailSelTarget = nil end
        -- v98 (user: "it should only do that once MOVE START or START MOVE is initiated")
        if (mark.kind == "mail" and TM.mailOpen()) or (mark.kind == "trade" and TM.tradeOpen()) or (mark.kind == "pad" and (pad.from == "mail" or pad.from == "trade")) then
            local fb = GetCurrentKeyBoardFocus and GetCurrentKeyBoardFocus()
            local n = fb and fb.GetName and fb:GetName() or ""
            if fb and fb.ClearFocus and (n:find("^SendMail") or n:find("^TradePlayerInputMoneyFrame")) then
                fb:ClearFocus()
            end
        end
        if mark.kind == "qreward" and TM.qrewardOpen() then   -- v106: show the choice once the game has marked it
            local ch = QuestInfoFrame and QuestInfoFrame.itemChoice or 0
            if ch ~= (TM.qrChosen or 0) then TM.qrChosen = ch; lightUp(TM.qrewardSlots()) end
        else TM.qrChosen = nil end
        if mailGetTarget and not (mark.kind == "mail" and TM.mailOpen()) then aimKey("/click zenvcgetthat"); mailGetTarget = nil end
        if armed.kind == "mail" then
            if not TM.mailSendOpen() then disarm()
            elseif TM.mailTerms() ~= armed.terms then
                disarm(); say1("the mail changed, so send mail was cancelled. " .. TM.mailTerms() .. ". Say send mail to see it again")
            end
        end
        if mark.kind == "mail" and TM.mailOpen() then
            local sv = (TM.mailSendOpen() and "send") or (isUp("OpenMailFrame") and ("open " .. tostring(InboxFrame and InboxFrame.openMailID))) or ("inbox " .. tostring(InboxFrame and InboxFrame.pageNum))
            if mailLastSend ~= nil and sv ~= mailLastSend and armed.kind ~= "mail" then local l = TM.mailSlots(); mark.i = TM.mailFirst(l); lightUp(l) end
            mailLastSend = sv
        else mailLastSend = nil end
        if not mark.kind then lastPage = nil return end
        local open = (mark.kind == "merchant" and merchantOpen()) or (mark.kind == "bags" and bagsOpen()) or (mark.kind == "gossip" and isUp("GossipFrame")) or (mark.kind == "qgreet" and isUp("QuestFrameGreetingPanel")) or (mark.kind == "qlog" and QG.qlogOpen()) or (mark.kind == "qmap" and QG.mapOpen()) or (mark.kind == "ah" and ahOpen()) or (mark.kind == "taxi" and taxiOpen()) or (mark.kind == "trade" and TM.tradeOpen()) or (mark.kind == "mail" and TM.mailOpen()) or (mark.kind == "bank" and TM.bankOpen()) or (mark.kind == "gbank" and TM.gbankOpen()) or (mark.kind == "qreward" and TM.qrewardOpen()) or (mark.kind == "pad" and pad.frame and pad.frame:IsShown() and pad.box and pad.box:IsVisible())   -- v93: the keypad counts as open
        if not open then mark.kind, mark.i = nil, 0; markerOff(); lastPage = nil return end
        if mark.kind == "merchant" then
            local page = MerchantFrame and MerchantFrame.page
            if lastPage and page and page ~= lastPage then mark.i = 1; lightUp(merchantSlots()) end
            lastPage = page
        end
    end)
end)

local function moveStep(dir)
    if EM.on then EM.nudge(dir) return end   -- v120 edit layout
    ZenVCExportDB._lastAct = date("%H:%M:%S") .. " move " .. tostring(dir) .. " (" .. tostring(mark.kind) .. ")"
    local rec = { at = date("%Y-%m-%d %H:%M:%S"), dir = dir, acted = "nothing" }
    pcall(function()
        if mark.kind == "pad" and pad.frame and pad.frame:IsShown() then   -- v91
            local list = padSlots()
            mark.i = (mark.i == 0) and 1 or bagNeighbour(list, math.min(mark.i, #list), dir)
            lightUp(list)
            rec.acted = "pad key " .. tostring(list[mark.i] and list[mark.i].padKey)
            return
        end
        if (mark.kind == "qlog" and QG.qlogOpen()) or (mark.kind == "qmap" and QG.mapOpen()) then   -- v124
            local list = mark.kind == "qlog" and QG.qlogLines() or QG.mapPins()
            if #list == 0 then say1("nothing here to move to") return end
            -- both sides are lists, like the flight master's (user: "the map should work like the flight master... it will expand as time goes on")
            local step = (dir == "up" or dir == "left") and -1 or 1
            local want = (mark.i == 0) and 1 or mark.i + step
            if want > #list then say1("end of the list") elseif want < 1 then say1("top of the list") end
            mark.i = math.max(1, math.min(#list, want))
            lightUp(list)
            rec.acted = mark.kind .. " " .. mark.i
            return
        end
        if mark.kind == "qreward" and TM.qrewardOpen() then   -- v106
            local list = TM.qrewardSlots()
            if #list == 0 then say1("no rewards to choose here") return end
            mark.i = (mark.i == 0) and 1 or bagNeighbour(list, math.min(math.max(mark.i, 1), #list), dir)
            lightUp(list)
            rec.acted = "reward " .. mark.i
            return
        end
        if mark.kind == "gbank" and TM.gbankOpen() then   -- v104
            local list = TM.gbankSlots()
            if #list == 0 then say1("nothing in the guild bank window to move to") return end
            mark.i = (mark.i == 0) and 1 or bagNeighbour(list, math.min(math.max(mark.i, 1), #list), dir)
            lightUp(list)
            rec.acted = "guild bank line " .. mark.i
            return
        end
        if mark.kind == "bank" and TM.bankOpen() then   -- v100
            local list = TM.bankSlots()
            if #list == 0 then say1("nothing in the bank window to move to") return end
            mark.i = (mark.i == 0) and 1 or bagNeighbour(list, math.min(math.max(mark.i, 1), #list), dir)
            lightUp(list)
            rec.acted = "bank line " .. mark.i
            return
        end
        if mark.kind == "mail" and TM.mailOpen() then   -- v95
            local list = TM.mailSlots()
            mark.i = (mark.i == 0) and 1 or bagNeighbour(list, math.min(math.max(mark.i, 1), #list), dir)
            lightUp(list)
            rec.acted = "mail line " .. mark.i
            return
        end
        if mark.kind == "trade" and TM.tradeOpen() then   -- v95
            local list = TM.tradeSlots()
            mark.i = (mark.i == 0) and 1 or bagNeighbour(list, math.min(math.max(mark.i, 1), #list), dir)
            lightUp(list)
            rec.acted = "trade line " .. mark.i
            return
        end
        if mark.kind == "taxi" and taxiOpen() then   -- v88
            local list = taxiSlots()
            if #list == 0 then say1("no flight points to fly to from here") return end
            local step = (dir == "up" or dir == "left") and -1 or 1
            local want = (mark.i == 0) and 1 or mark.i + step
            if want > #list then say1("end of the list") elseif want < 1 then say1("top of the list") end
            mark.i = math.max(1, math.min(#list, want))
            lightUp(list)
            rec.acted = "flight point " .. mark.i
            return
        end
        if mark.kind == "ah" and ahOpen() then   -- v77
            local list = ahSlots()
            if #list == 0 then say1("nothing in the auction house lists yet") return end
            mark.i = (mark.i == 0) and 1 or ahNeighbour(list, math.min(mark.i, #list), dir)
            lightUp(list)
            rec.acted = "auction row " .. mark.i
            return
        end
        if mark.kind == "bags" and bagsOpen() then
            local list = bagSlots()
            mark.i = (mark.i == 0) and 1 or bagNeighbour(list, math.min(mark.i, #list), dir)
            lightUp(list)
            rec.acted = "bag slot " .. mark.i
            return
        end
        if merchantOpen() then
            local list = merchantSlots()
            if #list == 0 then return end
            if mark.kind ~= "merchant" then mark.kind, mark.i = "merchant", 0 end
            local step = (dir == "up" and -2) or (dir == "down" and 2) or (dir == "left" and -1) or 1   -- the vendor shows two items side by side
            local want = mark.i == 0 and 1 or mark.i + step
            -- v68 (2026-11-07): the add-on never presses the vendor's page arrow itself (that brought the blocked box at 14:48). The page is turned by the
            -- "move page right" / "move page left" commands, which run the game's own /click macro on the arrow (a game-approved press).
            if want > #list then say1("end of this page: say move page right")
            elseif want < 1 and mark.i ~= 0 then say1("start of this page: say move page left") end
            mark.i = math.max(1, math.min(#list, want))
            lightUp(list)
            rec.acted = "vendor item " .. mark.i
        elseif isUp("QuestFrameGreetingPanel") then   -- v122
            local list = qgreetLines()
            if #list == 0 then return end
            if mark.kind ~= "qgreet" then mark.kind, mark.i = "qgreet", 0 end
            local step = (dir == "up" or dir == "left") and -1 or 1
            mark.i = math.max(1, math.min(#list, mark.i == 0 and 1 or mark.i + step))
            lightUp(list)
            rec.acted = "quest line " .. mark.i
        elseif isUp("GossipFrame") then
            local list = gossipLines()
            if #list == 0 then return end
            if mark.kind ~= "gossip" then mark.kind, mark.i = "gossip", 0 end
            local step = (dir == "up" or dir == "left") and -1 or 1
            mark.i = math.max(1, math.min(#list, mark.i == 0 and 1 or mark.i + step))
            lightUp(list)
            rec.acted = "talk line " .. mark.i
        end
    end)
    ZenVCExportDB._move = rec
end

local function buyStep()
    local rec = { at = date("%Y-%m-%d %H:%M:%S"), acted = "nothing" }
    pcall(function()
        if not merchantOpen() then rec.acted = "no vendor open" return end
        local list = merchantSlots()
        local e = mark.kind == "merchant" and list[mark.i]
        if not e then say1("say move down or move right first, to choose what to buy") rec.acted = "nothing chosen" return end
        BuyMerchantItem(e.index, 1)
        say1("bought " .. tostring(e.name))
        rec.acted = "bought " .. tostring(e.name)
    end)
    ZenVCExportDB._buy = rec
end

-- v94 (2026-11-09, user: option 2, "that is how the bags works, so ... do that"): at a vendor "buy that" works like "use that" in the bags:
-- the first press changes the outline's colour and says what would be bought; saying it again within 30 seconds buys it. Moving the
-- outline or waiting cancels. (In the Auction House the same key is pointed at the game's own Buy button instead, see aimKey.)
local function buyThatStep()
    if not merchantOpen() then buyStep() return end
    local e = mark.kind == "merchant" and merchantSlots()[mark.i]
    if not e then buyStep() return end   -- buyStep says what to do first
    local now = GetTime and GetTime() or 0
    if armed.kind == "buy" and now - armed.at < 30 then armed.kind = nil; markColor(MARK_ORANGE); buyStep() return end
    armed.kind, armed.at = "buy", now
    markColor(MARK_TEAL)
    say1("buy " .. tostring(e.name) .. "? say buy that again to buy it")
    if C_Timer and C_Timer.After then C_Timer.After(30, function() if armed.kind == "buy" and (GetTime() - armed.at) >= 29 then disarm() end end) end
end

local function sellJunkStep()
    local rec = { at = date("%Y-%m-%d %H:%M:%S"), sold = 0 }
    pcall(function()
        if not isUp("MerchantFrame") then say1("open a vendor first") return end
        local slots = (C_Container and C_Container.GetContainerNumSlots) or GetContainerNumSlots
        local use = (C_Container and C_Container.UseContainerItem) or UseContainerItem
        for bag = 0, 4 do
            for slot = 1, (slots(bag) or 0) do
                local quality, noValue
                if C_Container and C_Container.GetContainerItemInfo then
                    local info = C_Container.GetContainerItemInfo(bag, slot)
                    if info then quality, noValue = info.quality, info.hasNoValue end
                else
                    local _, _, _, q, _, _, _, _, nv = GetContainerItemInfo(bag, slot)
                    quality, noValue = q, nv
                end
                if quality == 0 and not noValue then use(bag, slot); rec.sold = rec.sold + 1 end
            end
        end
        say1(rec.sold == 0 and "no grey items to sell" or ("sold " .. rec.sold .. " grey item(s)"))
    end)
    ZenVCExportDB._sell = rec
end

local function repairStep()
    pcall(function()
        if not isUp("MerchantFrame") then say1("open a vendor first") return end
        if CanMerchantRepair and CanMerchantRepair() then
            local cost = GetRepairAllCost and GetRepairAllCost() or 0
            if cost and cost > 0 then RepairAllItems(); say1("repaired everything") else say1("nothing needs repairing") end
        else say1("this vendor cannot repair") end
    end)
end

local navEvents = CreateFrame("Frame")
pcall(function() navEvents:RegisterEvent("MERCHANT_CLOSED"); navEvents:RegisterEvent("GOSSIP_CLOSED") end)
navEvents:SetScript("OnEvent", function(_, ev)
    if ev == "BAG_CLOSED" and mark.kind ~= "bags" then return end
    mark.kind, mark.i = nil, 0; markerOff()
end)


-- v48 "switch side": vendor items <-> your bags (bags are opened when they are closed)
local function switchSideStep()
    if EM.on then EM.pick(1) return end   -- v120 edit layout: next piece
    if (mark.kind == "qlog" or mark.kind == "qmap") and QG.mapOpen() then QG.flip() return end   -- v124 the map: quest log side <-> map side
    pcall(function()
        if mark.kind ~= "bags" then
            -- never opened from here: the game forbids an add-on opening bags in controller mode (v51)
            local list = bagSlots()
            if #list == 0 then say1("open your bags first, then say move my box") return end
            mark.kind, mark.i = "bags", 1
            lightUp(list)
        else
            if TM.tradeOpen() then   -- v95 back from the bags to the trade window
                mark.kind, mark.i = "trade", 1
                lightUp(TM.tradeSlots())
            elseif TM.gbankOpen() and #TM.gbankSlots() > 0 then   -- v104 from the bags to the guild bank
                mark.kind, mark.i = "gbank", 1
                lightUp(TM.gbankSlots())
            elseif TM.bankOpen() and #TM.bankSlots() > 0 then   -- v100 from the bags to the bank
                mark.kind, mark.i = "bank", 1
                lightUp(TM.bankSlots())
            elseif TM.mailSendOpen() then   -- v95 back from the bags to the mail
                mark.kind, mark.i = "mail", 1
                lightUp(TM.mailSlots())
            elseif merchantOpen() then
                local list = merchantSlots()
                mark.kind, mark.i = "merchant", 1
                lightUp(list)
            else
                mark.kind, mark.i = nil, 0
                markerOff()
                say1("outline off")
            end
        end
    end)
end

-- v48 "sell that": the outlined bag item, only at a vendor
local function sellThatStep()
    local rec = { at = date("%Y-%m-%d %H:%M:%S"), acted = "nothing" }
    pcall(function()
        if not isUp("MerchantFrame") then say1("open a vendor first: outside a vendor this would use or equip the item") rec.acted = "no vendor" return end
        local e = mark.kind == "bags" and bagSlots()[mark.i]
        if not e then say1("say move my box, then move to the item to sell") rec.acted = "nothing outlined" return end
        if e.name == "empty" then say1("that slot is empty") rec.acted = "empty slot" return end
        local use = (C_Container and C_Container.UseContainerItem) or UseContainerItem
        use(e.bag, e.slot)
        say1("sold " .. tostring(e.name))
        rec.acted = "sold " .. tostring(e.name)
    end)
    ZenVCExportDB._sellThat = rec
end

-- v61 (2026-11-07, user: "I want to be able to use or destroy the item with voice after a confirmation box"): the bag item outlined by move up/down/left/right.
-- VCF asks first (X yes, B no), so these run only after the player said yes. Items named in RENAME AN ITEM are not affected.
local function outlinedBagItem(rec)
    local e = mark.kind == "bags" and bagSlots()[mark.i]
    if not e then say1("open your bags, say move my box, then move to the item") rec.acted = "nothing outlined" return nil end
    if e.name == "empty" then say1("that slot is empty") rec.acted = "empty slot" return nil end
    return e
end

local function useThatStep()
    local rec = { at = date("%Y-%m-%d %H:%M:%S"), acted = "nothing" }
    pcall(function()
        if isUp("MerchantFrame") then say1("a vendor is open, so using it would sell it: say sell that, or close the vendor first") rec.acted = "vendor open: not used" return end
        local e = outlinedBagItem(rec)
        if not e then return end
        -- v74: never UseContainerItem here (protected). Using happens only through the secure button (useArmSecure).
        if InCombatLockdown() then say1("not while in combat: say use that again after the fight") rec.acted = "in combat: not used" return end
        say1("say use that again")
        rec.acted = "not used: the secure button was not ready"
    end)
    ZenVCExportDB._useThat = rec
end

local function destroyThatStep()
    local rec = { at = date("%Y-%m-%d %H:%M:%S"), acted = "nothing" }
    pcall(function()
        local e = outlinedBagItem(rec)
        if not e then return end
        if CursorHasItem and CursorHasItem() then ClearCursor() end
        local pick = (C_Container and C_Container.PickupContainerItem) or PickupContainerItem
        pick(e.bag, e.slot)
        local kind = GetCursorInfo and GetCursorInfo()
        if kind ~= "item" then say1("could not pick it up, nothing was destroyed") rec.acted = "pick up failed: nothing destroyed" return end
        DeleteCursorItem()
        say1("destroyed " .. tostring(e.name))
        rec.acted = "destroyed " .. tostring(e.name)
    end)
    ZenVCExportDB._destroyThat = rec
end

local function armOrFire(kind, step, b)
    local now = GetTime and GetTime() or 0
    if armed.kind == kind and now - armed.at < 30 then
        armed.kind = nil; markColor(MARK_ORANGE)
        if kind == "use" then useBindBack(); step(); return end   -- v74: a use press that reached this ordinary button did not go through the secure one
        step(); return
    end
    local e = mark.kind == "bags" and bagSlots()[mark.i]
    if not e or e.name == "empty" or (kind == "use" and (isUp("MerchantFrame") or InCombatLockdown())) then step(); return end   -- nothing to wait for: the step says why
    if kind == "use" and not useArmSecure(e, b and b.key, b and b.id) then step(); return end
    armed.kind, armed.at = kind, now
    markColor(kind == "destroy" and MARK_RED or MARK_TEAL)
    say1((kind == "destroy" and "destroy " or (isUp("TradeFrame") and "put in the trade: " or isUp("SendMailFrame") and "attach to the mail: " or "use ")) .. tostring(e.name) .. "? Answer in VCF: say yes do that or no do not (X or B on a controller)")   -- v95
    if C_Timer and C_Timer.After then C_Timer.After(30, function() if armed.kind == kind and (GetTime() - armed.at) >= 29 then disarm() end end) end
end

-- v95 "finish trade" (user: "SAY IT 2X SO WE CAN SEE THE TERMS OF THE TRADE"). The first time: the box shows the whole trade, the outline goes onto the
-- trade window's own Trade button (teal) and the key is pointed at that button (the game's own click, see aimKey). The second time, within 30 seconds,
-- is that click. If either side changes the trade in between, the first one is cancelled and the new terms are shown.
local function finishTradeStep()
    ZenVCExportDB._lastAct = date("%H:%M:%S") .. " finish trade"
    pcall(function()
        if not TM.tradeOpen() then say1("no trade window is open: target a player and say trade") return end
        if InCombatLockdown() then say1("not while in combat") return end
        local btn = _G.TradeFrameTradeButton
        if not btn then say1("could not find the trade window's Trade button") return end
        if armed.kind == "trade" and GetTime() - armed.at < 30 then
            disarm(); say1("the Trade button could not be pressed by voice: nothing was accepted. Say finish trade to try again") return
        end
        local give, get = TM.tradeTerms()
        mark.kind, mark.i = "trade", 1
        lightUp(TM.tradeSlots())   -- the box shows the whole trade (and cancels anything else waiting)
        markerOn(btn)
        armed.kind, armed.at, armed.terms = "trade", GetTime(), give .. "|" .. get
        markColor(MARK_TEAL)
        aimKey("/click zenvcfinishtrade", "ZenVCTradeGo", btn)
        armed.unaim = function() aimKey("/click zenvcfinishtrade") end
        local g = _G["ZenVCTradeGo"]
        if g and not g.zvHooked then
            g.zvHooked = true
            g:HookScript("PostClick", function()
                ZenVCExportDB._trade = { at = date("%Y-%m-%d %H:%M:%S"), acted = "pressed Trade", terms = armed.terms }
                if C_Timer and C_Timer.After then C_Timer.After(0.3, function() if armed.kind == "trade" then disarm() end end) end
            end)
        end
        say1("you give: " .. give .. ". you get: " .. get .. ". Say finish trade again within 30 seconds to accept")
        local at = armed.at
        if C_Timer and C_Timer.After then C_Timer.After(30, function()
            if armed.kind == "trade" and armed.at == at then disarm(); say1("finish trade timed out: nothing was accepted") end
        end) end
    end)
end
do
    local tf = CreateFrame("Frame")
    for _, ev in ipairs({ "TRADE_SHOW", "TRADE_CLOSED", "TRADE_ACCEPT_UPDATE", "TRADE_PLAYER_ITEM_CHANGED", "TRADE_TARGET_ITEM_CHANGED", "TRADE_MONEY_CHANGED" }) do
        pcall(function() tf:RegisterEvent(ev) end)
    end
    local accP, accT = 0, 0
    local function refresh()
        if mark.kind == "trade" and TM.tradeOpen() and armed.kind ~= "trade" then
            local list = TM.tradeSlots()
            mark.i = math.max(1, math.min(mark.i, #list))
            lightUp(list)
        end
    end
    tf:SetScript("OnEvent", function(_, ev, a1, a2)
        pcall(function()
            if ev == "TRADE_SHOW" then   -- v98: no outline by itself; "start move" begins it
                accP, accT = 0, 0
            elseif ev == "TRADE_CLOSED" then
                if armed.kind == "trade" then disarm() end
                if mark.kind == "trade" then mark.kind, mark.i = nil, 0; markerOff() end
            elseif ev == "TRADE_ACCEPT_UPDATE" then
                local p, t = tonumber(a1) or 0, tonumber(a2) or 0
                if p == 1 and accP ~= 1 then
                    if armed.kind == "trade" then disarm() end
                    say1("you accepted. Waiting for " .. TM.tradeName())
                end
                if t == 1 and accT ~= 1 then say1(TM.tradeName() .. " accepted") end
                if p == 0 and accP == 1 then
                    local g, r = TM.tradeTerms()
                    say1("the trade changed, so you are no longer accepted. you give: " .. g .. ". you get: " .. r)
                end
                accP, accT = p, t
            else   -- an item or money changed on either side
                if armed.kind == "trade" then
                    local g, r = TM.tradeTerms()
                    if g .. "|" .. r ~= armed.terms then
                        disarm()
                        say1("the trade changed, so finish trade was cancelled. you give: " .. g .. ". you get: " .. r .. ". Say finish trade to see it again")
                    end
                end
                if C_Timer and C_Timer.After then C_Timer.After(0.2, function() pcall(refresh) end) end
            end
        end)
    end)
end

-- v95 "send mail", said twice like "finish trade": the first time the box shows the whole mail and the outline goes onto the Send button; the second
-- time, within 30 seconds, is the game's own click on it. A change to the mail in between cancels the first one.
local function sendMailStep()
    ZenVCExportDB._lastAct = date("%H:%M:%S") .. " send mail"
    pcall(function()
        if not TM.mailSendOpen() then
            say1(TM.mailOpen() and "open the Send Mail tab first: say start move, then select" or "open a mailbox first") return
        end
        if InCombatLockdown() then say1("not while in combat") return end
        local btn = _G.SendMailMailButton
        if not btn then say1("could not find the mailbox's Send button") return end
        if armed.kind == "mail" and GetTime() - armed.at < 30 then
            disarm(); say1("the Send button could not be pressed by voice: nothing was sent. Say send mail to try again") return
        end
        local to = _G.SendMailNameEditBox and SendMailNameEditBox:GetText() or ""
        mark.kind, mark.i = "mail", 1
        lightUp(TM.mailSlots())   -- the box shows the whole mail (and cancels anything else waiting)
        if to == "" then say1("who is it for? select on the to box and type the name first") return end
        if btn.IsEnabled and not btn:IsEnabled() then say1("the Send button is greyed out: add a subject or an item first") return end
        markerOn(btn)
        local tm = TM.mailTerms()
        armed.kind, armed.at, armed.terms = "mail", GetTime(), tm
        markColor(MARK_TEAL)
        aimKey("/click zenvcsendmail", "ZenVCMailGo", btn)
        armed.unaim = function() aimKey("/click zenvcsendmail") end
        local g = _G["ZenVCMailGo"]
        if g and not g.zvHooked then
            g.zvHooked = true
            g:HookScript("PostClick", function()
                if C_Timer and C_Timer.After then C_Timer.After(0.3, function() if armed.kind == "mail" then disarm() end end) end
            end)
        end
        say1(tm .. ". Say send mail again within 30 seconds to send it")
        local at = armed.at
        if C_Timer and C_Timer.After then C_Timer.After(30, function()
            if armed.kind == "mail" and armed.at == at then disarm(); say1("send mail timed out: nothing was sent") end
        end) end
    end)
end
do
    local mf = CreateFrame("Frame")
    for _, ev in ipairs({ "MAIL_SHOW", "MAIL_CLOSED", "MAIL_SEND_SUCCESS", "MAIL_FAILED", "MAIL_SEND_INFO_UPDATE", "MAIL_INBOX_UPDATE" }) do
        pcall(function() mf:RegisterEvent(ev) end)
    end
    local function refresh()
        if mark.kind == "mail" and TM.mailOpen() and armed.kind ~= "mail" then
            local list = TM.mailSlots()
            mark.i = math.max(1, math.min(mark.i, #list))
            lightUp(list)
        end
    end
    mf:SetScript("OnEvent", function(_, ev)
        pcall(function()
            if ev == "MAIL_SHOW" then   -- v98: no outline by itself; "start move" begins it
            elseif ev == "MAIL_CLOSED" then
                if armed.kind == "mail" then disarm() end
                if mark.kind == "mail" then mark.kind, mark.i = nil, 0; markerOff() end
            elseif ev == "MAIL_SEND_SUCCESS" then
                if armed.kind == "mail" then disarm() end
                say1("mail sent")
                if C_Timer and C_Timer.After then C_Timer.After(0.3, function() pcall(refresh) end) end
            elseif ev == "MAIL_FAILED" then
                if armed.kind == "mail" then disarm() end
                say1("the mail was not sent")
            else
                if C_Timer and C_Timer.After then C_Timer.After(0.2, function() pcall(refresh) end) end
            end
        end)
    end)
end

-- v62 (2026-11-07, user: "I need a NEXT PAGE that works for panels that have another page, and previous page needs to be there too"): presses the page button of
-- whichever open window has one (vendor, spellbook, mailbox, auction house browse, and others the game names the same way). The vendor outline follows the new page.
local NEXT_PAGE = { "MerchantNextPageButton", "SpellBookNextPageButton", "InboxNextPageButton", "BrowseNextPageButton", "QuestLogFrameNextPageButton",
    "ItemTextNextPageButton", "PetStableNextPageButton", "TradeSkillNextPageButton" }
local PREV_PAGE = { "MerchantPrevPageButton", "SpellBookPrevPageButton", "InboxPrevPageButton", "BrowsePrevPageButton", "QuestLogFramePrevPageButton",
    "ItemTextPrevPageButton", "PetStablePrevPageButton", "TradeSkillPrevPageButton" }
local function pageStep(names, word)
    ZenVCExportDB._lastAct = date("%H:%M:%S") .. " page " .. tostring(word)
    local rec = { at = date("%Y-%m-%d %H:%M:%S"), acted = "nothing" }
    pcall(function()
        for _, n in ipairs(names) do
            local b = _G[n]
            if b and b.IsVisible and b:IsVisible() then
                if b.IsEnabled and not b:IsEnabled() then say1("no " .. word .. " page") rec.acted = n .. " is greyed out" return end
                b:Click()
                rec.acted = "clicked " .. n
                if mark.kind == "merchant" then mark.i = 1; lightUp(merchantSlots())
                elseif mark.kind == "panel" then mark.i = 1; lightUp(panelSlots()) end
                return
            end
        end
        say1("nothing open has a " .. word .. " page")
    end)
    ZenVCExportDB._page = rec
end

-- v61 (2026-11-07, user: "there needs to be a STOP MOVE that takes the highlight off in the bag... it was stuck there until I reloaded")
local function stopMoveStep()
    if EM.on then EM.done() return end   -- v120 edit layout: done editing
    if ZenVCExportDB._holding and CursorHasItem and CursorHasItem() then ClearCursor(); say1("put back") end   -- v100 a "move that" item goes back
    ZenVCExportDB._holding = nil
    mark.kind, mark.i = nil, 0
    markerOff()
    say1("outline off")
end

-- v71 (2026-11-07, user: three tooltip sizes, chosen by voice): remembered in the saved data
local function tipSizeStep(scale, word)
    if EM.on then EM.size(word == "large" and 1 or word == "small" and -1 or 0) return end   -- v120 edit layout: bigger / smaller / normal size
    ZenVCExportDB._tipScale = scale
    say1("tooltip size: " .. word)
    if mark.kind then
        local list = (mark.kind == "trade" and TM.tradeSlots()) or (mark.kind == "mail" and TM.mailSlots()) or (mark.kind == "merchant" and merchantSlots()) or (mark.kind == "bags" and bagSlots()) or (mark.kind == "gossip" and gossipLines()) or {}
        if #list > 0 then lightUp(list) end   -- shows the outlined item's tooltip again at the new size
    end
end

local function selectStep()
    if (mark.kind == "qlog" or mark.kind == "qmap") and QG.mapOpen() then say1("select works on the map out of combat") return end   -- v124 (out of combat it is aimed at the quest itself)
    if mark.kind == "taxi" and taxiOpen() then say1("say take off to fly to the outlined flight point") return end   -- v90
    if mark.kind == "pad" then padPress() return end   -- v91
    if mark.kind == "gbank" and TM.gbankOpen() then   -- v104
        local e = TM.gbankSlots()[mark.i]
        say1((e and e.bankBtn) and "that could not be pressed by voice" or "say move that to pick it up, then move to where it goes and say move that again")
        return
    end
    if mark.kind == "bank" and TM.bankOpen() then   -- v100 (a tab is pressed by the aimed key, so this is an item or the aim failed)
        local e = TM.bankSlots()[mark.i]
        say1((e and (e.bankTab or e.bankBtn)) and "that could not be pressed by voice" or "say move that to pick it up, then move to where it goes and say move that again")
        return
    end
    if mark.kind == "mail" and TM.mailOpen() then   -- v95
        local e = TM.mailSlots()[mark.i]
        if e and e.mailBox then padOpen(e.mailBox, mark.i, "mail", (e.mailBox == _G.SendMailNameEditBox) and TM.mailNames() or nil); lightUp(padSlots())
        elseif e and (e.mailTab or e.inRow or e.mailClose) then say1("that could not be pressed by voice")
        elseif e and e.mailTake then say1("say get that to take it")
        else say1("say select on the to, subject, letter or money boxes for the keypad. To attach an item, say move my box and use that. Send mail twice sends it") end
        return
    end
    if mark.kind == "trade" and TM.tradeOpen() then   -- v95
        local e = TM.tradeSlots()[mark.i]
        if e and e.tradeBox then padOpen(e.tradeBox, mark.i, "trade"); lightUp(padSlots())
        else say1("say select on your gold, silver or copper to open the number pad. To put in an item, say move my box and use that. Finish trade twice accepts") end
        return
    end
    if mark.kind == "ah" and ahOpen() then   -- v91: select on a search or quantity box opens the keypad
        local e = ahSlots()[mark.i]
        if e and e.edit then padOpen(e.edit, mark.i); lightUp(padSlots()) return end
        if e and e.noClick then say1("to buy, say buy that") return end   -- v94
    end
    local rec = { at = date("%Y-%m-%d %H:%M:%S"), acted = "nothing", lines = {} }
    local function up(n) local fr = _G[n]; return fr and fr.IsVisible and fr:IsVisible() end
    pcall(function()
        if mark.kind == "bags" and isUp("MerchantFrame") then
            sellThatStep(); rec.acted = "vendor: sold the outlined bag item"
            return
        end
        if merchantOpen() and mark.kind == "merchant" then
            buyStep(); rec.acted = "vendor: bought the item VCF points at"
            return
        end
        if up("QuestFrameGreetingPanel") then   -- v122 the quest greeting list
            local e = qgreetChosen()
            rec.acted = "quest list: " .. (e and qgreetPick(e) or (qgreetFirstByNumber() or "no quest lines found"))
            return
        end
        if up("GossipFrame") and mark.kind == "gossip" then
            local e = gossipLines()[mark.i]
            if e then local ok, err = pcall(e.fr.Click, e.fr); rec.acted = "clicked the line VCF points at: " .. tostring(e.name) .. (ok and "" or (" failed: " .. tostring(err))); return end
        end
        if up("GossipFrame") then
            -- the lines on screen; the one the controller has highlighted wins
            local box = GossipFrame.GreetingPanel and GossipFrame.GreetingPanel.ScrollBox
            local picked
            if box and box.ForEachFrame then
                box:ForEachFrame(function(fr)
                    local d = fr.GetElementData and fr:GetElementData() or nil
                    local info = d and d.info
                    local txt = (fr.GetText and fr:GetText()) or (info and (info.name or info.title)) or "?"
                    local focus = (fr.IsMouseMotionFocus and fr:IsMouseMotionFocus()) or (fr.IsMouseOver and fr:IsMouseOver()) or false
                    local locked = (fr.IsHighlightLocked and fr:IsHighlightLocked()) or false
                    local state = fr.GetButtonState and fr:GetButtonState() or "?"
                    local clickable = info and (info.gossipOptionID or info.questID or info.orderIndex) and fr.Click
                    rec.lines[#rec.lines + 1] = string.format("%s | type %s | focus %s | locked %s | state %s", tostring(txt), tostring(d and d.buttonType), tostring(focus), tostring(locked), tostring(state))
                    if clickable and (focus or locked or state == "PUSHED") and not picked then picked = fr end
                end)
            end
            if picked then
                local ok, err = pcall(picked.Click, picked)
                rec.acted = "clicked the highlighted line" .. (ok and "" or (" failed: " .. tostring(err)))
                return
            end
            -- nothing highlighted that we can see: the first line, in the order the window shows them (quests to pick up, quests in progress, then the talk options)
            local av = C_GossipInfo and C_GossipInfo.GetAvailableQuests and C_GossipInfo.GetAvailableQuests() or {}
            local ac = C_GossipInfo and C_GossipInfo.GetActiveQuests and C_GossipInfo.GetActiveQuests() or {}
            local op = C_GossipInfo and C_GossipInfo.GetOptions and C_GossipInfo.GetOptions() or {}
            if av[1] and av[1].questID then C_GossipInfo.SelectAvailableQuest(av[1].questID); rec.acted = "first line: picked up quest " .. tostring(av[1].title)
            elseif ac[1] and ac[1].questID then C_GossipInfo.SelectActiveQuest(ac[1].questID); rec.acted = "first line: quest in progress " .. tostring(ac[1].title)
            elseif op[1] and op[1].gossipOptionID then C_GossipInfo.SelectOption(op[1].gossipOptionID); rec.acted = "first line: option " .. tostring(op[1].name) end
        elseif up("QuestFrame") then
            questStep(); rec.acted = "quest window: did what the quest button does"
        elseif up("StaticPopup1") and _G.StaticPopup1Button1 and StaticPopup1Button1:IsVisible() then
            StaticPopup1Button1:Click(); rec.acted = "yes/no box: yes"
        end
    end)
    ZenVCExportDB._select = rec
end

local function ensureButton(b)
    local name = BTN_PREFIX .. b.id
    local f = _G[name]
    if f then
        if not f.zvEmote and not f.zvReload and not f.zvQuest and not f.zvBack and not InCombatLockdown() then step("set macrotext on " .. b.id); setButtonAction(f, b) end
        return f
    end
    -- reload: a secure macro button does not run /reload, so a plain button calls the game's own ReloadUI
    if b.text:lower() == "/reload" and ReloadUI then
        step("create reload button " .. b.id)
        f = CreateFrame("Button", name, UIParent)
        f.zvReload = true
        f:RegisterForClicks("AnyUp")
        f:SetScript("OnClick", function() noteClick(b.id); ReloadUI() end)
        return f
    end
    -- the quest window's Accept button (see questStep): a plain button, because the answer depends on which quest window is on screen
    if b.text:lower() == "/click questframeacceptbutton" then
        step("create quest button " .. b.id)
        f = CreateFrame("Button", name, UIParent)
        f.zvQuest = true
        f:RegisterForClicks("AnyUp")
        f:SetScript("OnClick", function() noteClick(b.id); questStep() end)
        return f
    end
    -- the plain Lua buttons for NPC windows and vendors (v45 select, v46 move / buy / sell junk / repair): never given a macro
    local plain = {
        ["/click zenvcselect"] = selectStep, ["/click zenvcbuy"] = buyThatStep, ["/click zenvcselljunk"] = sellJunkStep, ["/click zenvcrepair"] = repairStep,
        ["/click zenvcswitchside"] = switchSideStep, ["/click zenvcsellthat"] = sellThatStep,
        ["/click zenvcstopmove"] = stopMoveStep,
        ["/click zenvceditlayout"] = function() EM.toggle() end,
        ["/click zenvcreadquest"] = function() RQ.toggle() end,   -- v121 read quest (again: stop)   -- v120 the one new key: edit layout on / off
        ["/click zenvcpadenter"] = function() padPress() end,   -- v91
        ["/click zenvcfinishtrade"] = function() finishTradeStep() end,   -- v95
        ["/click zenvcsendmail"] = function() sendMailStep() end,   -- v95
        -- v111 (2026-11-09, user: "SNAP CAM might be to put the camera behind us again in an instant"): the game's own saved camera view (the one in use,
        -- cameraView, 5 here), which sits behind the character. A saved view also has its own zoom.
        -- v118 (2026-11-11) "chat whisper": the target's exact name when there is a player target; otherwise the keypad spells the name
        ["/click zenvcwhispertarget"] = function()
            pcall(function()
                if UnitExists("target") and UnitIsPlayer("target") and not UnitIsUnit("target", "player") then
                    ChatFrame_OpenChat("/w " .. GetUnitName("target", true) .. " ")
                else
                    local eb = _G["ZenVCWhisperName"]
                    if not eb then
                        eb = CreateFrame("EditBox", "ZenVCWhisperName", UIParent, "InputBoxTemplate")
                        eb:SetSize(240, 32); eb:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 620); eb:SetAutoFocus(false)
                    end
                    eb:SetText(""); eb:Show(); eb:ClearFocus()
                    padOpen(eb, nil, "whisper")
                    say1("whisper: no player targeted. Spell the name on the letter pad, then Done")
                end
            end)
        end,
        -- 2026-11-11 (user: "CAN THIS DICTATION ALSO BE AN OPTION FOR MAIL AND AUCTION HOUSE?"): with a box selected (the letter pad open on a mail or
        -- Auction House box), the box takes the keyboard and the voice commander types what is said into it; otherwise the chat line opens on the game's channel
        ["/click zenvcdictation"] = function()
            pcall(function()
                if mark.kind == "pad" and pad.box and pad.from ~= "whisper" and pad.box.SetFocus then
                    local box = pad.box
                    padClose(true)
                    box:SetFocus()
                    say1("dictating into the box: speak, then say stop dictation")
                else
                    ChatFrame_OpenChat("")
                end
            end)
        end,
        ["/click zenvcsnapcam"] = function() pcall(function() SetView(tonumber(GetCVar("cameraView")) or 5) end) end,   -- v109 pressed by VCF before Shop, Talk and En Pee See (no words of its own)
        -- v107 (2026-11-09, user: "nudge the camera to look up or look down ... 3 movements ... very very small adjustments, like 10 pixels at a time"):
        -- the game's own camera tilt (MoveViewUpStart / MoveViewDownStart) at a tenth of its speed, stopped after a moment. No key is held in the game.
        -- v108 (user, after the first test): the commands are CAMERA UP 1-3 and LOWER CAMERA 1-3; "CAMERA UP 1 like 3 times what the look up 3 was" (0.4 s -> 1.2 s),
        -- "add that to itself" for 2 (2.4 s), "double that" for 3 (4.8 s); the same times the other way for LOWER CAMERA.
        ["/click zenvclookup1"] = function() pcall(function() MoveViewUpStart(0.1); C_Timer.After(1.2, function() pcall(MoveViewUpStop) end) end) end,
        ["/click zenvclookup2"] = function() pcall(function() MoveViewUpStart(0.1); C_Timer.After(2.4, function() pcall(MoveViewUpStop) end) end) end,
        ["/click zenvclookup3"] = function() pcall(function() MoveViewUpStart(0.1); C_Timer.After(4.8, function() pcall(MoveViewUpStop) end) end) end,
        ["/click zenvclookdown1"] = function() pcall(function() MoveViewDownStart(0.1); C_Timer.After(1.2, function() pcall(MoveViewDownStop) end) end) end,
        ["/click zenvclookdown2"] = function() pcall(function() MoveViewDownStart(0.1); C_Timer.After(2.4, function() pcall(MoveViewDownStop) end) end) end,
        ["/click zenvclookdown3"] = function() pcall(function() MoveViewDownStart(0.1); C_Timer.After(4.8, function() pcall(MoveViewDownStop) end) end) end,
        -- v100 "move that" (user: "MOVE item once picks it up then MOVE DIRECTION or MOVE BAG from bank to bag or bag to bank then MOVE THAT again drops it";
        -- "this could work in bags too for sorting"): the first time picks up the outlined item, the second puts it down on the outlined slot
        -- (on an item the two swap, and you then hold the other one). Stop move puts a held item back where it was.
        ["/click zenvcmovethat"] = function()
            local rec = { at = date("%Y-%m-%d %H:%M:%S"), acted = "nothing" }
            pcall(function()
                local list = (mark.kind == "bank" and TM.bankOpen() and TM.bankSlots()) or (mark.kind == "gbank" and TM.gbankOpen() and TM.gbankSlots())
                    or (mark.kind == "bags" and bagSlots()) or nil
                local e = list and list[mark.i]
                if not (e and ((e.bag ~= nil and e.slot) or e.gslot)) then
                    say1("say start move at your bags, the bank or the guild bank, move to an item, then say move that") rec.acted = "nothing outlined" return
                end
                local where = e.gslot and ("guild tab " .. tostring(e.gtab) .. " slot " .. e.gslot) or (e.bag .. " " .. e.slot)   -- v104
                local pick = (C_Container and C_Container.PickupContainerItem) or PickupContainerItem
                local holding = CursorHasItem and CursorHasItem()
                if not holding and e.name == "empty" then say1("that slot is empty") rec.acted = "empty slot" return end
                if e.gslot then PickupGuildBankItem(e.gtab, e.gslot) else pick(e.bag, e.slot) end   -- v104
                local now = CursorHasItem and CursorHasItem()
                if holding then
                    ZenVCExportDB._holding = now and true or nil
                    say1(now and "swapped: you now hold the other item. Move to where it goes and say move that" or "put down")
                    rec.acted = (now and "swapped at " or "put down at ") .. where
                elseif now then
                    ZenVCExportDB._holding = true
                    say1("holding " .. tostring(e.name) .. ". Move to where it goes (move my box goes between the bank or guild bank and your bags), then say move that. Stop move puts it back")
                    rec.acted = "picked up " .. tostring(e.name) .. " from " .. where
                else
                    say1("could not pick it up") rec.acted = "pick up failed"
                end
                local kind = mark.kind
                if C_Timer and C_Timer.After then C_Timer.After(0.3, function() pcall(function()
                    if mark.kind == kind then lightUp((kind == "bank" and TM.bankSlots()) or (kind == "gbank" and TM.gbankSlots()) or bagSlots()) end
                end) end) end
            end)
        end,
        -- v97 (2026-11-09, user: "I could not get GET THAT to take it"): v96 pointed the key at the attachment button (the game's own click) and nothing was
        -- taken. Now the add-on takes the outlined item or money itself (TakeInboxItem / TakeInboxMoney). Cash on delivery is NOT taken by voice.
        ["/click zenvcgetthat"] = function()
            local rec = { at = date("%Y-%m-%d %H:%M:%S"), acted = "nothing" }
            pcall(function()
                local e = mark.kind == "mail" and TM.mailOpen() and TM.mailSlots()[mark.i]
                if not (e and e.mailTake) then
                    say1("open a mail first: say start move at the mailbox, move to a mail and say select, move to an item or the money, then say get that")
                    rec.acted = "nothing outlined" return
                end
                local cod = tonumber((select(6, GetInboxHeaderInfo(e.inIdx)))) or 0
                if cod > 0 then
                    say1("this mail is cash on delivery (" .. tostring(cod) .. " copper" .. "): not taken by voice")
                    rec.acted = "cash on delivery: not taken" return
                end
                if e.inAtt then
                    TakeInboxItem(e.inIdx, e.inAtt)
                    say1("taking " .. (tostring(e.name):gsub("^attached: ", "")))
                    rec.acted = "TakeInboxItem " .. e.inIdx .. " " .. e.inAtt .. " " .. tostring(e.name)
                elseif e.inMoney then
                    TakeInboxMoney(e.inIdx)
                    say1("taking the money")
                    rec.acted = "TakeInboxMoney " .. e.inIdx
                end
            end)
        end,
        ["/click zenvctakeoff"] = function() say1("talk to a flight master, say start move, choose a flight point, then say take off") end,   -- v90
        ["/click zenvcsearchnow"] = function() say1("open the auction house first, then say search now") end,   -- v85
        ["/click zenvctipsmall"] = function() tipSizeStep(0.5, "small") end, ["/click zenvctipnormal"] = function() tipSizeStep(1, "normal") end,
        ["/click zenvctiplarge"] = function() tipSizeStep(2, "large") end, ["/click zenvcstartmove"] = startMoveStep,
        ["/click zenvcusethat"] = function() armOrFire("use", useThatStep, b) end, ["/click zenvcdestroythat"] = function() armOrFire("destroy", destroyThatStep) end,
        ["/click zenvcmoveup"] = function() moveStep("up") end, ["/click zenvcmovedown"] = function() moveStep("down") end,
        ["/click zenvcmoveleft"] = function() moveStep("left") end, ["/click zenvcmoveright"] = function() moveStep("right") end,
    }
    local run = plain[b.text:lower()]
    if run then
        step("create button " .. b.id)
        f = CreateFrame("Button", name, UIParent)
        f.zvBack = true
        f:RegisterForClicks("AnyUp")
        f:SetScript("OnClick", function() noteClick(b.id); run() end)
        return f
    end
    -- the back button for the NPC windows (see backStep)
    if b.text:lower() == "/click zenvcback" then
        step("create back button " .. b.id)
        f = CreateFrame("Button", name, UIParent)
        f.zvBack = true
        f:RegisterForClicks("AnyUp")
        f:SetScript("OnClick", function() noteClick(b.id); backStep() end)
        return f
    end
    -- an emote on its own (no target, no words): the game's own emote function runs it. A plain button, nothing secure.
    local word = b.text:match("^/(%S+)$")
    local token = word and emoteToken("/" .. word)
    if token and DoEmote then
        step("create emote button " .. b.id)
        f = CreateFrame("Button", name, UIParent)
        f.zvEmote = token
        f:RegisterForClicks("AnyUp")
        f:SetScript("OnClick", function() noteClick(b.id); DoEmote(token) end)
        return f
    end
    -- everything else (/cast, /use, /reload ...) runs as a secure macro, which also works in combat
    if InCombatLockdown() then return nil end
    step("create button " .. b.id)
    f = CreateFrame("Button", name, UIParent, "SecureActionButtonTemplate")
    f:RegisterForClicks("AnyUp", "AnyDown")
    setButtonAction(f, b)
    -- both halves of a press arrive now; note the press once, on the half the game acts on
    if f.HookScript then pcall(function() f:HookScript("PostClick", function(self, _, down)
        local onDown = GetCVar and GetCVar("ActionButtonUseKeyDown") ~= "0"
        if down == nil or down == onDown then noteClick(b.id, self) end
    end) end) end
    return f
end

-- every button that is wanted (the voice commander's list) or was made earlier
local function makeAllButtons()
    if InCombatLockdown() or buttonsOff() then return end
    local n = 0
    for _, b in ipairs(effectiveButtons()) do if b.id and b.text and not bindAction(b) and ensureButton(b) then n = n + 1 end end
    step("buttons made")
    return n
end

-- the keys that are FREE right now (nothing of yours is bound to them), with the key they are offered
local function freeKeys()
    local list = {}
    for _, b in ipairs(effectiveButtons()) do
        if b.id and b.text and b.key and b.key ~= "" then
            local cur = GetBindingAction(b.key)   -- your saved bindings only
            if cur == nil or cur == "" then list[#list + 1] = b end
        end
    end
    return list
end

-- put the keys on the buttons. Override bindings: nothing in your saved bindings changes.
local function applyKeys()
    if buttonsOff() or not keysWanted() or InCombatLockdown() then return 0 end
    lastApplied = GetTime and GetTime() or 0
    step("clear my override keys")
    ClearOverrideBindings(buttonOwner)
    local n = 0
    for _, b in ipairs(freeKeys()) do
        local action = bindAction(b)
        if action then
            step("bind key " .. b.key .. " to " .. action)
            SetOverrideBinding(buttonOwner, true, b.key, action)
            n = n + 1
        elseif ensureButton(b) then
            step("bind key " .. b.key)
            SetOverrideBindingClick(buttonOwner, true, b.key, BTN_PREFIX .. b.id, "LeftButton")
            n = n + 1
        end
    end
    step("keys applied")
    return n
end

local function showButtons()
    if buttonsOff() then say("the hidden-key feature is switched off (the game blocked a step). Nothing to do.") return end
    local list = freeKeys()
    if #list == 0 then say("none are waiting. Nothing to do.") return end
    say("PLAN (nothing changed yet). These would run from a key, with no chat box (your saved key bindings are not touched):")
    for _, b in ipairs(list) do say("  " .. prettyKey(b.key) .. "  =  " .. b.text) end
    say("To do it, type:  /zenvc emotes yes        To undo later:  /zenvc undo")
end

local function doButtons()
    if buttonsOff() then say("the hidden-key feature is switched off (the game blocked a step), so I did nothing.") return end
    if InCombatLockdown() then say("not in combat, please.") return end
    say("making the hidden buttons...")
    local made = makeAllButtons() or 0
    ZenVCExportDB._emotesOn = true
    say("made " .. made .. " button(s). Giving them their keys...")
    local n = applyKeys()
    if buttonsOff() then return end
    say("gave " .. n .. " command(s) their own key, with no chat box. Now type /reload, and /reload again, so the voice commander can read them. /zenvc undo takes them away.")
end

local function undoButtons()
    local was = ZenVCExportDB._emotesOn
    ZenVCExportDB._emotesOn = nil
    if not InCombatLockdown() then ClearOverrideBindings(buttonOwner) end
    return was and 1 or 0
end

-- (No question box here any more: the game blocked an add-on box in controller mode. The voice commander asks you, and
-- switches the keys on by writing ZENVC_EMOTES_ON = true into ZenVCCommands.lua. /zenvc emotes yes still works by hand.)

-- after a login / reload the keys are applied again (override bindings do not survive them), only if you said yes before
local frame_announced = false
local function reapplyIfWanted()
    if buttonsOff() or InCombatLockdown() then return end
    if keysWanted() then
        makeAllButtons()
        local n = applyKeys()
        if n > 0 and not frame_announced then frame_announced = true; print("VCF Helper: " .. n .. " voice command(s) now run from their own key, with no chat box.") end
    elseif ZENVC_EMOTES_ON == false and not ZenVCExportDB._emotesOn then
        ClearOverrideBindings(buttonOwner)   -- the voice commander switched this off
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("SPELLS_CHANGED")
frame:RegisterEvent("UPDATE_BINDINGS")
frame:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("UNIT_PET")
local function zvMainEvent(_, ev)
    if ev == "PLAYER_LOGIN" and ZenVCExportDB._blocked then
        while #ZenVCExportDB._blocked > 20 do table.remove(ZenVCExportDB._blocked, 1) end   -- an old long record is trimmed once
    end
    if ev == "PLAYER_LOGIN" then   -- v89: notes that answered their questions are no longer kept
        ZenVCExportDB._turns, ZenVCExportDB._auction, ZenVCExportDB._timing, ZenVCExportDB._compare, ZenVCExportDB._startMove = nil, nil, nil, nil, nil
        ZenVCExportDB._loot = nil
        -- v110 (2026-11-09, user: "take out unneeded listeners and loggers"): the notes of things now proven in the game
        for _, k in ipairs({ "_mailNames", "_bankFound", "_bankSurvey", "_ahMove", "_focusCleared", "_taxi", "_taxiKnown", "_mail", "_look", "_moveThat", "_getThat", "_softInteract" }) do ZenVCExportDB[k] = nil end
    end
    if ev == "PLAYER_LOGIN" and ZenVCExportDB._judgeVersion ~= 38 then
        -- the way hidden presses are judged changed in v38 (by spell name, pet spells included): older tallies are not comparable, so they start again
        ZenVCExportDB._hiddenResult = nil
        ZenVCExportDB._judgeVersion = 38
    end
    if ev == "PLAYER_LOGIN" then ZenVCExportDB._buttonsOff = nil end   -- v74: nothing switches the voice keys off any more; an old switch is cleared at every login
    if ev == "PLAYER_LOGIN" and ZenVCExportDB._offVersion ~= VERSION then
        -- a new version of this add-on gets a fresh chance: an off-switch set by an older version is cleared once.
        -- (what was blocked stays written down in _blocked)
        ZenVCExportDB._buttonsOff = nil
        ZenVCExportDB._boxesOff = nil
        ZenVCExportDB._offVersion = VERSION
    end
    save()
    if ev == "PLAYER_LOGIN" and not InCombatLockdown() then
        -- v49 an Alt + F4 key on an action bar button (an older key set) would close the game: take it off
        pcall(function()
            local gone = 0
            for _, k in ipairs({ "ALT-CTRL-SHIFT-F4", "ALT-CTRL-F4", "ALT-SHIFT-F4" }) do
                local a = GetBindingAction(k)
                if a and a ~= "" and (a:find("^MULTIACTIONBAR") or a:find("^ACTIONBUTTON")) then SetBinding(k); gone = gone + 1 end
            end
            if gone > 0 then SaveBindings(GetCurrentBindingSet and GetCurrentBindingSet() or 1) end
        end)
    end
    if ev == "PLAYER_LOGIN" then print("VCF Helper: addon updated, version " .. VERSION .. " (spells, action bars read two ways, controller facts and buttons, all key bindings, a box offers to give your spells keys)") end
    if ev == "PLAYER_ENTERING_WORLD" and C_Timer and C_Timer.After then
        -- the bars load a little after you enter the world, so look again a few times
        C_Timer.After(4, save); C_Timer.After(12, save); C_Timer.After(30, save)
        C_Timer.After(10, refreshRanks)
        C_Timer.After(14, function() readyToOffer = true; offerPlacement() end)
        C_Timer.After(5, reapplyIfWanted)
        C_Timer.After(20, reapplyIfWanted)
        C_Timer.After(6, bindPetBar); C_Timer.After(22, bindPetBar)
    end
    if ev == "SPELLS_CHANGED" and C_Timer and C_Timer.After and not frame.rankPending then
        frame.rankPending = true   -- a new rank was learned (or the list changed): check once, a moment later
        C_Timer.After(3, function()
            frame.rankPending = nil
            refreshRanks()
            if readyToOffer then offeredThisSession = false; C_Timer.After(2, offerPlacement) end   -- a new spell may need a key
        end)
    end
    if ev == "UNIT_PET" and C_Timer and C_Timer.After and not frame.petPending then
        frame.petPending = true   -- a pet came out (or changed): its abilities only show in the book now, so save once, a moment later
        C_Timer.After(3, function() frame.petPending = nil; bindPetBar(); save() end)
    end
    if ev == "PLAYER_REGEN_ENABLED" and refreshPending then refreshRanks() end
    if ev == "PLAYER_REGEN_ENABLED" then reapplyIfWanted(); bindPetBar() end
    if ev == "UPDATE_BINDINGS" and keysWanted() and not buttonsOff() and C_Timer and C_Timer.After and not frame.rebindPending then
        frame.rebindPending = true   -- the game reloaded your bindings: put my override keys back, once, a moment later
        C_Timer.After(2, function() frame.rebindPending = nil; reapplyIfWanted() end)
    end
    if ev == "ACTIONBAR_SLOT_CHANGED" and C_Timer and C_Timer.After and not frame.pending then
        frame.pending = true   -- you moved something on a bar: save once, a moment later, and let a hidden key that presses a bar slot (v24, Fishing) follow its ability
        C_Timer.After(3, function() frame.pending = nil; save(); reapplyIfWanted() end)
    end
end

-- v89 (2026-11-09): the v86 login timer is gone (it answered its question: about 40 ms); the handler is set directly
frame:SetScript("OnEvent", zvMainEvent)

-- v43 "/zvbind ACTION" only ever arrives typed when its key is not set up yet (before the two reloads): say so instead of "unknown command"
SLASH_ZENVCBIND1 = "/zvbind"
SlashCmdList["ZENVCBIND"] = function(msg)
    print("|cff2ee6d6VCF:|r that voice command gets its key after /reload (twice). Then it works.")
end

SLASH_ZENVCEXPORT1 = "/zenvc"
SlashCmdList["ZENVCEXPORT"] = function(msg)
    msg = (msg or ""):lower()
    if msg:find("^bars%s+yes") then doPlace() return end
    if msg:find("^bars") then showPlan() return end
    if msg:find("^click%s+") then
        local id = msg:match("^click%s+(%S+)")
        local f = _G[BTN_PREFIX .. tostring(id)]
        if not f then say("no hidden button called '" .. tostring(id) .. "'. Try /zenvc keys to see them.") return end
        local ok, err = pcall(function() f:Click("LeftButton") end)
        say("clicked " .. BTN_PREFIX .. id .. (f.zvEmote and (" (emote " .. f.zvEmote .. ")") or " (secure macro)") .. (ok and ": done." or (": failed: " .. tostring(err))))
        return
    end
    if msg:find("^keys") then
        local n = 0
        for _, b in ipairs(effectiveButtons()) do
            n = n + 1
            if n <= 12 then
                local f = _G[BTN_PREFIX .. b.id]
                say(string.format("%-22s key %-18s on key: %s | button: %s", b.text, tostring(b.key), tostring(GetBindingAction(b.key, true)), f and (f.zvEmote and "emote" or f.zvReload and "reload" or "secure") or "missing"))
            end
        end
        say("(showing the first 12 of " .. #effectiveButtons() .. "). keys wanted: " .. tostring(keysWanted()) .. ", switched off by the game: " .. tostring(buttonsOff()))
        return
    end
    if msg:find("^emotes%s+yes") then doButtons() return end
    if msg:find("^emotes") then showButtons() return end
    if msg:find("^undo") then local nb = undoButtons(); if nb > 0 then say("removed the hidden command keys I had added.") end doUndo() return end
    if msg:find("^fixkeys") then doFixKeys() return end
    if msg:find("^interact") then doInteract() return end
    if msg:find("^ranks") then showRanks() return end
    if msg:find("^rank%s+") then setRank(msg:match("^rank%s+(.+)$")) return end
    save()
    local d = ZenVCExportDB[(UnitName("player") or "") .. "-" .. (GetRealmName and GetRealmName() or "")]
    if d then
        print("VCF Helper: saved " .. #d.spells .. " spells and " .. #d.bindings .. " key bindings for " .. d.name .. " (" .. tostring(d.class) .. "). Type /reload to write the file now.")
    else
        print("VCF Helper: nothing saved yet.")
    end
end

-- v29 FISHING: while the line is cast, widen the game's soft-target interact range so the bobber keeps the interact prompt (the X) more easily; put the player's own value back afterward.
-- The original value is written to the save first (_softOrig) so a crash or log-out in the middle can never leave the wider range behind: it is restored at the next login.
-- v57 (2026-11-06): the game here casts Fishing as spell 7620, so the old check (7731 only) never widened the range and the bobber was lost at range 10.
-- Every Fishing rank counts now: 7620, 7731, 7732, 18248.
local FISH_SPELLS = { [7620] = true, [7731] = true, [7732] = true, [18248] = true }
local FISH_RANGE = "30"
local FISH_HOLD = 6   -- seconds after the line stops: time to reel in and loot before the range goes back

local function softRestore()
    local o = ZenVCExportDB._softOrig
    if type(o) ~= "table" or o.range == nil then return end
    local ok = pcall(function() SetCVar("SoftTargetInteractRange", o.range) end)
    if ok then ZenVCExportDB._softOrig = nil; ZenVCExportDB._softNote = date("%H:%M:%S") .. " range put back to " .. tostring(o.range) end
end

local function softWiden()
    local ok = pcall(function()
        local cur = GetCVar("SoftTargetInteractRange")
        if ZenVCExportDB._softOrig == nil then ZenVCExportDB._softOrig = { range = cur } end
        SetCVar("SoftTargetInteractRange", FISH_RANGE)
        ZenVCExportDB._softNote = date("%H:%M:%S") .. " range widened from " .. tostring(cur) .. " to " .. FISH_RANGE
    end)
    if not ok then ZenVCExportDB._softNote = date("%H:%M:%S") .. " could not change the interact range" end
end

-- v89 (2026-11-09, user: "loot notes... any use for this? I think we have that under control"): the v58 loot notes are removed.

do   -- v100: a block of its own, so the add-on stays under the game's 200 top-level names
local softFrame = CreateFrame("Frame")
local softToken = 0
for _, e in ipairs({ "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_CHANNEL_STOP", "PLAYER_LOGIN", "PLAYER_REGEN_ENABLED" }) do
    pcall(function() if e:find("UNIT_") and softFrame.RegisterUnitEvent then softFrame:RegisterUnitEvent(e, "player") else softFrame:RegisterEvent(e) end end)
end
softFrame:SetScript("OnEvent", function(_, ev, unit, a, spellID)
    if ev == "PLAYER_LOGIN" or ev == "PLAYER_REGEN_ENABLED" then
        if softToken == 0 or ev == "PLAYER_LOGIN" then softRestore() end
        return
    end
    if not FISH_SPELLS[spellID] then return end
    softToken = softToken + 1
    if ev == "UNIT_SPELLCAST_CHANNEL_START" then
        softWiden()
    else
        local mine = softToken
        C_Timer.After(FISH_HOLD, function() if mine == softToken then softToken = 0; softRestore() end end)
    end
end)
end

-- v112 (2026-11-10, user: "take the switch off the npc - didnt realize that used a key"): the v109 SoftTargetInteract switch is gone and its hidden
-- key is freed (saying friend first is what works). Only a switch left at 3 by an older version is put back to 1, once, at the next login.
do
    local sf = CreateFrame("Frame")
    pcall(function() sf:RegisterEvent("PLAYER_ENTERING_WORLD") end)
    sf:SetScript("OnEvent", function()
        pcall(function()
            if ZenVCExportDB._softPending and GetCVar("SoftTargetInteract") == "3" then SetCVar("SoftTargetInteract", "1") end
            ZenVCExportDB._softPending = nil
        end)
    end)
end

-- v114 (2026-11-10, user: "worth building now, accessibility users could have immediate need"): KEY TEST. Only when the voice commander wrote a test list
-- (ZENVC_KEYTEST, with no voice keys at all). Each test key is bound to a counter and does nothing else; the voice commander presses them all once
-- ("start key test"), then the chat says how many arrived. Saved at the next reload; the voice commander then never uses a key that did not arrive.
do
    local owner = CreateFrame("Frame", "ZenVCKeyTestOwner")
    -- v115 (2026-11-10): what arrived is kept in the saved data under the test's own name (ZENVC_KEYTEST_ID), so a stopped test carries on after a reload.
    -- The test is over when the FIRST key arrives a second time (the voice commander presses it again after all the others), or after 10 quiet minutes. Before, any 4 quiet seconds ended it,
    -- and a run of keys that did not arrive made the chat say to reload in the middle of the test.
    local hits, token, done = {}, 0, false
    local function finish()
        if done then return end
        done = true
        local got, missing = 0, {}
        for _, b in ipairs(ZENVC_KEYTEST or {}) do if (hits[b] or 0) >= 1 then got = got + 1 else missing[#missing + 1] = b end end
        -- v116 (2026-11-10, user: "determine if the GAMEPAD checkbox is ticked on or off"): the test remembers the game's Enable Gamepad box (GamePadEnable)
        local pad = "?"
        pcall(function() pad = tostring((C_CVar and C_CVar.GetCVar and C_CVar.GetCVar("GamePadEnable")) or (GetCVar and GetCVar("GamePadEnable")) or "?") end)
        ZenVCExportDB._keyTest = { at = date("%Y-%m-%d %H:%M:%S"), arrived = got, total = #ZENVC_KEYTEST, missing = missing, pad = pad }
        ZenVCExportDB._keyTestHits = nil
        ClearOverrideBindings(owner)
        -- v117 (2026-11-10, user: "take it out next update"): no gamepad box in the message (GamePadEnable is not the tickbox)
        if #missing == 0 then say1("KEY TEST DONE: every key works. Nothing to do. Now /reload the game twice.")
        else say1("KEY TEST DONE: " .. got .. " of " .. #ZENVC_KEYTEST .. " keys work. VCF skips the other " .. #missing .. ". Nothing to do. Now /reload the game twice.") end
    end
    local function listen()
        if not ZENVC_KEYTEST or #ZENVC_KEYTEST == 0 then return end
        if InCombatLockdown() then say1("KEY TEST: not in combat. /reload when out of combat.") return end
        local id = ZENVC_KEYTEST_ID or ""
        local kept = ZenVCExportDB._keyTestHits
        if type(kept) == "table" and kept.id == id and type(kept.hits) == "table" then hits = kept.hits else hits = {} end
        ZenVCExportDB._keyTestHits = { id = id, hits = hits }
        local first = ZENVC_KEYTEST[1]
        ClearOverrideBindings(owner)
        for i, b in ipairs(ZENVC_KEYTEST) do
            local btn = _G["ZenVCKeyTestBtn" .. i] or CreateFrame("Button", "ZenVCKeyTestBtn" .. i, UIParent)
            btn:SetScript("OnClick", function()
                hits[b] = (hits[b] or 0) + 1
                token = token + 1
                local mine = token
                if b == first and hits[b] >= 2 then C_Timer.After(1, finish) return end
                C_Timer.After(600, function() if mine == token then finish() end end)
            end)
            SetOverrideBindingClick(owner, true, b, btn:GetName())
        end
        say1("KEY TEST: listening for " .. #ZENVC_KEYTEST .. " keys. Stand still, out of combat, no chat box open, then click KEY TEST on the MIC IS box and click the game.")
    end
    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_LOGIN")
    f:SetScript("OnEvent", function() if C_Timer and C_Timer.After then C_Timer.After(6, listen) end end)
end
