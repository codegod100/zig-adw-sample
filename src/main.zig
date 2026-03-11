const std = @import("std");
const c = @cImport({
    @cInclude("gtk/gtk.h");
});

// App state
const App = struct {
    app: *c.GtkApplication,
    window: ?*c.GtkWindow,
    counter: i32,
};

var app_state = App{
    .app = undefined,
    .window = null,
    .counter = 0,
};

fn onActivate(app: *c.GtkApplication, _: c.gpointer) callconv(.c) void {
    // Create window
    const window = c.gtk_application_window_new(app);
    app_state.window = @ptrCast(window);
    c.gtk_window_set_title(@ptrCast(window), "Zig GTK4 Sample");
    c.gtk_window_set_default_size(@ptrCast(window), 800, 600);

    // Main vertical box
    const content = c.gtk_box_new(c.GTK_ORIENTATION_VERTICAL, 0);

    // Header bar
    const header = c.gtk_header_bar_new();
    c.gtk_window_set_titlebar(@ptrCast(window), @ptrCast(header));

    // Menu button
    const menu_btn = c.gtk_menu_button_new();
    const menu = c.g_menu_new();
    c.g_menu_append(menu, "About", "app.about");
    c.g_menu_append(menu, "Quit", "app.quit");
    c.gtk_menu_button_set_menu_model(@ptrCast(menu_btn), @ptrCast(@alignCast(menu)));
    c.gtk_menu_button_set_icon_name(@ptrCast(menu_btn), "open-menu-symbolic");
    c.gtk_header_bar_pack_end(@ptrCast(header), @ptrCast(menu_btn));

    // Main content box with padding
    const main_box = c.gtk_box_new(c.GTK_ORIENTATION_VERTICAL, 12);
    c.gtk_widget_set_margin_top(@ptrCast(main_box), 24);
    c.gtk_widget_set_margin_bottom(@ptrCast(main_box), 24);
    c.gtk_widget_set_margin_start(@ptrCast(main_box), 24);
    c.gtk_widget_set_margin_end(@ptrCast(main_box), 24);

    // Title label
    const title = c.gtk_label_new("Welcome to Zig + GTK4!");
    c.gtk_box_append(@ptrCast(main_box), @ptrCast(title));

    // Subtitle
    const subtitle = c.gtk_label_new("Fast compilation, native look, no CGO");
    c.gtk_box_append(@ptrCast(main_box), @ptrCast(subtitle));

    // Info box
    const info_box = c.gtk_box_new(c.GTK_ORIENTATION_VERTICAL, 8);
    c.gtk_widget_set_margin_top(@ptrCast(info_box), 24);
    c.gtk_widget_set_halign(@ptrCast(info_box), c.GTK_ALIGN_CENTER);

    const info_icon = c.gtk_image_new_from_icon_name("application-x-addon-symbolic");
    c.gtk_image_set_pixel_size(@ptrCast(info_icon), 64);
    c.gtk_box_append(@ptrCast(info_box), @ptrCast(info_icon));

    const info_title = c.gtk_label_new("Zig GTK4 Demo");
    c.gtk_box_append(@ptrCast(info_box), @ptrCast(info_title));

    const info_desc = c.gtk_label_new("GTK4 via direct C FFI");
    c.gtk_box_append(@ptrCast(info_box), @ptrCast(info_desc));

    c.gtk_box_append(@ptrCast(main_box), @ptrCast(info_box));

    // Button box
    const btn_box = c.gtk_box_new(c.GTK_ORIENTATION_HORIZONTAL, 6);
    c.gtk_widget_set_halign(@ptrCast(btn_box), c.GTK_ALIGN_CENTER);
    c.gtk_widget_set_margin_top(@ptrCast(btn_box), 12);

    // Counter label
    const counter_label = c.gtk_label_new("Count: 0");

    // Primary button
    const btn1 = c.gtk_button_new_with_label("Click Me!");
    _ = c.g_signal_connect_data(@ptrCast(btn1), "clicked", @ptrCast(&onClicked), @ptrCast(counter_label), null, 0);
    c.gtk_box_append(@ptrCast(btn_box), @ptrCast(btn1));

    // Secondary button
    const btn2 = c.gtk_button_new_with_label("Secondary");
    _ = c.g_signal_connect_data(@ptrCast(btn2), "clicked", @ptrCast(&onSecondary), null, null, 0);
    c.gtk_box_append(@ptrCast(btn_box), @ptrCast(btn2));

    c.gtk_box_append(@ptrCast(main_box), @ptrCast(btn_box));

    // Preferences section
    const prefs_frame = c.gtk_frame_new("Preferences");
    c.gtk_widget_set_margin_top(@ptrCast(prefs_frame), 24);

    const prefs_box = c.gtk_box_new(c.GTK_ORIENTATION_VERTICAL, 12);
    c.gtk_widget_set_margin_top(@ptrCast(prefs_box), 12);
    c.gtk_widget_set_margin_bottom(@ptrCast(prefs_box), 12);
    c.gtk_widget_set_margin_start(@ptrCast(prefs_box), 12);
    c.gtk_widget_set_margin_end(@ptrCast(prefs_box), 12);

    // Switch row
    const switch_box = c.gtk_box_new(c.GTK_ORIENTATION_HORIZONTAL, 12);
    const switch_label = c.gtk_label_new("Enable Feature");
    c.gtk_widget_set_hexpand(@ptrCast(switch_label), 1);
    c.gtk_widget_set_halign(@ptrCast(switch_label), c.GTK_ALIGN_START);
    const sw = c.gtk_switch_new();
    c.gtk_switch_set_active(@ptrCast(sw), 1);
    c.gtk_box_append(@ptrCast(switch_box), @ptrCast(switch_label));
    c.gtk_box_append(@ptrCast(switch_box), @ptrCast(sw));
    c.gtk_box_append(@ptrCast(prefs_box), @ptrCast(switch_box));

    // Entry row
    const entry_box = c.gtk_box_new(c.GTK_ORIENTATION_HORIZONTAL, 12);
    const entry_label = c.gtk_label_new("Name");
    c.gtk_widget_set_hexpand(@ptrCast(entry_label), 1);
    c.gtk_widget_set_halign(@ptrCast(entry_label), c.GTK_ALIGN_START);
    const entry = c.gtk_entry_new();
    c.gtk_widget_set_hexpand(@ptrCast(entry), 1);
    c.gtk_entry_set_placeholder_text(@ptrCast(entry), "Enter your name");
    c.gtk_box_append(@ptrCast(entry_box), @ptrCast(entry_label));
    c.gtk_box_append(@ptrCast(entry_box), @ptrCast(entry));
    c.gtk_box_append(@ptrCast(prefs_box), @ptrCast(entry_box));

    c.gtk_frame_set_child(@ptrCast(prefs_frame), @ptrCast(prefs_box));
    c.gtk_box_append(@ptrCast(main_box), @ptrCast(prefs_frame));

    c.gtk_box_append(@ptrCast(content), @ptrCast(main_box));
    c.gtk_window_set_child(@ptrCast(window), @ptrCast(content));

    // Setup actions
    setupActions(app);

    c.gtk_window_present(@ptrCast(window));
}

