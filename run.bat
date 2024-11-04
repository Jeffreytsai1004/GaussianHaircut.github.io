@CALL "%~dp0micromamba.exe" shell init --shell cmd.exe --prefix "%~dp0\"
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
@CALL condabin\micromamba.bat deactivate
@CALL condabin\micromamba.bat activate gaussian_splatting_hair
cd %PROJECT_DIR%\src\preprocessing
set CUDA_VISIBLE_DEVICES=%GPU%
python preprocess_raw_images.py --data_path %DATA_PATH%

REM 运行COLMAP重建和去畸变图像和相机
@CALL condabin\micromamba.bat deactivate
@CALL condabin\micromamba.bat activate gaussian_splatting_hair
cd %PROJECT_DIR%\src
set CUDA_VISIBLE_DEVICES=%GPU%
python convert.py -s %DATA_PATH% --camera %CAMERA% --max_size 1024

REM 运行 Matte-Anything
@CALL condabin\micromamba.bat deactivate
@CALL condabin\micromamba.bat activate matte_anything
cd %PROJECT_DIR%\src\preprocessing
set CUDA_VISIBLE_DEVICES=%GPU%
python calc_masks.py --data_path %DATA_PATH% --image_format png --max_size 2048

REM 使用IQA分数过滤图像
@CALL condabin\micromamba.bat deactivate
@CALL condabin\micromamba.bat activate gaussian_splatting_hair
cd %PROJECT_DIR%\src\preprocessing
set CUDA_VISIBLE_DEVICES=%GPU%
python filter_extra_images.py --data_path %DATA_PATH% --max_imgs 128

REM 调整图像大小
@CALL condabin\micromamba.bat deactivate
@CALL condabin\micromamba.bat activate gaussian_splatting_hair
cd %PROJECT_DIR%\src\preprocessing
set CUDA_VISIBLE_DEVICES=%GPU%
python resize_images.py --data_path %DATA_PATH%

REM 计算方向图
@CALL condabin\micromamba.bat deactivate
@CALL condabin\micromamba.bat activate gaussian_splatting_hair
cd %PROJECT_DIR%\src\preprocessing
set CUDA_VISIBLE_DEVICES=%GPU%
python calc_orientation_maps.py --img_path %DATA_PATH%\images_2 --mask_path %DATA_PATH%\masks_2\hair --orient_dir %DATA_PATH%\orientations_2\angles --conf_dir %DATA_PATH%\orientations_2\vars --filtered_img_dir %DATA_PATH%\orientations_2\filtered_imgs --vis_img_dir %DATA_PATH%\orientations_2\vis_imgs

REM 运行 OpenPose
@CALL condabin\micromamba.bat deactivate
@CALL condabin\micromamba.bat activate openpose
mkdir %DATA_PATH%\openpose
set CUDA_VISIBLE_DEVICES=%GPU% .\build\examples\openpose\openpose.exe --image_dir %DATA_PATH%\images_4 --scale_number 4 --scale_gap 0.25 --face --hand --display 0 --write_json %DATA_PATH%\openpose\json --write_images %DATA_PATH%\openpose\images --write_images_format jpg

REM 运行 Face-Alignment
@CALL condabin\micromamba.bat deactivate
@CALL condabin\micromamba.bat activate gaussian_splatting_hair
cd %PROJECT_DIR%\src\preprocessing
set CUDA_VISIBLE_DEVICES=%GPU%
python calc_face_alignment.py --data_path %DATA_PATH% --image_dir "images_4"

REM 运行 PIXIE
@CALL condabin\micromamba.bat deactivate
@CALL condabin\micromamba.bat activate pixie_env
cd %PROJECT_DIR%\ext\PIXIE
set CUDA_VISIBLE_DEVICES=%GPU%
python demos/demo_fit_face.py -i %DATA_PATH%\images_4 -s %DATA_PATH%\pixie --saveParam True --lightTex False --useTex False --rasterizer_type pytorch3d

REM 合并所有PIXIE预测
@CALL condabin\micromamba.bat deactivate
@CALL condabin\micromamba.bat activate gaussian_splatting_hair
cd %PROJECT_DIR%\src\preprocessing
set CUDA_VISIBLE_DEVICES=%GPU%
python merge_smplx_predictions.py --data_path %DATA_PATH%

REM 将COLMAP相机转换为txt
@CALL condabin\micromamba.bat deactivate
@CALL condabin\micromamba.bat activate gaussian_splatting_hair
if not exist %DATA_PATH%\sparse_txt mkdir %DATA_PATH%\sparse_txt
set CUDA_VISIBLE_DEVICES=%GPU%
colmap model_converter --input_path %DATA_PATH%\sparse\0 --output_path %DATA_PATH%\sparse_txt --output_type TXT

REM 将COLMAP相机转换为H3DS格式
@CALL condabin\micromamba.bat deactivate
@CALL condabin\micromamba.bat activate gaussian_splatting_hair
cd %PROJECT_DIR%\src\preprocessing
set CUDA_VISIBLE_DEVICES=%GPU%
python colmap_parsing.py --path_to_scene %DATA_PATH%

