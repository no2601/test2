@echo off

REM
REM shacollector (Storage and High Availability area log collection tool)
REM
REM Copyright (C) 2018 Microsoft All Rights Reserved.
REM
REM 2018/07/30 v1.0 making @Koji Ishida.
REM 2018/09/21 v1.1 add WinRM event log @Koji Ishida.
REM 2018/11/12 v1.2 add Hyper-V trace @Koji Ishida.
REM 2018/11/15 v1.3 add Storage Space trace @Koji Ishida.
REM 2018/11/19 v1.4 add S2D and Network information @Koji Ishida.
REM 2018/12/25 v1.5 add setup logs @Koji Ishida
REM 2019/01/17 v1.6 add mpclaim output @Koji Ishida
REM 2019/02/18 v1.7 add nfs and storage replica configuration @Koji Ishida
REM 2019/03/27 v1.8 add Windows Firewall info in Network @Koji Ishida
REM 2019/03/29 v1.9 add packet capture for boot mode @Koji Ishida
REM 2019/03/29 v2.0 add diskshadow and autmount log @Koji Ishida
REM 2019/04/15 v2.1 add get VMQ config @Koji Ishida
REM 2019/05/27 v2.2 add FailoverClustering-Manager trace and Hyper-V information @Koji Ishida
REM 2019/05/31 v2.3 implement to check admin authority. @Koji Ishida
REM 2019/06/04 v2.4 add NFS infomation and iSCSI information @Koji Ishida
REM
REM ------------------------------
REM USAGE:
REM    shacollector.bat [option] start
REM    shacollector.bat [option] stop
REM    shacollector.bat [option] boot
REM    shacollector.bat [option] delete
REM    shacollector.bat support
REM
REM OPTION:
REM    storage   collecting storage drivers trace. (ex storport.sys, classpnp.sys ...)
REM    usb       collecting USB drivers trace.
REM    pnp       collecting Plug and Play drivers trace.
REM    com       collecting COM/COM+ services trace.
REM    vds       collecting VDS services trace. (Windows Server 2012 or later)
REM    vss       collecting VSS services trace. (Windows Server 2008 R2 or later)
REM    wsb       collecting Windows Server Backup modules trace. (Windows Server 2008 R2 or later)
REM    cdrom     collecting CD/DVD modules trace.
REM    ata       collecting ATAPort drivers trace.
REM    fsrm      collecting FSRM drivers trace.
REM    dedup     collecting Dedup drivers trace. (Windows Server 2012 or later)
REM    nfs       collecting NFS services trace. 
REM    iscsi     collecting iSCSI driver trace.
REM    csv       collecting CSV drivers trace.
REM    wmi       collecting WMI services trace.
REM    rpc       collecting RPC services trace.
REM    hyper-v   collection Hyper-V modules trace.
REM    cluster-manager     collection Failover Clustering Manager trace.
REM    space     collecting Storage Space trace.
REM    storagereplica     collecting Storage Replica trace.
REM    packet    collecting Network Packet Capture. (Windows Server 2008 R2 or later)
REM    support   collecting support information logs.
REM 
REM =================================================================
REM configuration for output area.
REM =================================================================
SETLOCAL ENABLEDELAYEDEXPANSION

REM Administrator authority check.
openfiles > NUL 2>&1
if NOT %ERRORLEVEL% EQU 0 goto NotAdmin

for /f "usebackq tokens=*" %%i in (`powershell Get-Date -Format "yyyy-MMdd-HHmmss"`) do @set logdate=%%i

set basedir=c:\mslog
set bootlogdir=%basedir%\boot
set tracelogdir=%basedir%\trace
set supportlogdir=%basedir%\supportlog%logdate%

REM =================================================================
REM Check Arguments.
REM =================================================================
set TRACE=FALSE
if "%1" == "" goto USAGE
if /i "%1" =="support" goto SUPPORT
if /i "%2" =="boot" (
   set TRACE=TRUE
   set boot=autosession\
   set START_OR_STOP=start
)
if /i "%2" =="delete" (
   set TRACE=TRUE
   set boot=autosession\
   set START_OR_STOP=stop
)
if /i "%2" =="start" (
   set TRACE=TRUE
   set START_OR_STOP=start
)
if /i "%2" =="stop" (
   set TRACE=TRUE
   set START_OR_STOP=stop
)

if %TRACE%==TRUE (
   ECHO %1 %2 tracing.
   md %basedir% > NUL 2>&1
   md %bootlogdir% > NUL 2>&1
   md %tracelogdir% > NUL 2>&1
   if /i "%1" =="storage" (
      call :STORAGE %START_OR_STOP%
   ) else if /i "%1" =="usb" (
      call :USB %START_OR_STOP%
   ) else if /i "%1" =="pnp" (
      call :PNP %START_OR_STOP%
   ) else if /i "%1" =="com" (
      call :COM %START_OR_STOP%
   ) else if /i "%1" =="vds" (
      call :VDS %START_OR_STOP%
   ) else if /i "%1" =="vss" (
      call :VSS %START_OR_STOP%
   ) else if /i "%1" =="wsb" (
      call :WSB %START_OR_STOP%
   ) else if /i "%1" =="cdrom" (
      call :CDROM %START_OR_STOP%
   ) else if /i "%1" =="ata" (
      call :ATA %START_OR_STOP%
   ) else if /i "%1" =="fsrm" (
      call :FSRM %START_OR_STOP%
   ) else if /i "%1" =="dedup" (
      call :DEDUP %START_OR_STOP%
   ) else if /i "%1" =="nfs" (
      call :NFS %START_OR_STOP%
   ) else if /i "%1" =="iscsi" (
      call :ISCSI %START_OR_STOP%
   ) else if /i "%1" =="csv" (
      call :CSV %START_OR_STOP%
   ) else if /i "%1" =="wmi" (
      call :WMI %START_OR_STOP%
   ) else if /i "%1" =="rpc" (
      call :RPC %START_OR_STOP%
   ) else if /i "%1" =="hyper-v" (
      call :HYPER-V %START_OR_STOP%
   ) else if /i "%1" =="cluster-manager" (
      call :Cluster-Manager %START_OR_STOP%
   ) else if /i "%1" =="space" (
      call :SPACE %START_OR_STOP%
   ) else if /i "%1" =="storagereplica" (
      call :STORAGEREPLICA %START_OR_STOP%
   ) else if /i "%1" =="packet" (
      call :PACKET %START_OR_STOP%
   ) else (
      goto USAGE
   )
) else (
   goto USAGE
)

ENDLOCAL
exit /b

:USAGE
ECHO shacollector (Storage and High Availability area log collection tool) Usage:
ECHO   shacollector.bat [option] start
ECHO   shacollector.bat [option] stop
ECHO   shacollector.bat [option] boot
ECHO   shacollector.bat [option] delete
ECHO   shacollector.bat support
ECHO.
ECHO Option:
ECHO    storage   collecting storage drivers trace. (ex storport.sys, classpnp.sys ...)
ECHO    usb       collecting USB drivers trace.
ECHO    pnp       collecting Plug and Play drivers trace.
ECHO    com       collecting COM/COM+ services trace.
ECHO    vds       collecting VDS services trace. (Windows Server 2012 or later)
ECHO    vss       collecting VSS services trace. (Windows Server 2008 R2 or later)
ECHO    wsb       collecting Windows Server Backup modules trace. (Windows Server 2008 R2 or later)
ECHO    cdrom     collecting CD/DVD modules trace.
ECHO    ata       collecting ATAPort drivers trace.
ECHO    fsrm      collecting FSRM drivers trace.
ECHO    dedup     collecting Dedup drivers trace. (Windows Server 2012 or later)
ECHO    nfs       collecting NFS services trace. 
ECHO    iscsi     collecting iSCSI driver trace.
ECHO    csv       collecting CSV drivers trace.
ECHO    wmi       collecting WMI services trace.
ECHO    rpc       collecting RPC services trace.
ECHO    hyper-v   collection Hyper-V modules trace.
ECHO    cluster-manager     collection Failover Clustering Manager trace.
ECHO    space     collecting Storage Space trace.
ECHO    storagereplica     collecting Storage Replica trace.
ECHO    packet    collecting Network Packet Capture. (Windows Server 2008 R2 or later) 
ECHO    support   collecting support information logs.
ENDLOCAL
exit /b

:NotAdmin
ECHO Please run as Administrator authority.
pause
exit /b

REM =================================================================
REM storage   collecting storage drivers trace.
REM =================================================================
REM F96ABC17-6A5E-4A49-A3F4-A2A86FA03846 => StorVsp
REM 8B86727C-E587-4B89-8FC5-D1F24D43F69C => StorPort
REM 8E9AC05F-13FD-4507-85CD-B47ADC105FF6 => MPIO
REM DEDADFF5-F99F-4600-B8C9-2D4D9B806B5B => MSDSM
REM 1BABEFB4-59CB-49E5-9698-FD38AC830A91 => iSCSI
REM 945186BF-3DD6-4F3F-9C8E-9EDD3FC9D558 => Disk
REM FA8DE7C4-ACDE-4443-9994-C4E2359A9EDB => ClassPnP
REM 467C1914-37F0-4C7D-B6DB-5CD7DFE7BD5E => mountmgr
REM F5204334-1420-479B-8389-54A4A6BF6EF8 => volmgr
REM 0BEE3BC5-A50C-4EC3-A0E0-5AD11F2455A3 => partmgr
REM 67FE2216-727A-40CB-94B2-C02211EDB34A => volsnap
REM CB017CD2-1F37-4E65-82BC-3E91F6A37559 => volsnap (win10)
REM 3C70C3B0-2FAE-41D3-B68D-8F7FCAF79ADB => vhdmp
REM 6E580567-C67C-4B96-934E-FC2996E103AE => clusdisk
REM =================================================================
:STORAGE
if /i "%1" =="start" (
   logman create trace "%boot%storage_trace" -ow -o %tracelogdir%\storage_trace_%logdate%.etl -p {F96ABC17-6A5E-4A49-A3F4-A2A86FA03846} 0xffffffffffffffff 0xff -nb 16 16 -bs 1024 -mode Circular -f bincirc -max 4096 -ets > NUL 2>&1
   logman update trace "%boot%storage_trace" -p {8B86727C-E587-4B89-8FC5-D1F24D43F69C} 0xffffffffffffffff 0xff -ets > NUL 2>&1
   logman update trace "%boot%storage_trace" -p {8E9AC05F-13FD-4507-85CD-B47ADC105FF6} 0xffffffffffffffff 0xff -ets > NUL 2>&1
   logman update trace "%boot%storage_trace" -p {DEDADFF5-F99F-4600-B8C9-2D4D9B806B5B} 0xffffffffffffffff 0xff -ets > NUL 2>&1
   logman update trace "%boot%storage_trace" -p {1BABEFB4-59CB-49E5-9698-FD38AC830A91} 0xffffffffffffffff 0xff -ets > NUL 2>&1
   logman update trace "%boot%storage_trace" -p {945186BF-3DD6-4F3F-9C8E-9EDD3FC9D558} 0xffffffffffffffff 0xff -ets > NUL 2>&1
   logman update trace "%boot%storage_trace" -p {FA8DE7C4-ACDE-4443-9994-C4E2359A9EDB} 0xffffffffffffffff 0xff -ets > NUL 2>&1
   logman update trace "%boot%storage_trace" -p {467C1914-37F0-4C7D-B6DB-5CD7DFE7BD5E} 0xffffffffffffffff 0xff -ets > NUL 2>&1
   logman update trace "%boot%storage_trace" -p {F5204334-1420-479B-8389-54A4A6BF6EF8} 0xffffffffffffffff 0xff -ets > NUL 2>&1
   logman update trace "%boot%storage_trace" -p {0BEE3BC5-A50C-4EC3-A0E0-5AD11F2455A3} 0xffffffffffffffff 0xff -ets > NUL 2>&1
   logman update trace "%boot%storage_trace" -p {67FE2216-727A-40CB-94B2-C02211EDB34A} 0xffffffffffffffff 0xff -ets > NUL 2>&1
   logman update trace "%boot%storage_trace" -p {CB017CD2-1F37-4E65-82BC-3E91F6A37559} 0xffffffffffffffff 0xff -ets > NUL 2>&1
   logman update trace "%boot%storage_trace" -p {3C70C3B0-2FAE-41D3-B68D-8F7FCAF79ADB} 0xffffffffffffffff 0xff -ets > NUL 2>&1
   logman update trace "%boot%storage_trace" -p {6E580567-C67C-4B96-934E-FC2996E103AE} 0xffffffffffffffff 0xff -ets > NUL 2>&1

   if DEFINED boot (
      reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\WMI\Autologger\storage_trace /v FileName /t REG_SZ /d "%bootlogdir%\boot_storage_trace.etl" /f > NUL 2>&1
   )
)

if /i "%1" =="stop" (
   logman stop "%boot%storage_trace" -ets > NUL 2>&1

   if DEFINED boot (
      logman delete "%boot%storage_trace" > NUL 2>&1
   )
echo Tracing has been captured and saved at %basedir%.
)
exit /b
REM =================================================================

REM =================================================================
REM usb       collecting USB drivers trace.
REM =================================================================
REM C88A4EF5-D048-4013-9408-E04B7DB2814A => Microsoft-Windows-USB-USBPORT (USB 2.0)
REM 7426A56B-E2D5-4B30-BDEF-B31815C1A74A => Microsoft-Windows-USB-USBHUB  (USB 2.0)
REM D75AEDBE-CFCD-42B9-94AB-F47B224245DD => usbport (USB 2.0)
REM B10D03B8-E1F6-47F5-AFC2-0FA0779B8188 => usbhub  (USB 2.0)
REM 30E1D284-5D88-459C-83FD-6345B39B19EC => Microsoft-Windows-USB-USBXHCI (USB 3.0)
REM 36DA592D-E43A-4E28-AF6F-4BC57C5A11E8 => Microsoft-Windows-USB-UCX (USB 3.0)
REM AC52AD17-CC01-4F85-8DF5-4DCE4333C99B => Microsoft-Windows-USB-USBHUB3 (USB 3.0)
REM 6E6CC2C5-8110-490E-9905-9F2ED700E455 => USBHUB3 (USB 3.0)
REM 6FB6E467-9ED4-4B73-8C22-70B97E22C7D9 => UCX (USB 3.0)
REM 9F7711DD-29AD-C1EE-1B1B-B52A0118A54C => USBXHCI (USB 3.0)
REM =================================================================
:USB
if /i "%1" =="start" (
   logman create trace "%boot%usb_trace" -ow -o %tracelogdir%\usb_trace_%logdate%.etl -p {C88A4EF5-D048-4013-9408-E04B7DB2814A} 0xffffffffffffffff 0xff -nb 16 16 -bs 1024 -mode Circular -f bincirc -max 4096 -ets > NUL 2>&1
   logman update trace "%boot%usb_trace" -p {7426A56B-E2D5-4B30-BDEF-B31815C1A74A} 0xffffffffffffffff 0xff -ets > NUL 2>&1
   logman update trace "%boot%usb_trace" -p {D75AEDBE-CFCD-42B9-94AB-F47B224245DD} 0xffffffffffffffff 0xff -ets > NUL 2>&1
   logman update trace "%boot%usb_trace" -p {B10D03B8-E1F6-47F5-AFC2-0FA0779B8188} 0xffffffffffffffff 0xff -ets > NUL 2>&1
   logman update trace "%boot%usb_trace" -p {30E1D284-5D88-459C-83FD-6345B39B19EC} 0xffffffffffffffff 0xff -ets > NUL 2>&1
   logman update trace "%boot%usb_trace" -p {36DA592D-E43A-4E28-AF6F-4BC57C5A11E8} 0xffffffffffffffff 0xff -ets > NUL 2>&1
   logman update trace "%boot%usb_trace" -p {AC52AD17-CC01-4F85-8DF5-4DCE4333C99B} 0xffffffffffffffff 0xff -ets > NUL 2>&1
   logman update trace "%boot%usb_trace" -p {6E6CC2C5-8110-490E-9905-9F2ED700E455} 0xffffffffffffffff 0xff -ets > NUL 2>&1
   logman update trace "%boot%usb_trace" -p {6FB6E467-9ED4-4B73-8C22-70B97E22C7D9} 0xffffffffffffffff 0xff -ets > NUL 2>&1
   logman update trace "%boot%usb_trace" -p {9F7711DD-29AD-C1EE-1B1B-B52A0118A54C} 0xffffffffffffffff 0xff -ets > NUL 2>&1

   if DEFINED boot (
      reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\WMI\Autologger\usb_trace /v FileName /t REG_SZ /d "%bootlogdir%\boot_usb_trace.etl" /f > NUL 2>&1
   )
)

