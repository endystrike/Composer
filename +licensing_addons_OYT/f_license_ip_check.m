function [check] = f_license_ip_check()
%     try %#ok<*TRYNC>
%         ip = char(extractBetween(webread('https://ipaddress.my/'),'id="ip-address" value="','" readonly />'));
%         check = length(strfind(ip,'.'));
%     end
%     if ~exist('check','var') || check~=3
%         try
%             ip = char(extractBetween(webread('https://api.myip.com'),'"ip":"','","'));
%             check = length(strfind(ip,'.'));
%         end
%         if ~exist('check','var') || check~=3
%             try
%                 ip = char(extractBetween(char(extractBetween(webread('https://whatismyipaddress.com/'),'<span class="address" id="ipv4">','</span><')),'>','<'));
%                 check = length(strfind(ip,'.'));
%             end
%             if ~exist('check','var') || check~=3
%                 try
%                     ip = extractBetween(webread('https://ipapi.co/'),'data-ip="','"'); ip = ip{1};
%                 end
%             end
%         end
%     end

    ip = licensing_addons_OYT.f_get_pub_ip;

    check = length(strfind(ip,'.'))==3 && ~strcmpi(ip,'n/a');
    if check
        %verifica se esiste url
        [ipcry2,online_check] = urlread(['https://licensing.ungeracademy.com/composer/iplic/' ip '.iplic']); %#ok<*URLRD>
        if online_check
            aes = AES('fk9jTPxD4TNqwt35vvrLQtuUW4MCbvWG48RUDJbCTpFfFAJ55JhVmhW5JtTru7ax','SHA-512');
            ipcry = char(aes.encrypt(ip));
            check = strcmp(ipcry,ipcry2);
            if check
                fid = fopen('DefLic.txt','w'); fprintf(fid,'%d',2); fclose(fid);
            end
        else
            check=0;
        end
    end
    clear ip ipcry ipcry2 aes online_check;
end