enum GameState {
    INITIALIZING,
    MAIN_MENU,
    IN_GAME,
    PAUSED,
    MAP_EDITOR,
    OPTIONS,
    TESTING
}

enum LogLevel {
    DEBUG,
    INFO,
    WARNING,
    ERROR,
    CRITICAL
}

enum ButtonType {
    CONTINUE,
    START_NEW_GAME,
    OPTIONS,
    MAP_EDITOR,
    RUN_TESTS,
    EXIT
}

// Default fallback values (only used if config fails to load)
#macro DEFAULT_GAME_WIDTH 1920
#macro DEFAULT_GAME_HEIGHT 1080
#macro DEFAULT_FULLSCREEN false