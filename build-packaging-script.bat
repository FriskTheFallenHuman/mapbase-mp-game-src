@echo off
REM # =====================================================================================================
REM #
REM # Mapbase Build Packaging Script by Blixibon
REM #
REM # This is a shell script I created a few years ago to make it easier for me to package Mapbase builds.
REM # I've tried to adapt it for more general use, but it may not be an ideal solution for everyone.
REM #
REM # To set up this script on your machine, you must have certain folders for the script to draw files from.
REM # For that, you can follow these steps:
REM #
REM #		1.	Gather the VMT (material) files from HL2, EP1, EP2, and Lost Coast. All of these can be found
REM #			in Source SDK Base 2013 Singleplayer if you do not have the relevant games installed.
REM #
REM #		2.	Use the Mapbase Multi-Tool to convert those materials to the new shaders. Send them to new
REM #			"VPKs\hl2_materials_source", "VPKs\episodic_materials_source", and "VPKs\lostcoast_materials_source"
REM #			folders in this repository. For episodic_materials_source, make sure the EP2 materials are converted
REM #			after the EP1 materials so that the former group overwrites the latter.
REM #
REM #		3.	Tweak the directory variables below.
REM #
REM # With all of that done, you should be ready to create basic Mapbase builds using this script, although there are
REM # a few manual steps involved which are not automated by default:
REM #
REM #		-	For the code binaries, you will need to download artifacts from GitHub and insert them into the
REM #			games' bin folders. (If you have a local copy, you can set USE_LOCAL_CODE below to true, but this
REM #			usually does not contain everything needed for a build)
REM #
REM #		-	You will need to include the legacy pre-v7.0 shared_content VPK in mapbase_shared. This can be
REM #			obtained from previously released builds.
REM #
REM # After generating a build, a to-do list showing any applicable manual steps will be given in the console.
REM #
REM # Once those manual steps are complete, you should have a fully functional Mapbase build.
REM #
REM # =====================================================================================================
setlocal ENABLEDELAYEDEXPANSION

rem Getting Steam path from registry
rem for /F "usebackq tokens=2*" %%I in (`reg query "HKCU\Software\Valve\Steam"^|find /I "SteamPath"`) do set steampath=%%J
for /f "usebackq tokens=1,2,*" %%i in (`reg query "HKCU\Software\Valve\Steam" /v "SteamPath"`) do set "steampath=%%~k"
rem Since this is loop, we cannot use ERRORLEVEL here
rem if not ERRORLEVEL 0 goto error

rem Replacing "/"'s with "\" in some cases
set steampath=%steampath:/=\%

rem Testing common paths
if not exist "%steampath%\steam.exe" (
	if not exist "%ProgramFiles(x86)%\steam.exe" (
		if not exist "%ProgramFiles%\steam.exe" (
			goto error
		) else (
			set steampath=%ProgramFiles%
		)
	) else set steampath=%ProgramFiles(x86)%
)

title Creating Mapbase Build

REM # =====================================================================================================

rem Where vpk.exe and its dependencies are on your computer
set BIN_DIR="%steampath%\steamapps\common\Source SDK Base 2013 Multiplayer\bin"

rem This repository's 'VPKs' folder (used by vpk.exe)
set VPK_CONTENT_DIR="VPKs"

rem Whether or not to use a local source code repository to automatically gather DLLs
set USE_LOCAL_CODE=true

rem USE_LOCAL_CODE only: Where the DLLs and SDK tools are
set SOURCE_BIN_DIR="..\mapbase-mp\mp\game\bin"
set SOURCE_MOD_EPISODIC_DIR="..\mapbase-mp\mp\game\mapbase_episodic"
set SOURCE_MOD_HL2_DIR="..\mapbase-mp\mp\game\mapbase_hl2"
set SOURCE_MOD_HL2MP_DIR="..\mapbase-mp\mp\game\mapbase_hl2mp"
set SOURCE_MOD_SCRATCH_DIR="..\mapbase-mp\mp\game\mapbase_scratch"

rem Where the original games' VCD files are (they come with the code repo by default)
set SOURCE_HL2_SCENES_DIR="scenesrc\hl2\scenes"
set SOURCE_LC_SCENES_DIR="scenesrc\lostcoast\scenes"
set SOURCE_EP1_SCENES_DIR="scenesrc\episodic\scenes"
set SOURCE_EP2_SCENES_DIR="scenesrc\ep2\scenes"

rem Where the FGDs are
set SOURCE_FGDS_DIR="fgds"

rem The default build directory where the build is going to be made
set BUILD_DIR_FOLDER="build_dir"

REM "read VERSION" could've been used for this, but it doesn't change as frequently as builds
REM are packaged, so it's only modified in the file and confirmed at runtime.
set VERSION=v7_2
set VERSION_VPK_NAME=v7_2

REM # =====================================================================================================

echo The currently selected version is "%VERSION%"
echo If this is correct, press enter to continue. If not, close this window and configure the version in the file.
pause

set /p Please enter a folder name to put the build into. :
set /p It will appear in the 'BUILDS' folder of this repository. :
if not "!Build_Dir!"=="" (
    set BUILD_DIR_FOLDER=!Build_Dir!
)

mkdir BUILDS
set BUILD_DIR=BUILDS\%BUILD_DIR_FOLDER%
mkdir %BUILD_DIR%

echo =====================
echo Copying loose folders
echo =====================

