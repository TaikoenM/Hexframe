/// @description Initialize the configuration manager and load settings
function config_init() {
    global.config_file = "game_config.ini";
    global.config_loaded = false;
    
    // Initialize config structure with defaults
    global.config = {
        // Display settings
        game_width: DEFAULT_GAME_WIDTH,
        game_height: DEFAULT_GAME_HEIGHT,
        fullscreen: DEFAULT_FULLSCREEN,
        vsync: true,
        
        // UI settings
        menu_button_width: 300,
        menu_button_height: 60,
        menu_button_spacing: 80,
        menu_font_size: 24,
        
        // Asset paths
        asset_path_images: "assets/images/",
        asset_path_sounds: "assets/sounds/",
        asset_path_data: "assets/data/",
        
        // Logging settings
        log_enabled: true,
        log_level: LogLevel.INFO,
        log_file: "game_log.txt",
        
        // Menu layout
        menu_center_x_offset: 0,
        menu_center_y_offset: 0,
        menu_start_y_offset: -240,
        
        // Performance settings
        target_fps: 60,
        fixed_timestep: true
    };
    
    config_load();
    config_apply_display_settings();
}

/// @description Load configuration from ini file
function config_load() {
    logger_write(LogLevel.INFO, "ConfigManager", "Loading configuration from file", global.config_file);
    
    if (!file_exists(global.config_file)) {
        logger_write(LogLevel.WARNING, "ConfigManager", "Config file not found, creating default", global.config_file);
        config_save(); // Create default config file
        return;
    }
    
    try {
        // Display settings
        global.config.game_width = ini_read_real("Display", "width", global.config.game_width);
        global.config.game_height = ini_read_real("Display", "height", global.config.game_height);
        global.config.fullscreen = ini_read_real("Display", "fullscreen", global.config.fullscreen);
        global.config.vsync = ini_read_real("Display", "vsync", global.config.vsync);
        
        // UI settings
        global.config.menu_button_width = ini_read_real("UI", "button_width", global.config.menu_button_width);
        global.config.menu_button_height = ini_read_real("UI", "button_height", global.config.menu_button_height);
        global.config.menu_button_spacing = ini_read_real("UI", "button_spacing", global.config.menu_button_spacing);
        global.config.menu_font_size = ini_read_real("UI", "font_size", global.config.menu_font_size);
        
        // Asset paths
        global.config.asset_path_images = ini_read_string("Assets", "images_path", global.config.asset_path_images);
        global.config.asset_path_sounds = ini_read_string("Assets", "sounds_path", global.config.asset_path_sounds);
        global.config.asset_path_data = ini_read_string("Assets", "data_path", global.config.asset_path_data);
        
        // Logging settings
        global.config.log_enabled = ini_read_real("Logging", "enabled", global.config.log_enabled);
        global.config.log_level = ini_read_real("Logging", "level", global.config.log_level);
        global.config.log_file = ini_read_string("Logging", "file", global.config.log_file);
        
        // Menu layout
        global.config.menu_center_x_offset = ini_read_real("Menu", "center_x_offset", global.config.menu_center_x_offset);
        global.config.menu_center_y_offset = ini_read_real("Menu", "center_y_offset", global.config.menu_center_y_offset);
        global.config.menu_start_y_offset = ini_read_real("Menu", "start_y_offset", global.config.menu_start_y_offset);
        
        // Performance settings
        global.config.target_fps = ini_read_real("Performance", "target_fps", global.config.target_fps);
        global.config.fixed_timestep = ini_read_real("Performance", "fixed_timestep", global.config.fixed_timestep);
        
        global.config_loaded = true;
        logger_write(LogLevel.INFO, "ConfigManager", "Configuration loaded successfully", "All settings applied");
        
    } catch (error) {
        logger_write(LogLevel.ERROR, "ConfigManager", "Failed to load configuration", string(error));
        global.config_loaded = false;
    }
}

/// @description Save current configuration to ini file
function config_save() {
    logger_write(LogLevel.INFO, "ConfigManager", "Saving configuration to file", global.config_file);
    
    try {
        // Display settings
        ini_write_real("Display", "width", global.config.game_width);
        ini_write_real("Display", "height", global.config.game_height);
        ini_write_real("Display", "fullscreen", global.config.fullscreen);
        ini_write_real("Display", "vsync", global.config.vsync);
        
        // UI settings
        ini_write_real("UI", "button_width", global.config.menu_button_width);
        ini_write_real("UI", "button_height", global.config.menu_button_height);
        ini_write_real("UI", "button_spacing", global.config.menu_button_spacing);
        ini_write_real("UI", "font_size", global.config.menu_font_size);
        
        // Asset paths
        ini_write_string("Assets", "images_path", global.config.asset_path_images);
        ini_write_string("Assets", "sounds_path", global.config.asset_path_sounds);
        ini_write_string("Assets", "data_path", global.config.asset_path_data);
        
        // Logging settings
        ini_write_real("Logging", "enabled", global.config.log_enabled);
        ini_write_real("Logging", "level", global.config.log_level);
        ini_write_string("Logging", "file", global.config.log_file);
        
        // Menu layout
        ini_write_real("Menu", "center_x_offset", global.config.menu_center_x_offset);
        ini_write_real("Menu", "center_y_offset", global.config.menu_center_y_offset);
        ini_write_real("Menu", "start_y_offset", global.config.menu_start_y_offset);
        
        // Performance settings
        ini_write_real("Performance", "target_fps", global.config.target_fps);
        ini_write_real("Performance", "fixed_timestep", global.config.fixed_timestep);
        
        logger_write(LogLevel.INFO, "ConfigManager", "Configuration saved successfully", "File written");
        
    } catch (error) {
        logger_write(LogLevel.ERROR, "ConfigManager", "Failed to save configuration", string(error));
    }
}

/// @description Apply display settings from configuration
function config_apply_display_settings() {
    logger_write(LogLevel.INFO, "ConfigManager", "Applying display settings", 
                string("Resolution: {0}x{1}, Fullscreen: {2}", 
                       global.config.game_width, global.config.game_height, global.config.fullscreen));
    
    // Set window size
    window_set_size(global.config.game_width, global.config.game_height);
    
    // Set fullscreen mode
    window_set_fullscreen(global.config.fullscreen);
    
    // Apply VSync
    display_set_timing_method(global.config.vsync ? tm_systemtiming : tm_sleep);
    
    // Set target FPS
    game_set_speed(global.config.target_fps, gamespeed_fps);
    
    // Update surface and application surface
    surface_resize(application_surface, global.config.game_width, global.config.game_height);
}

/// @description Get a configuration value
/// @param {string} section Configuration section
/// @param {string} key Configuration key
/// @param {any} default_value Default value if not found
/// @return {any} Configuration value
function config_get(section, key, default_value = undefined) {
    var struct_key = string("{0}.{1}", section, key);
    return struct_exists(global.config, struct_key) ? global.config[$ struct_key] : default_value;
}

/// @description Set a configuration value
/// @param {string} section Configuration section
/// @param {string} key Configuration key
/// @param {any} value Value to set
function config_set(section, key, value) {
    var struct_key = string("{0}.{1}", section, key);
    global.config[$ struct_key] = value;
    logger_write(LogLevel.DEBUG, "ConfigManager", string("Config updated: {0} = {1}", struct_key, value), "Runtime change");
}