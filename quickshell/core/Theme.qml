pragma Singleton
import QtQuick

QtObject {
    // --- TYPOGRAPHY ---
    readonly property string fontFamily:    "JetBrainsMono Nerd Font"
    readonly property string fontFamilyAlt: "FiraMono Nerd Font"
    
    readonly property int fontSizeTiny:     10
    readonly property int fontSizeSmall:    12
    readonly property int fontSize:         14
    readonly property int fontSizeLarge:    16
    readonly property int fontSizeIcon:     16

    // --- BASE LAYERS ---
    readonly property color base:           "#1a1b26"
    readonly property color mantle:         "#15161e"

    // --- SURFACES ---
    readonly property color surface0:       "#1a1b26" // Default Block background
    readonly property color surface1:       "#283457" // Hover state (Selection)
    readonly property color surface2:       "#414868" // Pressed state

    // --- TEXT ---
    readonly property color text:           "#c0caf5"
    readonly property color subtext:        "#a9b1d6"
    readonly property color overlay:        "#414868" // Borders / Div

    // --- ACCENTS ---
    readonly property color primary:        "#7aa2f7"
    readonly property color secondary:      "#bb9af7"
    readonly property color success:        "#9ece6a"
    readonly property color warning:        "#e0af68"
    readonly property color urgent:         "#f7768e"
    readonly property color info:           "#7dcfff"

    // --- LAYOUT & SHAPE ---
    readonly property color barBackground:  "transparent"
    readonly property int cornerRadius:     8
}
