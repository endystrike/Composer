function [lifetime, iid, out] = license_check
    licensefile = 'licensekey.txt';

    if exist(licensefile,'file')   %check licenza da file
        fid = fopen(licensefile,'r');
        userlicense = textscan(fid,'%s');
        userlicense = userlicense{1};
        fclose(fid);
    else
        userlicense = 'none';
    end

    %cerco il macaddress e uuid
    [ uuid, processorId ] = getspecs2;
    processorId = strrep(processorId,'-','');
    processorId = strrep(processorId,':','');
    processorId = strrep(processorId,'.','');
    
    %cripto il UUID
    aes = AES('EzwgPJq7Bw8RrLgc4kYE4XuZgqwNUSLbL89vagPEpM3hbMB3SdBFhMRJ3wMjTMh3','SHA-256');
    enc1 = aes.encrypt(uuid);

    %cripto il Processor Id
    aes = AES('iCmA3Q9hmk4fcEP9hSPehZJAB9UPidZd3gSZprphFYaSR6LCiY86H94UVuRgugrY','SHA-384');
    enc2 = aes.encrypt(processorId);

    %cripto il merge di enc1 ed enc2 => installation ID
    aes = AES('u97uYiV7NYLfrxmWdWuR84h2Tp3GvXPk7rjJMBFyHZNdHf8q8urBeCJUgiJxHArn','SHA-512');
    iid = aes.encrypt(strcat(enc1,enc2));
    iid = strrep(iid,' ','');
    iid = strcat('UACOMPOSER',iid);
    
    %controllo che non sia stata bannata l'IID
    lifetime = lic_ban_check(iid);
    if ~lifetime
        out = "License has been revoked. You need to contact Unger Academy staff.";
    end
    
    %controllo se è attivata online
    if lifetime
        lifetime = (lifetime * lic_check_online(iid))==1;
        if ~lifetime
            out = "Your license has been revoked or has not yet been activated. Check your internet connection and firewall rules. Please wait for activation from UA Staff or send an email to licensing@ungeracademy.com"; 
        end
    end

    
    %procedo al controllo della chiave nel file, solo se non era stata bannata
    if lifetime
        if isfile(licensefile)    
            %genero la licenza sulla base dell'installation ID
            aes = AES('EarXGPBaABrfqi4JDKGJp8XvUF5RNxQ79zBEa7TPrQaXkgDzVAuSMubSDt8aA2pV','SHA-512');
            licenseID = aes.encrypt(iid);

            aes = AES('egNfTqFLybVEFVkZSLiqmpXvBjvKA2FbGMBQGnngcD9kuPQFbpNC6WJMVUWyv65w','SHA-512');
            licenseID = aes.encrypt(licenseID);

            lifetime = strcmp(licenseID,userlicense);
            if lifetime
                out = 'License key is valid.';
            else
                out = 'Invalid license key. You need to contact Unger Academy staff.';
            end
        else
            lifetime = 0;
            out = 'Invalid license key. You need to contact Unger Academy staff.';
        end
    end
    
    %pulizia vars
    clear fid aes enc1 enc2 licenseID processorId uuid;
end