if /i "%1" =="stop" (
   logman stop "usb_trace" -ets > NUL 2>&1

   if DEFINED boot (
      logman delete "%boot%usb_trace" > NUL 2>&1
   )
echo Tracing has been captured and saved at %basedir%.
)
exit /b
REM =================================================================

REM =================================================================
REM pnp       collecting Plug and Play drivers trace.
REM =================================================================
REM F52E9EE1-03D4-4DB3-B2D4-1CDD01C65582 => PnpInstal
REM 9C205A39-1250-487D-ABD7-E831C6290539 => Microsoft-Windows-Kernel-PnP
REM A676B545-4CFB-4306-A067-502D9A0F2220 => PlugPlay
REM 84051B98-F508-4E54-82FA-8865C697C3B1 => Microsoft-Windows-PnPMgrTriggerProvider
REM 96F4A050-7E31-453C-88BE-9634F4E02139 => Microsoft-Windows-UserPnp
REM D5EBB80C-4407-45E4-A87A-015F6AF60B41 => Microsoft-Windows-Kernel-PnPConfig
REM =================================================================
:PNP
if /i "%1" =="start" (
   logman create trace "%boot%pnp_trace" -ow -o %tracelogdir%\pnp_trace_%logdate%.etl -p {F52E9EE1-03D4-4DB3-B2D4-1CDD01C65582} 0xffffffffffffffff 0xff -nb 16 16 -bs 1024 -mode Circular -f bincirc -max 4096 -ets > NUL 2>&1
   logman update trace "%boot%pnp_trace" -p {9C205A39-1250-487D-ABD7-E831C6290539} 0xffffffffffffffff 0xff > NUL 2>&1
   logman update trace "%boot%pnp_trace" -p {A676B545-4CFB-4306-A067-502D9A0F2220} 0xffffffffffffffff 0xff > NUL 2>&1 
   logman update trace "%boot%pnp_trace" -p {84051B98-F508-4E54-82FA-8865C697C3B1} 0xffffffffffffffff 0xff > NUL 2>&1
   logman update trace "%boot%pnp_trace" -p {96F4A050-7E31-453C-88BE-9634F4E02139} 0xffffffffffffffff 0xff > NUL 2>&1
   logman update trace "%boot%pnp_trace" -p {D5EBB80C-4407-45E4-A87A-015F6AF60B41} 0xffffffffffffffff 0xff > NUL 2>&1

   if DEFINED boot (
      reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\WMI\Autologger\pnp_trace /v FileName /t REG_SZ /d "%bootlogdir%\boot_pnp_trace.etl" /f > NUL 2>&1
   )
)

if /i "%1" =="stop" (
   logman stop "pnp_trace" -ets > NUL 2>&1

   if DEFINED boot (
      logman delete "%boot%pnp_trace" > NUL 2>&1
   )
echo Tracing has been captured and saved at %basedir%.
)
exit /b
REM =================================================================

REM =================================================================
REM com       collecting COM/COM+ services trace.
REM =================================================================
REM B46FA1AD-B22D-4362-B072-9F5BA07B046D => COMSVCS
REM BDA92AE8-9F11-4D49-BA1D-A4C2ABCA692E => OLE32
REM 9474A749-A98D-4F52-9F45-5B20247E4F01 => DCOMSCM
REM A0C4702B-51F7-4EA9-9C74-E39952C694B8 => COMADMIN
REM =================================================================
:COM
if /i "%1" =="start" (
   logman create trace "%boot%com_trace" -ow -o %tracelogdir%\com_trace_%logdate%.etl -p {B46FA1AD-B22D-4362-B072-9F5BA07B046D} 0xffffffffffffffff 0xff -nb 16 16 -bs 1024 -mode Circular -f bincirc -max 4096 -ets > NUL 2>&1
   logman update trace "%boot%com_trace" -p {BDA92AE8-9F11-4D49-BA1D-A4C2ABCA692E} 0xffffffffffffffff 0xff -ets > NUL 2>&1
   logman update trace "%boot%com_trace" -p {9474A749-A98D-4F52-9F45-5B20247E4F01} 0xffffffffffffffff 0xff -ets > NUL 2>&1
   logman update trace "%boot%com_trace" -p {A0C4702B-51F7-4EA9-9C74-E39952C694B8} 0xffffffffffffffff 0xff -ets > NUL 2>&1

   if DEFINED boot (
      reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\WMI\Autologger\com_trace /v FileName /t REG_SZ /d "%bootlogdir%\boot_com_trace.etl" /f > NUL 2>&1
   )
)

if /i "%1" =="stop" (
   logman stop "com_trace" -ets > NUL 2>&1

   if DEFINED boot (
      logman delete "%boot%com_trace" > NUL 2>&1
   )
echo Tracing has been captured and saved at %basedir%.
)
exit /b
REM =================================================================

REM =================================================================
REM vds       collecting VDS services trace. (Windows Server 2012 or later)
REM =================================================================
REM 012F855E-CC34-4DA0-895F-07AF2826C03E => VDS
REM =================================================================
:VDS
if /i "%1" =="start" (
   logman create trace "%boot%vds_trace" -ow -o %tracelogdir%\vds_trace_%logdate%.etl -p {012F855E-CC34-4DA0-895F-07AF2826C03E} 0xffffffffffffffff 0xff -nb 16 16 -bs 1024 -mode Circular -f bincirc -max 4096 -ets > NUL 2>&1

   if DEFINED boot (
      reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\WMI\Autologger\vds_trace /v FileName /t REG_SZ /d "%bootlogdir%\boot_vds_trace.etl" /f > NUL 2>&1
   )
)

if /i "%1" =="stop" (
   logman stop "vds_trace" -ets > NUL 2>&1

   if DEFINED boot (
      logman delete "%boot%vds_trace" > NUL 2>&1
   )
echo Tracing has been captured and saved at %basedir%.
)
exit /b
REM =================================================================

REM =================================================================
REM vss       collecting VSS services trace. (Windows Server 2008 R2 or later)
REM =================================================================
REM 9138500E-3648-4EDB-AA4C-859E9F7B7C38 => VSS tracing provider
REM 67FE2216-727A-40CB-94B2-C02211EDB34A => volsnap
REM CB017CD2-1F37-4E65-82BC-3E91F6A37559 => volsnap (win10)
REM =================================================================
:VSS
if /i "%1" =="start" (
   logman create trace "%boot%vss_trace" -ow -o %tracelogdir%\vss_trace_%logdate%.etl -p {9138500E-3648-4EDB-AA4C-859E9F7B7C38} 0xffffffffffffffff 0xff -nb 16 16 -bs 1024 -mode Circular -f bincirc -max 4096 -ets > NUL 2>&1
   logman create trace "%boot%volsnap_trace" -ow -o %tracelogdir%\volsnap_trace_%logdate%.etl -p {67FE2216-727A-40CB-94B2-C02211EDB34A} 0xffffffffffffffff 0xff -nb 16 16 -bs 1024 -mode Circular -f bincirc -max 4096 -ets > NUL 2>&1
   logman update trace "%boot%volsnap_trace" -p {CB017CD2-1F37-4E65-82BC-3E91F6A37559} 0xffffffffffffffff 0xff -ets > NUL 2>&1

   if DEFINED boot (
      reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\WMI\Autologger\vss_trace /v FileName /t REG_SZ /d "%bootlogdir%\boot_vss_trace.etl" /f > NUL 2>&1
      reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\WMI\Autologger\volsnap_trace /v FileName /t REG_SZ /d "%bootlogdir%\boot_volsnap_trace.etl" /f > NUL 2>&1
   )
)

if /i "%1" =="stop" (
   logman stop "vss_trace" -ets > NUL 2>&1
   logman stop "volsnap_trace" -ets > NUL 2>&1

   if DEFINED boot (
      logman delete "%boot%vss_trace" > NUL 2>&1
      logman delete "%boot%volsnap_trace" > NUL 2>&1
   )
echo Tracing has been captured and saved at %basedir%.
)
exit /b
REM =================================================================

REM =================================================================
REM wsb       collecting Windows Server Backup modules trace. (Windows Server 2008 R2 or later)
REM =================================================================
REM 5602C36E-B813-49D1-A1AA-A0C2D43B4F38 => wbengine
REM 4B966436-6781-4906-8035-9AF94B32C3F7 => SPP
REM 9138500E-3648-4EDB-AA4C-859E9F7B7C38 => VSS tracing provider
REM 67FE2216-727A-40CB-94B2-C02211EDB34A => volsnap
REM CB017CD2-1F37-4E65-82BC-3E91F6A37559 => volsnap (win10)
REM 3C70C3B0-2FAE-41D3-B68D-8F7FCAF79ADB => vhdmp
REM =================================================================
:WSB
if /i "%1" =="start" (
   logman create trace "%boot%wbengine_trace" -ow -o %tracelogdir%\wbengine_trace_%logdate%.etl -p "Microsoft-Windows-Backup" 0xffffffffffffffff 0xff -nb 16 16 -bs 1024 -mode Circular -f bincirc -max 4096 -ets > NUL 2>&1
   logman update trace "%boot%wbengine_trace" -p {5602C36E-B813-49D1-A1AA-A0C2D43B4F38} 0xffffffffffffffff 0xff -ets > NUL 2>&1
   logman create trace "%boot%spp_trace" -ow -o %tracelogdir%\spp_trace_%logdate%.etl -p {4B966436-6781-4906-8035-9AF94B32C3F7} 0xffffffffffffffff 0xff -nb 16 16 -bs 1024 -mode Circular -f bincirc -max 4096 -ets > NUL 2>&1
   logman create trace "%boot%vss_trace" -ow -o %tracelogdir%\vss_trace_%logdate%.etl -p {9138500E-3648-4EDB-AA4C-859E9F7B7C38} 0xffffffffffffffff 0xff -nb 16 16 -bs 1024 -mode Circular -f bincirc -max 4096 -ets > NUL 2>&1
   logman create trace "%boot%volsnap_trace" -ow -o %tracelogdir%\volsnap_trace_%logdate%.etl -p {67FE2216-727A-40CB-94B2-C02211EDB34A} 0xffffffffffffffff 0xff -nb 16 16 -bs 1024 -mode Circular -f bincirc -max 4096 -ets > NUL 2>&1
   logman update trace "%boot%volsnap_trace" -p {CB017CD2-1F37-4E65-82BC-3E91F6A37559} 0xffffffffffffffff 0xff -ets > NUL 2>&1
   logman create trace "%boot%vhdmp_trace" -ow -o %tracelogdir%\vhdmp_trace_%logdate%.etl -p {3C70C3B0-2FAE-41D3-B68D-8F7FCAF79ADB} 0xffffffffffffffff 0xff -nb 16 16 -bs 1024 -mode Circular -f bincirc -max 4096 -ets > NUL 2>&1

   if DEFINED boot (
      reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\WMI\Autologger\wbengine_trace /v FileName /t REG_SZ /d "%bootlogdir%\boot_wbengine_trace.etl" /f > NUL 2>&1
      reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\WMI\Autologger\spp_trace /v FileName /t REG_SZ /d "%bootlogdir%\boot_spp_trace.etl" /f > NUL 2>&1
      reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\WMI\Autologger\vss_trace /v FileName /t REG_SZ /d "%bootlogdir%\boot_vss_trace.etl" /f > NUL 2>&1
      reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\WMI\Autologger\volsnap_trace /v FileName /t REG_SZ /d "%bootlogdir%\boot_volsnap_trace.etl" /f > NUL 2>&1
      reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\WMI\Autologger\vhdmp_trace /v FileName /t REG_SZ /d "%bootlogdir%\boot_vhdmp_trace" /f > NUL 2>&1
   )
)

if /i "%1" =="stop" (
   logman stop "wbengine_trace" -ets > NUL 2>&1
   logman stop "spp_trace" -ets > NUL 2>&1
   logman stop "vss_trace" -ets > NUL 2>&1
   logman stop "volsnap_trace" -ets > NUL 2>&1
   logman stop "vhdmp_trace" -ets > NUL 2>&1

   if DEFINED boot (
      logman delete "%boot%wbengine_trace" > NUL 2>&1
      logman delete "%boot%spp_trace" > NUL 2>&1
      logman delete "%boot%vss_trace" > NUL 2>&1
      logman delete "%boot%volsnap_trace" > NUL 2>&1
      logman delete "%boot%vhdmp_trace" > NUL 2>&1
   )
echo Tracing has been captured and saved at %basedir%.
)
exit /b
REM =================================================================

REM =================================================================
REM cdrom     collecting CD/DVD modules trace.
REM =================================================================
REM A4196372-C3C4-42D5-87BF-7EDB2E9BCC27 => Storage - CDROM
REM 9B6123DC-9AF6-4430-80D7-7D36F054FB9F => Microsoft-Windows-CDROM
REM 944A000F-5F60-4E5A-86FD-D55B84B543E9 => udfs
REM =================================================================
:CDROM
if /i "%1" =="start" (
   logman create trace "%boot%cdrom_trace" -ow -o %tracelogdir%\cdrom_trace_%logdate%.etl -p {A4196372-C3C4-42D5-87BF-7EDB2E9BCC27} 0xffffffffffffffff 0xff -nb 16 16 -bs 1024 -mode Circular -f bincirc -max 4096 -ets > NUL 2>&1
   logman update trace "%boot%cdrom_trace" -p {9B6123DC-9AF6-4430-80D7-7D36F054FB9F} 0xffffffffffffffff 0xff -ets > NUL 2>&1
   logman update trace "%boot%cdrom_trace" -p {944A000F-5F60-4E5A-86FD-D55B84B543E9} 0xffffffffffffffff 0xff -ets > NUL 2>&1

   if DEFINED boot (
      reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\WMI\Autologger\cdrom_trace /v FileName /t REG_SZ /d "%bootlogdir%\boot_cdrom_trace.etl" /f > NUL 2>&1
   )
)

if /i "%1" =="stop" (
   logman stop "cdrom_trace" -ets > NUL 2>&1

   if DEFINED boot (
      logman delete "%boot%cdrom_trace" > NUL 2>&1
   )
echo Tracing has been captured and saved at %basedir%.
)
exit /b
REM =================================================================

