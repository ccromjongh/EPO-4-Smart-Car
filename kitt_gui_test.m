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

    % Last Modified by GUIDE v2.5 05-May-2017 17:14:54

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
    
    handles.dataUpdatePeriod = 0.1;
    handles.graphDomain = 5;
    handles.graphUpdatePeriod = 0.2;
    handles.keysPressed = {};
    
    handles.KITT = testClass;
    handles.connected = false;
    handles.dataUpdateTimer = timer(...
        'ExecutionMode', 'fixedRate', ...           % Run timer repeatedly.
        'Period', handles.dataUpdatePeriod, ...     % Initial period, see above.
        'TimerFcn', {@update_display, hObject});    % Specify callback function.
    
    handles.graphUpdateTimer = timer(...
        'ExecutionMode', 'fixedRate', ...           % Run timer repeatedly.
        'Period', handles.graphUpdatePeriod, ...    % Initial period, see above.
        'TimerFcn', {@update_graph, hObject});      % Specify callback function.
    
    guidata(hObject, handles);
    handles = graphCreator(hObject);

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
    % handles.KITT.getBatteryVOltage();
    
    % Refresh data in table
    try
        data = {'Port name'         handles.KITT.currentPortName; ...
                'Battery voltage'	handles.KITT.batteryVoltage; ...
                'Left distance'     handles.KITT.leftDistance; ...
                'Right distance'    handles.KITT.rightDistance
               };
        handles.status_table.Data = data;
    catch
        disp(data);
        disp(handles.KITT.batteryVoltage);
    end
    
    % Refresh data in plots
    handles.distData = [handles.distData(1, 2:end) handles.KITT.leftDistance; ...
                        handles.distData(2, 2:end) handles.KITT.rightDistance];
    
    % Save data to handles variable
    guidata(hObject, handles);
end

