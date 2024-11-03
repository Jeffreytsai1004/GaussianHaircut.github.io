@echo off
REM 设置基础环境变量
@CALL "%~dp0micromamba.exe" shell init --shell cmd.exe --prefix "%~dp0\"
@CALL condabin\micromamba.bat activate gaussian_splatting_hair_001
@CALL SET ROOT_DIR=%~dp0
@CALL SET PROJECT_DIR=%ROOT_DIR%GaussianHaircut
@CALL SET BLENDER_DIR=C:\Program Files\Blender Foundation\Blender 3.6\
@CALL SET DATA_PATH=%PROJECT_DIR%\data\raw
@CALL SET GPU=0
@CALL SET CAMERA=PINHOLE
@CALL SET EXP_NAME_1=stage1
@CALL SET EXP_NAME_2=stage2
@CALL SET EXP_NAME_3=stage3

REM ##################
REM #     预处理     #
REM ##################

REM 将原始图像排列成3D高斯喷涂格式
@CALL condabin\micromamba.bat activate gaussian_splatting_hair_001
cd %PROJECT_DIR%\src\preprocessing
set CUDA_VISIBLE_DEVICES=%GPU%
python preprocess_raw_images.py --data_path %DATA_PATH%

REM 运行COLMAP重建和去畸变图像和相机
cd %PROJECT_DIR%\src
set CUDA_VISIBLE_DEVICES=%GPU%
python convert.py -s %DATA_PATH% --camera %CAMERA% --max_size 1024

REM 运行 Matte-Anything
@CALL condabin\micromamba.bat activate matte_anything_001
cd %PROJECT_DIR%\src\preprocessing
set CUDA_VISIBLE_DEVICES=%GPU%
python calc_masks.py --data_path %DATA_PATH% --image_format png --max_size 2048

REM 使用IQA分数过滤图像
@CALL condabin\micromamba.bat activate gaussian_splatting_hair_001
cd %PROJECT_DIR%\src\preprocessing
set CUDA_VISIBLE_DEVICES=%GPU%
python filter_extra_images.py --data_path %DATA_PATH% --max_imgs 128

REM 调整图像大小
@CALL condabin\micromamba.bat activate gaussian_splatting_hair_001
cd %PROJECT_DIR%\src\preprocessing
set CUDA_VISIBLE_DEVICES=%GPU%
python resize_images.py --data_path %DATA_PATH%

REM 计算方向图
@CALL condabin\micromamba.bat activate gaussian_splatting_hair_001
cd %PROJECT_DIR%\src\preprocessing
set CUDA_VISIBLE_DEVICES=%GPU%
python calc_orientation_maps.py --img_path %DATA_PATH%\images_2 --mask_path %DATA_PATH%\masks_2\hair --orient_dir %DATA_PATH%\orientations_2\angles --conf_dir %DATA_PATH%\orientations_2\vars --filtered_img_dir %DATA_PATH%\orientations_2\filtered_imgs --vis_img_dir %DATA_PATH%\orientations_2\vis_imgs

REM 运行 OpenPose
call conda deactivate
cd %PROJECT_DIR%\ext\openpose
if not exist %DATA_PATH%\openpose mkdir %DATA_PATH%\openpose
set CUDA_VISIBLE_DEVICES=%GPU%
.\build\examples\openpose\openpose.exe --image_dir %DATA_PATH%\images_4 --scale_number 4 --scale_gap 0.25 --face --hand --display 0 --write_json %DATA_PATH%\openpose\json --write_images %DATA_PATH%\openpose\images --write_images_format jpg

REM 运行 Face-Alignment
@CALL condabin\micromamba.bat activate gaussian_splatting_hair_001
cd %PROJECT_DIR%\src\preprocessing
set CUDA_VISIBLE_DEVICES=%GPU%
python calc_face_alignment.py --data_path %DATA_PATH% --image_dir "images_4"

REM 运行 PIXIE
@CALL condabin\micromamba.bat activate pixie-env
cd %PROJECT_DIR%\ext\PIXIE
set CUDA_VISIBLE_DEVICES=%GPU%
python demos/demo_fit_face.py -i %DATA_PATH%\images_4 -s %DATA_PATH%\pixie --saveParam True --lightTex False --useTex False --rasterizer_type pytorch3d

REM 合并所有PIXIE预测
@CALL condabin\micromamba.bat activate gaussian_splatting_hair_001
cd %PROJECT_DIR%\src\preprocessing
set CUDA_VISIBLE_DEVICES=%GPU%
python merge_smplx_predictions.py --data_path %DATA_PATH%

REM 将COLMAP相机转换为txt
@CALL condabin\micromamba.bat activate gaussian_splatting_hair_001
if not exist %DATA_PATH%\sparse_txt mkdir %DATA_PATH%\sparse_txt
set CUDA_VISIBLE_DEVICES=%GPU%
colmap model_converter --input_path %DATA_PATH%\sparse\0 --output_path %DATA_PATH%\sparse_txt --output_type TXT

REM 将COLMAP相机转换为H3DS格式
@CALL condabin\micromamba.bat activate gaussian_splatting_hair_001
cd %PROJECT_DIR%\src\preprocessing
set CUDA_VISIBLE_DEVICES=%GPU%
python colmap_parsing.py --path_to_scene %DATA_PATH%

REM 删除原始文件以节省空间
rmdir /s /q %DATA_PATH%\input %DATA_PATH%\images %DATA_PATH%\masks %DATA_PATH%\iqa*

REM ##################
REM # RECONSTRUCTION #
REM ##################

SET EXP_PATH_1=%DATA_PATH%\3d_gaussian_splatting\%EXP_NAME_1%

REM 运行3D高斯喷涂重建
@CALL condabin\micromamba.bat activate gaussian_splatting_hair_001
cd %PROJECT_DIR%\src
set CUDA_VISIBLE_DEVICES=%GPU%
python train_gaussians.py -s %DATA_PATH% -m "%EXP_PATH_1%" -r 1 --port "888%GPU%" --trainable_cameras --trainable_intrinsics --use_barf --lambda_dorient 0.1

REM 继续其他步骤...

