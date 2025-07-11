/// Draw the menu button
if (button_data == undefined || !button_data.visible) return;

// Determine button color based on state
var current_color = button_color;
if (is_pressed) {
    current_color = button_color_pressed;
} else if (is_hovered) {
    current_color = button_color_hover;
}

// Draw button background
draw_set_color(current_color);
var button_left = button_data.x - button_data.width / 2;
var button_top = button_data.y - button_data.height / 2;
draw_rectangle(button_left, button_top, 
               button_left + button_data.width, 
               button_top + button_data.height, false);

// Draw button border
draw_set_color(c_white);
draw_rectangle(button_left, button_top, 
               button_left + button_data.width, 
               button_top + button_data.height, true);

// Draw button text
draw_set_color(text_color);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(button_data.x, button_data.y, button_data.text);

// Reset draw settings
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);