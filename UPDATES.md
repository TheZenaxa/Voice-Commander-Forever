# UPDATES, newest first

What changed in each release of VCF and VCFI (and the voice language test), newest at the top, with the date and time it was published.
Download the newest setup from the front page.

---

## VCF 0.10.167 (VCFI 0.1.55 unchanged)

Published 2026-11-11 01:08 US Mountain Standard Time

### Hearing you better

- **Blunt background noise (new, on):** while nobody is talking, VCF learns what your background sounds like (a fan, music, a hum) and takes some of it out of each phrase before Windows listens. In a test with heavy noise, Windows heard 72 of 120 words right with it, against 38 without. It only works when the background is noisy; in a quiet room your voice is left exactly as it is. Tick box under the volume in the Control Panel.
- **Vowel check (new, off until you switch it on):** checks that the vowels you said match the command Windows heard, and ignores the command when they clearly do not. It learns how YOU say your vowel sounds and each phrase, from TEST MY WORDS and from play.

### Voice check, improved

- The voice check now looks at the **pitch** of your voice only (how high or low it is), learned from how you really talk in play. Your own words are no longer ignored because of the word you said.
- **My lowest note:** pick your lowest note (C2 to C4) under the voice check. Nothing at or above it is ever ignored as too low; a throat clear or a rumble below it is.

### Know when a check is ready

- The voice check and the vowel check both learn while they are OFF. Under their tick boxes each shows its own record ("in your last 50 commands it would have stopped 1"). When a check has proved itself, the MIC IS box says **READY PITCH** or **READY FORMANTS**: then tick it on.
- Nothing is recorded: only numbers about your voice are kept, on your PC.

### Credits

- The voice check is based on VIRTY-VOX by TheZenaxa. Noise blunting and the vowel check are written for VCF from published methods (see Credits in the FAQ).

After installing, reload the game twice.

---

## VCF 0.10.160 and VCFI 0.1.55

Published 2026-11-10 19:19 US Mountain Standard Time

### Move by more than one space

- **move up / down / left / right** with a number from two to twenty moves the outline that many spaces at once: "move down five", "move right twenty". They use the keys you already have, so no new keys are needed. Under Interaction in the Control Panel, and in the glossary.

### Voice check (new)

- VCF and VCFI can learn your voice, and then ignore voices that are not yours: a stream, a TV, or someone else in the room.
- It learns your voice in **TEST MY WORDS**: the words it hears correctly teach it your voice, and 10 are enough. Each person teaches it their own voice. Nothing is recorded: only a few numbers about your voice are kept, on your PC.
- Switch it on or off with the tick box under TEST MY WORDS in the Control Panel. Turn it off if it ever ignores your own words (for example when another voice in the room sounds very like yours).
- The voice check is based on VIRTY-VOX by TheZenaxa (see Credits in the FAQ).

### Key test

- The result now just says how many keys work and that there is nothing to do, for example "KEY TEST DONE: 204 of 214 keys work. VCF skips the other 10. Nothing to do."

### Only in VCFI

- The move words have numbers in each spoken language (for example "vers le bas cinq", "nach rechts zwanzig", "向左十七"), and the new screen text is in French, German, Spanish and Chinese (Simplified and Traditional). These have not been checked by native speakers yet.

The game's add-on that comes with VCF and VCFI is now version 117 in both.

After installing, reload the game twice.

---

## VCF 0.10.156 and VCFI 0.1.54

Published 2026-11-10 18:04 US Mountain Standard Time

### More keys

- 34 more key combinations for the hidden keys (Alt+Shift and Ctrl+Shift with Home, End, Page Up, Page Down, Insert, Delete, Backspace, minus, equals, the arrow keys, and Ctrl+Shift with punctuation). No key you already have moves.
- A key you set in the game's own Key Bindings always wins: if it was one of the program's hidden keys, the program gives its command another key and says so.

### No more "keys you cannot touch"

- No game key is off limits. The program reads your keys at every double reload and follows them. If an action it needs (Jump, Autorun, Attack Target, Target Nearest Enemy, Interact) has no key at all, it gives it a hidden key of its own.
- Drink and Eat use the last two slots of your main action bar (the - and = keys on a new character, where the game puts your water and food). Whatever you put in that slot is what the words use.
- The setup guide's first page: switch on all of the game's action bars (you can keep them hidden), set each to the most slots it allows, and a tip for controller players.

### KEY TEST (on the MIC IS box)

- Finds key combinations that never reach the game on your computer, and the program stops using them. Click KEY TEST, reload twice, click KEY TEST again, then click the game: it starts 10 seconds later. The button shows where the test stands. If it stops, click it again and it carries on where it stopped. Only a finished test counts.

### KEY CLEANUP, OOPS! and FREE KEY ON CLEANUP

- KEY CLEANUP (MIC IS box) frees keys still held for commands that were removed, and keys of commands that are switched off AND ticked FREE KEY ON CLEANUP in the Control Panel. Switched off alone keeps its key. It shows the list and changes nothing until you say yes. OOPS! (next to import and export) puts the last cleanup back.
- A command you delete gives its key back by itself at the next double reload.

### Removed

- The quiet NPC switch is taken out: it did not help and it used a key. Say **friend** first, then **talk** or **shop**.

Guild bank: still pending testing.

The game's add-on that comes with VCF and VCFI is now version 116 in both.

After installing, reload the game twice.

---

## VCF 0.10.149 and VCFI 0.1.47

Published 2026-11-10 00:07 US Mountain Standard Time

### New in both: follow, walk and snap cam

- **start walk:** follows the friendly player you have targeted (say **friend** first to target the nearest one). **stop walk** stops following with one tiny step.
- **walk one** (or just **walk**), **walk two** and **walk three:** walk forward a few steps, twice as far, and twice that again.
- **snap cam:** puts the camera straight back behind your character, for example after a turn. Your zoom stays as it is.
- All of these are under Movement in the Control Panel, and in the glossary.

### FAQ