REM =================================================================
REM ata     collecting ATAPort drivers trace.
REM =================================================================
REM D08BD885-501E-489A-BAC6-B7D24BFE6BBF => Storage - ATAPort
REM CB587AD1-CC35-4EF1-AD93-36CC82A2D319 => Microsoft-Windows-ATAPort
REM =================================================================
:ATA
if /i "%1" =="start" (
   logman create trace "%boot%ata_trace" -ow -o %tracelogdir%\ata_trace_%logdate%.etl -p {D08BD885-501E-489A-BAC6-B7D24BFE6BBF} 0xffffffffffffffff 0xff -nb 16 16 -bs 1024 -mode Circular -f bincirc -max 4096 -ets > NUL 2>&1
   logman update trace "%boot%ata_trace" -p {CB587AD1-CC35-4EF1-AD93-36CC82A2D319} 0xffffffffffffffff 0xff -ets > NUL 2>&1

   if DEFINED boot (
      reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\WMI\Autologger\ata_trace /v FileName /t REG_SZ /d "%bootlogdir%\boot_ata_trace.etl" /f > NUL 2>&1
   )
)

if /i "%1" =="stop" (
   logman stop "ata_trace" -ets > NUL 2>&1

   if DEFINED boot (
      logman delete "%boot%ata_trace" > NUL 2>&1
   )
echo Tracing has been captured and saved at %basedir%.
)
exit /b
REM =================================================================

REM =================================================================
REM fsrm     collecting FSRM drivers trace.
REM =================================================================
REM 3201C659-D580-4833-B17D-1ADAF643C64C => FSRM Tracing Provider
REM 1214600F-DF79-4A03-94F5-65D7CAB4FD16 => Quota
REM DB4A5343-AC92-4B83-9D84-7ED8FADD7AA5 => Datascrn
REM 1C7BC728-8199-48BE-BD4D-406A63303C8D => Cbafilt
REM F3C5E28E-63F6-49C7-A204-E48A1BC4B09D => filter manager
REM =================================================================
:FSRM
if /i "%1" =="start" (
   logman create trace "%boot%fsrm_trace" -ow -o %tracelogdir%\fsrm_trace_%logdate%.etl -p {3201C659-D580-4833-B17D-1ADAF643C64C} 0xffffffffffffffff 0xff -nb 16 16 -bs 1024 -mode Circular -f bincirc -max 4096 -ets > NUL 2>&1
   logman create trace "%boot%quota_trace" -ow -o %tracelogdir%\quota_trace_%logdate%.etl -p {1214600F-DF79-4A03-94F5-65D7CAB4FD16} 0xffffffffffffffff 0xff -nb 16 16 -bs 1024 -mode Circular -f bincirc -max 4096 -ets > NUL 2>&1
REM 
REM datascrn is disabled for a while because it does not work.
REM
REM   logman create trace "%boot%datascrn_trace" -ow -o %tracelogdir%\datascrn_trace_%logdate%.etl -p {DB4A5343-AC92-4B83-9D84-7ED8FADD7AA5} 0xffffffffffffffff 0xff -nb 16 16 -bs 1024 -mode Circular -f bincirc -max 4096 -ets > NUL 2>&1
   logman create trace "%boot%cbafilt_trace" -ow -o %tracelogdir%\cbafilt_trace_%logdate%.etl -p {1C7BC728-8199-48BE-BD4D-406A63303C8D} 0xffffffffffffffff 0xff -nb 16 16 -bs 1024 -mode Circular -f bincirc -max 4096 -ets > NUL 2>&1
   logman create trace "%boot%filtermgr_trace" -ow -o %tracelogdir%\filtermgr_trace_%logdate%.etl -p {F3C5E28E-63F6-49C7-A204-E48A1BC4B09D} 0xffffffffffffffff 0xff -nb 16 16 -bs 1024 -mode Circular -f bincirc -max 4096 -ets > NUL 2>&1

   if DEFINED boot (
      reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\WMI\Autologger\fsrm_trace /v FileName /t REG_SZ /d "%bootlogdir%\boot_fsrm_trace.etl" /f > NUL 2>&1
      reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\WMI\Autologger\quota_trace /v FileName /t REG_SZ /d "%bootlogdir%\boot_quota_trace.etl" /f > NUL 2>&1
REM      reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\WMI\Autologger\datascrn_trace /v FileName /t REG_SZ /d "%bootlogdir%\boot_datascrn_trace.etl" /f > NUL 2>&1
      reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\WMI\Autologger\cbafilt_trace /v FileName /t REG_SZ /d "%bootlogdir%\boot_cbafilt_trace.etl" /f > NUL 2>&1
      reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\WMI\Autologger\filtermgr_trace /v FileName /t REG_SZ /d "%bootlogdir%\boot_filtermgr_trace.etl" /f > NUL 2>&1

   )
)

if /i "%1" =="stop" (
   logman stop "fsrm_trace" -ets > NUL 2>&1
   logman stop "quota_trace" -ets > NUL 2>&1
REM   logman stop "datascrn_trace" -ets > NUL 2>&1
   logman stop "cbafilt_trace" -ets > NUL 2>&1
   logman stop "filtermgr_trace" -ets > NUL 2>&1

   if DEFINED boot (
      logman delete "%boot%fsrm_trace" > NUL 2>&1
      logman delete "%boot%quota_trace" > NUL 2>&1
REM      logman delete "%boot%datascrn_trace" > NUL 2>&1
      logman delete "%boot%cbafilt_trace" > NUL 2>&1
      logman delete "%boot%filtermgr_trace" > NUL 2>&1
   )
echo Tracing has been captured and saved at %basedir%.
)
exit /b
REM =================================================================

REM =================================================================
REM dedup     collecting Dedup drivers trace. (Windows Server 2012 or later)
REM =================================================================
REM F9FE3908-44B8-48D9-9A32-5A763FF5ED79 => Microsoft-Windows-Deduplication
REM 1D5E499D-739C-45A6-A3E1-8CBE0A352BEB => Microsoft-Windows-Deduplication-Change
REM 5EBB59D1-4739-4E45-872D-B8703956D84B => Deduplication Tracing Provider
REM =================================================================
:DEDUP
if /i "%1" =="start" (
   logman create trace "%boot%dedup_trace" -ow -o %tracelogdir%\dedup_trace_%logdate%.etl -p {F9FE3908-44B8-48D9-9A32-5A763FF5ED79} 0xffffffffffffffff 0xff -nb 16 16 -bs 1024 -mode Circular -f bincirc -max 4096 -ets > NUL 2>&1
   logman update trace "%boot%dedup_trace" -p {1D5E499D-739C-45A6-A3E1-8CBE0A352BEB} 0xffffffffffffffff 0xff -ets > NUL 2>&1
   logman update trace "%boot%dedup_trace" -p {5EBB59D1-4739-4E45-872D-B8703956D84B} 0xffffffffffffffff 0xff -ets > NUL 2>&1

   if DEFINED boot (
      reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\WMI\Autologger\dedup_trace /v FileName /t REG_SZ /d "%bootlogdir%\boot_dedup_trace.etl" /f > NUL 2>&1
   )
)

if /i "%1" =="stop" (
   logman stop "dedup_trace" -ets > NUL 2>&1

   if DEFINED boot (
      logman delete "%boot%dedup_trace" > NUL 2>&1
   )
echo Tracing has been captured and saved at %basedir%.
)
exit /b
REM =================================================================

REM =================================================================
REM nfs     collecting NFS services trace.
REM =================================================================
REM 3c33d8b3-66fa-4427-a31b-f7dfa429d78f => NFS Server
REM fc33d8b3-66fa-4427-a31b-f7dfa429d78f => NfsSvrNfsGuid2
REM 57294EFD-C387-4e08-9144-2028E8A5CB1A => NfsSvrNlmGuid
REM CC9A5284-CC3E-4567-B3F6-3EB24E7CFEC5 => MsNfsFltGuid
REM 355c2284-61cb-47bb-8407-4be72b5577b0 => NfsRdrGuid
REM 6361F674-C2C0-4F6B-AE19-8C62F47AE3FB => NfsClientGuid
REM E18A05DC-CCE3-4093-B5AD-211E4C798A0D => PortMapGuid
REM 94B45058-6F59-4696-B6BC-B23B7768343D => RpcXdrGuid
REM DD7A21E6-A651-46D4-B7C2-66543067B869 => NDISTraceGuid
REM eb004a05-9b1a-11d4-9123-0050047759bc => NETIO
REM E53C6823-7BB8-44BB-90DC-3F86090D48A6 => Microsoft-Windows-Winsock-AFD
REM 2F07E2EE-15DB-40F1-90EF-9D7BA282188A => Microsoft-Windows-TCPIP
REM B40AEF77-892A-46F9-9109-438E399BB894 => AFD Trace
REM =================================================================
:NFS
if /i "%1" =="start" (
   logman create trace "%boot%nfs_trace" -ow -o %tracelogdir%\nfs_trace_%logdate%.etl -p {3c33d8b3-66fa-4427-a31b-f7dfa429d78f} 0xffffffffffffffff 0xff -nb 16 16 -bs 1024 -mode Circular -f bincirc -max 4096 -ets > NUL 2>&1
   logman update trace "%boot%nfs_trace" -p {fc33d8b3-66fa-4427-a31b-f7dfa429d78f} 0xffffffffffffffff 0xff -ets > NUL 2>&1
   logman update trace "%boot%nfs_trace" -p {57294EFD-C387-4e08-9144-2028E8A5CB1A} 0xffffffffffffffff 0xff -ets > NUL 2>&1
   logman update trace "%boot%nfs_trace" -p {CC9A5284-CC3E-4567-B3F6-3EB24E7CFEC5} 0xffffffffffffffff 0xff -ets > NUL 2>&1
   logman update trace "%boot%nfs_trace" -p {355c2284-61cb-47bb-8407-4be72b5577b0} 0xffffffffffffffff 0xff -ets > NUL 2>&1
   logman update trace "%boot%nfs_trace" -p {6361F674-C2C0-4F6B-AE19-8C62F47AE3FB} 0xffffffffffffffff 0xff -ets > NUL 2>&1
   logman update trace "%boot%nfs_trace" -p {E18A05DC-CCE3-4093-B5AD-211E4C798A0D} 0xffffffffffffffff 0xff -ets > NUL 2>&1
   logman update trace "%boot%nfs_trace" -p {94B45058-6F59-4696-B6BC-B23B7768343D} 0xffffffffffffffff 0xff -ets > NUL 2>&1
   logman create trace "%boot%network_trace" -ow -o %tracelogdir%\network_trace_%logdate%.etl -p {DD7A21E6-A651-46D4-B7C2-66543067B869} 0xffffffffffffffff 0xff -nb 16 16 -bs 1024 -mode Circular -f bincirc -max 4096 -ets > NUL 2>&1
   logman update trace "%boot%network_trace" -p {eb004a05-9b1a-11d4-9123-0050047759bc} 0xffffffffffffffff 0xff -ets > NUL 2>&1
   logman update trace "%boot%network_trace" -p {E53C6823-7BB8-44BB-90DC-3F86090D48A6} 0xffffffffffffffff 0xff -ets > NUL 2>&1
   logman update trace "%boot%network_trace" -p {2F07E2EE-15DB-40F1-90EF-9D7BA282188A} 0xffffffffffffffff 0xff -ets > NUL 2>&1
   logman update trace "%boot%network_trace" -p {B40AEF77-892A-46F9-9109-438E399BB894} 0xffffffffffffffff 0xff -ets > NUL 2>&1

   if DEFINED boot (
      reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\WMI\Autologger\nfs_trace /v FileName /t REG_SZ /d "%bootlogdir%\boot_nfs_trace.etl" /f > NUL 2>&1
      reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\WMI\Autologger\network_trace /v FileName /t REG_SZ /d "%bootlogdir%\boot_network_trace.etl" /f > NUL 2>&1
   )
)

if /i "%1" =="stop" (
   logman stop "nfs_trace" -ets > NUL 2>&1
   logman stop "network_trace" -ets > NUL 2>&1

   if DEFINED boot (
      logman delete "%boot%nfs_trace" > NUL 2>&1
      logman delete "%boot%network_trace" > NUL 2>&1
   )
echo Tracing has been captured and saved at %basedir%.
)
exit /b
REM =================================================================

REM =================================================================
REM iscsi   collecting iSCSI driver trace.
REM =================================================================
REM 1BABEFB4-59CB-49E5-9698-FD38AC830A91 => iSCSI
REM =================================================================
:ISCSI
if /i "%1" =="start" (
   logman create trace "%boot%iscsi_trace" -ow -o %tracelogdir%\iscsi_trace_%logdate%.etl -p {1BABEFB4-59CB-49E5-9698-FD38AC830A91} 0xffffffffffffffff 0xff -nb 16 16 -bs 1024 -mode Circular -f bincirc -max 4096 -ets > NUL 2>&1

   if DEFINED boot (
      reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\WMI\Autologger\iscsi_trace /v FileName /t REG_SZ /d "%bootlogdir%\boot_iscsi_trace.etl" /f > NUL 2>&1
   )
)

if /i "%1" =="stop" (
   logman stop "%boot%iscsi_trace" -ets > NUL 2>&1

   if DEFINED boot (
      logman delete "%boot%iscsi_trace" > NUL 2>&1
   )
echo Tracing has been captured and saved at %basedir%.
)
exit /b
REM =================================================================

REM =================================================================
REM csv     collecting CSV drivers trace.
REM =================================================================
REM D82DBA12-8B70-49EE-B844-44D0885951D2 => CSVFLT
REM 4E6177A5-C0A7-4D9B-A686-56ED5435A908 => CtlGuid ### nfilter is removed.
REM 4E6177A5-C0A7-4D9B-A686-56ED5435A904 => VBus
REM B421540C-1FC8-4C24-90CC-C5166E1DE302 => CSVFLT
REM 151D3C03-E442-4C4F-AF20-BD48FF41F793 => Microsoft-Windows-FailoverClustering-CsvFlt-Diagnostic
REM 6A86AE90-4E9B-4186-B1D1-9CE0E02BCBC1 => Microsoft-Windows-FailoverClustering-CsvFs-Diagnostic
REM =================================================================
:CSV
if /i "%1" =="start" (
   logman create trace "%boot%csv_trace" -ow -o %tracelogdir%\csv_trace_%logdate%.etl -p {D82DBA12-8B70-49EE-B844-44D0885951D2} 0xffffffffffffffff 0xff -nb 16 16 -bs 1024 -mode Circular -f bincirc -max 4096 -ets > NUL 2>&1
   logman update trace "%boot%csv_trace" -p {4E6177A5-C0A7-4D9B-A686-56ED5435A904} 0xffffffffffffffff 0xff -ets > NUL 2>&1
   logman update trace "%boot%csv_trace" -p {B421540C-1FC8-4C24-90CC-C5166E1DE302} 0xffffffffffffffff 0xff -ets > NUL 2>&1
   logman update trace "%boot%csv_trace" -p {151D3C03-E442-4C4F-AF20-BD48FF41F793} 0xffffffffffffffff 0xff -ets > NUL 2>&1
   logman update trace "%boot%csv_trace" -p {6A86AE90-4E9B-4186-B1D1-9CE0E02BCBC1} 0xffffffffffffffff 0xff -ets > NUL 2>&1

   if DEFINED boot (
      reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\WMI\Autologger\csv_trace /v FileName /t REG_SZ /d "%bootlogdir%\boot_csv_trace.etl" /f > NUL 2>&1
   )
)

if /i "%1" =="stop" (
   logman stop "csv_trace" -ets > NUL 2>&1

   if DEFINED boot (
      logman delete "%boot%csv_trace" > NUL 2>&1
   )
echo Tracing has been captured and saved at %basedir%.
)
exit /b
REM =================================================================

