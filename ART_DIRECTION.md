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

## Preparation and forged equipment (v0.8)
The original Honing Kit is a dual-layer sage/charcoal stone in a rounded walnut cradle, with small brass fittings and engraved fine strokes. `tools/build_modification_assets.py`, `art/honing_kit.blend` and `assets/models/equipment/honing_kit.glb` retain its editable source and exact preview geometry. It is a reusable preparation tool rather than a blade attachment; application changes the selected knife's effective sharpness, without changing its silhouette, reach or collision path. The actual kit turns in an isolated product-study world, becoming still with Reduced Motion.

The Steak Knife uses polished forged steel, a pointed tapered blade, a curved olivewood handle around a visible full tang, a steel bolster and three brass through-rivets. `tools/build_steak_assets.py`, `art/steak_knife.blend` and `assets/models/knives/steak.glb` preserve this original geometry. Its three-point lower edge agrees with the sweep definition; the handle and upper spine are not cutting edges. It has greater base sharpness and a more compact reach than the picnic knife. Earlier models are unchanged.

An original engraved stone icon joins the existing line-icon family. Knife and preparation pages share cream paper, restrained gold accents, generous actual-model previews, separate ownership/application actions and clear current/prepared stats. Targets list only owned instruments; changing a target never equips it. No cosmetic placeholder tab is shown. The kit and three-instrument pages were inspected at both supported aspect ratios.

`tools/build_audio.py` now also generates the short original `steak_slice.wav` cue. Equipment data selects it for whole-fruit and fragment cuts through the shared bounded player pool and persisted master/effects settings. Other generated WAVs remain byte-for-byte unchanged. Loading, length and actual dispatch are tested with Dummy audio; audible timbre/quality and final hand refinement remain production review tasks.

## Rare-seed archive (v0.9)
`tools/build_prestige_art.py` creates the original editable `assets/illustrations/prestige/seed_envelope.svg`: a cream folded packet, fine engraved rules, a restrained gold botanical seed seal and small catalog marks. The envelope navigation icon is drawn in the existing original line family with the normal hover/delayed tooltip behavior. No new tomato/knife model or event is counted by this artwork.

The archive uses the existing cream paper, serif titles, muted ink annotations and generous margins. Its left ledger shows qualifying cycle earnings and the seed quote; the right scroll contains only genuinely revealed permanent investments, with current/next effects, seed prices and bounds. Actual botanical vines, label/art fades, clipped-title dwell acknowledgement, unread dots and reduced motion share the seed-catalog implementation. Permanent discovery/read state survives prestige. Reset/preserve consequences stay visible before the confirmation dialog. Dialogs freeze discovery acknowledgement so their underlying ledger quote cannot change while blocked by a modal.

Main menu, Results and menu navigation expose the envelope icon without entering live gameplay. Ordinary and prestige actions leave the kitchen camera fixed. The short original `prestige.wav` chime is local to a successful saved reset and respects existing master/effects settings. Dummy audio checks loading/dispatch, not audible quality. Actual archive/branch/16:9 frames were inspected; final illustration refinement, listening and supported-PC performance remain future production work.

## Golden Harvest (v0.10)
`tools/build_assets.py -- --golden` creates the original event-specific seven-lobed golden specimen, seven-leaf crown, curved segmented stem and amber seven-chamber interior with ivory seeds. Whole/half/wedge/eighth GLBs are separate from all normal varieties, including future Sungold. Matching seven-lobed descendant proxies preserve the silhouette. `art/golden_harvest.blend` retains all four editable models; prior Blender/GLB assets were preserved. Golden skin uses restrained metallic gold with low emission; flesh, central pith, chambers and seeds remain distinct. An initially over-bright interior was toned down after actual-size/gallery inspection. Software OpenGL frames show the actual whole fruit and separated tumbling interiors, not a replacement sprite.

`tools/build_event_art.py` authors the original engraved gold specimen/star plate in `assets/illustrations/prestige/golden_harvest.svg`. The archive's Special Events category appears only after an actual reveal and keeps the established paper, ink, botanical vine, clipped-title discovery, unread indicators and Reduced Motion. Real current/next frequency and value comparisons remain readable at 16:10/16:9; rebuilding the same category retains scroll position. Other event categories/nodes are not simulated.

