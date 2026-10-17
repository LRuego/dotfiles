
--    ██╗  ██╗██╗   ██╗██████╗ ██████╗ ██╗      █████╗ ███╗   ██╗██████╗
--    ██║  ██║╚██╗ ██╔╝██╔══██╗██╔══██╗██║     ██╔══██╗████╗  ██║██╔══██╗
--    ███████║ ╚████╔╝ ██████╔╝██████╔╝██║     ███████║██╔██╗ ██║██║  ██║
--    ██╔══██║  ╚██╔╝  ██╔═══╝ ██╔══██╗██║     ██╔══██║██║╚██╗██║██║  ██║
--    ██║  ██║   ██║   ██║     ██║  ██║███████╗██║  ██║██║ ╚████║██████╔╝
--    ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝
-- By: LRuego
-- --------------------------------------------------------------------------

-- Refer to the wiki for more information.
-- https://wiki.hypr.land/Configuring/Start/

-- hyprsplit (Lua library, replaces the old hyprpm plugin)
local hs = require("hyprsplit")


------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({ output = "DP-2",     mode = "1920x1080", position = "0x0",    scale = 1 })
hl.monitor({ output = "HDMI-A-1", mode = "1920x1080", position = "1920x0", scale = 1 })


---------------------
---- MY PROGRAMS ----
---------------------

local terminal          = "ghostty"
local fileManager       = "ghostty -e yazi"
local backupFileManager = "nemo"
local menu              = "rofi -show drun"


-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
hl.on("hyprland.start", function()
    hl.exec_cmd("discord")
    -- hl.exec_cmd("hyprsunset")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("quickshell")
    hl.exec_cmd("wl-clip-persist --clipboard regular")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")  -- Stores only text data
    hl.exec_cmd("wl-paste --type image --watch cliphist store") -- Stores only image data
end)


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "Bibata-Modern-Ice")
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Ice")
hl.env("LANG", "en_US.UTF-8")
hl.env("QT_QPA_PLATFORM", "wayland")


-----------------------
----- PERMISSIONS -----
-----------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Permissions/
-- Please note permission changes here require a Hyprland restart and are not applied on-the-fly
-- for security reasons
hl.config({
    ecosystem = {
        no_update_news      = false,
        no_donation_nag     = false,
        enforce_permissions = false,
    },
})


-----------------------
---- LOOK AND FEEL ----
-----------------------

local accentGradient = { colors = { "rgba(7aa2f7ee)", "rgba(c0caf5ee)" }, angle = 45 }
local inactiveBorder = "rgba(595959aa)"

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = { top = 15, right = 20, bottom = 20, left = 20 },

        border_size = 2,

        col = {
            active_border         = accentGradient,
            inactive_border       = inactiveBorder,
            nogroup_border_active = accentGradient,
            nogroup_border        = inactiveBorder,
        },

        resize_on_border = false,

        -- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
        allow_tearing = false,

        layout = "dwindle",
    },

    decoration = {
        rounding       = 4,
        rounding_power = 2,

        -- Change transparency of focused and unfocused windows
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        dim_special = 0,

        shadow = {
            enabled      = true,
            range        = 1,
            render_power = 3,
            color        = "rgba(1a1a1aee)",
        },

        blur = {
            enabled  = true,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },

    group = {
        drag_into_group = 2,

        col = {
            border_active          = accentGradient,
            border_inactive        = inactiveBorder,
            border_locked_active   = accentGradient,
            border_locked_inactive = inactiveBorder,
        },

        groupbar = {
            render_titles = true,
            font_size     = 10,
            height        = 12,
            text_color    = "rgba(c0caf5ee)",
            gaps_out      = 1,

            col = {
                active          = "rgba(7aa2f7ff)",
                inactive        = "rgba(24283b88)",
                locked_active   = "rgba(7aa2f7ff)",
                locked_inactive = "rgba(24283b88)",
            },
        },
    },

    animations = {
        enabled = true,
    },
})

-- Curves and animations, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1} } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1} } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}    } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1} } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}  } })

