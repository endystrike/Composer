function [lifetime, iid, out] = f_lifetime_check
    %cerco il macaddress e uuid
    [uuid, processorId] = licensing.f_getspecs2;
    
    %cripto il UUID
    enc1 = licensing.AES('EzwgPJq7Bw8RrLgc4kYE4XuZgqwNUSLbL89vagPEpM3hbMB3SdBFhMRJ3wMjTMh3','SHA-256').encrypt(uuid);

    %cripto il Processor Id
    enc2 = licensing.AES('iCmA3Q9hmk4fcEP9hSPehZJAB9UPidZd3gSZprphFYaSR6LCiY86H94UVuRgugrY','SHA-384').encrypt(processorId);

    %cripto il merge di enc1 ed enc2 => installation ID
    iid = licensing.AES('u97uYiV7NYLfrxmWdWuR84h2Tp3GvXPk7rjJMBFyHZNdHf8q8urBeCJUgiJxHArn','SHA-512').encrypt(strcat(enc1,enc2));
    iid = strrep(iid,' ','');
    iid = strcat('UACOMPOSER-',iid);
    
    try %verifico se attivata in automatico
        online_lic = webread(['https://licensing.ungeracademy.com/lics_data/auto/' char(licensing.f_cleanStr4FileName(iid))],weboptions('ContentType','text'));
    catch
        online_lic = 'N/A';
    end
      
    if strcmpi(online_lic,'N/A') %verifico se è una 2° licenza
        try
            online_lic = webread(['https://licensing.ungeracademy.com/lics_data/extras/' char(licensing.f_cleanStr4FileName(iid))],weboptions('ContentType','text'));
        catch
            online_lic = 'N/A';
        end
    end
    
    %procedo al controllo della chiave nel file
    if ~strcmpi(online_lic,'N/A')
        %genero la licenza sulla base dell'installation ID
        licenseID = licensing.AES('EarXGPBaABrfqi4JDKGJp8XvUF5RNxQ79zBEa7TPrQaXkgDzVAuSMubSDt8aA2pV','SHA-512').encrypt(iid);
        licenseID = licensing.AES('egNfTqFLybVEFVkZSLiqmpXvBjvKA2FbGMBQGnngcD9kuPQFbpNC6WJMVUWyv65w','SHA-512').encrypt(licenseID);
        
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