xcopy /E /I mapbase_episodic %BUILD_DIR%\mapbase_episodic
echo mapbase_episodic copied
xcopy /E /I mapbase_hl2 %BUILD_DIR%\mapbase_hl2
echo "mapbase_hl2 copied"
xcopy /E /I mapbase_hl2mp %BUILD_DIR%\mapbase_hl2mp
echo "mapbase_hl2mp copied"
xcopy /E /I mapbase_scratch %BUILD_DIR%\mapbase_scratch
echo "mapbase_scratch copied"

if "%USE_LOCAL_CODE%"=="true" (
    echo =====================
    echo Copying binaries from SDK bin
    echo =====================
    
    echo Validating bin folders...

    if not exist %BUILD_DIR%\mapbase_engine_bin mkdir %BUILD_DIR%\mapbase_engine_bin
    if not exist %BUILD_DIR%\mapbase_episodic\bin mkdir %BUILD_DIR%\mapbase_episodic\bin
    if not exist %BUILD_DIR%\mapbase_hl2\bin mkdir %BUILD_DIR%\mapbase_hl2\bin
    if not exist %BUILD_DIR%\mapbase_hl2mp\bin mkdir %BUILD_DIR%\mapbase_hl2mp\bin
    if not exist %BUILD_DIR%\mapbase_scratch\bin mkdir %BUILD_DIR%\mapbase_scratch\bin
    
    echo Copying binaries from mapbase-mp...
	
	echo [ ========== mapbase_episodic ================== ]
   
    if exist %SOURCE_MOD_EPISODIC_DIR%\bin\Release\client.dll xcopy /Y %SOURCE_MOD_EPISODIC_DIR%\bin\Release\client.dll %BUILD_DIR%\mapbase_episodic\bin
    if exist %SOURCE_MOD_EPISODIC_DIR%\bin\Release\server.dll xcopy /Y %SOURCE_MOD_EPISODIC_DIR%\bin\Release\server.dll %BUILD_DIR%\mapbase_episodic\bin
    if exist %SOURCE_MOD_EPISODIC_DIR%\bin\Release\game_shader_dx9.dll xcopy /Y %SOURCE_MOD_EPISODIC_DIR%\bin\Release\game_shader_dx9.dll %BUILD_DIR%\mapbase_episodic\bin
    if exist %SOURCE_MOD_EPISODIC_DIR%\bin\Release\vaudio_miles.dll xcopy /Y %SOURCE_MOD_EPISODIC_DIR%\bin\Release\vaudio_miles.dll %BUILD_DIR%\mapbase_episodic\bin

    if exist %SOURCE_MOD_EPISODIC_DIR%\bin\brotlicommon.dll xcopy /Y %SOURCE_MOD_EPISODIC_DIR%\bin\brotlicommon.dll %BUILD_DIR%\mapbase_episodic\bin
    if exist %SOURCE_MOD_EPISODIC_DIR%\bin\brotlidec.dll xcopy /Y %SOURCE_MOD_EPISODIC_DIR%\bin\brotlidec.dll %BUILD_DIR%\mapbase_episodic\bin
    if exist %SOURCE_MOD_EPISODIC_DIR%\bin\brotlienc.dll xcopy /Y %SOURCE_MOD_EPISODIC_DIR%\bin\brotlienc.dll %BUILD_DIR%\mapbase_episodic\bin
    if exist %SOURCE_MOD_EPISODIC_DIR%\bin\crashpad_handler.exe xcopy /Y %SOURCE_MOD_EPISODIC_DIR%\bin\crashpad_handler.exe %BUILD_DIR%\mapbase_episodic\bin
    if exist %SOURCE_MOD_EPISODIC_DIR%\bin\crashpad_wer.dll xcopy /Y %SOURCE_MOD_EPISODIC_DIR%\bin\crashpad_wer.dll %BUILD_DIR%\mapbase_episodic\bin
    if exist %SOURCE_MOD_EPISODIC_DIR%\bin\curl.exe xcopy /Y %SOURCE_MOD_EPISODIC_DIR%\bin\curl.exe %BUILD_DIR%\mapbase_episodic\bin
    if exist %SOURCE_MOD_EPISODIC_DIR%\bin\curl-ca-bundle.crt xcopy /Y %SOURCE_MOD_EPISODIC_DIR%\bin\curl-ca-bundle.crt %BUILD_DIR%\mapbase_episodic\bin
    if exist %SOURCE_MOD_EPISODIC_DIR%\bin\fmt.dll xcopy /Y %SOURCE_MOD_EPISODIC_DIR%\bin\fmt.dll %BUILD_DIR%\mapbase_episodic\bin
    if exist %SOURCE_MOD_EPISODIC_DIR%\bin\legacy.dll xcopy /Y %SOURCE_MOD_EPISODIC_DIR%\bin\legacy.dll %BUILD_DIR%\mapbase_episodic\bin
    if exist %SOURCE_MOD_EPISODIC_DIR%\bin\libcrypto-3.dll xcopy /Y %SOURCE_MOD_EPISODIC_DIR%\bin\libcrypto-3.dll %BUILD_DIR%\mapbase_episodic\bin
    if exist %SOURCE_MOD_EPISODIC_DIR%\bin\libssh2.dll xcopy /Y %SOURCE_MOD_EPISODIC_DIR%\bin\libssh2.dll %BUILD_DIR%\mapbase_episodic\bin
    if exist %SOURCE_MOD_EPISODIC_DIR%\bin\libssl-3.dll xcopy /Y %SOURCE_MOD_EPISODIC_DIR%\bin\libssl-3.dll %BUILD_DIR%\mapbase_episodic\bin
    if exist %SOURCE_MOD_EPISODIC_DIR%\bin\nghttp2.dll xcopy /Y %SOURCE_MOD_EPISODIC_DIR%\bin\nghttp2.dll %BUILD_DIR%\mapbase_episodic\bin
    if exist %SOURCE_MOD_EPISODIC_DIR%\bin\sentry.dll xcopy /Y %SOURCE_MOD_EPISODIC_DIR%\bin\sentry.dll %BUILD_DIR%\mapbase_episodic\bin
    if exist %SOURCE_MOD_EPISODIC_DIR%\bin\zlib1.dll xcopy /Y %SOURCE_MOD_EPISODIC_DIR%\bin\zlib1.dll %BUILD_DIR%\mapbase_episodic\bin

	echo [ ========== mapbase_hl2 ================== ]
    
    if exist %SOURCE_MOD_HL2_DIR%\bin\Release\client.dll xcopy /Y %SOURCE_MOD_HL2_DIR%\bin\Release\client.dll %BUILD_DIR%\mapbase_hl2\bin
    if exist %SOURCE_MOD_HL2_DIR%\bin\Release\server.dll xcopy /Y %SOURCE_MOD_HL2_DIR%\bin\Release\server.dll %BUILD_DIR%\mapbase_hl2\bin
    if exist %SOURCE_MOD_HL2_DIR%\bin\Release\game_shader_dx9.dll xcopy /Y %SOURCE_MOD_HL2_DIR%\bin\Release\game_shader_dx9.dll %BUILD_DIR%\mapbase_hl2\bin
    if exist %SOURCE_MOD_HL2_DIR%\bin\Release\vaudio_miles.dll xcopy /Y %SOURCE_MOD_HL2_DIR%\bin\Release\vaudio_miles.dll %BUILD_DIR%\mapbase_hl2\bin
	
    if exist %SOURCE_MOD_HL2_DIR%\bin\brotlicommon.dll xcopy /Y %SOURCE_MOD_HL2_DIR%\bin\brotlicommon.dll %BUILD_DIR%\mapbase_hl2\bin
    if exist %SOURCE_MOD_HL2_DIR%\bin\brotlidec.dll xcopy /Y %SOURCE_MOD_HL2_DIR%\bin\brotlidec.dll %BUILD_DIR%\mapbase_hl2\bin
    if exist %SOURCE_MOD_HL2_DIR%\bin\brotlienc.dll xcopy /Y %SOURCE_MOD_HL2_DIR%\bin\brotlienc.dll %BUILD_DIR%\mapbase_hl2\bin
    if exist %SOURCE_MOD_HL2_DIR%\bin\crashpad_handler.exe xcopy /Y %SOURCE_MOD_HL2_DIR%\bin\crashpad_handler.exe %BUILD_DIR%\mapbase_hl2\bin
    if exist %SOURCE_MOD_HL2_DIR%\bin\crashpad_wer.dll xcopy /Y %SOURCE_MOD_HL2_DIR%\bin\crashpad_wer.dll %BUILD_DIR%\mapbase_hl2\bin
    if exist %SOURCE_MOD_HL2_DIR%\bin\curl.exe xcopy /Y %SOURCE_MOD_HL2_DIR%\bin\curl.exe %BUILD_DIR%\mapbase_hl2\bin
    if exist %SOURCE_MOD_HL2_DIR%\bin\curl-ca-bundle.crt xcopy /Y %SOURCE_MOD_HL2_DIR%\bin\curl-ca-bundle.crt %BUILD_DIR%\mapbase_hl2\bin
    if exist %SOURCE_MOD_HL2_DIR%\bin\fmt.dll xcopy /Y %SOURCE_MOD_HL2_DIR%\bin\fmt.dll %BUILD_DIR%\mapbase_hl2\bin
    if exist %SOURCE_MOD_HL2_DIR%\bin\legacy.dll xcopy /Y %SOURCE_MOD_HL2_DIR%\bin\legacy.dll %BUILD_DIR%\mapbase_hl2\bin
    if exist %SOURCE_MOD_HL2_DIR%\bin\libcrypto-3.dll xcopy /Y %SOURCE_MOD_HL2_DIR%\bin\libcrypto-3.dll %BUILD_DIR%\mapbase_hl2\bin
    if exist %SOURCE_MOD_HL2_DIR%\bin\libssh2.dll xcopy /Y %SOURCE_MOD_HL2_DIR%\bin\libssh2.dll %BUILD_DIR%\mapbase_hl2\bin
    if exist %SOURCE_MOD_HL2_DIR%\bin\libssl-3.dll xcopy /Y %SOURCE_MOD_HL2_DIR%\bin\libssl-3.dll %BUILD_DIR%\mapbase_hl2\bin
    if exist %SOURCE_MOD_HL2_DIR%\bin\nghttp2.dll xcopy /Y %SOURCE_MOD_HL2_DIR%\bin\nghttp2.dll %BUILD_DIR%\mapbase_hl2\bin
    if exist %SOURCE_MOD_HL2_DIR%\bin\sentry.dll xcopy /Y %SOURCE_MOD_HL2_DIR%\bin\sentry.dll %BUILD_DIR%\mapbase_hl2\bin
    if exist %SOURCE_MOD_HL2_DIR%\bin\zlib1.dll xcopy /Y %SOURCE_MOD_HL2_DIR%\bin\zlib1.dll %BUILD_DIR%\mapbase_hl2\bin
	
	echo [ ========== mapbase_hl2mp ================== ]
	
    if exist %SOURCE_MOD_HL2MP_DIR%\bin\Release\client.dll xcopy /Y %SOURCE_MOD_HL2MP_DIR%\bin\Release\client.dll %BUILD_DIR%\mapbase_hl2mp\bin
    if exist %SOURCE_MOD_HL2MP_DIR%\bin\Release\server.dll xcopy /Y %SOURCE_MOD_HL2MP_DIR%\bin\Release\server.dll %BUILD_DIR%\mapbase_hl2mp\bin
    if exist %SOURCE_MOD_HL2MP_DIR%\bin\Release\game_shader_dx9.dll xcopy /Y %SOURCE_MOD_HL2MP_DIR%\bin\Release\game_shader_dx9.dll %BUILD_DIR%\mapbase_hl2mp\bin
    if exist %SOURCE_MOD_HL2MP_DIR%\bin\Release\vaudio_miles.dll xcopy /Y %SOURCE_MOD_HL2MP_DIR%\bin\Release\vaudio_miles.dll %BUILD_DIR%\mapbase_hl2mp\bin
	
    if exist %SOURCE_MOD_HL2MP_DIR%\bin\brotlicommon.dll xcopy /Y %SOURCE_MOD_HL2MP_DIR%\bin\brotlicommon.dll %BUILD_DIR%\mapbase_hl2mp\bin
    if exist %SOURCE_MOD_HL2MP_DIR%\bin\brotlidec.dll xcopy /Y %SOURCE_MOD_HL2MP_DIR%\bin\brotlidec.dll %BUILD_DIR%\mapbase_hl2mp\bin
    if exist %SOURCE_MOD_HL2MP_DIR%\bin\brotlienc.dll xcopy /Y %SOURCE_MOD_HL2MP_DIR%\bin\brotlienc.dll %BUILD_DIR%\mapbase_hl2mp\bin
    if exist %SOURCE_MOD_HL2MP_DIR%\bin\crashpad_handler.exe xcopy /Y %SOURCE_MOD_HL2MP_DIR%\bin\crashpad_handler.exe %BUILD_DIR%\mapbase_hl2mp\bin
    if exist %SOURCE_MOD_HL2MP_DIR%\bin\crashpad_wer.dll xcopy /Y %SOURCE_MOD_HL2MP_DIR%\bin\crashpad_wer.dll %BUILD_DIR%\mapbase_hl2mp\bin
    if exist %SOURCE_MOD_HL2MP_DIR%\bin\curl.exe xcopy /Y %SOURCE_MOD_HL2MP_DIR%\bin\curl.exe %BUILD_DIR%\mapbase_hl2mp\bin
    if exist %SOURCE_MOD_HL2MP_DIR%\bin\curl-ca-bundle.crt xcopy /Y %SOURCE_MOD_HL2MP_DIR%\bin\curl-ca-bundle.crt %BUILD_DIR%\mapbase_hl2mp\bin
    if exist %SOURCE_MOD_HL2MP_DIR%\bin\fmt.dll xcopy /Y %SOURCE_MOD_HL2MP_DIR%\bin\fmt.dll %BUILD_DIR%\mapbase_hl2mp\bin
    if exist %SOURCE_MOD_HL2MP_DIR%\bin\legacy.dll xcopy /Y %SOURCE_MOD_HL2MP_DIR%\bin\legacy.dll %BUILD_DIR%\mapbase_hl2mp\bin
    if exist %SOURCE_MOD_HL2MP_DIR%\bin\libcrypto-3.dll xcopy /Y %SOURCE_MOD_HL2MP_DIR%\bin\libcrypto-3.dll %BUILD_DIR%\mapbase_hl2mp\bin
    if exist %SOURCE_MOD_HL2MP_DIR%\bin\libssh2.dll xcopy /Y %SOURCE_MOD_HL2MP_DIR%\bin\libssh2.dll %BUILD_DIR%\mapbase_hl2mp\bin
    if exist %SOURCE_MOD_HL2MP_DIR%\bin\libssl-3.dll xcopy /Y %SOURCE_MOD_HL2MP_DIR%\bin\libssl-3.dll %BUILD_DIR%\mapbase_hl2mp\bin
    if exist %SOURCE_MOD_HL2MP_DIR%\bin\nghttp2.dll xcopy /Y %SOURCE_MOD_HL2MP_DIR%\bin\nghttp2.dll %BUILD_DIR%\mapbase_hl2mp\bin
    if exist %SOURCE_MOD_HL2MP_DIR%\bin\sentry.dll xcopy /Y %SOURCE_MOD_HL2MP_DIR%\bin\sentry.dll %BUILD_DIR%\mapbase_hl2mp\bin
    if exist %SOURCE_MOD_HL2MP_DIR%\bin\zlib1.dll xcopy /Y %SOURCE_MOD_HL2MP_DIR%\bin\zlib1.dll %BUILD_DIR%\mapbase_hl2mp\bin

	echo [ ========== mapbase_scratch ================== ]
	
    if exist %SOURCE_MOD_SCRATCH_DIR%\bin\Release\client.dll xcopy /Y %SOURCE_MOD_SCRATCH_DIR%\bin\Release\client.dll %BUILD_DIR%\mapbase_scratch\bin
    if exist %SOURCE_MOD_SCRATCH_DIR%\bin\Release\server.dll xcopy /Y %SOURCE_MOD_SCRATCH_DIR%\bin\Release\server.dll %BUILD_DIR%\mapbase_scratch\bin
    if exist %SOURCE_MOD_SCRATCH_DIR%\bin\Release\game_shader_dx9.dll xcopy /Y %SOURCE_MOD_SCRATCH_DIR%\bin\Release\game_shader_dx9.dll %BUILD_DIR%\mapbase_scratch\bin
    if exist %SOURCE_MOD_SCRATCH_DIR%\bin\Release\vaudio_miles.dll xcopy /Y %SOURCE_MOD_SCRATCH_DIR%\bin\Release\vaudio_miles.dll %BUILD_DIR%\mapbase_scratch\bin
	
    if exist %SOURCE_MOD_SCRATCH_DIR%\bin\brotlicommon.dll xcopy /Y %SOURCE_MOD_SCRATCH_DIR%\bin\brotlicommon.dll %BUILD_DIR%\mapbase_scratch\bin
    if exist %SOURCE_MOD_SCRATCH_DIR%\bin\brotlidec.dll xcopy /Y %SOURCE_MOD_SCRATCH_DIR%\bin\brotlidec.dll %BUILD_DIR%\mapbase_scratch\bin
    if exist %SOURCE_MOD_SCRATCH_DIR%\bin\brotlienc.dll xcopy /Y %SOURCE_MOD_SCRATCH_DIR%\bin\brotlienc.dll %BUILD_DIR%\mapbase_scratch\bin
    if exist %SOURCE_MOD_SCRATCH_DIR%\bin\crashpad_handler.exe xcopy /Y %SOURCE_MOD_SCRATCH_DIR%\bin\crashpad_handler.exe %BUILD_DIR%\mapbase_scratch\bin
    if exist %SOURCE_MOD_SCRATCH_DIR%\bin\crashpad_wer.dll xcopy /Y %SOURCE_MOD_SCRATCH_DIR%\bin\crashpad_wer.dll %BUILD_DIR%\mapbase_scratch\bin
    if exist %SOURCE_MOD_SCRATCH_DIR%\bin\curl.exe xcopy /Y %SOURCE_MOD_SCRATCH_DIR%\bin\curl.exe %BUILD_DIR%\mapbase_scratch\bin
    if exist %SOURCE_MOD_SCRATCH_DIR%\bin\curl-ca-bundle.crt xcopy /Y %SOURCE_MOD_SCRATCH_DIR%\bin\curl-ca-bundle.crt %BUILD_DIR%\mapbase_scratch\bin
    if exist %SOURCE_MOD_SCRATCH_DIR%\bin\fmt.dll xcopy /Y %SOURCE_MOD_SCRATCH_DIR%\bin\fmt.dll %BUILD_DIR%\mapbase_scratch\bin
    if exist %SOURCE_MOD_SCRATCH_DIR%\bin\legacy.dll xcopy /Y %SOURCE_MOD_SCRATCH_DIR%\bin\legacy.dll %BUILD_DIR%\mapbase_scratch\bin
    if exist %SOURCE_MOD_SCRATCH_DIR%\bin\libcrypto-3.dll xcopy /Y %SOURCE_MOD_SCRATCH_DIR%\bin\libcrypto-3.dll %BUILD_DIR%\mapbase_scratch\bin
    if exist %SOURCE_MOD_SCRATCH_DIR%\bin\libssh2.dll xcopy /Y %SOURCE_MOD_SCRATCH_DIR%\bin\libssh2.dll %BUILD_DIR%\mapbase_scratch\bin
    if exist %SOURCE_MOD_SCRATCH_DIR%\bin\libssl-3.dll xcopy /Y %SOURCE_MOD_SCRATCH_DIR%\bin\libssl-3.dll %BUILD_DIR%\mapbase_scratch\bin
    if exist %SOURCE_MOD_SCRATCH_DIR%\bin\nghttp2.dll xcopy /Y %SOURCE_MOD_SCRATCH_DIR%\bin\nghttp2.dll %BUILD_DIR%\mapbase_scratch\bin
    if exist %SOURCE_MOD_SCRATCH_DIR%\bin\sentry.dll xcopy /Y %SOURCE_MOD_SCRATCH_DIR%\bin\sentry.dll %BUILD_DIR%\mapbase_scratch\bin
    if exist %SOURCE_MOD_SCRATCH_DIR%\bin\zlib1.dll xcopy /Y %SOURCE_MOD_SCRATCH_DIR%\bin\zlib1.dll %BUILD_DIR%\mapbase_scratch\bin

    echo =====================
    echo Copying compile tools from SDK bin
    echo =====================
    

    xcopy /Y %SOURCE_BIN_DIR%\Release\vbsp.exe %BUILD_DIR%\mapbase_engine_bin
    xcopy /Y %SOURCE_BIN_DIR%\Release\vrad_launcher.exe %BUILD_DIR%\mapbase_engine_bin
    xcopy /Y %SOURCE_BIN_DIR%\Release\vrad_dll.dll %BUILD_DIR%\mapbase_engine_bin
    xcopy /Y %SOURCE_BIN_DIR%\Release\vvis_launcher.exe %BUILD_DIR%\mapbase_engine_bin
    xcopy /Y %SOURCE_BIN_DIR%\Release\vvis_dll.dll %BUILD_DIR%\mapbase_engine_bin
)