Golden spawn feedback is a short local gold label, a restrained original two-note `golden.wav` cue and pooled golden juice on real cuts. The camera stays fixed. Label visibility shares Damage Indicators; earnings popups remain separate. Reduced Motion limits travel; Reduced Effects uses fewer drops without changing rewards or budgets. Normal pooled juice restores its red material on reuse. Inspected archive captures `65`/`67`, actual Golden Tomato `68`, fragment study `69` and tumbling split `70`. Dummy audio validates loading/dispatch only; native Forward+, audible quality, final hand refinement and supported-PC performance remain unverified.

## Tomato Stampede (v0.11)
The event uses the existing original eligible normal tomato models and seeded fragment sets at **68%** of their usual scale, including matching circle radii or transformed Roma hulls and lower family mass. It adds an actual fan of six to twelve specimens; it is not counted as a new normal variety or a new Blender model. Each specimen retains its variety silhouette, interior, quality and independent family ledger. Positions span the cutting board, with small vertical staggering and varied real launch velocities. All previous Blender/GLB sources remain unchanged.

`tools/build_event_art.py` additionally authors `assets/illustrations/prestige/stampede.svg`: an engraved basket releasing a fan of small botanical specimens, in the established cream/ink/sage/terracotta/gold family. The real Stampede Season unlock and its frequency/size/reward successors use it in Special Events. New entries retain clipped-title discovery, botanical vines, unread indicators, current/next effects and scroll retention; their actions fit 16:10 and 16:9. No manual variety picker or empty event category is added.

The original short `stampede.wav` cue and local textual wave count identify an automatic arrival; individual wave launches do not stack a launch cue for every fruit. Cuts use the actual equipped knife sound and normal pooled red juice. Effects and fragments retain the shared budgets; Reduced Effects limits drops and Reduced Motion/disabled Damage Indicators preserve gameplay. The kitchen camera remains fixed. Reviewed actual archive, wave, separated seeded fragments and results in captures `72`–`77`. Software OpenGL/Dummy audio validate presentation paths only; native Forward+, listening, supported-PC performance and final hand refinement remain separate production gates.

## Very official printed controls (v0.12, requested UI pass)
All button surfaces now belong to the same original culinary print family. Primary actions use tomato-red chamfered tickets with a cream tomato seal, engraved double rules, a restrained arrow, serif lettering and offset ink shadow. Cultivation uses sage paper order slips with a dark botanical seal rail and a perforated end. Secondary actions use cream clipped-paper labels; selected tabs/products use a printed corner marker and gold underline. Navigation remains the original line-icon family, now on small stamped tiles, with a visible current-page underline. The playful seal gives the institution a little absurd self-importance without obscuring labels or prices.

`tools/build_button_art.py` authors **23 original SVGs** under `assets/illustrations/buttons/`: four states for five surface roles, a shared dotted focus frame and check/dash preference marks. `PrintedButtons` installs native Godot nine-slice StyleBoxTexture variants. Corner geometry, seals and typography retain their insets as controls grow; decoration does not become another input layer. Hover/pressed/hover-pressed, disabled and keyboard-focus states are explicit. All assets are used by the real home/results, seed catalog, equipment/preparation, archive, settings and confirmation controls. No external icon pack or replacement gameplay model is used.

Primary labels keep their clear action wording. Costs/effects and reset consequences remain visible; selected entries do not grant ownership. Preference marks differ by shape as well as color. Native keyboard activation, focus, disabled transactions and one-second navigation tooltips remain functional. Selected equipment-section tiles now identify the current knife/preparation page. Preferences have enough internal padding and footer clearance. Motion is limited to a printed pressed impression; no tween, camera movement or extra Reduced Motion exception is introduced.

Inspected actual 16:10/16:9 home, hover/focus, disabled/affordable cultivation, preferences, equipment and archive captures `78`–`85`. This completes the requested shared control pass; final whole-game art/audio/hardware polish remains in the roadmap. Original fruit/knife/fragment Blender and GLB assets, SVG specimen plates and audio are preserved.