REM =================================================================
REM wmi     collecting WMI services trace.
REM =================================================================
REM 1FF6B227-2CA7-40F9-9A66-980EADAA602E => WMI_Tracing
REM 1EDEEE53-0AFE-4609-B846-D8C0B2075B1F => Microsoft-Windows-WMI
REM 1418EF04-B0B4-4623-BF7E-D74AB47BBDAA => Microsoft-Windows-WMI-Activity
REM 1FF6B227-2CA7-40F9-9A66-980EADAA602E => WMI_Tracing_Guid
REM 8E6B6962-AB54-4335-8229-3255B919DD0E => WMI_Tracing_Client_Operations_Info_Guid
REM 2CF953C0-8DF7-48E1-99B9-6816A2FBDC9F => Microsoft-Windows-WMIAdapter
REM =================================================================
:WMI
if /i "%1" =="start" (
   logman create trace "%boot%wmi_trace" -ow -o %tracelogdir%\wmi_trace_%logdate%.etl -p {1FF6B227-2CA7-40F9-9A66-980EADAA602E} 0xffffffffffffffff 0xff -nb 16 16 -bs 1024 -mode Circular -f bincirc -max 4096 -ets > NUL 2>&1
   logman update trace "%boot%wmi_trace" -p {1EDEEE53-0AFE-4609-B846-D8C0B2075B1F} 0xffffffffffffffff 0xff -ets > NUL 2>&1
   logman update trace "%boot%wmi_trace" -p {1418EF04-B0B4-4623-BF7E-D74AB47BBDAA} 0xffffffffffffffff 0xff -ets > NUL 2>&1
   logman update trace "%boot%wmi_trace" -p {1FF6B227-2CA7-40F9-9A66-980EADAA602E} 0xffffffffffffffff 0xff -ets > NUL 2>&1
   logman update trace "%boot%wmi_trace" -p {8E6B6962-AB54-4335-8229-3255B919DD0E} 0xffffffffffffffff 0xff -ets > NUL 2>&1
   logman update trace "%boot%wmi_trace" -p {2CF953C0-8DF7-48E1-99B9-6816A2FBDC9F} 0xffffffffffffffff 0xff -ets > NUL 2>&1

   if DEFINED boot (
      reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\WMI\Autologger\wmi_trace /v FileName /t REG_SZ /d "%bootlogdir%\boot_wmi_trace.etl" /f > NUL 2>&1
   )
)

if /i "%1" =="stop" (
   logman stop "wmi_trace" -ets > NUL 2>&1

   if DEFINED boot (
      logman delete "%boot%wmi_trace" > NUL 2>&1
   )
echo Tracing has been captured and saved at %basedir%.
)
exit /b
REM =================================================================

REM =================================================================
REM rpc     collecting RPC services trace.
REM =================================================================
REM 272A979B-34B5-48EC-94F5-7225A59C85A0 => Microsoft-Windows-RPC-Proxy-LBS
REM 879B2576-39D1-4C0F-80A4-CC086E02548C => Microsoft-Windows-RPC-Proxy
REM 536CAA1F-798D-4CDB-A987-05F79A9F457E => Microsoft-Windows-RPC-LBS
REM 6AD52B32-D609-4BE9-AE07-CE8DAE937E39 => Microsoft-Windows-RPC 
REM F4AED7C7-A898-4627-B053-44A7CAA12FCD => Microsoft-Windows-RPC-Events
REM D8975F88-7DDB-4ED0-91BF-3ADF48C48E0C => Microsoft-Windows-RPCSS
REM =================================================================
:RPC
if /i "%1" =="start" (
   logman create trace "%boot%rpc_trace" -ow -o %tracelogdir%\rpc_trace_%logdate%.etl -p {272A979B-34B5-48EC-94F5-7225A59C85A0} 0xffffffffffffffff 0xff -nb 16 16 -bs 1024 -mode Circular -f bincirc -max 4096 -ets > NUL 2>&1
   logman update trace "%boot%rpc_trace" -p {879B2576-39D1-4C0F-80A4-CC086E02548C} 0xffffffffffffffff 0xff -ets > NUL 2>&1
   logman update trace "%boot%rpc_trace" -p {536CAA1F-798D-4CDB-A987-05F79A9F457E} 0xffffffffffffffff 0xff -ets > NUL 2>&1
   logman update trace "%boot%rpc_trace" -p {6AD52B32-D609-4BE9-AE07-CE8DAE937E39} 0xffffffffffffffff 0xff -ets > NUL 2>&1
   logman update trace "%boot%rpc_trace" -p {F4AED7C7-A898-4627-B053-44A7CAA12FCD} 0xffffffffffffffff 0xff -ets > NUL 2>&1
   logman update trace "%boot%rpc_trace" -p {D8975F88-7DDB-4ED0-91BF-3ADF48C48E0C} 0xffffffffffffffff 0xff -ets > NUL 2>&1

   if DEFINED boot (
      reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\WMI\Autologger\rpc_trace /v FileName /t REG_SZ /d "%bootlogdir%\boot_rpc_trace.etl" /f > NUL 2>&1
   )
)

if /i "%1" =="stop" (
   logman stop "rpc_trace" -ets > NUL 2>&1

   if DEFINED boot (
      logman delete "%boot%rpc_trace" > NUL 2>&1
   )
echo Tracing has been captured and saved at %basedir%.
)
exit /b
REM =================================================================

REM =================================================================
REM hyper-v     collection Hyper-V modules trace.
REM =================================================================
REM collecting Hyper-V Analystic logs
REM =================================================================
:Hyper-V
if /i "%1" =="start" (
   reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Virtualization\VML" /v TraceLevel /t REG_DWORD /d 3 /f
   for /f "usebackq tokens=1*" %%e in (`wevtutil el ^| findstr Microsoft-Windows-Hyper-V.*-Analytic`) do (
      wevtutil sl %%e /rt:false /ms:67108864 /e:true /q > NUL 2>&1
   )

   for /f "usebackq tokens=1*" %%e in (`wevtutil el ^| findstr Microsoft-Windows-Hyper-V.*-Debug`) do (
      wevtutil sl %%e /rt:false /ms:67108864 /e:true /q > NUL 2>&1
   )
)

if /i "%1" =="stop" (
   reg delete "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Virtualization\VML" /v TraceLevel /f
   for /f "usebackq tokens=1*" %%e in (`wevtutil el ^| findstr Microsoft-Windows-Hyper-V.*-Analytic`) do (
      wevtutil sl %%e /e:false > NUL 2>&1
      copy %SystemRoot%\System32\Winevt\Logs\%%e.etl %tracelogdir%\%%e_%logdate%.etl > NUL 2>&1
   )

   for /f "usebackq tokens=1*" %%e in (`wevtutil el ^| findstr Microsoft-Windows-Hyper-V.*-Debug`) do (
      wevtutil sl %%e /e:false > NUL 2>&1
      copy %SystemRoot%\System32\Winevt\Logs\%%e.etl %tracelogdir%\%%e_%logdate%.etl > NUL 2>&1
   )
echo Tracing has been captured and saved at %basedir%.
)
exit /b
REM =================================================================

REM =================================================================
REM cluster-manager     collection Failover Clustering Manager trace.
REM =================================================================
REM collecting Failover Clustering Manager trace logs
REM =================================================================
:Cluster-Manager
if /i "%1" =="start" (
   for /f "usebackq tokens=1*" %%e in (`wevtutil el ^| findstr FailoverClustering-Manager.*Diagnostic`) do (
      wevtutil sl %%e /rt:false /ms:67108864 /e:true /q > NUL 2>&1
   )

   for /f "usebackq tokens=1*" %%e in (`wevtutil el ^| findstr FailoverClustering-Manager.*Tracing`) do (
      wevtutil sl %%e /rt:false /ms:67108864 /e:true /q > NUL 2>&1
   )

   for /f "usebackq tokens=1*" %%e in (`wevtutil el ^| findstr FailoverClustering-WMIProvider.*Diagnostic`) do (
      wevtutil sl %%e /rt:false /ms:67108864 /e:true /q > NUL 2>&1
   )
)

if /i "%1" =="stop" (
   for /f "usebackq tokens=1*" %%e in (`wevtutil el ^| findstr FailoverClustering-Manager.*Diagnostic`) do (
      wevtutil sl %%e /e:false > NUL 2>&1
      wevtutil qe %%e /f:text > %tracelogdir%\FailoverClustering-Manager-Diagnostic_%logdate%.txt 2>&1
      wevtutil epl %%e %tracelogdir%\FailoverClustering-Manager-Diagnostic_%logdate%.evtx > NUL 2>&1
   )

   for /f "usebackq tokens=1*" %%e in (`wevtutil el ^| findstr FailoverClustering-Manager.*Tracing`) do (
      wevtutil sl %%e /e:false > NUL 2>&1
      wevtutil qe %%e /f:text > %tracelogdir%\FailoverClustering-Manager-Tracing_%logdate%.txt 2>&1
      wevtutil epl %%e %tracelogdir%\FailoverClustering-Manager-Tracing_%logdate%.evtx > NUL 2>&1
   )

   for /f "usebackq tokens=1*" %%e in (`wevtutil el ^| findstr FailoverClustering-WMIProvider.*Diagnostic`) do (
      wevtutil sl %%e /e:false > NUL 2>&1
      wevtutil qe %%e /f:text > %tracelogdir%\FailoverClustering-WMIProvider-Diagnostic_%logdate%.txt 2>&1
      wevtutil epl %%e %tracelogdir%\FailoverClustering-WMIProvider-Diagnostic_%logdate%.evtx > NUL 2>&1
   )

echo Tracing has been captured and saved at %basedir%.
)
exit /b
REM =================================================================

REM =================================================================
REM space     collecting Storage Space trace.
REM =================================================================
REM =================================================================
:SPACE
if /i "%1" =="start" (
   logman create trace "%boot%StorageSpace" -ow -o %tracelogdir%\StorageSpace_%logdate%.etl -p "Microsoft-Windows-StorageSpaces-ManagementAgent" 0xffffffffffffffff 0xff -nb 16 16 -bs 1024 -mode Circular -f bincirc -max 4096 -ets > NUL 2>&1
   logman update trace "%boot%StorageSpace" -p `"Microsoft-Windows-StorageSpaces-Driver`" 0xffffffffffffffff 0xff -ets > NUL 2>&1
   logman update trace "%boot%StorageSpace" -p `{929C083B-4C64-410A-BFD4-8CA1B6FCE362`} 0xffffffffffffffff 0xff -ets > NUL 2>&1

   if DEFINED boot (
      reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\WMI\Autologger\StorageSpace /v FileName /t REG_SZ /d "%bootlogdir%\boot_StorageSpace.etl" /f > NUL 2>&1
   )
)

if /i "%1" =="stop" (
   logman stop "StorageSpace" -ets > NUL 2>&1

   if DEFINED boot (
      logman delete "%boot%StorageSpace" > NUL 2>&1
   )
echo Tracing has been captured and saved at %basedir%.
)
exit /b
REM =================================================================

REM =================================================================
REM storagereplica     collecting Storage Replica trace.
REM =================================================================
REM 35A2925C-30A3-43EB-B737-03E9659955E2 => Microsoft-Windows-StorageReplica-Cluster
REM CE171FD7-A5BA-4D95-926B-6DC4D89E8171 => Microsoft-Windows-StorageReplica-Service
REM F661B376-6E59-4483-89F8-D5ACA1816EAD => Microsoft-Windows-StorageReplica
REM =================================================================
:STORAGEREPLICA
if /i "%1" =="start" (
   logman create trace "%boot%StorageReplica" -ow -o %tracelogdir%\StorageReplica_%logdate%.etl -p {35A2925C-30A3-43EB-B737-03E9659955E2} 0xffffffffffffffff 0xff -nb 16 16 -bs 1024 -mode Circular -f bincirc -max 4096 -ets > NUL 2>&1
   logman update trace "%boot%StorageReplica" -p {CE171FD7-A5BA-4D95-926B-6DC4D89E8171} 0xffffffffffffffff 0xff -ets > NUL 2>&1
   logman update trace "%boot%StorageReplica" -p {F661B376-6E59-4483-89F8-D5ACA1816EAD} 0xffffffffffffffff 0xff -ets > NUL 2>&1

   if DEFINED boot (
      reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\WMI\Autologger\StorageReplica /v FileName /t REG_SZ /d "%bootlogdir%\boot_StorageReplica.etl" /f > NUL 2>&1
   )
)

if /i "%1" =="stop" (
   logman stop "StorageReplica" -ets > NUL 2>&1

   if DEFINED boot (
      logman delete "%boot%StorageReplica" > NUL 2>&1
   )
echo Tracing has been captured and saved at %basedir%.
)
exit /b
REM =================================================================

REM =================================================================
REM packet    collecting Network Packet Capture. (Windows Server 2008 R2 or later)
REM =================================================================
:PACKET
if /i "%1" =="start" (
   if DEFINED boot (
      netsh trace start capture=yes persistent=yes maxsize=2048 traceFile=%tracelogdir%\packet_capture_%logdate%.etl
   ) else (
      netsh trace start capture=yes maxsize=2048 traceFile=%tracelogdir%\packet_capture_%logdate%.etl
   )
)

if /i "%1" =="stop" (
   netsh trace stop

echo Tracing has been captured and saved at %basedir%.
)
exit /b
REM =================================================================

REM =================================================================
REM support   collecting support information logs.
REM =================================================================
:SUPPORT
echo start collecting support logs.
md %basedir% > NUL 2>&1
md %supportlogdir% > NUL 2>&1

set /p prompt=collecting disk info ... <NUL
md %supportlogdir%\disk > NUL 2>&1
powershell "Get-Disk" > %supportlogdir%\disk\get-disk.txt 2>&1
powershell "Get-Disk | select *" > %supportlogdir%\disk\get-disk-detail.txt 2>&1
powershell "Get-PhysicalDisk" > %supportlogdir%\disk\get-physicaldisk.txt 2>&1
powershell "Get-PhysicalDisk | select *" > %supportlogdir%\disk\get-physicaldisk-detail.txt 2>&1
powershell "Get-VirtualDisk" > %supportlogdir%\disk\get-virtualdisk.txt 2>&1
powershell "Get-VirtualDisk | select *" > %supportlogdir%\disk\get-virtualdisk-detail.txt 2>&1
powershell "Get-StoragePool" > %supportlogdir%\disk\get-storagepool.txt 2>&1
powershell "Get-StoragePool | select *" > %supportlogdir%\disk\get-storagepool-detail.txt 2>&1
powershell "Get-StorageTier" > %supportlogdir%\disk\get-storagetier.txt 2>&1
powershell "Get-StorageTier | select *" > %supportlogdir%\disk\get-storagetier-detail.txt 2>&1
powershell "Get-StorageJob" > %supportlogdir%\disk\get-storagejob.txt 2>&1
powershell "Get-StorageJob | select *" > %supportlogdir%\disk\get-storagejob-detail.txt 2>&1
powershell "Get-Partition" > %supportlogdir%\disk\get-partition.txt 2>&1
powershell "Get-Partition | select *" > %supportlogdir%\disk\get-partition-detail.txt 2>&1
powershell "Get-Volume" > %supportlogdir%\disk\get-volume.txt 2>&1
powershell "Get-Volume | select *" > %supportlogdir%\disk\get-volume-detail.txt 2>&1
powershell "Get-StorageEnclosure" > %supportlogdir%\disk\get-storageenclosure.txt 2>&1
powershell "Get-StorageEnclosure | select *" > %supportlogdir%\disk\get-storageenclosure-detail.txt 2>&1
powershell "Get-StorageFaultDomain" > %supportlogdir%\disk\get-storagefaultdomain.txt 2>&1
powershell "Get-StorageFaultDomain | select *" > %supportlogdir%\disk\get-storagefaultdomain-detail.txt 2>&1
powershell "Get-StorageSubsystem" > %supportlogdir%\disk\get-storagesubsystem.txt 2>&1
powershell "Get-StorageSubsystem | select *" > %supportlogdir%\disk\get-storagesubsystem-detail.txt 2>&1
powershell "Get-DedupStatus" > %supportlogdir%\disk\get-dedupstatus.txt 2>&1
powershell "Get-DedupStatus | select *" > %supportlogdir%\disk\get-dedupstatus-detail.txt 2>&1

