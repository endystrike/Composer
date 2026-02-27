function license_ok = f_check_startup(swSku, swVersion, auxAesKey, auxLicPath)
%F_CHECK_STARTUP Check minimum version and verify license.
%   swSku      - product SKU (e.g. 'ZZ_SW_ZEUS')
%   swVersion  - current software version string (e.g. '5.6.0')
%   auxAesKey  - AES key for Auxilium license check
%   auxLicPath - Auxilium server folder name (e.g. 'Zeus')
%   Returns true only if version is valid and license is active.

    license_ok = false;

    % 1. Check minimum version via server
    try
        response = webread( ...
            sprintf('https://n8n.ungeracademy.com/webhook/sw-check-minver?sw=%s&ver=%s', swSku, swVersion), ...
            weboptions('ContentType','json','Timeout',15));
        versionPass = response.pass;
    catch
        waitfor(errordlg({'Unable to connect to the license server.';' '; ...
            'Please check your internet connection and firewall settings, then try again.'}, ...
            'CONNECTION ERROR'));
        return;
    end

    if ~versionPass
        waitfor(errordlg({'Your software version is outdated: an update is required before proceeding.';' '; ...
            'Please download the latest version from the Unger Academy portal.'}, ...
            'UPDATE REQUIRED'));
        web('https://lms.ungeracademy.com','-browser');
        return;
    end

    % 2. Verify license
    defLic = readDefLicReg();
    switch defLic
        case 0
            license_ok = checkAuxilium(auxAesKey, auxLicPath) || verifyCrmLicense(swSku);
        case 1
            license_ok = checkAuxilium(auxAesKey, auxLicPath);
        otherwise
            license_ok = verifyCrmLicense(swSku);
    end

    if ~license_ok
        waitfor(errordlg({'No active license found for this software.'; ...
            'Please contact Unger Academy support.'}, ...
            'LICENSE ERROR'));
    end
end

%% --- Registry helpers ---

function defLic = readDefLicReg()
    try
        defLic = winqueryreg('HKEY_CURRENT_USER', 'Software\Unger Academy\Softwares', 'default_lic_method');
    catch
        defLic = 0;
    end
end

function writeDefLicReg(value)
    try
        cmd = sprintf('reg add "HKCU\\Software\\Unger Academy\\Softwares" /v default_lic_method /t REG_DWORD /d %d /f', value);
        system([cmd ' >nul 2>&1']);
    catch
    end
end

%% --- Auxilium license check ---

function license_ok = checkAuxilium(aesKey, licPath)
    license_ok = false;
    if ~contains(getPublicIp(), '185.191.97.')
        return;
    end
    acc = getWindowsAccount();
    try
        url = ['https://licensing.ungeracademy.com/lics_data/auxilium/' licPath '/' urlencode(acc)];
        license_ok = strcmpi(char(licensing.AES(aesKey,'SHA-512').decrypt( ...
            webread(url, weboptions('Timeout',30,'ContentType','text')))), acc);
    catch
        license_ok = false;
    end
    if license_ok
        writeDefLicReg(1);
    end
end

function acct = getWindowsAccount()
    [~, acct] = system(char(strcat('powershell -command "$env:username+', "'@'", ',$env:userdnsdomain"')));
    acct = lower(strrep(strrep(deblank(acct),' ',''), newline, ''));
end

function out = urlencode(in)
    out = matlab.net.internal.urlencode(in);
    if ~ischar(out)
        out = char(out);
    end
end

%% --- CRM license check ---

function license_ok = verifyCrmLicense(targetSku)
    license_ok = false;

    BASE_URL  = 'https://crm.ungeracademy.com/api/product-activations';
    CRED_KEY  = 'zh5ga3224qhqu3zqjy4zcqpjkbww4qhkzpe057r2quiq98dj6p8yn14re1k9g7cd';
    HTTP_OPTS = weboptions('MediaType','application/json','ContentType','json','Timeout',30);

    % Load saved credentials and show login dialog
    [savedEmail, savedPwd] = loadSavedCredentials(CRED_KEY);
    [email, password] = licensing.f_crm_login_dialog(savedEmail, savedPwd);
    if email == "" || password == ""
        return;
    end

    % Verify credentials
    try
        response = webwrite([BASE_URL '/verify-license'], ...
            struct('email',email,'password',password), HTTP_OPTS);
    catch
        return;
    end

    if ~isfield(response,'data') || ~isfield(response.data,'valid') || ~response.data.valid
        return;
    end

    % Find a valid license matching target SKU
    foundLicense = findValidLicense(response.data, targetSku);
    if isempty(foundLicense)
        return;
    end

    % Activate license with hardware key
    hardwareKey = generateHardwareKey();
    try
        actResponse = webwrite([BASE_URL '/activate-license'], ...
            struct('email',email,'password',password, ...
                   'licenseKey',foundLicense.licenseKey, ...
                   'hardwareKey',hardwareKey), HTTP_OPTS);
    catch
        return;
    end

    actData = unwrapResponse(actResponse);

    if isfield(actData,'hardwareMismatch') && actData.hardwareMismatch
        return;
    end

    if ~isfield(actData,'activated') || ~actData.activated
        return;
    end

    % Success: persist state
    license_ok = true;
    writeDefLicReg(4);
    saveCredentials(CRED_KEY, email, password);
