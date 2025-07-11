// --- Keyboard panning (arrow keys, WSAD) ---
// Left / A
if (keyboard_check(vk_left) || keyboard_check(ord("A")))
    target_cam_x -= camera_speed / zoom;
// Right / D
if (keyboard_check(vk_right) || keyboard_check(ord("D")))
    target_cam_x += camera_speed / zoom;
// Up / W
if (keyboard_check(vk_up) || keyboard_check(ord("W")))
    target_cam_y -= camera_speed / zoom;
// Down / S
if (keyboard_check(vk_down) || keyboard_check(ord("S")))
    target_cam_y += camera_speed / zoom;

// --- Mouse Drag Panning (Right Button) ---
// Begin dragging on right button press.
if (mouse_check_button_pressed(mb_right)) {
    dragging = true;
    drag_start_mouse_x = device_mouse_x_to_gui(0);
    drag_start_mouse_y = device_mouse_y_to_gui(0);
    drag_start_cam_x = target_cam_x;
    drag_start_cam_y = target_cam_y;
}

// Process dragging.
if (dragging) {
    if (mouse_check_button(mb_right)) {
        var cur_mx = device_mouse_x_to_gui(0);
        var cur_my = device_mouse_y_to_gui(0);
        var dx = cur_mx - drag_start_mouse_x;
        var dy = cur_my - drag_start_mouse_y;
        target_cam_x = drag_start_cam_x - dx / zoom;
        target_cam_y = drag_start_cam_y - dy / zoom;
    } else {
        dragging = false;
    }
}

// --- Keyboard Zooming (centered zoom) ---
// Q to zoom in, E to zoom out.
if (keyboard_check_pressed(ord("Q")))
    target_zoom *= (1 + zoom_keyboard_step);
if (keyboard_check_pressed(ord("E")))
    target_zoom *= (1 - zoom_keyboard_step);

// --- Calculate minimum allowed zoom ---
// Prevent the view rectangle from exceeding bounds.
var vp_w = display_get_gui_width();
var vp_h = display_get_gui_height();
var min_zoom_x = vp_w / (view_x_max - view_x_min);
var min_zoom_y = vp_h / (view_y_max - view_y_min);
var min_allowed_zoom = max(min_zoom_x, min_zoom_y);
if (target_zoom < min_allowed_zoom)
    target_zoom = min_allowed_zoom;

// --- Disallow zoom greater than 2 ---
if (target_zoom > 2)
    target_zoom = 2;

// --- Clamp target_cam_x and target_cam_y based on target_zoom ---
var target_view_w = vp_w / target_zoom;
var target_view_h = vp_h / target_zoom;
var half_target_view_w = target_view_w * 0.5;
var half_target_view_h = target_view_h * 0.5;
target_cam_x = clamp(target_cam_x, view_x_min + half_target_view_w, view_x_max - half_target_view_w);
target_cam_y = clamp(target_cam_y, view_y_min + half_target_view_h, view_y_max - half_target_view_h);

// --- Smooth interpolation for camera position and zoom ---
cam_x = lerp(cam_x, target_cam_x, smooth_speed);
cam_y = lerp(cam_y, target_cam_y, smooth_speed);
zoom   = lerp(zoom, target_zoom, smooth_speed);

// --- Calculate view size based on current zoom ---
// Force view dimensions to integers.
var view_w = round(vp_w / zoom);
var view_h = round(vp_h / zoom);
var half_view_w = view_w * 0.5;
var half_view_h = view_h * 0.5;

// --- Clamp the current camera center to keep view within bounds ---
cam_x = clamp(cam_x, view_x_min + half_view_w, view_x_max - half_view_w);
cam_y = clamp(cam_y, view_y_min + half_view_h, view_y_max - half_view_h);

// --- Update camera viewport using integer values ---
// Round the position to ensure integer coordinates.
camera_set_view_size(cam, view_w, view_h);
camera_set_view_pos(cam, round(cam_x - half_view_w), round(cam_y - half_view_h));
