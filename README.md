# DAQ_SYNC

多机采集时间对齐引擎。MATLAB R2016b 兼容。引擎版本 4.2。

工作目录必须是 `code`。先 `restoredefaultpath`，不要把旧树加进路径。

```matlab
restoredefaultpath
cd('<本仓库>/code')
run_acceptance('jinghong_18w')
```

说明见 `docs/DAQ_SYNC_冻结与使用说明.md`。日常命令见 `docs/DAQ_SYNC_日常操作卡.md`。

已交付十八条结果不在本仓库，不要重跑对齐、不要重导相对时间 CSV。绝对时间路径挂起。
