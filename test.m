clf; close all; 
a = figure('units','normalized','outerposition',[.25 .25 .5 .5]);
title('Trigger example');
chrt = imread('extras\highs1lows1rev.jpg');
imshow(chrt,'Border','tight');
hold on;
disableDefaultInteractivity(gca);
a.ToolBar = 'no';
a.MenuBar = 'no';

[file,name,path] = uiputfile('*.txt','Save script...',['UAturboDevelop' '.txt']);
if path==1
    websa
    
    ff = websave([name file], ['https://learn.ungeracademy.com/documents/CodeWriter/UATrendDeveloper.txt']);