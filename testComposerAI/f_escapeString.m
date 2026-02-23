function [escapedText2] = f_escapeString(inputText)
    for k=1:size(inputText,1)
        % Inizializza il testo di uscita come l'input originale
        escapedText = inputText(k,:);
        
        % Sostituisci i caratteri speciali nell'ordine corretto
        escapedText = strrep(escapedText, '\', '\\');
        escapedText = strrep(escapedText, sprintf('\b'), '\b');
        escapedText = strrep(escapedText, sprintf('\f'), '\f');
        escapedText = strrep(escapedText, sprintf('\n'), '\n');
        escapedText = strrep(escapedText, sprintf('\r'), '\r');
        escapedText = strrep(escapedText, sprintf('\t'), '\t');
        escapedText = strrep(escapedText, '"', '\"');
        
        % Assicurati che l'output sia un char vector
        escapedText = char(escapedText);
    
        if k>1
            escapedText2 = strcat(escapedText2, '\n', escapedText);
        else
            escapedText2 = escapedText;
        end
    end
end