Windows

Download TILED-v0.1.0-alpha.1.zip from this page.
Extract the zip to a normal folder (for example: Desktop/Tiled).
Open the extracted folder and run TILED.exe.
If Windows SmartScreen appears, choose More info, then Run anyway.
Allow network access if Windows Firewall prompts you (required for phone controllers).
Linux

Download TILED-linux-v0.1.0-alpha.1.zip from this page.
Extract the zip to a normal folder.
In the extracted folder, ensure both files are executable:
chmod +x TILED.x86_64 TILED.sh
Launch with:
./TILED.sh
Allow firewall access on ports 8000 and 9080 if prompted.
How to connect phone controllers

Start a Local Game on the host machine.
On the Lobby screen, scan the QR code with your phone.
The controller page should auto-connect.
Enter player name, choose avatar, then tap Ready.
Important

Host machine and phones must be on the same Wi-Fi/LAN.
This is an alpha playtest build, so rough edges are expected.
Quick troubleshooting

Phone cannot connect:
Re-scan the current QR code (do not use an old bookmark).
Controller page opens but no connection:
Confirm host and phone are on the same network.
Linux controller connect issues:
Open ports 8000/tcp and 9080/tcp in firewall.