REM 删除原始文件以节省空间
rmdir /s /q %DATA_PATH%\input %DATA_PATH%\images %DATA_PATH%\masks %DATA_PATH%\iqa*

REM ##################
REM #      重建      #
REM ##################

@CALL SET EXP_PATH_1=%DATA_PATH%\3d_gaussian_splatting\%EXP_NAME_1%

@REM 运行 3D 高斯喷涂重建
@CALL condabin\micromamba.bat deactivate
@CALL condabin\micromamba.bat activate gaussian_splatting_hair
@CALL cd %PROJECT_DIR%\src
@CALL set CUDA_VISIBLE_DEVICES=%GPU%
@CALL python train_gaussians.py -s %DATA_PATH% -m "%EXP_PATH_1%" -r 1 --port "888%GPU%" --trainable_cameras --trainable_intrinsics --use_barf --lambda_dorient 0.1

@REM 运行 FLAME 网格拟合
@CALL condabin\micromamba.bat deactivate
@CALL condabin\micromamba.bat activate gaussian_splatting_hair
@CALL cd %PROJECT_DIR%\ext\NeuralHaircut\src\multiview_optimization

@CALL set CUDA_VISIBLE_DEVICES=%GPU%
@CALL python fit.py --conf confs/train_person_1.conf --batch_size 1 --train_rotation True --fixed_images True --save_path %DATA_PATH%\flame_fitting\%EXP_NAME_1%\stage_1 --data_path %DATA_PATH% --fitted_camera_path %EXP_PATH_1%\cameras\30000_matrices.pkl
@CALL python fit.py --conf confs/train_person_1.conf --batch_size 4 --train_rotation True --fixed_images True --save_path %DATA_PATH%\flame_fitting\%EXP_NAME_1%\stage_2 --checkpoint_path %DATA_PATH%\flame_fitting\%EXP_NAME_1%\stage_1\opt_params_final --data_path %DATA_PATH% --fitted_camera_path %EXP_PATH_1%\cameras\30000_matrices.pkl
@CALL python fit.py --conf confs/train_person_1_.conf --batch_size 32 --train_rotation True --train_shape True --save_path %DATA_PATH%\flame_fitting\%EXP_NAME_1%\stage_3 --checkpoint_path %DATA_PATH%\flame_fitting\%EXP_NAME_1%\stage_2\opt_params_final --data_path %DATA_PATH% --fitted_camera_path %EXP_PATH_1%\cameras\30000_matrices.pkl

@REM 裁剪重建的场景
@CALL condabin\micromamba.bat deactivate
@CALL condabin\micromamba.bat activate gaussian_splatting_hair
@CALL cd %PROJECT_DIR%\src\preprocessing
@CALL python scale_scene_into_sphere.py --path_to_data %DATA_PATH% -m "%DATA_PATH%\3d_gaussian_splatting\%EXP_NAME_1%" --iter 30000

REM 删除与 FLAME 头部网格相交的头发高斯
@CALL condabin\micromamba.bat deactivate
@CALL condabin\micromamba.bat activate gaussian_splatting_hair
@CALL cd %PROJECT_DIR%\src\preprocessing
@CALL python filter_flame_intersections.py --flame_mesh_dir %DATA_PATH%\flame_fitting\%EXP_NAME_1% -m "%DATA_PATH%\3d_gaussian_splatting\%EXP_NAME_1%" --iter 30000 --project_dir %PROJECT_DIR%\ext\NeuralHaircut

REM 运行渲染训练视图
@CALL condabin\micromamba.bat deactivate
@CALL condabin\micromamba.bat activate gaussian_splatting_hair
@CALL cd %PROJECT_DIR%\src
@CALL python render_gaussians.py -s %DATA_PATH% -m "%DATA_PATH%\3d_gaussian_splatting\%EXP_NAME_1%" --skip_test --scene_suffix "_cropped" --iteration 30000 --trainable_cameras --trainable_intrinsics --use_barf

@REM 获取 FLAME 网格头皮图
@CALL condabin\micromamba.bat deactivate
@CALL condabin\micromamba.bat activate gaussian_splatting_hair
@CALL cd %PROJECT_DIR%\src\preprocessing
@CALL python extract_non_visible_head_scalp.py --project_dir %PROJECT_DIR%\ext\NeuralHaircut --data_dir %DATA_PATH% --flame_mesh_dir %DATA_PATH%\flame_fitting\%EXP_NAME_1% --cams_path %DATA_PATH%\3d_gaussian_splatting\%EXP_NAME_1%\cameras\30000_matrices.pkl -m "%DATA_PATH%\3d_gaussian_splatting\%EXP_NAME_1%"

