function varargout = PanelOwis(varargin)
% PANELOWIS MATLAB code for PanelOwis.fig
%      PANELOWIS, by itself, creates a new PANELOWIS or raises the existing
%      singleton*.
%
%      H = PANELOWIS returns the handle to a new PANELOWIS or the handle to
%      the existing singleton*.
%
%      PANELOWIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PANELOWIS.M with the given input arguments.
%
%      PANELOWIS('Property','Value',...) creates a new PANELOWIS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PanelOwis_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PanelOwis_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PanelOwis

% Last Modified by GUIDE v2.5 02-Aug-2024 16:03:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PanelOwis_OpeningFcn, ...
                   'gui_OutputFcn',  @PanelOwis_OutputFcn, ...
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


% --- Executes just before PanelOwis is made visible.
function PanelOwis_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PanelOwis (see VARARGIN)




%loadlibrary('ps35')                                                         %%%%%%%Carga la libreria PS35 de Owis. loadlibrary()es una función de Matlab
                                                                            %%%%%%%La carpeta del archivo PanelOwis.m debe contener el archivo ps35.h
handles.movY = str2double(get(handles.edit1,'Value'));
handles.movX = str2double(get(handles.edit2,'Value'));
                                                                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handles.movYF = str2double(get(handles.slider1,'Value'));                   %%%%%%% handles.name es una variable global. Es necesario crear una por cada
handles.movXF = str2double(get(handles.slider2,'Value'));                   %%%%%%% boton interactivo. Esto es importante para la lógica y código 
                                                                            %%%%%%% PanelOwis.m. Note que, handles.edit y handles.pushbutton son el name
handles.puertoCOM = str2double(get(handles.edit5,'Value'));                 %%%%%%% de cada editor de texto y boton interactivo del PanelOwis.fig 
                                                                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handles.changeVel_X = str2double(get(handles.edit4,'Value'));               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handles.changeVel_Y = str2double(get(handles.edit3,'Value'));

handles.ejeX = str2double(get(handles.edit6,'Value'));
handles.ejeY = str2double(get(handles.edit7,'Value'));

handles.StepSize = str2double(get(handles.edit10,'Value'));
handles.nCase = str2double(get(handles.edit9,'Value'));

handles.NumLineas = str2double(get(handles.edit12,'Value'));
handles.DXdots = str2double(get(handles.edit13,'Value'));
handles.DYdots = str2double(get(handles.edit14,'Value'));
handles.fTrain = str2double(get(handles.edit15,'Value'));
handles.nDut = str2double(get(handles.edit16,'Value'));


handles.img=get(handles.pushbutton4,'Value');
handles.Im=get(handles.pushbutton9,'Value');


handles.xhome = str2double(get(handles.pushbutton5,'Value'));
handles.yhome = str2double(get(handles.pushbutton5,'Value'));




% Choose default command line output for PanelOwis

handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PanelOwis wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = PanelOwis_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

movYF = str2double(get(hObject,'String'));   % Esta variable es para entregar el valor del slider al cuadro de texto
%set(handles.text5,'String',movYF); % esta linea setea el valor al cuadro de texto

handles.movYF = movYF;                              %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
guidata (hObject, handles);                         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                    %%%%%La función slider1_Callbackes la barra de movimiento del archivo PanelOwis.fig 
                                                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            in1 = handles.puertoCOM;
            in2Y=handles.ejeY;
            in3Y = handles.changeVel_Y;
            in4Y=handles.movY + handles.movYF;
            in4YS=sprintf('%.6f',in4Y);
            set(handles.text5,'String',in4YS);

            in5=0;
     

retvalY = ps35toolY( in1, in2Y, in3Y, in4Y, in5 );                 %Se llama a la función ps35toolY para ordenar el movimiento del motor Y


guidata(hObject,handles);                                         %guidata(hObject,handles) es necesaria para crear a las variables handles.name globales
                                                                  % siempre debe exitir para el correcto funcionamiento de PanelOwis
                                                                  
% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

movXF = str2double(get(hObject,'String'));   % Esta variable es para entregar el valor del slider al cuadro de texto
%set(handles.text5,'String',movXF); % esta linea setea el valor al cuadro de texto

handles.movXF = movXF;
guidata (hObject, handles);

            in1 = handles.puertoCOM;

            in2X =handles.ejeX;
            %in2Y=handles.ejeY;
            %in3Y = handles.changeVel_Y;
            in3X = handles.changeVel_X;
            %in4Y=handles.movY + handles.movYF;
            in4X=handles.movX + handles.movXF;
            in4XS=sprintf('%.6f',in4X);
            set(handles.text6,'String',in4XS);
            in5=0;
      

retvalX = ps35toolX( in1, in2X, in3X, in4X, in5 );



% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double

