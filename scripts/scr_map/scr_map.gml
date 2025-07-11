/// @function create_diamond_hex_map
/// @desc Creates a map of hexes in a parallelogram grid layout using cube coordinates.
/// @param map_width  Number of hex columns (axial q range)
/// @param map_height Number of hex rows (axial r range)
/// @returns A ds_list containing all hex instances created.
function create_diamond_hex_map(map_width, map_height) {
    // Create a ds_grid to hold hex instances, indexed by axial coordinates [q, r]
    var hex_grid = ds_grid_create(map_width, map_height);
    // Create a list to store all hex instances (for convenience)
    var hex_list = ds_list_create();
    hex_count = map_width * map_height
    // Create hex instances in a parallelogram layout.
    // Here we use axial coordinates where:
    //   axial q = column index (0 to map_width-1)
    //   axial r = row index (0 to map_height-1)
    // Cube coordinate is computed as [q, -q - r, r].
    for (var q = 0; q < map_width; q++) {
        for (var r = 0; r < map_height; r++) {
            var cube = [ q, -q - r, r ];
            // Convert cube coordinate to pixel position (using your hex_cube_to_pixel function)
            var pos = hex_cube_to_pixel(cube);
            // Create an instance of oHex on a layer named "Instances" (adjust layer name as needed)
			var hex_inst = create_hex_instance(pos[0], pos[1], "1")
            
            // Save coordinate information in the hex instance
            hex_inst.cube = cube;       // Cube coordinate: [q, -q-r, r]
            hex_inst.axial_q = q;         // Axial coordinate q
            hex_inst.axial_r = r;         // Axial coordinate r
            
            // Initialize neighbor variables (they will later hold a reference to the neighbor hex instance)
            hex_inst.neighbor_E  = noone;
            hex_inst.neighbor_NE = noone;
            hex_inst.neighbor_NW = noone;
            hex_inst.neighbor_W  = noone;
            hex_inst.neighbor_SW = noone;
            hex_inst.neighbor_SE = noone;
            
            // Store the hex instance in the grid and add to the list
            hex_grid[# q, r] = hex_inst;
            ds_list_add(hex_list, hex_inst);
        }
    }
    
    // Now assign neighbor references.
    // The cubeDirections array (declared in your utility script) is defined as:
    // [ 1, -1,  0]  --> E   (axial: q+1, r+0)
    // [ 1,  0, -1]  --> NE  (axial: q+1, r-1)
    // [ 0,  1, -1]  --> NW  (axial: q+0, r-1)
    // [-1,  1,  0]  --> W   (axial: q-1, r+0)
    // [-1,  0,  1]  --> SW  (axial: q-1, r+1)
    // [ 0, -1,  1]  --> SE  (axial: q+0, r+1)
    // We loop through each hex, compute its neighbor cube coordinate, then determine the corresponding axial coordinates.
    for (var q = 0; q < map_width; q++) {
        for (var r = 0; r < map_height; r++) {
            var hex_inst = hex_grid[# q, r];
            var cube = hex_inst.cube;
            // Process all six directions
            for (var i = 0; i < 6; i++) {
                var n_cube = hex_get_neighbor(cube, i);
                // Convert neighbor cube to axial: (n_q, n_r)
                var n_q = n_cube[0];
                var n_r = n_cube[2];
                // Check if neighbor falls within our grid bounds
                if (n_q >= 0 && n_q < map_width && n_r >= 0 && n_r < map_height) {
                    var neighbor = hex_grid[# n_q, n_r];
                    if (i == 0)      hex_inst.neighbor_E  = neighbor;
                    else if (i == 1) hex_inst.neighbor_NE = neighbor;
                    else if (i == 2) hex_inst.neighbor_NW = neighbor;
                    else if (i == 3) hex_inst.neighbor_W  = neighbor;
                    else if (i == 4) hex_inst.neighbor_SW = neighbor;
                    else if (i == 5) hex_inst.neighbor_SE = neighbor;
                }
            }
        }
    }
    
    // (Optional) Store the grid and list globally for later reference
    global.hex_grid = hex_grid;
    global.hex_list = hex_list;
    
    return hex_list;
}


/// @function create_hex_map
/// @desc Creates a rectangular map of hexes using an odd-r offset coordinate system.
/// @param map_width  Number of columns (offset coordinate x)
/// @param map_height Number of rows (offset coordinate y)
/// @returns A ds_list containing all hex instances created.
function create_hex_map(map_width, map_height) {
    // Create a ds_grid to store hex instances by their offset coordinates [col, row]
    var hex_grid = ds_grid_create(map_width, map_height);
    // List for convenience to hold all hexes
    var hex_list = ds_list_create();
    
	var global_hex_offset = HEX_SIZE/2
	
    // Loop over offset coordinates.
    // For odd-r layout, each hex’s cube coordinate is computed as:
    //   cube_x = col - floor(row/2)
    //   cube_z = row
    //   cube_y = -cube_x - cube_z
    // Pixel coordinates for pointy-top hexes are computed as:
    //   pixel_x = HEX_SIZE * sqrt(3) * (col + 0.5 * (row mod 2))
    //   pixel_y = HEX_SIZE * (3/2) * row
    for (var row = 0; row < map_height; row++) {
        for (var col = 0; col < map_width; col++) {
            var cube_x = col - floor(row/2);
            var cube_z = row;
            var cube_y = -cube_x - cube_z;
            var cube = [ cube_x, cube_y, cube_z ];
            
            var pixel_x = global_hex_offset + HEX_SIZE * sqrt(3) * (col + 0.5 * (row mod 2));
            var pixel_y = global_hex_offset + HEX_SIZE * (3/2) * row;
            
            // Create instance of oHex on a layer (adjust layer name as needed)
			var hex_inst = create_hex_instance(pixel_x, pixel_y, "1")
            
            // Save coordinate information in the hex instance
            hex_inst.cube = cube;         // Cube coordinate: [cube_x, cube_y, cube_z]
            hex_inst.offset_col = col;      // Offset coordinate: column
            hex_inst.offset_row = row;      // Offset coordinate: row
            
            // Optionally store axial coordinates (using cube_x and cube_z)
            hex_inst.axial_q = cube_x;
            hex_inst.axial_r = cube_z;
            
            // Initialize neighbor variables
            hex_inst.neighbor_E  = noone;
            hex_inst.neighbor_NE = noone;
            hex_inst.neighbor_NW = noone;
            hex_inst.neighbor_W  = noone;
            hex_inst.neighbor_SW = noone;
            hex_inst.neighbor_SE = noone;
            
            // Store in grid and list
            hex_grid[# col, row] = hex_inst;
            ds_list_add(hex_list, hex_inst);
        }
    }
    
    // Define neighbor offsets for odd-r layout.
    // For even rows (row mod 2 == 0):
    var even_offsets = {
        E:  [ 1,  0 ],
        NE: [ 0, -1 ],
        NW: [ -1, -1 ],
        W:  [ -1,  0 ],
        SW: [ -1,  1 ],
        SE: [ 0,  1 ]
    };
    // For odd rows (row mod 2 == 1):
    var odd_offsets = {
        E:  [ 1,  0 ],
        NE: [ 1, -1 ],
        NW: [ 0, -1 ],
        W:  [ -1,  0 ],
        SW: [ 0,  1 ],
        SE: [ 1,  1 ]
    };
    
    // Now assign neighbor references using the appropriate offset set based on row parity.
    for (var row = 0; row < map_height; row++) {
        for (var col = 0; col < map_width; col++) {
            var hex_inst = hex_grid[# col, row];
            var offsets = (row mod 2 == 0) ? even_offsets : odd_offsets;
            
            // E
            var n_col = col + offsets.E[0];
            var n_row = row + offsets.E[1];
            if (n_col >= 0 && n_col < map_width && n_row >= 0 && n_row < map_height)
                hex_inst.neighbor_E = hex_grid[# n_col, n_row];
            
            // NE
            n_col = col + offsets.NE[0];
            n_row = row + offsets.NE[1];
            if (n_col >= 0 && n_col < map_width && n_row >= 0 && n_row < map_height)
                hex_inst.neighbor_NE = hex_grid[# n_col, n_row];
            
            // NW
            n_col = col + offsets.NW[0];
            n_row = row + offsets.NW[1];
            if (n_col >= 0 && n_col < map_width && n_row >= 0 && n_row < map_height)
                hex_inst.neighbor_NW = hex_grid[# n_col, n_row];
            
            // W
            n_col = col + even_offsets.W[0]; // same for both parity rows
            n_row = row + even_offsets.W[1];
            if (n_col >= 0 && n_col < map_width && n_row >= 0 && n_row < map_height)
                hex_inst.neighbor_W = hex_grid[# n_col, n_row];
            
            // SW
            n_col = col + offsets.SW[0];
            n_row = row + offsets.SW[1];
            if (n_col >= 0 && n_col < map_width && n_row >= 0 && n_row < map_height)
                hex_inst.neighbor_SW = hex_grid[# n_col, n_row];
            
            // SE
            n_col = col + offsets.SE[0];
            n_row = row + offsets.SE[1];
            if (n_col >= 0 && n_col < map_width && n_row >= 0 && n_row < map_height)
                hex_inst.neighbor_SE = hex_grid[# n_col, n_row];
        }
    }
    
    // Optionally store the grid and list in global variables for later reference
    global.hex_grid = hex_grid;
    global.hex_list = hex_list;
    
    return hex_list;
}
	
function get_hex_map_pixel_size(map_width, map_height) {
	var row = map_height - 1
	var col = map_width - 1
	var pixel_x = global_hex_offset + HEX_SIZE * sqrt(3) * (col + 0.5 * (row mod 2));
    var pixel_y = global_hex_offset + HEX_SIZE * (3/2) * row;
	return [pixel_x + HEX_SIZE, pixel_y + HEX_SIZE]
}

function setup_room_for_hex_map(map_width, map_height) {
    // Compute room width:
    // Left edge: -HEX_SIZE*sqrt(3)/2, right edge: HEX_SIZE*sqrt(3)*(map_width + 0.5)
    // Total width = HEX_SIZE*sqrt(3) * (map_width + 0.5) + HEX_SIZE*sqrt(3)/2
    // But for simplicity, we use the formula:
    var new_room_width = HEX_SIZE + HEX_SIZE * sqrt(3) * (map_width + 0.5);
    
    // Compute room height:
    // Top edge: -HEX_SIZE, bottom edge: HEX_SIZE*(3/2)*(map_height-1) + HEX_SIZE
    // Total height = HEX_SIZE * (1.5*(map_height - 1) + 2)
    var new_room_height = HEX_SIZE+ HEX_SIZE * ((3/2) * (map_height - 1) + 2);
    
    // Set room dimensions (if you have these functions available)
    room_set_width(room_hexmap, new_room_width);
    room_set_height(room_hexmap, new_room_height);
    
    show_debug_message("Room dimensions set to: " + string(new_room_width) + " x " + string(new_room_height));
}