echo =====================
echo Copying materials
echo =====================

xcopy /E /I VPKs\hl2_materials_source VPKs\hl2_materials
echo hl2_materials_source copied.
xcopy /E /I VPKs\hl2_materials_overrides VPKs\hl2_materials
echo hl2_materials_overrides copied.

xcopy /E /I VPKs\ep2_materials_source VPKs\ep2_materials
echo ep2_materials_source copied.
REM TODO
REM xcopy /E /I VPKs\ep2_materials_overrides VPKs\ep2_materials
REM echo ep2_materials_overrides copied.

xcopy /E /I VPKs\episodic_materials_source VPKs\episodic_materials
echo episodic_materials_source copied.
xcopy /E /I VPKs\episodic_materials_overrides VPKs\episodic_materials
echo episodic_materials_overrides copied.

xcopy /E /I VPKs\lostcoast_materials_source VPKs\lostcoast_materials
echo lostcoast_materials_source copied.
xcopy /E /I VPKs\lostcoast_materials_overrides VPKs\lostcoast_materials
echo lostcoast_materials_overrides copied.

echo =====================
echo Copying scenes
echo =====================

mkdir VPKs\hl2_scenes
mkdir VPKs\lostcoast_scenes
mkdir VPKs\episodic_scenes
mkdir VPKs\ep2_scenes