hl.animation({ leaf = "global",           enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",           enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",          enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",        enabled = true, speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",       enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",           enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",          enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",             enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",           enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",         enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",        enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",     enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut",    enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",       enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",     enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut",    enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3,    bezier = "easeOutQuint", style = "slidevert" })
hl.animation({ leaf = "zoomFactor",       enabled = true, speed = 7,    bezier = "quick" })


---------------------
---- LAYER RULES ----
---------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/#layer-rules
hl.layer_rule({ match = { namespace = "^selection$" }, no_anim = true })

-- Quickshell blur
hl.layer_rule({
    name         = "notifications-center-blur",
    match        = { namespace = "notifications-center" },
    blur         = true,
    ignore_alpha = 0.5,
})


----------------------
---- WINDOW RULES ----
----------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/

-- Floating / Dialogs
hl.window_rule({
    name   = "hyprpolkit-dialog",
    match  = { class = "^hyprpolkitagent$" },
    float  = true,
    center = true,
    group  = "deny",
})

hl.window_rule({
    name   = "system-dialog",
    match  = { title = "^(All Files|Open File|Select a File|Choose wallpaper|Open Folder|Save As|Save File|Library|File Upload).*$" },
    center = true,
    float  = true,
    group  = "deny",
})

hl.window_rule({
    name   = "save-open-dialog",
    match  = { title = "^.*wants to (save|open)$" },
    float  = true,
    center = true,
    group  = "deny",
})

hl.window_rule({
    name   = "termfilechooser",
    match  = { title = "^termfilechooser$" },
    float  = true,
    center = true,
    size   = { 1100, 650 },
    group  = "deny",
})

hl.window_rule({
    name   = "xdg-desktop-portal-dialog",
    match  = { class = "^xdg-desktop-portal-gtk$" },
    float  = true,
    center = true,
    group  = "deny",
})

hl.window_rule({
    name   = "browser-related-dialog",
    match  = { title = "^Untitled - Helium$" },
    float  = true,
    center = true,
    group  = "deny",
})

hl.window_rule({
    name  = "misc-floats",
    match = { title = "^.*(Welcome|Shell conflicts).*$" },
    float = true,
    group = "deny",
})

hl.window_rule({
    name   = "feh",
    match  = { class = "^feh$" },
    float  = true,
    center = true,
    group  = "deny",
})

hl.window_rule({ name = "openrgb",          match = { class = "^org.openrgb.OpenRGB$" }, float = true })
hl.window_rule({ name = "twintaillauncher", match = { class = "^twintaillauncher$" },    float = true })

hl.window_rule({
    name   = "satty",
    match  = { class = "^com.gabm.satty$" },
    float  = true,
    center = true,
})

-- Albion
hl.window_rule({
    name           = "albion-online",
    match          = { class = "^Albion-Online$" },
    fullscreen     = true,
    suppress_event = "fullscreen",
    group          = "deny",
})

-- Bitwarden (extension)
hl.window_rule({
    name              = "bitwarden",
    match             = { class = "^chrome-nngceckbapebfimnlniiiahkandclblb.*$" },
    float             = true,
    group             = "deny",
    keep_aspect_ratio = true,
    move              = { "monitor_w*0.79", "monitor_h*0.11" },
    size              = { 400, 600 },
})

-- Discord
hl.window_rule({
    name      = "discord",
    match     = { class = "^discord$" },
    workspace = "special:Discord silent",
})

-- Helium DevTools
hl.window_rule({
    name   = "helium-devtools",
    match  = { class = "^helium$", title = "^DevTools$" },
    float  = true,
    center = true,
    group  = "deny",
})

-- LibrePods
hl.window_rule({
    name  = "librepods",
    match = { title = "^LibrePods$" },
    float = true,
})

-- Lutris
hl.window_rule({
    name   = "lutris",
    match  = { class = "^net.lutris.Lutris$" },
    pseudo = true,
    size   = { 1200, 700 },
})

-- Nemo
hl.window_rule({
    name   = "nemo-dialogs",
    match  = { class = "^nemo$", title = "^.*(Properties|Preferences)$" },
    float  = true,
    center = true,
})

-- Neovim
hl.window_rule({
    name   = "nvim-floating",
    match  = { initial_title = "^nvim-float$" },
    float  = true,
    center = true,
    size   = { "monitor_w*0.75", "monitor_h*0.75" },
})

-- PavuControl (Volume Control)
hl.window_rule({
    name  = "pavucontrol",
    match = { class = "^(pavucontrol|org.pulseaudio.pavucontrol)$" },
    float = true,
    size  = { 600, 300 },
    move  = { "monitor_w*0.68", "monitor_h*0.026" },
    pin   = true,
})

-- Picture in Picture (PiP)
hl.window_rule({
    name              = "pip",
    match             = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" },
    float             = true,
    keep_aspect_ratio = true,
    move              = { "monitor_w*0.74", "monitor_h*0.73" },
    size              = { "monitor_w*0.25", "monitor_h*0.25" },
    pin               = true,
    group             = "deny",
})

-- Steam
hl.window_rule({
    name   = "steam-default",
    match  = { class = "^[Ss]team$" },
    float  = true,
    center = true,
    group  = "deny",
})

-- Taskbar Hero
hl.window_rule({
    name        = "taskbar-hero",
    match       = { class = "^(taskbarhero.exe|steam_app_3678970)$" },
    float       = true,
    no_shadow   = true,
    no_blur     = true,
    border_size = 0,
    group       = "deny",
})

hl.window_rule({
    name  = "steam-main",
    match = { class = "^[Ss]team$", title = "^Steam$", initial_title = "^Steam$" },
    float = false,
    group = "unset",
})

hl.window_rule({
    name  = "steam-friends",
    match = { class = "^[Ss]team$", title = "^Friends List$" },
    size  = { "monitor_w*0.2", "monitor_h*1.0" },
    float = false,
    group = "deny",
})

-- Timeshift
hl.window_rule({
    name   = "timeshift",
    match  = { class = "^timeshift-gtk$" },
    float  = true,
    center = true,
})

-- Waydroid-helper
hl.window_rule({
    name   = "waydroid-helper",
    match  = { title = "^waydroid-helper$" },
    float  = true,
    center = true,
})

-- Zathura
hl.window_rule({
    name   = "zathura",
    match  = { class = "^org.pwmt.zathura$" },
    float  = true,
    size   = { 1880, 1016 },
    center = true,
})

-- Overlayed
hl.window_rule({
    name        = "overlayed",
    match       = { class = "^Overlayed$" },
    float       = true,
    pin         = true,
    no_shadow   = true,
    group       = "deny",
    border_size = 0,
})


-------------------------
---- WORKSPACE RULES ----
-------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
hl.workspace_rule({
    workspace   = "special:Discord",
    monitor     = "DP-2",
    gaps_in     = 0,
    gaps_out    = 0,
    border_size = 0,
    no_shadow   = true,
})

-- "Smart gaps" / "No gaps when only"
-- hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
-- hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })
-- hl.window_rule({ match = { float = false, workspace = "w[tv1]" }, border_size = 0, rounding = 0 })
-- hl.window_rule({ match = { float = false, workspace = "f[1]" },   border_size = 0, rounding = 0 })


