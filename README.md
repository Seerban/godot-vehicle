# godot-vehicle

WIP custom implementation of a 3D Raycast Vehicle, customizable alternative to Godot's VehicleBody3D node.

Proper documentation and ease of use for custom nodes node are not a priority at the moment. <br>

# Relevant Classes:
<ol>
<li><b>Vehicle</b>:  Handles the controls and general properties and layout of vehicle.</li>
<li><b>Wheel</b> Handles the suspension and grip.</li>
<li><b>LightsManager</b>:  Turns meshes into working dynamic lights. (Based on node.name atm).
<li><b>Aero/Stabilizer:</b>  Apply forces based on speed (And aero curve).</li>
<li><b>SprintRace</b>: Turns Node3D children into checkpoints for a race and handles timer & <b>GhostPlayer</b> for replays.</li>
<li><b>GhostPlayer</b>:  Can record or replay actions of vehicle object.</li>
<li><b>RoadCurve</b>: Small wrapper for Path3D and CSGPolygon, updates <b>Radar</b>.</li>
<li><b>Radar</b>: Draws roads, checkpoints & vehicles. (Currently unoptimized and unfinished)</li>
</ol>


# Adjustable Parameters
**Power & Brake Force**: How much force the wheels can produce. (Limited by max grip) <br>
**Brake Bias**: Where the brake force is applied, causes drifty handling toward -1 (rear) and understeer toward 1 (front) <br>
**Turn Angle**: Maximum wheel angle when turning. <br>
**Grip**: Multiplier to maximum grip. <br>
**Grip Forgiveness**: Makes acceleration and braking less costly on grip. Gives the "Arcade" feel (1 = more arcadey, grip not limited by reduced under acceleration or braking).<br>
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