xcopy /E /I %SOURCE_HL2_SCENES_DIR% VPKs\hl2_scenes
echo HL2 scenes copied
xcopy /E /I %SOURCE_EP1_SCENES_DIR% VPKs\episodic_scenes
echo EP1 scenes copied
xcopy /E /I %SOURCE_LC_SCENES_DIR% VPKs\lostcoast_scenes
echo LC scenes copied
xcopy /E /I %SOURCE_EP2_SCENES_DIR% VPKs\ep2_scenes
echo EP2 scenes copied

echo =====================
echo Packing VPKs
echo =====================

mkdir %BUILD_DIR%\base_content
mkdir %BUILD_DIR%\mapbase_episodic\content
mkdir %BUILD_DIR%\mapbase_hl2\content
mkdir %BUILD_DIR%\mapbase_hl2mp\content
mkdir %BUILD_DIR%\mapbase_scratch\content

echo Generating keypair for %VERSION%

%BIN_DIR%\vpk.exe generate_keypair "mapbase_mp_%VERSION%"

REM [===========] base_content [===============]

%BIN_DIR%\vpk.exe -M -P -c 50 -k mapbase_mp_%VERSION%.publickey.vdf -K mapbase_mp_%VERSION%.privatekey.vdf -vpk "%VPK_CONTENT_DIR%\base_content"
%BIN_DIR%\vpk.exe rehash "%VPK_CONTENT_DIR%\base_content"
echo Moving base_content
move VPKs\*.vpk %BUILD_DIR%\base_content

