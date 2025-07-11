/// @description Create menu button data structure
/// @param {ButtonType} type Type of button
/// @param {string} text Display text
/// @param {real} x X position
/// @param {real} y Y position
/// @param {function} callback Function to call when clicked
/// @return {struct} Button data structure
function menu_create_button_data(type, text, x, y, callback) {
    return {
        type: type,
        text: text,
        x: x,
        y: y,
        width: global.config.menu_button_width,
        height: global.config.menu_button_height,
        callback: callback,
        enabled: true,
        visible: true
    };
}

/// @description Factory function to create menu buttons
/// @param {array} button_configs Array of button configuration structs
function menu_create_buttons(button_configs) {
    logger_write(LogLevel.INFO, "MenuSystem", 
                string("Creating {0} menu buttons", array_length(button_configs)), "Menu initialization");
    
    for (var i = 0; i < array_length(button_configs); i++) {
        var config = button_configs[i];
        var button_instance = instance_create_layer(config.x, config.y, "UI", obj_menu_button);
        
        // Initialize button properties
        button_instance.button_data = config;
        
        logger_write(LogLevel.DEBUG, "MenuSystem", 
                    string("Created button: {0} at ({1}, {2})", config.text, config.x, config.y), 
                    "Button factory");
    }
}

/// @description Get main menu button configurations
/// @return {array} Array of button configurations
function menu_get_main_menu_buttons() {
    var center_x = global.config.game_width / 2 + global.config.menu_center_x_offset;
    var center_y = global.config.game_height / 2 + global.config.menu_center_y_offset;
    var start_y = center_y + global.config.menu_start_y_offset;
    var spacing = global.config.menu_button_spacing;
    
    var buttons = [
        menu_create_button_data(ButtonType.CONTINUE, "Continue", center_x, start_y, menu_callback_continue),
        menu_create_button_data(ButtonType.START_NEW_GAME, "Start New Game", center_x, start_y + spacing, menu_callback_new_game),
        menu_create_button_data(ButtonType.OPTIONS, "Options", center_x, start_y + spacing * 2, menu_callback_options),
        menu_create_button_data(ButtonType.MAP_EDITOR, "Map Editor", center_x, start_y + spacing * 3, menu_callback_map_editor),
        menu_create_button_data(ButtonType.RUN_TESTS, "Run Tests", center_x, start_y + spacing * 4, menu_callback_run_tests),
        menu_create_button_data(ButtonType.EXIT, "Exit", center_x, start_y + spacing * 5, menu_callback_exit)
    ];
    
    return buttons;
}

// Menu button callbacks (same as before)
function menu_callback_continue() {
    logger_write(LogLevel.INFO, "MenuSystem", "Continue button pressed", "Not implemented yet");
    // TODO: Implement continue functionality
}

function menu_callback_new_game() {
    logger_write(LogLevel.INFO, "MenuSystem", "New Game button pressed", "Not implemented yet");
    // TODO: Implement new game functionality
}

function menu_callback_options() {
    logger_write(LogLevel.INFO, "MenuSystem", "Options button pressed", "Not implemented yet");
    // TODO: Implement options functionality
}

function menu_callback_map_editor() {
    logger_write(LogLevel.INFO, "MenuSystem", "Map Editor button pressed", "Not implemented yet");
    // TODO: Implement map editor functionality
}

function menu_callback_run_tests() {
    logger_write(LogLevel.INFO, "MenuSystem", "Run Tests button pressed", "Not implemented yet");
    // TODO: Implement test runner functionality
}

function menu_callback_exit() {
    logger_write(LogLevel.INFO, "MenuSystem", "Exit button pressed", "Shutting down game");
    config_save(); // Save any runtime config changes
    assets_cleanup(); // Clean up dynamic assets
    game_end();
}