-----------------
---- LAYOUTS ----
-----------------

hl.config({
    -- See https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/
    scrolling = {
        column_width             = 0.5,
        fullscreen_on_one_column = true,
        focus_fit_method         = 1,
        follow_focus             = true,
    },

    -- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/
    dwindle = {
        preserve_split = true,
        smart_resizing = true,
        force_split    = 2, -- always split right/bottom, keeps hyprsplit swaps predictable
    },

    -- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/
    master = {
        new_status = "master",
    },
})


--------------
---- MISC ----
--------------

hl.config({
    misc = {
        font_family                    = "Inter Medium",
        force_default_wallpaper        = -1,   -- Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo          = true, -- If true disables the random hyprland logo / anime girl background. :(
        disable_splash_rendering       = true,
        middle_click_paste             = false,
        exit_window_retains_fullscreen = false,
    },
})


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,

        sensitivity    = 0, -- -1.0 - 1.0, 0 means no modification.
        accel_profile  = "flat",
        force_no_accel = true,

        scroll_method = "on_button_down",
        scroll_button = 274,

        touchpad = {
            natural_scroll = false,
        },
    },
})

-- See https://wiki.hypr.land/Configuring/Basics/Gestures/
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- Per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/
hl.device({ name = "compx-vxe-nordicmouse-1k-dongle-2", sensitivity = 0 })
hl.device({ name = "compx-vxe-nordicmouse-1k-dongle-3", sensitivity = 0 })


