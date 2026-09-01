function report = preflight(projectName)
%PREFLIGHT  只读。数秒内检查清单与磁盘。
    if nargin < 1 || isempty(projectName)
        projectName = 'jinghong_18w';
    end
    T = project_topology(projectName);
    loc = load_local_paths();
    P = resolve_paths(T, loc);
    rows = window_table(projectName);

    report = struct();
    report.project = projectName;
    report.status = 'ok';
    report.warnings = {};
    report.errors = {};
    report.nRows = numel(rows);

    expectDev = {T.devices.key};
    headerDev = {'unit_a', 'unit_b', 'unit_c'};
    if numel(expectDev) ~= numel(headerDev)
        report.errors{end+1} = '清单设备列与 topology 设备数不一致';
    end
    for i = 1:min(numel(expectDev), numel(headerDev))
        if ~strcmp(expectDev{i}, headerDev{i})
            report.errors{end+1} = sprintf('设备键次序不符: %s vs %s', ...
                expectDev{i}, headerDev{i});
        end
    end

    for i = 1:numel(rows)
        r = rows(i);
        if numel(r.alias) ~= 3
            report.errors{end+1} = sprintf('行 %s alias 宽度=%d，应为 3', ...
                r.window_id, numel(r.alias));
        end
        if numel(r.unit_a_segment) ~= 3
            report.errors{end+1} = sprintf('行 %s unit_a_segment 宽度=%d，应为 3', ...
                r.window_id, numel(r.unit_a_segment));
        end
        report = check_file(loc.dataRoot, T.devices(1).dataDir, r.unit_a_file, r, report, 'unit_a');
        report = check_file(loc.dataRoot, T.devices(2).dataDir, r.unit_b_file, r, report, 'unit_b');
        report = check_file(loc.dataRoot, T.devices(3).dataDir, r.unit_c_file, r, report, 'unit_c');
        report = warn_stamp_vs_files(r, report);
    end

    if exist(P.outputRoot, 'dir') ~= 7
        report.warnings{end+1} = sprintf('输出根不存在: %s', P.outputRoot);
    end

    if ~isempty(report.errors)
        report.status = 'block';
    elseif ~isempty(report.warnings)
        report.status = 'warn';
    end

    fprintf('preflight %s  status=%s  rows=%d  warn=%d  err=%d\n', ...
        projectName, report.status, report.nRows, ...
        numel(report.warnings), numel(report.errors));
    for i = 1:numel(report.errors)
        fprintf('  ERR  %s\n', report.errors{i});
    end
    for i = 1:numel(report.warnings)
        fprintf('  WARN %s\n', report.warnings{i});
    end
end

function report = check_file(dataRoot, dataDir, fname, r, report, key)
    if isempty(fname)
        if strcmp(key, 'unit_c')
            report.errors{end+1} = sprintf('%s 缺时间基准文件', r.window_id);
        else
            report.warnings{end+1} = sprintf('%s 缺 %s 文件列', r.window_id, key);
        end
        return;
    end
    p = fullfile(dataRoot, dataDir, fname);
    if exist(p, 'file') ~= 2
        report.errors{end+1} = sprintf('%s 找不到 %s: %s', r.window_id, key, p);
    end
end

function report = warn_stamp_vs_files(r, report)
    % 主键三方校验的文件名侧：从文件名抽出 6 位时分秒与 window_id 末 6 位比较。
    wid = r.window_id;
    if numel(wid) < 6
        return;
    end
    tag = wid(end-5:end);
    files = {r.unit_b_file, r.unit_c_file};
    for i = 1:numel(files)
        tok = regexp(files{i}, '(\d{6})(?:\.mat)?$', 'tokens', 'once');
        if isempty(tok)
            continue;
        end
        dt = stamp_sec_diff(tag, tok{1});
        if abs(dt) >= 120
            report.errors{end+1} = sprintf('%s 与文件 %s 时差 %d s，阻断', ...
                wid, files{i}, dt); %#ok<AGROW>
        elseif abs(dt) >= 30
            report.warnings{end+1} = sprintf('%s 与文件 %s 时差 %d s', ...
                wid, files{i}, dt); %#ok<AGROW>
        elseif abs(dt) > 0
            report.warnings{end+1} = sprintf('%s 与文件 %s 时差 %d s（秒级，放行）', ...
                wid, files{i}, dt); %#ok<AGROW>
        end
    end
end

function dt = stamp_sec_diff(a, b)
    dt = hhmmss_to_sec(a) - hhmmss_to_sec(b);
end

function s = hhmmss_to_sec(x)
    s = str2double(x(1:2))*3600 + str2double(x(3:4))*60 + str2double(x(5:6));
end
