# TOMATO CUT
## Complete Game Design, Art Direction & Development Specification
### Master Development Prompt for ChatGPT Codex

---

# 1. PROJECT OVERVIEW

Build **Tomato Cut**, a complete, polished Windows PC game developed in Godot 4.x using GDScript.

Tomato Cut is a visually distinctive arcade-incremental game centered on one deceptively simple activity: slicing tomatoes.

The player begins with a rusty butter knife, a ten-second round, and a single ordinary tomato launching into the air every four seconds.

Moving the mouse sweeps the knife across airborne tomatoes. Successful cuts produce satisfying physical separation, juicy effects, and monetary rewards.

Players spend their earnings on upgrades, additional tomato varieties, better knives, special cutting abilities, and eventually permanent prestige progression.

Over time, a humble kitchen experiment becomes an increasingly absurd tomato-cutting operation involving premium heirlooms, legendary kitchen equipment, and rare special events.

The game must combine a simple, immediately enjoyable action with substantial long-term progression.

**Build a fully playable game, not a concept demo or an attractive interface with incomplete gameplay.**

## Core Design Principles

1. **Simple to learn:** Move the mouse, slice tomatoes, earn money, upgrade.
2. **Exceptionally satisfying:** Cutting tomatoes must feel responsive, tactile, and rewarding.
3. **Deep progression:** Provide meaningful upgrades, equipment, tomato varieties, and prestige systems.
4. **Distinctive visual identity:** Stylized 2.5D gameplay paired with vintage botanical and culinary illustrations.
5. **Clean interface:** Icon-first navigation, progressive content discovery, and minimal clutter.
6. **Professional execution:** Cohesive assets, reliable systems, balanced economy, and stable performance.
7. **Playful personality:** Treat an absurd subject with the presentation of an unusually prestigious culinary institution.

Avoid generic mobile-game graphics, unnecessary mechanics, overwhelming effects, and repetitive menu interactions.

The game should be funny without relying on constant jokes or dialogue.

---

# 2. TECHNICAL REQUIREMENTS

Use the following architecture.

| Component | Requirement |
|---|---|
| Game engine | Godot 4.x |
| Programming language | GDScript |
| Platform | Windows PC |
| Rendering | Forward+ 3D |
| Visual presentation | Stylized 2.5D |
| Camera | Fixed orthographic |
| Tomatoes | Stylized low/mid-poly 3D models |
| Knives | Unique 3D models with blade-specific collision |
| Gameplay physics | Controlled 2D-plane movement with 3D presentation |
| Cutting | Swept blade detection and convincing fragment separation |
| Effects | Godot particles, shaders, procedural trails |
| Interface | Godot Control nodes with custom 2D artwork |
| Modeling | Blender |
| Model format | glTF / GLB |
| Controls | Mouse-first |
| Performance | Target stable 60 FPS on supported Windows PCs |
| Save system | Local, persistent, versioned saves |

Use native Godot systems wherever practical.

Do not introduce unnecessary plugins or external dependencies.

Keep the project modular, well-organized, and suitable for continued development in VS Code.

## Gameplay Plane

Although tomatoes and knives are 3D objects, gameplay should take place primarily on one fixed plane.

Tomatoes launch into the visible playfield, follow gravity-driven arcs, and fall downward.

The knife follows mouse movements across this same plane.

Detached fragments may tumble in 3D, providing visual depth without complicating player controls.

The camera must remain fixed, except for extremely limited special-event feedback.

Physics and cutting calculations must remain independent of decorative camera movement.

## Resolution and Scaling

Support common desktop aspect ratios, including 16:9 and 16:10.

Use responsive UI anchors and containers.

The gameplay field, timer, navigation controls, and results must remain readable at different resolutions.

Avoid stretched models, distorted icons, or cropped catalog controls.

---

# 3. VISUAL ART DIRECTION

Tomato Cut should resemble an unusually beautiful indie game about a ridiculous subject.

The defining aesthetic is:

**Stylized 3D culinary arcade gameplay combined with luxurious, vintage illustrated interfaces.**

Three visual systems must work together.

## A. Tomatoes and Knives

Use stylized 3D models with:

- Exaggerated but recognizable proportions.
- Rich, tactile materials.
- Soft highlights.
- Subtle surface imperfections.
- Warm, appealing lighting.
- Clear silhouettes.
- Convincing physical reactions.
- Distinctive shapes for each variety or equipment type.

Tomatoes should not be identical spheres with recolored textures.

Knives should not be flat pictures floating over 3D tomatoes.

Each should feel like a carefully modeled physical object.

## B. Menus and Progression

Use illustrated artwork inspired by:

- Vintage botanical seed catalogs.
- Mid-century culinary advertisements.
- Horticultural field guides.
- Premium knife catalogs.
- Printed agricultural packaging.
- Illustrated cookbooks.

The interface should combine aged-paper textures, botanical illustrations, elegant typography, product labels, and subtle decorative elements.

These references must inform an original visual language rather than result in copied artwork.

## C. Gameplay Effects

Use expressive but controlled visual feedback:

- Juicy splashes.
- Knife trails.
- Tomato fragments.
- Subtle squash-and-stretch.
- Animated money rewards.
- Brief impact emphasis.
- Premium variety effects.
- Special-event animations.

Avoid excessive particles, large explosions after every cut, or effects that hide targets.

## Color Palette

Use a restrained but inviting palette:

**Primary**

- Tomato red.
- Warm cream.
- Botanical green.
- Muted yellow.
- Charcoal.
- Brushed steel.

**Secondary**

- Golden yellow.
- Heirloom purple.
- Soft orange.
- Pale mint.
- Warm pink.

The gameplay scene should be vivid.

Menus should be more restrained, resembling expertly printed vintage publications.

## Material Standards

Tomato exteriors require appealing skins, subtle roughness variation, small imperfections, and variety-specific coloring.

Cut interiors require appropriate flesh, seed chambers, and moist surfaces.

Knife materials should suggest steel, ceramic, wood, plastic, gold, or futuristic materials as appropriate.

Do not make everything uniformly glossy or plastic-like.

---

# 4. CORE GAMEPLAY

## Starting Conditions

A new save begins with:

| Attribute | Value |
|---|---|
| Round duration | 10 seconds |
| Launch interval | 4 seconds |
| Tomatoes per launch | 1 |
| Available variety | Standard Red |
| Equipped knife | Rusty Butter Knife |
| Maximum rewarded cuts per tomato | 1 |
| Standard cut reward | $1 |
| Starting balance | $0 |
| Prestige currency | 0 Tomato Seeds |
| Special tomato events | All locked |

The player presses Play and begins slicing airborne tomatoes.

A successful cut awards money.

The round ends when the timer expires.

A results screen appears, showing earnings and performance.

The player can immediately play again or visit the catalog, shop, or prestige screen.

## Main Loop

**PLAY → SLICE → EARN → UPGRADE → REPEAT**

Long-term progression adds:

