function P = resolve_paths(T, loc)
%RESOLVE_PATHS  结果子树绝对路径。取值与现状逐字相同，本刀只搬家。
    if nargin < 1 || isempty(T)
        T = project_topology();
    end
    if nargin < 2 || isempty(loc)
        loc = local_paths();
    end
    P = struct();
    P.dataRoot = loc.dataRoot;
    P.outputRoot = loc.outputRoot;
    P.final_by_load = fullfile(loc.outputRoot, 'final_by_load');
    P.C6_CSV_by_load = fullfile(loc.outputRoot, 'C6_CSV_by_load');
    P.C6_CSV_ABS_by_load = fullfile(loc.outputRoot, 'C6_CSV_ABS_by_load');
    P.archive = fullfile(loc.outputRoot, '_archive');
    P.final = fullfile(loc.outputRoot, 'final');
    P.intermediate = fullfile(loc.outputRoot, 'intermediate');
    P.acceptance = fullfile(loc.outputRoot, '_acceptance');
    P.layout = T.layout;
end

function pth = layout_path(P, kind, bucket, window_id, suffix)
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
