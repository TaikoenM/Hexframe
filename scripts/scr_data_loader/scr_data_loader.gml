/// @description Load game data from CSV files
function load_game_data() {
    log("Starting to load game data", LogImportance.INFO, LogComponent.DATA_LOAD);
    
    // Initialize global data structures
    global.hexTypes = ds_map_create();
    global.terrainFeatures = ds_map_create();
    global.unitTypes = ds_map_create();
    global.objectTypes = ds_map_create();
	global.options = ds_map_create();
    global.gameVersion = "";
    
    // Load base game data
    load_base_game_data();

	init_game_options();
	
    // Load mods that override or add to base game data
    load_mod_data();
    
    log("Game data loading complete", LogImportance.INFO, LogComponent.DATA_LOAD);
}


/// @description Setups graphics etc
function init_game_options() {
	window_set_size(global.options[? "WINDOW_WIDTH"], global.options[? "WINDOW_HEIGHT"])
}

/// @description Load base game data from CSV files
function load_base_game_data() {
    log("Loading base game data", LogImportance.INFO, LogComponent.DATA_LOAD);
    
    // Check if base folder exists
    if (!directory_exists("base")) {
		
		//log("temp: "+ temp_directory, LogImportance.ERROR, LogComponent.DATA_LOAD);
		
		//log("working_directory : "+ working_directory , LogImportance.ERROR, LogComponent.DATA_LOAD);
		
		//log("program_directory: "+ program_directory, LogImportance.ERROR, LogComponent.DATA_LOAD);
		
        log("Base folder not found!", LogImportance.ERROR, LogComponent.DATA_LOAD);
        return;
    }
    
    // Load general info from ini file
    load_game_info("base/game_info.ini");
    
    // Load hex types
    load_hex_types("base/hex_types.csv");
    
    // Load terrain features
    load_terrain_features("base/terrain_features.csv");
    
    // Load unit types
    load_unit_types("base/unit_types.csv");
    
    // Load object types
    load_object_types("base/object_types.csv");
}

/// @description Load game info from INI file
/// @param {string} filename - Path to the INI file
function load_game_info(filename) {
    if (!file_exists(filename)) {
        log("Game info file not found: " + filename, LogImportance.ERROR, LogComponent.DATA_LOAD);
        return;
    }
    
    ini_open(filename);
    global.gameVersion = ini_read_real("GENERAL", "Version", 1.0);
	
	global.options[? "WINDOW_WIDTH"] = ini_read_real("DISPLAY", "WINDOW_WIDTH", 1920);
	global.options[? "WINDOW_HEIGHT"] = ini_read_real("DISPLAY", "WINDOW_HEIGHT", 1080);
	
	
    // Read other general settings as needed
    ini_close();
    
    log("Loaded game info, version: " + string(global.gameVersion), LogImportance.INFO, LogComponent.DATA_LOAD);
}

/// @description Load hex types from CSV file
/// @param {string} filename - Path to the CSV file
function load_hex_types(filename) {
    if (!file_exists(filename)) {
        log("Hex types file not found: " + filename, LogImportance.ERROR, LogComponent.DATA_LOAD);
        return;
    }
    
    var file = file_text_open_read(filename);
    
    // Read header
    var header = file_text_read_string(file);
    file_text_readln(file);
    
    // Parse header to get column indices
    var headers = string_split(header, ";");
    var col_hex_id = array_get_index(headers, "hex_id");
    var col_name = array_get_index(headers, "name");
    var col_sprite = array_get_index(headers, "sprite");
    var col_passable = array_get_index(headers, "passable");
    // Add other columns as needed
    
    // Check if required columns exist
    if (col_hex_id == -1) {
        log("Missing hex_id column in hex types CSV", LogImportance.ERROR, LogComponent.DATA_LOAD);
        file_text_close(file);
        return;
    }
    
    // Read data rows
    while (!file_text_eof(file)) {
        var line = file_text_read_string(file);
        file_text_readln(file);
        
        if (line == "") continue;
        
        var values = string_split(line, ";");
        
        // Create hex type struct
        var hex_id = values[col_hex_id];
        var hex_type = new HexTypeData(
            hex_id,
            col_name != -1 ? values[col_name] : "",
            col_sprite != -1 ? values[col_sprite] : "",
            col_passable != -1 ? bool(values[col_passable]) : true
            // Add other properties as needed
        );
        
        // Add to global map
        ds_map_add(global.hexTypes, hex_id, hex_type);
        
        log("Loaded hex type: (" + string(hex_id) +") "+string(hex_type.name), LogImportance.DEBUG, LogComponent.DATA_LOAD);
    }
    
    file_text_close(file);
    log("Loaded " + string(ds_map_size(global.hexTypes)) + " hex types", LogImportance.INFO, LogComponent.DATA_LOAD);
}

