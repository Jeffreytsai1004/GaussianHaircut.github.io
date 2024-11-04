@ECHO OFF
SETLOCAL EnableDelayedExpansion

@CALL SET micromamba=%~dp0micromamba.exe
@CALL %micromamba% activate gaussian_splatting_hair

@CALL SET ROOT_DIR=%~dp0
@CALL SET PROJECT_DIR=%ROOT_DIR%GaussianHaircut
@CALL SET BLENDER_DIR="C:\Program Files\Blender Foundation\Blender 3.6\"
@CALL SET OPENPOSE_DIR=%PROJECT_DIR%\ext\openpose
@CALL SET MATTE_ANYTHING_DIR=%PROJECT_DIR%\ext\Matte-Anything
@CALL SET PIXIE_DIR=%PROJECT_DIR%\ext\PIXIE
@CALL SET DATA_PATH=%PROJECT_DIR%\data\raw
