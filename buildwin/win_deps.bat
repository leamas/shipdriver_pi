::
:: Install build dependencies. Requires a working choco installation,
:: see https://docs.chocolatey.org/en-us/choco/setup.
::
:: Initial run will do choco installs requiring administrative
:: privileges.
::

:: Install the pathman tool: https://github.com/therootcompany/pathman
:: Fix PATH so it can be used in this script.
:: The regular installation using webi is broken since long, the root
:: cause (pun intended) is broken https setup at https://rootprojects.org.
::
set localbin="%HomeDrive%%HomePath%\.local\bin"
set pathman_path="buildwin\pathman.exe"
if not "%APPVEYOR_BUILD_FOLDER%" == "" (
    set pathman_path="%APPVEYOR_BUILD_FOLDER%\%pathman_path%"
)
if not exist "%HomeDrive%%HomePath%\.local\bin\pathman.exe" (
    if not exist %localbin% mkdir %localbin%
    copy %pathman_path%  %localbin%
)
pathman list > nul 2>&1
if errorlevel 1 set PATH=%PATH%;%HomeDrive%\%HomePath%\.local\bin
pathman add %HomeDrive%%HomePath%\.local\bin >nul

:: Make sure we use 64-bit python on appveyor
:: Outside appveyor, make sure we don't use the pesky python alias
:: invoking appstore installed by MS.
if not "%APPVEYOR_BUILD_FOLDER%" == "" (
    rmdir /s /q C:\Python312
    rmdir /s /q C:\Python313
    rmdir /s /q C:\Python314
    pathman add C:\Python314-x64
    pathman add C:\Python314-x64\Scripts
    set python="C:\Python314-x64\python"
) else if exist "C:\python314" (
    set python="C:\python314\python.exe"
) else (
    set python="python"
)

:: Install choco cmake and add it's persistent user path element
::
set CMAKE_HOME=C:\Program Files\CMake
if not exist "%CMAKE_HOME%\bin\cmake.exe" choco install --no-progress -y cmake
pathman add "%CMAKE_HOME%\bin" > nul

:: Install choco poedit and add it's persistent user path element
::
@echo on
if exist "C:\Program Files (x86)\Poedit\Gettexttools" (
  set POEDIT_HOME="C:\Program Files (x86)\Poedit\Gettexttools"
) else (
  set POEDIT_HOME="C:\Program Files\Poedit\Gettexttools"
)
if not exist %POEDIT_HOME% (
  choco install --version 2.4.2 --no-progress -y poedit
)

pathman add "%POEDIT_HOME%\bin" > nul

:: Update required python stuff
::
%python% --version > nul 2>&1 && %python% -m ensurepip > nul 2>&1
if errorlevel 1 choco install --no-progress -y python

echo "Checking for 64-bit python"
%python% -c "import sys; print(sys.maxsize > 2**32)"

%python% --version
%python% -m ensurepip
@echo on
%python% -m pip install --upgrade --no-warn-script-location pip
%python% -m pip install -q --no-warn-script-location setuptools wheel
%python% -m pip install -q --no-warn-script-location cloudsmith-cli
%python% -m pip install -q --no-warn-script-location cryptography
:: @echo off

:: Install pre-compiled wxWidgets and other DLL; add required paths.
::
set SCRIPTDIR=%~dp0
set WXWIN=%SCRIPTDIR%..\cache\wxWidgets.3.2.8
set CACHEDIR=%SCRIPTDIR%..\cache
set wxWidgets_ROOT_DIR=%WXWIN%
set wxWidgets_LIB_DIR=%WXWIN%\lib\native\x86\release
if not exist "%CACHEDIR%" mkdir "%CACHEDIR%"
if not exist "%WXWIN%" (
  pushd %CACHEDIR%
  if not exist "nuget.exe" (
    wget https://dist.nuget.org/win-x86-commandline/latest/nuget.exe
  )
  nuget install wxWidgets -Version 3.2.8
  popd
)
pathman add "%WXWIN%" > nul
pathman add "%wxWidgets_LIB_DIR%" > nul

if not exist %SCRIPTDIR%\..\cache ( mkdir %SCRIPTDIR%\..\cache )
set "CONFIG_FILE=%SCRIPTDIR%\..\cache\wx-config.bat"
echo set "wxWidgets_ROOT_DIR=%wxWidgets_ROOT_DIR%" > %CONFIG_FILE%
echo set "wxWidgets_LIB_DIR=%wxWidgets_LIB_DIR%" >> %CONFIG_FILE%


refreshenv
