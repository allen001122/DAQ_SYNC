function pathOut = run_manifest(projectName, items, destDir)
%RUN_MANIFEST  每次批量运行写一份运行清单。
    if nargin < 1 || isempty(projectName)
        projectName = 'jinghong_18w';
    end
    if nargin < 2
        items = struct('window_id', {}, 'alias', {}, 'status', {}, ...
            'elapsed_s', {}, 'outputs', {});
    end
    if nargin < 3 || isempty(destDir)
        loc = load_local_paths();
        destDir = fullfile(loc.outputRoot, '_acceptance');
    end
    if exist(destDir, 'dir') ~= 7
        mkdir(destDir);
    end
    T = project_topology(projectName);
    stamp = datestr(now, 'yyyymmdd_HHMMSS');
    pathOut = fullfile(destDir, sprintf('run_manifest_%s.csv', stamp));
    fid = fopen(pathOut, 'w');
    if fid < 0
        error('无法写入 %s', pathOut);
    end
    cleaner = onCleanup(@() fclose(fid));
    fprintf(fid, ['run_time,engine_version,topology_version,window_id,', ...
        'alias,status,elapsed_s,outputs\n']);
    ev = engine_version();
    tv = T.project.version;
    rt = datestr(now, 31);
    if isempty(items)
        fprintf(fid, '%s,%s,%s,,,empty,NA,\n', rt, ev, tv);
        return;
    end
    for i = 1:numel(items)
        outp = '';
        if isfield(items, 'outputs') && ~isempty(items(i).outputs)
            outp = items(i).outputs;
        end
        el = 'NA';
        if isfield(items, 'elapsed_s') && ~isempty(items(i).elapsed_s)
            el = num2str(items(i).elapsed_s);
        end
        fprintf(fid, '%s,%s,%s,%s,%s,%s,%s,%s\n', ...
            rt, ev, tv, items(i).window_id, items(i).alias, ...
            items(i).status, el, outp);
    end
end
