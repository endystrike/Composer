function [lifetime, iid, out] = f_lifetime_check
    %cerco il macaddress e uuid
    [uuid, processorId] = licensing_addon.f_getspecs2;
    
    %cripto il UUID
    enc1 = licensing_addon.AES('eDJsl0wBYfamhoNYiyuzi6HUY5X0CLaHkNc6mglVqbZh2J7t8NkugGyZK1tz90Jl','SHA-256').encrypt(uuid);

    %cripto il Processor Id
    enc2 = licensing_addon.AES('JpTJzxsocBb8HTGe3wnikL70sZejKfctsBQ32ble9i8affLxSy9K1sSkufR2Qh79','SHA-384').encrypt(processorId);

    %cripto il merge di enc1 ed enc2 => installation ID
    iid = licensing_addon.AES('MJymFW6H4chZXKeTILKxcnkGyZWYzxkKg8FzSNjntatCRB61wHsRRACJDDyIoeMX','SHA-512').encrypt(strcat(enc1,enc2));
    iid = strrep(iid,' ','');
    iid = strcat('ATF5ENGINES-',iid);
    
    try %verifico se attivata in automatico
        online_lic = webread(['https://licensing.ungeracademy.com/lics_data/auto/' char(licensing_addon.f_cleanStr4FileName(iid))],weboptions('ContentType','text'));
    catch
        online_lic = 'N/A';
    end
      
    if strcmpi(online_lic,'N/A') %verifico se è una 2° licenza
        try
            online_lic = webread(['https://licensing.ungeracademy.com/lics_data/extras/' char(licensing_addon.f_cleanStr4FileName(iid))],weboptions('ContentType','text'));
        catch
            online_lic = 'N/A';
        end
    end
    
    %procedo al controllo della chiave nel file
    if ~strcmpi(online_lic,'N/A')
        %genero la licenza sulla base dell'installation ID
        licenseID = licensing_addon.AES('x8DUwvjUjTPZNj7a2loEXG4MOqKs4At60xZCqrxpAUfpES9vuNsd0NQmnh0KXgyv','SHA-512').encrypt(iid);
        licenseID = licensing_addon.AES('xsNdxYRCBsygJeA3D1EMNAkLR2tD1qKHi0lHQGmNTr3QQ5oZlX34ZGIjMW1iUUhZ','SHA-512').encrypt(licenseID);
        
        lifetime = strcmp(licenseID,online_lic);
        if lifetime
            out = 'License key is valid.';
        else
            out = 'Invalid license key. You need to contact Unger Academy staff.';
        end
    else
        lifetime = 0;
        out = 'Cannot find your license. Please contact Unger Academy staff.';
    end
end