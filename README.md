# godot-vehicle

My own custom implementation of a 3D Raycast Vehicle, alternative to VehicleBody3D node (Not related).

Proper documentation and ease of use for custom nodes node are not a priority at the moment. <br>

# Main Classes:
<ol>
<li><b>Vehicle</b>:  Handles the controls and general properties and layout of vehicle.</li>
<li><b>Wheel</b> Handles the suspension and grip. (<b>Axle</b> is for positioning)</li>
<li><b>LightsManager/MeshColorable/WheelMesh</b>: Utility classes for changing colors/materials/lighting.</li>
<li><b>GhostPlayer/GhostData</b>: Record or replayd actions of target vehicle.</li>
<li><b>RoadPath</b>: Wrapper for Path3D and CSGPolygon, updates <b>Minimap</b>.</li>
<li><b>SprintRace</b>: Spawns checkpoints for a race and handles <b>GhostPlayer</b> for replays/medals.</li>
<li><b>Minimap</b>: Draws map height and roadpaths.</li>
<li><b>PlayerData</b>: Stores info about user, vehicle and sprint times, managed in global.gd.</li>
</ol>


# Adjustable Parameters
**Power & Brake Force**: How much force the wheels can produce. (Limited by max grip) <br>
**Brake Bias**: Where the brake force is applied, causes drifty handling toward -1 (rear) and understeer toward 1 (front) <br>
**Turn Angle**: Maximum wheel angle when turning. <br>
**Grip**: Multiplier to maximum grip. <br>
**Grip Forgiveness**: Makes acceleration and braking less costly on grip. Gives the "Arcade" feel (1 = more arcadey, grip not reduced under acceleration or braking).<br>
**Height, Strength, Damping**: Suspension parameters. <br>
**Anti-roll**: Counter-force to rotation. (Might cause undesired understeer) <br>
**Aero**: Downforce at position of aero component. (One at rear and one at front for example vehicle) <br>
**Stabilizer**: Keeps vehicle straight and less likely to spin out. (If placed behind center)

### Parameters (soon to be adjustable)
**Curves for acceleration, braking and others** <br>
**Lights parameters** <br>
**Material Properties** <br>
**Center of Mass** <br>

## Credits
Terrain made using [Terrain3D](https://tokisan.com/terrain3d/) <br>
Placeholder materials sourced from [ambientcg.com](https://ambientcg.com/) <br>
Shader Materials from [GodotShaders](https://godotshaders.com/)

## How to Run:
**Windows**: download and run the .exe from latest release. <br>
**Linux**: Run project inside editor or run using steam Proton by adding as a game to steam, selecting properties and compatibility and latest Proton version.