**PRESTIGE → PERMANENT IMPROVEMENTS → NEW EVENTS → FASTER PROGRESSION**

The game must always provide a clear next goal.

## Round Results

Display:

- Money earned.
- Tomatoes successfully sliced.
- Total rewarded cuts.
- Best combo.
- Bonus earnings.
- Current balance.

Use a brief, satisfying results animation.

The Play Again action should be prominent and immediately accessible.

## Timer Behavior

The timer appears at the top center of gameplay.

Format:

**00:10.0**

During the final three seconds, provide a subtle visual and audio warning.

Do not use camera shake for the countdown.

When the timer expires, stop new launches and cleanly finalize active interactions.

Save the result automatically.

---

# 5. MOUSE-CONTROLLED SLICING

The cutting mechanic is the highest development priority.

It must feel excellent before building the full progression system.

## Knife Control

The mouse directly controls the knife.

The knife should:

- Follow the cursor responsively.
- Orient naturally toward movement direction.
- Use cutting geometry matching its visible blade.
- Detect fast movements reliably.
- Avoid noticeable input lag.
- Support different knife shapes.
- Provide immediate cutting feedback.

Avoid excessive interpolation that causes the blade to trail behind the mouse.

## Cut Detection

Implement swept collision detection using previous and current blade positions.

A cut occurs when the effective cutting region crosses a valid tomato target.

Requirements:

- Fast swipes must register.
- Stationary overlapping must not repeatedly cut.
- One swipe must not generate duplicate rewards.
- Cut strength must consider knife and upgrade properties.
- Tomato durability must be evaluated.
- Cuts should visually correspond to the blade trajectory.

## 3D Tomato Separation

Implement a reliable hybrid slicing system.

### Initial Production Approach

Create prepared 3D fragment configurations for each tomato variety.

These should include appropriate halves, wedges, and smaller chopped pieces, with detailed interior surfaces.

When sliced:

1. Identify the cut trajectory.
2. Determine whether the cut succeeds.
3. Select an appropriate fragment configuration.
4. Orient fragments to approximate the cut.
5. Apply separation forces.
6. Display interior flesh and seeds.
7. Generate juice and particle effects.
8. Play the knife-specific cutting sound.
9. Award money.

Use prepared fragments if they deliver better reliability and performance than runtime mesh destruction.

### Optional Advanced Approach

Implement true runtime mesh cutting only after the core game is stable.

This would require mesh intersection, surface capping, interior materials, collision generation, and fragment physics.

Do not sacrifice responsiveness or visual quality to achieve mathematically exact slicing.

If using prebuilt fragments, do not misrepresent them as exact arbitrary-plane geometry.

## Multiple Cuts

Initially, a tomato allows one rewarded cut.

Upgrades increase its maximum rewarded cuts.

A piece may be sliced again until the configured limit or minimum fragment size is reached.

At very small sizes, further cuts should create juice and lightweight visual debris rather than dozens of additional physics bodies.

## Durability

Durability represents resistance to cutting.

A Standard Red Tomato is easy to slice.

Larger or premium varieties may need greater sharpness or multiple strikes.

Durability and maximum rewarded cuts are separate attributes.

Successful damage that does not yet split a tomato should have a clear but restrained visual response.

---

# 6. TOMATO PHYSICS AND ANIMATION

Tomatoes use stylized 3D physics presentation.

Each variety has configurable:

- Size.
- Mass.
- Launch velocity.
- Angular velocity.
- Gravity behavior.
- Durability.
- Collision geometry.
- Reward value.
- Special characteristics.

Movement should feel slightly exaggerated but predictable enough for skillful slicing.

## Variety-Specific Behavior

Cherry Tomatoes should be small, fast, and energetic.

Roma Tomatoes should have elongated silhouettes and tumble end-over-end.

Beefsteak Tomatoes should be large, heavy, and dramatic.

Irregular heirlooms should have varied shapes and asymmetrical tumbling.

Cut fragments should retain convincing momentum and separate naturally.

Do not allow visual depth motion to cause mismatches with cutting detection.

## Animation Personality

Use restrained squash-and-stretch, subtle launch wobble, natural rotation, and expressive fragment physics.

Large tomatoes may have a brief launch anticipation.

Special events can have more dramatic animations, but ordinary tomatoes should not create distracting spectacle.

---

# 7. GAME FEEL AND SCREEN EFFECTS

The game should achieve satisfying feedback through object animation, sound, and particles—not constant camera movement.

## Cutting Feedback Sequence

A successful cut should produce:

1. Immediate hit confirmation.
2. A crisp cutting sound.
3. A very brief impact emphasis when appropriate.
4. Fragment separation.
5. Juice particles.
6. A money popup.
7. Natural fragment motion.

The sequence must feel responsive even when many cuts occur rapidly.

## Screen Shake Policy

**Screen shake must be extremely limited.**

Never shake the screen for:

- Ordinary cuts.
- Routine combos.
- Knife movement.
- Money rewards.
- Upgrade purchases.
- Normal menu interactions.
- Regular tomato launches.

Allow subtle shake only for rare dramatic events such as slicing an enormous prestige tomato or triggering an especially powerful legendary effect.

Recommended upper limits at reference resolution:

- Maximum displacement: 2–3 screen pixels.
- Maximum duration: 0.10–0.15 seconds.
- Minimum interval: 2 seconds between shake events.

Screen shake should be disabled during menus.

Use a default Low setting and an Off option.

Reduced Motion must disable it automatically.

Camera feedback must never affect knife collision accuracy.

## Preferred Feedback Alternatives

Use:

- Short localized flashes.
- Tomato squash-and-stretch.
- Distinctive cut sounds.
- Fragment impulses.
- Subtle impact pauses.
- Controlled knife trails.
- Particle bursts.
- Animated rewards.

Provide limits so late-game effects remain readable.

---

# 8. PROGRESSION SYSTEM

The game should have substantial depth without requiring complicated controls.

Standard progression consists of seven major upgrade categories:

1. Time.
2. Tomato Production.
3. Cutting Power.
4. Money.
5. Combos.
6. Special Cutting Abilities.
7. Tomato Varieties & Harvest Quality.

All standard upgrades are purchased using money earned during rounds.

Upgrade effects must be implemented, not merely described.

## Upgrade Data

Each upgrade should define:

- Unique identifier.
- Display name.
- Description.
- Category.
- Maximum level.
- Base price.
- Price growth rate.
- Gameplay effect.
- Reveal prerequisites.
- Purchase requirements.
- Required prerequisite levels.
- Illustration or icon.
- Progression connections.

The same data must drive gameplay calculations, UI descriptions, purchase eligibility, and saving.

Avoid duplicate hard-coded values across multiple scripts.

---

# 9. UPGRADE CATEGORIES

## A. TIME

