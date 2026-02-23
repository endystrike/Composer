function [out] = f_lic_checkDefault()
    if exist('DefLic.txt','file')
        fid = fopen('DefLic.txt','r');
        out = textscan(fid,'%f');
        out = cell2mat(out);
        fclose(fid);
    else
        out = 0;
    end
end

