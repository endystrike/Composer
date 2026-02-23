function [acct_dom] = f_get_win_acct()
    [~, acct_dom] = system(char(strcat('powershell -command "$env:username+',"'@'+",'$env:userdnsdomain"')));
    acct_dom = lower(strrep(strrep(deblank(acct_dom),' ',''),newline,''));
end