| Upgrade | Effect |
|---|---|
| Extra Seconds | Adds round time |
| Overtime | Adds time after cutting milestones |
| Clock Stretch | Slightly extends effective time during combos |
| Last Second Hero | Rewards critical final-second cuts with time |
| Tomato Time | Occasionally awards bonus seconds |
| Extended Shift | Raises maximum round duration |
| Second Wind | Grants a limited additional time extension |

Time upgrades should make rounds more productive without allowing excessively long sessions.

## B. TOMATO PRODUCTION

| Upgrade | Effect |
|---|---|
| Faster Throwing | Reduces launch interval |
| Double Toss | Adds tomatoes per launch |
| Tomato Rain | Occasionally adds extra waves |
| Kitchen Chaos | Increases simultaneous tomatoes |
| Tomato Cannon | Improves launch frequency |
| Overflowing Basket | Periodically adds bonus tomatoes |
| Tomato Storm | Creates occasional larger groups |
| Endless Harvest | Improves late-game production |

Balance production around player readability and technical performance.

## C. CUTTING POWER

| Upgrade | Effect |
|---|---|
| Extra Cuts | Increases rewarded cuts per tomato |
| Sharp Edge | Improves cutting strength |
| Blade Reach | Increases effective cutting reach |
| Clean Cuts | Rewards centered cuts |
| Precision | Improves clean-cut tolerance |
| Double Slice | Chance for an additional rewarded cut |
| Tomato Shredder | Improves effectiveness against large tomatoes |
| Razor Finish | Rewards complete slicing |

Knife geometry and tomato durability must remain relevant.

## D. MONEY

| Upgrade | Effect |
|---|---|
| Better Prices | Raises base cutting value |
| Premium Produce | Improves valuable tomato payouts |
| Combo Cash | Improves combo earnings |
| Juicy Profits | Chance for additional money |
| Golden Harvest Bonus | Improves Golden Tomato event payouts once unlocked |
| Perfect Slice | Rewards accurate cuts |
| Bulk Buyer | Rewards high-volume rounds |
| Tomato Economics | Improves general earnings |

Event-specific effects cannot unlock events.

## E. COMBOS

| Upgrade | Effect |
|---|---|
| Combo Window | Extends combo timing |
| Combo Multiplier | Increases combo rewards |
| Slice Streak | Rewards consecutive cuts |
| Tomato Frenzy | Temporarily increases production |
| Momentum | Rewards sustained slicing |
| Crowd Pleaser | Improves large-combo bonuses |

Combos should reward skill without becoming mandatory for progression.

## F. SPECIAL CUTTING ABILITIES

| Upgrade | Effect |
|---|---|
| Juice Explosion | Chance to affect nearby tomatoes |
| Chain Reaction | Chance for one cut to trigger another |
| Slow Motion | Briefly slows tomato movement |
| Critical Slice | Chance for increased cutting damage |
| Tomato Magnet | Gently improves target accessibility |
| Blade Echo | Creates a temporary secondary cutting trail |
| Tomato Fireworks | Chance for bonus rewards |
| Perfect Storm | Improves cutting-effect activation |

These abilities activate automatically.

They must not require additional keyboard inputs or complicated management.

**Normal cutting abilities are distinct from prestige-exclusive special tomato events.**

## G. TOMATO VARIETIES & HARVEST QUALITY

Every normal tomato variety has a dedicated progression branch.

Each branch includes:

**Variety Unlock** — Makes the variety available to spawn.

**Harvest Frequency** — Increases its relative spawn probability.

**Premium Quality** — Increases its reward value.

**Harvest Dominance** — Gradually reduces the presence of lower-tier varieties.

**Variety Mastery** — Provides optional variety-specific benefits.

These upgrades appear in the illustrated seed catalog, not the equipment shop.

---

# 10. THE ILLUSTRATED SEED CATALOG

The seed catalog is one of Tomato Cut's signature features.

Do not use a conventional futuristic skill tree or generic grid of upgrade cards.

Instead, create a large, beautifully illustrated botanical catalog that expands as the player progresses.

## Visual Design

Use:

- Cream-colored paper.
- Botanical drawings.
- Elegant printed labels.
- Deep green decorative lines.
- Tomato-red accents.
- Vintage catalog numbers.
- Illustrated vines and stems.
- Small specimen notes.
- Restrained animations.

The catalog should feel like a carefully printed horticultural publication.

## Upgrade Presentation

Each upgrade appears as a catalog entry.

An entry should display:

- Illustration or icon.
- Upgrade name.
- Current level.
- Next-level effect.
- Purchase price.
- Purchase eligibility.
- Maximum-level state.

Use clear interactive controls.

Decoration must never obscure information.

## Tomato Variety Pages

Each tomato variety should have a distinctive illustrated specimen entry.

Include:

- Botanical illustration.
- Variety name.
- Catalog number.
- Short description.
- Unlock status.
- Reward value.
- Durability.
- Movement properties.
- Current spawn probability.
- Connected upgrade branches.

Connected progression paths should resemble botanical vines, stems, or printed diagram lines.

The catalog should feel alive as the player discovers new varieties.

## Catalog Sections

Organize the seven upgrade categories into separate navigable sections.

Use compact illustrated category icons.

Display only the selected category or focused branch rather than showing every upgrade simultaneously.

Support scrolling, controlled pan/zoom where needed, and a reset-view control.

Use stable node positioning so the catalog does not constantly rearrange as upgrades become visible.

---

# 11. PROGRESSIVE UPGRADE REVEALS

**Do not display the complete upgrade tree at the beginning of the game.**

Players should gradually discover upgrades as they purchase prerequisites.

This is a mandatory design rule.

## Starting Visibility

A new save should show a small number of introductory upgrades.

Recommended:

- Extra Seconds.
- Faster Throwing.
- Better Prices.
- Sharp Edge.

The starting Standard Red Tomato entry should also be available.

All advanced upgrades remain hidden until reveal conditions are met.

## Visibility States

Each upgrade has three primary states.

**Hidden:** Prerequisites have not been met. Do not render the upgrade or its details.

**Revealed:** Reveal conditions have been met. Display the upgrade, even if it is currently unaffordable.

**Purchased:** At least one level has been purchased. Show current level, next cost, and effects.

Maximum-level upgrades display a completion state.

## Reveal Conditions

An upgrade can require:

- Purchase of another upgrade.
- A specified level of another upgrade.
- Several prerequisite upgrades.
- A tomato variety unlock.
- A progression milestone.
- A prestige milestone.

Some upgrades may reveal one successor.

Others may reveal two or three branches.

Avoid an entirely linear progression path.

The player should usually have several meaningful choices.

## Example

**Faster Throwing**

After reaching its required level, reveal:

- Double Toss.
- Tomato Rain.

Further progression reveals:

- Kitchen Chaos.
- Tomato Cannon.

Newly revealed upgrades should appear near their prerequisite entries.

## Reveal Animation

Use a brief, elegant botanical animation:

- Connecting vine extends.
- New illustration appears.
- Printed label fades in.
- Subtle discovery sound plays.

