function draft = probe_mat_fields(matPath)
%PROBE_MAT_FIELDS  探测工具。正式读取路径不得调用本函数猜名。
    if nargin < 1 || exist(matPath, 'file') ~= 2
        error('probe_mat_fields 需要一个存在的 mat 路径');
    end
    S = load(matPath);
    fn = fieldnames(S);
    draft = struct('file', matPath, 'fields', {fn});
    fprintf('probe %s  fields=%d\n', matPath, numel(fn));
    for i = 1:numel(fn)
        x = S.(fn{i});
        fprintf('  %s  class=%s  numel=%d\n', fn{i}, class(x), numel(x));
    end
    fprintf('以上为草稿，须人工确认后写入 topology，正式运行不猜。\n');
end
