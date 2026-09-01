function out = pairing_config(groupId, projectName)
%PAIRING_CONFIG  薄封装。定位数据已迁至 windows.csv。
    if nargin < 2 || isempty(projectName)
        projectName = 'jinghong_18w';
    end
    if nargin < 1 || isempty(groupId)
        rows = window_table(projectName);
        out = cell(numel(rows), 1);
        for i = 1:numel(rows)
            out{i} = row_as_pair(rows(i));
        end
        return;
    end
    w = window_table(projectName, groupId);
    out = row_as_pair(w);
end

function r = row_as_pair(w)
    keys = {};
    if isfield(w, 'files') && isstruct(w.files)
        keys = fieldnames(w.files);
    end
    if numel(keys) < 3
        error('window row 缺少三台设备的 files');
    end
    r = struct('groupId', w.alias, ...
        'dew589', w.files.(keys{1}), ...
        'c7', w.files.(keys{2}), ...
        'c10', w.files.(keys{3}));
end
