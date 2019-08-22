function varargout = countingFingersProject(varargin)
% COUNTINGFINGERSPROJECT MATLAB code for countingFingersProject.fig
%      COUNTINGFINGERSPROJECT, by itself, creates a new COUNTINGFINGERSPROJECT or raises the existing
%      singleton*.
%
%      H = COUNTINGFINGERSPROJECT returns the handle to a new COUNTINGFINGERSPROJECT or the handle to
%      the existing singleton*.
%
%      COUNTINGFINGERSPROJECT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COUNTINGFINGERSPROJECT.M with the given input arguments.
%
%      COUNTINGFINGERSPROJECT('Property','Value',...) creates a new COUNTINGFINGERSPROJECT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before countingFingersProject_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to countingFingersProject_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help countingFingersProject

% Last Modified by GUIDE v2.5 04-Mar-2019 20:17:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @countingFingersProject_OpeningFcn, ...
                   'gui_OutputFcn',  @countingFingersProject_OutputFcn, ...
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


% --- Executes just before countingFingersProject is made visible.
function countingFingersProject_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to countingFingersProject (see VARARGIN)

% Choose default command line output for countingFingersProject
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes countingFingersProject wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = countingFingersProject_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% setting off count button:
set(handles.count_button,'Enable','off')

% --- Executes on button press in load_button.
function load_button_Callback(hObject, eventdata, handles)
% hObject    handle to load_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file_name, path_name] = uigetfile('*'); %get file and path
full_path = [path_name '\' file_name];
handles.path_name = path_name;
handles.file_name = file_name;
handles.im_original = imread(full_path); %read the image
axes(handles.axes1);
imagesc(handles.im_original); axis off;
guidata(hObject, handles); %to save changes in handle object
set(handles.count_button,'Enable','on')


% --- Executes on button press in count_button.
function count_button_Callback(hObject, eventdata, handles)
% hObject    handle to count_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

figure(1);
subplot(3,3,1);
imshow(handles.im_original);
title('1. original image');

% get height and width of original image:
im_original_height = size(handles.im_original, 1);
im_original_width = size(handles.im_original, 2);

% to manipulate the original image without ruin it.
new_original = handles.im_original; 
% binary image filled with zeros(size of original image).
im_bw = zeros(im_original_height, im_original_width); 

% using rgb2YCbCr for skin detection:
im_ycbcr = rgb2ycbcr(handles.im_original);
cb = im_ycbcr(:,:,2);
cr = im_ycbcr(:,:,3);

figure(1);
subplot(3,3,2);
imshow(im_ycbcr);
title('2. skin detection');
% detecting skin pixeles:
[r,c,v] = find(cb >= 77 & cb <= 127 & cr >= 133 & cr <= 173);
numid = size(r,1);

for i = 1:numid
    % skin on original image marked with green color:
    new_original(r(i),c(i),:) = [0,255,0];
    % fill binary image with ones where skin detected previous:
    im_bw(r(i),c(i)) = 1;
end

figure(1);
subplot(3,3,3);
imshow(new_original);
title('3. hand marked green');
% fill black holes:
im_bw = imfill(im_bw, 'holes');
figure(1);
subplot(3,3,4);
imshow(im_bw);
title({'4. hand filled with', 'black holes'});

% delete small "islands":
im_bw = bwareaopen(im_bw, 10000);
figure(1);
subplot(3,3,5);
imshow(im_bw);
title({'5. hand without', '"small islands" around'});

% create structuring element(size was chosen after several various tries):
se = strel('square', 430);
% delete fingers to get palm only:
im_palm = imerode(im_bw, se);
% recreate the palm:
im_palm = imdilate(im_palm, se);
figure(1);
subplot(3,3,6);
imshow(im_palm);
title('6. palm only');
% subtract palm from original image will get us the fingers:
im_fingers = imsubtract(im_bw, im_palm);
figure(1);
subplot(3,3,7);
imshow(im_fingers);
title('7. fingers without palm');
% noise reduction(pretty big to make sure we reduce enough, chosen manually):
im_fingers = bwareaopen(im_fingers, 100000);
figure(1);
subplot(3,3,8);
imshow(im_fingers);
title({'8. fingers with', 'noise reduction'});

% getting stats of fingers only image:
stats = regionprops(im_fingers, 'ALL');
all_areas_found = [stats.Area];

figure(1);
subplot(3,3,9);
imshow(handles.im_original);
title(['9. counted fingers: ', num2str(length(all_areas_found))]);

axes(handles.axes1);
imagesc(handles.im_original);
title([num2str(length(all_areas_found)), ' fingers']);