.\libs\dosdev.exe -a > %supportlogdir%\disk\dosdev.txt 2>&1
.\libs\SAN6.3.0.1\Win32\san.exe /d %supportlogdir%\disk > NUL 2>&1
.\libs\SAN6.3.0.1\Win32\san.exe /s %supportlogdir%\disk > NUL 2>&1
.\libs\SAN6.3.0.1\Win32\san.exe /h %supportlogdir%\disk > NUL 2>&1

diskpart /s .\libs\automount.dat > %supportlogdir%\disk\automount.txt 2>&1
mountvol > %supportlogdir%\disk\mountvol.txt 2>&1

if EXIST c:\windows\system32\mpclaim.exe (
mpclaim -s -d > %supportlogdir%\disk\mpclaim-s-d.txt 2>&1
for /f "tokens=2 usebackq delims=:" %%i in (`wmic /namespace:\\root\wmi path MPIO_DISK_INFO get NumberDrives ^| findstr /n /v Number ^| findstr :.`) do (
   for /l %%j IN (1,1,%%i) do (
      set /a count=%%j-1
      mpclaim -s -d !count! >> %supportlogdir%\disk\mpclaim-s-d-all.txt 2>&1
   )
)
)
echo done.

if EXIST c:\windows\system32\iscsicli.exe (
   set /p prompt=Start iSCSI configuration ... <NUL
   md %supportlogdir%\iscsi > NUL 2>&1
   iscsicli.exe ListInitiators > %supportlogdir%\iscsi\ListInitiators.txt 2>&1
   iscsicli.exe ListTargetPortals > %supportlogdir%\iscsi\ListTargetPortals.txt 2>&1
   iscsicli.exe SessionList > %supportlogdir%\iscsi\SessionList.txt 2>&1
   iscsicli.exe ListPersistentTargets > %supportlogdir%\iscsi\ListPersistentTargets.txt 2>&1
   iscsicli.exe ReportTargetMappings > %supportlogdir%\iscsi\ReportTargetMappings.txt 2>&1
   iscsicli.exe ListiSNSServers > %supportlogdir%\iscsi\ListiSNSServers.txt 2>&1
   echo done.
)

if EXIST c:\windows\system32\nfsadmin.exe (
set /p prompt=Start NFS configuration ... <NUL
md %supportlogdir%\nfs > NUL 2>&1
nfsadmin server > %supportlogdir%\nfs\nfsadmin-server.txt 2>&1
nfsadmin client > %supportlogdir%\nfs\nfsadmin-client.txt 2>&1
nfsadmin mapping > %supportlogdir%\nfs\nfsadmin-mapping.txt 2>&1
powershell "Get-NfsMountedClient" > %supportlogdir%\nfs\Get-NfsMountedClient.txt 2>&1
powershell "Get-NfsNetgroupStore" > %supportlogdir%\nfs\Get-NfsNetgroupStore.txt 2>&1
powershell "Get-NfsOpenFile" > %supportlogdir%\nfs\Get-NfsOpenFile.txt 2>&1
powershell "Get-NfsServerConfiguration" > %supportlogdir%\nfs\Get-NfsServerConfiguration.txt 2>&1
powershell "Get-NfsSession" > %supportlogdir%\nfs\Get-NfsSession.txt 2>&1
powershell "Get-NfsShare | select *" > %supportlogdir%\nfs\Get-NfsShare.txt 2>&1
powershell "Get-NfsStatistics" > %supportlogdir%\nfs\Get-NfsStatistics.txt 2>&1
nfsshare > %supportlogdir%\nfs\nfsshare.txt 2>&1
wmic /namespace:\\root\Microsoft\Windows\NFS path MSFT_NfsShare > %supportlogdir%\nfs\MSFT_NfsShare.txt 2>&1
for /f "tokens=1 usebackq delims==" %%i in (`nfsshare ^| findstr ^=`) do (
nfsshare %%i >> %supportlogdir%\nfs\nfsshare-all.txt 2>&1
echo ========================== >> %supportlogdir%\nfs\nfsshare-all.txt 2>&1
)
echo done.
)

if EXIST C:\Windows\system32\wvrsvc.exe (
set /p prompt=Start Storage Replica configuration ... <NUL
md %supportlogdir%\StorageReplica > NUL 2>&1
powershell "Get-SRGroup | select *" > %supportlogdir%\StorageReplica\Get-SRGroup.txt 2>&1
powershell "(Get-SRGroup).replicas" > %supportlogdir%\StorageReplica\Get-SRGroup-replicas.txt 2>&1
powershell "Get-SRAccess | select *" > %supportlogdir%\StorageReplica\Get-SRAccess.txt 2>&1
powershell "Get-SRNetworkConstraint | select *" > %supportlogdir%\StorageReplica\Get-SRNetworkConstraint.txt 2>&1
powershell "Get-SRPartnership | select *" > %supportlogdir%\StorageReplica\Get-SRPartnership.txt 2>&1
echo done.
)

set /p prompt=Start VSS info ... <NUL
md %supportlogdir%\vss > NUL 2>&1
vssadmin list Providers > %supportlogdir%\vss\vssadmin_list_providers.txt 2>&1
vssadmin list Shadows > %supportlogdir%\vss\vssadmin_list_shadows.txt 2>&1
vssadmin list ShadowStorage > %supportlogdir%\vss\vssadmin_list_shadowstorage.txt 2>&1
vssadmin list Volumes > %supportlogdir%\vss\vssadmin_list_volumes.txt 2>&1
vssadmin list Writers  > %supportlogdir%\vss\vssadmin_list_writers.txt 2>&1
diskshadow /s .\libs\list_shadows_all.dat /l %supportlogdir%\vss\diskshadow_list_shadows_all.txt > NUL 2>&1
diskshadow /s .\libs\list_writers_detailed.dat /l %supportlogdir%\vss\diskshadow_list_writers_detailed.txt > NUL 2>&1
echo done.

set /p prompt=Start fltmc ... <NUL
md %supportlogdir%\fltmc > NUL 2>&1
fltmc filters > %supportlogdir%\fltmc\fltmc-filters.log 2>&1
fltmc volumes > %supportlogdir%\fltmc\fltmc-volumes.log 2>&1
fltmc instances > %supportlogdir%\fltmc\fltmc-instances.log 2>&1

echo done.
set /p prompt=Collecting setup info and winlog files ... <NUL
md %supportlogdir%\setup > NUL 2>&1
wmic qfe > %supportlogdir%\setup\qfe.txt 2>&1
Powershell "Get-HotFix | select *" > %supportlogdir%\setup\get-hotfix.log 2>&1
md %supportlogdir%\setup\CBS > NUL 2>&1
xcopy /s /e /c C:\Windows\Logs\CBS\* %supportlogdir%\setup\CBS > NUL 2>&1
md %supportlogdir%\setup\DISM > NUL 2>&1
xcopy /s /e /c C:\Windows\Logs\DISM\* %supportlogdir%\setup\DISM > NUL 2>&1
md %supportlogdir%\WindowsServerBackup > NUL 2>&1
xcopy /s /e /c C:\Windows\Logs\WindowsServerBackup\* %supportlogdir%\WindowsServerBackup > NUL 2>&1
Copy %Windir%\WindowsUpdate.log %supportlogdir%\setup > NUL 2>&1
Copy %Windir%\SoftwareDistribution\ReportingEvents.log %supportlogdir%\setup > NUL 2>&1
Copy %Windir%\IE11_main.log %supportlogdir%\setup > NUL 2>&1
Copy %Windir%\inf\setupapi.* %supportlogdir%\setup > NUL 2>&1
Copy %Windir%\WinSXS\pending.xml.* %supportlogdir%\setup > NUL 2>&1
Copy %Windir%\WinSXS\poqexec.log %supportlogdir%\setup > NUL 2>&1
Copy %WinDir%\System32\LogFiles\SCM\*.EVM*  %supportlogdir%\setup > NUL 2>&1
md %supportlogdir%\setup\USOSharedLogs > NUL 2>&1
xcopy /s /e /c %programdata%\USOShared\Logs %supportlogdir%\setup\USOSharedLogs > NUL 2>&1
BitsAdmin /list /AllUsers /Verbose > %supportlogdir%\setup\BitsAdmin.log 2>&1
dir /t:c /a /s /c /n C:\ > %supportlogdir%\setup\dir-Windows.log 2>&1
bcdedit /enum all > %supportlogdir%\setup\BCDedit.log 2>&1
dism /Online /Get-intl > %supportlogdir%\setup\Get_intl.log 2>&1
dism /Online /Get-Packages /Format:Table > %supportlogdir%\setup\Get-Packages.log 2>&1
dism /Online /Get-Features /Format:Table > %supportlogdir%\setup\Get-Features.log 2>&1
icacls C:\ > %supportlogdir%\setup\c-driveicacls.log 2>&1
icacls %SystemRoot%\System32\config /t /c > %supportlogdir%\setup\configicacls.log 2>&1
icacls %SystemRoot%\inf /t /c > %supportlogdir%\setup\inficacls.log 2>&1
icacls %SystemRoot%\SoftwareDistribution /t /c > %supportlogdir%\setup\SoftwareDistributionicacls.log 2>&1
icacls C:\Windows\winsxs\catalogs /t /c  > %supportlogdir%\setup\Winsxsicacls.log 2>&1
sc queryex > %supportlogdir%\setup\sc_queryex.log 2>&1
sc sdshow TrustedInstaller > %supportlogdir%\setup\TrustedInstaller_sdshow.log 2>&1
sc sdshow wuauserv > %supportlogdir%\setup\wuauserv_sdshow.log 2>&1
echo done.