movY = str2double(get(hObject,'String'));   % Esta variable es para entregar el valor del slider al cuadro de texto
set(handles.text5,'String',movY); % esta linea setea el valor al cuadro de texto

handles.movY = movY;

guidata (hObject, handles);





% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double

movX = str2double(get(hObject,'String'));   % Esta variable es para entregar el valor del slider al cuadro de texto
set(handles.text6,'String',movX); % esta linea setea el valor al cuadro de texto

handles.movX = movX;

guidata (hObject, handles);




% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

            in1 = handles.puertoCOM;

            in2X =handles.ejeX;
            in2Y=handles.ejeY;
            in3Y = handles.changeVel_Y;
            in3X = handles.changeVel_X;
            in4Y=handles.movY;
            in4X=handles.movX;
            in5=0;
      
                
retvalY = ps35toolY( in1, in2Y, in3Y, in4Y, in5 );

retvalX = ps35toolX( in1, in2X, in3X, in4X, in5 );


guidata (hObject, handles);




function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double

changeVel_Y = str2double(get(hObject,'String'));

handles.changeVel_Y = 10*changeVel_Y;

guidata (hObject, handles);




% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


changeVel_X = str2double(get(hObject,'String'));

handles.changeVel_X = 10*changeVel_X;

guidata (hObject, handles);




% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function text5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double

puertoCOM = str2double(get(hObject,'String'));

handles.puertoCOM = puertoCOM;

guidata (hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double

ejeX = str2double(get(hObject,'String'));

handles.ejeX = ejeX;

guidata (hObject, handles);





% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double

ejeY = str2double(get(hObject,'String'));

handles.ejeY = ejeY;

guidata (hObject, handles);





% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDAT

DAQstate('false');
calllib('ps35','PS35_MotorOff', 1,handles.ejeX);
calllib('ps35','PS35_MotorOff', 1, handles.ejeY);

calllib('ps35','PS35_Disconnect',1);

unloadlibrary ps35




% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%[filename, pathname] = uigetfile('.png','All Files(".")');



[filename, path]= uigetfile('.png','All Files(".")');

imagen =strcat(path,filename);


img=imread(imagen);

handles.img=img;


imshow(img,'Parent',handles.axes1)


guidata(hObject,handles);



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double

nCase = str2double(get(hObject,'String'));

handles.nCase = nCase;

guidata (hObject, handles);




% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double

StepSize = str2double(get(hObject,'String'));   % Esta variable es para entregar el valor del slider al cuadro de texto

handles.StepSize = StepSize;

guidata (hObject, handles);




% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton5.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%                                                               %%%%%%
%%%%%%                                                               %%%%%%
%%%%%%                                                               %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% loadlibrary('ps35')                                       
calllib('ps35','PS35_Connect', 1, 0, 3, 230400, 0, 0, 0, 0);                % Starts communication with OWIS driver
calllib('ps35','PS35_MotorInit', 1, handles.ejeX);                          % Initialize motor on x axis                               
calllib('ps35','PS35_MotorInit', 1, handles.ejeY);                          % Initialize motor on y axis
calllib('ps35','PS35_SetDispMode',1,handles.ejeX,1);                        % Set display mode on milimeters
calllib('ps35','PS35_SetDispMode',1,handles.ejeY,1);                        % Set display mode on milimeters
xhome = calllib('ps35','PS35_GetDispPos',1,handles.ejeX);                   % Read display's current position on x axis 
yhome = calllib('ps35','PS35_GetDispPos',1,handles.ejeY);                   % Read display's current position on y axis
handles.xhome = xhome;
handles.yhome = yhome;
% unloadlibrary('ps35')

guidata (hObject, handles);

% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

            in1 = handles.puertoCOM;

            in2X = handles.ejeX;
            in2Y = handles.ejeY;
            in3Y = handles.changeVel_Y;
            in3X = handles.changeVel_X;
            in4Y = handles.yhome/10000;
            in4X = handles.xhome/10000;
            in5 = 0;

retvalY2 = ps35toolY2( in1, in2Y, in3Y, in4Y, in5 );
retvalX2 = ps35toolX2( in1, in2X, in3X, in4X, in5 );


guidata (hObject, handles);


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

guidata (hObject, handles);
                                                    % handles.movY = str2double(get(handles.edit1,'Value'));
                                                    % handles.movX = str2double(get(handles.edit2,'Value'));
                                                    % 
                                                    % 
                                                    % handles.movYF = str2double(get(handles.slider1,'Value'));
                                                    % handles.movXF = str2double(get(handles.slider2,'Value'));
                                                    % 
                                                    % handles.puertoCOM = str2double(get(handles.edit5,'Value'));
                                                    % 
                                                    % handles.changeVel_X = str2double(get(handles.edit4,'Value'));
                                                    % handles.changeVel_Y = str2double(get(handles.edit3,'Value'));
                                                    % 
                                                    % handles.ejeX = str2double(get(handles.edit6,'Value'));
                                                    % handles.ejeY = str2double(get(handles.edit7,'Value'));
                                                    % 
                                                    % handles.img=get(handles.pushbutton4,'Value');
                                                    % handles.Im=get(handles.pushbutton9,'Value');




% figname = handles.Im;
COMp = handles.puertoCOM;
vy = handles.changeVel_Y;
vx = handles.changeVel_X;
ax = handles.ejeX;
ay = handles.ejeY;

n=handles.nCase;

% n = 1;
tr = handles.StepSize;

% st = false;
Im = handles.Im;

if isempty(Im) || isequal(Im, 0)
    errordlg('Primero carga la imagen con el botón de detección.');
    return
end

% ---- ANTES (esquinas + líneas rectas) ----
% res = VertexDetection(Im);
% generalMov(res,COMp,vx,vy,n,tr,ax,ay)

% ---- AHORA (círculos y anillos + interpolación circular) ----
[res, grupos, BW] = RingDetection(Im);

p.axis_X = ax;
p.axis_Y = ay;
p.vx = vx;                       % velocidad de los traslados (láser apagado)
p.vy = vy;
p.pix2mm = 1/1000;               % 1 px = 1 um (igual que generalMov)
p.laserStepWidth = tr/1000;      % StepSize del panel, en um -> mm
p.motorSpeed = 0.2e-3;           % mm/ms (0.2 mm/s), la de circulo_while
p.secantNum = 100;

circlesMov(res, grupos, BW, p);







guidata (hObject, handles);



% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

DAQstate('false');
calllib('ps35','PS35_MotorOff', 1,handles.ejeX);
calllib('ps35','PS35_MotorOff', 1, handles.ejeY);


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename1, pathname1] = uigetfile('.png','All Files(".")');


