if ~isfile('UA_Big.png')
    urlwrite('https://licensing.ungeracademy.com/utils/UA_Big.png','UA_Big.png');
    pause(0.5);
end

%temp license expiration
expdate = '09/07/2020';

%check server licenze e ultima versione raggiungibile...
[srv_min_ver, srv_reachable] = urlread('https://licensing.ungeracademy.com/composer/chk/last_ver.txt'); %#ok<URLRD>

if srv_reachable
    if str2double(t_ver)>=str2double(srv_min_ver)
        license_ok = licensing.auxilium.f_check_license_auxilium || license_check_ip;
        if ~license_ok
            [license_ok, ~, ~] = license_check;
        end
        if license_ok
            clear;
            CodeWriterApp;
        else
            waitfor(newlicense);
            [license_ok, ~, ~] = license_check;
            if license_ok
                clear;
                CodeWriterApp;
            else
                [temp_lic, out] = lic_temp_check(expdate);
                if temp_lic
                    waitfor(msgbox({'Temporary license found ';out},'Alert!'));
                    clear;
                    CodeWriterApp;
                else
                    waitfor(errordlg('The software cannot be lauched: no trial license found. This software will be closed.','License not found!'));
                    clear;
                    exit;
                end
            end
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