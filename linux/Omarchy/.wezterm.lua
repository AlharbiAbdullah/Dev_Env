local wezterm = require("wezterm")
local config = {}

if wezterm.config_builder then
    config = wezterm.config_builder()
end

-- BiDi support for Arabic RTL
config.bidi_enabled = true
config.bidi_direction = "AutoLeftToRight"

-- Font
config.font = wezterm.font_with_fallback({
    { family = "NotoSansM Nerd Font", harfbuzz_features = { "liga=0" } },
    { family = "Cairo", weight = "Bold" },
    "Noto Color Emoji",
})
config.font_size = 14.0

-- Gruvbox Dark
config.colors = {
    background = "#282828",
    foreground = "#ebdbb2",
    cursor_bg = "#ebdbb2",
    cursor_fg = "#282828",
    selection_bg = "#665c54",
    selection_fg = "#ebdbb2",

    ansi = {
        "#282828",
        "#cc241d",
        "#98971a",
        "#d79921",
        "#458588",
        "#b16286",
        "#689d6a",
        "#a89984",
    },
    brights = {
        "#928374",
        "#fb4934",
        "#b8bb26",
        "#fabd2f",
        "#83a598",
        "#d3869b",
        "#8ec07c",
        "#ebdbb2",
    },
}

-- Wayland support
config.enable_wayland = true

-- Keybindings
config.keys = {
    { key = "Enter", mods = "SHIFT", action = wezterm.action.SendString("\n") },
}

config.window_close_confirmation = "NeverPrompt"

return config