%[filename1, path1]= uigetfile('.png','All Files(".")');

Im =strcat(pathname1,filename1);


%Im=imread(imagen1);

handles.Im=Im;

guidata(hObject,handles);

% ---- ANTES ----
% res = VertexDetection(Im);
% for i = 1 : length(res)
%    hold on
%    plot(res{i}(:,2),res{i}(:,1),'yo','MarkerFaceColor','r','MarkerSize',5);
%    hold off
% end

% ---- AHORA: RingDetection ya dibuja la imagen, los centros y los círculos ----
axes(handles.axes1);
[res, grupos] = RingDetection(Im);
fprintf('%d círculo(s) detectado(s) en %d figura(s).\n', numel(res), numel(grupos));



axis off

guidata(hObject,handles);


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

s = get(handles.pushbutton10,'Value');

switch s

    case 0
        set (handles.TextPause,'String','System RUN')
        set (handles.LED,'BackgroundColor','green')

    case 1
        set(handles.TextPause,'String','System Pause')
        set (handles.LED,'BackgroundColor','red')
end






% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

COMp = handles.puertoCOM;
%vy = handles.changeVel_Y;
vx = handles.changeVel_X;
% ax = handles.ejeX;
% ay = handles.ejeY;


in4=handles.NumLineas;
in6=handles.DYdots;
in7=handles.DXdots;
freqRR=handles.fTrain;
ndut=handles.nDut;


val=repRate(COMp,0, vx, in4,0,in6,in7,freqRR,ndut);



function edit12_Callback(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit12 as text
%        str2double(get(hObject,'String')) returns contents of edit12 as a double

NumLineas = str2double(get(hObject,'String'));   % Esta variable es para entregar el valor del slider al cuadro de texto

handles.NumLineas = NumLineas;

guidata (hObject, handles);



% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit13_Callback(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit13 as text
%        str2double(get(hObject,'String')) returns contents of edit13 as a double



DXdots = str2double(get(hObject,'String'));   % Esta variable es para entregar el valor del slider al cuadro de texto

handles.DXdots = DXdots;

guidata (hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit14_Callback(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit14 as text
%        str2double(get(hObject,'String')) returns contents of edit14 as a double


DYdots = str2double(get(hObject,'String'));   % Esta variable es para entregar el valor del slider al cuadro de texto

handles.DYdots = DYdots;

guidata (hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit15_Callback(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit15 as text
%        str2double(get(hObject,'String')) returns contents of edit15 as a double

fTrain = str2double(get(hObject,'String'));   % Esta variable es para entregar el valor del slider al cuadro de texto

handles.fTrain = fTrain;

guidata (hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit16_Callback(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit16 as text
%        str2double(get(hObject,'String')) returns contents of edit16 as a double

nDut = str2double(get(hObject,'String'));   % Esta variable es para entregar el valor del slider al cuadro de texto

handles.nDut = nDut;

guidata (hObject, handles);




% --- Executes during object creation, after setting all properties.
function edit16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