set /p prompt=Copy Eventlog files ... <NUL
md %supportlogdir%\eventlog > NUL 2>&1
wevtutil epl System %supportlogdir%\eventlog\System.evtx > NUL 2>&1
wevtutil epl Application %supportlogdir%\eventlog\Application.evtx > NUL 2>&1
wevtutil epl Setup %supportlogdir%\eventlog\Setup.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-Hyper-V-Compute-Admin %supportlogdir%\eventlog\Microsoft-Windows-Hyper-V-Compute-Admin.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-Hyper-V-Compute-Operational %supportlogdir%\eventlog\Microsoft-Windows-Hyper-V-Compute-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-Hyper-V-Guest-Drivers/Admin %supportlogdir%\eventlog\Microsoft-Windows-Hyper-V-Guest-Drivers-Admin.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-Hyper-V-Shared-VHDX/Operational %supportlogdir%\eventlog\Microsoft-Windows-Hyper-V-Shared-VHDX-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-Hyper-V-Shared-VHDX/Reservation %supportlogdir%\eventlog\Microsoft-Windows-Hyper-V-Shared-VHDX-Reservation.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-Hyper-V-StorageVSP-Admin %supportlogdir%\eventlog\Microsoft-Windows-Hyper-V-StorageVSP-Admin.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-Hyper-V-VmSwitch-Operational %supportlogdir%\eventlog\Microsoft-Windows-Hyper-V-VmSwitch-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-Hyper-V-Config-Admin %supportlogdir%\eventlog\Microsoft-Windows-Hyper-V-Config-Admin.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-Hyper-V-Config-Operational %supportlogdir%\eventlog\Microsoft-Windows-Hyper-V-Config-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-Hyper-V-Hypervisor-Admin %supportlogdir%\eventlog\Microsoft-Windows-Hyper-V-Hypervisor-Admin.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-Hyper-V-Hypervisor-Operational %supportlogdir%\eventlog\Microsoft-Windows-Hyper-V-Hypervisor-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-Hyper-V-Integration-Admin %supportlogdir%\eventlog\Microsoft-Windows-Hyper-V-Integration-Admin.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-Hyper-V-SynthFc-Admin %supportlogdir%\eventlog\Microsoft-Windows-Hyper-V-SynthFc-Admin.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-Hyper-V-SynthNic-Admin %supportlogdir%\eventlog\Microsoft-Windows-Hyper-V-SynthNic-Admin.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-Hyper-V-SynthStor-Admin %supportlogdir%\eventlog\Microsoft-Windows-Hyper-V-SynthStor-Admin.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-Hyper-V-SynthStor-Operational %supportlogdir%\eventlog\Microsoft-Windows-Hyper-V-SynthStor-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-Hyper-V-VID-Admin %supportlogdir%\eventlog\Microsoft-Windows-Hyper-V-VID-Admin.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-Hyper-V-VMMS-Admin %supportlogdir%\eventlog\Microsoft-Windows-Hyper-V-VMMS-Admin.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-Hyper-V-VMMS-Networking %supportlogdir%\eventlog\Microsoft-Windows-Hyper-V-VMMS-Networking.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-Hyper-V-VMMS-Operational %supportlogdir%\eventlog\Microsoft-Windows-Hyper-V-VMMS-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-Hyper-V-VMMS-Storage %supportlogdir%\eventlog\Microsoft-Windows-Hyper-V-VMMS-Storage.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-Hyper-V-Worker-Admin %supportlogdir%\eventlog\Microsoft-Windows-Hyper-V-Worker-Admin.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-VHDMP/Operational %supportlogdir%\eventlog\Microsoft-Windows-VHDMP-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-Hyper-V-High-Availability-Admin %supportlogdir%\eventlog\Microsoft-Windows-Hyper-V-High-Availability-Admin.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-FailoverClustering/Operational %supportlogdir%\eventlog\Microsoft-Windows-FailoverClustering-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-FailoverClustering-Manager/Admin %supportlogdir%\eventlog\Microsoft-Windows-FailoverClustering-Manager-Admin.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-FailoverClustering-WMIProvider/Admin %supportlogdir%\eventlog\Microsoft-Windows-FailoverClustering-WMIProvider-Admin.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-Backup %supportlogdir%\eventlog\Microsoft-Windows-Backup.evtx > NUL 2>&1
wevtutil epl "Microsoft-Windows-BitLocker/BitLocker Management" %supportlogdir%\eventlog\Microsoft-Windows-BitLocker-Management.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-BitLocker-DrivePreparationTool/Admin %supportlogdir%\eventlog\Microsoft-Windows-BitLocker-DrivePreparationTool-Admin.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-BitLocker-DrivePreparationTool/Operational %supportlogdir%\eventlog\Microsoft-Windows-BitLocker-DrivePreparationTool-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-ClusterAwareUpdating/Admin %supportlogdir%\eventlog\Microsoft-Windows-ClusterAwareUpdating-Admin.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-ClusterAwareUpdating-Management/Admin %supportlogdir%\eventlog\Microsoft-Windows-ClusterAwareUpdating-Management-Admin.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-Containers-Wcifs/Operational %supportlogdir%\eventlog\Microsoft-Windows-Containers-Wcifs-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-Containers-Wcnfs/Operational %supportlogdir%\eventlog\Microsoft-Windows-Containers-Wcnfs-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-DataIntegrityScan/Admin %supportlogdir%\eventlog\Microsoft-Windows-DataIntegrityScan-Admin.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-DataIntegrityScan/CrashRecovery %supportlogdir%\eventlog\Microsoft-Windows-DataIntegrityScan-CrashRecovery.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-Deduplication/Diagnostic %supportlogdir%\eventlog\Microsoft-Windows-Deduplication-Diagnostic.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-Deduplication/Operational %supportlogdir%\eventlog\Microsoft-Windows-Deduplication-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-Deduplication/Scrubbing %supportlogdir%\eventlog\Microsoft-Windows-Deduplication-Scrubbing.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-DeviceGuard/Operational %supportlogdir%\eventlog\Microsoft-Windows-DeviceGuard-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-DeviceSetupManager/Admin %supportlogdir%\eventlog\Microsoft-Windows-DeviceSetupManager-Admin.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-DeviceSetupManager/Operational %supportlogdir%\eventlog\Microsoft-Windows-DeviceSetupManager-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-Diagnostics-Networking/Operational %supportlogdir%\eventlog\Microsoft-Windows-Diagnostics-Networking-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-DiskDiagnostic/Operational %supportlogdir%\eventlog\Microsoft-Windows-DiskDiagnostic-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-DiskDiagnosticDataCollector/Operational %supportlogdir%\eventlog\Microsoft-Windows-DiskDiagnosticDataCollector-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-DiskDiagnosticResolver/Operational %supportlogdir%\eventlog\Microsoft-Windows-DiskDiagnosticResolver-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-FailoverClustering/Diagnostic %supportlogdir%\eventlog\Microsoft-Windows-FailoverClustering-Diagnostic.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-FailoverClustering/DiagnosticVerbose %supportlogdir%\eventlog\Microsoft-Windows-FailoverClustering-DiagnosticVerbose.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-FailoverClustering-ClusBflt/Management %supportlogdir%\eventlog\Microsoft-Windows-FailoverClustering-ClusBflt-Management.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-FailoverClustering-ClusBflt/Operational %supportlogdir%\eventlog\Microsoft-Windows-FailoverClustering-ClusBflt-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-FailoverClustering-Clusport/Operational %supportlogdir%\eventlog\Microsoft-Windows-FailoverClustering-Clusport-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-FailoverClustering-CsvFs/Operational %supportlogdir%\eventlog\Microsoft-Windows-FailoverClustering-CsvFs-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-FailoverClustering-NetFt/Operational %supportlogdir%\eventlog\Microsoft-Windows-FailoverClustering-NetFt-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-Health/Operational %supportlogdir%\eventlog\Microsoft-Windows-Health-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-HostGuardianService-Client/Admin %supportlogdir%\eventlog\Microsoft-Windows-HostGuardianService-Client-Admin.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-HostGuardianService-Client/Operational %supportlogdir%\eventlog\Microsoft-Windows-HostGuardianService-Client-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-Host-Network-Service-Admin %supportlogdir%\eventlog\Microsoft-Windows-Host-Network-Service-Admin.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-Host-Network-Service-Operational %supportlogdir%\eventlog\Microsoft-Windows-Host-Network-Service-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-iSCSITarget-Service/Admin %supportlogdir%\eventlog\Microsoft-Windows-iSCSITarget-Service-Admin.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-iSCSITarget-Service/Operational %supportlogdir%\eventlog\Microsoft-Windows-iSCSITarget-Service-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-iSCSITarget-VDSProvider/Admin %supportlogdir%\eventlog\Microsoft-Windows-iSCSITarget-VDSProvider-Admin.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-iSCSITarget-VDSProvider/Operational %supportlogdir%\eventlog\Microsoft-Windows-iSCSITarget-VDSProvider-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-iSCSITarget-VSSProvider/Admin %supportlogdir%\eventlog\Microsoft-Windows-iSCSITarget-VSSProvider-Admin.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-iSCSITarget-VSSProvider/Operational %supportlogdir%\eventlog\Microsoft-Windows-iSCSITarget-VSSProvider-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-Kernel-ApphelpCache/Operational %supportlogdir%\eventlog\Microsoft-Windows-Kernel-ApphelpCache-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-Kernel-Boot/Operational %supportlogdir%\eventlog\Microsoft-Windows-Kernel-Boot-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-Kernel-EventTracing/Admin %supportlogdir%\eventlog\Microsoft-Windows-Kernel-EventTracing-Admin.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-Kernel-IO/Operational %supportlogdir%\eventlog\Microsoft-Windows-Kernel-IO-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-Kernel-PnP/Configuration %supportlogdir%\eventlog\Microsoft-Windows-Kernel-PnP-Configuration.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-Kernel-Power/Thermal-Operational %supportlogdir%\eventlog\Microsoft-Windows-Kernel-Power-Thermal-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-Kernel-ShimEngine/Operational %supportlogdir%\eventlog\Microsoft-Windows-Kernel-ShimEngine-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-Kernel-StoreMgr/Operational %supportlogdir%\eventlog\Microsoft-Windows-Kernel-StoreMgr-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-Kernel-WDI/Operational %supportlogdir%\eventlog\Microsoft-Windows-Kernel-WDI-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-Kernel-WHEA/Errors %supportlogdir%\eventlog\Microsoft-Windows-Kernel-WHEA-Errors.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-Kernel-WHEA/Operational %supportlogdir%\eventlog\Microsoft-Windows-Kernel-WHEA-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-MemoryDiagnostics-Results/Debug %supportlogdir%\eventlog\Microsoft-Windows-MemoryDiagnostics-Results-Debug.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-MsLbfoProvider/Operational %supportlogdir%\eventlog\Microsoft-Windows-MsLbfoProvider-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-NdisImPlatform/Operational %supportlogdir%\eventlog\Microsoft-Windows-NdisImPlatform-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-NTLM/Operational %supportlogdir%\eventlog\Microsoft-Windows-NTLM-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-Ntfs/Operational %supportlogdir%\eventlog\Microsoft-Windows-Ntfs-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-Ntfs/WHC %supportlogdir%\eventlog\Microsoft-Windows-Ntfs-WHC.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-OfflineFiles/Operational %supportlogdir%\eventlog\Microsoft-Windows-OfflineFiles-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-OneBackup/Debug %supportlogdir%\eventlog\Microsoft-Windows-OneBackup-Debug.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-OOBE-Machine-DUI/Operational %supportlogdir%\eventlog\Microsoft-Windows-OOBE-Machine-DUI-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-Partition/Diagnostic %supportlogdir%\eventlog\Microsoft-Windows-Partition-Diagnostic.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-ReadyBoost/Operational %supportlogdir%\eventlog\Microsoft-Windows-ReadyBoost-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-ReFS/Operational %supportlogdir%\eventlog\Microsoft-Windows-ReFS-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-Regsvr32/Operational %supportlogdir%\eventlog\Microsoft-Windows-Regsvr32-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-SDDC-Management/Admin %supportlogdir%\eventlog\Microsoft-Windows-SDDC-Management-Admin.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-SDDC-Management/Operational %supportlogdir%\eventlog\Microsoft-Windows-SDDC-Management-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-Security-Netlogon/Operational %supportlogdir%\eventlog\Microsoft-Windows-Security-Netlogon-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-ServicesForNFS-Client/IdentityMapping %supportlogdir%\eventlog\Microsoft-Windows-ServicesForNFS-Client-IdentityMapping.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-ServicesForNFS-Client/Operational %supportlogdir%\eventlog\Microsoft-Windows-ServicesForNFS-Client-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-ServicesForNFS-Portmapper/Admin %supportlogdir%\eventlog\Microsoft-Windows-ServicesForNFS-Portmapper-Admin.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-ServicesForNFS-Server/Admin %supportlogdir%\eventlog\Microsoft-Windows-ServicesForNFS-Server-Admin.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-ServicesForNFS-Server/IdentityMapping %supportlogdir%\eventlog\Microsoft-Windows-ServicesForNFS-Server-IdentityMapping.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-ServicesForNFS-Server/Operational %supportlogdir%\eventlog\Microsoft-Windows-ServicesForNFS-Server-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-SmbClient/Connectivity %supportlogdir%\eventlog\Microsoft-Windows-SmbClient-Connectivity.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-SMBClient/Operational %supportlogdir%\eventlog\Microsoft-Windows-SMBClient-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-SmbClient/Security %supportlogdir%\eventlog\Microsoft-Windows-SmbClient-Security.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-SMBDirect/Admin %supportlogdir%\eventlog\Microsoft-Windows-SMBDirect-Admin.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-SMBServer/Audit %supportlogdir%\eventlog\Microsoft-Windows-SMBServer-Audit.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-SMBServer/Connectivity %supportlogdir%\eventlog\Microsoft-Windows-SMBServer-Connectivity.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-SMBServer/Operational %supportlogdir%\eventlog\Microsoft-Windows-SMBServer-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-SMBServer/Security %supportlogdir%\eventlog\Microsoft-Windows-SMBServer-Security.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-SMBWitnessClient/Admin %supportlogdir%\eventlog\Microsoft-Windows-SMBWitnessClient-Admin.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-SMBWitnessClient/Informational %supportlogdir%\eventlog\Microsoft-Windows-SMBWitnessClient-Informational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-SMBWitnessServer/Admin %supportlogdir%\eventlog\Microsoft-Windows-SMBWitnessServer-Admin.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-Storage-ClassPnP/Operational %supportlogdir%\eventlog\Microsoft-Windows-Storage-ClassPnP-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-StorageManagement/Operational %supportlogdir%\eventlog\Microsoft-Windows-StorageManagement-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-Storage-MultipathIoControlDriver/Operational %supportlogdir%\eventlog\Microsoft-Windows-Storage-MultipathIoControlDriver-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-StorageReplica/Admin %supportlogdir%\eventlog\Microsoft-Windows-StorageReplica-Admin.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-StorageReplica/Operational %supportlogdir%\eventlog\Microsoft-Windows-StorageReplica-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-StorageSpaces-Driver/Diagnostic %supportlogdir%\eventlog\Microsoft-Windows-StorageSpaces-Driver-Diagnostic.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-StorageSpaces-Driver/Operational %supportlogdir%\eventlog\Microsoft-Windows-StorageSpaces-Driver-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-StorageSpaces-ManagementAgent/WHC %supportlogdir%\eventlog\Microsoft-Windows-StorageSpaces-ManagementAgent-WHC.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-StorageSpaces-SpaceManager/Diagnostic %supportlogdir%\eventlog\Microsoft-Windows-StorageSpaces-SpaceManager-Diagnostic.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-StorageSpaces-SpaceManager/Operational %supportlogdir%\eventlog\Microsoft-Windows-StorageSpaces-SpaceManager-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-Storage-Storport/Operational %supportlogdir%\eventlog\Microsoft-Windows-Storage-Storport-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-Storage-Tiering/Admin %supportlogdir%\eventlog\Microsoft-Windows-Storage-Tiering-Admin.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-Store/Operational %supportlogdir%\eventlog\Microsoft-Windows-Store-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-TaskScheduler/Maintenance %supportlogdir%\eventlog\Microsoft-Windows-TaskScheduler-Maintenance.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-TaskScheduler/Operational %supportlogdir%\eventlog\Microsoft-Windows-TaskScheduler-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-TCPIP/Operational %supportlogdir%\eventlog\Microsoft-Windows-TCPIP-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-Volume/Diagnostic %supportlogdir%\eventlog\Microsoft-Windows-Volume-Diagnostic.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-VolumeSnapshot-Driver/Operational %supportlogdir%\eventlog\Microsoft-Windows-VolumeSnapshot-Driver-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-WMI-Activity/Operational %supportlogdir%\eventlog\Microsoft-Windows-WMI-Activity-Operational.evtx > NUL 2>&1
wevtutil epl Microsoft-Windows-WinRM/Operational %supportlogdir%\eventlog\Microsoft-Windows-WinRM-Operational.evtx > NUL 2>&1

