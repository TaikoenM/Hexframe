// In the Draw GUI event of obj_mapController:
// set debug_mode = true in Create event for debugging
    // Get GUI dimensions
    var vp_w = display_get_gui_width();
    var vp_h = display_get_gui_height();
    
    // Compute minimum allowed zoom (ensuring view rectangle does not exceed bounds)
    var min_zoom_x = vp_w / (view_x_max - view_x_min);
    var min_zoom_y = vp_h / (view_y_max - view_y_min);
    var min_allowed_zoom = max(min_zoom_x, min_zoom_y);
    
    // Calculate current view dimensions in world coordinates
    var view_w = vp_w / zoom;
    var view_h = vp_h / zoom;
    var half_view_w = view_w * 0.5;
    var half_view_h = view_h * 0.5;
    
    // Calculate current view rectangle (room pixels)
    var view_left   = cam_x - half_view_w;
    var view_top    = cam_y - half_view_h;
    var view_right  = cam_x + half_view_w;
    var view_bottom = cam_y + half_view_h;
    
    // Assemble debug text with all relevant values
    var debugText = "";
    debugText += "cam_x: " + string(cam_x) + "\n";
    debugText += "cam_y: " + string(cam_y) + "\n";
    debugText += "target_cam_x: " + string(target_cam_x) + "\n";
    debugText += "target_cam_y: " + string(target_cam_y) + "\n";
    debugText += "zoom: " + string(zoom) + "\n";
    debugText += "target_zoom: " + string(target_zoom) + "\n";
    debugText += "min_allowed_zoom: " + string(min_allowed_zoom) + "\n";
    debugText += "View size: " + string(view_w) + " x " + string(view_h) + "\n";
    debugText += "Current view rect: L:" + string(view_left) + " T:" + string(view_top) + " R:" + string(view_right) + " B:" + string(view_bottom) + "\n";
    debugText += "Bounds rect: L:" + string(view_x_min) + " T:" + string(view_y_min) + " R:" + string(view_x_max) + " B:" + string(view_y_max);
    
    // Draw the debug text on the GUI
    draw_set_color(c_white);
    draw_text(10, 10, debugText);

