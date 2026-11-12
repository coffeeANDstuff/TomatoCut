# Tomato Cut — session continuity

- Read GAME_DESIGN.md, ART_DIRECTION.md, ROADMAP.md, PROGRESS.md and TESTING.md before modifying the game. GAME_DESIGN.md preserves the complete authoritative specification; DEVELOPMENT_INSTRUCTIONS.md preserves the continuity brief.
- Inspect actual files and Git state first. Continue existing work; preserve working systems and user changes. Use the existing isolated checkout; do not create a worktree unless requested.
- Use Godot 4.x, GDScript, fixed-plane 3D and the established modular architecture. Build integrated functionality, not visual mockups. Avoid unrelated dependencies.
- Follow ART_DIRECTION.md before making assets. Keep Blender sources, GLB exports and their generation scripts together. Document production art limitations honestly.
- Follow ROADMAP.md in dependency order. Prioritize slicing reliability, visual cohesion, gameplay and performance over superficial content counts.
- Preserve all 25 varieties/knives in the roadmap; automatic harvest, progressive reveals, prestige-gated events, icon-first navigation, delayed tooltips and restrained feedback remain mandatory.
- Test affected systems and dependencies; fix regressions. Never claim an unrun test passed. Record failures, likely causes and untested platforms explicitly.
- Update PROGRESS.md, ROADMAP.md and TESTING.md after meaningful work. Leave an exact next task and use the explicit status vocabulary in PROGRESS.md.
- Commit stable milestones when Git is available. Do not push or publish without authorization. Keep exports separate from source.