/// @description Load terrain features from CSV file
/// @param {string} filename - Path to the CSV file
function load_terrain_features(filename) {
    if (!file_exists(filename)) {
        log("Terrain features file not found: " + filename, LogImportance.ERROR, LogComponent.DATA_LOAD);
        return;
    }
    
    var file = file_text_open_read(filename);
    
    // Read header
    var header = file_text_read_string(file);
    file_text_readln(file);
    
    // Parse header to get column indices
    var headers = string_split(header, ";");
    var col_feature_id = array_get_index(headers, "feature_id");
    var col_name = array_get_index(headers, "name");
    var col_sprite = array_get_index(headers, "sprite");
    var col_blocks_los = array_get_index(headers, "blocks_los");
    // Add other columns as needed
    
    // Check if required columns exist
    if (col_feature_id == -1) {
        log("Missing feature_id column in terrain features CSV", LogImportance.ERROR, LogComponent.DATA_LOAD);
        file_text_close(file);
        return;
    }
    
    // Read data rows
    while (!file_text_eof(file)) {
        var line = file_text_read_string(file);
        file_text_readln(file);
        
        if (line == "") continue;
        
        var values = string_split(line, ";");
        
        // Create terrain feature struct
        var feature_id = values[col_feature_id];
        var terrain_feature = new TerrainFeatureData(
            feature_id,
            col_name != -1 ? values[col_name] : "",
            col_sprite != -1 ? values[col_sprite] : "",
            col_blocks_los != -1 ? bool(values[col_blocks_los]) : false
            // Add other properties as needed
        );
        
        // Add to global map
        ds_map_add(global.terrainFeatures, feature_id, terrain_feature);
        
        log("Loaded terrain feature: " + feature_id, LogImportance.DEBUG, LogComponent.DATA_LOAD);
    }
    
    file_text_close(file);
    log("Loaded " + string(ds_map_size(global.terrainFeatures)) + " terrain features", LogImportance.INFO, LogComponent.DATA_LOAD);
}

/// @description Load unit types from CSV file
/// @param {string} filename - Path to the CSV file
function load_unit_types(filename) {
    if (!file_exists(filename)) {
        log("Unit types file not found: " + filename, LogImportance.ERROR, LogComponent.DATA_LOAD);
        return;
    }
    
    var file = file_text_open_read(filename);
    
    // Read header
    var header = file_text_read_string(file);
    file_text_readln(file);
    
    // Parse header to get column indices
    var headers = string_split(header, ";");
    var col_unit_id = array_get_index(headers, "unit_id");
    var col_name = array_get_index(headers, "name");
    var col_sprite = array_get_index(headers, "sprite");
    var col_movement = array_get_index(headers, "movement");
    var col_attack = array_get_index(headers, "attack");
    var col_defense = array_get_index(headers, "defense");
    // Add other columns as needed
    
    // Check if required columns exist
    if (col_unit_id == -1) {
        log("Missing unit_id column in unit types CSV", LogImportance.ERROR, LogComponent.DATA_LOAD);
        file_text_close(file);
        return;
    }
    
    // Read data rows
    while (!file_text_eof(file)) {
        var line = file_text_read_string(file);
        file_text_readln(file);
        
        if (line == "") continue;
        
        var values = string_split(line, ";");
        
        // Create unit type struct
        var unit_id = values[col_unit_id];
        var unit_type = new UnitTypeData(
            unit_id,
            col_name != -1 ? values[col_name] : "",
            col_sprite != -1 ? values[col_sprite] : "",
            col_movement != -1 ? real(values[col_movement]) : 1,
            col_attack != -1 ? real(values[col_attack]) : 1,
            col_defense != -1 ? real(values[col_defense]) : 1
            // Add other properties as needed
        );
        
        // Add to global map
        ds_map_add(global.unitTypes, unit_id, unit_type);
        
        log("Loaded unit type: " + unit_id, LogImportance.DEBUG, LogComponent.DATA_LOAD);
    }
    
    file_text_close(file);
    log("Loaded " + string(ds_map_size(global.unitTypes)) + " unit types", LogImportance.INFO, LogComponent.DATA_LOAD);
}

/// @description Load object types from CSV file
/// @param {string} filename - Path to the CSV file
function load_object_types(filename) {
    if (!file_exists(filename)) {
        log("Object types file not found: " + filename, LogImportance.ERROR, LogComponent.DATA_LOAD);
        return;
    }
    
    var file = file_text_open_read(filename);
    
    // Read header
    var header = file_text_read_string(file);
    file_text_readln(file);
    
    // Parse header to get column indices
    var headers = string_split(header, ";");
    var col_object_id = array_get_index(headers, "object_id");
    var col_name = array_get_index(headers, "name");
    var col_sprite = array_get_index(headers, "sprite");
    var col_type = array_get_index(headers, "type");  // resource, hazard, item, etc.
    var col_value = array_get_index(headers, "value");
    // Add other columns as needed
    
    // Check if required columns exist
    if (col_object_id == -1) {
        log("Missing object_id column in object types CSV", LogImportance.ERROR, LogComponent.DATA_LOAD);
        file_text_close(file);
        return;
    }
    
    // Read data rows
    while (!file_text_eof(file)) {
        var line = file_text_read_string(file);
        file_text_readln(file);
        
        if (line == "") continue;
        
        var values = string_split(line, ";");
        
        // Create object type struct
        var object_id = values[col_object_id];
        var object_type = new ObjectTypeData(
            object_id,
            col_name != -1 ? values[col_name] : "",
            col_sprite != -1 ? values[col_sprite] : "",
            col_type != -1 ? values[col_type] : "item",
            col_value != -1 ? real(values[col_value]) : 0
            // Add other properties as needed
        );
        
        // Add to global map
        ds_map_add(global.objectTypes, object_id, object_type);
        
        log("Loaded object type: " + object_id, LogImportance.DEBUG, LogComponent.DATA_LOAD);
    }
    
    file_text_close(file);
    log("Loaded " + string(ds_map_size(global.objectTypes)) + " object types", LogImportance.INFO, LogComponent.DATA_LOAD);
}

