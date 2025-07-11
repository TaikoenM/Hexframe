/// @description Create a hex instance with data from the loaded hex type definitions
/// @param {real} x - X position to create the hex
/// @param {real} y - Y position to create the hex
/// @param {string} hex_id - ID of the hex type to create
/// @param {real} [height=0] - Height level of the hex (0-4)
/// @returns {Id.Instance} Instance ID of the created hex or noone if failed
function create_hex_instance(x, y, hex_id, height = 0) {
    // Check if the hex type exists
    if (!ds_map_exists(global.hexTypes, hex_id)) {
        log("Failed to create hex: hex_id '" + string(hex_id) + "' not found in definitions", 
            LogImportance.ERROR, LogComponent.DATA_LOAD);
        return noone;
    }
    
    // Get the hex type data
    var hex_data = global.hexTypes[? hex_id];
    
    // Create the hex instance
    var inst = instance_create_layer(x, y, "Instances", oHex);
    
    // Set up the instance with data from the hex type
    with (inst) {
        // Basic properties
        hex_type_id = hex_id;
        hex_name = hex_data.name;
        passable = hex_data.passable;
        //2DO TODO TERMINATION
		
        // Set the sprite if valid
        if (asset_get_index(hex_data.sprite) != -1) {
            sprite_index = asset_get_index(hex_data.sprite)
			
			image_index = floor(random_range(0, image_number))
			image_angle = floor(random_range(0,6))*60
			sprite_set_offset(sprite_index, round(sprite_get_width(sprite_index) * 0.5),round(sprite_get_height(sprite_index) * 0.5))  
			visible = true

		}
		else {
			sprite_index = spr_hex_grass
			log("Hex "+string("spr_hex_grass" == hex_data.sprite)+" Sprite ("+hex_data.sprite+") not found!", LogImportance.WARNING, LogComponent.INSTANCE_CREATE)
		}
        
        // Set height (clamped between 0-4)
        hex_height = clamp(height, 0, 4);
        
        // Initialize arrays for terrain features, units, and objects
        terrain_features = [];
        units = [];
        hex_objects = [];
        
        // Any other initialization...
        
       // log("Created hex of type '" + hex_name + "' at (" + string(x) + "," + string(y) + ")",             LogImportance.DEBUG, LogComponent.INSTANCE_CREATE);
    }
    
    return inst;
}

/// @description Add a terrain feature to an existing hex
/// @param {Id.Instance} hex_inst - Hex instance to add the terrain feature to
/// @param {string} feature_id - ID of the terrain feature to add
/// @returns {bool} True if successful, false otherwise
function add_terrain_feature_to_hex(hex_inst, feature_id) {
    // Check if the feature type exists
    if (!ds_map_exists(global.terrainFeatures, feature_id)) {
        log("Failed to add terrain feature: feature_id '" + string(feature_id) + "' not found in definitions", 
            LogImportance.ERROR, LogComponent.DATA_LOAD);
        return false;
    }
    
    // Get the terrain feature data
    var feature_data = global.terrainFeatures[? feature_id];
    
    // Ensure the hex instance exists and is valid
    if (!instance_exists(hex_inst) || hex_inst.object_index != oHex) {
        log("Failed to add terrain feature: invalid hex instance", 
            LogImportance.ERROR, LogComponent.INSTANCE_CREATE);
        return false;
    }
    
    // Create terrain feature struct for the hex
    var feature = {
        feature_id: feature_id,
        name: feature_data.name,
        blocks_los: feature_data.blocks_los,
        sprite: feature_data.sprite
    };
    
    // Add the feature to the hex
    with (hex_inst) {
        array_push(terrain_features, feature);
        log("Added terrain feature '" + feature.name + "' to hex at (" + string(x) + "," + string(y) + ")", 
            LogImportance.DEBUG, LogComponent.INSTANCE_CREATE);
    }
    
    return true;
}