Never use screen shake for upgrade reveals.

## Hidden Layout Behavior

Hidden upgrades must not create enormous empty spaces.

Keep branch layouts stable but compact.

New entries should expand the visible catalog naturally.

Use a small discovery indicator on a category icon when a newly revealed upgrade has not yet been viewed.

Do not use excessive notifications.

## Visibility Persistence

During a normal prestige cycle, revealed entries remain revealed once discovered.

When the player prestiges, normal-run discovery resets alongside normal upgrades.

Prestige-tree discovery remains permanent as appropriate.

Reconstruct visibility from saved progression and discovery data.

---

# 12. TOMATO VARIETIES

Implement 25 normal tomato varieties.

Each must have its own stylized 3D model, recognizable properties, and illustrated catalog entry.

| Variety | Gameplay Character |
|---|---|
| Standard Red | Balanced starter |
| Cherry | Tiny and fast |
| Grape | Small, elongated, quick |
| Roma | Firm, oval, durable |
| Campari | Medium, consistent rewards |
| Cocktail | Small and lively |
| Plum | Compact, resistant |
| Beefsteak | Large, heavy, valuable |
| Big Boy | Large and tough |
| Better Boy | Strong premium payout |
| Early Girl | Fast-moving and frequent |
| Celebrity | Reliable combo potential |
| Brandywine | Large premium heirloom |
| Cherokee Purple | Dark, valuable heirloom |
| Black Krim | Rich-colored premium variety |
| Green Zebra | Striped, irregular movement |
| Yellow Pear | Small, unusual silhouette |
| Sungold | Bright golden cherry variety |
| Sweet 100 | Appears in small groups |
| San Marzano | Elongated, precision-oriented |
| Mortgage Lifter | Extremely large and valuable |
| Pineapple | Large yellow-red heirloom |
| Indigo Rose | Dark, rare premium tomato |
| Oxheart | Heart-shaped, heavy |
| Costoluto Genovese | Deeply ribbed, irregular |

Assign each tomato:

- Progression tier.
- Reward value.
- Size and mass.
- Durability.
- Launch behavior.
- Rotation characteristics.
- Base spawn weight.
- Fragment configurations.
- Exterior and interior materials.

All normal varieties unlock through their own seed catalog branches.

Do not place tomatoes in the shop.

## Progressive Discovery

Do not reveal all 25 varieties immediately.

Begin with Standard Red.

Early purchases reveal introductory varieties such as Cherry and Roma.

Further progression reveals larger and more valuable tomatoes.

Use a branching dependency structure so multiple progression paths can be explored.

Do not allow a purely cosmetic catalog reveal to unlock a tomato for spawning; its actual Variety Unlock upgrade must be purchased.

---

# 13. AUTOMATIC TOMATO SPAWN PROGRESSION

The player cannot manually select which tomato varieties appear.

The game calculates the spawn distribution from purchased upgrades.

## Mandatory Rules

1. Only purchased, unlocked varieties can spawn.
2. Harvest Frequency increases relative spawn probability.
3. Premium Quality increases monetary value.
4. Harvest Dominance reduces lower-tier spawn probability.
5. Less profitable varieties are gradually phased out.
6. Lower-tier spawn probability may eventually reach zero.
7. The system always retains valid spawn candidates.
8. Normal variety progression resets on prestige.

## Example Distribution

Initially:

| Variety | Spawn Share |
|---|---:|
| Standard Red | 100% |

After unlocking and upgrading Cherry:

| Variety | Spawn Share |
|---|---:|
| Standard Red | 45% |
| Cherry | 55% |

After investing in higher-tier varieties:

| Variety | Spawn Share |
|---|---:|
| Standard Red | 5% |
| Cherry | 20% |
| Roma | 30% |
| Beefsteak | 45% |

Eventually, Standard Red may disappear entirely.

These are illustrative distributions, not fixed scripted stages.

## Spawn Calculation

Use normalized weighted selection based on:

- Unlocked status.
- Base spawn weight.
- Frequency upgrade levels.
- Dominance effects.
- Progression tier.
- Configurable balance modifiers.

Use expected earning potential and tomato durability to prevent the mix from advancing into varieties the player cannot realistically slice.

## Interface

The seed catalog should display current calculated spawn percentages.

These values are read-only.

Do not provide:

- Tomato enable/disable toggles.
- Spawn percentage sliders.
- Manual favorite selections.
- Custom tomato loadouts.
- Shop purchases that alter the mix directly.

The player's upgrade investments determine the harvest automatically.

---

# 14. THE CULINARY EQUIPMENT SHOP

The shop should resemble a premium, slightly absurd culinary equipment catalog.

It should look related to the seed catalog but more luxurious.

## Shop Categories

- Knives.
- Knife Modifications.
- Cosmetics.

**No tomatoes are sold in the shop.**

## Presentation

Each item should have:

- Large rotating 3D preview.
- Product name.
- Catalog number.
- Purchase price.
- Statistics.
- Special effect.
- Short humorous description.
- Purchase or Equip control.

Example:

**THE RUSTY BUTTER KNIFE**

*Catalog No. 001*

"Once considered suitable for spreading butter. Now entrusted with the future of tomato civilization."

Sharpness: Terrible  
Reach: Short  
Precision: Questionable  
Special: None

The humor should be subtle and consistent.

---

# 15. KNIFE COLLECTION

Implement 25 distinct knives.

| Knife | Main Characteristic |
|---|---|
| Rusty Butter Knife | Weak starting equipment |
| Plastic Picnic Knife | Slight reach improvement |
| Steak Knife | Improved cutting strength |
| Paring Knife | Precision |
| Utility Knife | Balanced |
| Santoku | Combo bonuses |
| Chef's Knife | Strong general-purpose performance |
| Cleaver | Heavy cutting power |
| Bread Knife | Serrated durability damage |
| Fillet Knife | High precision |
| Nakiri | Vegetable specialist |
| Chinese Cleaver | Broad cutting area |
| Butcher Knife | Heavy-duty slicing |
| Damascus Chef Knife | Premium balanced performance |
| Ceramic Knife | Critical slice bonus |
| Carbon Steel Knife | Cutting efficiency |
| Sushi Knife | Long, precise blade |
| Industrial Slicer | Multiple-cut effects |
| Pizza Cutter | Circular cutting behavior |
| Electric Carving Knife | Rapid cutting effects |
| Golden Chef Knife | Money multiplier |
| Diamond-Edge Knife | Exceptional cutting power |
| Laser Kitchen Knife | Glowing advanced blade |
| Molecular Blade | Advanced cutting effects |
| The Final Knife | Legendary late-game equipment |

Each knife requires:

- Unique 3D model.
- Correct blade geometry.
- Appropriate cutting collision.
- Distinct materials.
- Equipment statistics.
- Purchase price.
- Visual identity.
- Special ability where specified.

## Knife Statistics

Use four easy-to-understand attributes:

