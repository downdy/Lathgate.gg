# Lathgate.gg

A lightweight, zero-dependency personal website and local network (LAN) hub built in pure HTML, CSS, and JavaScript, paired with a native Windows PowerShell system tray server.

## Features
* **Zero External Dependencies:** Single-file frontend (`lathgategg.htm`) with custom SVG icons and dynamic favicon injection.
* **Custom Themes & Live Overrides:** Includes 6 built-in themes (*Default Dark*, *Midnight OLED*, *Nord Frost*, *Clean Light*, *Sunset Synth*, and *Matrix Terminal*) plus custom background and accent color pickers saved to `localStorage`.
* **Responsive Mobile & Desktop UI:** Automatically detects mobile vs. desktop viewports, adapts button layouts, and supports real-time touch swipe gestures for the slide-out navigation sidebar.
* **Shared LAN Guestbook:** Built-in message wall backed by a lightweight `/api/guestbook` endpoint (`guestbook.json`) so anyone on the same Wi-Fi network can post notes from a PC or phone.
* **System Tray Server:** Runs silently in the Windows System Tray (`tray-server.ps1`) with a custom fox icon (`fox.ico`) and quick controls to open the site or stop the server.

## Project Structure
* `lathgategg.htm` — Main single-page web application (Home, Friends & Links, LAN Guestbook, Settings, and Dev Tools).
* `tray-server.ps1` — PowerShell `.NET HttpListener` web server and Windows Forms system tray controller.
* `Start Lathgate.bat` — Hidden-window launcher script for starting the tray server.
* `fox.png` & `fox.ico` — Site favicon and Windows shortcut/system tray icon.
* `guestbook.json` — Auto-generated local storage file for LAN Guestbook posts.

## Local & LAN Setup (Windows)

### 1. Clone or Download
Place all project files inside a folder on your Desktop named `lathgate.gg` (`%USERPROFILE%\Desktop\lathgate.gg`).

### 2. Enable LAN Access (One-Time Admin Setup)
To allow other devices on your local network (phones, roommate PCs) to connect over port `8000`, open **Command Prompt as Administrator** and run:
```cmd
netsh http add urlacl url=http://+:8000/ sddl=D:(A;;GX;;;S-1-1-0)
netsh advfirewall firewall add rule name="Lathgate Local Server" dir=in action=allow protocol=TCP localport=8000
```

### 3. Start the Server
* Double-click **`Start Lathgate.bat`** to launch the server silently in the Windows System Tray.
* **Local URL:** `http://localhost:8000/lathgategg.htm`
* **LAN URL (for other devices on Wi-Fi):** `http://<YOUR-IPV4-ADDRESS>:8000/lathgategg.htm` (find your IPv4 address using `ipconfig`).

### 4. Auto-Start on Boot (Optional)
1. Create a shortcut to `Start Lathgate.bat` (optionally assign `fox.ico` under **Properties > Change Icon**).
2. Press `Win + R`, type `shell:startup`, and copy the shortcut into that folder.
