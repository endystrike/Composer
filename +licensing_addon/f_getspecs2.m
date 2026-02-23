function [uuid, processorId] = f_getspecs2()
    try
        cmd = 'wmic csproduct get UUID';
        [~, result] = system(cmd);
        fields = textscan(result, '%s', 'Delimiter', '\n' );
        fields = strtrim(fields{1});
        uuid = convertCharsToStrings(fields{2});
    catch
        cmd = 'powershell -Command "(Get-CimInstance -ClassName Win32_ComputerSystemProduct).UUID"';
        [~, result] = system(cmd);
        uuid = string(result(1:end-1));
    end
    clear fields cmd;
    
    try
        cmd = 'wmic cpu get ProcessorId';
        [~, result] = system(cmd);
        fields = textscan( result, '%s', 'Delimiter', '\n' );
        fields = strtrim(fields{1});
        processorId = fields{2};
    catch
        cmd = 'powershell -Command "(Get-CimInstance -ClassName Win32_Processor).ProcessorId"';
        [~, result] = system(cmd);
        processorId = result(1:end-1);
    end
    
    processorId = strrep(processorId,'-','');
    processorId = strrep(processorId,':','');
    processorId = strrep(processorId,'.','');
    processorId = string(processorId);
    clear status result fields cmd;
end