**Sharpness:** Cutting effectiveness.  
**Reach:** Blade coverage.  
**Precision:** Clean-cut effectiveness.  
**Special:** Unique passive behavior.

Knife modifications may improve these values.

Purchased knives and modifications reset on prestige unless a separately defined permanent upgrade explicitly changes that rule.

---

# 16. THE PRESTIGE SYSTEM

Prestige provides long-term progression.

The player eventually resets their current run in exchange for permanent currency:

**TOMATO SEEDS**

Prestiging should create a meaningful sense of increased power on subsequent runs.

## Prestige Currency

Calculate Tomato Seeds from qualifying earnings accumulated during the current prestige cycle.

Use diminishing returns.

An initial formula may be:

`Seeds = floor((RunEarnings / PrestigeThreshold) ^ 0.45)`

Tune through gameplay simulation.

Do not allow repeated resets to claim the same earnings twice.

The first prestige opportunity should initially target approximately 60–90 minutes of normal play, subject to balancing.

## Prestige Resets

Prestige resets:

- Current money.
- Standard upgrades.
- Normal tomato unlocks.
- Harvest Frequency.
- Premium Quality.
- Harvest Dominance.
- Purchased knives.
- Knife modifications.
- Normal catalog reveal progress.

Prestige preserves:

- Tomato Seeds.
- Permanent prestige upgrades.
- Special-event unlocks.
- Special-event prestige upgrades.
- Achievements.
- Lifetime statistics.
- Cosmetic unlocks.
- Settings.
- Appropriate persistent mastery progress.

Clearly display reset consequences before confirmation.

## Prestige Presentation

Use an illustrated rare-seed archive with:

- Botanical envelopes.
- Golden accents.
- Cream paper.
- Decorative seals.
- Premium typography.
- Connected botanical progression.

Use the same progressive discovery system as the standard seed catalog.

Do not display every prestige upgrade immediately.

## Prestige Branches

### Permanent Wealth

- Starting Cash.
- Permanent Slice Value.
- Prestige Profit Multiplier.
- Premium Tomato Rewards.
- Combo Profit Bonus.
- Compound Harvest.

### Permanent Production

- Faster Starting Throws.
- Additional Starting Tomatoes.
- Spawn Capacity.
- Bonus Tomato Chance.
- Harvest Efficiency.
- Starting Production Boost.

### Permanent Cutting

- Starting Sharpness.
- Blade Reach.
- Starting Extra Cuts.
- Precision.
- Critical Slice Chance.
- Durable Tomato Damage.
- Chain Reaction Chance.

### Permanent Time

- Starting Round Time.
- Overtime Bonus.
- Timer Efficiency.
- Combo Time Extension.
- Second Wind.
- Maximum Round Duration.

### Permanent Harvest

- Reduced Variety Unlock Costs.
- Improved Premium Value.
- Harvest Frequency Efficiency.
- Stronger Harvest Dominance.
- Faster Variety Progression.
- Tomato Mastery Bonuses.

These upgrades improve normal progression without automatically granting every tomato variety.

### Special Tomato Events

Contains all event unlocks and event-specific improvements.

---

# 17. PRESTIGE-EXCLUSIVE SPECIAL TOMATO EVENTS

Special tomato events must initially be locked.

**An event cannot occur until the player purchases its dedicated permanent prestige unlock.**

Normal tomato unlocks and regular cutting abilities must not activate special events.

## Golden Tomato

**Unlock: Golden Harvest**

A rare glowing golden tomato appears, awarding a large payout.

Possible permanent upgrades:

- Golden Frequency.
- Golden Value.
- Golden Multipliers.
- Golden Jackpot.

## Tomato Stampede

**Unlock: Stampede Season**

A large wave of smaller tomatoes enters the playfield.

Possible upgrades:

- Larger Stampedes.
- Increased Frequency.
- Stampede Rewards.
- Combo Bonuses.

## The Big One

**Unlock: Giant Harvest**

An enormous durable tomato appears.

It has dramatic movement and unusually high rewards.

Possible upgrades:

- Giant Frequency.
- Giant Rewards.
- Giant Weak Points.
- Giant Bonus Cuts.

## Rainbow Harvest

**Unlock: Heirloom Celebration**

A colorful wave of premium tomatoes appears.

Possible upgrades:

- Rainbow Frequency.
- Rainbow Rewards.
- Extended Harvest.
- Heirloom Multiplier.

## Tomato Jackpot

**Unlock: Jackpot Harvest**

An exceptionally rare tomato appears with a very large payout.

Possible upgrades:

- Jackpot Frequency.
- Jackpot Multiplier.
- Jackpot Duration.
- Ultimate Jackpot.

## Event Requirements

- Events activate automatically during rounds.
- Locked events have zero activation probability.
- Unlocks are permanent.
- Event-specific improvements reveal only after their unlock prerequisites.
- Effects are distinctive but not visually overwhelming.
- Events respect spawn and particle limits.

Ordinary Sungold Tomatoes and Golden Tomato events are separate systems.

Ordinary Beefsteak Tomatoes and The Big One event are separate systems.

---

# 18. ICON-FIRST INTERFACE DESIGN

Use icons for familiar, frequently accessed actions rather than spelling out every button's purpose.

The interface should feel modern, clear, and minimally cluttered while retaining the illustrated culinary aesthetic.

## Navigation Icons

| Action | Icon Direction |
|---|---|
| Play | Triangle |
| Upgrades | Seed packet or sprout |
| Shop | Knife or equipment bag |
| Prestige | Golden seed |
| Settings | Gear |
| Achievements | Trophy |
| Statistics | Chart |
| Back | Left arrow |
| Home | House |
| Close | X |
| Information | Circled information symbol |
| Equip | Checkmark |

Create a consistent original icon family.

Avoid mixing emojis, inconsistent icon styles, and generic placeholder graphics.

## Important Exceptions

Keep visible text for:

- Prices.
- Upgrade names and effects.
- Item information.
- Confirmation dialogs.
- Irreversible actions.
- Prestige reset warnings.
- Actions whose meaning is ambiguous.

The UI should be icon-first, not icon-only.

## Results Screen

Keep **Play Again** especially prominent, with both an icon and visible label if needed.

Secondary navigation may use icon-only controls with tooltips.

## Interaction Quality

All interactive icons should have:

- Clear hover feedback.
- Consistent size.
- Comfortable click targets.
- Visible active state.
- Disabled state when appropriate.
- Accessible descriptive names.

Do not use decorative elements that look clickable but have no function.

---

# 19. DELAYED HOVER TOOLTIPS

Icon-only buttons must provide a hover label.

## Exact Behavior

1. Mouse enters an icon button.
2. Button immediately shows a subtle hover state.
3. A one-second delay begins.
4. If the cursor remains over the button for at least one second, a tooltip appears.
5. Tooltip displays the action's name.
6. Tooltip remains while the cursor is over the button.
7. Tooltip disappears immediately when the cursor leaves.

