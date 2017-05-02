function varargout = kitt_gui_test(varargin)
    % KITT_GUI_TEST MATLAB code for kitt_gui_test.fig
    
    % KITT_GUI_TEST, by itself, creates a new KITT_GUI_TEST or raises the existing
    % singleton*.
    %
    % H = KITT_GUI_TEST returns the handle to a new KITT_GUI_TEST or the handle to
    % the existing singleton*.
    %
    % KITT_GUI_TEST('CALLBACK',hObject,eventData,handles,...) calls the local
    % function named CALLBACK in KITT_GUI_TEST.M with the given input arguments.
    %
    % KITT_GUI_TEST('Property','Value',...) creates a new KITT_GUI_TEST or raises the
    % existing singleton*.  Starting from the left, property value pairs are
    % applied to the GUI before kitt_gui_test_OpeningFcn gets called.  An
    % unrecognized property name or invalid value makes property application
    % stop.  All inputs are passed to kitt_gui_test_OpeningFcn via varargin.
    %
    % *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    % instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES

    % Edit the above text to modify the response to help kitt_gui_test

    % Last Modified by GUIDE v2.5 02-May-2017 21:18:52

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @kitt_gui_test_OpeningFcn, ...
                       'gui_OutputFcn',  @kitt_gui_test_OutputFcn, ...
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
end

% --- Executes just before kitt_gui_test is made visible.
function kitt_gui_test_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to kitt_gui_test (see VARARGIN)
    handles.KITT = testClass;
    handles.connected = false;
    handles.updateTimer = timer(...
        'ExecutionMode', 'fixedRate', ...       % Run timer repeatedly.
        'Period', 0.1, ...                      % Initial period is 0.1 sec.
        'TimerFcn', {@update_display,hObject}); % Specify callback function.

    % Choose default command line output for kitt_gui_test
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);
    refresh_com_ports_Callback(hObject, eventdata, handles);

    % UIWAIT makes kitt_gui_test wait for user response (see UIRESUME)
    % uiwait(handles.figure1);
end

function update_display(~, ~, hObject)
    handles = guidata(hObject);
    handles.KITT.getDistance();
    handles.KITT.getBatteryVOltage();
    data = {'Port name'         handles.KITT.currentPortName; ...
            'Battery voltage'	handles.KITT.batteryVoltage; ...
            'Left distance'     handles.KITT.leftDistance; ...
            'Right distance'    handles.KITT.rightDistance
           };
    set(handles.status_table, 'Data', data);
    guidata(hObject, handles);
end

% --- Outputs from this function are returned to the command line.
function varargout = kitt_gui_test_OutputFcn(hObject, eventdata, handles) 
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;
end

% --- Executes on selection change in serial_list.
function serial_list_Callback(hObject, eventdata, handles)
    % hObject    handle to serial_list (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: contents = cellstr(get(hObject,'String')) returns serial_list contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from serial_list
end

% --- Executes during object creation, after setting all properties.
function serial_list_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to serial_list (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


% --- Executes on button press in refresh_com_ports.
function refresh_com_ports_Callback(hObject, eventdata, handles)
    prevValue = get(handles.serial_list, 'value');
    prevLength = length(get(handles.serial_list, 'String'));
    
    % [~, queryResult] = dos(['REG QUERY ' 'HKEY_LOCAL_MACHINE\HARDWARE\DEVICEMAP\SERIALCOMM']);
    % serialPorts = unique(regexp(queryResult, 'COM[0-9]+', 'match'));
    
    [~, serialPorts] = dos('wmic path win32_pnpentity get caption | findstr (COM');
    serialPorts = regexp(serialPorts, '[\w \-]+\(COM[0-9]+\)', 'match');
    
    % serialInfo = instrhwinfo('serial');
    % serialPorts = serialInfo.AvailableSerialPorts;
    
    % serialPorts = cell(0);
    % for i = 1:20
    %     s = serial(['COM' num2str(i)]);
    %     try
    %         fopen(s);
    %         fclose(s);
    %         delete(s);
    %         serialPorts{end+1,1}=['COM',num2str(i)];
    %     catch
    %         delete(s);
    %     end
    % end
    stringSet = {'Select COM Port' serialPorts{:}};
    
    % Prevent breaking the UI element if the selected index >= new length
    if (length(stringSet) ~= prevLength)
        set(handles.serial_list, 'value', 1);
    end
    set(handles.serial_list, 'string', stringSet);
    
    % hObject    handle to refresh_com_ports (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
end

% --- Executes on button press in connect_button.
function connect_button_Callback(hObject, eventdata, handles)
    if (~handles.connected)
        comNumber = get(handles.serial_list, 'value');
        comString = get(handles.serial_list, 'string');
        comString = comString{comNumber};
        usableComString = regexp(comString, 'COM[0-9]+', 'match');
        if (~strcmp(usableComString, ''))
            try
                handles.KITT.openPort(['\\.\' usableComString{1}]);
                hObject.BackgroundColor = [1.0, 0.3, 0.3];
                hObject.String = 'Disconnect';
                handles.connected = true;
                start(handles.updateTimer);
            catch
                handles.connected = false;
            end
        end
    else
        handles.KITT.closePort();
        handles.connected = false;
        stop(handles.updateTimer);
        hObject.BackgroundColor = [0.573, 0.867, 0.596];
        hObject.String = 'Connect';
    end
    guidata(hObject, handles);

    % hObject    handle to connect_button (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over connect_button.
function connect_button_ButtonDownFcn(hObject, eventdata, handles)
    % hObject    handle to connect_button (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
end

% --- Executes during object creation, after setting all properties.
function distance_graph_CreateFcn(hObject, eventdata, handles)
    handles.distance_data = zeros(2, 50);
    handles.distance_time = -4.9:0.1:0;
    axes(handles.distance_graph);
    plot(handles.distance_time, handles.distance_data, 'x-');
    title('Distance graph');
    xlim([-5 0]);
    ylim([0 350]);
    xlabel('Time (s)', 'HorizontalAlignment', 'right');
    ylabel('Distance (cm)');
    legend({'Left' 'Right'});

    % hObject    handle to distance_graph (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: place code in OpeningFcn to populate distance_graph
end
