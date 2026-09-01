function pth = layout_path(P, kind, bucket, window_id, suffix)
%LAYOUT_PATH  按 topology.layout 模板拼路径。
    if nargin < 1 || isempty(P)
        P = resolve_paths();
    end
    if strcmp(kind, 'final')
        tpl = P.layout.finalTemplate;
    elseif strcmp(kind, 'csv')
        tpl = P.layout.csvTemplate;
    elseif strcmp(kind, 'abs')
        tpl = P.layout.absTemplate;
    else
        error('unknown layout kind %s', kind);
    end
    tpl = strrep(tpl, '{bucket}', bucket);
    tpl = strrep(tpl, '{window_id}', window_id);
    tpl = strrep(tpl, '{suffix}', suffix);
    pth = fullfile(P.outputRoot, tpl);
end
