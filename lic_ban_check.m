function [unbanned] = lic_ban_check(iid)
    %aggiungere gli IID da bannare (es. vecchi pc dei clienti)
    ban_list = {'none';'none2'};
    unbanned = sum(strcmp(iid,ban_list))==0;
end