REM [===========] hl2_mapbase_content [===============]

%BIN_DIR%\vpk.exe -M -P -c 50 -k mapbase_mp_%VERSION%.publickey.vdf -K mapbase_mp_%VERSION%.privatekey.vdf -vpk "%VPK_CONTENT_DIR%\hl2_mapbase_content"
%BIN_DIR%\vpk.exe rehash "%VPK_CONTENT_DIR%\hl2_mapbase_content"
echo Moving hl2_mapbase_content
move VPKs\*.vpk %BUILD_DIR%\mapbase_hl2\content

REM [===========] hl2_mapbase_unused_content [===============]

%BIN_DIR%\vpk.exe -M -P -c 50 -k mapbase_mp_%VERSION%.publickey.vdf -K mapbase_mp_%VERSION%.privatekey.vdf -vpk "%VPK_CONTENT_DIR%\hl2_mapbase_unused_content"
%BIN_DIR%\vpk.exe rehash "%VPK_CONTENT_DIR%\hl2_mapbase_unused_content"
echo Moving hl2_mapbase_unused_content
move VPKs\*.vpk %BUILD_DIR%\mapbase_hl2\content

REM [===========] hl2_materials [===============]

%BIN_DIR%\vpk.exe -M -P -c 50 -k mapbase_mp_%VERSION%.publickey.vdf -K mapbase_mp_%VERSION%.privatekey.vdf -vpk "%VPK_CONTENT_DIR%\hl2_materials"
%BIN_DIR%\vpk.exe rehash "%VPK_CONTENT_DIR%\hl2_materials"
echo Moving hl2_materials
move VPKs\*.vpk %BUILD_DIR%\mapbase_hl2\content

