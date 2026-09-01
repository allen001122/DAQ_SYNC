function T = topology()
% 等价拓扑：设备键与通道键已改名，原始文件未改。
    T = struct();
    T.project = struct('name', 'jinghong_18w_equiv', ...
        'timezone', 'Asia/Shanghai', 'version', '1.0-equiv');
    metaFields = struct('Start_time', 'Start_time', ...
        'Start_store_time', 'Start_store_time', ...
        'Sample_rate', 'Sample_rate', 'Duration', 'Duration', ...
        'File_name', 'File_name');
    genericTime = {'time_I1', 'time_I2', 'time_I3', 'time_U1', 'time_U2', 'time_U3'};

    T.devices = struct('key', {}, 'reader', {}, 'dataDir', {}, ...
        'filePattern', {}, 'timeRoleDefault', {}, 'expectedFs', {}, 'contract', {});
    T.devices(1).key = 'dev_dew';
    T.devices(1).reader = 'reader_dewetron';
    T.devices(1).dataDir = 'Dewetron';
    T.devices(1).filePattern = 'm_*.mat';
    T.devices(1).timeRoleDefault = 'target';
    T.devices(1).expectedFs = 20000;
    T.devices(1).contract = struct('timeField', 'ch_AI_3_I1_TIME', ...
        'dataFields', {{'ch_AI_3_I1','ch_AI_3_I2','ch_AI_3_I3'}}, ...
        'phaseOrder', {{'A','B','C'}}, 'timeSemantics', 'relative_seconds', ...
        'epoch', '', 'unit', 'SI', 'scale', 1, 'polarity', 1, ...
        'metaFields', metaFields, 'maps', unit_a_maps());

    T.devices(2).key = 'dev_sf7';
    T.devices(2).reader = 'reader_dewesoft';
    T.devices(2).dataDir = 'Dewesoft\C7';
    T.devices(2).filePattern = 'Power_*.mat';
    T.devices(2).timeRoleDefault = 'target';
    T.devices(2).expectedFs = 20000;
    T.devices(2).contract = struct('timeField', 'time_I1', ...
        'dataFields', {{'I1','I2','I3'}}, 'phaseOrder', {{'A','B','C'}}, ...
        'timeSemantics', 'relative_seconds', 'epoch', '', 'unit', 'SI', ...
        'scale', 1, 'polarity', 1, 'metaFields', metaFields, ...
        'maps', unit_bc_maps(genericTime));

    T.devices(3).key = 'dev_sf10';
    T.devices(3).reader = 'reader_dewesoft';
    T.devices(3).dataDir = 'Dewesoft\C10';
    T.devices(3).filePattern = 'Power_*.mat';
    T.devices(3).timeRoleDefault = 'reference';
    T.devices(3).expectedFs = 20000;
    T.devices(3).contract = struct('timeField', 'time_I1', ...
        'dataFields', {{'I1','I2','I3'}}, 'phaseOrder', {{'A','B','C'}}, ...
        'timeSemantics', 'relative_seconds', 'epoch', '', 'unit', 'SI', ...
        'scale', 1, 'polarity', 1, 'metaFields', metaFields, ...
        'maps', unit_bc_maps(genericTime));

    T.channels = struct('key', {}, 'device', {}, 'electricalRole', {}, ...
        'scale', {}, 'polarity', {});
    T.channels(1) = ch('BR5', 'dev_dew', 'component');
    T.channels(2) = ch('BR8', 'dev_dew', 'component');
    T.channels(3) = ch('BR9', 'dev_dew', 'component');
    T.channels(4) = ch('BR7', 'dev_sf7', 'component');
    T.channels(5) = ch('BR10', 'dev_sf10', 'total');
    T.channels(6) = ch('BR6', '', 'derived');

    T.edges = {{'voltage_from', 'BR8', 'BR5'}};
    T.derivations = struct('target', {}, 'terms', {}, 'voltageFrom', {});
    T.derivations(1).target = 'BR6';
    T.derivations(1).terms = struct('channel', {'BR10','BR5','BR7','BR8','BR9'}, ...
        'coeff', {1, -1, -1, -1, -1});
    T.derivations(1).voltageFrom = 'BR10';

    T.align = struct('searchRangeSec', Inf, 'needCoarseScan', true, ...
        'minCorr', 0.95, 'maxPhaseSpreadSamp', 2, 'coarseFs', 200, ...
        'windowSec', 1.0, 'stepSec', 2.0, 'searchMs', 9, ...
        'minGoodFraction', 0.80, 'coarseMaxLagSec', Inf, 'autoScan', true);
    T.constants = struct('f0Nom', 50, 'maxHarmOrder', 50, ...
        'thdRange', [2 50], 'shortWindowCycles', 10);
    T.layout = struct();
    T.layout.finalTemplate = 'final_by_load/{bucket}/{window_id}_{suffix}';
    T.layout.csvTemplate = 'C6_CSV_by_load/{bucket}/{window_id}_{suffix}';
    T.layout.absTemplate = 'C6_CSV_ABS_by_load/{bucket}/{window_id}_{suffix}';
    T.layout.definedNotEnabled = false;
