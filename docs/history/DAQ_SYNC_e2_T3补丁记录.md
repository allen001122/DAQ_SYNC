# T3 补丁记录（相对 T2）

engine_version 改为 3.0。

process_one_window.m 交付路径改为 final_by_load/<bucket>/<window_id>_*，中间文件改为 <window_id>.mat。命令行仍可敲 007。

run_tidy_and_harmonics.m 非 detail 目录也保留 _corrected_data.mat，与落盘迁移同时修 B3。

run_harmonics.m 截完文件名后用 window_table 反查 window_id。

A3、A4 未改：未能在本环境复现。
