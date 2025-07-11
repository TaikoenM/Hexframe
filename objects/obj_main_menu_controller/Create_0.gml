/// Initialize the main menu
logger_write(LogLevel.INFO, "MainMenuController", "Main menu controller created", "Room transition");

// Set game state
gamestate_change(GameState.MAIN_MENU, "Entered main menu room");

// Create menu buttons
var button_configs = menu_get_main_menu_buttons();
menu_create_buttons(button_configs);

logger_write(LogLevel.INFO, "MainMenuController", "Main menu initialization complete", "Menu setup finished");
