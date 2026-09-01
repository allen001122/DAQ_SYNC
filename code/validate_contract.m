function info = validate_contract(S, contract)
%VALIDATE_CONTRACT  读取前校验。契约对不上就停。
    info = struct('ok', true, 'messages', {{}});
    if ~isfield(contract, 'maps') && ~isfield(contract, 'timeField')
        info.ok = false;
        info.messages{end+1} = 'contract empty';
        return;
    end
    if isfield(contract, 'timeField') && ~isempty(contract.timeField)
        if ~isfield(S, contract.timeField)
            info.ok = false;
            info.messages{end+1} = sprintf('missing timeField %s', contract.timeField);
        end
    end
    if ~info.ok
        error('validate_contract failed: %s', strjoin(info.messages, '; '));
    end
end
