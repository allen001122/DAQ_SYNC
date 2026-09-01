function [t_out, X_out, info] = nearest_pick(t_ref, t_src, X_src)
%NEAREST_PICK  在 t_src 上为 t_ref 的每个时刻选取时间最近的样本
%
%   输入:
%     t_ref  - 参考时间轴 (N×1)，通常为 C10 校正后时间
%     t_src  - 源设备时间轴 (M×1)
%     X_src  - 源数据 (M×C)，C 为通道数（如三相）
%
%   输出:
%     t_out  - 与 t_ref 等长的时间（取自 t_src 被选中的点）
%     X_out  - 对应的数据 (N×C)，全部为原始采样值，无插值
%     info   - 统计信息
%         .residual_us   : 每个点的时间残差 (us)
%         .max_abs_us    : 最大绝对残差
%         .rms_us        : 残差 RMS
%         .idx           : 选中的源下标

    t_ref = t_ref(:);
    t_src = t_src(:);
    if size(X_src, 1) ~= numel(t_src)
        error('nearest_pick: X_src 行数 (%d) 与 t_src 长度 (%d) 不一致', ...
            size(X_src, 1), numel(t_src));
    end
    if numel(t_ref) < 2 || numel(t_src) < 2
        error('nearest_pick: 时间轴过短');
    end
    if any(diff(t_ref) <= 0)
        error('nearest_pick: t_ref 必须严格递增');
    end
    if any(diff(t_src) <= 0)
        error('nearest_pick: t_src 必须严格递增');
    end

    % 向量化最近邻：用 interp1 的 nearest 模式取下标
    % 先把源下标映射到时间，再反查
    idx = interp1(t_src, (1:numel(t_src))', t_ref, 'nearest', 'extrap');
    idx = max(1, min(numel(t_src), round(idx)));

    t_out = t_src(idx);
    X_out = X_src(idx, :);

    residual_s  = t_out - t_ref;
    residual_us = residual_s * 1e6;

    info = struct();
    info.residual_us = residual_us;
    info.max_abs_us  = max(abs(residual_us));
    info.rms_us      = sqrt(mean(residual_us.^2));
    info.idx         = idx;
    info.n           = numel(t_ref);
end
