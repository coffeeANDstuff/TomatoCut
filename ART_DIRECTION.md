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

## First illustrated variety branch (v0.3)
Cherry has its own rounder/taller shell, four-point calyx, thinner stem, three-chamber interior and full half/wedge/eighth set. Authored normalized axes are (0.54, 0.60, 0.54), then gameplay scales the model to 0.62. Standard Red retains its original wider lobed silhouette. Cherry flesh uses a restrained coral red; the close-up review corrected an initially over-yellow material. Do not imply that this normal red-skinned variety is a prestige Golden Tomato event.

`tools/build_assets.py -- --cherry` and `art/cherry.blend` preserve the source without overwriting the Standard Red/knife assets. `tools/build_catalog_art.py` generates the original two botanical specimen illustrations, printed branch rule and six matching category line icons. These are integrated in the live Varieties catalog. Standard Red and Cherry remain visible after discovery, including a 0% phased-out share; never turn specimen navigation into a spawn selector.

Fragment model caches now retain at most three variants per pooled piece, evicting inactive scene instances rather than accumulating every variety indefinitely. Match each variety's authored axes/lobes, model scale and fragment map when adding more content. Normalized asset-study screenshots are distinct from actual in-game-size screenshots.

## Durable elongated variety (v0.4)
Roma uses its own tapered oval shell, three-leaf crown, compact stem, two elongated seed chambers and half/wedge/eighth set. Normalized axes are (0.40, 0.78, 0.40), with 0.15 vertical taper and 0.95 gameplay scale. Its authored elongated silhouette and faster Z tumble distinguish it from a recolored sphere. `art/roma.blend` and `tools/build_assets.py -- --roma` preserve the four integrated GLBs; previous variety/knife assets remain intact.

The live catalog includes an original matching botanical Roma plate. Whole Roma and its descendants use sampled convex hulls from the same axes/lobes/taper, transformed with their actual 3D pose. The calyx remains decorative. Half/wedge/eighth cut faces and seeds were inspected in the rendered study; no runtime arbitrary mesh cutting is implied.

A resisted strike uses a short squash on whole fruit, a restrained original resistance sound and an optional remaining-strikes label with ink shadow. Labels obey reduced motion; their preference is independent of money popups. No screen shake is introduced. Settings and ordinary catalog buttons retain ink-colored text on hover/press/focus for paper contrast. These are integrated original assets, with final material/texture refinement still in Phase 7.

## Botanical discovery presentation (v0.5)
Newly revealed entries keep the existing compact catalog order. A small tomato-red seed dot on the category and catalog navigation icons advertises unread entries. It is a quiet indicator, not a notification panel or modal. Category controls use the established one-second tooltip delay.

`CatalogVine` draws an original thin ink stem with three engraved leaves. For an unseen entry, the vine grows over 0.5s as its existing category/specimen illustration and printed title fade in. The geometry reserves its final space from the start; no moving panels, layout reshuffles or camera shake. Animations bind to their catalog page and stop when it is freed. Reduced Motion shows the complete vine, illustration and label immediately.

Exposure tracking uses the clipped title rectangle and a short dwell; merely opening a category does not consume all its discoveries. One quiet original discovery cue plays per visible batch. Seen entries appear fully printed on later visits. Existing botanical plates and all 3D assets are preserved. Final hand refinement remains a separate production-art pass.

## First automatic cutting ability (v0.6)
The gated Abilities section uses an original engraved sprout/spark icon from the same line-art generator as the other category icons. Seven-category spacing leaves the read-only harvest summary clear at 16:10 and 16:9. A real revealed ability is required before the category appears; no placeholder section is exposed.

Critical Slice uses a brief cream/ink-shadow label and an original short wet/steel accent. It changes accepted-strike damage in gameplay. Feedback stays local, uses the existing damage-indicator preference and reduced-motion behavior, and introduces no camera shake or prestige-gold styling. Money feedback and cut values retain their usual behavior. Whole fruit, interiors and knife assets are unchanged. Original effects are integrated and exercised with Dummy audio; audible review remains unperformed.

## First equipment catalog (v0.7)
The Plastic Picnic Knife is an original molded ivory-plastic instrument with a sage grip inset, raised ivory grip ribs, rounded handle and small hanging loop. Its longer, angular blunt blade differs in geometry/materials from the existing worn-steel, walnut/brass starter. `tools/build_equipment_assets.py`, `art/picnic_knife.blend` and `assets/models/knives/plastic_picnic.glb` retain the editable/exported source without overwriting earlier assets. The lower blade outline matches the authored cutting-edge polyline in `data/knives.json`; the handle never becomes a cutting target.

The generous cream-paper product page uses catalog numbers, subtle humor, restrained gold rules, honest current sharpness/reach/precision/special attributes, and separate purchase/equip actions. It renders the actual equipped-capable GLB in its own lit 3D world. Automatic rotation never moves the kitchen camera; Reduced Motion fixes a useful three-quarter pose. Product transitions free the old viewport/world. Knife navigation uses the existing original line-icon family and delayed tooltips. Reviewed starter/picnic pages and the equipped product/home at 16:10 and 16:9. These are integrated milestone assets; final surface texture and hand refinement remain Phase 7 work.
