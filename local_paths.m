function p = local_paths()
%LOCAL_PATHS  本文件随机器走，换机器只改此处。
% 不得放入工程事实。
    p = struct();
    p.dataRoot = 'C:\Users\allen\Desktop\daq_yfy';
    p.outputRoot = fullfile(p.dataRoot, 'Sync_Analysis_Results');
    p.projectName = 'jinghong_18w';
end