end

function s = ch(key, device, role)
    s = struct('key', key, 'device', device, 'electricalRole', role, ...
        'scale', 1, 'polarity', 1);
end

function maps = unit_a_maps()
    maps = struct();
    maps.BR5I.time = 'ch_AI_3_I1_TIME';
    maps.BR5I.data = {'ch_AI_3_I1', 'ch_AI_3_I2', 'ch_AI_3_I3'};
    maps.BR5I.timeCheck = {'ch_AI_3_I1_TIME', 'ch_AI_3_I2_TIME', 'ch_AI_3_I3_TIME'};
    maps.BR5U.time = 'ch_AI_3_I1_TIME';
    maps.BR5U.data = {'ch_AI_3_U1', 'ch_AI_3_U2', 'ch_AI_3_U3'};
    maps.BR5U.timeCheck = {'ch_AI_3_U1_TIME', 'ch_AI_3_U2_TIME', 'ch_AI_3_U3_TIME'};
    maps.BR8I.time = 'ch_AI_1_I1_TIME';
    maps.BR8I.data = {'ch_AI_1_I1', 'ch_AI_1_I2', 'ch_AI_1_I3'};
    maps.BR8I.timeCheck = {'ch_AI_1_I1_TIME', 'ch_AI_1_I2_TIME', 'ch_AI_1_I3_TIME'};
    maps.BR8U = [];
    maps.BR9I.time = 'ch_AI_1_I1_TRIONet3_1293_TIME';
    maps.BR9I.data = {'ch_AI_1_I1_TRIONet3_1293', 'ch_AI_1_I2_TRIONet3_1293', 'ch_AI_1_I3_TRIONet3_1293'};
    maps.BR9I.timeCheck = {'ch_AI_1_I1_TRIONet3_1293_TIME', 'ch_AI_1_I2_TRIONet3_1293_TIME', 'ch_AI_1_I3_TRIONet3_1293_TIME'};
    maps.BR9U.time = 'ch_AI_1_I1_TRIONet3_1293_TIME';
    maps.BR9U.data = {'ch_AI_1_U1_TRIONet3_1293', 'ch_AI_1_U2_TRIONet3_1293', 'ch_AI_1_U3_TRIONet3_1293'};
    maps.BR9U.timeCheck = {'ch_AI_1_U1_TRIONet3_1293_TIME', 'ch_AI_1_U2_TRIONet3_1293_TIME', 'ch_AI_1_U3_TRIONet3_1293_TIME'};
end

function maps = unit_bc_maps(genericTime)
    maps = struct();
    maps.I.time = 'time_I1';
    maps.I.data = {'I1', 'I2', 'I3'};
    maps.I.timeCheck = genericTime;
    maps.U.time = 'time_I1';
    maps.U.data = {'U1', 'U2', 'U3'};
    maps.U.timeCheck = genericTime;
end