-------------------
---- HYPRSPLIT ----
-------------------

hs.config({ num_workspaces = 4 })


---------------------
---- KEYBINDINGS ----
---------------------

-- See https://wiki.hypr.land/Configuring/Basics/Binds/
local mainMod = "SUPER"

local function bind(keys, dispatcher, opts)
    hl.bind(mainMod .. " + " .. keys, dispatcher, opts)
end

local function exec(cmd)
    return hl.dsp.exec_cmd(cmd)
end

-- App Launcher
bind("RETURN", exec(menu))

-- Reload Hyprland
bind("CTRL + R", exec("hyprctl reload"))

-- Reload Quickshell (hard reload, mirrors browser ctrl+shift+r)
bind("CTRL + SHIFT + R", exec("quickshell ipc call shell softReload"))

-- Key Passthrough (Toggle SUPER+F1 to send all keys to VM)
bind("F1", function()
    hl.dispatch(exec('notify-send -t 1500 "Passthrough Mode" "Host shortcuts DISABLED"'))
    hl.dispatch(hl.dsp.submap("passthrough"))
end)
hl.define_submap("passthrough", function()
    bind("F1", function()
        hl.dispatch(exec('notify-send -t 1500 "Passthrough Mode" "Host shortcuts ENABLED"'))
        hl.dispatch(hl.dsp.submap("reset"))
    end)
end)

-- Screenshot
bind("SHIFT + S", exec([[grim -g "$(slurp -o -r -c '#ff0000ff')" -t ppm - | satty --filename - --output-filename $HOME/Pictures/Screenshots/$(date '+%Y%m%d-%H%M%S').png]]))

-- Instant Fullscreen Screenshot to Clipboard
bind("SHIFT + CTRL + S", exec([[grim - | wl-copy && notify-send -a "Satty" "Satty" "Screenshot Copied to clipboard."]]))

-- Window-only Screenshot
bind("CTRL + S", exec("~/.config/hypr/scripts/window_screenshot.sh"))

-- Main Browser
bind("B", exec([[~/.config/hypr/scripts/helium-safe-launch --profile-directory="Default"]]))

-- Browser Selector
bind("SHIFT + B", exec("~/.config/hypr/scripts/helium-safe-launch"))

-- Terminal
bind("Q", exec(terminal))

-- Exit
bind("SHIFT + ESCAPE", exec("uwsm stop"))

-- Clipboard Manager (Text) - Win+V style
bind("V", exec([[cliphist list | rofi -dmenu -display-columns 2 -show-icons -p "󰅇" | cliphist decode | wl-copy]]))

-- Clipboard Manager (Images)
bind("SHIFT + V", exec([[rofi -show  -modi ":~/.config/rofi/scripts/cliphist-images" -show-icons -display-columns 1 -theme ~/.config/rofi/themes/cliphist-images.rasi]]))

-- Emoji Picker - Win+. style
bind("PERIOD", exec("rofimoji --action copy"))

-- Color Picker (hyprpicker)
bind("SHIFT + P", exec("hyprpicker -a"))

-- Messaging Workspace
bind("D",         hl.dsp.workspace.toggle_special("Discord"))
bind("SHIFT + D", hl.dsp.window.move({ workspace = "special:Discord" }))

-- Close any active special workspace
bind("escape", exec("~/.config/hypr/scripts/close_special.sh"))

