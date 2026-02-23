clear;

[unescapedText] = escape_string_gui();

clc;
token = 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzNjI2MDQiLCJmaXJzdF9uYW1lIjoidGhvcmFuIiwibGFzdF9uYW1lIjoicmVxdWlyZWQiLCJlbWFpbCI6InRyYWRpbmdAdGhvcmFuLmNvbSIsImlhdCI6MTcxMjIxOTc2OSwiZXhwIjoxODEyMzA2MTY5LCJ0YWdzIjpbIjEyMiIsIjIxOCIsIjI0MiIsIjI0NCIsIjI0NiIsIjI0OCIsIjI1MCIsIjI1MiIsIjI1NCIsIjI1NiIsIjM0OCIsIjQ0MiIsIjUzNCIsIjUzNiIsIjUzOCIsIjU0MCIsIjU0MiIsIjU0NiIsIjU0OCIsIjU3MCIsIjU4MiIsIjU5NCIsIjU5NiIsIjU5OCIsIjYxNCIsIjYxNiIsIjYxOCIsIjYyMCIsIjYzMCIsIjYzOCIsIjY3OCIsIjY4NCIsIjY5MCIsIjcxOCIsIjcyMCIsIjcyMiIsIjcyNiIsIjcyOCIsIjc4MiIsIjgzNCIsIjg3NCIsIjk0NCIsIjk2OCIsIjk3MiIsIjk3NCIsIjk3NiIsIjk4MiIsIjEyNTQiLCIxMjc2IiwiMTI5MCIsIjEyOTIiLCIxMzAyIiwiMTMwNCIsIjEzMDYiLCIxMzI2IiwiMTM1OCIsIjEzNjYiLCIxNDE0IiwiMTQ0NCIsIjE0NTYiLCIxNDU4IiwiMTQ2MCIsIjE0NjIiLCIxNDY0IiwiMTUxNCIsIjE1MTYiLCIxNzA4IiwiMTcxOCIsIjE3MzYiLCIxODMwIiwiMjAwNCIsIjIwNTAiLCIyMDk0IiwiMjA5OCIsIjIxMDIiLCIyMTA2IiwiMjExMCIsIjIxMjYiLCIyMjE0IiwiMjIxOCIsIjIyNTYiLCIyMjY2IiwiMjMwNiIsIjIzMDgiLCIyMzEwIiwiMjMxMiIsIjIzMjIiLCIyMzI0IiwiMjMzMCIsIjIzMzIiLCIyMzM4IiwiMjM0MCIsIjI1MjQiLCIyNTU4IiwiMjU2MiIsIjI1NjYiLCIyNTc2IiwiMjU4NCIsIjI2MDIiLCIyNjIwIiwiMjY2OCIsIjI2ODgiLCIyNjk0IiwiMjY5NiIsIjI3MDgiLCIyNzUyIiwiMjc1NCIsIjI3NzAiLCIyNzg0IiwiMjgwNCIsIjI5OTQiLCIyOTk2IiwiMzAzMiIsIjMwMzgiLCIzMDQwIiwiMzA5NiIsIjMxMDAiLCIzMTA0IiwiMzE3MiIsIjMzMjAiLCIzMzI2IiwiMzQyNCIsIjM0MzYiLCIzNTUwIiwiMzU3MCIsIjM2MDEiLCIzNjM5IiwiMzcwMyIsIjQwOTkiLCI0MTAxIiwiNDI4NyIsIjUyODYiLCI1MzU1IiwiNTM1NyIsIjU1ODIiLCI1NTg2IiwiNTczMiIsIjU4NTAiLCI1ODUyIiwiNTkwMCIsIjU5OTQiLCI2MzMwIiwiNzEwMiIsIjcxMjQiXSwiaXNzIjoidW5nZXJhY2FkZW15LmNvbSJ9.ZcDdkC6mJENR9FqgNmNoPn2YI_0nmDg0Rz0Hc9mDT40';
escaped = f_escapeString(unescapedText);
chatID = ['COMPOSERAI-' num2str(posixtime(datetime('now'))*1000, '%.6f') '-' num2str(randi([1, 10000]))];
data = struct( ...
    'chatId', chatID, ...
    'prompt', escaped, ...
    'promptTemplate', 'composerai' ...
);

% URL dell'API
url = 'https://api-test.ungeracademy.com/chats';

% fai la domanda a Warren
options = weboptions( ...
    'HeaderFields', { ...
        'Authorization', token; ...
        'Content-Type', 'application/json' ...
    }, ...
    'Timeout',30 ...
);
response = webwrite(url, data, options);
options = weboptions( ...
    'HeaderFields', { ...
        'Authorization', token ...
    },...
    'Timeout',30 ...
);

% Fai fetch della risposta e merge dei chunks
%tic
for k=1:20
    reply = webread(strcat(url,'?page=1&pagesize=1&filter={"chatId": "',chatID,'"}'),options);
    if isfield(reply,'status') && strcmpi(reply.status,'complete')
        break;
    end
    pause(3);
end
%toc

chunks = reply.chunks;
combinedChunks = '';
for i = 1:length(chunks)
    combinedChunks = [combinedChunks, chunks{i}];
end
disp(combinedChunks);