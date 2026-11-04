# survival game

Minimal Godot 4.7 walking playground. Open `project.godot` and press F5.

The game uses a 1280×720 (16:9) base viewport with aspect-preserving window scaling. A Camera2D saved under the Player follows smoothly at 1.5× zoom, showing roughly 853×480 world units. It tracks the player's stable physics position, so the walking bob does not shake the view, and stops at the meadow boundaries. Adjust `Actors/Player/Camera` in the scene to tune zoom and smoothing.

- **Walk:** WASD, arrows, controller left stick or D-pad.
- **Pause/resume:** Escape, P, or controller Start/Menu. Pause freezes movement without a menu or HUD.
- The player uses the supplied `default_player_idle_front.png`, with smooth acceleration/deceleration and a subtle vertical walking bob. Its world height remains 42 units.
- The 22 animal placements use all ten designs from the supplied `Forest Animal Pixel Sprite Sheet.png`: rabbit, squirrel, fox, frog, duck, hedgehog, fawn, boar, owl and raccoon. Designs repeat across existing placements. The animals now have distinct passive behaviors, described below.
- One continuous meadow uses the former leftmost grass color. Larger trees and rocks form irregular groves and outcrops, with 550 additional grass tufts scattered in patches using the supplied foliage atlas. Trunk and rock collisions leave room to walk through the playground.
- Everything is saved directly in `scenes/playground.tscn`; no runtime map construction or spawning. Y-sorting and foot-level collisions provide basic 2.5D overlap.
- Adjust `walk_speed`, `acceleration`, `deceleration`, `bob_height`, and `stride_length` on the Player node to iterate on feel.

## Lighting

The animals use regions of `assets/sheets/forest_animals.png` with aligned approximate relief normals in `assets/normals/forest_animals_normal.png`. Color PNGs remain unchanged. These are synthetic relief maps, not artist-authored 3D geometry. Each animal's saved ground shadow uses the same new sprite region.

The trees, rocks, foliage and player use AtlasTexture regions of unchanged source PNGs in `assets/sheets`. Corresponding normal-map atlases are in `assets/normals/*_normal.png`, with exactly the same dimensions and region alignment. They approximate broad silhouette curvature and subtle color relief. The material also hides bright matte remnants visible in the supplied sheets. Region coordinates and placed object positions are recorded in `assets/environment_regions.json`.

A warm `PlayerLight` follows the player. Five colored `PointLight2D` nodes under `Lighting/NormalMapLights` highlight grove, ore and foliage surfaces. Their shallow virtual height makes the normal detail visible as the player walks past. All lights are placed in the scene and work during day and night; press N/LB for the clearest night comparison. Local lights add normal-map highlights; the finite ground shadows continue to follow the sun/moon.

When adding sprites, include an aligned normal map. For an environment sheet, register its regions and run `python tools/bake_normal_maps.py` (Pillow and NumPy required), then assign the generated normal atlas to its material's `normal_atlas` parameter. Existing authored normals can be assigned through CanvasTexture instead. The bake leaves original color images untouched.

A two-minute day/night cycle changes ambient light, sunlight, moonlight, and shadow direction/length. **N / controller LB** jumps between day and night for comparison. Pause freezes the cycle too. On the `Lighting` node, adjust `time_of_day`, `cycle_seconds`, or disable `cycle_enabled` to hold a particular time.

Shadows are finite projections of the actual sprite silhouettes onto the ground, with slightly softened edges. They track the dominant sun/moon direction and become longer near the horizon. They are stylized ground shadows, not 3D shadows that fall across neighboring characters. The lights and shadow nodes are saved in the scene. Godot's built-in infinite directional shadows are disabled.

This rebuild has no combat, dash, interactions, objectives, HUD, web export or deployment configuration.

## Monster NPCs

All 29 designs from `Chunky Pixel Monster Sprite Atlas.png` are saved as NPC nodes in the meadow. Small slimes, bugs and critters are shorter than the player; goblins and the mage are roughly player-sized; golems and the large mushroom/tree creatures are taller. The nine slimes have matching green, blue, purple, teal, pink or orange point lights, a restrained luminous surface and a soft ground halo. Other monster NPCs remain stationary.

The nine slimes now passively wander through short collision-aware hops near their starting spots. They squish before takeoff, stretch upward in the air, and squash as they land. Their normal-mapped sprite and glowing surface deform together; their projected shadow and ground halo shrink and fade during a jump. Hop timing varies between slimes. They avoid solid scenery and the player, bounce in place when blocked, and do not attack or chase. Pause freezes both hopping and animation. Tune `wander_radius`, `hop_height` and `hop_distance` on a slime node.