Moving to another button resets the timer.

Clicking or closing the menu dismisses the tooltip.

## Appearance

Tooltips should resemble small printed catalog labels:

- Cream background.
- Thin botanical-green border.
- Compact typography.
- Soft shadow.
- Appropriate padding.

Tooltips must remain within the visible screen.

## Implementation

Create a shared TooltipManager using Godot Control nodes.

It should support:

- Configurable hover delay.
- Immediate dismissal.
- Cursor movement between buttons.
- Automatic positioning.
- Cleanup on menu transitions.
- Optional descriptions for disabled controls.

Critical upgrade details should not depend exclusively on delayed tooltips.

Selected upgrade cards may display their full information immediately in a detail panel.

---

# 20. GAME MENUS AND NAVIGATION

## Main Menu

Display:

**TOMATO CUT**

Use a distinctive stylized 3D tomato and knife presentation.

Primary actions:

- New Game.
- Continue.
- Settings.

Continue should appear only when a valid save exists.

Starting a new game over existing progress requires confirmation.

## Gameplay Screen

Keep the playfield uncluttered.

**Top center:** Round timer.

**Top left:** Current earnings.

**Top right:** Combo counter.

**Center:** Tomatoes and knife interaction.

Use compact navigation controls outside the main cutting area.

## Upgrade Catalog

Show:

- Money balance.
- Category icons.
- Revealed upgrades.
- Botanical connections.
- Purchase prices.
- Levels and effects.
- Newly discovered upgrade indicators.

Display only the active category or selected branch.

## Equipment Shop

Show:

- Knife previews.
- Equipment categories.
- Prices.
- Statistics.
- Purchase/Equip controls.

## Prestige Archive

Show:

- Tomato Seeds.
- Potential prestige reward.
- Revealed permanent upgrades.
- Event unlocks.
- Reset confirmation.

## Navigation Standard

Players should normally be within two interactions of beginning another round.

Avoid unnecessary modal dialogs.

Do not require closing several screens to return to gameplay.

---

# 21. ECONOMY AND BALANCING

The game must have a progression economy that remains rewarding over time.

## Upgrade Pricing

Use configurable exponential pricing.

`Cost = BaseCost × GrowthRate ^ CurrentLevel`

Use different growth rates for different upgrade categories.

Starting examples:

| Upgrade | Base Cost | Growth |
|---|---:|---:|
| Extra Seconds | $3 | 1.18 |
| Better Prices | $5 | 1.22 |
| Faster Throwing | $8 | 1.20 |
| Extra Cuts | $15 | 1.25 |
| Double Toss | $30 | 1.28 |

These figures are provisional.

Balance using actual gameplay data and simulations.

## Progression Targets

**First 2 minutes**

Learn slicing and purchase several upgrades.

**First 10 minutes**

Unlock an additional tomato variety and improve equipment.

**First 30 minutes**

Explore several upgrade branches, increase production, and encounter higher-value tomatoes.

**First 60–90 minutes**

Approach the first prestige opportunity.

**After Prestige**

Restart with enough permanent bonuses to feel noticeably more powerful.

## Tomato Economy

Higher-value tomatoes should provide meaningful profit improvements.

Harvest Dominance should become expensive because it changes the overall earning potential of the spawn pool.

Durability must be considered when balancing tomato value.

The best nominal payout should not automatically produce the best real earnings if the tomato is difficult to slice.

## Late-Game Scaling

Avoid unlimited growth in simultaneous physics objects.

When scene density approaches technical limits, later production upgrades may increase aggregate rewards or batch values rather than endlessly creating more physical tomatoes.

## Number Formatting

Use readable abbreviations:

$1,250  
$24.8K  
$3.6M  
$1.2B  
$45.7T

The same formatter should be used across all UI screens.

---

# 22. GAME ENVIRONMENTS

Create six distinct environments.

They should share the same stylized 3D art direction.

## 1. The Humble Kitchen

Warm, charming, modest, and slightly worn.

## 2. Professional Prep Station

Clean professional culinary equipment and attractive stainless-steel materials.

## 3. Tomato Laboratory

An absurdly scientific setting for an unusually simple task.

## 4. Grand Culinary Arena

A dramatic competition environment.

## 5. The Golden Kitchen

Extravagant and luxurious.

## 6. The Cosmic Cutting Board

A spectacular late-game environment that embraces the absurd premise.

Backgrounds may unlock through progression, achievements, or prestige.

Keep gameplay targets more visually prominent than the environment.

Avoid animated backgrounds that interfere with tracking tomatoes.

---

# 23. SOUND AND MUSIC

Create a cohesive original audio identity.

## Knife Sounds

Different knives should have appropriate effects.

Examples:

- Rusty Butter Knife: dull scrape.
- Chef's Knife: crisp slice.
- Cleaver: heavy chop.
- Ceramic Knife: sharp cut.
- Electric Knife: mechanical buzzing.
- Laser Knife: subtle energy effect.

## Tomato Sounds

Include:

- Wet slicing.
- Juice splashes.
- Soft impacts.
- Fragment movement.
- Large tomato impacts.
- Special event cues.

Use subtle variation to prevent repetitive sounds.

## Interface Audio

Include:

- Button clicks.
- Catalog interactions.
- Purchase confirmations.
- Unlock sounds.
- Rare variety discoveries.
- Prestige effects.

## Music

Use original playful instrumental music.

Potential stylistic influences:

- Light jazz.
- Funk.
- Retro arcade music.
- Quirky synthesizers.
- Playful percussion.

Avoid excessively busy or repetitive arrangements.

Provide independent music and sound-effect volume controls.

---

# 24. ACHIEVEMENTS AND MASTERY

Include achievements that reward progression without becoming mandatory.

Examples:

| Achievement | Requirement |
|---|---|
| First Blood | Slice first tomato |
| Kitchen Apprentice | Slice 100 tomatoes |
| Tomato Menace | Slice 1,000 tomatoes |
| Certified Tomato Problem | Slice 100,000 tomatoes |
| The First Million | Earn $1 million |
| Butter Knife Enthusiast | Reach 100 successful starter-knife cuts |
| Tiny Target | Slice 100 Cherry Tomatoes |
| Absolute Unit | Defeat The Big One |
| The Golden Touch | Slice 100 event Golden Tomatoes |
| Fresh Start | Prestige once |
| Tomato Legend | Prestige ten times |
| Harvest Takeover | Phase out Standard Red |
| Premium Produce Empire | Reach an advanced-variety-only harvest |

Achievements may award cosmetics or modest bonuses.

## Tomato Mastery

Each variety accumulates mastery through successful slicing.

Mastery unlocks passive bonuses or cosmetics.

It must not provide manual spawn controls.

## Knife Mastery

Knives gain experience while equipped.

Mastery provides modest enhancements.

The system should encourage experimenting with equipment without requiring tedious grinding.

---

# 25. SETTINGS AND ACCESSIBILITY

Implement functional settings.

