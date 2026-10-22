# Battle of Buxar

**3D Godot game:** open [`godot/project.godot`](godot/project.godot) in Godot and press F5. See [3D game instructions](godot/README.md) for controls, features, and scope. The browser game below remains the earlier strategy prototype.

A dependency-free, turn-based browser strategy prototype centered on Buxar Fort, Bihar.

## Play

Open `index.html` in a modern browser. No installation or build step is required. Alternatively run `python -m http.server 8080` in this folder and visit http://localhost:8080.

Select one of your positions, choose a troop count, click **Dispatch troops**, and select a directly connected destination. Recruit troops and repair the fort with gold. End turn to collect income and let the enemy act. Hold the fort and at least three positions through turn 12 to win. Field guide explains combat and controls.

## Scope and historical grounding

This is a fictional kingship-control scenario, not a simulation of the historical 1764 battle. The map is schematic, not surveyed or georeferenced. Fort appearance, position placement, routes, opposing forces, and economy are gameplay placeholders. Buxar Fort's location on the Ganga is grounded in [Bihar Tourism](https://tourism.bihar.gov.in/en/destinations/buxar/buxar-fort). A researched geography and period-specific historical scenario are future work.

## Files

- `index.html`: accessible interface and field guide
- `style.css`: responsive military-map presentation
- `game.js`: campaign state, deterministic combat, enemy decisions, SVG map

No external assets, services, libraries, or credentials are needed. Campaign state resets on reload. Ruflo is not required by this initial standalone prototype.
