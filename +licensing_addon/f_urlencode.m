function [out] = f_urlencode(in)
    out = matlab.net.internal.urlencode(in);
    if ~ischar(out)
        out = char(out);
    end
end

