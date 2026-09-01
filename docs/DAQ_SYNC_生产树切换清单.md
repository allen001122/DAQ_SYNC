# 生产树切换清单（只出清单，不执行）

以 docs/DAQ_SYNC_落地操作步骤.md 为准。该文按 2026-09-01 现场实际目录编写。

要点：

1. 旧树已在 原版\DAQ_SYNC_18batch，不必再往归档搬一次。
2. 把冻结包里的 DAQ_SYNC 复制到 C:\Users\allen\Desktop\daq_yfy\DAQ_SYNC，只新增、不覆盖。
3. 核对 local_paths.m 的 dataRoot 与 outputRoot。
4. restoredefaultpath 后 cd 到新位置 code，跑 run_acceptance('jinghong_18w')。不过不要清理。
5. 通过后才清理 _acceptance 与根目录过程包。已交付 final_by_load 与 C6_CSV_by_load 不许动。原版保留。
6. 绝对时间试验目录默认保留原地。

不要自动搬动用户机器上的任何目录。
