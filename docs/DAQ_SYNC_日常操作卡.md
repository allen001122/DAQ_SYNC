# DAQ_SYNC 日常操作卡

引擎 4.2。先 restoredefaultpath。详细说明见 docs\DAQ_SYNC_冻结与使用说明.md。

```matlab
restoredefaultpath
cd('C:\Users\allen\Desktop\daq_yfy\重构\T4_DAQ_SYNC\code')
run_acceptance('jinghong_18w')
```

单窗与整批（已交付十八条不要跑）：

```matlab
run_one_window('jinghong_18w', '007')
run_batch('jinghong_18w')
run_batch('jinghong_18w', 'force')
```

相对时间自测：

```matlab
export_window_csv_relative('selftest')
```

本轮不要运行 export_window_csv_absolute。不要移动或删除已导出的绝对时间 CSV。不要改 config.m 的 groupId 来选组。
