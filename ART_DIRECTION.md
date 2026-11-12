# Art direction

Authority: GAME_DESIGN.md §§3, 6–7, 10, 14–15, 18–19, 22–23, 28.

## Shared visual language
Stylized tactile 3D culinary objects against a quiet warm kitchen. Vintage seed-catalog interfaces: cream paper, botanical green ink, tomato red accents, engraved linework, serif display typography and quiet sans-serif annotations. No emoji or mixed icon packs. Restrained gold denotes prestigious equipment and permanent seeds, never generic mobile-game gloss.

Palette: cream #F4EAD5, ink #213D35, red #C84630, gold #BA8E4E, muted sage #8A9B7A, charcoal #222A27. Main objects have soft highlights, varied roughness, clean silhouettes and original geometry. Preserve readability over decoration.

## Modeling and cutting
Blender is the source of truth; export GLB. Standard Red: lobed, slightly flattened skin, crown depression, five-point calyx, curved stem. Rusty Butter Knife: rounded blunt blade, worn steel, wooden handle, brass rivets. Prepared halves expose pink flesh, a pale core, seed chambers and visible cream seeds. Align prepared split sets to the swipe and add momentum, tumble and separation. This is hybrid prepared-fragment slicing, not exact runtime arbitrary-plane cutting.

Each later variety requires its own silhouette, skin/interior, behavior and illustrated specimen. Each knife requires distinct blade geometry and corresponding sweep detection. Do not count recolored spheres or unused assets as finished content.

## Interface
Aim for a carefully printed culinary publication: spacious margins, small catalog numbers, thin rules, illustrated sprout motifs and paper texture. Main menu integrates the actual 3D tomato and knife. Catalog entries follow a branching specimen ledger, not a futuristic skill tree or generic card grid. Stable branch layout, compact category navigation, hidden prerequisites, current/next effects and clear prices. Equipment uses generous 3D product previews. Prestige becomes a rare-seed archive.

Use a cohesive original line-icon family. Frequent navigation is icon-first with immediate hover styling, one-second delayed labels, immediate dismissal and screen-clamped positioning. Keep Play Again and irreversible actions visibly labeled. Responsive containers must work at 16:9 and 16:10.

## Motion and effects
Fixed orthographic camera. Ordinary slices never shake it. Fruit arcs stay on XY; decorative fragments may tumble in depth. Juice bursts and slim warm trails stay localized and bounded. Money popups are brief. Reduced Motion removes unnecessary UI movement. Rare shake, if introduced, is limited to 2–3 pixels / 0.15s with a 2s cooldown and Off support.

## Audio
Original short wet cuts, dull steel scrape, soft launch and paper-click cues. Independent master/music/effects levels. Music is playful instrumental jazz/funk, reserved for a later milestone; do not claim synthesized effects constitute a finished soundtrack.

## Asset workflow and review
Run tools/build_assets.py with Blender to regenerate the authored vertical-slice GLBs and .blend. Keep deterministic seeds. tools/build_audio.py creates the original milestone effects. Integrate every counted asset. Review actual rendered frames as well as import logs; headless checks cannot establish visual quality or 60 FPS. Future production pass must hand-refine meshes, botanical illustrations and material texture detail.

## Integrated multi-cut asset pass (v0.2)
Standard Red now has prepared halves, quarter wedges and eighth chunks exported from the same Blender flesh/skin/chamber/seed materials. The diagonal eighth cap exposes a small chamber and seeds. Geometry is preserved through mirrored parent frames; recut impulses follow the new swipe. Recut faces use authored planes and are an approximation rather than arbitrary mesh intersections. Additional prepared orientations and hand-refined silhouettes remain a production-art task.

Interactive fragment proxies project sampled shell hulls through the actual 3D fragment transform. Never substitute the original full-tomato circle for a tumbling wedge. The smallest eighths are visual debris, and edge-on/minuscule projections are not reward targets. Preserve this agreement when changing meshes, pivots or scales.

Use `tests/fragment_gallery.gd` to review the three actual fragment models together; it is a development tool, not additional game content. All three are also integrated into real cuts.
