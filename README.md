
Lathgate.gg 

A lightweight, zero-dependency personal website and local network (LAN) hub featuring a single-file HTML/CSS/JS frontend, custom themes, a shared editable LAN guestbook, built-in arcade and multiplayer LAN games, a Dev Mode LAN clipboard, and a native Windows PowerShell system tray server.

Features

• Zero External Dependencies: Single-file frontend (lathgategg.htm) with custom SVG icons and dynamic favicon injection.
• Custom Themes & Live Overrides: 6 built-in themes (Default Dark, Midnight OLED, Nord Frost, Clean Light, Sunset Synth, and Matrix Terminal) plus custom background and accent color pickers saved to localStorage.
• Responsive Mobile & Desktop UI: Adapts automatically to mobile and desktop viewports with touch swipe gestures for the slide-out navigation sidebar.
• Shared Editable LAN Guestbook: Message wall backed by /api/guestbook (guestbook.json) with post, edit, delete, and Enter-to-send support for devices on the same Wi-Fi network.
• Games & Shared LAN Records: Separate popup modals for Snake, Reaction Timer, and 2-Player LAN Tic-Tac-Toe, backed by /api/scores (scores.json) and /api/ttt (ttt.json).
• Dev Tools & LAN Clipboard: Toggleable Dev Mode in Settings unlocking viewport diagnostics and a shared LAN Clipboard (/api/clip, clip.json) to send, fetch, and copy links or text between your PC and phone.
• Smart System Tray Server: Runs silently in the Windows System Tray (tray-server.ps1) on Port 80, automatically detecting your active LAN IP (http://<LAN-IP>/) alongside http://lathgate.local with one-click open and copy controls.

1. Folder & File Placement

Create a folder on your Windows Desktop named lathgate.gg (%USERPROFILE%\Desktop\lathgate.gg) with these files:
• lathgategg.htm — Main single-file web application
• tray-server.ps1 — PowerShell HTTP listener, JSON APIs, and System Tray controller
• Start lathgate.bat — Silent launcher for tray-server.ps1
• fox.png & fox.ico — Browser favicon and System Tray icon
• guestbook.json, scores.json, ttt.json, clip.json — Auto-generated local JSON storage files

2. One-Time Windows Port 80 & mDNS Setup

Open Command Prompt as Administrator and run these commands individually:
• Allow PowerShell to listen on Port 80:cmd
netsh http add urlacl url=http://+:80/ sddl=D:(A;;GX;;;S-1-1-0)
Use code with caution.
• Open Port 80 in Windows Defender Firewall:cmd
netsh advfirewall firewall add rule name="Lathgate Port 80" dir=in action=allow protocol=TCP localport=80
Use code with caution.
• Enable Windows mDNS & Install Apple Bonjour (for .local resolution on phones):cmd
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v EnableMDNS /t REG_DWORD /d 1 /f
Use code with caution.
cmd
winget install --id Apple.BonjourPrintServices -e
Use code with caution.

3. Windows Network Profile & PC Hostname

1. Set Network to Private: Go to Win + I > Network & internet, click your Wi-Fi/Ethernet connection, and set Network profile type to Private.
2. Rename PC: Go to Win + I > System > About > Rename this PC, set it to lathgate, and restart.

4. Starting & Accessing the Server

• Start: Double-click Start lathgate.bat to launch the fox icon in your System Tray.
• Tray Menu: Hover over or right-click the fox icon to open http://lathgate.local, open http://<YOUR-LAN-IP>/, copy your LAN IP URL, or stop the server.
• Mobile Tip (Android 8 or older): Devices on Android 11 or earlier do not natively resolve .local domains; open http://<YOUR-LAN-IP>/ in Chrome and tap ⋮ > Add to Home screen for a one-tap shortcut.

5. Auto-Start on Windows Boot

1. Right-click Start lathgate.bat > Create shortcut (assign fox.ico in Properties > Change Icon).
2. Press Win + R, type shell:startup, and move the shortcut into that folder