wevtutil qe System /f:text > %supportlogdir%\eventlog\System.txt 2>&1
wevtutil qe Application /f:text > %supportlogdir%\eventlog\Application.txt 2>&1
wevtutil qe Setup /f:text > %supportlogdir%\eventlog\Setup.txt 2>&1
wevtutil qe Microsoft-Windows-Hyper-V-Compute-Admin /f:text > %supportlogdir%\eventlog\Microsoft-Windows-Hyper-V-Compute-Admin.txt 2>&1
wevtutil qe Microsoft-Windows-Hyper-V-Compute-Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-Hyper-V-Compute-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-Hyper-V-Guest-Drivers/Admin /f:text > %supportlogdir%\eventlog\Microsoft-Windows-Hyper-V-Guest-Drivers-Admin.txt 2>&1
wevtutil qe Microsoft-Windows-Hyper-V-Shared-VHDX/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-Hyper-V-Shared-VHDX-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-Hyper-V-Shared-VHDX/Reservation /f:text > %supportlogdir%\eventlog\Microsoft-Windows-Hyper-V-Shared-VHDX-Reservation.txt 2>&1
wevtutil qe Microsoft-Windows-Hyper-V-StorageVSP-Admin /f:text > %supportlogdir%\eventlog\Microsoft-Windows-Hyper-V-StorageVSP-Admin.txt 2>&1
wevtutil qe Microsoft-Windows-Hyper-V-VmSwitch-Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-Hyper-V-VmSwitch-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-Hyper-V-Config-Admin /f:text > %supportlogdir%\eventlog\Microsoft-Windows-Hyper-V-Config-Admin.txt 2>&1
wevtutil qe Microsoft-Windows-Hyper-V-Config-Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-Hyper-V-Config-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-Hyper-V-Hypervisor-Admin /f:text > %supportlogdir%\eventlog\Microsoft-Windows-Hyper-V-Hypervisor-Admin.txt 2>&1
wevtutil qe Microsoft-Windows-Hyper-V-Hypervisor-Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-Hyper-V-Hypervisor-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-Hyper-V-Integration-Admin /f:text > %supportlogdir%\eventlog\Microsoft-Windows-Hyper-V-Integration-Admin.txt 2>&1
wevtutil qe Microsoft-Windows-Hyper-V-SynthFc-Admin /f:text > %supportlogdir%\eventlog\Microsoft-Windows-Hyper-V-SynthFc-Admin.txt 2>&1
wevtutil qe Microsoft-Windows-Hyper-V-SynthNic-Admin /f:text > %supportlogdir%\eventlog\Microsoft-Windows-Hyper-V-SynthNic-Admin.txt 2>&1
wevtutil qe Microsoft-Windows-Hyper-V-SynthStor-Admin /f:text > %supportlogdir%\eventlog\Microsoft-Windows-Hyper-V-SynthStor-Admin.txt 2>&1
wevtutil qe Microsoft-Windows-Hyper-V-SynthStor-Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-Hyper-V-SynthStor-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-Hyper-V-VID-Admin /f:text > %supportlogdir%\eventlog\Microsoft-Windows-Hyper-V-VID-Admin.txt 2>&1
wevtutil qe Microsoft-Windows-Hyper-V-VMMS-Admin /f:text > %supportlogdir%\eventlog\Microsoft-Windows-Hyper-V-VMMS-Admin.txt 2>&1
wevtutil qe Microsoft-Windows-Hyper-V-VMMS-Networking /f:text > %supportlogdir%\eventlog\Microsoft-Windows-Hyper-V-VMMS-Networking.txt 2>&1
wevtutil qe Microsoft-Windows-Hyper-V-VMMS-Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-Hyper-V-VMMS-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-Hyper-V-VMMS-Storage /f:text > %supportlogdir%\eventlog\Microsoft-Windows-Hyper-V-VMMS-Storage.txt 2>&1
wevtutil qe Microsoft-Windows-Hyper-V-Worker-Admin /f:text > %supportlogdir%\eventlog\Microsoft-Windows-Hyper-V-Worker-Admin.txt 2>&1
wevtutil qe Microsoft-Windows-VHDMP/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-VHDMP-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-Hyper-V-High-Availability-Admin /f:text > %supportlogdir%\eventlog\Microsoft-Windows-Hyper-V-High-Availability-Admin.txt 2>&1
wevtutil qe Microsoft-Windows-FailoverClustering/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-FailoverClustering-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-FailoverClustering-Manager/Admin /f:text > %supportlogdir%\eventlog\Microsoft-Windows-FailoverClustering-Manager-Admin.txt 2>&1
wevtutil qe Microsoft-Windows-FailoverClustering-WMIProvider/Admin /f:text > %supportlogdir%\eventlog\Microsoft-Windows-FailoverClustering-WMIProvider-Admin.txt 2>&1
wevtutil qe Microsoft-Windows-Backup /f:text > %supportlogdir%\eventlog\Microsoft-Windows-Backup.txt 2>&1
wevtutil qe "Microsoft-Windows-BitLocker/BitLocker Management" /f:text > %supportlogdir%\eventlog\Microsoft-Windows-BitLocker-Management.txt 2>&1
wevtutil qe Microsoft-Windows-BitLocker-DrivePreparationTool/Admin /f:text > %supportlogdir%\eventlog\Microsoft-Windows-BitLocker-DrivePreparationTool-Admin.txt 2>&1
wevtutil qe Microsoft-Windows-BitLocker-DrivePreparationTool/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-BitLocker-DrivePreparationTool-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-ClusterAwareUpdating/Admin /f:text > %supportlogdir%\eventlog\Microsoft-Windows-ClusterAwareUpdating-Admin.txt 2>&1
wevtutil qe Microsoft-Windows-ClusterAwareUpdating-Management/Admin /f:text > %supportlogdir%\eventlog\Microsoft-Windows-ClusterAwareUpdating-Management-Admin.txt 2>&1
wevtutil qe Microsoft-Windows-Containers-Wcifs/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-Containers-Wcifs-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-Containers-Wcnfs/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-Containers-Wcnfs-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-DataIntegrityScan/Admin /f:text > %supportlogdir%\eventlog\Microsoft-Windows-DataIntegrityScan-Admin.txt 2>&1
wevtutil qe Microsoft-Windows-DataIntegrityScan/CrashRecovery /f:text > %supportlogdir%\eventlog\Microsoft-Windows-DataIntegrityScan-CrashRecovery.txt 2>&1
wevtutil qe Microsoft-Windows-Deduplication/Diagnostic /f:text > %supportlogdir%\eventlog\Microsoft-Windows-Deduplication-Diagnostic.txt 2>&1
wevtutil qe Microsoft-Windows-Deduplication/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-Deduplication-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-Deduplication/Scrubbing /f:text > %supportlogdir%\eventlog\Microsoft-Windows-Deduplication-Scrubbing.txt 2>&1
wevtutil qe Microsoft-Windows-DeviceGuard/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-DeviceGuard-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-DeviceSetupManager/Admin /f:text > %supportlogdir%\eventlog\Microsoft-Windows-DeviceSetupManager-Admin.txt 2>&1
wevtutil qe Microsoft-Windows-DeviceSetupManager/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-DeviceSetupManager-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-Diagnostics-Networking/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-Diagnostics-Networking-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-DiskDiagnostic/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-DiskDiagnostic-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-DiskDiagnosticDataCollector/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-DiskDiagnosticDataCollector-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-DiskDiagnosticResolver/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-DiskDiagnosticResolver-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-FailoverClustering/Diagnostic /f:text > %supportlogdir%\eventlog\Microsoft-Windows-FailoverClustering-Diagnostic.txt 2>&1
wevtutil qe Microsoft-Windows-FailoverClustering/DiagnosticVerbose /f:text > %supportlogdir%\eventlog\Microsoft-Windows-FailoverClustering-DiagnosticVerbose.txt 2>&1
wevtutil qe Microsoft-Windows-FailoverClustering-ClusBflt/Management /f:text > %supportlogdir%\eventlog\Microsoft-Windows-FailoverClustering-ClusBflt-Management.txt 2>&1
wevtutil qe Microsoft-Windows-FailoverClustering-ClusBflt/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-FailoverClustering-ClusBflt-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-FailoverClustering-Clusport/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-FailoverClustering-Clusport-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-FailoverClustering-CsvFs/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-FailoverClustering-CsvFs-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-FailoverClustering-NetFt/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-FailoverClustering-NetFt-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-Health/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-Health-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-HostGuardianService-Client/Admin /f:text > %supportlogdir%\eventlog\Microsoft-Windows-HostGuardianService-Client-Admin.txt 2>&1
wevtutil qe Microsoft-Windows-HostGuardianService-Client/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-HostGuardianService-Client-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-Host-Network-Service-Admin /f:text > %supportlogdir%\eventlog\Microsoft-Windows-Host-Network-Service-Admin.txt 2>&1
wevtutil qe Microsoft-Windows-Host-Network-Service-Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-Host-Network-Service-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-iSCSITarget-Service/Admin /f:text > %supportlogdir%\eventlog\Microsoft-Windows-iSCSITarget-Service-Admin.txt 2>&1
wevtutil qe Microsoft-Windows-iSCSITarget-Service/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-iSCSITarget-Service-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-iSCSITarget-VDSProvider/Admin /f:text > %supportlogdir%\eventlog\Microsoft-Windows-iSCSITarget-VDSProvider-Admin.txt 2>&1
wevtutil qe Microsoft-Windows-iSCSITarget-VDSProvider/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-iSCSITarget-VDSProvider-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-iSCSITarget-VSSProvider/Admin /f:text > %supportlogdir%\eventlog\Microsoft-Windows-iSCSITarget-VSSProvider-Admin.txt 2>&1
wevtutil qe Microsoft-Windows-iSCSITarget-VSSProvider/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-iSCSITarget-VSSProvider-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-Kernel-ApphelpCache/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-Kernel-ApphelpCache-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-Kernel-Boot/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-Kernel-Boot-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-Kernel-EventTracing/Admin /f:text > %supportlogdir%\eventlog\Microsoft-Windows-Kernel-EventTracing-Admin.txt 2>&1
wevtutil qe Microsoft-Windows-Kernel-IO/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-Kernel-IO-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-Kernel-PnP/Configuration /f:text > %supportlogdir%\eventlog\Microsoft-Windows-Kernel-PnP-Configuration.txt 2>&1
wevtutil qe Microsoft-Windows-Kernel-Power/Thermal-Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-Kernel-Power-Thermal-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-Kernel-ShimEngine/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-Kernel-ShimEngine-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-Kernel-StoreMgr/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-Kernel-StoreMgr-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-Kernel-WDI/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-Kernel-WDI-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-Kernel-WHEA/Errors /f:text > %supportlogdir%\eventlog\Microsoft-Windows-Kernel-WHEA-Errors.txt 2>&1
wevtutil qe Microsoft-Windows-Kernel-WHEA/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-Kernel-WHEA-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-MemoryDiagnostics-Results/Debug /f:text > %supportlogdir%\eventlog\Microsoft-Windows-MemoryDiagnostics-Results-Debug.txt 2>&1
wevtutil qe Microsoft-Windows-MsLbfoProvider/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-MsLbfoProvider-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-NdisImPlatform/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-NdisImPlatform-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-NTLM/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-NTLM-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-Ntfs/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-Ntfs-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-Ntfs/WHC /f:text > %supportlogdir%\eventlog\Microsoft-Windows-Ntfs-WHC.txt 2>&1
wevtutil qe Microsoft-Windows-OfflineFiles/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-OfflineFiles-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-OneBackup/Debug /f:text > %supportlogdir%\eventlog\Microsoft-Windows-OneBackup-Debug.txt 2>&1
wevtutil qe Microsoft-Windows-OOBE-Machine-DUI/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-OOBE-Machine-DUI-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-Partition/Diagnostic /f:text > %supportlogdir%\eventlog\Microsoft-Windows-Partition-Diagnostic.txt 2>&1
wevtutil qe Microsoft-Windows-ReadyBoost/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-ReadyBoost-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-ReFS/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-ReFS-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-Regsvr32/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-Regsvr32-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-SDDC-Management/Admin /f:text > %supportlogdir%\eventlog\Microsoft-Windows-SDDC-Management-Admin.txt 2>&1
wevtutil qe Microsoft-Windows-SDDC-Management/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-SDDC-Management-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-Security-Netlogon/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-Security-Netlogon-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-ServicesForNFS-Client/IdentityMapping /f:text > %supportlogdir%\eventlog\Microsoft-Windows-ServicesForNFS-Client-IdentityMapping.txt 2>&1
wevtutil qe Microsoft-Windows-ServicesForNFS-Client/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-ServicesForNFS-Client-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-ServicesForNFS-Portmapper/Admin /f:text > %supportlogdir%\eventlog\Microsoft-Windows-ServicesForNFS-Portmapper-Admin.txt 2>&1
wevtutil qe Microsoft-Windows-ServicesForNFS-Server/Admin /f:text > %supportlogdir%\eventlog\Microsoft-Windows-ServicesForNFS-Server-Admin.txt 2>&1
wevtutil qe Microsoft-Windows-ServicesForNFS-Server/IdentityMapping /f:text > %supportlogdir%\eventlog\Microsoft-Windows-ServicesForNFS-Server-IdentityMapping.txt 2>&1
wevtutil qe Microsoft-Windows-ServicesForNFS-Server/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-ServicesForNFS-Server-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-SmbClient/Connectivity /f:text > %supportlogdir%\eventlog\Microsoft-Windows-SmbClient-Connectivity.txt 2>&1
wevtutil qe Microsoft-Windows-SMBClient/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-SMBClient-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-SmbClient/Security /f:text > %supportlogdir%\eventlog\Microsoft-Windows-SmbClient-Security.txt 2>&1
wevtutil qe Microsoft-Windows-SMBDirect/Admin /f:text > %supportlogdir%\eventlog\Microsoft-Windows-SMBDirect-Admin.txt 2>&1
wevtutil qe Microsoft-Windows-SMBServer/Audit /f:text > %supportlogdir%\eventlog\Microsoft-Windows-SMBServer-Audit.txt 2>&1
wevtutil qe Microsoft-Windows-SMBServer/Connectivity /f:text > %supportlogdir%\eventlog\Microsoft-Windows-SMBServer-Connectivity.txt 2>&1
wevtutil qe Microsoft-Windows-SMBServer/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-SMBServer-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-SMBServer/Security /f:text > %supportlogdir%\eventlog\Microsoft-Windows-SMBServer-Security.txt 2>&1
wevtutil qe Microsoft-Windows-SMBWitnessClient/Admin /f:text > %supportlogdir%\eventlog\Microsoft-Windows-SMBWitnessClient-Admin.txt 2>&1
wevtutil qe Microsoft-Windows-SMBWitnessClient/Informational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-SMBWitnessClient-Informational.txt 2>&1
wevtutil qe Microsoft-Windows-SMBWitnessServer/Admin /f:text > %supportlogdir%\eventlog\Microsoft-Windows-SMBWitnessServer-Admin.txt 2>&1
wevtutil qe Microsoft-Windows-Storage-ClassPnP/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-Storage-ClassPnP-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-StorageManagement/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-StorageManagement-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-Storage-MultipathIoControlDriver/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-Storage-MultipathIoControlDriver-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-StorageReplica/Admin /f:text > %supportlogdir%\eventlog\Microsoft-Windows-StorageReplica-Admin.txt 2>&1
wevtutil qe Microsoft-Windows-StorageReplica/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-StorageReplica-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-StorageSpaces-Driver/Diagnostic /f:text > %supportlogdir%\eventlog\Microsoft-Windows-StorageSpaces-Driver-Diagnostic.txt 2>&1
wevtutil qe Microsoft-Windows-StorageSpaces-Driver/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-StorageSpaces-Driver-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-StorageSpaces-ManagementAgent/WHC /f:text > %supportlogdir%\eventlog\Microsoft-Windows-StorageSpaces-ManagementAgent-WHC.txt 2>&1
wevtutil qe Microsoft-Windows-StorageSpaces-SpaceManager/Diagnostic /f:text > %supportlogdir%\eventlog\Microsoft-Windows-StorageSpaces-SpaceManager-Diagnostic.txt 2>&1
wevtutil qe Microsoft-Windows-StorageSpaces-SpaceManager/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-StorageSpaces-SpaceManager-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-Storage-Storport/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-Storage-Storport-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-Storage-Tiering/Admin /f:text > %supportlogdir%\eventlog\Microsoft-Windows-Storage-Tiering-Admin.txt 2>&1
wevtutil qe Microsoft-Windows-Store/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-Store-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-TaskScheduler/Maintenance /f:text > %supportlogdir%\eventlog\Microsoft-Windows-TaskScheduler-Maintenance.txt 2>&1
wevtutil qe Microsoft-Windows-TaskScheduler/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-TaskScheduler-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-TCPIP/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-TCPIP-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-Volume/Diagnostic /f:text > %supportlogdir%\eventlog\Microsoft-Windows-Volume-Diagnostic.txt 2>&1
wevtutil qe Microsoft-Windows-VolumeSnapshot-Driver/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-VolumeSnapshot-Driver-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-WMI-Activity/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-WMI-Activity-Operational.txt 2>&1
wevtutil qe Microsoft-Windows-WinRM/Operational /f:text > %supportlogdir%\eventlog\Microsoft-Windows-WinRM-Operational.txt 2>&1
echo done.

set /p prompt=Copy TaskScheduler files ... <NUL
md %supportlogdir%\task > NUL 2>&1
schtasks /query /v /FO CSV > %supportlogdir%\task\tasklog.csv 2>&1
schtasks /query /v > %supportlogdir%\task\tasklog.txt 2>&1
Powershell "Get-ScheduledTask | select *" > %supportlogdir%\task\get-scheduledtask.log 2>&1
echo done.

set /p prompt=Copy Registry files ... <NUL
md %supportlogdir%\registry > NUL 2>&1
reg export HKLM\System\mounteddevices %supportlogdir%\registry\MountedDevices.reg > NUL 2>&1
reg save HKLM\System\mounteddevices %supportlogdir%\registry\MountedDevices.hiv > NUL 2>&1
reg export HKLM\SYSTEM\CurrentControlSet\Enum %supportlogdir%\registry\Enum.reg > NUL 2>&1
reg save HKLM\SYSTEM\CurrentControlSet\Enum %supportlogdir%\registry\Enum.hiv > NUL 2>&1
reg export HKLM\SYSTEM\CurrentControlSet\Services %supportlogdir%\registry\Services.reg > NUL 2>&1
reg save HKLM\SYSTEM\CurrentControlSet\Services %supportlogdir%\registry\Services.hiv > NUL 2>&1
reg export HKLM\HARDWARE\DEVICEMAP %supportlogdir%\registry\devicemap.reg > NUL 2>&1
reg save HKLM\HARDWARE\DEVICEMAP %supportlogdir%\registry\devicemap.hiv > NUL 2>&1
reg export HKLM\Software\Policies %supportlogdir%\registry\ComputerPolicies.reg > NUL 2>&1
reg save HKLM\Software\Policies %supportlogdir%\registry\ComputerPolicies.hiv > NUL 2>&1
reg export HKCU\Software\Policies %supportlogdir%\registry\UserPolicies.reg > NUL 2>&1
reg save HKCU\Software\Policies %supportlogdir%\registry\UserPolicies.hiv > NUL 2>&1
reg load HKLM\COMPONENTS C:\Windows\System32\config\components > NUL 2>&1
reg save HKLM\COMPONENTS %supportlogdir%\registry\COMPONENTS.hiv > NUL 2>&1
reg export HKLM\COMPONENTS %supportlogdir%\registry\COMPONENTS.reg > NUL 2>&1
reg save HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion %supportlogdir%\registry\Software.hiv > NUL 2>&1
reg save HKLM\SYSTEM\CurrentControlSet %supportlogdir%\registry\SYSTEM.hiv > NUL 2>&1
reg save "HKLM\SOFTWARE\Microsoft\Windows NT" %supportlogdir%\registry\WindowsNT.hiv > NUL 2>&1
reg save HKLM\SYSTEM\DriverDatabase %supportlogdir%\registry\DriverDatabase.hiv > NUL 2>&1
reg export "HKLM\SOFTWARE\Microsoft\NET Framework Setup" %supportlogdir%\registry\DataReport\NETFrameworkSetup.reg > NUL 2>&1
echo done.

