Here is a clean, comprehensive, and easy-to-read Markdown documentation file. You can copy this text, save it as `keyd-setup.md` inside your Obsidian vault or a dedicated configuration folder, and refer back to it whenever you need a refresher or want to expand your layout.

---

# Custom Keyboard Layout Documentation (`keyd`)

## Overview

This document outlines the system-level keyboard customization implemented via `keyd`. The goal of this configuration is to maximize efficiency, eliminate reliance on the mouse, minimize hand travel away from the home row, and balance the physical workload between the left pinky and thumbs to prevent strain.

Unlike legacy tools like `xmodmap`, `keyd` operates at the Linux kernel level (`evdev`). This ensures the layout is **universal** (works across laptop hardware and Bluetooth keyboards like the Logi Pebble) and **persistent** (does not break when devices disconnect or sleep).

---

## 1. Core Key Mappings & Layers

### The `[main]` Layer (Default State)

* **Caps Lock (Dual-Function):** * **Hold:** Activates the custom `[nav]` (Navigation) layer.
* **Tap:** Sends the standard `Escape` key (ideal for Vim operations).


* **Left Alt:** Acts as the **Control** (`Ctrl`) modifier. This shifts heavy shortcut execution (Copy, Paste, Tab management) from the left pinky to the left thumb, mirroring ergonomic macOS behavior.

### The `[nav]` Layer (Activated by Holding Caps Lock)

When **Caps Lock** is held down, the home row and surrounding keys transform into a high-speed navigation pad:

| Physical Key | Re-mapped Action | Description |
| --- | --- | --- |
| **`h`** | `Left Arrow` | Move cursor left (Vim style) |
| **`j`** | `Down Arrow` | Move cursor down (Vim style) |
| **`k`** | `Up Arrow` | Move cursor up (Vim style) |
| **`l`** | `Right Arrow` | Move cursor right (Vim style) |
| **`y`** | `Home` | Jump to the beginning of the line |
| **`o`** | `End` | Jump to the end of the line |
| **`u`** | `Page Up` | Scroll up half a page |
| **`d`** | `Page Down` | Scroll down half a page |
| **`i`** | `Backspace` | Delete character to the left without moving hand |

---

## 2. Configuration File

The master configuration file is located at `/etc/keyd/default.conf`.

```ini
[ids]
# Applies to all internal and external connected keyboards
*

[main]
# Caps Lock: Hold for navigation layer, Tap for Escape
capslock = overload(nav, escape)

# Thumb-driven Control modifier (replaces Left Alt)
leftalt = layer(control)

[nav]
# Vim-style character navigation
h = left
j = down
k = up
l = right

# Document navigation chunks
y = home
o = end
u = pageup
d = pagedown

# Home-row backspace
i = backspace

```

---

## 3. Maintenance Cheat Sheet

### Service Management

`keyd` runs as a systemd background service. It is enabled to start automatically on boot.

* **Check service status:**
```bash
sudo systemctl status keyd

```


* **Restart the service manually:**
```bash
sudo systemctl restart keyd

```



### Applying Changes

You do **not** need to reboot your computer or restart the systemd service when you edit the configuration file. To apply new changes instantly:

```bash
sudo keyd reload

```

### Troubleshooting & Identifying Keys

If you introduce a new hardware device or want to map an unusual key, use the monitor utility to read raw kernel event strings in real-time:

```bash
keyd monitor

```

*(Press `Ctrl + C` to exit the monitor).*

---

## 4. Future Expansion Blueprint (When needed)

If a workflow eventually requires heavy use of the traditional `Alt` modifier (e.g., in a specific window manager or IDE shortcut), the bottom-left layout can be completely balanced by executing a full **Alt/Control swap**.

To restore `Alt` functionality to the left hand without losing the thumb-driven `Control` button, add this line to the `[main]` section:

```ini
[main]
leftalt = layer(control)     # Current setup: Thumb becomes Control
leftcontrol = layer(alt)     # Future addition: Corner Pinky becomes Alt

```
