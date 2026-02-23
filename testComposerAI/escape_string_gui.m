function [unescapedText] = escape_string_gui()
    % Crea una finestra di dialogo per inserire il testo
    prompt = {'Inserisci il testo da formattare:'};
    dlgtitle = 'Input';
    dims = [10 50];
    definput = {''};
    inputText = inputdlg(prompt, dlgtitle, dims, definput);

    % Verifica se l'utente ha inserito del testo
    if isempty(inputText)
        return;
    end

    % Esegui l'escape del testo inserito
    unescapedText = inputText{1};

    % Mostra il risultato in una finestra di dialogo
    %msgbox(escapedText, 'Testo Formattato');
end