REM [===========] hl2mp_mapbase_content [===============]

%BIN_DIR%\vpk.exe -M -P -c 50 -k mapbase_mp_%VERSION%.publickey.vdf -K mapbase_mp_%VERSION%.privatekey.vdf -vpk "%VPK_CONTENT_DIR%\hl2mp_mapbase_content"
%BIN_DIR%\vpk.exe rehash "%VPK_CONTENT_DIR%\hl2mp_mapbase_content"
echo Moving hl2mp_mapbase_content
move VPKs\*.vpk %BUILD_DIR%\mapbase_hl2mp\content

REM [===========] lostcoast_materials [===============]

%BIN_DIR%\vpk.exe -M -P -c 50 -k mapbase_mp_%VERSION%.publickey.vdf -K mapbase_mp_%VERSION%.privatekey.vdf -vpk "%VPK_CONTENT_DIR%\lostcoast_materials"
%BIN_DIR%\vpk.exe rehash "%VPK_CONTENT_DIR%\lostcoast_materials"
echo Moving lostcoast_materials
move VPKs\*.vpk %BUILD_DIR%\mapbase_hl2\content

REM [===========] episodic_mapbase_content [===============]

%BIN_DIR%\vpk.exe -M -P -c 50 -k mapbase_mp_%VERSION%.publickey.vdf -K mapbase_mp_%VERSION%.privatekey.vdf -vpk "%VPK_CONTENT_DIR%\episodic_mapbase_content"
%BIN_DIR%\vpk.exe rehash "%VPK_CONTENT_DIR%\episodic_mapbase_content"
echo Moving episodic_mapbase_content
move VPKs\*.vpk %BUILD_DIR%\mapbase_episodic\content

