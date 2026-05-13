# ARC: Adaptive Reactor Control
A set of Minecraft ComputerCraft Tweaked (CC:Tweaked) scripts that provide visual and safety measures to a Mekanism Fission reactor.

# Features
1) Powered by Basalt UI Framework
https://github.com/Pyroxenium/Basalt2 

2) Real-time statistics
<img width="2560" height="1440" alt="2026-01-28_00 38 21" src="https://github.com/user-attachments/assets/511bd6e2-8d64-49b1-94ca-0937be43ff3c" />

3) Simple UI-Based Installer
<img width="1057" height="603" alt="image" src="https://github.com/user-attachments/assets/8376ae69-f57e-47fb-923e-88273df59783" />

4) Automatic reactor SCRAM protection systems

# Installation
## ARC_Installer
To simplify the process, ARC-related scripts can be installed via the dedicated ARC_Installer.lua. You may also opt to install the code manually from the "src" folder.
1) In the computer's shell, type: "wget run https://raw.githubusercontent.com/Nooble12/CC-Tweaked-Adaptive-Reactor-Control-ARC-/refs/heads/ARC-V1/MekanismReactorControl/Installers/ARC_Installer.lua"

## ARC_Manager
2) Place a computer on the fission reactor's Logic Adapter port.
3) Place a wireless ender modem on the computer.
4) To run the installer, type: "ARC_Installer.lua" into the computer shell.
5) Select and install ARC_Manager from the installer menu.
6) Edit the ARC_Manager file and set the computer ID variable to the monitor computer's id (not the manager computer). To find id, type "id" in the shell of the monitor computer. 

## ARC_Monitor
7) Set up a large monitor multi-block structure.
8) Place a computer that touches any of the monitors.
9) Place a wireless ender modem on the computer.
10) Place a Mekanism Alarm on the left side.
11) Install ARC_Monitor via the "ARC_Installer.lua" app.

## Running The Scripts
12) Type the file name into the computer shell. For example: "ARC_Manager.lua" and press enter.

# Example Setup
## ARC_Monitor
<img width="2560" height="1440" alt="2026-01-28_00 44 03" src="https://github.com/user-attachments/assets/de53771b-7d5e-4c8f-a8a8-9d8a20c8af0a" />
## ARC_Manager
<img width="2560" height="1440" alt="2026-01-28_00 44 33" src="https://github.com/user-attachments/assets/80e22d3a-d28d-4bc7-b924-9063c3efdb19" />

# Not working?
## Did you install Basalt UI Framework? Release (Full) 
To download the Basalt Installer UI using a ComputerCraft shell command: wget run https://raw.githubusercontent.com/Pyroxenium/Basalt2/main/install.lua -f

## No data coming to the monitor?
Make sure that the "reactorMonitorComputerID" variable in the ARC_Manager is set to the monitor computer's id. To find id, type "id" in the computer's shell.

## Black screen issue
If the program is running but there is a black screen, restart the program. Not sure why it does this. Happens when you run the program for the first time.
