# 杂物外置清单（只出清单，不执行）

建议迁到 C:\Users\allen\Desktop\daq_yfy_archive_20260831 或同级旁路目录，不由自动流程代劳。

生产目录最终只留：DAQ_SYNC 代码、Dewesoft、Dewetron、Sync_Analysis_Results、SrcData_202602、C6dxd、C10dxd。

SrcData_202602 与 C6dxd 保留，不在外置范围内。

移出生产路径、进归档：

- 重构\T2_DAQ_SYNC、重构\T3_DAQ_SYNC（合并后的唯一代码树是 DAQ_SYNC；现场验收代码目前仍在 重构\T4_DAQ_SYNC，切换完成后再迁 T4）
- DAQ_SYNC_18batch 整棵（确认切换后再迁，不要删）
- DAQ_SYNC_第一刀_e1
- 桌面上的 DAQ_SYNC_现行代码_20260829.zip、DAQ_SYNC_18batch.zip、临时补丁夹
- file_catalog_提速版.py 以及不再当生产入口的辅助脚本
- Sync_Analysis_Results\final 与 intermediate 中与 final_by_load 重复的 Group_* 工作副本，确认无唯一数据后再迁
- 根目录散落试跑脚本、已退役脚本

不要动：Dewesoft、Dewetron、SrcData_202602、C6dxd、C10dxd、final_by_load、C6_CSV_by_load、C6_CSV_ABS_by_load（绝对时间试验文件挂起保留）。