/// @description Create a unit instance on a specified hex
/// @param {Id.Instance} hex_inst - Hex instance to place the unit on
/// @param {string} unit_id - ID of the unit type to create
/// @param {real} owner - ID of the player who owns the unit
/// @param {real} facing - Direction the unit is facing (0-5 for hex directions)
/// @returns {id} Instance ID of the created unit or noone if failed
function create_unit_instance(hex_inst, unit_id, owner, facing) {
    // Check if the unit type exists
    if (!ds_map_exists(global.unitTypes, unit_id)) {
        log("Failed to create unit: unit_id '" + string(unit_id) + "' not found in definitions", 
            LogImportance.ERROR, LogComponent.DATA_LOAD);
        return noone;
    }
    
    // Get the unit type data
    var unit_data = global.unitTypes[? unit_id];
    
    // Ensure the hex instance exists and is valid
    if (!instance_exists(hex_inst) || hex_inst.object_index != oHex) {
        log("Failed to create unit: invalid hex instance", 
            LogImportance.ERROR, LogComponent.INSTANCE_CREATE);
        return noone;
    }
    
    // Check if hex can hold more units (max 3)
    if (array_length(hex_inst.units) >= 3) {
        log("Failed to create unit: hex already has maximum units", 
            LogImportance.WARNING, LogComponent.INSTANCE_CREATE);
        return noone;
    }
    
    // Create the unit instance at the hex position
    var inst = instance_create_layer(hex_inst.x, hex_inst.y, "Units", oUnit);
    
    // Set up the instance with data from the unit type
    with (inst) {
        // Basic properties
        unit_type_id = unit_id;
        unit_name = unit_data.name;
        unit_owner = owner;
        unit_facing = clamp(facing, 0, 5); // Hex directions 0-5
        
        // Stats from unit type
        movement = unit_data.movement;
        attack = unit_data.attack;
        defense = unit_data.defense;
        
        // Set the sprite if valid
        if (sprite_exists(asset_get_index(unit_data.sprite))) {
            sprite_index = asset_get_index(unit_data.sprite);
        }
        
        // Store reference to parent hex
        parent_hex = hex_inst;
        
        // Initialize any other properties
        moved_this_turn = false;
        attacked_this_turn = false;
        
        log("Created unit '" + unit_name + "' owned by player " + string(unit_owner) + 
            " at hex (" + string(x) + "," + string(y) + ")", 
            LogImportance.DEBUG, LogComponent.INSTANCE_CREATE);
    }
    
    // Add the unit to the hex's units array
    array_push(hex_inst.units, inst);
    
    return inst;
}

/// @description Add an object to an existing hex
/// @param {Id.Instance} hex_inst - Hex instance to add the object to
/// @param {string} object_id - ID of the object type to add
/// @returns {bool} True if successful, false otherwise
function add_object_to_hex(hex_inst, object_id) {
    // Check if the object type exists
    if (!ds_map_exists(global.objectTypes, object_id)) {
        log("Failed to add object: object_id '" + string(object_id) + "' not found in definitions", 
            LogImportance.ERROR, LogComponent.DATA_LOAD);
        return false;
    }
    
    // Get the object type data
    var object_data = global.objectTypes[? object_id];
    
    // Ensure the hex instance exists and is valid
    if (!instance_exists(hex_inst) || hex_inst.object_index != oHex) {
        log("Failed to add object: invalid hex instance", 
            LogImportance.ERROR, LogComponent.INSTANCE_CREATE);
        return false;
    }
    
    // Create object struct for the hex
    var hex_object = {
        object_id: object_id,
        name: object_data.name,
        type: object_data.type,
        value: object_data.value,
        sprite: object_data.sprite
    };
    
    // Add the object to the hex
    with (hex_inst) {
        array_push(hex_objects, hex_object);
        log("Added object '" + hex_object.name + "' to hex at (" + string(x) + "," + string(y) + ")", 
            LogImportance.DEBUG, LogComponent.INSTANCE_CREATE);
    }
    
    return true;
}

/// @description Create a complete hex with terrain features, units, and objects
/// @param {real} x - X position to create the hex
/// @param {real} y - Y position to create the hex
/// @param {string} hex_id - ID of the hex type to create
/// @param {real} height - Height level of the hex (0-4)
/// @param {array} [features=[]] - Array of feature_ids to add to the hex
/// @param {array} [units=[]] - Array of unit creation data [{unit_id, owner, facing}, ...]
/// @param {array} [objects=[]] - Array of object_ids to add to the hex
/// @returns {Id.Instance} Instance ID of the created hex or noone if failed
function create_complete_hex(x, y, hex_id, height, features = [], units = [], objects = []) {
    // Create the base hex
    var hex_inst = create_hex_instance(x, y, hex_id, height);
    
    if (hex_inst == noone) {
        return noone;
    }
    
    // Add terrain features
    for (var i = 0; i < array_length(features); i++) {
        add_terrain_feature_to_hex(hex_inst, features[i]);
    }
    
    // Add units
    for (var i = 0; i < array_length(units); i++) {
        var unit_data = units[i];
        create_unit_instance(hex_inst, unit_data.unit_id, unit_data.owner, unit_data.facing);
    }
    
    // Add objects
    for (var i = 0; i < array_length(objects); i++) {
        add_object_to_hex(hex_inst, objects[i]);
    }
    
    return hex_inst;
}