REM [===========] episodic_materials [===============]

%BIN_DIR%\vpk.exe -M -P -c 50 -k mapbase_mp_%VERSION%.publickey.vdf -K mapbase_mp_%VERSION%.privatekey.vdf -vpk "%VPK_CONTENT_DIR%\episodic_materials"
%BIN_DIR%\vpk.exe rehash "%VPK_CONTENT_DIR%\episodic_materials"
echo Moving episodic_materials
move VPKs\*.vpk %BUILD_DIR%\mapbase_episodic\content

REM [===========] ep2_materials [===============]

%BIN_DIR%\vpk.exe -M -P -c 50 -k mapbase_mp_%VERSION%.publickey.vdf -K mapbase_mp_%VERSION%.privatekey.vdf -vpk "%VPK_CONTENT_DIR%\ep2_materials"
%BIN_DIR%\vpk.exe rehash "%VPK_CONTENT_DIR%\ep2_materials"
echo Moving ep2_materials
move VPKs\*.vpk %BUILD_DIR%\mapbase_episodic\content

REM [===========] sdk_template_content [===============]

%BIN_DIR%\vpk.exe -M -P -c 50 -k mapbase_mp_%VERSION%.publickey.vdf -K mapbase_mp_%VERSION%.privatekey.vdf -vpk "%VPK_CONTENT_DIR%\sdk_template_content"
%BIN_DIR%\vpk.exe rehash "%VPK_CONTENT_DIR%\sdk_template_content"
echo Moving sdk_template_content
move VPKs\*.vpk %BUILD_DIR%\mapbase_scratch\content

REM [===========] Scenes [===============]

if exist VPKs\hl2_scenes (
	%BIN_DIR%\vpk.exe -M -P -c 50 -k mapbase_mp_%VERSION%.publickey.vdf -K mapbase_mp_%VERSION%.privatekey.vdf -vpk "%VPK_CONTENT_DIR%\hl2_scenes"
	%BIN_DIR%\vpk.exe rehash "%VPK_CONTENT_DIR%\hl2_scenes"
	echo Moving hl2_scenes
	move VPKs\*.vpk %BUILD_DIR%\mapbase_hl2\content
)

if exist VPKs\lostcoast_scenes (
	%BIN_DIR%\vpk.exe -M -P -c 50 -k mapbase_mp_%VERSION%.publickey.vdf -K mapbase_mp_%VERSION%.privatekey.vdf -vpk "%VPK_CONTENT_DIR%\lostcoast_scenes"
	%BIN_DIR%\vpk.exe rehash "%VPK_CONTENT_DIR%\lostcoast_scenes"
	echo Moving lostcoast_scenes
	move VPKs\*.vpk %BUILD_DIR%\mapbase_episodic\content
)

if exist VPKs\episodic_scenes (
	%BIN_DIR%\vpk.exe -M -P -c 50 -k mapbase_mp_%VERSION%.publickey.vdf -K mapbase_mp_%VERSION%.privatekey.vdf -vpk "%VPK_CONTENT_DIR%\episodic_scenes"
	%BIN_DIR%\vpk.exe rehash "%VPK_CONTENT_DIR%\episodic_scenes"
	echo Moving episodic_scenes
	move VPKs\*.vpk %BUILD_DIR%\mapbase_episodic\content
)

if exist VPKs\ep2_scenes (
	%BIN_DIR%\vpk.exe -M -P -c 50 -k mapbase_mp_%VERSION%.publickey.vdf -K mapbase_mp_%VERSION%.privatekey.vdf -vpk "%VPK_CONTENT_DIR%\ep2_scenes"
	%BIN_DIR%\vpk.exe rehash "%VPK_CONTENT_DIR%\ep2_scenes"
	echo Moving ep2_scenes
	move VPKs\*.vpk %BUILD_DIR%\mapbase_episodic\content
)

echo =====================
echo Copying FGDs
echo =====================

mkdir %BUILD_DIR%\mapbase_episodic\fgd
mkdir %BUILD_DIR%\mapbase_hl2\fgd
mkdir %BUILD_DIR%\mapbase_hl2mp\fgd
mkdir %BUILD_DIR%\mapbase_scratch\fgd