end

%% --- CRM helper functions ---

function [email, password] = loadSavedCredentials(aesKey)
    email = "";
    password = "";
    try
        encData = winqueryreg('HKEY_CURRENT_USER', 'Software\Unger Academy\Softwares', 'logins_credentials');
        cred = jsondecode(licensing.AES(aesKey, 'SHA-256').decrypt(encData));
        email = string(cred.email);
        password = string(cred.password);
    catch
    end
end

function saveCredentials(aesKey, email, password)
    try
        encCred = char(licensing.AES(aesKey, 'SHA-256').encrypt( ...
            jsonencode(struct('email',email,'password',password))));
        cmd = sprintf('reg add "HKCU\\Software\\Unger Academy\\Softwares" /v logins_credentials /t REG_SZ /d "%s" /f', encCred);
        system([cmd ' >nul 2>&1']);
    catch
    end
end

function foundLicense = findValidLicense(data, targetSku)
    foundLicense = [];
    if ~isfield(data,'licenses')
        return;
    end
    now_utc = datetime('now','TimeZone','UTC');
    for i = 1:numel(data.licenses)
        lic = data.licenses(i);
        if ~isfield(lic,'productSku')
            continue;
        end
        if string(lic.productSku) ~= targetSku
            continue;
        end
        if isfield(lic,'expiryDate') && ~isempty(lic.expiryDate)
            dateStr = regexprep(string(lic.expiryDate), '\.\d+Z$', 'Z');
            expiry = datetime(dateStr,'InputFormat','yyyy-MM-dd''T''HH:mm:ss''Z''','TimeZone','UTC');
            if expiry <= now_utc
                continue;
            end
        end
        foundLicense = lic;
        return;
    end
end

function hwKey = generateHardwareKey()
    [uuid, processorId] = getHardwareSpecs();
    hwKey = char(licensing.AES('chiave','SHA-256').encrypt(strcat(uuid, processorId)));
end

function data = unwrapResponse(response)
    if isfield(response,'data')
        data = response.data;
    else
        data = response;
    end
end

%% --- Hardware / Network utilities ---

function pub_ip = getPublicIp()
    ipapilist = {'https://api.ipify.org','http://ipinfo.io/ip','http://ifconfig.me/ip','http://icanhazip.com','http://ident.me','http://smart-ip.net/myip'};
    for i = 1:length(ipapilist)
        try %#ok<TRYNC>
            pub_ip = strrep(deblank(webread(ipapilist{i}, weboptions('Timeout',10))),' ','');
            if numel(strfind(pub_ip,'.')) == 3 && strlength(pub_ip) >= 7 && strlength(pub_ip) <= 15
                return;
            end
        end
    end
    pub_ip = 'n/a';
end

function [uuid, processorId] = getHardwareSpecs()
    try
        [~, result] = system('powershell -Command "(Get-CimInstance -ClassName Win32_ComputerSystemProduct).UUID"');
        uuid = string(result(1:end-1));
    catch
        [~, result] = system('wmic csproduct get UUID');
        fields = strtrim(textscan(result, '%s', 'Delimiter', '\n'));
        uuid = convertCharsToStrings(fields{1}{2});
    end
    try
        [~, result] = system('powershell -Command "(Get-CimInstance -ClassName Win32_Processor).ProcessorId"');
        processorId = result(1:end-1);
    catch
        [~, result] = system('wmic cpu get ProcessorId');
        fields = strtrim(textscan(result, '%s', 'Delimiter', '\n'));
        processorId = fields{1}{2};
    end
    processorId = strrep(strrep(strrep(processorId,'-',''),':',''),'.','');
    processorId = string(processorId);
end
