enum LogImportance {
	DEBUG,
	INFO,
    WARNING,
    ERROR
}

enum LogComponent {
    MAP,
    AI,
    SOUND,
	GENERAL,
	DATA_LOAD,
	INSTANCE_CREATE
}

global.log_display_threshold = LogImportance.DEBUG
global.log_components = ds_map_create();
global.log_components[? LogComponent.MAP] = true;
global.log_components[? LogComponent.AI] = false;
global.log_components[? LogComponent.SOUND] = true;
global.log_components[? LogComponent.GENERAL] = true;
global.log_components[? LogComponent.DATA_LOAD] = true;
global.log_components[? LogComponent.INSTANCE_CREATE] = true;



// Create a ds_list as the log buffer.
global.log_buffer = ds_list_create();


global.importance_names = ["DEBUG", "INFO", "WARNING", "ERROR"];
global.component_names = ["MAP", "AI", "SOUND", "GENERAL", "DATA_LOAD", "INSTANCE_CREATE"];
	
/// @function get_timestamp
/// @desc Returns the current time as a formatted string in HH:MM:SS format.
function get_timestamp() {
    var dt = date_current_datetime();
    
    // Get hour, minute, second as strings
    var hh = string(date_get_hour(dt));
    var mm = string(date_get_minute(dt));
    var ss = string(date_get_second(dt));
    
    // Pad single-digit numbers with a leading zero
    if (string_length(hh) < 2) hh = "0" + hh;
    if (string_length(mm) < 2) mm = "0" + mm;
    if (string_length(ss) < 2) ss = "0" + ss;

    return hh + ":" + mm + ":" + ss;
}

	
	
/// @function log_game
/// @desc Formats a log message and appends it to the global log buffer.
/// @param _msg The log message.
/// @param importance A LogImportance enum value.
/// @param component A LogComponent enum value.
function log(_msg, importance = LogImportance.INFO, component = LogComponent.GENERAL) {
   
    // Format the log message.
    var log_line = "[" + get_timestamp() + "] [" + global.importance_names[importance] + "] [" + global.component_names[component] + "] " + _msg;
    
    // Append the log line to the global buffer.
    ds_list_add(global.log_buffer, log_line);
    
    // Optionally display the log message if conditions are met.
    if (importance >= global.log_display_threshold &&
        ds_map_exists(global.log_components, component) &&
        global.log_components[? component])
    {
        show_debug_message(log_line);
    }
}

/// @function flush_log_buffer
/// @desc Writes all buffered log messages to a file and clears the buffer.
function log_flush_buffer() {
    // Only write if there are messages in the buffer.
    if (ds_list_size(global.log_buffer) > 0) {
        var file = file_text_open_append("log.txt");
        for (var i = 0; i < ds_list_size(global.log_buffer); i++) {
            file_text_write_string(file, ds_list_find_value(global.log_buffer, i));
			file_text_writeln(file); 
        }
        file_text_close(file);
        ds_list_clear(global.log_buffer);
    }
}
	
	
function struct_to_log(_str, str_name, log_component) {
	log($"STRUCT {str_name} content:", LogImportance.DEBUG, log_component)
	struct_foreach(_str, function(_name, _value, log_component)
	{
	    log($"{_name}: {_value}", LogImportance.DEBUG, log_component);
	});
}