function varargout = newlicense(varargin)
% NEWLICENSE MATLAB code for newlicense.fig
%      NEWLICENSE, by itself, creates a new NEWLICENSE or raises the existing
%      singleton*.
%
%      H = NEWLICENSE returns the handle to a new NEWLICENSE or the handle to
%      the existing singleton*.
%
%      NEWLICENSE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NEWLICENSE.M with the given input arguments.
%
%      NEWLICENSE('Property','Value',...) creates a new NEWLICENSE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before newlicense_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to newlicense_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help newlicense

% Last Modified by GUIDE v2.5 23-Jan-2020 03:15:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @newlicense_OpeningFcn, ...
                   'gui_OutputFcn',  @newlicense_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before newlicense is made visible.
function newlicense_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to newlicense (see VARARGIN)

% Choose default command line output for newlicense
handles.output = hObject;
axes = handles.UA_Logo;
imshow('UA_Big.png');
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes newlicense wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = newlicense_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function UA_Logo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to UA_Logo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate UA_Logo
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function newlic_CreateFcn(hObject, eventdata, handles)
% hObject    handle to newlic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function iid_show_CreateFcn(hObject, eventdata, handles)
[~,iid,~] = license_check;
setappdata(0,'iid',iid);
iid_show = findobj(0, 'tag', 'iid_show');
set(iid_show,'string',iid);
% hObject    handle to iid_show (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
%guidata(hObject, handles);

function ul_Callback(hObject, eventdata, handles)
% hObject    handle to ul (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ul as text
%        str2double(get(hObject,'String')) returns contents of ul as a double

% --- Executes on button press in lic_confirm.
function lic_confirm_Callback(hObject, eventdata, handles)
% hObject    handle to lic_confirm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
userlicense = get(handles.ul,'string');
lf = 'licensekey.txt';
if isfile(lf)
    delete(lf);
end
fid = fopen(lf,'w');
fprintf(fid,'%s',userlicense);
fclose(fid);

[ lifetime, ~, out] = license_check;
if lifetime
    waitfor(msgbox({'Your license has been activated successfully!'},'Titan'));
    closereq
else
    waitfor(errordlg(out,'Error'));
end

% --- Executes on button press in quit.
function quit_Callback(hObject, eventdata, handles)
closereq
% hObject    handle to quit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in iid_send.
function iid_send_Callback(hObject, eventdata, handles)
% hObject    handle to iid_send (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in iid_write.
function iid_write_Callback(hObject, eventdata, handles)
try
    iid = getappdata(0,'iid');
end

iidf = 'YourIID.txt';
if isfile(iidf)
    delete(iidf);
end

fid = fopen(iidf,'w');
fprintf(fid,'%s',iid);
fclose(fid);
waitfor(msgbox({"Please send to Unger Academy staff your 'YourIID.txt' file. You can find it in Titan's folder"},'Your IID file!'));

% hObject    handle to iid_write (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
