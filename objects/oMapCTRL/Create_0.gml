/// @description Create HexMap


create_hex_map(global.mapSetupData.width, global.mapSetupData.height)
// Predefined view boundaries (adjust as needed)
view_x_min = 0;
view_y_min = 0;
view_x_max = room_width;
view_y_max = room_height;

// Initialize camera variables
target_cam_x = room_width * 0.5;
target_cam_y = room_height * 0.5;
cam_x = target_cam_x;
cam_y = target_cam_y;

target_zoom = 1;   // Desired zoom factor (1 = no zoom)
zoom = target_zoom; // Current zoom value
smooth_speed = 0.1; // Smoothing factor (0.0–1.0)

// Movement and zoom speeds
camera_speed = 10;          // Pixels per step (adjustable)
zoom_keyboard_step = 0.1;   // Keyboard zoom change (10% each press)
zoom_mouse_factor = 1.1;    // Mouse wheel zoom multiplier

// Create a camera for view[0]
var vp_w = display_get_gui_width();
var vp_h = display_get_gui_height();
cam = camera_create();
camera_set_view_size(cam, vp_w, vp_h);
camera_set_view_pos(cam, round(cam_x - vp_w * 0.5), round(cam_y - vp_h * 0.5));
view_camera[0] = cam;

// Initialize dragging variables for right mouse drag movement
dragging = false;
drag_start_mouse_x = 0;
drag_start_mouse_y = 0;
drag_start_cam_x = 0;
drag_start_cam_y = 0;