fn onClicked(_: *c.GtkWidget, data: c.gpointer) callconv(.c) void {
    app_state.counter += 1;
    const label: *c.GtkLabel = @ptrCast(data);
    var buf: [32]u8 = undefined;
    const text = std.fmt.bufPrintZ(&buf, "Count: {}", .{app_state.counter}) catch return;
    c.gtk_label_set_text(label, text.ptr);
}

fn onSecondary(_: *c.GtkWidget, _: c.gpointer) callconv(.c) void {
    if (app_state.window) |w| {
        const dialog = c.gtk_message_dialog_new(
            w,
            c.GTK_DIALOG_DESTROY_WITH_PARENT | c.GTK_DIALOG_MODAL,
            c.GTK_MESSAGE_INFO,
            c.GTK_BUTTONS_OK,
            "Secondary button clicked!",
        );
        c.gtk_window_set_title(@ptrCast(dialog), "Info");
        _ = c.g_signal_connect_data(@ptrCast(dialog), "response", @ptrCast(&onDialogResponse), null, null, 0);
        c.gtk_window_present(@ptrCast(dialog));
    }
}

fn onDialogResponse(dialog: *c.GtkDialog, _: c.gint, _: c.gpointer) callconv(.c) void {
    c.gtk_window_close(@ptrCast(dialog));
}

fn onAbout(_: *c.GSimpleAction, _: *c.GVariant, _: c.gpointer) callconv(.c) void {
    const about = c.gtk_about_dialog_new();
    c.gtk_about_dialog_set_program_name(@ptrCast(about), "Zig GTK4 Sample");
    c.gtk_about_dialog_set_logo_icon_name(@ptrCast(about), "application-x-addon-symbolic");
    c.gtk_about_dialog_set_version(@ptrCast(about), "0.1.0");
    c.gtk_about_dialog_set_comments(@ptrCast(about), "A sample GTK4 app in Zig");
    c.gtk_about_dialog_set_website(@ptrCast(about), "https://ziglang.org");
    c.gtk_about_dialog_set_copyright(@ptrCast(about), "© 2024");
    if (app_state.window) |w| {
        c.gtk_window_set_transient_for(@ptrCast(about), w);
    }
    c.gtk_window_present(@ptrCast(about));
}

fn onQuit(_: *c.GSimpleAction, _: *c.GVariant, _: c.gpointer) callconv(.c) void {
    c.g_application_quit(@ptrCast(app_state.app));
}

fn setupActions(app: *c.GtkApplication) void {
    // About action
    const about_action = c.g_simple_action_new("about", null);
    _ = c.g_signal_connect_data(@ptrCast(about_action), "activate", @ptrCast(&onAbout), null, null, 0);
    c.g_action_map_add_action(@ptrCast(app), @ptrCast(about_action));

    // Quit action
    const quit_action = c.g_simple_action_new("quit", null);
    _ = c.g_signal_connect_data(@ptrCast(quit_action), "activate", @ptrCast(&onQuit), null, null, 0);
    c.g_action_map_add_action(@ptrCast(app), @ptrCast(quit_action));
}

pub fn main() !void {
    const app = c.gtk_application_new("com.example.zig-gtk-sample", c.G_APPLICATION_DEFAULT_FLAGS);
    app_state.app = @ptrCast(app);
    defer c.g_object_unref(app);

    _ = c.g_signal_connect_data(app, "activate", @ptrCast(&onActivate), null, null, 0);

    const status = c.g_application_run(@ptrCast(app), 0, null);
    if (status != 0) std.process.exit(1);
}
