function [out] = chg_last_coma_semicolumn(in)
    %CHG_LAST_COMA_SEMICOLUMN Summary of this function goes here
    out=in;
    a = in(end);
    a = char(a);
    a(end) = ';';
    out(end) = string(a);
    out = [out '\n'];
end

