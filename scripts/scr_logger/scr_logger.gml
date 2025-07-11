/// @description Initialize the logging system
function logger_init() {
    if (!global.config.log_enabled) {
        global.log_enabled = false;
        return;
    }
    
    global.log_enabled = true;
    global.log_file = global.config.log_file;
    global.log_level = global.config.log_level;
    global.log_session_start = date_current_datetime();
    
    // Clear previous log
    if (file_exists(global.log_file)) {
        file_delete(global.log_file);
    }
    
    logger_write(LogLevel.INFO, "Logger", "Logging system initialized", "System startup");
}

/// @description Write a log entry
/// @param {LogLevel} level Severity level
/// @param {string} source Source of the log entry
/// @param {string} message Main log message
/// @param {string} reason Additional context/reason
function logger_write(level, source, message, reason = "") {
    if (!global.log_enabled || level < global.log_level) return;
    
    var level_text = "";
    switch(level) {
        case LogLevel.DEBUG:    level_text = "DEBUG"; break;
        case LogLevel.INFO:     level_text = "INFO"; break;
        case LogLevel.WARNING:  level_text = "WARN"; break;
        case LogLevel.ERROR:    level_text = "ERROR"; break;
        case LogLevel.CRITICAL: level_text = "CRIT"; break;
    }
    
    var timestamp = string(date_current_datetime());
    var log_entry = string("{0} [{1}] {2}: {3}", timestamp, level_text, source, message);
    if (reason != "") {
        log_entry += string(" | Reason: {0}", reason);
    }
    
    // Write to file
    var file = file_text_open_append(global.log_file);
    file_text_write_string(file, log_entry);
    file_text_writeln(file);
    file_text_close(file);
    
    // Also output to console for debugging
    show_debug_message(log_entry);
}
