function T = topology()
%TOPOLOGY  jinghong_18w 工程事实。version=1.0
% 契约从 read_window_sources.m 的 maps 原样搬入，未规范化。

    T = struct();
    T.project = struct();
    T.project.name = 'jinghong_18w';
    T.project.timezone = 'Asia/Shanghai';
    T.project.version = '1.0';

    genericTime = {'time_I1', 'time_I2', 'time_I3', 'time_U1', 'time_U2', 'time_U3'};
    metaFields = struct( ...
        'Start_time', 'Start_time', ...
        'Start_store_time', 'Start_store_time', ...
        'Sample_rate', 'Sample_rate', ...
        'Duration', 'Duration', ...
        'File_name', 'File_name');

    T.devices = struct('key', {}, 'reader', {}, 'dataDir', {}, ...
        'filePattern', {}, 'timeRoleDefault', {}, 'expectedFs', {}, 'contract', {});

    T.devices(1).key = 'unit_a';
    T.devices(1).reader = 'reader_dewetron';
    T.devices(1).dataDir = 'Dewetron';
    T.devices(1).filePattern = 'm_*.mat';
    T.devices(1).timeRoleDefault = 'target';
    T.devices(1).expectedFs = 20000;
    T.devices(1).contract = struct();
    T.devices(1).contract.timeField = 'ch_AI_3_I1_TIME';
    T.devices(1).contract.dataFields = { ...
        'ch_AI_3_I1', 'ch_AI_3_I2', 'ch_AI_3_I3'; ...
        'ch_AI_3_U1', 'ch_AI_3_U2', 'ch_AI_3_U3'};
    T.devices(1).contract.phaseOrder = {'A', 'B', 'C'};
    T.devices(1).contract.timeSemantics = 'relative_seconds';
    T.devices(1).contract.epoch = '';
    T.devices(1).contract.unit = 'SI';
    T.devices(1).contract.scale = 1;
    T.devices(1).contract.polarity = 1;
    T.devices(1).contract.metaFields = metaFields;
    T.devices(1).contract.maps = unit_a_maps();

    T.devices(2).key = 'unit_b';
    T.devices(2).reader = 'reader_dewesoft';
    T.devices(2).dataDir = 'Dewesoft\C7';
    T.devices(2).filePattern = 'Power_*.mat';
    T.devices(2).timeRoleDefault = 'target';
    T.devices(2).expectedFs = 20000;
    T.devices(2).contract = struct();
    T.devices(2).contract.timeField = 'time_I1';
    T.devices(2).contract.dataFields = {'I1', 'I2', 'I3'; 'U1', 'U2', 'U3'};
    T.devices(2).contract.phaseOrder = {'A', 'B', 'C'};
    T.devices(2).contract.timeSemantics = 'relative_seconds';
    T.devices(2).contract.epoch = '';
    T.devices(2).contract.unit = 'SI';
    T.devices(2).contract.scale = 1;
    T.devices(2).contract.polarity = 1;
    T.devices(2).contract.metaFields = metaFields;
    T.devices(2).contract.maps = unit_bc_maps(genericTime);

    T.devices(3).key = 'unit_c';
    T.devices(3).reader = 'reader_dewesoft';
    T.devices(3).dataDir = 'Dewesoft\C10';
    T.devices(3).filePattern = 'Power_*.mat';
    T.devices(3).timeRoleDefault = 'reference';
    T.devices(3).expectedFs = 20000;
    T.devices(3).contract = struct();
    T.devices(3).contract.timeField = 'time_I1';
    T.devices(3).contract.dataFields = {'I1', 'I2', 'I3'; 'U1', 'U2', 'U3'};
    T.devices(3).contract.phaseOrder = {'A', 'B', 'C'};
    T.devices(3).contract.timeSemantics = 'relative_seconds';
    T.devices(3).contract.epoch = '';
    T.devices(3).contract.unit = 'SI';
    T.devices(3).contract.scale = 1;
    T.devices(3).contract.polarity = 1;
    T.devices(3).contract.metaFields = metaFields;
    T.devices(3).contract.maps = unit_bc_maps(genericTime);

    T.channels = struct('key', {}, 'device', {}, 'electricalRole', {}, ...
        'scale', {}, 'polarity', {});
    T.channels(1) = ch('C5', 'unit_a', 'component');
    T.channels(2) = ch('C8', 'unit_a', 'component');
    T.channels(3) = ch('C9', 'unit_a', 'component');
    T.channels(4) = ch('C7', 'unit_b', 'component');
    T.channels(5) = ch('C10', 'unit_c', 'total');
    T.channels(6) = ch('C6', '', 'derived');

    T.edges = {{'voltage_from', 'C8', 'C5'}};

    T.derivations = struct('target', {}, 'terms', {}, 'voltageFrom', {});
    T.derivations(1).target = 'C6';
    T.derivations(1).terms = struct('channel', {'C10', 'C5', 'C7', 'C8', 'C9'}, ...
        'coeff', {1, -1, -1, -1, -1});
    T.derivations(1).voltageFrom = 'C10';

    T.align = struct();
    T.align.searchRangeSec = Inf;
    T.align.needCoarseScan = true;
    T.align.minCorr = 0.95;
    T.align.maxPhaseSpreadSamp = 2;
    T.align.coarseFs = 200;
    T.align.windowSec = 1.0;
    T.align.stepSec = 2.0;
    T.align.searchMs = 9;
    T.align.minGoodFraction = 0.80;
    T.align.coarseMaxLagSec = Inf;
    T.align.autoScan = true;

    T.constants = struct();
    T.constants.f0Nom = 50;
    T.constants.maxHarmOrder = 50;
    T.constants.thdRange = [2 50];
    T.constants.shortWindowCycles = 10;

    T.layout = struct();
    T.layout.finalTemplate = 'final_by_load/{bucket}/{window_id}_{suffix}';
    T.layout.csvTemplate = 'C6_CSV_by_load/{bucket}/{window_id}_{suffix}';
    T.layout.absTemplate = 'C6_CSV_ABS_by_load/{bucket}/{window_id}_{suffix}';
    T.layout.definedNotEnabled = true;
