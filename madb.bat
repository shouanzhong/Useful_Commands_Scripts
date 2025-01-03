REM 机器上连接多个手机时，使用adb时，免输入序列号
@echo off
setlocal enabledelayedexpansion

goto :main

:devices
echo List of devices attached
set i=1
for /f "skip=1 tokens=1,*" %%a in ('adb devices -l') do (
	if "%%a" NEQ "" (
		echo !i!    %%a %%b
		set device[!i!]=%%a
		set /a i+=1
	)
)
exit /b 

:help_menu
echo Usage:
echo     madb devices
echo     madb set ^<index^>
echo     madb clear
echo     madb -h ^| --help
exit /b

:quit_script
echo Exiting...
title 
goto :eof

:loop
set user_input=
set /p user_input=madb^>

if "!user_input!" == "" goto :loop
if "!user_input!" == "quit" goto :quit_script
if "!user_input!" == "exit" goto :quit_script

if exist "!user_input!" (
    echo %user_input% exist
    call "%user_input%"
) else if exist "!user_input!.bat" (
    echo %user_input%.bat exist
    call "%user_input%.bat"
) else (
    REM echo run cmd: "%user_input%"
    %user_input%
)
goto :loop


:main

:: Function to list devices with index
if "%1" == "devices" (
    call :devices
    goto :eof
) else if "%1" == "set" ( REM Function to bind device by index
    if "%2"=="" (
        echo Please provide a device index to bind.
        goto :eof
    )
	call :devices
    set selected_device=!device[%2]!

    :config_target
    if "!selected_device!"=="" (
        echo Invalid device index.
        goto :eof
    )
    set ANDROID_SERIAL=!selected_device!
    echo;
    echo set !selected_device! as default
    REM echo ANDROID_SERIAL=!ANDROID_SERIAL!
    title madb ^<--^> !selected_device!
    echo;
    
    echo Please enter a command to execute or type "[quit|exit]" to exit:
    echo;
    call :loop
    
    goto :eof
) else if "%1" == "clear" ( REM Function to clear bound device
    set ANDROID_SERIAL=
    echo clear binded device
    goto :eof
) else if "%1" equ "" (
    call :devices
    set selected_device=!device[1]!
    goto :config_target
) else if "%1" equ "-h" (
    call :help_menu
) else if "%1" equ "--help" (
    call :help_menu
) else (
    :: Default case if command not recognized
    echo Invalid command.
    call :help_menu
)

endlocal
