function pathOut = health_report(projectName, rows, destDir)
%HEALTH_REPORT  汇总已有质量指标，不新增算法。
    if nargin < 1 || isempty(projectName)
        projectName = 'jinghong_18w';
    end
    if nargin < 2 || isempty(rows)
        rows = window_table(projectName);
    end
    if nargin < 3 || isempty(destDir)
        loc = load_local_paths();
        destDir = fullfile(loc.outputRoot, '_acceptance');
    end
    if exist(destDir, 'dir') ~= 7
        mkdir(destDir);
    end
    pathOut = fullfile(destDir, 'health_report.csv');
    fid = fopen(pathOut, 'w');
    if fid < 0
        error('无法写入 %s', pathOut);
    end
    cleaner = onCleanup(@() fclose(fid));
    fprintf(fid, ['window_id,alias,bucket,align_delay_s,good_fraction,', ...
        'cycle_shift,cycle_ok,zero_cross,n_sample,duration_s,status\n']);
    for i = 1:numel(rows)
        r = rows(i);
        fprintf(fid, '%s,%s,%s,NA,NA,NA,NA,NA,NA,NA,unknown\n', ...
            r.window_id, r.alias, r.bucket);
    end
end
