function result = run_manual_window(group, cfg)
%RUN_MANUAL_GROUP  手动选文件入口（供界面或脚本调用）
%
%   group.dew589  - 589 (C5/C8/C9) 完整绝对路径
%   group.c7      - C7 完整绝对路径
%   group.c10     - C10 完整绝对路径
%   group.groupId - 可选，用于输出命名
%   group.source  - 建议设为 'manual'
%
%   cfg           - config() 返回的结构体（主要用 outputRoot）
%
%   若 nargin < 2，自动调用 config()。
%
% 示例（脚本）：
%   group.dew589 = 'D:\data\xxx.mat';
%   group.c7     = 'D:\data\yyy.mat';
%   group.c10    = 'D:\data\zzz.mat';
%   group.groupId = '065';
%   group.source  = 'manual';
%   r = run_manual_window(group);

    if nargin < 2 || isempty(cfg)
        cfg = config();
    end

    if ~isstruct(group) || ~isfield(group, 'dew589') || ...
            ~isfield(group, 'c7') || ~isfield(group, 'c10')
        error('run_manual_window: group 必须是含 dew589/c7/c10 字段的结构体');
    end

    if ~isfield(group, 'source') || isempty(group.source)
        group.source = 'manual';
    end

    fprintf('============================================================\n');
    if isfield(group, 'groupId') && ~isempty(group.groupId)
        fprintf('Sync Analysis - 手动路径A  Group %s\n', group.groupId);
    else
        fprintf('Sync Analysis - 手动路径A\n');
    end
    fprintf('============================================================\n');
    fprintf('589: %s\nC7 : %s\nC10: %s\n', group.dew589, group.c7, group.c10);

    result = process_one_window(group, cfg);

    switch result.status
        case 'success'
            fprintf('OK  N=%d  C6I THD=%.3f/%.3f/%.3f %%\n', ...
                result.n, result.THD(1), result.THD(2), result.THD(3));
            if isfield(result, 'THDU_C10')
                fprintf('    C6U THDU=%.3f/%.3f/%.3f %%\n', ...
                    result.THDU_C10(1), result.THDU_C10(2), result.THDU_C10(3));
            end
            fprintf('最终 C6: %s\n', result.finalFile);
            if isfield(result, 'correctedFile')
                fprintf('校正时间数据: %s\n', result.correctedFile);
            end
            if isfield(result, 'offsetFile')
                fprintf('最终 offset: %s\n', result.offsetFile);
            end
            fprintf('中间: %s\n', result.interFile);
        case 'skipped_align_fail'
            fprintf('对齐未通过，已跳过路径A\n');
        otherwise
            fprintf('失败: %s\n', result.errorMsg);
    end
end
