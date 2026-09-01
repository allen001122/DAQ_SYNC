function cfg = config()
%CONFIG  只改 dataRoot / groupId
%
% 输出：
%   对齐器实际写出：outputRoot/final/Group_<groupId>_C6.mat
%   以及同目录 Group_<groupId>_corrected_data.mat、Group_<groupId>_offset.xlsx
%   交付整理后位于：outputRoot/final_by_load/<分类档>/< 窗口标签>_*
%   两者的转换目前不在对齐流程内。
%   outputRoot/intermediate/Group_xxx.mat   中间工作区（全部U/I均为时间+三相）
%
% 独立画图入口：plot_corrected_data_ui

    loc = load_local_paths();
    cfg = struct();
    cfg.dataRoot   = loc.dataRoot;
    cfg.outputRoot = loc.outputRoot;
    cfg.groupId    = '001';   % 单组入口默认；批量时由 pairing_config / window_table 决定
    cfg.projectName = loc.projectName;
    cfg.saveExtracted = false;
end
