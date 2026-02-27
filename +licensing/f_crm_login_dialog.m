function [email, password] = f_crm_login_dialog(savedEmail, savedPassword)
%F_CRM_LOGIN_DIALOG Dialog modale email+password per verifica licenza CRM.
%   Se vengono passate credenziali salvate, precompila i campi.
%   Ritorna [email, password] o stringhe vuote se annullato.

    email = "";
    password = "";
    confirmed = false;
    hasSaved = nargin >= 2 && savedEmail ~= "" && savedPassword ~= "";

    fig = uifigure('Name','Unger Academy - License Verification','Position',[100 100 400 290],...
        'Resize','off','CloseRequestFcn',@closeFig,'WindowStyle','modal');

    uilabel(fig,'Text','Please insert in the fields below the credentials you use on lms.ungeracademy.com',...
        'Position',[30 230 340 40],'WordWrap','on');

    uilabel(fig,'Text','Email:','Position',[30 190 80 22]);
    emailField = uieditfield(fig,'text','Position',[120 190 250 22]);

    uilabel(fig,'Text','Password:','Position',[30 150 80 22]);
    pwdField = uieditfield(fig,'text','Position',[120 150 250 22]);
    realPassword = '';
    pwdDirty = false;
    pwdField.ValueChangingFcn = @onPwdChanging;

    uibutton(fig,'push','Text','Login','Position',[120 70 150 35],...
        'ButtonPushedFcn',@onVerify);

    % Precompila campi se ci sono credenziali salvate
    if hasSaved
        emailField.Value = char(savedEmail);
        realPassword = char(savedPassword);
        pwdField.Value = repmat('*', 1, length(realPassword));
    end

    waitfor(fig);

    function onPwdChanging(~, evt)
        newVal = char(evt.Value);

        if hasSaved && ~pwdDirty
            % Prima modifica su campo pre-compilato: svuota tutto e
            % riparti da zero cosi' l'utente ridigita la nuova password
            pwdDirty = true;
            realPassword = '';
            pwdField.Value = '';
            return;
        else
            oldLen = length(realPassword);
            newLen = length(newVal);
            if newLen > oldLen
                realPassword = [realPassword newVal(oldLen+1:end)];
            elseif newLen < oldLen
                realPassword = realPassword(1:newLen);
            end
        end

        pwdField.Value = repmat('*', 1, length(realPassword));
    end

    function onVerify(~,~)
        email = string(emailField.Value);
        password = string(realPassword);
        confirmed = true;
        closeFig();
    end

    function closeFig(~,~)
        if ~confirmed
            email = "";
            password = "";
        end
        delete(fig);
    end
end
