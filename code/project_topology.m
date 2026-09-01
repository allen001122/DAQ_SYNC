function T = project_topology(projectName)
%PROJECT_TOPOLOGY  定位工程目录并检查结构完整性。
    if nargin < 1 || isempty(projectName)
        projectName = default_project_name();
    end
    root = daq_sync_root();
    projDir = fullfile(root, 'projects', projectName);
    topoFile = fullfile(projDir, 'topology.m');
    if exist(topoFile, 'file') ~= 2
        error('找不到工程拓扑: %s', topoFile);
    end
    old = cd(projDir);
    cleaner = onCleanup(@() cd(old));
    T = topology();
    clear cleaner;
    assert_topology(T, projectName);
end

function name = default_project_name()
    name = 'jinghong_18w';
    lp = fullfile(daq_sync_root(), 'local_paths.m');
    if exist(lp, 'file') == 2
        p = load_local_paths();
        if isfield(p, 'projectName') && ~isempty(p.projectName)
            name = p.projectName;
        end
    end
end

function root = daq_sync_root()
    here = fileparts(mfilename('fullpath'));
    root = fileparts(here);
end

function assert_topology(T, projectName)
    need = {'project', 'devices', 'channels', 'edges', 'derivations', ...
        'align', 'constants', 'layout'};
    for i = 1:numel(need)
        if ~isfield(T, need{i})
            error('topology 缺少字段 %s', need{i});
        end
    end
    keys = {T.devices.key};
    if numel(unique(keys)) ~= numel(keys)
        error('设备键不唯一');
    end
    nRef = 0;
    for i = 1:numel(T.devices)
        if strcmp(T.devices(i).timeRoleDefault, 'reference')
            nRef = nRef + 1;
        end
    end
    if nRef ~= 1
        error('时间基准必须有且仅有一台，当前 %d（工程 %s）', nRef, projectName);
    end
end
