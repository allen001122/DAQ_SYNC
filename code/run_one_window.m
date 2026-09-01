function r = run_one_window(projectName, windowKey, mode)
%RUN_ONE_WINDOW  单窗口入口。
%  run_one_window
%  run_one_window('jinghong_18w','007')
%  run_one_window('jinghong_18w','007','force')
% 窗口键缺省取 config.groupId。无 clear。

    if nargin < 1 || isempty(projectName)
        projectName = 'jinghong_18w';
    end
    cfg = config();
    cfg.projectName = projectName;
    if nargin < 2 || isempty(windowKey)
        windowKey = cfg.groupId;
    end
    if nargin < 3 || isempty(mode)
        mode = 'run';
    end
    groupId = windowKey;
    if ~isempty(regexp(char(windowKey), '^\d{1,4}$', 'once'))
        groupId = sprintf('%03d', str2double(windowKey));
    end

    fprintf('============================================================\n');
    fprintf('Sync Analysis - 单组路径A  %s  %s\n', projectName, groupId);
    fprintf('============================================================\n');

    if exist(cfg.dataRoot, 'dir') ~= 7
        error('数据根目录不存在: %s', cfg.dataRoot);
    end

    if ~strcmpi(mode, 'force')
        try
            wdone = window_table(projectName, groupId);
            loc = load_local_paths();
            loc.outputRoot = cfg.outputRoot;
            Pth = resolve_paths(project_topology(projectName), loc);
            der = project_topology(projectName);
            sfx = [der.derivations(1).target '.mat'];
            doneFile = layout_path(Pth, 'final', wdone.bucket, wdone.window_id, sfx);
            if exist(doneFile, 'file') == 2
                fprintf('已存在 %s ，mode=run 跳过。要重跑用 force。\n', doneFile);
                r = struct('groupId', groupId, 'status', 'skipped_exists', ...
                    'finalFile', doneFile);
                return;
            end
        catch
        end
    end

    r = process_one_window(groupId, cfg);

    switch r.status
        case 'success'
            fprintf('OK  N=%d  C6I THD=%.3f/%.3f/%.3f %%\n', r.n, r.THD(1), r.THD(2), r.THD(3));
            if isfield(r, 'THDU_C10')
                fprintf('    THDU_ref=%.3f/%.3f/%.3f %%\n', r.THDU_C10(1), r.THDU_C10(2), r.THDU_C10(3));
            end
            fprintf('最终: %s\n', r.finalFile);
        case 'skipped_align_fail'
            fprintf('对齐未通过，已跳过路径A\n');
        case 'skipped_exists'
            fprintf('已存在，已跳过\n');
        otherwise
            fprintf('失败: %s\n', r.errorMsg);
    end
end
