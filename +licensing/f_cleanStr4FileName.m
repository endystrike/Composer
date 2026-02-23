function [cleaned] = f_cleanStr4FileName(dusty)
    del = '/+?\-@:<>*|"`~.;_,=^{}[]()#£$€%';
    del = strcat(del,char("'"));
    cleaned = dusty;
    for k=1:strlength(del)
        cleaned = strrep(cleaned,del(k),'');
    end
    cleaned = deblank(strrep(cleaned,newline,''));
end