end

function s = ch(key, device, role)
    s = struct('key', key, 'device', device, ...
        'electricalRole', role, 'scale', 1, 'polarity', 1);
end

function maps = unit_a_maps()
    maps = struct();
    maps.C5I.time = 'ch_AI_3_I1_TIME';
    maps.C5I.data = {'ch_AI_3_I1', 'ch_AI_3_I2', 'ch_AI_3_I3'};
    maps.C5I.timeCheck = {'ch_AI_3_I1_TIME', 'ch_AI_3_I2_TIME', 'ch_AI_3_I3_TIME'};
    maps.C5U.time = 'ch_AI_3_I1_TIME';
    maps.C5U.data = {'ch_AI_3_U1', 'ch_AI_3_U2', 'ch_AI_3_U3'};
    maps.C5U.timeCheck = {'ch_AI_3_U1_TIME', 'ch_AI_3_U2_TIME', 'ch_AI_3_U3_TIME'};
    maps.C8I.time = 'ch_AI_1_I1_TIME';
    maps.C8I.data = {'ch_AI_1_I1', 'ch_AI_1_I2', 'ch_AI_1_I3'};
    maps.C8I.timeCheck = {'ch_AI_1_I1_TIME', 'ch_AI_1_I2_TIME', 'ch_AI_1_I3_TIME'};
    maps.C8U = [];
    maps.C9I.time = 'ch_AI_1_I1_TRIONet3_1293_TIME';
    maps.C9I.data = {'ch_AI_1_I1_TRIONet3_1293', ...
        'ch_AI_1_I2_TRIONet3_1293', 'ch_AI_1_I3_TRIONet3_1293'};
    maps.C9I.timeCheck = {'ch_AI_1_I1_TRIONet3_1293_TIME', ...
        'ch_AI_1_I2_TRIONet3_1293_TIME', 'ch_AI_1_I3_TRIONet3_1293_TIME'};
    maps.C9U.time = 'ch_AI_1_I1_TRIONet3_1293_TIME';
    maps.C9U.data = {'ch_AI_1_U1_TRIONet3_1293', ...
        'ch_AI_1_U2_TRIONet3_1293', 'ch_AI_1_U3_TRIONet3_1293'};
    maps.C9U.timeCheck = {'ch_AI_1_U1_TRIONet3_1293_TIME', ...
        'ch_AI_1_U2_TRIONet3_1293_TIME', 'ch_AI_1_U3_TRIONet3_1293_TIME'};
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
