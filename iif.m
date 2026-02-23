function [result] = iif(Cond,T,F)
    if Cond
        result = T;
    else
        result = F;
    end
end

