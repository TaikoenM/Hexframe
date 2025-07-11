/// @description Game state enumeration for managing different phases of the game
enum GameState {
    INITIALIZING,   // Game is starting up and initializing systems
    MAIN_MENU,      // Main menu is displayed
    IN_GAME,        // Gameplay is active
    PAUSED,         // Game is paused
    MAP_EDITOR,     // Map editor is active
    OPTIONS,        // Options menu is displayed
    TESTING         // Automated testing mode
}

/// @description Logging severity levels for the logging system
enum LogLevel {
    DEBUG,      // Detailed debug information
    INFO,       // General information messages
    WARNING,    // Warning messages
    ERROR,      // Error messages
    CRITICAL    // Critical error messages
}

/// @description Menu button types for identification and behavior
enum ButtonType {
    CONTINUE,        // Continue from saved game
    START_NEW_GAME,  // Start a new game
    OPTIONS,         // Open options menu
    MAP_EDITOR,      // Open map editor
    RUN_TESTS,       // Run automated tests
    EXIT             // Exit the game
}

// Display constants - used as fallbacks when config system fails
#macro DEFAULT_GAME_WIDTH 1920      // Default window width in pixels
#macro DEFAULT_GAME_HEIGHT 1080     // Default window height in pixels  
#macro DEFAULT_FULLSCREEN false     // Default fullscreen setting

// Runtime display macros - updated after config loads
#macro GAME_WIDTH (global.config_loaded ? global.config.game_width : DEFAULT_GAME_WIDTH)
#macro GAME_HEIGHT (global.config_loaded ? global.config.game_height : DEFAULT_GAME_HEIGHT)