## Graphics

- Fullscreen / Windowed.
- Resolution.
- VSync.
- Quality preset.
- Shadow quality.
- Particle density.
- Lighting quality.
- Reduced Effects.
- Screen Shake: Off / Low.

## Audio

- Master volume.
- Music volume.
- Sound effects volume.

## Gameplay and Accessibility

- Reduced Motion.
- Colorblind-friendly effect options.
- Money popup visibility.
- Damage indicator visibility.
- Cursor/knife visibility adjustments.
- Mouse sensitivity if needed.

Reduced Motion must disable camera shake and reduce unnecessary interface animations.

Do not use color alone to communicate important gameplay information.

Settings must persist.

---

# 26. SAVE SYSTEM

Implement reliable local saving through Godot's user-data directory.

Save automatically:

- After completed rounds.
- After upgrade purchases.
- After tomato unlocks.
- After knife purchases.
- After equipment changes.
- After prestige.
- After special-event unlocks.
- After settings changes.

Store:

- Money.
- Standard upgrades.
- Tomato unlocks.
- Harvest Frequency.
- Premium Quality.
- Harvest Dominance.
- Normal catalog discovery.
- Purchased equipment.
- Equipped knife.
- Prestige currency.
- Prestige upgrades.
- Special-event unlocks.
- Event upgrade levels.
- Persistent mastery.
- Achievements.
- Cosmetics.
- Lifetime statistics.
- Settings.

Use versioned save data.

Validate data when loading.

Handle corrupt or missing saves without crashing.

Avoid silently overwriting valid progress.

Reconstruct the tomato spawn mix automatically from unlocked varieties and purchased upgrades.

Do not store manual tomato spawn selections.

---

# 27. SOFTWARE ARCHITECTURE

Use modular Godot scenes, resources, and scripts.

Recommended responsibilities:

| System | Responsibility |
|---|---|
| GameManager | Overall game state |
| RoundManager | Round lifecycle and timer |
| TomatoSpawner | Automatic tomato launches |
| TomatoController | Tomato movement and attributes |
| SliceSystem | Blade intersection and cut processing |
| KnifeController | Mouse movement and equipment |
| FragmentManager | Cut fragments and cleanup |
| EconomyManager | Rewards, prices, multipliers |
| UpgradeManager | Standard upgrade definitions and levels |
| UpgradeVisibilityManager | Progressive reveal prerequisites |
| TomatoProgressionManager | Varieties, weights, dominance |
| ShopManager | Equipment purchases and inventory |
| PrestigeManager | Resets, seeds, permanent bonuses |
| SpecialEventManager | Prestige-exclusive event activation |
| CatalogUIManager | Illustrated upgrade interface |
| EquipmentCatalogManager | Shop interface and previews |
| TooltipManager | Delayed hover labels |
| CameraFeedbackManager | Limited camera effects |
| SaveManager | Persistent progress |
| AudioManager | Music and sound effects |
| UIManager | Navigation and screen transitions |

Use signals or defined interfaces for communication.

Avoid enormous scripts responsible for unrelated systems.

## Data-Driven Content

Define content using Godot Resources or structured data files.

Separate content definitions from UI and gameplay logic.

Use unique stable IDs for:

- Upgrades.
- Tomato varieties.
- Knives.
- Prestige nodes.
- Special events.
- Achievements.

Validate missing assets, duplicate IDs, invalid prerequisites, and circular upgrade dependencies.

The architecture must support adding content without rewriting entire systems.

---

# 28. ASSET CREATION PIPELINE

Use Blender to create original stylized 3D assets.

Export to Godot as glTF or GLB.

## Tomato Assets

Every variety needs:

- Exterior 3D model.
- Stem geometry.
- Exterior material.
- Interior material.
- Seed details.
- Appropriate collision geometry.
- At least one convincing cutting configuration.
- Additional fragment sets where needed.

## Knife Assets

Every knife needs:

- Unique blade geometry.
- Handle model.
- Appropriate materials.
- Correct pivot.
- Blade collision geometry.
- Shop preview configuration.

## Illustrated UI Assets

Create an original icon and illustration family.

Use the same artistic language across:

- Seed catalog.
- Equipment shop.
- Prestige archive.
- Achievements.
- Settings.
- Results.
- Tooltips.

Do not use inconsistent icon packs or emoji as final graphics.

## Asset Targets

| Category | Target |
|---|---:|
| Tomato models | 25 |
| Knife models | 25 |
| Game environments | 6 |
| Tomato fragment sets | Multiple per variety |
| Standard upgrade icons | 40+ |
| Botanical variety illustrations | 25 |
| Tomato progression icons | 50+ |
| Prestige icons/illustrations | 40+ |
| Achievement illustrations | 20+ |
| Cutting and juice effects | 15+ |
| General interface illustrations | 15+ |
| Special event visual sets | 5+ |

These are intended content goals.

Maintain consistent quality and correct integration.

A smaller set of excellent, functional assets is preferable to a larger set of broken or unrelated files.

## Directory Organization

Use descriptive folders such as:

`assets/models/tomatoes/`

`assets/models/knives/`

`assets/models/fragments/`

`assets/materials/`

`assets/textures/`

`assets/illustrations/catalog/`

`assets/illustrations/equipment/`

`assets/icons/`

`assets/effects/`

`assets/audio/`

`scenes/`

`scripts/`

`data/`

Every asset should be properly referenced and used by the relevant game system.

---

# 29. PERFORMANCE

The game must remain responsive during late-game chaos.

Target stable 60 FPS on supported Windows PCs.

Implement:

- Object pooling.
- Maximum active tomato counts.
- Fragment limits.
- Particle budgets.
- Off-screen cleanup.
- Efficient collision checks.
- Configurable graphics quality.
- Reduced physics complexity when appropriate.
- Visual-only debris where useful.

Do not allow thousands of persistent rigid bodies to accumulate.

As the player advances, progression should increasingly improve profitability rather than producing unlimited visible objects.

Special tomato events must obey the same performance limits.

---

# 30. DEVELOPMENT AND IMPLEMENTATION PLAN

Build the project in stages, but maintain a playable integrated build throughout development.

Do not create all art assets before validating the core gameplay.

## Phase 1 — Vertical Slice

Implement:

- Fixed orthographic camera.
- One polished Standard Red Tomato model.
- One Rusty Butter Knife.
- Mouse-controlled cutting.
- Reliable swept collision.
- Convincing fragment separation.
- Tomato interiors.
- Juice effects.
- Cutting audio.
- Ten-second rounds.
- Earnings.
- Results screen.
- Basic restart.

**Acceptance condition:** Cutting one tomato repeatedly is visually satisfying and technically reliable.

## Phase 2 — Core Incremental Gameplay

Implement:

- Core upgrades.
- Upgrade pricing.
- Round extensions.
- Increased tomato production.
- Multiple cuts.
- Combos.
- Money multipliers.
- Persistent saving.
- Basic economy balancing.

