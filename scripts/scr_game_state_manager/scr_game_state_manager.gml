/// @description Initialize the game state manager
function gamestate_init() {
    global.game_state = GameState.INITIALIZING;
    global.previous_game_state = GameState.INITIALIZING;
    global.state_change_callbacks = ds_map_create();
    
    logger_write(LogLevel.INFO, "GameStateManager", "Game state manager initialized", "System startup");
}

/// @description Change the current game state
/// @param {GameState} new_state The new state to transition to
/// @param {string} reason Reason for state change
function gamestate_change(new_state, reason = "") {
    if (global.game_state == new_state) {
        logger_write(LogLevel.WARNING, "GameStateManager", 
                    string("Attempted to change to same state: {0}", new_state), reason);
        return false;
    }
    
    global.previous_game_state = global.game_state;
    global.game_state = new_state;
    
    logger_write(LogLevel.INFO, "GameStateManager", 
                string("State changed from {0} to {1}", global.previous_game_state, new_state), reason);
    
    // Execute callbacks for this state change
    gamestate_execute_callbacks(new_state);
    return true;
}

/// @description Get current game state
/// @return {GameState} Current game state
function gamestate_get() {
    return global.game_state;
}

/// @description Register a callback for state changes
/// @param {GameState} state State to watch for
/// @param {function} callback Function to call when state is entered
function gamestate_register_callback(state, callback) {
    var callback_list = global.state_change_callbacks[? state];
    if (is_undefined(callback_list)) {
        callback_list = ds_list_create();
        global.state_change_callbacks[? state] = callback_list;
    }
    ds_list_add(callback_list, callback);
}

/// @description Execute callbacks for a given state
/// @param {GameState} state State that was entered
function gamestate_execute_callbacks(state) {
    var callback_list = global.state_change_callbacks[? state];
    if (!is_undefined(callback_list)) {
        for (var i = 0; i < ds_list_size(callback_list); i++) {
            var callback = callback_list[| i];
            callback();
        }
    }
}