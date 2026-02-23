function [lifetime, iid, out] = f_lifetime_check
    %cerco il macaddress e uuid
    [uuid, processorId] = licensing_addons_AI.f_getspecs2;
    
    %cripto il UUID
    enc1 = licensing_addons_AI.AES('nXi4pT9Y5CiuhR932N0ECBieCGf1mwxe7KQMKA6HQN5UUNmkwKRyrx0FcZnTGNkW','SHA-256').encrypt(uuid);

    %cripto il Processor Id
    enc2 = licensing_addons_AI.AES('tpU0NXYxNeJYwj88SqWFzgUZuhDc7F9fwGVxDTVEufW7Y5r3yDAjNknGTzcKUgRu','SHA-384').encrypt(processorId);

    %cripto il merge di enc1 ed enc2 => installation ID
    iid = licensing_addons_AI.AES('CGNAQW2igGdbzqzm7p1gjqRC4nH2Jk8fFNkRgeAj1w1e1iz9eZyqnwafk4qw1br6','SHA-512').encrypt(strcat(enc1,enc2));
    iid = strrep(iid,' ','');
    iid = strcat('COMPOSER_AI_EXTRAS-',iid);
    
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
        licenseID = licensing_addons_AI.AES('3B4zeYFrPwYZ1LWWvKWK2JfeKSPNt6qhc5F3KP7ak0BnK7TmHDGruZyzEuYkGrQb','SHA-512').encrypt(iid);
        licenseID = licensing_addons_AI.AES('cEpWjzBTE4182KjqUBDZ0ZJm5gwGyNEEGC7BXHBcwLHGizHwKBwrWb435VtWimG4','SHA-512').encrypt(licenseID);
        
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