**Acceptance condition:** The player can complete a rewarding upgrade-and-replay loop.

## Phase 3 — Illustrated Seed Catalog

Implement:

- Custom catalog interface.
- Upgrade category navigation.
- Progressive reveal system.
- Dependency rules.
- Botanical connections.
- Upgrade details.
- Discovery animations.
- Automatic tomato variety progression.

**Acceptance condition:** New upgrades and varieties reveal correctly, and the player can navigate the growing catalog without confusion.

## Phase 4 — Equipment Catalog

Implement:

- Knife shop.
- Knife 3D previews.
- Knife purchases.
- Equipment changes.
- Blade-specific geometry.
- Knife modifications.
- Equipment bonuses.

**Acceptance condition:** Different knives provide recognizable visual and gameplay differences.

## Phase 5 — Prestige

Implement:

- Tomato Seeds.
- Prestige calculation.
- Reset logic.
- Permanent upgrade branches.
- Progressive prestige discovery.
- Prestige-exclusive event unlocks.
- Special event activation and improvements.

**Acceptance condition:** Prestige functions reliably and makes future runs more rewarding.

## Phase 6 — Full Content

Complete:

- All 25 tomato varieties.
- All 25 knives.
- Upgrade branches.
- Harvest Frequency and Dominance.
- Special events.
- Achievements.
- Mastery.
- Background progression.
- Cosmetics.

**Acceptance condition:** The intended content is implemented and integrated into actual gameplay.

## Phase 7 — Polish and Balance

Improve:

- 3D models.
- Materials.
- Lighting.
- Slicing animations.
- Particles.
- UI illustrations.
- Tooltips.
- Catalog transitions.
- Sound effects.
- Music.
- Performance.
- Economy balance.
- Accessibility.
- Stability.

**Acceptance condition:** The game feels cohesive and professionally finished.

---

# 31. QUALITY ASSURANCE

Review every major system before delivering the project.

## Core Gameplay

Verify that:

- Mouse movements accurately control the blade.
- Fast swipes register correctly.
- Stationary contact does not create repeated cuts.
- Cutting rewards are counted once.
- Durability behaves correctly.
- Fragment separation is convincing.
- Timers and round completion work.
- Results are accurate.

## Progression

Verify that:

- All upgrades apply their stated effects.
- Prices deduct correctly.
- Maximum levels are enforced.
- Prerequisites work.
- Hidden upgrades do not appear.
- Revealed upgrades remain visible appropriately.
- Branches reveal in the correct order.
- Multi-prerequisite conditions work.
- No progression dependencies create unreachable content.

## Tomato Varieties

Verify that:

- Only unlocked tomatoes spawn.
- Variety unlocks exist only in the seed catalog.
- Frequency upgrades affect spawn weights.
- Premium Quality affects earnings.
- Dominance gradually phases out lower tiers.
- Spawn weights normalize correctly.
- At least one valid variety always remains.
- The game does not create impossible tomato-only harvests.
- Players cannot manually control spawn distribution.

## Shop

Verify that:

- Every knife can be purchased.
- The correct model appears when equipped.
- Blade geometry matches its appearance.
- Modifications work.
- Purchased equipment persists during the prestige cycle.
- No tomato shop exists.

## Prestige and Events

Verify that:

- Prestige rewards calculate correctly.
- Resets affect only intended systems.
- Permanent upgrades persist.
- Locked events never occur.
- Every event requires its dedicated unlock.
- Event frequency upgrades cannot bypass locks.
- Special event unlocks survive prestige.
- Duplicate prestige rewards cannot be claimed.

## UI

Verify that:

- Icons are recognizable and consistent.
- Hover states respond immediately.
- Tooltips appear after one second.
- Tooltips disappear immediately on exit.
- Tooltips remain on screen.
- Menu transitions remove stale tooltips.
- Upgrade catalog navigation remains usable.
- Hidden nodes do not create broken layouts.
- Important controls remain clearly labeled where necessary.
- UI works at supported resolutions.

## Screen Effects

Verify that:

- Ordinary cuts never shake the camera.
- Menu interactions never shake the camera.
- Rare shake events remain subtle.
- Shake cooldowns are enforced.
- Off disables all shake.
- Reduced Motion disables shake.
- Knife collision accuracy is unaffected.

## Performance and Saving

Verify that:

- Tomato and fragment counts are bounded.
- Particles are cleaned up.
- Late-game rounds remain responsive.
- Saves persist after closing the game.
- Upgrade reveals restore correctly.
- Prestige progress restores correctly.
- Invalid save files do not crash the game.

Run Godot project validation and automated tests where practical.

Report any tests that could not be performed.

---

# 32. FINAL DELIVERY REQUIREMENTS

Provide the complete project, not disconnected scripts or isolated demonstrations.

The deliverable should include:

1. Full Godot project.
2. Complete GDScript source.
3. All required scenes.
4. All original 3D models.
5. Materials and textures.
6. Illustrated interface assets.
7. Knife and tomato fragment assets.
8. Audio and music assets included in the implemented build.
9. Content definitions.
10. Working save system.
11. Windows export configuration.
12. Windows executable when export tooling is available.
13. Complete ZIP archive.
14. Clear Windows installation and launch instructions.
15. Brief testing and implementation summary.
16. Honest list of incomplete features or known issues.

Do not claim that content or tests are complete unless they actually are.

If a system cannot be fully implemented, preserve the working game and document the limitation.

Do not substitute placeholder content for complete features without explaining that it remains unfinished.

---

# 33. FINAL DESIGN DIRECTIVE

Tomato Cut should feel like a ridiculous idea executed with extraordinary care.

The player begins with a single ordinary tomato, a terrible butter knife, and ten seconds.

Every successful cut earns money.

Every purchase makes the next round better.

Over time, the player discovers new tomato varieties through a beautifully illustrated seed catalog.

The catalog gradually expands, revealing new botanical entries and upgrade branches as the player progresses.

The player does not manage which tomatoes appear. Their upgrade investments naturally transform the harvest, gradually replacing low-value tomatoes with premium varieties.

The equipment shop offers increasingly elaborate knives presented through a luxurious and slightly absurd culinary catalog.

Prestige permanently transforms future runs and unlocks rare special tomato events that never occur before their dedicated unlocks are purchased.

Throughout the experience, the interface remains clean.

Icons replace unnecessary text, with delayed hover labels for clarity.

Screen shake is rare and restrained.

The tomatoes remain the focus.

The 3D models should feel tactile, the cuts should feel precise, and the physics should be exaggerated just enough to make the interaction delightful.

Do not add complicated controls, unrelated mechanics, or unnecessary systems.

**Build a complete, polished, replayable arcade-incremental game with a distinctive visual identity and meaningful long-term progression.**

The game should be impressive not because it is complicated, but because every part of a simple concept has been thoughtfully executed.

**MAKE SLICING TOMATOES FEEL INCREDIBLE.**