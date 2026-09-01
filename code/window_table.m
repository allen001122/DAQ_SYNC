function out = window_table(projectName, key)
%WINDOW_TABLE  读取 windows.csv。
%  out = window_table(projectName)
%  out = window_table(projectName, key)   key 为 window_id 或 alias
    if nargin < 1 || isempty(projectName)
        projectName = 'jinghong_18w';
    end
    rows = read_windows_csv(projectName);
    if nargin < 2 || isempty(key)
        out = rows;
        return;
    end
    key = char(key);
    for i = 1:numel(rows)
        if strcmp(rows(i).window_id, key) || strcmp(rows(i).alias, key)
            out = rows(i);
            return;
        end
    end
    avail = {};
    for i = 1:numel(rows)
        avail{end+1} = rows(i).alias; %#ok<AGROW>
        avail{end+1} = rows(i).window_id; %#ok<AGROW>
    end
    error('window_table 找不到键 %s。可用: %s', key, strjoin(avail, ', '));
end

function rows = read_windows_csv(projectName)
    root = fileparts(fileparts(mfilename('fullpath')));
    csvPath = fullfile(root, 'projects', projectName, 'windows.csv');
    if exist(csvPath, 'file') ~= 2
        error('找不到窗口清单: %s', csvPath);
    end
    fid = fopen(csvPath, 'r');
    if fid < 0
        error('无法打开 %s', csvPath);
    end
    cleaner = onCleanup(@() fclose(fid));
    headerLine = fgetl(fid);
    if ~ischar(headerLine)
        error('windows.csv 为空');
    end
    header = parse_csv_line(headerLine);
    T = project_topology(projectName);
    expect = {'window_id','start','duration','bucket','alias'};
    for di = 1:numel(T.devices)
        expect{end+1} = [T.devices(di).key '_file']; %#ok<AGROW>
        expect{end+1} = [T.devices(di).key '_segment']; %#ok<AGROW>
    end
    expect{end+1} = 'note';
    if numel(header) ~= numel(expect)
        error('windows.csv 列数 %d 与 topology 声明 %d 不符', numel(header), numel(expect));
    end
    for i = 1:numel(expect)
        if ~strcmp(header{i}, expect{i})
            error('windows.csv 第 %d 列表头为 %s，期望 %s', i, header{i}, expect{i});
        end
    end
    spec = {};
    for ei = 1:numel(expect)
        spec{end+1} = expect{ei}; %#ok<AGROW>
        spec{end+1} = {}; %#ok<AGROW>
    end
    spec = [spec, {'files', {}, 'segments', {}, 'groupId', {}}];
    rows = struct(spec{:});
    while true
        line = fgetl(fid);
        if ~ischar(line)
            break;
        end
        if isempty(strtrim(line))
            continue;
        end
        cols = parse_csv_line(line);
        if numel(cols) < numel(expect)
            tmp = cols;
            cols = cell(1, numel(expect));
            for k = 1:numel(expect)
                if k <= numel(tmp)
                    cols{k} = tmp{k};
                else
                    cols{k} = '';
                end
            end
        end
        r = struct();
        r.window_id = cols{1};
        r.start = cols{2};
        r.duration = cols{3};
        r.bucket = cols{4};
        r.alias = cols{5};
        col = 6;
        r.files = struct();
        r.segments = struct();
        for di = 1:numel(T.devices)
            dk = T.devices(di).key;
            r.files.(dk) = cols{col};
            r.segments.(dk) = cols{col+1};
            r.([dk '_file']) = cols{col};
            r.([dk '_segment']) = cols{col+1};
            col = col + 2;
        end
        r.note = cols{col};
        r.groupId = r.alias;
        rows(end+1) = r; %#ok<AGROW>
    end
end

function cols = parse_csv_line(line)
    raw = textscan(line, '%s', 'Delimiter', ',', 'WhiteSpace', '');
    cols = raw{1}';
    for i = 1:numel(cols)
        cols{i} = strtrim(cols{i});
    end
end
