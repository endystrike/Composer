function [uuid, processorId] = getspecs2()
    cmd = 'wmic csproduct get UUID';
    [~, result] = system(cmd);    
    fields = textscan(result, '%s', 'Delimiter', '\n' ); 
    fields = strtrim(fields{1});
    uuid = convertCharsToStrings(fields{2});
    clear fields cmd;

    cmd = 'wmic cpu get ProcessorId';
    [~, result] = system(cmd);    
    fields = textscan( result, '%s', 'Delimiter', '\n' ); 
    fields = strtrim(fields{1});
    processorId = fields{2};
    clear status result fields cmd;
end