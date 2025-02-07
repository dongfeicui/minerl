@echo off
:: Test attempt to run Minecraft with commandline arguments.
:: Eg "launchClient -channel 2"
:: Currently must be run from within the mod dev folder.
:: Works by generating a Minecraft config file from the commandline arguments,
:: which the Mod then loads at initialisation time.

REM Command line parser due to dbenham - see here: http://stackoverflow.com/a/8162578

setlocal enableDelayedExpansion

:: Define the option names along with default values, using a <space>
:: delimiter between options.
:: Each option has the format -name:[default]
:: The option names are NOT case sensitive.
::
:: Options that have a default value expect the subsequent command line
:: argument to contain the value. If the option is not provided then the
:: option is set to the default. If the default contains spaces, contains
:: special characters, or starts with a colon, then it should be enclosed
:: within double quotes. The default can be undefined by specifying the
:: default as empty quotes "".
:: NOTE - defaults cannot contain * or ? with this solution.
::
:: Options that are specified without any default value are simply flags
:: that are either defined or undefined. All flags start out undefined by
:: default and become defined if the option is supplied.
::
:: The order of the definitions is not important.
::
set "options=-port:0 -replaceable: -scorepolicy:0 -env: -runDir:run  -performanceDir:NONE -seed:NONE -maxMem:4G"

:: Set the default option values
for %%O in (%options%) do for /f "tokens=1,* delims=:" %%A in ("%%O") do set "%%A=%%~B"

:loop
:: Validate and store the options, one at a time, using a loop.
:: Each SHIFT is done starting at the first option so required args are preserved.
::
if not "%~1"=="" (
  set "test=!options:*%~1:=! "
  if "!test!"=="!options! " (
    rem No substitution was made so this is an invalid option.
    rem Error handling goes here.
    rem I will simply echo an error message.
    echo Error: Invalid option %~1
  ) else if "!test:~0,1!"==" " (
    rem Set the flag option using the option name.
    rem The value doesn't matter, it just needs to be defined.
    set "%~1=true"
  ) else (
    rem Set the option value using the option as the name.
    rem and the next arg as the value
    set "%~1=%~2"
    shift /1
  )
  shift /1
  goto :loop
)

REM finally run Minecraft:
call java -Xmx"!-maxMem!" -jar build/libs/mcprec-6.13.jar --envPort="!-port!"
