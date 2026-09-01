function p = load_local_paths()
    root = fileparts(fileparts(mfilename('fullpath')));
    f = fullfile(root, 'local_paths.m');
    if exist(f, 'file') ~= 2
        error('找不到机器路径文件: %s', f);
    end
    old = cd(root);
    cleaner = onCleanup(@() cd(old));
    p = local_paths();
end
