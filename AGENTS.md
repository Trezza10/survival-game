# Playground conventions

- Keep the current iterative scope: walking, pause, stationary NPCs and visual/environment work. Add gameplay only when requested.
- Tree chopping is now authorized: a mobile axe button, keyboard/controller swing, four-hit trees, visual/audio feedback, and stumps. No creature damage, inventory, harvesting economy or other combat is authorized.
- The user has requested passive hopping AI for slimes, frogs, mushroom creatures and rabbits; species-specific wildlife movement; tree-perched owls; and unique local movement/idle profiles for all remaining monsters, bats and rats. No attacks or chasing are authorized.
- Place map objects and lights directly in the saved Godot scene. Do not generate the map or spawn NPCs at runtime.
- Every sprite added to the game must have aligned normal-map coverage. Reuse supplied normals when available; otherwise bake approximate normals with `tools/bake_normal_maps.py` after registering sheet regions in `assets/environment_regions.json`, and connect them to the material.
- Preserve original color sprite sheets. Keep normal-map dimensions and atlas regions aligned with their color textures.
- Keep the project local unless the user explicitly requests publishing.
