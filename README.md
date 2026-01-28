# ARC: Adaptive Reactor Control
A set of Minecraft ComputerCraft Tweaked (CC:Tweaked) scripts that provide visual and safety measures to a Mekanism Fission reactor.

# Features
1) Powered by Basalt UI Framework
https://github.com/Pyroxenium/Basalt2 

2) Real-time statistics
<img width="2560" height="1440" alt="2026-01-28_00 38 21" src="https://github.com/user-attachments/assets/511bd6e2-8d64-49b1-94ca-0937be43ff3c" />

3) Automatic reactor SCRAM protection systems

# How to use
## ARC_Manager
1) Place a computer on the fission reactor's Logic Adapter port.
  2) Then install the "ARC_Manager" program onto the computer.
  3) Place a wireless ender modem on the computer.
  4) Edit the "reactorMonitorComputerID" variable in the program to match your monitor computer's id. To find id, type id in the monitor computer's shell. 
  5) Run the program by typing the file name in the computer's command line.

 ## ARC_Monitor
6) Set up a large monitor multi-block structure.
  7) Place a computer that touches any of the monitors.
  8) Install the "ARC_Monitor" program onto the computer.
  9) Run this command on the computer's command line to install Basalt UI Framework "wget run https://raw.githubusercontent.com/Pyroxenium/Basalt2/main/install.lua -f"
  10) Install a Mekanism Alarm block on the left side of the computer.
  11) Place a wireless ender modem on the computer.
  12) Run the program.

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
  
