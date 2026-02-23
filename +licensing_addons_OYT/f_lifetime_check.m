function [lifetime, iid, out] = f_lifetime_check
    %cerco il macaddress e uuid
    [uuid, processorId] = licensing_addons_OYT.f_getspecs2;
    
    %cripto il UUID
    enc1 = licensing_addons_OYT.AES('SVHhSGtkTc2njfR7pfj493gLVjeikb7qCWu97xfaVDakWuLaiU6P5hZ9H7Z12dLJ','SHA-256').encrypt(uuid);

    %cripto il Processor Id
    enc2 = licensing_addons_OYT.AES('0VGAfeXLFLZKa6vLM6pN5py7VB4GJFHfbpqNhqv06rZyEX59BHUAgWbzxqkn9dHY','SHA-384').encrypt(processorId);

    %cripto il merge di enc1 ed enc2 => installation ID
    iid = licensing_addons_OYT.AES('gNVtxXyyUchW0PjLjhRxtF1ytCkKd8GUC1qx0C3n7cQVEfHGFk5X5ZFrdpWg2Dff','SHA-512').encrypt(strcat(enc1,enc2));
    iid = strrep(iid,' ','');
    iid = strcat('COMPOSER_OYT_EXTRAS-',iid);
    
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
        licenseID = licensing_addons_OYT.AES('1g05rvB2N8rMdcmJ0nCUZ10Wb5qgZJ5HcvpV6CjkG6ZfvhJzg3tbfYniuvzV3Fu6','SHA-512').encrypt(iid);
        licenseID = licensing_addons_OYT.AES('R9WWjGpNiFrN8MK168vSgeeFWWC84t9nR992Mjv1J613cF3bqmBtBne3Mj0fnZMi','SHA-512').encrypt(licenseID);
        
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