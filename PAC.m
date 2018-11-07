function varargout = PAC(varargin)
% PAC MATLAB code for PAC.fig
%      PAC, by itself, creates a new PAC or raises the existing
%      singleton*.
%
%      H = PAC returns the handle to a new PAC or the handle to
%      the existing singleton*.
%
%      PAC('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PAC.M with the given input arguments.
%
%      PAC('Property','Value',...) creates a new PAC or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PAC_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PAC_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PAC

% Last Modified by GUIDE v2.5 07-Nov-2018 18:07:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PAC_OpeningFcn, ...
                   'gui_OutputFcn',  @PAC_OutputFcn, ...
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


% --- Executes just before PAC is made visible.
function PAC_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PAC (see VARARGIN)

% Choose default command line output for PAC
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PAC wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = PAC_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file,path] = uigetfile('*.pac','Select One or More Files',...
                            'MultiSelect', 'on');
if ~isequal(file,0)
    files = fullfile(path,file);
    if isa(files, 'char')
        data = read_pac_file(files);
        plot_image(data, handles.axes1)
    elseif isa(files, 'cell')
        files = sort(files);
        data = cell(1,length(files));
        for i=1:length(data)
            [~,name,ext] = fileparts(files{i});
            disp([name, ext])
            data{i} = read_pac_file(files{i});
            if i==1
                plot_image(data{i}, handles.axes1)
            elseif i==2
                plot_image(data{i}, handles.axes2)
            elseif i==3
                plot_image(data{i}, handles.axes3)
            elseif i==4
                plot_image(data{i}, handles.axes4)
            end
        end
        if length(data)>=4
            OD = [data{1}; data{2}];
            [path, ~, ~] = fileparts(files{1});
            save([path,'\OD.mat'],'OD')
            plot_image(OD, handles.axes5)
            %
            OS = [data{3}; data{4}];
            [path, ~, ~] = fileparts(files{3});
            save([path,'\OS.mat'],'OS')
            plot_image(OS, handles.axes6)
        end
    else
        disp('unknown returned file types!')
    end
end

function plot_image(data, ax1)   
    set(ax1,'Units','pixels');
    resize_pos = get(ax1,'Position');
    img = imresize(data, [resize_pos(4) resize_pos(3)]);
    axes(ax1);
    imshow(img,[]);
    set(ax1,'Units','normalized');

function data = read_pac_file(filepath)
    fid = fopen(filepath);
    data = [];
    n_line = 0;
    while ~feof(fid)
        line = fgets(fid); %# read line by line
        if length(line)>7 && strcmp(line(1:7),'Matrix ')
            data = [data; str_array_to_matrix(line)];
            n_line = n_line + 1;
        end
    end
    [path, name, ~] = fileparts(filepath);
    save([path,'\',name,'.mat'],'data')
    disp(size(data))
    fclose(fid);

function values = str_array_to_matrix(line)
    strs = strsplit(line,'=');
    values = str2num(strs{2});


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    dir_path = uigetdir();
    if dir_path == 0
        return
    end
    disp(dir_path)
    % get subfolders
    d = dir(dir_path);
    isub = [d(:).isdir]; %# returns logical vector
    subfolders = {d(isub).name}';
    subfolders(ismember(subfolders,{'.','..'})) = [];
    % load files in each folder
    OD = []; OS = []; 
    n_person = 0;
    for i=1:length(subfolders)
        curr_path_OD = fullfile(dir_path, subfolders{i}, 'OD.mat');
        curr_path_OS = fullfile(dir_path, subfolders{i}, 'OS.mat');
        if exist(curr_path_OD, 'file') == 2 && exist(curr_path_OS, 'file') == 2
            tmp_OD = load(curr_path_OD,'OD');
            OD = [OD; tmp_OD.OD];
            tmp_OS = load(curr_path_OS,'OS');
            OS = [OS; tmp_OS.OS];
            n_person = n_person + 1;
        else
            disp(['(skip) not enough file: ', fullfile(dir_path, subfolders{i})])
        end
    end
    %
    disp(['combined ', num2str(n_person), ' subjects'])
    save(fullfile(dir_path,'full_OD.mat'),'OD')
    plot_image(OD, handles.axes7)
    save(fullfile(dir_path,'full_OS.mat'),'OS')
    plot_image(OS, handles.axes8)