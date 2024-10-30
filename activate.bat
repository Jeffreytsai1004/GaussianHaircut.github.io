@ECHO OFF

@REM 设置当前目录为环境根目录
@CALL SET ROOT_DIR=%~dp0
@CALL SET MAMBA_ROOT_PREFIX=%ROOT_DIR%\mamba

@CALL "%ROOT_DIR%micromamba.exe" shell init --shell cmd.exe --prefix "%ROOT_DIR%" || (
    ECHO Failed to initialize micromamba shell
    EXIT /B 1
)

@REM 设置环境变量
@CALL SET PROJECT_DIR=%ROOT_DIR%
@CALL SET BLENDER_DIR=[用户需要设置Blender路径]
@CALL SET DATA_PATH=[用户需要设置数据路径]

start cmd /k "%ROOT_DIR%condabin\micromamba.bat" activate %ROOT_DIR%\env || (
    ECHO Failed to activate environment
    EXIT /B 1
)
