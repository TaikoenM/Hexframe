/// @description zoom out
// Mouse wheel down: zoom out
var factor = 1 / zoom_mouse_factor;
var vp_w = display_get_gui_width();
var vp_h = display_get_gui_height();

var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

var world_mouse_x = cam_x + (mx - vp_w * 0.5) / zoom;
var world_mouse_y = cam_y + (my - vp_h * 0.5) / zoom;

target_zoom *= factor;
target_cam_x = world_mouse_x - (mx - vp_w * 0.5) / target_zoom;
target_cam_y = world_mouse_y - (my - vp_h * 0.5) / target_zoom;
