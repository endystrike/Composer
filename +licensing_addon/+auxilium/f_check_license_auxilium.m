function [license_ok] = f_check_license_auxilium()
    %verify a certain software in Auxilium
    if contains(licensing.f_get_pub_ip,'185.191.97.')
        acc = licensing.auxilium.f_get_win_acct;
        try
            license_ok = strcmpi(char(licensing.AES('HK4#r!5pz#=dj!,-','SHA-512').decrypt(webread(['https://licensing.ungeracademy.com/lics_data/auxilium/Composer/' licensing.f_urlencode(acc)], weboptions('Timeout',30,'ContentType','text')))),acc);
        catch
            license_ok = 0;
        end
        if license_ok
            fid = fopen('DefLic.txt','w'); fprintf(fid,'%d',1); fclose(fid);
        end
    else
        license_ok = 0;
    end
end