@echo off
setlocal enabledelayedexpansion

REM Function to URL-encode a string
set urle=for %%A in (0 1 2 3 4 5 6 7 8 9 A B C D E F) do set "hex=%%A"

REM Function definition for URL encoding
REM This is a workaround since batch doesn't support functions well
set urleString=for %%i in (0) do (
  set "str=%%~1"
  set "encoded="
  for /l %%j in (0,1,31) do (
    set "char=!str:~%%j,1!"
    if "!char!"=="" goto endLoop
    set "code=!char!"
    for %%h in (!hex!) do (
      if "!char!"=="%%h" set "encoded=!encoded!!char!"
      if "!char!"=="%%h" set "code="
    )
    if defined code (
      set /a "ascii=code+0"
      set "encoded=!encoded!%%%02x"
    )
  )
)

:endLoop

REM Inform the user about registration
echo.
echo You need to register at https://smpl-x.is.tue.mpg.de

REM Prompt for SMPL-X username and password
set /p username=Username (SMPL-X):
set /p password=Password (SMPL-X):

REM URL encode the username and password
call :urleString %username%
set username=%encoded%
call :urleString %password%
set password=%encoded%

REM Download the SMPL-X model
curl -d "username=%username%&password=%password%" -o ".\data\SMPLX_NEUTRAL_2020.npz" --insecure --continue-at - "https://download.is.tue.mpg.de/download.php?domain=smplx&sfile=SMPLX_NEUTRAL_2020.npz&resume=1"

REM Inform the user about registration
echo.
echo You need to register at https://pixie.is.tue.mpg.de/

REM Prompt for PIXIE username and password
set /p username=Username (PIXIE):
set /p password=Password (PIXIE):

REM URL encode the username and password
call :urleString %username%
set username=%encoded%
call :urleString %password%
set password=%encoded%

REM Download the PIXIE pretrained model and utilities
curl -d "username=%username%&password=%password%" -o ".\data\pixie_model.tar" --insecure --continue-at - "https://download.is.tue.mpg.de/download.php?domain=pixie&sfile=pixie_model.tar&resume=1"
curl -d "username=%username%&password=%password%" -o ".\data\utilities.zip" --insecure --continue-at - "https://download.is.tue.mpg.de/download.php?domain=pixie&sfile=utilities.zip&resume=1"

REM Unzip the utilities.zip file
cd .\data
tar -xf utilities.zip

:end
echo Download and extraction complete.