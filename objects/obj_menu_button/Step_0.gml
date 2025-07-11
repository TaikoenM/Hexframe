/// Handle button input and state
if (button_data == undefined) return;

var mouse_x_gui = device_mouse_x_to_gui(0);
var mouse_y_gui = device_mouse_y_to_gui(0);

// Check if mouse is over button
var button_left = button_data.x - button_data.width / 2;
var button_right = button_data.x + button_data.width / 2;
var button_top = button_data.y - button_data.height / 2;
var button_bottom = button_data.y + button_data.height / 2;

is_hovered = (mouse_x_gui >= button_left && mouse_x_gui <= button_right && 
              mouse_y_gui >= button_top && mouse_y_gui <= button_bottom);

// Handle clicking
if (is_hovered && mouse_check_button_pressed(mb_left)) {
    is_pressed = true;
    logger_write(LogLevel.DEBUG, "MenuButton", 
                string("Button pressed: {0}", button_data.text), "User input");
}

if (is_pressed && mouse_check_button_released(mb_left)) {
    is_pressed = false;
    if (is_hovered && button_data.enabled) {
        logger_write(LogLevel.INFO, "MenuButton", 
                    string("Button clicked: {0}", button_data.text), "User interaction");
        button_data.callback();
    }
}