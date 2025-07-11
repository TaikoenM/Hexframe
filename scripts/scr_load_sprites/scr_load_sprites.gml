/// @description Load all PNG files from a folder as sprites into a ds_map
/// @param {string} folder_path - Path to the folder containing PNG files
/// @param {bool} [subfolders=false] - Whether to include subfolders
/// @returns {ds_map} DS map with filename (without extension) as key and sprite index as value
function load_sprites_from_folder(folder_path, subfolders = true) {
    // Create a new ds_map to store sprites
    var sprites_map = ds_map_create();
    
    log("Loading sprites from folder: " + folder_path, LogImportance.INFO, LogComponent.DATA_LOAD);
    
    // Normalize folder path - ensure consistent forward slashes
    folder_path = string_replace_all(folder_path, "\\", "/");
    if (string_char_at(folder_path, string_length(folder_path)) != "/") {
        folder_path += "/";
    }
    
	
	// Check if the folder exists
    if (!directory_exists(folder_path)) {
        log("Sprite folder not found: " + folder_path, LogImportance.WARNING, LogComponent.DATA_LOAD);
	    // Check if we need to use working_directory
	    var full_path;
	    if (string_pos(":", folder_path) > 0) {
	        // Absolute path was provided
	        full_path = folder_path;
	    } else {
	        // Relative path - prepend working_directory
	        full_path = working_directory + folder_path;
	    }
    
	    log("Full path for sprites: " + full_path, LogImportance.DEBUG, LogComponent.DATA_LOAD);
		    // Check if the folder exists
	    if (!directory_exists(full_path)) {
	        log("Sprite folder not found: " + full_path, LogImportance.ERROR, LogComponent.DATA_LOAD);
	        return sprites_map; // Return empty map
	    }
		folder_path = full_path
    }
	full_path = folder_path
    
    // Find the first file - use the full path for finding files
    var file = file_find_first(full_path + "*.png", 0);
    var file_count = 0;
    
    // Process each PNG file
    while (file != "") {
        // Get filename without extension
        var filename = string_replace(file, ".png", "");
        var sprite_key = filename;
        var sprite_id = -1;
        
        // Check if filename starts with a number followed by underscore (e.g., "5_")
        var prefix_pos = string_pos("_", filename);
        var is_strip = false;
        var strip_length = 1;
        
        if (prefix_pos > 0) {
            var prefix = string_copy(filename, 1, prefix_pos - 1);
            
            // Check if the prefix is a number
            if (string_digits(prefix) == prefix) {
                strip_length = real(prefix);
                is_strip = true;
                
                // Remove the prefix from the sprite key
                sprite_key = string_delete(filename, 1, prefix_pos);
                
                log("Detected sprite strip: " + file + " with " + string(strip_length) + " frames", 
                    LogImportance.DEBUG, LogComponent.DATA_LOAD);
            }
        }
        
        // Construct the full file path for loading
        var sprite_path = full_path + file;
        
        // Log what we're trying to load
        log("Attempting to load sprite from: " + sprite_path, LogImportance.DEBUG, LogComponent.DATA_LOAD);
        
        // Check if file actually exists before trying to load it
        if (file_exists(sprite_path)) {
            // Load the sprite
            if (is_strip && strip_length > 1) {
                // Load as a sprite strip
                sprite_id = sprite_add(sprite_path, strip_length, false, false, 0, 0);
				sprite_set_offset(sprite_id, round(sprite_get_width(sprite_id) * 0.5),round(sprite_get_height(sprite_id) * 0.5))  
            } else {
                // Load as a single image sprite
                sprite_id = sprite_add(sprite_path, 1, false, false, 0, 0);
				sprite_set_offset(sprite_id, round(sprite_get_width(sprite_id) * 0.5),round(sprite_get_height(sprite_id) * 0.5))  
            }
            
            // Check if sprite was loaded successfully
            if (sprite_id != -1) {
                ds_map_add(sprites_map, sprite_key, sprite_id);
                file_count++;
                
                log("Loaded sprite: " + sprite_key + " (ID: " + string(sprite_id) + ")", 
                    LogImportance.DEBUG, LogComponent.DATA_LOAD);
            } else {
                log("Failed to load sprite: " + sprite_path, LogImportance.ERROR, LogComponent.DATA_LOAD);
            }
        } else {
            log("File does not exist: " + sprite_path, LogImportance.ERROR, LogComponent.DATA_LOAD);
        }
        
        // Find the next file
        file = file_find_next();
    }
    
    // Close the file finder
    file_find_close();
    
    // Process subfolders if requested
    if (subfolders) {
        // Find first directory
        var dir = file_find_first(full_path + "*", fa_directory);
        
        while (dir != "") {
            if (dir != "." && dir != "..") {
                var dir_path = full_path + dir;
                
                // Check if it's a directory
                if (directory_exists(dir_path)) {
                    // Recursively load sprites from subfolder - use the relative path for recursion
                    var subfolder_sprites = load_sprites_from_folder(folder_path + dir, true);
                    
                    // Add prefix to keys to avoid collisions
                    var key = ds_map_find_first(subfolder_sprites);
                    
                    while (!is_undefined(key)) {
                        var sprite_value = subfolder_sprites[? key];
                        var new_key = dir + "/" + key;
                        
                        // Add to main map
                        ds_map_add(sprites_map, new_key, sprite_value);
                        
                        // Move to next key
                        key = ds_map_find_next(subfolder_sprites, key);
                    }
                    
                    // Clean up the subfolder map
                    ds_map_destroy(subfolder_sprites);
                }
            }
            
            // Find next directory
            dir = file_find_next();
        }
        
        // Close the directory finder
        file_find_close();
    }
    
    log("Loaded " + string(file_count) + " sprites from " + folder_path, 
        LogImportance.INFO, LogComponent.DATA_LOAD);
    
    return sprites_map;
}

