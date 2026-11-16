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
- Nothing runs on its own: no loops, timers, rotations or automatic play. Every action starts from the player speaking.
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
- Places spells on an empty action bar, with keys, only when the player asks (/zenvc bars yes). It never replaces anything on the player's bars.
- Lets the player move an outline through bags, vendors, trainers, professions, the map and the quest log by voice, and select with the game's own clicks. Its own tooltip shows the outlined item in large text.
- Reads quest text aloud with World of Warcraft's own text-to-speech.
- Asks the player to confirm before using, destroying or unlearning anything. The game's own confirmation boxes still appear and are answered by the player.
- Writes down any action the game blocks, so problems can be fixed.

If any part of this does not fit Blizzard's rules, I would be grateful to be told, and I will change it.

Thank you,

TheZenaxa

Reports and questions: vcfireports@<span>gmail.com</span>
