Missile Command Arcade for the Tang Nano 20K FPGA Dev Board. Pinballwiz.org 2025
Code by Jim Gregory 

Notes:
Setup for keyboard controls in Upright mode 1 Player only (5 = Coin) (Start P1 = 1)(Z-X-C = Fire Bases)(Arrow Keys = CrossHair L or R or U or D)
Consult the Schematics Folder for Information regarding peripheral connections.
Consult the Schematics Folder for Information on Tang Nano 20K Internal Clock setup.

Build:
* Obtain correct roms file for Missile Command (see scripts in tools folder for rom details).
* Unzip rom files to the tools folder.
* Run the make missile command proms script in the tools folder.
* Place the generated prom files inside the proms folder.
* Open the TN20K-MissileCommand project file using GoWin.
* Compile the project updating filepaths to source files as necessary.
* If GoWin Place and Route Error - see gowin_place_route_error.txt in tools folder for fix.
* Program Tang Nano 20K Board.