/// @description Example usage - load sprites and use in game
function load_game_sprites() {
    // Load sprites with correct paths
    // Option 1: Using included_files directory (preferred)
    global.unit_sprites = load_sprites_from_folder("datafiles/base/unit_sprites");
    global.hex_sprites = load_sprites_from_folder("datafiles/base/hex_sprites");
    global.feature_sprites = load_sprites_from_folder("datafiles/base/feature_sprites");
    global.object_sprites = load_sprites_from_folder("datafiles/base/object_sprites");
    
    // Option 2: Alternative locations (if needed)
    if (ds_map_size(global.hex_sprites) == 0) {
        log("Trying alternative path for hex sprites", LogImportance.INFO, LogComponent.DATA_LOAD);
        global.hex_sprites = load_sprites_from_folder("base/hex_sprites");
    }
    
    if (ds_map_size(global.unit_sprites) == 0) {
        log("Trying alternative path for unit sprites", LogImportance.INFO, LogComponent.DATA_LOAD);
        global.unit_sprites = load_sprites_from_folder("base/unit_sprites");
    }
    
    // Log results
    log("Loaded " + string(ds_map_size(global.hex_sprites)) + " hex sprites", LogImportance.INFO, LogComponent.DATA_LOAD);
    log("Loaded " + string(ds_map_size(global.unit_sprites)) + " unit sprites", LogImportance.INFO, LogComponent.DATA_LOAD);
    log("Loaded " + string(ds_map_size(global.feature_sprites)) + " feature sprites", LogImportance.INFO, LogComponent.DATA_LOAD);
    log("Loaded " + string(ds_map_size(global.object_sprites)) + " object sprites", LogImportance.INFO, LogComponent.DATA_LOAD);
}


/// @description Load one specific sprite for testing
/// @param {string} full_path - Full path to the specific sprite to test
function test_load_single_sprite(full_path) {
    log("Test loading single sprite: " + full_path, LogImportance.INFO, LogComponent.DATA_LOAD);
    
    if (file_exists(full_path)) {
        var sprite_id = sprite_add(full_path, 1, false, false, 0, 0);
        if (sprite_id != -1) {
            log("Successfully loaded test sprite: " + string(sprite_id), LogImportance.INFO, LogComponent.DATA_LOAD);
			sprite_set_offset(sprite_id, round(sprite_get_width(sprite_id) * 0.5),round(sprite_get_height(sprite_id) * 0.5))  
            return sprite_id;
        } else {
            log("Failed to load test sprite despite file existing", LogImportance.ERROR, LogComponent.DATA_LOAD);
        }
    } else {
        log("Test sprite file does not exist", LogImportance.ERROR, LogComponent.DATA_LOAD);
    }
    
    return -1;
}