# Tomato Cut — Production Polish & Final Development

Continue developing **Tomato Cut** from the existing project, prioritizing production-quality polish, completing the tomato and knife collections, redesigning the upgrade systems, optimizing performance, and refining the UI into a cohesive, professional-quality game.

Read `AGENTS.md`, `GAME_DESIGN.md`, `ART_DIRECTION.md`, `ROADMAP.md`, `PROGRESS.md`, and `TESTING.md`. Inspect the actual implementation, identify incomplete systems, and continue building upon existing work without unnecessarily restarting completed features.

## 1. Complete Tomatoes & Knives

Finish creating, refining, and integrating every planned tomato and knife variation according to the existing specifications.

- Complete missing assets and replace unfinished or inconsistent artwork.
- Give each tomato distinctive shapes, colors, textures, interior details, slicing behavior, and visual effects.
- Give each knife a unique silhouette, blade material, handle design, and visual personality.
- Maintain consistent scale, perspective, lighting, and the established stylized 2.5D arcade aesthetic.
- Polish slicing animations, physics interactions, deformation, particles, and tactile feedback.
- Ensure every asset functions correctly with gameplay, selection, unlocks, and progression.
- Make higher-tier collectibles visually desirable through exceptional design rather than excessive effects.

**Every tomato and knife should feel individually crafted, visually polished, and fully integrated—not like a placeholder or simple recolor.**

## 2. Redesign Upgrade Pages Into Organic Root Systems

Completely redesign the existing upgrade pages into **large, interconnected, branching upgrade trees inspired by natural root systems**.

The upgrade system should become a visually engaging centerpiece of the game.

- Replace conventional upgrade lists and grids with beautifully illustrated, organic branching nodes.
- Begin with a central root node, with upgrade paths naturally branching outward into increasingly complex networks.
- Design the system to eventually resemble a massive underground root structure filled with interconnected upgrades.
- Allow players to **click and drag to pan across the tree** and **zoom smoothly using the mouse wheel**, with intuitive navigation across a potentially enormous upgrade network.
- Use smooth camera movement, sensible zoom limits, and clear visual indicators for navigation.
- Reveal new branches and upgrade nodes progressively as preceding upgrades are purchased. Do not display the entire tree immediately.
- Make available, purchased, locked, and newly revealed upgrades visually distinguishable without excessive clutter.
- Provide clear hover tooltips showing upgrade names, costs, effects, requirements, and benefits.
- Animate root growth, branching, and node activation when upgrades are purchased.
- Maintain excellent readability and usability at different zoom levels.
- Ensure the system supports a large number of meaningful upgrades without becoming confusing or difficult to navigate.

The root system should feel **handcrafted, organic, tactile, and visually spectacular**, while remaining consistent with Tomato Cut's illustrated arcade style.

Preserve all existing upgrade logic, progression, costs, prerequisites, and saved progress unless an intentional improvement is justified.

## 3. Production-Ready Menu & UI Refinement

Perform a comprehensive visual and usability overhaul of the game's menus and interfaces.

- Refine the main menu, settings, collections, knife selection, tomato selection, upgrade screens, and other existing interfaces.
- Improve layouts, spacing, typography, iconography, visual hierarchy, and navigation.
- Use beautifully illustrated UI elements that complement the game's playful, tactile 2.5D aesthetic.
- Favor intuitive icon-based controls where appropriate, revealing labels after approximately one second of hovering.
- Add polished transitions, subtle animations, satisfying interaction feedback, and consistent button states.
- Eliminate clutter, clipping, overlapping elements, excessive text, and inconsistent styling.
- Ensure menus remain responsive, accessible, and easy to navigate at different resolutions.

**The UI should feel like a finished commercial indie game, not a functional development interface.**

## 4. FPS Optimization & Performance Stability

There is currently a noticeable **FPS degradation when larger numbers of tomatoes and sliced tomato pieces accumulate on screen**, causing gameplay to slow down and become less responsive.

Investigate and resolve this issue without compromising the existing gameplay experience, visuals, physics, or intended mechanics.

- Profile the game to identify the primary causes of performance degradation.
- Investigate physics calculations, collision detection, rendering, draw calls, particle effects, object spawning, and sliced-object management.
- Identify unnecessary per-frame calculations, memory allocations, or inefficient update loops.
- Explore optimizations such as object pooling, improved collision handling, render batching, caching, and more efficient object lifecycle management where appropriate.
- Ensure sliced tomato pieces and other objects are managed efficiently without prematurely disappearing or changing their intended behavior.
- Maintain consistent gameplay speed regardless of fluctuations in rendering performance.
- Test performance under increasingly demanding scenarios involving large numbers of tomatoes, slices, and effects.
- Compare FPS and frame-time performance before and after optimization to verify measurable improvements.

**Performance improvements must preserve the current gameplay, physics behavior, visual fidelity, and player experience.** Do not simply reduce the number of tomatoes, remove slices, disable effects, or lower visual quality to achieve higher FPS.

Prioritize fixing underlying inefficiencies rather than masking the problem.

## 5. Gameplay & Visual Polish

Refine the existing experience rather than introducing unnecessary new mechanics.

Prioritize cutting responsiveness, precise hit detection, satisfying physics, smooth animations, refined lighting, consistent shadows, and cohesive visual effects.

Keep screen shake subtle and localized to gameplay. Favor expressive object animations, tactile cutting feedback, and carefully controlled particles.

Ensure newly completed assets integrate seamlessly with existing gameplay systems.

## 6. Integration, Testing & Quality Assurance

After implementing improvements:

- Review modified code for errors, regressions, and incomplete integrations.
- Verify all tomatoes, knives, animations, and upgrade nodes load and function correctly.
- Test upgrade purchasing, branch revealing, pan/zoom controls, unlock progression, and save/load behavior.
- Benchmark FPS and frame times under normal and high-object-count gameplay conditions.
- Check for memory leaks, unnecessary processing, and performance degradation during extended sessions.
- Check menu navigation, layout consistency, responsiveness, and visual quality.
- Fix discovered issues and rerun relevant tests.
- Remove obsolete UI elements, unused placeholders, and broken asset references.

Do not claim successful testing for anything that could not actually be verified.

## 7. Development Priorities & Autonomy

Work autonomously through as many connected tasks as practical, prioritizing:

1. Complete and polish the tomato and knife collections.
2. Investigate and resolve FPS degradation with numerous tomatoes and slices.
3. Build and integrate the new organic root-based upgrade system.
4. Overhaul and polish all menus and UI.
5. Refine gameplay animations, physics, and visual feedback.
6. Resolve remaining bugs, optimize performance, and validate the implementation.

**Prioritize actual game development over planning or documentation.** Do not repeatedly ask for instructions, restart completed systems, or abandon established requirements.

Update `ROADMAP.md`, `PROGRESS.md`, and `TESTING.md` to reflect actual progress.

## 8. Completion Report

Provide a concise summary of what was implemented, which assets and systems were completed, performance bottlenecks identified, FPS improvements achieved, tests performed, bugs fixed, outstanding issues, and the next recommended task.

## Final Directive

Treat this as a **professional game production and finishing pass**. Aim for polished, distinctive artwork, satisfying interactions, consistently smooth performance, an expansive and beautifully designed root-based upgrade system, and menus worthy of a commercially released indie game.

Make substantial implementation progress, maintain the established artistic vision, and continue until practical session limits or genuine blockers are reached.