/// @description Load mod data from CSV files
function load_mod_data() {
    log("Checking for mods", LogImportance.INFO, LogComponent.DATA_LOAD);
    
    // Check if mods folder exists
    if (!directory_exists("mods")) {
        log("Mods folder not found, skipping mod loading", LogImportance.INFO, LogComponent.DATA_LOAD);
        return;
    }
    
    // Get list of mod folders
    var mod_folders = [];
    var mod_dir = "mods";
    var file = file_find_first(mod_dir + "/*", fa_directory);
    
    while (file != "") {
        if (directory_exists(mod_dir + "/" + file)) {
            array_push(mod_folders, file);
        }
        file = file_find_next();
    }
    
    file_find_close();
    
    // Load each mod
    for (var i = 0; i < array_length(mod_folders); i++) {
        var mod_path = mod_dir + "/" + mod_folders[i];
        log("Loading mod from: " + mod_path, LogImportance.INFO, LogComponent.DATA_LOAD);
        
        // Load mod info
        if (file_exists(mod_path + "/mod_info.ini")) {
            ini_open(mod_path + "/mod_info.ini");
            var mod_name = ini_read_string("General", "Name", mod_folders[i]);
            var mod_version = ini_read_string("General", "Version", "1.0");
            ini_close();
            
            log("Loading mod: " + mod_name + " v" + mod_version, LogImportance.INFO, LogComponent.DATA_LOAD);
        }
        
        // Load mod data files to override or add to base game data
        if (file_exists(mod_path + "/hex_types.csv")) {
            load_hex_types(mod_path + "/hex_types.csv");
        }
        
        if (file_exists(mod_path + "/terrain_features.csv")) {
            load_terrain_features(mod_path + "/terrain_features.csv");
        }
        
        if (file_exists(mod_path + "/unit_types.csv")) {
            load_unit_types(mod_path + "/unit_types.csv");
        }
        
        if (file_exists(mod_path + "/object_types.csv")) {
            load_object_types(mod_path + "/object_types.csv");
        }
    }
}

/// @description Convert string to boolean
/// @param {string} str - String to convert
/// @return {bool} Converted boolean value
function bool(str) {
    str = string_lower(str);
    return (str == "true" || str == "1" || str == "yes");
}


/// @description Split a string by delimiter
/// @param {string} str - String to split
/// @param {string} delimiter - Delimiter to split by
/// @return {array<String>} Array of strings
function string_split(str, delimiter) {
    var result = [];
    var pos = string_pos(delimiter, str);
    
    while (pos > 0) {
        array_push(result, string_copy(str, 1, pos - 1));
        str = string_delete(str, 1, pos);
        pos = string_pos(delimiter, str);
    }
    
    array_push(result, str);
    return result;
}

// Constructor for HexTypeData
function HexTypeData(_hex_id, _name, _sprite, _passable) constructor {
    hex_id = _hex_id;
    name = _name;
    sprite = _sprite;
    passable = _passable;
    // Add more properties as needed
    
    static toString = function() {
        return "HexType: " + name + " (" + hex_id + ")";
    }
}

// Constructor for TerrainFeatureData
function TerrainFeatureData(_feature_id, _name, _sprite, _blocks_los) constructor {
    feature_id = _feature_id;
    name = _name;
    sprite = _sprite;
    blocks_los = _blocks_los;
    // Add more properties as needed
    
    static toString = function() {
        return "TerrainFeature: " + name + " (" + feature_id + ")";
    }
}

// Constructor for UnitTypeData
function UnitTypeData(_unit_id, _name, _sprite, _movement, _attack, _defense) constructor {
    unit_id = _unit_id;
    name = _name;
    sprite = _sprite;
    movement = _movement;
    attack = _attack;
    defense = _defense;
    // Add more properties as needed
    
    static toString = function() {
        return "UnitType: " + name + " (" + unit_id + ")";
    }
}

// Constructor for ObjectTypeData
function ObjectTypeData(_object_id, _name, _sprite, _type, _value) constructor {
    object_id = _object_id;
    name = _name;
    sprite = _sprite;
    type = _type;  // resource, hazard, item, etc.
    value = _value;
    // Add more properties as needed
    
    static toString = function() {
        return "ObjectType: " + name + " (" + object_id + ") - " + type;
    }
}