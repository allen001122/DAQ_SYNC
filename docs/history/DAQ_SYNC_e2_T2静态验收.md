# T2 静态验收

windows.csv 十八行。alias 与 unit_a_segment 均为三字符，抽查 007、062、001。
window_id、bucket 与原四份身份表一致。unit_*_file 与原 pairing_config 的 dew589/c7/c10 一致。
topology.maps 中 C9U.time 仍为 ch_AI_1_I1_TRIONet3_1293_TIME，C9U.data 含 TRIONet3_1293，未规范化。
resolve_paths 的 final_by_load、C6_CSV_by_load、C6_CSV_ABS_by_load、_archive 字符串与现状相同。
process_one_window 在 T2 仍写 Group_<groupId>。
现场数值回归由 run_acceptance 第 4 段执行，本文件不做冒充通过。