@REM 运行潜在头发丝重建
@CALL condabin\micromamba.bat deactivate
@CALL condabin\micromamba.bat activate gaussian_splatting_hair
@CALL cd %PROJECT_DIR%\src
@CALL python train_latent_strands.py -s %DATA_PATH% -m "%DATA_PATH%\3d_gaussian_splatting\%EXP_NAME_1%" -r 1 --model_path_hair "%DATA_PATH%\strands_reconstruction\%EXP_NAME_2%" --flame_mesh_dir "%DATA_PATH%\flame_fitting\%EXP_NAME_1%" --pointcloud_path_head "%EXP_PATH_1%\point_cloud_filtered\iteration_30000\raw_point_cloud.ply" --hair_conf_path "%PROJECT_DIR%\src\arguments\hair_strands_textured.yaml" --lambda_dmask 0.1 --lambda_dorient 0.1 --lambda_dsds 0.01 --load_synthetic_rgba --load_synthetic_geom --binarize_masks --iteration_data 30000 --trainable_cameras --trainable_intrinsics --use_barf --iterations 20000 --port "800%GPU%"

REM 运行头发丝重建
@CALL condabin\micromamba.bat deactivate
@CALL condabin\micromamba.bat activate gaussian_splatting_hair
@CALL cd %PROJECT_DIR%\src
@CALL python train_strands.py -s %DATA_PATH% -m "%DATA_PATH%\3d_gaussian_splatting\%EXP_NAME_1%" -r 1 --model_path_curves "%DATA_PATH%\curves_reconstruction\%EXP_NAME_3%" --flame_mesh_dir "%DATA_PATH%\flame_fitting\%EXP_NAME_1%" --pointcloud_path_head "%EXP_PATH_1%\point_cloud_filtered\iteration_30000\raw_point_cloud.ply" --start_checkpoint_hair "%DATA_PATH%\strands_reconstruction\%EXP_NAME_2%\checkpoints\20000.pth" --hair_conf_path "%PROJECT_DIR%\src\arguments\hair_strands_textured.yaml" --lambda_dmask 0.1 --lambda_dorient 0.1 --lambda_dsds 0.01 --load_synthetic_rgba --load_synthetic_geom --binarize_masks --iteration_data 30000 --position_lr_init 0.0000016 --position_lr_max_steps 10000 --trainable_cameras --trainable_intrinsics --use_barf --iterations 10000 --port "800%GPU%"

@CALL rmdir /s /q "%DATA_PATH%\3d_gaussian_splatting\%EXP_NAME_1%\train_cropped"

##################
#     可视化     #
##################

@REM 将结果的头发丝导出为 pkl 和 ply
@CALL condabin\micromamba.bat deactivate
@CALL condabin\micromamba.bat activate gaussian_splatting_hair
@CALL cd %PROJECT_DIR%\src\preprocessing
@CALL python export_curves.py --data_dir %DATA_PATH% --model_name %EXP_NAME_3% --iter 10000 --flame_mesh_path "%DATA_PATH%\flame_fitting\%EXP_NAME_1%\stage_3\mesh_final.obj" --scalp_mesh_path "%DATA_PATH%\flame_fitting\%EXP_NAME_1%\scalp_data\scalp.obj" --hair_conf_path "%PROJECT_DIR%\src\arguments\hair_strands_textured.yaml"

REM 渲染可视化
@CALL condabin\micromamba.bat deactivate
@CALL condabin\micromamba.bat activate gaussian_splatting_hair
@CALL cd %PROJECT_DIR%\src\postprocessing
@CALL python render_video.py --blender_path "%BLENDER_DIR%" --input_path "%DATA_PATH%" --exp_name_1 "%EXP_NAME_1%" --exp_name_3 "%EXP_NAME_3%"

REM 渲染头发丝
@CALL condabin\micromamba.bat deactivate
@CALL condabin\micromamba.bat activate gaussian_splatting_hair
@CALL cd %PROJECT_DIR%\src
@CALL python render_strands.py -s %DATA_PATH% --data_dir "%DATA_PATH%" --data_device "cpu" --skip_test -m "%DATA_PATH%\3d_gaussian_splatting\%EXP_NAME_1%" --iteration 30000 --flame_mesh_dir "%DATA_PATH%\flame_fitting\%EXP_NAME_1%" --model_hair_path "%DATA_PATH%\curves_reconstruction\%EXP_NAME_3%" --hair_conf_path "%PROJECT_DIR%\src\arguments\hair_strands_textured.yaml" --checkpoint_hair "%DATA_PATH%\strands_reconstruction\%EXP_NAME_2%\checkpoints\20000.pth" --checkpoint_curves "%DATA_PATH%\curves_reconstruction\%EXP_NAME_3%\checkpoints\10000.pth" --pointcloud_path_head "%EXP_PATH_1%\point_cloud\iteration_30000\raw_point_cloud.ply" --interpolate_cameras

REM 制作视频
@CALL condabin\micromamba.bat deactivate
@CALL condabin\micromamba.bat activate gaussian_splatting_hair
@CALL cd %PROJECT_DIR%\src\postprocessing
@CALL python concat_video.py --input_path "%DATA_PATH%" --exp_name_3 "%EXP_NAME_3%"