set /p prompt=Start collecting drivers and modules info ... <NUL
md %supportlogdir%\drivers-and-modules > NUL 2>&1
driverquery /v > %supportlogdir%\drivers-and-modules\driverinfo.txt 2>&1
driverquery /fo csv /v > %supportlogdir%\drivers-and-modules\driverinfo.csv 2>&1
driverquery /si > %supportlogdir%\drivers-and-modules\driverinfo-si.txt 2>&1
.\libs\Checksym%PROCESSOR_ARCHITECTURE%.exe -F c:\Windows\System32 -R > %supportlogdir%\drivers-and-modules\system32Checksym.log 2>&1
.\libs\Checksym%PROCESSOR_ARCHITECTURE%.exe -F c:\Windows\System32\drivers -R > %supportlogdir%\drivers-and-modules\system32driversChecksym.log 2>&1
Powershell "Get-CimInstance -ClassName Win32_PnPSignedDriver | select *" > %supportlogdir%\drivers-and-modules\Win32_PnPSignedDriver.log 2>&1
echo done.

set /p prompt=Start network info ... <NUL
md %supportlogdir%\network > NUL 2>&1
netstat -ano > %supportlogdir%\network\netstat.txt 2>&1
ipconfig /all > %supportlogdir%\network\ipconfig-all.txt 2>&1
netsh advfirewall firewall show rule name=all > %supportlogdir%\network\advfirewall-rule-all.txt 2>&1
netsh advfirewall show allprofiles > %supportlogdir%\network\advfirewall-allprofiles.txt 2>&1
netsh advfirewall show global > %supportlogdir%\network\advfirewall-global.txt 2>&1
md %supportlogdir%\network\etc > NUL 2>&1
xcopy /s C:\Windows\System32\drivers\etc\* %supportlogdir%\network\etc > NUL 2>&1
powershell "Get-NetAdapter | select *" > %supportlogdir%\network\Get-NetAdapter.txt 2>&1
powershell "Get-NetAdapterAdvancedProperty | select *" > %supportlogdir%\network\Get-NetAdapterAdvancedProperty.txt 2>&1
powershell "Get-NetAdapterBinding | select *" > %supportlogdir%\network\Get-NetAdapterBinding.txt 2>&1
powershell "Get-NetAdapterChecksumOffload | select *" > %supportlogdir%\network\Get-NetAdapterChecksumOffload.txt 2>&1
powershell "Get-NetAdapterIPsecOffload | select *" > %supportlogdir%\network\Get-NetAdapterIPsecOffload.txt 2>&1
powershell "Get-NetAdapterLso | select *" > %supportlogdir%\network\Get-NetAdapterLso.txt 2>&1
powershell "Get-NetAdapterPacketDirect | select *" > %supportlogdir%\network\Get-NetAdapterPacketDirect.txt 2>&1
powershell "Get-NetAdapterRdma | select *" > %supportlogdir%\network\Get-NetAdapterRdma.txt 2>&1
powershell "Get-NetAdapterRsc | select *" > %supportlogdir%\network\Get-NetAdapterRsc.txt 2>&1
powershell "Get-NetIpAddress | select *" > %supportlogdir%\network\Get-NetIpAddress.txt 2>&1
powershell "Get-NetAdapterRss | select *" > %supportlogdir%\network\Get-NetAdapterRss.txt 2>&1
powershell "Get-NetIPv4Protocol | select *" > %supportlogdir%\network\Get-NetIPv4Protocol.txt 2>&1
powershell "Get-NetIPv6Protocol | select *" > %supportlogdir%\network\Get-NetIPv6Protocol.txt 2>&1
powershell "Get-NetLbfoTeam | select *" > %supportlogdir%\network\Get-NetLbfoTeam.txt 2>&1
powershell "Get-NetLbfoTeamMember | select *" > %supportlogdir%\network\Get-NetLbfoTeamMember.txt 2>&1
powershell "Get-NetLbfoTeamNic | select *" > %supportlogdir%\network\Get-NetLbfoTeamNic.txt 2>&1
powershell "Get-NetOffloadGlobalSetting | select *" > %supportlogdir%\network\Get-NetOffloadGlobalSetting.txt 2>&1
powershell "Get-NetPrefixPolicy | select *" > %supportlogdir%\network\Get-NetPrefixPolicy.txt 2>&1
powershell "Get-NetQosPolicy | select *" > %supportlogdir%\network\Get-NetQosPolicy.txt 2>&1
powershell "Get-NetRoute | select *" > %supportlogdir%\network\Get-NetRoute.txt 2>&1
powershell "Get-NetTcpConnection | select *" > %supportlogdir%\network\Get-NetTcpConnection.txt 2>&1
powershell "Get-NetTcpSetting | select *" > %supportlogdir%\network\Get-NetTcpSetting.txt 2>&1
powershell "Get-NetFirewallProfile | select *" > %supportlogdir%\network\Get-NetFirewallProfile.txt 2>&1
powershell "Get-NetFirewallRule | select *" > %supportlogdir%\network\Get-NetFirewallRule.txt 2>&1
powershell "Get-NetAdapterVMQ | select *" > %supportlogdir%\network\Get-NetAdapterVMQ.txt 2>&1
powershell "Get-NetAdapterVMQqueue | select *" > %supportlogdir%\network\Get-NetAdapterVMQqueue.txt 2>&1
echo done.

if EXIST C:\Windows\system32\srmsvc.dll (
set /p prompt=Start FSRM info ... <NUL
md %supportlogdir%\FSRM > NUL 2>&1
dirquota quota list > %supportlogdir%\FSRM\dirquota-quota-list.txt 2>&1
filescrn screen list > %supportlogdir%\FSRM\filescrn-screen-list.txt 2>&1
storrept reports list > %supportlogdir%\FSRM\storrept-reports-list.txt 2>&1
echo done.
)

if EXIST C:\Windows\system32\vmms.exe (
set /p prompt=Start Hyper-V info ... <NUL
md %supportlogdir%\hyper-v > NUL 2>&1
powershell.exe -executionpolicy remotesigned .\libs\HyperVBasicInfo.ps1 %supportlogdir%\hyper-v > NUL 2>&1
powershell.exe "Get-VM" > %supportlogdir%\hyper-v\Get-VM.txt 2>&1
powershell.exe "Get-VM | select *" > %supportlogdir%\hyper-v\Get-VM-all.txt 2>&1
powershell.exe "Get-VMHost | select *" > %supportlogdir%\hyper-v\Get-VMHost.txt 2>&1
powershell.exe "Get-VMHostNumaNode | select *" > %supportlogdir%\hyper-v\Get-VMHostNumaNode.txt 2>&1
powershell.exe "Get-VM | Get-VMIntegrationService | select *" > %supportlogdir%\hyper-v\Get-VMIntegrationService.txt 2>&1
powershell.exe "Get-VM | Get-VMNetworkAdapter | select *" > %supportlogdir%\hyper-v\Get-VMNetworkAdapter.txt 2>&1
powershell.exe "Get-VM | Get-VMNetworkAdapterVlan | select *" > %supportlogdir%\hyper-v\Get-VMNetworkAdapterVlan.txt 2>&1
powershell.exe "Get-VM | Get-VMprocessor | select *" > %supportlogdir%\hyper-v\Get-VMprocessor.txt 2>&1
powershell.exe "Get-VM | Get-VMSnapshot | select *" > %supportlogdir%\hyper-v\Get-VMSnapshot.txt 2>&1
powershell.exe "Get-VM | Get-VMSecurity | select *" > %supportlogdir%\hyper-v\Get-VMSecurity.txt 2>&1
powershell.exe "Get-VMSwitch | select *" > %supportlogdir%\hyper-v\Get-VMSwitch.txt 2>&1
echo done.
)

if EXIST C:\Windows\Cluster\clussvc.exe (
set /p prompt=Start Failover Cluster info ... <NUL
md %supportlogdir%\cluster > NUL 2>&1
Powershell "Get-Item c:\Windows\cluster\* | fl VersionInfo" > %supportlogdir%\cluster\clustermoduleinfo.log 2>&1
.\libs\Checksym%PROCESSOR_ARCHITECTURE%.exe -F c:\Windows\cluster -R > %supportlogdir%\cluster\clustermoduleChecksym.log 2>&1
REG EXPORT HKLM\Cluster %supportlogdir%\cluster\Cluster.reg > NUL 2>&1
REG SAVE HKLM\Cluster %supportlogdir%\cluster\Cluster.hiv > NUL 2>&1
powershell "Get-Cluster | select *" > %supportlogdir%\cluster\get-cluster.txt 2>&1
powershell Get-ClusterGroup > %supportlogdir%\cluster\get-clustergroup.txt 2>&1
powershell "Get-ClusterGroup | select *" > %supportlogdir%\cluster\get-clustergroup-all.txt 2>&1
powershell Get-ClusterResource > %supportlogdir%\cluster\get-clusterresource.txt 2>&1
powershell "Get-ClusterResource | select *" > %supportlogdir%\cluster\get-clusterresource-all.txt 2>&1
powershell "Get-ClusterResource | Get-ClusterParameter" > %supportlogdir%\cluster\get-clusterresource-with-parameter.txt 2>&1
powershell "Get-ClusterResource | Get-ClusterParameter | select *" > %supportlogdir%\cluster\get-clusterresource-with-parameter-all.txt 2>&1
powershell "Get-SMBShare | select *" > %supportlogdir%\cluster\get-smbshare-all.txt 2>&1
powershell "Get-SmbServerNetworkInterface | select *" > %supportlogdir%\cluster\get-smbservernetworkinterface.txt 2>&1
powershell "Get-StorageSubSystem Cluster* | Debug-StorageSubsystem | select *" > %supportlogdir%\cluster\debug-storagesubsystem.txt 2>&1
powershell "Get-StorageSubSystem Cluster* | Get-StorageHealthReport | select *"> %supportlogdir%\cluster\get-storagehealthreport.txt 2>&1
powershell "Get-CimInstance -Namespace root\wmi -ClassName ClusBfltDeviceInformation | select *" > %supportlogdir%\cluster\clusbflt-deviceinformation.txt 2>&1
powershell "Get-CimInstance -Namespace root\wmi -ClassName ClusPortDeviceInformation | select *" > %supportlogdir%\cluster\clusport-deviceinformation.txt 2>&1
powershell Get-ClusterNetwork > %supportlogdir%\cluster\get-clusternetwork.txt 2>&1
powershell "Get-ClusterNetwork | select *" > %supportlogdir%\cluster\get-clusternetwork-all.txt 2>&1
powershell Get-ClusterSharedVolume > %supportlogdir%\cluster\get-clustersharedvolume.txt 2>&1
powershell "Get-ClusterSharedVolume | select *" > %supportlogdir%\cluster\get-clustersharedvolume-all.txt 2>&1
powershell "Get-ClusterSharedVolume | select -Property Name -ExpandProperty SharedVolumeInfo" > %supportlogdir%\cluster\get-clustersharedvolume-sharedvolumeinfo.txt 2>&1
powershell "Get-ClusterSharedVolume | Get-ClusterParameter" > %supportlogdir%\cluster\get-clustersharedvolume-clusterparameter.txt 2>&1
powershell "Get-ClusterSharedVolume | Get-ClusterParameter | select *" > %supportlogdir%\cluster\get-clustersharedvolume-clusterparameter-all.txt 2>&1
cluster /prop > %supportlogdir%\cluster\cluster-prop.log 2>&1
cluster /priv > %supportlogdir%\cluster\cluster-priv.log 2>&1
cluster group > %supportlogdir%\cluster\cluster-group.log 2>&1
cluster group /prop > %supportlogdir%\cluster\cluster-group-prop.log 2>&1
cluster group /priv > %supportlogdir%\cluster\cluster-group-priv.log 2>&1
cluster res > %supportlogdir%\cluster\cluster-res.log 2>&1
cluster res /prop > %supportlogdir%\cluster\cluster-res-prop.log 2>&1
cluster res /priv > %supportlogdir%\cluster\cluster-res-priv.log 2>&1
cluster /quorum > %supportlogdir%\cluster\cluster-quorum.log 2>&1
cluster /listnetpri > %supportlogdir%\cluster\cluster-listnetpri.log 2>&1
cluster /share > %supportlogdir%\cluster\cluster-share.log 2>&1
cluster net > %supportlogdir%\cluster\cluster-net.log 2>&1
cluster net /prop > %supportlogdir%\cluster\cluster-net-prop.log 2>&1
cluster net /priv > %supportlogdir%\cluster\cluster-net-priv.log 2>&1
cluster netint > %supportlogdir%\cluster\cluster-netint.log 2>&1
cluster netint /prop > %supportlogdir%\cluster\cluster-netint-prop.log 2>&1
cluster netint /priv > %supportlogdir%\cluster\cluster-netint-priv.log 2>&1
powershell "Get-Clusterlog -Node localhost" > NUL 2>&1
powershell "Get-Clusterlog -Node localhost -Health" > NUL 2>&1
cluster log /g /node:"localhost" > NUL 2>&1
xcopy /s C:\Windows\Cluster\Reports\* %supportlogdir%\cluster > NUL 2>&1
echo done.
)

set /p prompt=Collecting System Information. <NUL
md %supportlogdir%\system > NUL 2>&1
set /p prompt=Start msinfo32 ... <NUL
msinfo32 /nfo %supportlogdir%\system\msinfo32.nfo > NUL 2>&1
echo done.

set /p prompt=Start systeminfo ... <NUL
systeminfo > %supportlogdir%\system\systeminfo.txt 2>&1
powershell "Get-WmiObject Win32_Product | select *" > %supportlogdir%\system\Win32_Product.txt 2>&1
echo done.

set /p prompt=Start verifierinfo ... <NUL
verifier /query > %supportlogdir%\system\verifier-query.txt 2>&1
verifier /querysettings > %supportlogdir%\system\verifier-querysettings.txt 2>&1
echo done.

set /p prompt=Start tasklist ... <NUL
tasklist > %supportlogdir%\system\tasklist.txt 2>&1
tasklist /M > %supportlogdir%\system\tasklist-M.txt 2>&1
tasklist /SVC > %supportlogdir%\system\tasklist-SVC.txt 2>&1
Powershell "Get-Process | Format-Table -Property "Handles","NPM","PM","WS","VM","CPU","Id","ProcessName","StartTime",@{ Label = 'Running Time';Expression={(GetAgeDescription -TimeSpan (new-TimeSpan $_.StartTime))}} -AutoSize" > %supportlogdir%\system\get-process.txt 2>&1
echo done.

set /p prompt=Start gpresult ... <NUL
gpresult /H %supportlogdir%\system\gpresult.html > NUL 2>&1
echo done.

echo Support log files are saved successfully at %basedir%.
ENDLOCAL
exit /b
