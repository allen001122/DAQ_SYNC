# DAQ_SYNC 落地操作步骤

2026-09-01。按 `daq_yfy` 当前实际目录状态编写，替代交付包里那份切换清单的第 3 步假设。

## 当前实情

新树尚未放到生产位置，`daq_yfy` 根下没有 `DAQ_SYNC`。

旧树已经不在生产位置了，它在 `原版\DAQ_SYNC_18batch`，二十八项俱全。切换清单里"把旧树整体移到归档目录"这一步你已经做过，不用再做。

已交付结果完好：`final_by_load` 一百四十四个文件 115.77 GB，`C6_CSV_by_load` 三十八个 13.87 GB，与十八条乘八、十八条乘二加二完全吱合。

`_acceptance` 攘了五次运行共 82.65 GB：`T2.0` 13.16、`T3.0` 13.16、`T4.0` 14.45、`T4.1` 20.94、`T4.2` 20.94。

`daq_yfy` 总占用约 346 GB。

---

## 第一步　放新树（不破坏任何东西）

把 W3 冻结包里的 `DAQ_SYNC` 整个复制到：

`C:\Users\allen\Desktop\daq_yfy\DAQ_SYNC`

这一步只是新增一个目录，不覆盖、不移动任何现有内容。放完之后根下应该有 `DAQ_SYNC` 与 `code`、`docs`、`projects`、`local_paths.m`、`文件清单.txt` 五项。

打开 `DAQ_SYNC\local_paths.m`，确认两条：`dataRoot` 是 `C:\Users\allen\Desktop\daq_yfy`，`outputRoot` 是 `C:\Users\allen\Desktop\daq_yfy\Sync_Analysis_Results`。

## 第二步　在新位置跑一次验收

这一步必须做，也是唯一必须跑 MATLAB 的一步。它验证的不是代码——代码已经字节比对过——而是**路径**：新树在生产位置上能不能正确找到数据与结果。

```matlab
restoredefaultpath
cd('C:\Users\allen\Desktop\daq_yfy\DAQ_SYNC\code')
run_acceptance('jinghong_18w')
```

约二十分钟。判定标准：`ok=1`，八项零偏差全部为零，预检 `err=0 warn=24`。

**这一步不过，不要往下做第三步。** 报告发我，先定位路径问题。

结果会写进 `_acceptance` 下一个新目录（大概是 `T4.3`），再占约 21 GB。第四步会一并清掉。

## 第三步　确认新树接管

验收过了，新树就是生产树。此后所有操作都在 `DAQ_SYNC\code` 下进行，不要再进 `重构\T4_DAQ_SYNC`。

日常怎么跑看 `DAQ_SYNC\docs\DAQ_SYNC_日常操作卡.md`，细节看同目录的冻结与使用说明。

---

## 第四步　清理 `_acceptance`（释放约 82 GB）

**这一步在第二步通过之后才做。** 顺序反了，万一验收不过就没有对比现场了。

`T2.0` 与 `T3.0` 是已废弃的两棵树留下的，完全没用，整个删掉，释放 26.32 GB。

`T4.0` 与 `T4.1` 是过程版本，已被 `T4.2` 取代，整个删掉，释放 35.39 GB。

`T4.2` 是最终验收那次，是证据，但真正有价值的只有两个报告文件，几 KB。做法是：把 `T4.2\acceptance_report.txt` 与 `acceptance_report.csv` 复制到 `DAQ_SYNC\docs\history\` 下另存，然后把整个 `T4.2` 删掉，释放 20.94 GB。

第二步新产生的那个目录同样处理：报告留档，其余删掉。

四项做完，`_acceptance` 从 82.65 GB 降到几乎为零，报告全部归档进交付树。

---

## 第五步　清理根目录的过程包

以下都是重构过程中的中间产物，代码已经全部进了 `DAQ_SYNC`，可以整体删除或移进一个归档目录。占用极小，清理是为了根目录能看清楚。

目录：`T4_W1`、`T4_W2`、`T4_R2补丁`、`T4_e3阶段一二`、`投递`、`重构`。

压缩包：`T4_W1.zip`、`T4_W2.zip`、`T4_e3阶段一二.zip`。

脚本：`分割原版与重构.py`。根下的 `file_catalog_提速版.py` 与 `工具\file_catalog_提速版.py` 重复，留一份即可，建议留 `工具\` 下那份。

`原版` 保留不动，那是旧树归档，是回退路径。

建议做法是新建 `daq_yfy\_archive_重构过程\`，把上面这些整体移进去，而不是直接删——它们很小，留着不占地方，万一要查某一轮改了什么还有据可依。

## 第六步　杂物外置

按 `DAQ_SYNC\docs\DAQ_SYNC_杂物外置清单.md` 执行。

清单里已经写明不许动的：`Dewesoft`、`Dewetron`、`SrcData_202602`、`C6dxd`、`C10dxd`、`final_by_load`、`C6_CSV_by_load`、`C6_CSV_ABS_by_load`。

`SrcData_202602` 里有两个大压缩包 `fitting_test_all_v7.zip` 513 MB 与 `yfy_ysm_compare.zip` 169 MB，还有两个 Excel 临时锁文件 `~$pianyi.xlsx`、`~$pianyinew.xlsx`。锁文件是 Excel 异常退出留下的垃圾，删掉无害。两个 zip 你自己判断还要不要。

---

## 第七步　绝对时间试验产物的处置

`C6_CSV_ABS_by_load` 现在有四个文件共 0.98 GB：`70-80pct\2025_05_08_122000_C6.csv` 977 MB，加上自动生成的 `导入清单.csv`、`导入说明.txt`、`*_C6_dewesoft.txt`。

按之前定的，**保留原地不动**，它不是交付物，是未验证的试验产物，状态写在 `DAQ_SYNC\docs\DAQ_SYNC_冻结与使用说明.md` 第六节。

若你想省这 0.98 GB 也可以删——重导一条只要七十一秒。但删之前把那一节的措辞从"已导出一条"改成"尚未导出"，免得文档与磁盘对不上。**二选一，不要留着文件却改成没导。**

---

## 做完之后的样子

`daq_yfy` 根下：`DAQ_SYNC`（生产树）、`Dewesoft`、`Dewetron`、`Sync_Analysis_Results`、`SrcData_202602`、`C6dxd`、`C10dxd`、`原版`（旧树归档）、`工具`、`_archive_重构过程`。

`Sync_Analysis_Results` 下：`final_by_load`、`C6_CSV_by_load`、`C6_CSV_ABS_by_load`、`final`、`intermediate`，`_acceptance` 清空或只留空目录。

总占用从约 346 GB 降到约 264 GB。

---

## 全程红线

不许动 `Dewesoft`、`Dewetron` 下任何文件。

不许动 `Sync_Analysis_Results\final_by_load` 与 `C6_CSV_by_load` 下任何文件——那是已上交的一百四十四个加三十八个文件，第四步清理只碰 `_acceptance`。

`原版\DAQ_SYNC_18batch` 保留不删，它是回退路径。新树用满一段时间、下一批数据也跑顺了，再考虑处置。

第四步之前必须先过第二步。清理之前先验证，这个顺序不要颠倒。

---

## 剩下的挂起项

绝对时间在 Dewesoft 里的人工导入验证，等你有条件时按冻结说明第六节的四步做。

下一批数据来的时候用新引擎跑一遍——那才是通用性的真正检验，现在的等价拓扑测试只是模拟。