Frogs, slimes and the three mushroom creatures share `scripts/passive_hopper.gd` with individually saved profiles. Frogs have longer, quicker leaps and less body squish; the gold mushroom has a higher, springier bounce; the red mushroom makes short, softer hops; the mushroom giant has a slow wind-up and a heavy landing with a restrained cap wobble. Their acceleration, launch speed, arc, height, crouch, landing and resting times are independently tunable in the Inspector. Hop height is measured in world units so the small scaled frogs still leap visibly. Scenery mushrooms remain static, and no attacks or chasing are added.

The source sheets are unchanged in `assets/sheets`, with aligned baked normals for the new player and every monster in `assets/normals`. Positions, dimensions, atlas rectangles and slime colors are recorded in `assets/environment_regions.json`.

## Wind

Living tree canopies and all grass/foliage materials use `assets/wind.gdshaderinc`. The lower portions remain anchored while a gentle spatial breeze and slow gusts move the upper leaves/blades. The same UV warp is applied to the color texture, normal map and projected shadow. Extra shader draw space prevents the moving outline from clipping against its atlas region; no source PNGs are modified. Dead trees, rocks, animals and the player remain rigid.

The saved `Wind` node drives a pausable shader clock. The meadow now has 110 drifting pixel leaves, 38 short translucent wind streaks, and small canopy emitters on every living tree. Canopy leaves drift and rotate downward; autumn trees emit warm-colored leaves. The leaf shapes are tiny stepped pixel silhouettes. All emitters are saved in the scene, and Escape/P freezes them along with the wind. Adjust the node's `speed` or `animate` values, particle amounts, and the sprite materials' `wind_amplitude` (source pixels) and `wind_anchor` values to tune the effect. Physics bodies and collision shapes remain fixed.

## Campfire

The campfire near the center uses the three supplied animation frames at 6 fps. It has a red-orange light with gentle flicker, a luminous flame layer, and small square embers that rise and fade in warm colors. Its source PNG is unchanged, and an aligned normal atlas covers all three frames. The logs block walking. Animation, flicker and particles pause with the game. All nodes, including the particle emitter and light, are saved under `Actors/Campfire` in the playground scene.

## Wildlife behavior

Rabbits make quick, low hops with less squash than slimes. Foxes trot and pause; raccoons amble with longer inspection stops; squirrels scamper in fast bursts; ducks waddle; hogs shuffle and make rooting motions at rest; deer pause and trot with a light bounding bob; hedgehogs creep slowly with small sniffing motions. These use the existing static poses with procedural body movement and facing flips rather than newly drawn walk cycles.

The bee follows a small hovering route with a height bob, slight buzzing deformation and a softened ground shadow. The two owls are saved as children of actual tree nodes, sitting in the canopy with slow breathing, a small body tilt and occasional facing changes. Their ground collisions and ground shadows are disabled. All wildlife stays local and pauses with the game. There are no attacks or chasing. Tune the ground species in `scripts/wildlife.gd` through their saved Inspector settings; perching uses `scripts/perched_owl.gd`.

## Other creature movement

All remaining monster NPCs now use distinct passive profiles in `scripts/creature_motion.gd`: goblins patrol with different weight and pacing; stone/moss golems and the tree giant lumber slowly; crystal creatures shuffle; rats dart and pause; spiders skitter; bats follow looping flight paths with a procedural wing-span flutter; wisps drift and pulse; and the mage floats while wandering. The plant and runestone remain rooted with restrained rocking/breathing poses. Flight has no ground collision, while walkers avoid scenery and the player. All movement stays near its home and pauses with the game. These effects use the existing poses rather than newly drawn animation frames, and add no combat or chasing.

## Web and mobile preview

The Web export uses the Compatibility renderer and a single thread, so it does not require cross-origin isolation headers. On a phone, hold and drag on the left side to walk; use the upper-right pause button to pause/resume. Touch controls only appear on touch devices. Landscape provides the widest view. Keyboard and controller controls still work.

Export with Godot 4.7: `godot --headless --path . --export-release Web docs/index.html`. The generated `docs/` directory is ignored by source control and contains the standalone browser build. Scene objects and lights remain authored in `scenes/playground.tscn`.
