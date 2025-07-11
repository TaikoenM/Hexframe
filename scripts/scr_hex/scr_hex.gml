// --- Hex Utility Script for Cube Coordinates (Pointy-Top Hexes) ---

/// Constant for hex size (distance from center to any corner)
globalvar HEX_SIZE;
HEX_SIZE = 66; // Adjust this value to scale your hex grid

/// Cube directions (offsets) for neighbor computation in cube coordinates
globalvar cubeDirections;
cubeDirections = [
    [ 1, -1,  0],
    [ 1,  0, -1],
    [ 0,  1, -1],
    [-1,  1,  0],
    [-1,  0,  1],
    [ 0, -1,  1]
];

/// @function hex_get_neighbor
/// @desc Returns the cube coordinate of the neighbor hex in a given direction (0 to 5)
/// @param cube   An array [x, y, z] representing the cube coordinate of the current hex
/// @param direction   An integer (0-5) representing the neighbor direction
function hex_get_neighbor(cube, direction) {
    var offset = cubeDirections[direction];
    return [ cube[0] + offset[0], cube[1] + offset[1], cube[2] + offset[2] ];
}

/// @function hex_get_all_neighbors
/// @desc Returns an array of cube coordinates for all 6 neighboring hexes
/// @param cube   The current hex’s cube coordinate [x, y, z]
function hex_get_all_neighbors(cube) {
    var neighbors = [];
    for (var i = 0; i < 6; i++) {
        neighbors[i] = hex_get_neighbor(cube, i);
    }
    return neighbors;
}

/// @function hex_distance
/// @desc Calculates the distance (in hexes) between two cube coordinates
/// @param a   First cube coordinate [x, y, z]
/// @param b   Second cube coordinate [x, y, z]
function hex_distance(a, b) {
    // Using the Manhattan distance divided by 2 (or max of the differences)
    return ( abs(a[0] - b[0]) + abs(a[1] - b[1]) + abs(a[2] - b[2]) ) / 2;
}

/// @function hex_cube_to_pixel
/// @desc Converts a cube coordinate to pixel coordinates (for pointy-top hexes)
/// @param cube   The hex’s cube coordinate [x, y, z]
function hex_cube_to_pixel(cube) {
    // Convert cube to axial coordinates: q = x, r = z
    var q = cube[0];
    var r = cube[2];
    var pixel_x = HEX_SIZE * sqrt(3) * (q + r/2);
    var pixel_y = HEX_SIZE * (3/2) * r;
    return [ pixel_x, pixel_y ];
}

/// @function hex_pixel_to_cube
/// @desc Converts pixel coordinates to fractional cube coordinates (for pointy-top hexes)
/// @param x   The x pixel coordinate
/// @param y   The y pixel coordinate
function hex_pixel_to_cube(x, y) {
    var q = (sqrt(3)/3 * x - 1.0/3 * y) / HEX_SIZE;
    var r = (2.0/3 * y) / HEX_SIZE;
    var cube_x = q;
    var cube_z = r;
    var cube_y = -cube_x - cube_z;
    return [ cube_x, cube_y, cube_z ];
}

/// @function hex_round
/// @desc Rounds fractional cube coordinates to the nearest valid hex cube coordinate
/// @param cube   The fractional cube coordinate [x, y, z]
function hex_round(cube) {
    var rx = round(cube[0]);
    var ry = round(cube[1]);
    var rz = round(cube[2]);
    
    var x_diff = abs(rx - cube[0]);
    var y_diff = abs(ry - cube[1]);
    var z_diff = abs(rz - cube[2]);
    
    // Adjust the coordinate with the largest difference to ensure x + y + z = 0
    if (x_diff > y_diff && x_diff > z_diff) {
        rx = -ry - rz;
    } else if (y_diff > z_diff) {
        ry = -rx - rz;
    } else {
        rz = -rx - ry;
    }
    
    return [ rx, ry, rz ];
}

// --- Example Usage ---
// In your oHex object, you might store the cube coordinate as a variable, e.g.,
// self.cube_coord = [0, 0, 0];
//
// To get the pixel position to draw the hex, you can use:
// var pos = hex_cube_to_pixel(self.cube_coord);
// x = pos[0];
// y = pos[1];
//
// To find a neighbor, for example, the neighbor in direction 2:
// var neighborCube = hex_get_neighbor(self.cube_coord, 2);
