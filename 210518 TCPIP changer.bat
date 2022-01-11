@echo off & setlocal
title TCP IP Tool v1.6a
rem TCP/IP Batch v1.6a for [local servers] by nickwong 18-05-21
echo *Remember to plug in your CAT6 cable and run script as Administrator!*
:I
set "ipadd="
set "staticip="
:I0
echo.
echo Set BMC IP Address, or press Enter for 192.168.0.120 
echo Or press Return to go to Main Menu
echo.
rem check IP Address format for invalid characters.
set /p ipadd="Enter BMC IP Address here: "|| set "ipadd=192.168.0.120"
setlocal enabledelayedexpansion
echo !ipadd!| findstr /i "[^0-9.]" > nul && (
    endlocal
    echo.
    cls
    set /p "=Variable contain invalid characters." < nul
    timeout 1 > nul
    echo.
    goto I0
)
endlocal
echo.
echo BMC IP Address is now set to %ipadd% for this script.
:choice1
echo.
echo Choose:
echo [S] Set Static IP [I] Initialize/Reset BMC IP
echo [D] Set DHCP
echo [R] Show Curent Network Config
echo [P] ping %ipadd% [L] localhost
echo [X] Close Window [E] Expand Menu
echo [Z] Extras
echo.
choice /c SIDRPLXEZ /t 6000 /d X
if errorlevel 9 goto Extras
if errorlevel 8 cls && goto choice2
if errorlevel 7 goto end
if errorlevel 6 goto L
if errorlevel 5 goto P1
if errorlevel 4 goto R
if errorlevel 3 goto D
if errorlevel 2 cls && goto I
if errorlevel 1 goto S

:S
rem setting Static IP
echo.
echo Set Static IP Address, or press Enter for 192.168.0.100
rem check IP Address format for invalid characters.
set /p staticip="Enter Static IP Address here: "|| set "staticip=192.168.0.100"
setlocal enabledelayedexpansion
echo !staticip!| findstr /i "[^0-9.]" > nul && (
    endlocal
    echo.
    cls
    set /p "=Variable contain invalid characters." < nul
    echo.
    goto S
)
endlocal
timeout 1 > nul
echo Setting IP Address to %staticip%
netsh int ipv4 set address name="Ethernet" source="static" address="%staticip%" mask="255.255.255.0" gateway=none
timeout 3 > null
netsh int ipv4 show config name="Ethernet"
timeout 1 > nul
:P0
rem ping
echo.
echo Pinging %ipadd% now
timeout 1 > nul
ping %ipadd%
goto choice2

:choice2
echo.
rem check for recorded Static and BMC IP
if "%ipadd%" == "" (echo BMC IP Address not recorded for script yet.) else (echo Current BMC Address is set to "%ipadd%")
if "%staticip%" == "" (echo No Static IP recorded for script yet.) else (echo Current Static IP is set to "%staticip%")
rem Expanded Menu
echo.
echo Choose:
echo [S] Set Static IP [I] Initialize/Reset BMC IP
echo [D] Set DHCP
echo [R] Show/Reload Current Network Config
echo [P] ping %ipadd% [T] -t [L] localhost
echo [O] Open WebGUI [M] Get MAC Address 
echo [X] Close Window [C] New cmd Window 
echo [Z] Extras
echo.
choice /c SIDROMPTLXCZ /t 600 /d X
if errorlevel 12 goto Extras
if errorlevel 11 goto C
if errorlevel 10 goto end
if errorlevel 9 goto L
if errorlevel 8 goto T
if errorlevel 7 goto P0
if errorlevel 6 goto M1
rem errorlevel 4 will open WebGUI with default browser
if errorlevel 5 goto O
if errorlevel 4 goto R
if errorlevel 3 goto D
if errorlevel 2 cls && goto I
if errorlevel 1 goto S

:M0
cls
:M1
echo.
rem retrieve MAC Address
echo Retriving MAC Address...
timeout 1 > nul
arp -a %ipadd%
timeout 2 > nul
echo.
echo Choose: 
echo [P] ping %ipadd% [L] localhost
echo [O] Open WebGUI [M] View MAC Address
echo [X] Close Window [E] Expand Menu
echo [Z] Extras
echo.
choice /c POMXE /t 300 /d X
if errorlevel 7 goto Extras
if errorlevel 6 goto choice2
if errorlevel 5 goto end
if errorlevel 4 goto M0
if errorlevel 3 goto O
if errorlevel 2 goto L
if errorlevel 1 goto P0

:O
rem open WebGUI with google chrome
start chrome "" http://%ipadd%/
timeout 2 > nul
cls
goto choice1

:P1
rem request might time out because Static IP not set
echo.
echo Possible request will time out if Static IP not changed yet.
echo (Ignore this if ping successful)
ping %ipadd%
echo.
goto choice2

:L
rem ping localhost
ping localhost
echo.
timeout 1 > nul
goto choice2

:D
rem setting DHCP
echo.
echo Resetting IP Address and Subnet Mask for DHCP
timeout 4 > nul
netsh int ipv4 set address name="Ethernet" source=dhcp
netsh int ipv4 set dns a\name="Wi-Fi" static 8.8.8.8
echo [F] flushdns [X] Skip
echo.
choice /c FX /t 2 /d X
if errorlevel 2 goto R
if errorlevel 1 goto F
:F
echo.
timeout 1 > nul
ipconfig /flushdns
goto choice2

:T
rem continuous ping
start cmd /c "ping "%ipadd%" -t"
echo Opening new window...
timeout 5 > nul
pause
cls
goto choice2

:R
rem Ethernet config after setting DHCP
echo.
echo loading Ethernet configurations...
set /a rn=%random% %% 4 + 2
timeout %rn% > null
netsh int ipv4 show config name="Ethernet"
echo loading Wi-Fi configurations...
timeout 1 > null 
netsh int ipv4 show config name="Wi-Fi"
netsh int ipv4 set dns name="Wi-Fi" static 8.8.8.8
timeout 2 > nul
goto choice2

:C
rem open new batch window
start cmd /k
timeout 300
echo.
cls
echo Choose:
echo [E] Expand Menu [X] Close Window [I] Initialize/Reset BMC IP
choice /c EXI /t 7 /d X 
if errorlevel 3 goto I
if errorlevel 2 goto end
if errorlevel 1 goto choice2

:Extras
cls
echo Choose: 
echo [H] Control Panel Home
echo [N] Network Connections
echo [D] Device Manager
echo [E] Expand Menu
echo.
choice /c HNDE /t 300 /d E
if errorlevel 4 goto choice2
if errorlevel 3 goto DeviceMng
if errorlevel 2 goto NetworkCon
if errorlevel 1 goto ControlPanelHome

:ControlPanelHome
start cmd /c "Control"
timeout 2 > nul
cls
goto Extras

:NetworkCon
start cmd /c "Control netconnections"
timeout 2 > nul
cls
goto Extras

:DeviceMng
start cmd /c "devmgmt.msc"
timeout 2 > nul
cls
goto Extras

:end