-- Window
bind("W",         hl.dsp.window.close())
bind("E",         exec(fileManager))
bind("SHIFT + E", exec(backupFileManager))
bind("SPACE",     hl.dsp.window.float({ action = "toggle" }))
bind("P",         hl.dsp.window.pseudo()) -- dwindle
bind("SHIFT + F", hl.dsp.window.fullscreen())

-- Grouping
bind("G",         hl.dsp.group.toggle())
bind("TAB",       hl.dsp.group.next())
bind("SHIFT + G", hl.dsp.window.move({ out_of_group = true }))

-- Move focus / swap windows with mainMod (+ SHIFT) + arrows or hjkl
local directions = {
    { "left",  "H", "left" },
    { "right", "L", "right" },
    { "up",    "K", "up" },
    { "down",  "J", "down" },
}
for _, d in ipairs(directions) do
    local arrow, vim, dir = d[1], d[2], d[3]
    bind(arrow,              hl.dsp.focus({ direction = dir }))
    bind(vim,                hl.dsp.focus({ direction = dir }))
    bind("SHIFT + " .. arrow, hl.dsp.window.move({ direction = dir }))
    bind("SHIFT + " .. vim,   hl.dsp.window.move({ direction = dir }))
end

-- Move/resize windows with mainMod + LMB/RMB and dragging
bind("mouse:272", hl.dsp.window.drag(),   { mouse = true })
bind("mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Volume Control / Media Keys
hl.bind("XF86AudioLowerVolume",  exec("wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%-"),        { locked = true, repeating = true })
hl.bind("XF86AudioRaiseVolume",  exec("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 10%+"), { locked = true, repeating = true })
hl.bind("XF86AudioMute",         exec("playerctl play-pause"),     { locked = true })
hl.bind("XF86MonBrightnessUp",   exec("brightnessctl set 5%+"),    { locked = true })
hl.bind("XF86MonBrightnessDown", exec("brightnessctl set 5%-"),    { locked = true })
hl.bind("XF86AudioNext",         exec("playerctl next"))
hl.bind("XF86AudioPause",        exec("playerctl pause"))
hl.bind("XF86AudioPlay",         exec("playerctl play"))
hl.bind("XF86AudioPrev",         exec("playerctl previous"))

-- Per-monitor workspaces (hyprsplit)
for i = 1, 4 do
    bind(tostring(i),             hs.dsp.focus({ workspace = i }))
    bind("SHIFT + " .. tostring(i), hs.dsp.window.move({ workspace = i, follow = true }))
end

-- Move window to the next/previous monitor
bind("CTRL + L", hl.dsp.window.move({ monitor = "+1" }))
bind("CTRL + H", hl.dsp.window.move({ monitor = "-1" }))

-- Swap the active workspaces between DP-2 and HDMI-A-1, keeping each layout
-- Native swap moves whole workspaces, then the ids are swapped back so hyprsplit numbering stays per-monitor
local function swap_monitors_keep_layout(name1, name2)
    return function()
        local m1, m2 = hl.get_monitor(name1), hl.get_monitor(name2)
        if not (m1 and m2 and m1.active_workspace and m2.active_workspace) then
            return
        end
        local id1, id2 = m1.active_workspace.id, m2.active_workspace.id
        local tmp = 999999

        hl.dispatch(hl.dsp.workspace.swap_monitors({ monitor1 = name1, monitor2 = name2 }))
        hl.dispatch(hl.dsp.workspace.change_id({ workspace = tostring(id1), id = tmp }))
        hl.dispatch(hl.dsp.workspace.change_id({ workspace = tostring(id2), id = id1 }))
        hl.dispatch(hl.dsp.workspace.change_id({ workspace = tostring(tmp), id = id2 }))
    end
end

bind("S", swap_monitors_keep_layout("DP-2", "HDMI-A-1"))

-- Scroll through existing workspaces with mainMod + scroll
bind("mouse_down", hs.dsp.focus({ workspace = "m+1" }))
bind("mouse_up",   hs.dsp.focus({ workspace = "m-1" }))
