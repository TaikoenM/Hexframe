/// Initialize the game during the init phase

// Initialize configuration first (before logging)
config_init();

// Initialize logging system (uses config)
logger_init();

// Initialize other systems
gamestate_init();
assets_init();

logger_write(LogLevel.INFO, "GameController", "Game initialization started", "System startup");

// Load main menu background
assets_load_sprite("mainmenu_background");

// Transition to main menu
gamestate_change(GameState.MAIN_MENU, "Initialization complete");
room_goto(room_main_menu);

logger_write(LogLevel.INFO, "GameController", "Transitioning to main menu", "Initialization complete");