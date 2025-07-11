/// @description Initialize the asset manager
function assets_init() {
    global.loaded_sprites = ds_map_create();
    global.loaded_sounds = ds_map_create();
    global.asset_manifest = ds_map_create();
    
    logger_write(LogLevel.INFO, "AssetManager", "Asset manager initialized", "System startup");
    assets_load_manifest();
}

/// @description Load asset manifest file
function assets_load_manifest() {
    var manifest_file = global.config.asset_path_data + "asset_manifest.ini";
    
    if (!file_exists(manifest_file)) {
        logger_write(LogLevel.WARNING, "AssetManager", "Asset manifest not found, creating default", manifest_file);
        assets_create_default_manifest();
        return;
    }
    
    logger_write(LogLevel.INFO, "AssetManager", "Loading asset manifest", manifest_file);
    
    // Load image assets
    var image_count = ini_read_real("Images", "count", 0);
    for (var i = 0; i < image_count; i++) {
        var asset_key = ini_read_string("Images", string("asset_{0}_key", i), "");
        var asset_file = ini_read_string("Images", string("asset_{0}_file", i), "");
        
        if (asset_key != "" && asset_file != "") {
            global.asset_manifest[? asset_key] = global.config.asset_path_images + asset_file;
        }
    }
    
    logger_write(LogLevel.INFO, "AssetManager", string("Loaded {0} asset definitions", ds_map_size(global.asset_manifest)), "Manifest processed");
}

/// @description Create default asset manifest
function assets_create_default_manifest() {
    var manifest_file = global.config.asset_path_data + "asset_manifest.ini";
    
    // Create default manifest
    ini_write_real("Images", "count", 1);
    ini_write_string("Images", "asset_0_key", "mainmenu_background");
    ini_write_string("Images", "asset_0_file", "mainmenu_background.png");
    
    logger_write(LogLevel.INFO, "AssetManager", "Created default asset manifest", manifest_file);
}

/// @description Load a sprite dynamically
/// @param {string} asset_key Key identifier for the asset
/// @return {sprite} Sprite resource or -1 if failed
function assets_load_sprite(asset_key) {
    // Check if already loaded
    if (ds_map_exists(global.loaded_sprites, asset_key)) {
        return global.loaded_sprites[? asset_key];
    }
    
    // Get file path from manifest
    var file_path = global.asset_manifest[? asset_key];
    if (is_undefined(file_path)) {
        logger_write(LogLevel.ERROR, "AssetManager", string("Asset key not found in manifest: {0}", asset_key), "Missing asset definition");
        return -1;
    }
    
    // Check if file exists
    if (!file_exists(file_path)) {
        logger_write(LogLevel.ERROR, "AssetManager", string("Asset file not found: {0}", file_path), "Missing file");
        return -1;
    }
    
    try {
        // Load the sprite
        var sprite_id = sprite_add(file_path, 0, false, false, 0, 0);
        
        if (sprite_id == -1) {
            logger_write(LogLevel.ERROR, "AssetManager", string("Failed to load sprite: {0}", file_path), "Sprite loading error");
            return -1;
        }
        
        // Cache the loaded sprite
        global.loaded_sprites[? asset_key] = sprite_id;
        
        logger_write(LogLevel.INFO, "AssetManager", string("Loaded sprite: {0} from {1}", asset_key, file_path), "Dynamic loading");
        return sprite_id;
        
    } catch (error) {
        logger_write(LogLevel.ERROR, "AssetManager", string("Exception loading sprite {0}: {1}", asset_key, error), "Loading exception");
        return -1;
    }
}

/// @description Get a loaded sprite or load it if not cached
/// @param {string} asset_key Key identifier for the asset
/// @return {sprite} Sprite resource or -1 if failed
function assets_get_sprite(asset_key) {
    var sprite_id = global.loaded_sprites[? asset_key];
    if (is_undefined(sprite_id)) {
        return assets_load_sprite(asset_key);
    }
    return sprite_id;
}

/// @description Cleanup asset manager
function assets_cleanup() {
    // Free all loaded sprites
    var key = ds_map_find_first(global.loaded_sprites);
    while (!is_undefined(key)) {
        var sprite_id = global.loaded_sprites[? key];
        if (sprite_exists(sprite_id)) {
            sprite_delete(sprite_id);
        }
        key = ds_map_find_next(global.loaded_sprites, key);
    }
    
    ds_map_destroy(global.loaded_sprites);
    ds_map_destroy(global.loaded_sounds);
    ds_map_destroy(global.asset_manifest);
    
    logger_write(LogLevel.INFO, "AssetManager", "Asset manager cleaned up", "System shutdown");
}
