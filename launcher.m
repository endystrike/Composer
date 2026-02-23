if ~exist('UA_Big.png','file')
    urlwrite('https://licensing.ungeracademy.com/utils/UA_Big.png','UA_Big.png');
    pause(0.5);
end

%check server licenze e ultima versione raggiungibile...
try
    srv_min_ver = str2double(webread('https://licensing.ungeracademy.com/composer/chk/last_ver.txt', weboptions('ContentType','text')));
catch
    srv_min_ver = 99999;
end

if srv_min_ver<99999
    if str2double(t_ver)>=srv_min_ver
        defLic = licensing.f_lic_checkDefault;
        switch defLic
            case 0
                license_ok = licensing.auxilium.f_check_license_auxilium || licensing.f_license_ip_check || licensing.f_lic_fromRootCheckLifetimeorNewReq;
            case 1
                license_ok = licensing.auxilium.f_check_license_auxilium;
            case 2
                license_ok = licensing.f_license_ip_check;
            case 3
                license_ok = licensing.f_lic_fromRootCheckLifetimeorNewReq;
        end
        
        if license_ok
            GUImode = 1;
            CodeWriterApp;
        else
            waitfor(errordlg(["It seems you don't have an active license for this software."; "Please contact Unger Academy staff"],...
                'MISSING LICENSE!'));
        end
    else
        waitfor(errordlg({"You're not using the most recent version of this software: update is mandatory before proceeding!"},...
            'UPDATE MANDATORY!'));
        web('https://learn.ungeracademy.com','-browser');
        clear;
        exit;
    end
else
    waitfor(errordlg({"Cannot connect to the license server...";" ";...
        "Please try the following solutions:";...
        '- add Composer.exe to your antivirus exceptions';
        '- add Composer.exe as exception to your firewall';
        '- check your internet connection.'},...
        'INTERNET CONNECTION ERROR!'));
    clear;
    exit;
end