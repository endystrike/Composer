function [email, password] = f_crm_login_dialog(savedEmail, savedPassword)
%F_CRM_LOGIN_DIALOG Dialog modale email+password per verifica licenza CRM.
%   Se vengono passate credenziali salvate, precompila i campi.
%   Ritorna [email, password] o stringhe vuote se annullato.

    email = "";
    password = "";
    confirmed = false;
    hasSaved = nargin >= 2 && savedEmail ~= "" && savedPassword ~= "";

    fig = uifigure('Name','Unger Academy - License Verification','Position',[100 100 400 250],...
        'Resize','off','CloseRequestFcn',@closeFig,'WindowStyle','modal');

    uilabel(fig,'Text','Email:','Position',[30 170 80 22]);
    emailField = uieditfield(fig,'text','Position',[120 170 250 22]);

    uilabel(fig,'Text','Password:','Position',[30 130 80 22]);
    pwdField = uieditfield(fig,'text','Position',[120 130 250 22]);
    realPassword = '';
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
        oldLen = length(realPassword);
        newLen = length(newVal);
        if newLen > oldLen
            added = newVal(oldLen+1:end);
            realPassword = [realPassword added];
        elseif newLen < oldLen
            realPassword = realPassword(1:newLen);
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
