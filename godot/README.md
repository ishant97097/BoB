# Battle of Buxar — Last Banner

Open `project.godot` in Godot 4.7 (tested with 4.7.2) and press F6 on `main.tscn`, or F5 to run the project. Click **Enter the battle**.

An offline 3D first-person battle royale prototype: one player and eleven AI fighters. Opponents fight one another, seek the safe zone, and use line-of-sight attacks. The safe zone starts shrinking after 25 seconds. Last survivor wins.

## Controls

WASD move, mouse aim, left click fire, Shift sprint, Space jump, R reload, Escape release/capture mouse. Click inside the match to recapture the mouse. Enter restarts after a result. Green crates heal 35; brass crates add 24 reserve rounds. The rifle has a twelve-round magazine and a 1.8-second reload.

## Setting and current limits

Buxar-inspired fort, Ganga riverbank, village buildings, fields, and cover. All geometry is generated locally from original primitive shapes. No asset downloads or network connection are needed to play. The map is not georeferenced; buildings, weapons, uniforms, and match events are fictional placeholders. It is not yet a historically accurate 1764 scenario, realistic-art release, multiplayer game, or complete kingship simulator. AI currently uses direct steering with obstacle jumping rather than a navigation mesh. Sound, save games, configurable bindings, and controller support are future work.

## Validation

Run `Godot --headless --path . --script res://tests/smoke.gd` to check spawning, physics, shots, healing, zone shrinking, eliminations, and victory. Launch the project normally for visual playtesting.

## Ruflo

The repository has been initialized using `ruflo init --minimal --skip-claude --no-global --no-signup --no-skills-sh --no-codex-detect --no-mods --no-plugin-install`. Its project-local configuration is in `.claude-flow/config.yaml`. Ruflo is development tooling; the game has no Ruflo runtime dependency. No Ruflo swarm or external model provider was started.
