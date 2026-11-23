
1. Folder & File Placement

• Create a folder on your Windows Desktop named lathgate.gg (%USERPROFILE%\Desktop\lathgate.gg).
• Place the core files inside the root: lathgategg.htm, tray-server.ps1, Start lathgate.bat, fox.png, and fox.ico.
• Optional files include a legacy/ backup archive folder and an auto-generated guestbook.json.

2. One-Time Windows Port 80 & mDNS Setup

Open Command Prompt as Administrator and run the following commands individually:
• Allow PowerShell on Port 80:

cmd netsh http add urlacl url=http://+:80/ sddl=D:(A;;GX;;;S-1-1-0)

• Open Port 80 in Windows Defender Firewall: 
cmd netsh advfirewall firewall add rule name="Lathgate Port 80" dir=in action=allow protocol=TCP localport=80

• Enable Windows mDNS Responder:
cmd reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v EnableMDNS /t REG_DWORD /d 1 /f


3. Windows Network Profile & PC Hostname

1. Set Network to Private: Go to Win + I > Network & internet > click your connection and set Network profile type to Private.
2. Rename PC: Go to settings> System > About > click Rename this PC, set it to lathgate, and Restart now.

4. Starting the Server & Accessing the Site

• Start Manually: Double-click Start lathgate.bat to run tray-server.ps1 in the background with the system tray icon.
• Tray Controls: Double-click the fox icon to open http://localhost/, or right-click to access server options.
• Access URLs: Use http://localhost/ or http://lathgate.local locally and from devices on the same Wi-Fi.

5. Auto-Start on Windows Boot

1. Create a shortcut of Start lathgate.bat and assign fox.ico via its Properties.
2. Press Win + R, type shell:startup, and place the shortcut inside the opened Startup folder.

6. Troubleshooting

• DNS_PROBE_FINISHED_NXDOMAIN: Confirm your PC hostname is lathgate, your network profile is Private, and flush your DNS via ipconfig /flushdns.
• Port 80 in Use: Run 
netstat -ano | findstr :80 to identify conflicting applications.
• Guestbook Issues: Ensure you access the app via http://localhost/ or http://lathgate.local rather than a direct file:/// path.
