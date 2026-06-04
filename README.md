# godot-vehicle

A WIP racing game made in Godot 4.6 that has a custom Raycast vehicle implementation, racing with ghost replays, vehicle performance customization and tuning, UI for saving, minimap, previewing events and for seeing vehicle performance and grip. 

Plan on adding: AI opponents/traffic, more visual customization and more gamification using currency, achievements and more vehicle types, ingame city and more map variety.

## [Vehicle Classes](Scripts/vehicle):
**Vehicle** Manages the vehicle stats (inside **VehicleData**), input from **VehicleController** and *Axle* to place and connect the wheels. *LD* versions use simplified physics (for non player vehicles).

**Wheel**: Handles the suspension and grip. Applies all forces to vehicle (besides Drag/Downforce)

**LightsManager/MeshColorable**: Utility classes for changing colors/materials/lighting of meshes.

**PlayerData**: Stores info about user, user's vehicle and sprint times. Managed in *global.gd*.

## [Race Classes](Scripts/sprint)

**SprintRace**: Spawns **Checkpoint**s for a race and handles **GhostPlayer** for replays/medals.

**GhostPlayer**/**GhostData**: Record and replay actions of target vehicle.

## Other

**RoadPath**: Wrapper for Path3D and CSGPolygon to create roads, updates **Minimap**.

**UI Manager**: Handles all ui elements.

**GripUI** for seeing current grip usage and breakdown.

**Map** Draws map height, roadpaths, important places (ex: autoshops) and vehicle icons.

**SprintUI**/**SprintPopup** Shows a preview of a race and data about time and checkpoint status, also starts **SprintRace**.

**Autoshop** Gives the player options for customization and tuning.

## [Car Components](Resources)
**Chassis** Not modifiable, unique for each car (Currently only 1 car implemented)

**Engine** Gives base Power and TopSpeed stats.

**Transmission** Allows tuning of gear ratio and multiplies engine performance.

**Aspiration** Allows for use of Turbo/Superchargers and modifies the acceleration curve of the vehicle.

**Suspension** Currently only allows for customization of ride height.

**Tires** Changes the wheels visual on the vehicle and handle differently in different terrains. Some are better for straight line and others for cornering.

**Drivetrain** Changes the power distribution of the vehicle to the wheels.

**Weight Kit** and **Aero Kit** simply modify the weight and drag/downforce of the chassis

All components are managed in VehicleData.


## Asset Credits

Terrain made using [Terrain3D](https://tokisan.com/terrain3d/)

Terrain materials [ambientcg.com](https://ambientcg.com/)

[City-asset-pack](https://sketchfab.com/3d-models/free-low-poly-simple-urban-city-3d-asset-pack-310c806355814c3794f5e3022b38db85#download)
[Car-pack](https://sketchfab.com/3d-models/asset-of-low-poly-cars-part-2-55e75735c7144234b7016d0f7fa50dd4#download)

Sky shader [krzmig-shader](https://github.com/krzmig/godot-simple-sky-project)

[Water shader](https://godotshaders.com/shader/transparent-water-shader-supporting-ssr/) (Currently unconfigured)

## How to Run:
Download latest release and run .exe on Windows or .x86-64 on Linux (Might need to run with Wine or steam's Proton if not available) or clone the repo and run inside Godot 4.6 editor