- New: an NPC that does not answer talk or shop (say **friend** first), following another player and walking, and snap cam.
- Fishing: once you have interacted with something else, you need to say **fish** and press X on the controller again before fishing, catching or looting works as normal (added in the user's own words).

### Only in VCFI

- The new commands have words in each spoken language (for example "commencer marche", "Gehen stoppen", "caminar tres", "镜头复位"), and the new screen text is in French, German, Spanish and Chinese (Simplified and Traditional). These have not been checked by native speakers yet.

The game's add-on that comes with VCF and VCFI is now version 111 in both.

After installing, reload the game twice.

---

## VCF 0.10.144 and VCFI 0.1.46

Published 2026-11-09 22:42 US Mountain Standard Time

### An NPC does not answer talk or shop?

Assuming your MIC is ON and hearing your voice: face the NPC and say the words for **Target Nearest Friendly** first ("friend" in English), then say **talk** or **shop** again. Touching the controller stick works too. This tip is in the READ ME FIRST of both programs. VCFI's READ ME FIRST lists the words in each language.

### Tidier add-on

- The notes the game's add-on kept while things were being tested (mail, bank, Auction House, flight map, camera, move that, get that, and the controller button record) are gone, now that these work. The add-on also clears them from its saved file the next time you log in. The notes for the guild bank, trade and quest rewards stay until those are tested.

### New in VCFI 0.1.46

- Before **shop**, **talk** and **en pee see**, VCFI briefly lets the game pick NPCs for keyboard keys too, then sets it back after 3 seconds (as VCF 0.10.143).

The game's add-on that comes with VCF and VCFI is now version 110 in both.

After installing, reload the game twice.

---

## VCF 0.10.143 (VCFI 0.1.45 unchanged)

Published 2026-11-09 22:37 US Mountain Standard Time

### An NPC does not answer talk or shop?

Assuming your MIC is ON and hearing your voice: face the NPC and say **friend** first (Target Nearest Friendly), then say **talk** or **shop** again. Touching the controller stick works too.

The game picks the NPC in front of you only after a real touch of the controller. Targeting the NPC by voice gets around that. This tip is now in the READ ME FIRST.

### Also

- Before **shop**, **talk** and **en pee see**, VCF briefly lets the game pick NPCs for keyboard keys too (the game's SoftTargetInteract setting goes from 1 to 3), then sets it back to 1 after 3 seconds, and again when you log out. Loot, mining, skinning, herbalism and fishing are not touched.

After installing, reload the game twice.

The game's add-on that comes with VCF is now version 109.

---

## VCF 0.10.142 and VCFI 0.1.45

Published 2026-11-09 21:54 US Mountain Standard Time

### New in both

- **Camera up / lower camera (1 to 3):** tilts the camera a little up or down. "camera up one" is the smallest nudge, "two" twice that, "three" twice that again. "lower camera one" to "three" go the other way.
- **Choosing a quest reward:** when a quest offers a choice, say **start move**, move to the reward, **select** it, then **complete**. With nothing to choose, select and complete work as before.
- **The glossary** now lists the window commands (start move, select, enter, buy, take off, finish trade, send mail, get that, move that, tick yes and tick no, camera up and more), each with where to find it in the Control Panel.

### New in VCFI 0.1.45

VCFI now has everything that came to VCF from 0.10.127 to 0.10.142:
- Trade, mail (inbox, "get that", sending), the bank, "move that", and the guild bank (PENDING TESTING).
- Answering the game's question boxes ("tick yes" / "tick no" in English). Every VCFI question box shows the words that answer it.
- "move start" as well as "start move" (English).
- For testing, the game's add-on keeps a short note of your controller button presses next to its voice key presses. It stays on your computer and nothing is uploaded. It will be taken out when testing is done.

Only in VCFI:
- The new commands have words in each spoken language (for example "finir échange", "Post senden", "cámara arriba uno", "回答是"), and the new screen text is shown in French, German, Spanish and Chinese (Simplified and Traditional). These have not been checked by native speakers yet.

The game's add-on that comes with VCF and VCFI is now version 108 in both.

After installing, reload the game twice.

---

## VCF 0.10.138 (VCFI 0.1.43 unchanged)

Published 2026-11-09 21:11 US Mountain Standard Time

### New: the bank by voice

- At the bank, say **start move** (or **move start**). The outline goes over the bank's slots, its tabs and its buttons, such as Purchase and the bag slots. The tooltip box shows each one.
- **select** on a tab opens it, and on a button presses it. When you buy a bank slot, the game asks its own question first.
- **move my box** goes between the bank and your bags.

### New: "move that"

- Say **move that** on an item to pick it up. Move to where it should go and say **move that** again to put it down. On another item, the two swap places.
- It works in your bags for sorting, and between the bank and your bags.
- **stop move** while you are holding an item puts it back where it was.

### New: the guild bank (PENDING TESTING)

- It works like the bank: **start move**, the tabs and buttons, and **move that** between the guild bank and your bags.
- It has not been tested in the game yet.

### Answering the game's questions

- **tick yes** and **tick no** answer the question box the game shows: an invite, buying a bank slot, or anything else it asks. They replace "accept invite" and "decline invite".
- **tick yes** asks yes or no in VCF first. **tick no** answers straight away.
- Every VCF question box now says the words that answer it: **yes do that** or **no do not**.

### Also

- Mail: the item count and the money in the mail summary now read correctly.
- For testing, the game's add-on keeps a short note of your controller button presses next to its voice key presses. It stays on your computer and nothing is uploaded. It will be taken out when testing is done.

After installing, reload the game twice.

The game's add-on that comes with VCF is now version 105.

---

## VCF 0.10.131 (VCFI 0.1.43 unchanged)

Published 2026-11-09 19:56 US Mountain Standard Time

### New: mail by voice

- At a mailbox, say **start move** (or **move start**) to begin. Nothing appears until you do.
- **Your inbox:** move up and down through your mail. The tooltip box shows who it is from, the subject, money, items and the days left. Say **select** to open a mail; the box shows the letter.
- **get that** takes the outlined item or money into your bags. Mail that is cash on delivery is not taken by voice.
- **Sending:** select the Send Mail tab. On the To box, **select** gives a list: Type a name (the on-screen letter pad) first, then your characters. Move through it and say **enter** to choose. The Subject and letter use the letter pad, the money boxes the number pad. **move my box** goes to your bags, where **use that** attaches an item.
- **send mail**, said once, shows the whole mail in the box; said again within 30 seconds it sends it.

### New: trade by voice

- After a trade opens, say **start move**. The box shows who the trade is with and both sides of it.
- **use that** in your bags puts an item in the trade. **select** on your gold, silver or copper opens the number pad.
- **finish trade**, said once, shows what you give and what you get; said again within 30 seconds it accepts. If either side changes the trade in between, nothing is accepted and the new terms are shown.
- Trade has not been tested with another player yet.

### Also

- **move start** now works as well as **start move**, everywhere.
- While the outline is in the mailbox or a trade, the game's typing cursor is kept out of their boxes, so your voice commands are not typed into them.

After installing, reload the game twice.

The game's add-on that comes with VCF is now version 99.

---

## VCF 0.10.126 and VCFI 0.1.43

Published 2026-11-09 17:19 US Mountain Standard Time

### New in VCFI 0.1.43

VCFI now has what came to VCF in 0.10.126:

- **An on-screen keypad** for the Auction House search box and quantity boxes: say select on the box, move over the keys, and say enter (in your language) to press one. Numbers for quantities; letters in keyboard order, with a key that switches to A B C order. Done closes it. Nothing is typed on your keyboard, so no letter can open a game window by accident.
- **Buying with "buy that":** at a vendor, say it once to see what would be bought (the outline changes colour), and again to buy. In the Auction House it presses the game's own Buy Now or Buyout button. The buying screen's buttons can now be outlined.

Only in VCFI:
- The new "enter" has its own words in each spoken language (for example "valider" in French), and its name is shown in French, German, Spanish and Chinese (Simplified and Traditional). These have not been checked by native speakers yet. The keypad's own keys are letters and numbers, the same in every language.

VCF is the same as 0.10.126. The game's add-on that comes with VCF and VCFI is now version 94 in both.

After installing, use Update and reload the game twice: "enter" gets its key on the second reload.

---

## VCF 0.10.126 (VCFI 0.1.42 unchanged)

Published 2026-11-09 17:17 US Mountain Standard Time

### New: an on-screen keypad for the Auction House

- With the outline on the search box, or on a quantity box when buying, say **select** and a keypad appears.
- **Numbers** (for quantities): 1 2 3 / 4 5 6 / 7 8 9 / Backspace 0 Done.
- **Letters** (for the search box): in keyboard order (Q W E R T Y...) with Space, Backspace and Done. The last key switches to A B C order and back; your choice is remembered.
- **move up / down / left / right** go over the keys; say **enter** to press the outlined key. The tooltip box shows the key and what you have typed so far.
- **Done** closes the keypad and puts the outline back on the box. Then say **search now** to search.
- Each key goes straight into that one box. Nothing is typed on your keyboard, so no letter can open a game window by accident.

### Buying with "buy that"

- **At a vendor:** the first "buy that" changes the outline's colour and says what would be bought; say **buy that** again within 30 seconds to buy it. Moving the outline or waiting cancels. This works like "use that" in your bags.
- **In the Auction House:** "buy that" presses the game's own Buy Now or Buyout button for the auction or quantity on screen; the game's own check comes after.
- **move right** from the Auction House lists now reaches the buying screen's buttons (Buy Now, Buyout, Bid, Cancel). The box shows each name, and "(not available now)" when it is greyed out.

After installing, use Update and reload the game twice: "enter" gets its key on the second reload.

The game's add-on that comes with VCF is now version 94.

---

## VCF 0.10.122 and VCFI 0.1.42

Published 2026-11-09 16:08 US Mountain Standard Time

### New: fly from a flight master by voice

- At a flight master with the flight map open, **start move** puts the outline on the places you can fly to, A to Z. **move up / down** go through them.
- The box (lower middle, like the other tooltips) shows the place's name and the cost.
- **take off** flies there. VCF asks yes or no first: say "yes do that" or press X to fly, "no do not" or B to stay. Select and accept do not fly you, so nothing takes off without a yes.
- If you do not have the coin, the game simply says so and nothing happens.

### Important fix: a key that came before game crashes

- Five game crashes each began in the exact second "move right" was pressed, which used Alt+Ctrl+Shift+PageDown. That key is never used again; "move right" gets another key. Since the change: no crash.
- Use Update and reload the game twice so the new key reaches the game.

### Also

- The add-on keeps fewer notes: the ones that had answered their questions (turn timing, Auction House survey, login timing, comparison, loot) are removed.

Only in VCFI:
- "take off" has its own words in each spoken language (for example "décoller" in French), and the new question box is shown in French, German, Spanish and Chinese (Simplified and Traditional). These have not been checked by native speakers yet.

The game's add-on that comes with VCF and VCFI is now version 90 in both.

---

## VCF 0.10.116 and VCFI 0.1.41

Published 2026-11-09 14:58 US Mountain Standard Time

### New in VCFI 0.1.41

VCFI now has what came to VCF in 0.10.116:

- **The Auction House by voice:** start move, move up / down / left / right through the categories, results and search row, select (or accept) to open a category or an item, go back to return, search now to press Search, and scrolling past the rows on screen with move down and move up. The box shows each item's tooltip with the comparison, the lowest auction price and how many are available, and on a single auction its own price.
- **Invites:** accept invite and decline invite also answer a guild invite. Accept invite asks yes or no first.
- These only work while the Auction House is open; everywhere else the commands work as before.

Only in VCFI:
- "Search now" has its own words in each spoken language (for example "chercher maintenant" in French), and the new question box and name are shown in French, German, Spanish and Chinese (Simplified and Traditional). These have not been checked by native speakers yet.

VCF is the same as 0.10.116. The game's add-on that comes with VCF and VCFI is now version 86 in both.

After installing, use Update and reload the game twice: "search now" gets its key on the second reload.

---

## VCF 0.10.116 and VCFI 0.1.40

Published 2026-11-09 14:54 US Mountain Standard Time

### New: the Auction House by voice

- **start move** with the Auction House open puts the outline on the first category. **move up / down** go through a list, **move left / right** go between the category list and the results.
- **move up** from the top of a list reaches the search row: Favourites, Search box, Filter and Search.
- **select** (or **accept**) on a category opens it; on an item it opens that item's list of single auctions. **go back** (your Back command) returns to the results.
- **search now** presses the Search button directly, wherever the outline is.
- **Scrolling:** on the last row you can see, **move down** scrolls the list; on the top row, **move up** scrolls back.
- **The box shows each item's tooltip** with the comparison to what you are wearing, the **lowest auction price** and how many are available. On a single auction it also shows **that auction's own price**, bid and quantity.
- All of this only works while the Auction House is open. Everywhere else, accept, select, back and the move commands work exactly as before.
- Typing in the search box and buying by voice come later.

### Invites

- **accept invite** and **decline invite** now also answer a **guild** invite (its own window, with Join Guild and Decline Invitation).
- **accept invite** asks yes or no first, for party and guild invites alike. Say "yes do that" or press X to accept. **decline invite** goes straight through.

### Also

- The add-on's description in the game's AddOns list now says everything it does.
- The add-on keeps a few small read-only notes (how far turns go, what the Auction House window holds, and how long its own work takes at login: about 40 milliseconds). They only read and change nothing.

After installing, use Update and reload the game twice: "search now" gets its key on the second reload.

The game's add-on that comes with VCF is now version 86. VCFI's add-on is version 76 (description only).

---

## VCF 0.10.104 and VCFI 0.1.39

Published 2026-11-09 11:27 US Mountain Standard Time

### New: turn your character by voice

- **"go left"** turns your character left one step and **"go right"** turns right one step. One step is 30 degrees, like one hour on a clock face.
- **Add a number for more steps,** up to six: "go left three" is a quarter turn, and "go left six" turns you to face the other way.
- It uses the game's own Turn Left and Turn Right, held for exactly the time the turn takes. The steps were measured in the game: six steps come out at 177 to 183 degrees.
- Together with Autorun, this lets you move around without a controller or mouse.
- In the Control Panel the commands are Turn Left 1 to 6 and Turn Right 1 to 6, in the Movement group. Like every command, their words can be changed, and each one keeps its own number of steps.
- The Glossary explains it under "Go left / go right (1 to 6)".

Also: the game's add-on keeps a small read-only note of how far each turn went, so the steps can be checked. It only reads which way you face and changes nothing.

Only in VCFI:
- The turn words are in each spoken language (for example "pivot gauche" and "pivot droite" in French), and the new names and Glossary entry are shown in French, German, Spanish and Chinese (Simplified and Traditional). These have not been checked by native speakers yet.

After installing, use Update and reload the game twice: the turn keys reach the game on the second reload.

The game's add-on that comes with VCF and VCFI is now version 75.

---

## VCF 0.10.97 and VCFI 0.1.38

Published 2026-11-09 10:35 US Mountain Standard Time

### New: zoom the camera by voice

- **"click in"** zooms the camera in one step and **"click out"** zooms it out one step, like one notch of the mouse wheel.
- **Add a number for more steps,** up to ten: "click in five" zooms in five steps, "click out ten" zooms out ten.
- It uses the game's own camera zoom, so it works wherever your mouse pointer is. At the game's closest or farthest zoom, extra steps simply do nothing.
- In the Control Panel the commands are Zoom In and Zoom Out (and Zoom In 2 to 10, Zoom Out 2 to 10), in the Movement group. Like every command, their words can be changed, and each one keeps its own number of steps.
- The Glossary explains it under "Click in / click out (1 to 10)".

Only in VCFI:
- The zoom words are in each spoken language (for example "clic avant" and "clic arrière" in French), and the new names and Glossary entry are shown in French, German, Spanish and Chinese (Simplified and Traditional). These have not been checked by native speakers yet.

After installing, use Update and reload the game twice: the zoom keys reach the game on the second reload.

The game's add-on that comes with VCF and VCFI is still version 74.

---

## VCF 0.10.92 and VCFI 0.1.37

Published 2026-11-09 10:04 US Mountain Standard Time

### More hidden keys

- **VCF and VCFI had run out of hidden keys for some characters.** New commands, such as an item given words in RENAME AN ITEM, then got no key, and saying their words did nothing (the log said "no key for it in the game yet").
- **45 new key combinations are added:** Alt+Shift with a letter, a number, or one of [ ] ; ' , . / \ `. All 45 were tested in the game first, and all arrived.
- They are handed out only after the keys already in use, so every key you already have stays the same.
- Nothing in the game or on your keyboard uses these combinations by default. If you bound one of them yourself, VCF will not take it.

After installing, use Update and reload the game twice: new keys reach the game on the second reload.

The game's add-on that comes with VCF and VCFI is still version 74.

---

## VCF 0.10.91 and VCFI 0.1.36

Published 2026-11-09 09:37 US Mountain Standard Time

### Important fix: voice commands pressing the wrong things

If your voice commands suddenly opened the wrong windows or did nothing, while plain ones like sit still worked, this is the fix. Please update.

- **What happened:** saying "use that" on a bag item made the game block the add-on. The add-on then switched all its hidden keys off, and they stayed off through restarts and logins. Commands on the game's own keys kept working; everything on a hidden key did not.
- **Fixed:** "use that" now uses the item the way the game allows, like your own macro. A blocked action no longer switches your voice keys off. If your keys were switched off, they come back on the first time you log in with this version.
- "Use that" cannot pick a new bag item during combat; the game does not allow that for any add-on. For something you need mid-fight, such as a healing potion, give it words in RENAME AN ITEM, which works in combat.

### Importing a shared profile

- An import can no longer switch off the Interaction and Movement commands (looting, talking, the window and bag commands, jump, sit, autorun). It can still switch them on and change their words.
- Everything else, such as emotes and chat, still follows the shared profile, off included.
- The import question says so.

Only in VCFI:
- The new import question is shown in French, German, Spanish and Chinese (Simplified and Traditional). These have not been checked by native speakers yet.

The game's add-on that comes with VCF and VCFI is now version 74. After installing, restart the game once.

---

## VCF 0.10.89 and VCFI 0.1.34

Published 2026-11-07 16:45 US Mountain Standard Time

### New in VCF 0.10.89 and VCFI 0.1.34

- **The Glossary has a new group, WINDOWS BY VOICE,** so you know what to say: start move and stop move, move up, down, left and right, move my box, move page right and move page left, box small, box average and box big, use that and destroy that, and yes do that and no do not.

Only in VCFI:
- The new group is shown in French, German, Spanish and Chinese (Simplified and Traditional), with the words you say in each language. These have not been checked by native speakers yet.

The game's add-on that comes with VCF and VCFI is still version 73.

---

## VCF 0.10.88 and VCFI 0.1.33

Published 2026-11-07 16:38 US Mountain Standard Time

### New in VCFI 0.1.33

VCFI now has the comparison that came to VCF in 0.10.88:

- When the outlined item at a vendor or in your bags is something you can wear or wield, what you have on in that slot shows in its own box, next to the outlined item's tooltip in the lower middle of the screen.
- Rings, trinkets and one-hand weapons show both items you have on.
- Nothing worn in that slot, or an item you cannot wear: no comparison box.
- The boxes follow the tooltip's three sizes, stay on the screen, and keep clear of the vendor window and your bags. When a row does not fit, the comparison boxes stack above.
- It works with the game in any language VCFI supports: it uses the game's own names for the slots.

After installing, reload the game once.

VCF is the same as 0.10.88. The game's add-on that comes with VCF and VCFI is now version 73 in both.

---

## VCF 0.10.88 (VCFI 0.1.32 unchanged)

Published 2026-11-07 16:35 US Mountain Standard Time

### New in VCF 0.10.88

**Comparison with what you have on**
- When the outlined item at a vendor or in your bags is something you can wear or wield, what you have on in that slot now shows in its own box, next to the outlined item's tooltip in the lower middle of the screen.
- Rings, trinkets and one-hand weapons show both items you have on.
- Nothing worn in that slot, or an item you cannot wear: no comparison box.
- The boxes follow "box small", "box average" and "box big", stay on the screen, and keep clear of the vendor window and your bags. When a row does not fit, the comparison boxes stack above.
- The game's own "if you replace this item" summary is not shown in these boxes.

After installing, reload the game once.

The game's add-on that comes with VCF is now version 73. VCFI still uses version 71. This change is not in VCFI yet.

---

## VCF 0.10.86 and VCFI 0.1.32

Published 2026-11-07 15:47 US Mountain Standard Time

### New in VCFI 0.1.32

VCFI now has everything that came to VCF in 0.10.86:

- "start move" puts an outline on the open vendor, your bags or a talk window. Move up, down, left and right move it. "stop move" takes it off, and it switches itself off when its window closes.
- "move page right" and "move page left" turn the vendor's pages.
- The outlined item's tooltip shows in the lower middle of the screen. "box small", "box average" and "box big" set its size.
- "use that" and "destroy that" on the outlined bag item ask first. Answer with X or B, or say "yes do that" or "no do not". Those two answers work for any VCFI question box.
- Switch Side is now called Move My Box.

The words above are the English ones. In French, German, Spanish, Japanese and Chinese, VCFI listens for that language's own words, which show in the control panel. The screens are translated too. Native speakers have not checked these translations yet.

New default words only apply where you have not chosen your own; your own words are kept. After installing, reload the game twice: the new commands get their hidden keys on the second reload.

VCF is the same as 0.10.86. The game's add-on that comes with VCF and VCFI is now version 71 in both.

---

## VCF 0.10.86 (VCFI 0.1.31 unchanged)

Published 2026-11-07 15:32 US Mountain Standard Time

### New in VCF 0.10.86

**Moving through bags, vendors and talk windows by voice**
- "start move" puts an outline on the open vendor, your bags or a talk window. Move up, down, left and right move it. "stop move" takes it off.
- The outline switches itself off when its window closes.
- "move page right" and "move page left" turn the vendor's pages. The outline goes back to the first item on the new page.
- Switch Side is now called Move My Box, with the default words "move my box".

**A tooltip for the outlined item**
- The outlined item's tooltip shows in the lower middle of the screen, clear of the game's own controller tooltip. (The comparison with what you have on came in 0.10.88.)
- "box small", "box average" and "box big" make it half size, normal or twice the size. The size is remembered.

**Use or destroy the outlined bag item**
- Say "use that" or "destroy that". The outline turns teal for use or red for destroy, and VCF asks first.
- Answer with X (yes) or B (no) on the controller, or say "yes do that" or "no do not".
- It cancels by itself after 30 seconds or when the outline moves. Use does nothing while a vendor is open, so nothing is sold by mistake.
- "yes do that" and "no do not" answer any VCF question box, not only this one.

**Fixed**
- The game's "blocked from an action only available to the Blizzard UI" box, which could not be closed, no longer appears when moving through windows or turning vendor pages. The spellbook is no longer part of start move.

New default words only apply where you have not chosen your own; your own words are kept. After installing, reload the game twice: the new commands get their hidden keys on the second reload.

The game's add-on that comes with VCF is now version 71. VCFI still uses version 60. These changes are not in VCFI yet.

---

## VCF 0.10.71 and VCFI 0.1.31

Published 2026-11-06 19:46 US Mountain Standard Time

### New in VCF 0.10.71 and VCFI 0.1.31

- **A new FAQ entry (known issue):** "while fishing, the X to interact is not shown on the bobber." If the X disappears, try moving the camera a bit. If the X isn't showing on the bobber although it is in plain sight, use X on your controller to reel in one cast; the X should then appear for the casts after that.

Everything from 0.10.70 / 0.1.30 is included (grey gear in RENAME AN ITEM, the Hide junk items tick box, items that are ignored, destroyed or sold give up their key, Accept takes loot).

Only in VCFI:
- The new FAQ entry is shown in French, German, Spanish and Chinese (Simplified and Traditional). These have not been checked by native speakers yet.

The game's add-on that comes with VCF and VCFI is still version 60.

---

## VCF 0.10.70 and VCFI 0.1.30

Published 2026-11-06 19:38 US Mountain Standard Time

### New in VCF 0.10.70 and VCFI 0.1.30

- **RENAME AN ITEM finds grey (junk) weapons and armour.** Grey items you can wear or wield, such as a starting axe, are on the list now, so you can give them your own words and equip them by voice. They are marked "junk".
- **"Hide junk items (grey)"**: a new tick box in RENAME AN ITEM. It is off unless you tick it.
- **An item on the rename list gives up its key when it is ignored, destroyed or sold.** Its words stay. Saying them while you no longer have the item gives an "out of" note and presses nothing. When you carry the item again, it gets a key again at the next update.

Also from 0.10.67 / 0.1.27: when a loot window stays open, saying "accept" takes everything in it.

The game's add-on that comes with VCF and VCFI is now version 60. Open VCF or VCFI first, then start the game (or /reload once if the game is already open) so it loads. After giving an item new words, /reload twice so it gets its key.

Only in VCFI:
- The new tick box is shown in French, German, Spanish and Chinese (Simplified and Traditional). These have not been checked by native speakers yet.

---

## VCF 0.10.67 and VCFI 0.1.27

Published 2026-11-06 17:54 US Mountain Standard Time

### New in VCF 0.10.67 and VCFI 0.1.27

- **Accept takes the loot.** Sometimes the game leaves the loot window open even with Auto Loot turned on in WoW's settings. When a loot window is open, saying "accept" now takes every item in it. With no loot window, Accept works on quest windows as before.

The game's add-on that comes with VCF and VCFI is now version 59. Open VCF or VCFI first, then start the game (or /reload once if the game is already open) so it loads.

---

## VCF 0.10.66 and VCFI 0.1.26

Published 2026-11-06 17:11 US Mountain Standard Time

### Fixed in VCF 0.10.66 and VCFI 0.1.26

- **Fishing: the bobber is easier to keep.** While your line is out, the helper add-on widens the game's interact range to 30, so the bobber keeps its interact prompt, then puts your own setting back. It only recognised one Fishing spell before, so on most characters it never did this. It now recognises every Fishing rank.
- **Loot, Catch and the other Interact commands** use a key without Shift (also in 0.10.64 / 0.1.24). In WoW, holding Shift while looting flips your Auto Loot setting.
- The helper add-on now quietly notes each loot window (whether the game auto-looted, which keys were held), so a loot problem can be explained. It changes nothing in the game.

After updating: open VCF or VCFI, then start the game so the new add-on (version 58) loads, and /reload twice. If Loot still opens the loot window instead of autolooting, while Auto Loot is turned on in WoW's settings, close the game and start it again once; the game can keep the old Interact key until a restart.

---

## VCF 0.10.64 and VCFI 0.1.24

Published 2026-11-06 16:38 US Mountain Standard Time

### Fixed in VCF 0.10.64 and VCFI 0.1.24

- **Loot (and Catch, Skin, Talk and the other commands that use the game's Interact) no longer use a key with Shift in it.** In WoW, holding Shift while looting flips your Auto Loot setting, so Loot sometimes opened the loot window even with Auto Loot on (for example on a fishing catch). Loot now follows your Auto Loot setting exactly.
- After updating: /reload in the game twice. If Loot still opens the loot window, close the game and start it again once; the game can keep the old Interact key until a restart.

### Fixed in VCFI 0.1.24 only

- **Autorun works again in VCFI.** The autorun change in 0.1.22 used a name VCFI's add-on does not know, so autorun did nothing. It now has its own hidden key, as intended.
- The protection added in 0.1.21 that stops a hidden key's name from ever being typed into chat now works in VCFI too.

The game's add-on that comes with VCF and VCFI is still version 56.

---

## VCF 0.10.63 and VCFI 0.1.23

Published 2026-11-06 16:07 US Mountain Standard Time

### New in VCF 0.10.63 and VCFI 0.1.23

- **A new FAQ entry:** "Accept (or another voice command) does nothing." If ACCEPT doesn't work, make sure the Num Lock key on the keyboard is shown to be ON. Some hidden keys are on the number pad, and they only work while Num Lock is on.

Also included from 0.10.62 / 0.1.22: autorun no longer presses Num Lock. It has its own hidden key. After updating, /reload in the game twice so autorun gets it.

Only in VCFI:
- The new FAQ entry is shown in French, German, Spanish and Chinese (Simplified and Traditional). These have not been checked by native speakers yet.

The game's add-on that comes with VCF and VCFI is still version 56.

---

## VCF 0.10.62 and VCFI 0.1.22

Published 2026-11-06 15:57 US Mountain Standard Time

### Fixed in VCF 0.10.62 and VCFI 0.1.22

- **Autorun no longer presses Num Lock.** WoW's default key for autorun is Num Lock, and pressing it switches Num Lock off for the whole computer. With Num Lock off, the game reads numpad keys as other keys, so several voice commands that use them (such as accepting a quest) stopped working. Autorun now has its own hidden key, which the game's autorun is bound to directly. This happens for every character the next time you open VCF or VCFI.
- VCF and VCFI never use Num Lock, Caps Lock or Scroll Lock as a command's key.

If accept or another command stopped working after you said "autorun", click on your desktop (not the game) and press Num Lock once so its light is on.

After updating, /reload in the game twice so autorun gets its new key.

The game's add-on that comes with VCF and VCFI is still version 56.

---

## VCF 0.10.61 and VCFI 0.1.21

Published 2026-11-05 21:21 US Mountain Standard Time

### New in VCF 0.10.61 and VCFI 0.1.21

- **Words already in use.** If a newer command comes with words you already use for a command that does something different (for example "heal" on a spell and on an item), your command keeps your words. The newer one gets no words, and its words box says PHRASE "HEAL" IS IN USE, REWORD THIS ONE OR THE OTHER ONE until you reword one of the two. Similar words, like "pee one heal" and "pee two heal", are never affected.
- **Commands that do the same thing can share words.** For example, Attack Target and the Attack in your spellbook are the same action, so you can give Attack Target the words "attack target, attack foe" even if "attack foe" is already on Attack. Saying the words does it once, never twice.
- **Attack uses the game's key.** The Attack in your spellbook now uses the key the game gives Attack Target (T by default), not the action bar slot it sits in. This happens for every character the next time VCF reads it from the game.
- **Hunters:** your pet's Attack command no longer takes your own Attack key. It uses the pet's own key again.
- If one copy of the same command is on one of VCF's hidden keys and the other on a key the game gave it, your words go to the game's key and the hidden-key copy is removed, which frees that hidden key.
- **Superfood:** an item that is food and drink in one now gets the words "superfood". You can rename it in RENAME AN ITEM or in the Control Panel.
- VCF never types its own hidden-key names into the game's chat. If a hidden key isn't ready yet, the command is skipped and the log says why.
- **Two new FAQ entries:** what the IN USE notice means, and what to do if Loot, Catch or another Interact command stops working after switching controller mode (restart the game).

Only in VCFI:
- The new texts are shown in French, German, Spanish and Chinese (Simplified and Traditional). Superfood is "superaliment", "Superfood", "superalimento" and 超级食物 / 超級食物. These have not been checked by native speakers yet.

The game's add-on that comes with VCF and VCFI is still version 56.

---

## VCF 0.10.58 and VCFI 0.1.18

Published 2026-11-05 20:16 US Mountain Standard Time

### New in VCF 0.10.58

- **Ignoring a named item now frees its key.** In RENAME AN ITEM, ticking Ignore on an item you gave words to also removes those words and frees its key, so items you no longer use don't use up keys.

### New in VCFI 0.1.18

VCFI gets RENAME AN ITEM (as in VCF 0.10.56 and 0.10.58):

- A new **RENAME AN ITEM** button in the MIC IS box. Click it: VCFI reloads the game for you, then opens the Control Panel with a list of the items your character carries that can be used or worn (armor, weapons, trinkets, food, drink).
- Type your own words next to an item and press Enter. Saying them puts the item on (armor, weapons, trinkets) or uses it (food, drink). For example, give your weapon a name and say it to swap weapons.
- Tick **Ignore** beside an item you never want to see on the list; its words are removed and its key is freed. **Show ignored items** brings one back.
- New words work after your next /reload. Closing the Control Panel ends renaming; click RENAME AN ITEM again to rename more.
- If you say an item's words when you no longer have it, VCFI writes "out of" that item in its log and sends nothing.
- Each character has its own list. Your item words are not given to other characters through shared profiles; only importing a shared profile back onto the same character brings them back.

Only in VCFI:
- The RENAME AN ITEM button, window and messages are shown in French, German, Spanish and Chinese (Simplified and Traditional). With English chosen, VCFI looks the same as VCF. These texts have not been checked by native speakers yet.

The game's add-on that comes with VCF and VCFI is version 56. Open VCF or VCFI, then restart the game, so it loads.

---

## VCF 0.10.56 and VCFI 0.1.17

Published 2026-11-05 18:02 US Mountain Standard Time

### New in VCF 0.10.56

**RENAME AN ITEM: your own words for your items**
- A new **RENAME AN ITEM** button in the MIC IS box. Click it: VCF reloads the game for you, then opens the Control Panel with a list of the items your character carries that can be used or worn (armor, weapons, trinkets, food, drink).
- Type your own words next to an item and press Enter. Saying them puts the item on (armor, weapons, trinkets) or uses it (food, drink). For example, give your weapon a name and say it to swap weapons.
- Tick **Ignore** beside an item you never want to see on the list. **Show ignored items** brings one back.
- New words work after your next /reload.
- Closing the Control Panel ends renaming. Click RENAME AN ITEM again to rename more.
- If you say an item's words when you no longer have it, VCF writes "out of" that item in its log and sends nothing.
- Each character has its own list. Your item words are not given to other characters through shared profiles; only importing a shared profile back onto the same character brings them back.

The game's add-on that comes with VCF is now version 56. Open VCF, then restart the game, so it loads.

---

## VCF 0.10.55 and VCFI 0.1.17

Published 2026-11-05 17:12 US Mountain Standard Time

### New in VCF 0.10.55

**The game's own preset keys, by voice**
Each of these presses the game's own key for it, so it follows you if you change that key in the game:
- "attack target" (T), "last enemy" (G), "previous enemy" (Shift+Tab), "target pet" (Shift+F1)
- "open all bags" (Shift+B), "autorun" (Num Lock), "sheathe weapon" (Z)
- "professions" (K), "reputation" (U), "pee vee pee" for PvP (H), "group finder" (I), "pet journal" (Shift+I), "nameplates" (V)

**Fixes**
- Find Friend and Next Friend now start on Ctrl+Tab, and Guild Window on J: the game's own keys. (Characters VCF already knew were not affected.)
- Legacy gets its key Y as soon as VCF opens, on characters that had the old Achievements with no key.

**FAQ**
- New entry: "Fishing won't work by voice. What can I do?" Fishing by voice has been tested and works through a bar slot that /zenvc bars places.

### New in VCFI 0.1.17

VCFI gets the same as VCF 0.10.55 (with /zenvci in the FAQ).

Only in VCFI:
- The new commands' words in your language, for example French "attaquer cible", German "Ziel angreifen", Spanish "atacar objetivo", Japanese "ターゲットを攻撃", Chinese "攻击目标" / "攻擊目標". Their names on the screen and the new FAQ entry are translated too.
- These words have not been checked by native speakers yet. You can change any of them in the Control Panel.

---

## VCF 0.10.53 and VCFI 0.1.16

Published 2026-11-05 16:19 US Mountain Standard Time

### New in VCF 0.10.53

- **Legacy replaces Achievements.** WoW Forever has no achievements: the Legacy System takes their place. Say "legacy" to open the Legacy panel. It uses your game's own Legacy key (Y unless you changed it).
- **Riding is hidden until learned**, like Archaeology. Riding is a skill with nothing to use. Getting on and off a mount is done by using the mount itself, which will show with your items once you have one.

### New in VCFI 0.1.16

VCFI gets the same as VCF 0.10.53:

- **Legacy replaces Achievements.** Say the word for Legacy in your language to open the Legacy panel, with your game's own Legacy key (Y unless you changed it).
- **Riding is hidden until learned**, like Archaeology.

Only in VCFI:

- The spoken word for Legacy: French "héritage", German "Vermächtnis", Spanish "legado", Japanese "レガシー", Chinese (Simplified) "传承", Chinese (Traditional) "傳承". The command's name is shown the same way on the screen. These words have not been checked by native speakers yet; you can change them in the Control Panel.

---

## VCF 0.10.52 and VCFI 0.1.15

Published 2026-11-05 15:52 US Mountain Standard Time

### New in VCF 0.10.52

**Profession abilities on your bars (ALPHA TESTING)**
- Cooking, First Aid, Basic Campfire, Smelting and the crafting windows are now found from your game, even though they are not in the spellbook.
- They show in their own group, "Professions (ALPHA TESTING)". That label goes away once they are proven.
- They only work from an action bar slot with a key. Type /zenvc bars in the game's chat to see where they would go, then /zenvc bars yes to place them, then /reload twice.
- Fishing is not part of this test: it keeps its own Professions group and works as before, from a keyboard bar slot with a key.

**FAQ**
- New entries explain the /zenvc bars, /zenvc bars yes and /zenvc undo lines that sometimes show in the game's chat, and whether /zenvc bars yes is an alternative to reloading twice.

### New in VCFI 0.1.15

VCFI gets everything VCF got today (VCF 0.10.51 and 0.10.52):

**Your spells come from your own spellbook**
- VCFI now takes every class spell from your character's real WoW Forever spellbook. The old built-in class lists (written for a different version of WoW) are gone, so the list only shows what your character can really use.
- Words you gave to a spell are kept.
- Passive spells and racials (always on, nothing to press) no longer get a key. The game itself says which ones are passive.
- Active racials such as Walk on Air, Skysight and Shatter Curse are now in the list.

**Grouped the way the game does it**
- Spells are grouped like your spellbook: General, one group per talent tree, Talents, and Items.
- Your character's name is in the group, for example "Warrior Gallagar · Spellbook: Arms".
- A Hunter's or Warlock's pet commands sit next to the pet's own abilities.

**Updates itself when you reload**
- Learn a new spell, then /reload twice and keep playing. VCFI picks up your character's new spells, talents and items by itself. VCFI never reloads your game on its own.
- The line under the buttons now counts your character's spells and items, and how many are new.

**Food, drink and potions**
- Food and drink get short words: "eat bread", "eat jerky", "drink water".
- Health potions: "drink aitch pee" or "drink health pot". Mana potions: "drink em pee", "drink mah nah pot" or "drink man nah pot".
- Food or drink you no longer carry is switched off and gives up its key, so it never presses a slot that now holds something else.

**Interact (loot, talk, shop, gathering)**
- VCFI keeps its own Interact key. If you give Interact a key of your own in the game, VCFI adds it as a second key. Only one is ever sent.

**Profession abilities on your bars (ALPHA TESTING)**
- Cooking, First Aid, Basic Campfire, Smelting and the crafting windows are found from your game and shown in "Professions (ALPHA TESTING)". Use /zenvci bars, then /zenvci bars yes, then /reload twice. Fishing works as before.

**Other**
- Close All is removed. It had no key in the game. Say "go back" to close a window.
- Your character's race now comes from the game.
- New FAQ entries about /zenvci bars, /zenvci bars yes and /zenvci undo.

Only in VCFI:

**Your language**
- The new group names, messages and FAQ entries are shown in French, German, Spanish and Chinese (Simplified and Traditional). With English chosen, VCFI looks the same as VCF.
- Food, drink and potion words follow the language VCFI listens in:
  - French: "manger pain", "boire eau", "boire potion de soins", "boire potion de mana"
  - German: "Brot essen", "Wasser trinken", "Heiltrank trinken", "Manatrank trinken"
  - Spanish: "comer pan", "beber agua", "beber poción de salud", "beber poción de maná"
  - Chinese (Simplified): "吃" or "喝" with the item's name, "喝治疗药水", "喝法力药水"
  - Chinese (Traditional): "吃" or "喝" with the item's name, "喝治療藥水", "喝法力藥水"
  - Japanese: the item's name stays its words.
- These words have not been checked by native speakers yet. You can change any of them in the Control Panel.

---

## VCF 0.10.51 and VCFI 0.1.13

Published 2026-11-05 15:11 US Mountain Standard Time

New in VCF:

**Your spells come from your own spellbook**
- VCF now takes every class spell from your character's real WoW Forever spellbook. The old built-in class lists (written for a different version of WoW) are gone, so the list only shows what your character can really use.
- Words you gave to a spell are kept.
- Passive spells and racials (always on, nothing to press) no longer get a key. The game itself says which ones are passive.
- Active racials such as Walk on Air, Skysight and Shatter Curse are now in the list.

**Grouped the way the game does it**
- Spells are grouped like your spellbook: General, one group per talent tree, Talents, and Items.
- Your character's name is in the group, for example "Warrior Gallagar · Spellbook: Arms".
- A Hunter's or Warlock's pet commands sit next to the pet's own abilities.

**Updates itself when you reload**
- Learn a new spell, then /reload twice and keep playing. VCF picks up your character's new spells, talents and items by itself. VCF never reloads your game on its own.
- The line under the buttons now counts your character's spells and items, and how many are new.

**Food, drink and potions**
- Food and drink get short words: "eat bread", "eat jerky", "drink water".
- Health potions: "drink aitch pee" or "drink health pot". Mana potions: "drink em pee", "drink mah nah pot" or "drink man nah pot".
- Food or drink you no longer carry is switched off and gives up its key, so it never presses a slot that now holds something else.

**Interact (loot, talk, shop, gathering)**
- VCF keeps its own Interact key. If you give Interact a key of your own in the game, VCF adds it as a second key. Only one is ever sent.

**Other**
- Close All is removed. It had no key in the game. Say "go back" to close a window.
- Your character's race now comes from the game.

---

## VCF 0.10.45 and VCFI 0.1.13

Published 2026-11-04 23:36 US Mountain Standard Time

New in VCFI:

- **CLOSE CHAT** clears the text from the chat bar. Then press B on the controller, or say ESCAPE (the default word; use whatever word you've chosen if you changed it), to exit chat mode.
- **SEND CHAT** sends the text as chat from you.
- Both have spoken words in every VCFI language: French, German, Spanish, Japanese, and Chinese (Simplified and Traditional).
- The Glossary has entries for Close chat and Send chat, in each screen language.
- The Glossary is sorted by topic, then alphabetically within each topic, in your screen language.

---

## VCF 0.10.45 and VCFI 0.1.12

Published 2026-11-04 23:22 US Mountain Standard Time

New in VCF:

- The Glossary now has its own entries for **Close chat** and **Send chat**.
- The Glossary is sorted by topic, then alphabetically within each topic.

---

## VCF 0.10.44 and VCFI 0.1.12

Published 2026-11-04 20:40 US Mountain Standard Time

VCF 0.10.44. VCFI is unchanged at 0.1.12. VCF and VCFI are still in testing.

New in VCF:

- **CLOSE CHAT** clears the text from the chat bar. Then press B on the controller, or say ESCAPE (the default word; use whatever word you've chosen if you changed it), to exit chat mode.
- **SEND CHAT** sends the text as chat from you.

---

## VCF 0.10.43 and VCFI 0.1.12

Published 2026-11-04 16:58 US Mountain Standard Time

First release. VCF and VCFI are still in testing.

- **VCF 0.10.43:** English.
- **VCFI 0.1.12:** French, German, Spanish, Chinese (Simplified), Chinese (Traditional), Japanese and English.

---

## Voice Language Test 1.1.0

Published 2026-11-04 00:26 US Mountain Standard Time

The voice language test, version 1.1.0. Download VOICE.LANGUAGE.TEST.exe and its READ ME below, then run the exe. There is no installer and nothing is uploaded. It saves a report on your desktop, and your own list if you use TEST CUSTOM LIST. You choose whether to email your report to vcfireports@gmail.com.

New in 1.1.0:
- The license is shown first: click I AGREE to continue.
- Choose TEST VC WORDS (VCFI's own words) or TEST CUSTOM LIST to type and test your own words, one phrase per line.
- Your own list works like VCFI's words: 20 phrases or fewer are done in one go; a longer list stops after 20 and offers 10 more at a time. Testing every phrase still shows the thank-you screen.
- A Finish button on every phrase lets you stop early and save a report of what you have done.
- Your custom list is saved on your computer for next time, in %APPDATA%\Voice language test\custom list.txt (delete that folder to remove it).
- The report says which test you chose.