copy %SOURCE_FGDS_DIR%\base.fgd %BUILD_DIR%\mapbase_episodic\fgd
copy %SOURCE_FGDS_DIR%\base.fgd %BUILD_DIR%\mapbase_hl2\fgd
copy %SOURCE_FGDS_DIR%\base.fgd %BUILD_DIR%\mapbase_hl2mp\fgd
copy %SOURCE_FGDS_DIR%\base.fgd %BUILD_DIR%\mapbase_scratch\fgd
echo base.fgd copied
copy %SOURCE_FGDS_DIR%\halflife2.fgd %BUILD_DIR%\mapbase_episodic\fgd
copy %SOURCE_FGDS_DIR%\halflife2.fgd %BUILD_DIR%\mapbase_hl2\fgd
copy %SOURCE_FGDS_DIR%\halflife2.fgd %BUILD_DIR%\mapbase_hl2mp\fgd
echo halflife2.fgd copied
copy %SOURCE_FGDS_DIR%\hl2mp.fgd %BUILD_DIR%\mapbase_hl2mp\fgd
echo hl2mp.fgd copied
copy %SOURCE_FGDS_DIR%\sdk.fgd %BUILD_DIR%\mapbase_scratch\fgd
echo sdk.fgd copied
copy %SOURCE_FGDS_DIR%\obsolete.fgd %BUILD_DIR%\mapbase_hl2\fgd
copy %SOURCE_FGDS_DIR%\obsolete.fgd %BUILD_DIR%\mapbase_hl2\fgd
copy %SOURCE_FGDS_DIR%\obsolete.fgd %BUILD_DIR%\mapbase_hl2mp\fgd
copy %SOURCE_FGDS_DIR%\obsolete.fgd %BUILD_DIR%\mapbase_scratch\fgd
echo obsolete.fgd copied

echo =====================
echo Copying READMEs
echo =====================

copy README.txt %BUILD_DIR%
echo README.txt copied
copy MAPBASE_CONTENT_USAGE.txt %BUILD_DIR%
echo MAPBASE_CONTENT_USAGE.txt copied

echo =====================
echo Cleaning up files
echo =====================

rd /s /q VPKs\ep2_materials
echo Loose ep2_materials removed
rd /s /q VPKs\episodic_materials
echo Loose episodic_materials removed
rd /s /q VPKs\hl2_materials
echo Loose hl2_materials removed
rd /s /q VPKs\lostcoast_materials
echo Loose lostcoast_materials removed

rd /s /q VPKs\ep2_scenes
echo Loose ep2_scenes removed
rd /s /q VPKs\episodic_scenes
echo Loose episodic_scenes removed
rd /s /q VPKs\hl2_scenes
echo Loose hl2_scenes removed
rd /s /q VPKs\lostcoast_scenes
echo Loose lostcoast_scenes removed

mkdir %BUILD_DIR%\mapbase_episodic\custom
mkdir %BUILD_DIR%\mapbase_hl2\custom
mkdir %BUILD_DIR%\mapbase_hl2mp\custom
mkdir %BUILD_DIR%\mapbase_scratch\custom

mkdir %BUILD_DIR%\mapbase_episodic\maps
mkdir %BUILD_DIR%\mapbase_hl2\maps

echo ==========================================
echo Manual steps needed:
echo ==========================================

if "%USE_LOCAL_CODE%"=="false" (
    echo     - ADD THE CODE
    echo         - Add binaries to mapbase_hl2\mapbase_episodic\mapbase_hl2mp and mapbase_scratch
    echo         - If applicable, add compile tools

    if not exist %BUILD_DIR%\mapbase_hl2\content\hl2_scenes_dir.vpk (
        if not exist %BUILD_DIR%\mapbase_episodic\content\episodic_scenes_dir.vpk (
            echo     "- Add hl2_scenes and\or episodic_scenes or lostcoast_scenes VPKs to the respective games' content directories."
        )
    )
) else (
    if not exist %BUILD_DIR%\mapbase_episodic\bin\game_shader_dx9.dll (
        if not exist %BUILD_DIR%\mapbase_hl2\bin\game_shader_dx9.dll (
			if not exist %BUILD_DIR%\mapbase_hl2mp\bin\game_shader_dx9.dll (
				if not exist %BUILD_DIR%\mapbase_scratch\bin\game_shader_dx9.dll (
					echo     "- Add missing shader DLLs."
				)
			)
        )
    )
	
    if not exist %BUILD_DIR%\mapbase_hl2\bin\vaudio_miles.dll (
		if not exist %BUILD_DIR%\mapbase_episodic\bin\vaudio_miles.dll (
			if not exist %BUILD_DIR%\mapbase_hl2mp\bin\vaudio_miles.dll (
				if not exist %BUILD_DIR%\mapbase_scratch\bin\vaudio_miles.dll (
					echo     "- Add missing Audio DLLs (This makes the engine use MiniMp3)"
				)
			)
		)
    )

    if not exist %BUILD_DIR%\mapbase_hl2\bin\server.so (
		if not exist %BUILD_DIR%\mapbase_episodic\bin\server.so (
			if not exist %BUILD_DIR%\mapbase_hl2mp\bin\server.so (
				if not exist %BUILD_DIR%\mapbase_scratch\bin\server.so (
					echo     "- Add missing Linux SOs (if this build should support Linux)"
				)
			)
		)
    )
	
    if not exist %BUILD_DIR%\mapbase_hl2\bin\server.dylib (
		if not exist %BUILD_DIR%\mapbase_episodic\bin\server.dylib (
			if not exist %BUILD_DIR%\mapbase_hl2mp\bin\server.dylib (
				if not exist %BUILD_DIR%\mapbase_scratch\bin\server.dylib (
					echo     "- Add missing OSxs (if this build should support macOS)"
				)
			)
		)
    )
)

if not exist %BUILD_DIR%\base_content\fgd\base.fgd (
    echo     "- Add the FGDs to base_content\fgd"
)

if %ERRORLEVEL% NEQ 0 goto error
goto success

:success
echo ==========================================

echo Done! Press enter to continue
pause
exit

:error
echo Error packing assets!
pause
exit
