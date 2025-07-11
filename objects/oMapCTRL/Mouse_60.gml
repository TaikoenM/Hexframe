/// @description zoom in
// Mouse wheel up: zoom in
var factor = zoom_mouse_factor;
var vp_w = display_get_gui_width();
var vp_h = display_get_gui_height();

// Get mouse position in GUI coordinates
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

// Calculate the world coordinate under the mouse before zooming
var world_mouse_x = cam_x + (mx - vp_w * 0.5) / zoom;
var world_mouse_y = cam_y + (my - vp_h * 0.5) / zoom;

// Adjust target zoom and update target camera so that the mouse point stays fixed
target_zoom *= factor;
target_cam_x = world_mouse_x - (mx - vp_w * 0.5) / target_zoom;
target_cam_y = world_mouse_y - (my - vp_h * 0.5) / target_zoom;

