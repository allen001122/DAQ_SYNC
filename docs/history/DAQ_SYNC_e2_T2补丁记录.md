# T2 补丁记录（相对第一刀 e1-A 树）

## 新增整文件

local_paths.m（工程根）机器路径。
projects/jinghong_18w/topology.m 工程事实，契约原样搬自 maps。
projects/jinghong_18w/windows.csv 十八行清单，alias 与 unit_a_segment 三字符。
code/engine_version.m 返回 2.0。
code/load_local_paths.m
code/project_topology.m
code/window_table.m
code/resolve_paths.m
code/preflight.m
code/health_report.m
code/run_manifest.m
code/run_acceptance.m

## 已有文件改动

pairing_config.m 清空内嵌十八行，改为查 window_table。
export_window_csv_relative.m / absolute.m / run_tidy_and_harmonics.m 的 group_table 改为查表投影。
run_harmonics.m 的 lookup_group_id 改为查表。
config.m 的 dataRoot/outputRoot 改为读 local_paths。
read_window_sources.m 文件头注明契约已搬、本刀读取逻辑不改。
verify_modules.m 白名单补入本刀新模块。

## 未改

对齐算法、落盘 Group_ 前缀、十三条缺陷、Dewesoft/Dewetron/已交付结果。
