
Lathgate.gg

A lightweight, zero-dependency personal website and local network (LAN) hub featuring a single-file HTML/CSS/JS frontend, custom themes, a shared editable LAN guestbook, and a native Windows PowerShell system tray server.

Features

• Zero External Dependencies: Single-file frontend (lathgategg.htm) with custom SVG icons and dynamic favicon injection.
• Custom Themes & Live Overrides: Includes 6 built-in themes (Default Dark, Midnight OLED, Nord Frost, Clean Light, Sunset Synth, and Matrix Terminal) plus custom background and accent color pickers saved to localStorage.
• Responsive Mobile & Desktop UI: Automatically detects mobile vs. desktop viewports, adapts button layouts, and supports real-time touch swipe gestures for the slide-out navigation sidebar.
• Shared Editable LAN Guestbook: Built-in message wall backed by /api/guestbook (guestbook.json) with full post, edit, delete, and Enter-to-send support for devices on the same Wi-Fi network.
• System Tray Server: Runs silently in the Windows System Tray (tray-server.ps1) on Port 80 with a custom fox icon (fox.ico) and quick controls to open or stop the server.

1. Folder & File Placement

• Set up a root folder named lathgate.gg on your Windows Desktop (%USERPROFILE%\Desktop\lathgate.gg).
• Add the essential files to the directory: lathgategg.htm, tray-server.ps1, Start lathgate.bat, fox.png, and fox.ico.
• Optionally include a legacy/ backup archive folder and a guestbook.json data file.

. One-Time Windows Port 80 & mDNS Setup

Open Command Prompt as Administrator and run the following commands individually:
• Allow PowerShell on Port 80:
To complete the Windows Port 80, firewall, Bonjour service configuration, and the remaining setup steps for network profiles, server launching, auto-start, and troubleshooting, please refer to the configuration instructions and setup guide 