function update_graph(~, ~, hObject)
    % Get handles
    handles = guidata(hObject);
    
    % Refresh data in plots
    handles.distance_plot(1).YData = handles.distData(1, :);
    handles.distance_plot(2).YData = handles.distData(2, :);
    
    % Save data to handles variable
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
function connect_button_Callback(hObject, eventdata, handles) %#ok<DEFNU>
    if (~handles.connected)
        comNumber = get(handles.serial_list, 'value');
        comString = get(handles.serial_list, 'string');
        comString = comString{comNumber};
        usableComString = regexp(comString, 'COM[0-9]+', 'match');
        if (~strcmp(usableComString, ''))
            try
                handles.KITT.openPort(usableComString{1});
                handles = setConnectionState(hObject, true);
            catch
                handles.KITT.closePort();
                handles = setConnectionState(hObject, false);
            end
        end
    else
        handles.KITT.closePort();
        handles = setConnectionState(hObject, false);
    end
    guidata(hObject, handles);

    % hObject    handle to connect_button (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
end

function handles = setConnectionState(hObject, state)
    handles = guidata(hObject);
    if (state)
        hObject.BackgroundColor = [1.0, 0.3, 0.3];
        hObject.String = 'Disconnect';
        handles.connected = true;
        start(handles.dataUpdateTimer);
        start(handles.graphUpdateTimer);
        handles.refresh_com_ports.Enable = 'off';
    else
        handles.connected = false;
        stop(handles.dataUpdateTimer);
        stop(handles.graphUpdateTimer);
        hObject.BackgroundColor = [0.573, 0.867, 0.596];
        hObject.String = 'Connect';
        handles.refresh_com_ports.Enable = 'on';
    end
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over connect_button.
function connect_button_ButtonDownFcn(hObject, eventdata, handles)
    % hObject    handle to connect_button (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
end

% --- Executes during object creation, after setting all properties.
function handles = graphCreator(hObject)
    handles = guidata(hObject);
    
    graphPeriod = handles.graphDomain;
    updatePeriod = handles.dataUpdatePeriod;
    nItems = graphPeriod/updatePeriod;
    distance_data = zeros(2, nItems); %*40 + 150;
    distance_time = -graphPeriod + updatePeriod:updatePeriod:0;
    
    axes(handles.distance_graph);
    handles.distance_plot = plot(distance_time, distance_data, 'x-');
    title('Distance graph');
    xlim([-5 0]);
    ylim([0 350]);
    xlabel('Time (s)', 'HorizontalAlignment', 'right');
    ylabel('Distance (cm)');
    legend({'Left' 'Right'});
    
    handles.distData = distance_data;

    % Hint: place code in OpeningFcn to populate distance_graph
end


% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
    % hObject    handle to figure1 (see GCBO)
    % eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
    %	Key: name of the key that was pressed, in lower case
    %	Character: character interpretation of the key(s) that was pressed
    %	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
    % handles    structure with handles and user data (see GUIDATA)
    
    keyPressed = eventdata.Key;
    if (~any(strcmp(handles.keysPressed, keyPressed)))
        handles.keysPressed{end+1} = keyPressed;
    end
    
    middle = 15;
    manualControlSpeed = handles.manual_control_slider.Value;
    
    doControl = handles.manual_control_check.Value;
    
    if (doControl && handles.connected)
        switch keyPressed
        	case 'w'
            	KITT.setMotorSpeed(middle + manualControlSpeed);
            case 'a'
            	KITT.setSteerDirection(-22);
            case 's'
            	KITT.setMotorSpeed(middle - manualControlSpeed);
            case 'd'
            	KITT.setSteerDirection(22);
            case 'escape'
            	KITT.setMotorSpeed(15);
                handles.keysPressed = {'escape'};
            otherwise
        end
    end
    
    guidata(hObject, handles);
end

% --- Executes on key release with focus on figure1 or any of its controls.
function figure1_WindowKeyReleaseFcn(hObject, eventdata, handles) %#ok<DEFNU>
    % hObject    handle to figure1 (see GCBO)
    % eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
    %	Key: name of the key that was released, in lower case
    %	Character: character interpretation of the key(s) that was released
    %	Modifier: name(s) of the modifier key(s) (i.e., control, shift) released
    % handles    structure with handles and user data (see GUIDATA)
    
    
    keyReleased = eventdata.Key;
    keysPressed = handles.keysPressed;
    
    try
        % Remove value from array
        keysPressed(strcmp(keysPressed, keyReleased)) = [];
    % If something goes wrong, delete whole array and stop KITT
    catch
        keysPressed = {};
        KITT.setMotorSpeed(15);
    end
    
    % If neither 'w' or 's' is pressed, stop KITT
    if (~any([strcmp(keysPressed, 'w') strcmp(keysPressed, 's')]))
        KITT.setMotorSpeed(15);
    end
    
    % If neither 'a' or 'd' is pressed, stop KITT
    if (~any([strcmp(keysPressed, 'a') strcmp(keysPressed, 'd')]))
        KITT.setMotorSpeed(15);
    end
    
    % Return values to their original array
    handles.keysPressed = keysPressed;
    
    guidata(hObject, handles);
end


% --- Executes on button press in manual_control_check.
function manual_control_check_Callback(hObject, eventdata, handles)
    % hObject    handle to manual_control_check (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hint: get(hObject,'Value') returns toggle state of manual_control_check
end


% --- Executes on slider movement.
function manual_control_slider_Callback(hObject, eventdata, handles)
    % hObject    handle to manual_control_slider (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'Value') returns position of slider
    %        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
    
    % Aquire, round and set value
    value = uint8(hObject.Value);
    hObject.Value = value;
    
    handles.manual_control_slider_text.String = ['Control speed: ' num2str(value) '/15'];
end


% --- Executes during object creation, after setting all properties.
function manual_control_slider_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to manual_control_slider (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: slider controls usually have a light gray background.
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end
end
