# DAQ_SYNC 现场执行说明

现行唯一代码树是交付包里的 DAQ_SYNC。现场验收代码目前仍在：

C:\Users\allen\Desktop\daq_yfy\重构\T4_DAQ_SYNC\code

不要覆盖 DAQ_SYNC_18batch。不要按 T2、T3、T4 三棵树分别再跑一遍。

## 本轮（W3，文档收尾）

先覆盖文档补丁，不要改任何 .m。然后只跑：

```matlab
restoredefaultpath
cd('C:\Users\allen\Desktop\daq_yfy\重构\T4_DAQ_SYNC\code')
run_acceptance('jinghong_18w')
```

不要 addpath 旧树。不要跑 export_window_csv_absolute。不要对正式 final_by_load 跑 clean 或 all。

八项零偏差应与 T4.2 完全相同。任何数值变化说明误改了代码，停下来报告。

## 跑完发什么回来

acceptance_report.txt、acceptance_report.csv，以及控制台从 restoredefaultpath 到 ok。不要打包整个 _acceptance。
