# CataClysm

CataClysm is a collection of Roblox Luau scripts and user-interface libraries. It includes game-specific utilities for FTAP as well as reusable interface components with different themes, controls, and configuration features.

## Repository Contents

| Path | Description |
| --- | --- |
| `Games/FTAP/` | FTAP-related scripts and supporting files. |
| `Games/FTAP/keyboard.lua` | A draggable on-screen keyboard with key and mouse input buttons, plus minimize and close controls. |
| `Games/FTAP/UnholdBlob.lua` | A character and vehicle-seat interaction helper for the FTAP scripts. |
| `Librarys/BetterOrion/` | A themed Orion-style interface library and its icon resources. |
| `Librarys/Obsidian/` | An interface library with supporting save and theme manager add-ons. |
| `Librarys/Vetor/` | A Luau interface toolkit with controls, notifications, input bindings, and utility components. |
| `Librarys/Worky/` | A customizable interface library with windows, tabs, themes, controls, notifications, and dialogs. |
| `Librarys/Worky/documentation.md` | Usage reference and examples for the Worky library. |

The `Librarys` directory name is retained as it appears in the repository.

## Getting Started

1. Review the source and documentation for the component you intend to use.
2. Select a library or script appropriate to your project; the UI libraries are separate implementations and are not designed to be loaded together as one framework.
3. Run and test the code in a Roblox Luau environment where you have permission to use it.

These files are source scripts rather than a packaged application. The repository does not currently define a shared installer or build process.

## Runtime Requirements

The code targets Roblox and Luau APIs, including Roblox services and GUI objects. Some scripts or library features may also rely on environment-specific capabilities such as `CoreGui` access, `loadstring`, HTTP requests, clipboard support, or filesystem functions. Availability varies by runtime, so review each source file and its dependencies before use.

## Responsible Use

Use these scripts only in experiences and environments where you are authorized to do so, and follow Roblox's terms and the rules of the experience. This project is not affiliated with or endorsed by Roblox.
