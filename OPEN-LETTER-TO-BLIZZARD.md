# An open letter to Blizzard Entertainment

**To the World of Warcraft Accessibility team, and the World of Warcraft UI and add-on team, at Blizzard Entertainment**

**About: Voice Commander Forever (VCF and VCFI), a free voice accessibility tool for World of Warcraft: Forever**

November 16, 2026

Hello,

I am TheZenaxa, a legally blind player. I made Voice Commander Forever so that I, and other players who cannot easily use a keyboard, mouse or controller, can play World of Warcraft: Forever by voice. This letter describes exactly how it works, in good faith, so there is an open record. I understand that Blizzard does not certify software made by others.

## What it is

- Two Windows programs: **VCF** (English) and **VCFI** (international: French, German, Spanish, Japanese, Chinese). Written in C#, .NET 9 and Avalonia.
- Made, intended, and tested for World of Warcraft: Forever, played through Blizzard's Battle.net app.
- Free. Nothing is sold, no donations are asked for, and there are no advertisements in the game.
- The source code of the in-game add-on is public, in this repository's **addon-code** folder.

## How it hears

- Spoken commands use the speech recognizer built into Windows (Microsoft Speech, offline).
- Optional dictation and a second check use OpenAI's Whisper model, run locally on the player's PC (whisper.cpp). Nothing the player says is uploaded.

## How it sends input

- It sends keyboard keystrokes through Windows (SendInput), and only while the World of Warcraft window is in front. It sends no mouse input.
- One spoken command sends the key for one action. A few commands press their key more than once when the player says a number (for example "move down three"). Chat and dictation type the words the player speaks and press Enter.
- Nothing runs on its own: no loops, timers, rotations or automatic play. Every action starts from the player speaking, or clicking a button in VCF.
- One exception, started by the player by hand: a KEY TEST presses each of its keys once (about 200, a third of a second apart) to find which keys reach the game on that PC. During the test those keys are bound only to counters and do nothing in the game.

## What it does not do

- It does not read or write game memory, inject code, read or change network traffic, or read the screen.
- It does not change the game's program or data files.

## Files it uses

- It installs and updates its own add-on in the game's Interface\AddOns folder, and writes a command list file there for the add-on.
- It reads the add-on's saved variables in the game's WTF folder, which the game writes when the player logs out or reloads.

## The in-game add-on ("VCF Helper": ZenVCExport; "VCFI Helper": ZenVCIExport)

It uses only the standard World of Warcraft add-on API. It:

- Saves the character's spells, items, key bindings and a few settings, so the voice program knows what each character can do.
- Gives voice commands hidden keys through override bindings to its own buttons (spells, items, emotes), set out of combat.
- Uses secure action buttons for protected actions, so those happen only through the game's own approved click path, after a key press.
- Places spells that are on no bar onto a spare action bar (one the player has not placed anything on, including the one it started filling), with keys, only when the player asks: by saying "new spells" or clicking NEW SPELLS in VCF and then answering VCF's yes or no question, or by typing /zenvc bars yes. It never uses or replaces anything on the player's own bars, and does nothing in combat.
- Lets the player move an outline through bags, vendors, trainers, professions, the map and the quest log by voice, and select with the game's own clicks. Its own tooltip shows the outlined item in large text.
- Buys, sells or trains only the outlined line, one per spoken command. At a trainer it asks first, and says the game's own reason when something cannot be trained yet.
- In the professions window, opens a profession when the player selects its tab (C_TradeSkillUI.OpenTradeSkill) and shows the outlined recipe in the window's own recipe panel, out of combat. When the player says "create", it presses the window's own Create button through a secure click, making one item per spoken command.
- Copies the text of the game's own tooltip into its own larger box (read only, from the tooltip's after-hooks; the game's tooltip is never changed).
- Shows the player's coin in its own box, read only, when the player asks.
- Moves the player's bag frames to the places the player chose, only out of combat and only after the game has placed them.
- Shows short hint lines (in its own box, see below) with the player's own command words, for example when a quest page opens.
- Shows its own lines (hints, tips, announcements) in its own movable box instead of the game's chat, and keeps the last 300 lines in its saved file.
- Reads the character pane's worn slots, the spellbook and the talents as outline lists (read only: names, ranks and the game's own tooltips). In the spellbook and the talents, the only button it presses is a tab or page button, through a secure click, when the player says "select".
- Reads an open letter aloud with the game's own text-to-speech when the player asks.
- Never touches a window the game marks as forbidden to add-ons.
- Reads quest text aloud with World of Warcraft's own text-to-speech.
- Asks the player to confirm before using, destroying or unlearning anything. The game's own confirmation boxes still appear and are answered by the player.
- Writes down any action the game blocks, so problems can be fixed.

If any part of this does not fit Blizzard's rules, I would be grateful to be told, and I will change it.

Thank you,

TheZenaxa

Reports and questions: vcfireports@<span>gmail.com</span>

**Note: movement is best handled by keyboard and mouse or controller, and entering text may be more efficient with a keyboard. Voice commands take effect once the player is logged in, and some actions may still need physical input. Please report errors or requests to me.**
