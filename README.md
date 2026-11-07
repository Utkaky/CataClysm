# CataClysm

CataClysm is a collection of Roblox Luau scripts and standalone user-interface libraries. The repository brings together FTAP-related utilities and several UI frameworks with different components, themes, and configuration options.

## Repository Structure

```text
Roblox/
├── Games/
│   └── FTAP/
│       ├── keyboard.lua
│       ├── Module
│       ├── plots
│       └── UnholdBlob.lua
└── Librarys/
    ├── BetterOrion/
    │   ├── icons
    │   └── Library.lua
    ├── Obsidian/
    │   ├── addons/
    │   │   ├── SaveM.lua
    │   │   └── ThemeM.lua
    │   └── Library.lua
    ├── Vetor/
    │   └── Library.lua
    └── Worky/
        ├── assets
        ├── documentation.md
        └── Library.lua
```

`Librarys` is the directory name used in the repository.

## Components

### FTAP scripts

The `Roblox/Games/FTAP/` folder contains scripts and supporting files for FTAP. `keyboard.lua` provides an on-screen keyboard interface, while `UnholdBlob.lua` contains a character and vehicle-seat interaction helper. Review each script and its dependencies before using it.

### UI libraries

The libraries are independent implementations; choose one that fits your project rather than treating them as a single framework.

| Library | Overview |
| --- | --- |
| **BetterOrion** | Orion-style interface library with theme and icon resources. |
| **Obsidian** | Interface library with separate save-manager and theme-manager add-ons. |
| **Vetor** | UI toolkit with controls, notifications, input bindings, and utility components. |
| **Worky** | Customizable windows, tabs, themes, controls, notifications, and dialogs. See the [Worky documentation](Roblox/Librarys/Worky/documentation.md) for usage examples. |

## Getting Started

1. Browse `Roblox/Games/FTAP/` or `Roblox/Librarys/` and select the script or library you need.
2. Read any component-specific documentation and check the source for dependencies and runtime assumptions.
3. Use and test the code only in Roblox experiences and environments where you are authorized to do so.

This repository contains source files, not a packaged application. It does not define a shared installer, build process, or test suite.

## Runtime Requirements

The code targets Roblox and Luau APIs, including Roblox services and GUI objects. Depending on the selected script or library, some features may also rely on environment-specific capabilities such as access to `CoreGui`, HTTP requests, clipboard support, or filesystem functions. These capabilities are not available in every runtime.
