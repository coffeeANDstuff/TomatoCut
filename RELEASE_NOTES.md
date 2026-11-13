# Tomato Cut v0.7.0 — The equipment catalog

**[Download the FULL PACKAGE](https://github.com/coffeeANDstuff/TomatoCut/releases/download/v0.7.0/TomatoCut-Full-v0.7.0.zip)** — Windows game, complete editable Godot source, Blender art, tests and handoff documentation.

Unzip it and run **Windows/TomatoCut.exe**. Use **Windows/Play-Compatibility.bat** for the OpenGL fallback. No editor or installer is required to play; open **Source/project.godot** in Godot 4.6.3 standard to continue development.

- Browse the new equipment catalog through its original knife icon on Home, Results or menu navigation. Generous rotating 3D product studies use the actual gameplay models; Reduced Motion keeps a useful static pose.
- The Rusty Butter Knife is already owned. Buy the **Plastic Picnic Knife for $20**, then **Equip** it separately. Owned knives can be switched freely between rounds.
- The original ivory/sage picnic model has a modestly longer cutting edge, with matching swept collision for whole tomatoes and recut pieces. Its base strength, critical chance and cut rewards remain the same as the starter.
- Equipped models update on the cutting board and Home. Save version 3 persists owned/equipped state; v1/v2 saves migrate with their existing progress and the free starter. Invalid inventory is rejected atomically and uses existing backup recovery.
- New Game confirms before replacing purchased equipment. Live rounds deny buying or changing knives. Existing Critical Slice, automatic harvest, family limits and discovery remain integrated.
- Original Blender source, GLB, asset generator, content definitions and equipment regression/render tests are included in the full package.
- Validation: **324 headless checks**, **83 rendered GUI checks**, and **27 embedded-pack checks per export target** pass; the full ZIP and a fresh source extraction are verified.

This development milestone integrates three of 25 normal varieties, two of 25 knives and eighteen upgrades. Equipment modifications are next; remaining content, prestige/events, production polish and human balance stay on the roadmap. Native Windows execution, Forward+ GPU rendering, audible review and target-PC 60 FPS remain unverified. See Source/PROGRESS.md, Source/ROADMAP.md and Source/TESTING.md for executed checks and the exact next task.
