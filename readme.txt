Running the game
----------------
RUN THE GAME AT NTSC SPEED (60 Hz)! This is the speed at which the game was designed to run. It is fine if you have to emulate a Japanese MSX to do so. If run at PAL speed (50 Hz), the music will be slower, not to mention the game in general.

If your emulator or flash cart asks for the ROM type, there should be an option like "ASCII 8kbyte" or "ASCII8". Choose that one. Chances are, though, that the emulator will autodetect the ROM type correctly. You'll know if it doesn't, since the game will not run at all with the wrong ROM type.


Translation notes
-----------------
Our general philosophy when translating is that making the text natural and entertaining is more important than making it an accurate reflection of the original Japanese. After all, if you want an authentic Japanese experience, you're only going to get it by playing the game in Japanese. That said, we have tried our best to preserve the spirit of the original game, and most of the concessions we've made are pretty minor.

Here are some of the particular issues we ran into when translating. WARNING: Here be minor spoilers!

* Many character names were changed. For example, Renard was originally named Gonkichi, and Kit was originally named Kokon. "Gon" and "kon" are fox noises in Japanese, and "ko-" is often a prefix meaning "little" or "offspring". (For example, a "koinu" is a puppy, and the Koopalings in the Mario series are called "Kokuppa".) So we chose "Renard", which is French for "fox", and of course a fox's offspring is called a "kit". We didn't manage to capture the nuance of every name, and a couple of names were pulled out of a hat.

* We ran into a few technical limitations. We didn't have the typical problem of how to fit the text into the ROM because it was easy to expand the ROM and allocate about 12 KB of text per chapter. Likewise, we didn't have any problems with fitting stuff onto the screen since we added a proportional font to the game, despite the game using a tile-based screen mode. (This added weeks to the hacking process, so we hope you like it!) What we did run into, though, was that our proportional font doesn't allow us to change the color in the middle of text, as the original game occasionally did. We can only change colors cleanly at 8x8 tile boundaries. On the upside, our custom font allowed us to bold the words instead. We also included a monospace uppercase font for passwords because the password prompt used a blinking cursor that assumed the text was monospace, and it was too much work to rework the code for a single prompt. Besides, we felt the use of a typewriter-like font for passwords seemed appropriate, and typewriter fonts are monospace.

* "Puff-puff" is mentioned a couple of times. This is a running gag in Enix games (particularly Dragon Quest), apparently borrowed from Dragon Ball. Akira Toriyama's involvement with Dragon Quest probably had to do with it. Anyway, Google it if you want to know more.

* Some jokes and other ideas didn't translate. One of the most notable is the "N" that is written on the scrap of paper early in the game was originally a katakana "nu". A minor plot point was that this sloppily written character could also be interpreted as a kanji meaning "again" or "later" -- perhaps whoever wrote it intended to return! About the best we could do was suggest it could be a "Z" rather than an "N".

* The name of The Dragon Cafe may have had a dual meaning. The name was spelled "Doragon" in Japanese, and Renard's and Drago's original names were "Gonkichi" and "Dorakure". So "Doragon" could be read as a portmanteau: "Dora[kure]-Gon[kichi]".

* There is a tortured pun involving a stone you find in the Forest Maze. You are told to find the "Kokeshi Rock". A Japanese player would expect to find a rock in the shape of a Japanese kokeshi doll. Instead, what you actually find is a rock with an inscription that almost makes sense, but not quite. Your partner realizes the inscription makes sense if you remove the letter "ko" -- the word "kokeshi" has a second meaning of "erasing the 'ko'".


QUESTIONS & ANSWERS
-------------------
We can't call 'em "frequently asked questions" because then we would be lying.

Q: The game said something about a file to record my progress. Where are the files stored?
A: They aren't. The names are really passwords.

Q: Is there any way to go back to the title screen after choosing "continue"?
A: None that we've found. Reset your MSX.

Q: Can I back out of a command menu when there's no "Cancel" option?
A: Press the 0 key.

Q: This game's too easy!
A: That's not a question. And, well, it is something of a kid's game.

Q: This game's graphics suck!
A: One, that's still not a question. Two, this game was written for the MSX1, on which it is extremely hard to get pretty graphics. The screen is divided into 8x8 tiles, and each line of pixels in those tiles can only have two colors. That means, for example, that drawing an outline around a character or object is just not possible. I'm sure that a particularly skilled artist would be able to create better images, but it would not be easy. Prettier MSX games generally used the much more advanced graphics capabilities of the MSX2.


Credits
-------
* Kef Schecter (furrykef): Hacking, translation (primarily chapters 1 and 2), editing, fonts
* Torbjorn: Translation (primarily chapters 3 through 7), translation checking
* BiFi: Figured out password routine and graphics compression
* Tauwasser: Not directly involved, but the main font is a very heavily modified variant of Tau's Custom Font
* ##japanese on freenode: Invaluable help for some of the finer points of the game's text
* #msxdev on Rizon: Invaluable help for some of the finer points of MSX hacking

Beta testers:
* I.S.T.

Tools used, in no particular order:
* Notepad2
* openMSX
* meisei
* MESS
* Atlas
* Translhextion
* WindHex
* Tile Layer Pro
* git
* TortoiseGit
* GitHub for Windows
* tniASM 0.45
* Python
