% data_logger_init_analog_acq - helper script to initialize acquisition
%
% To do - functionalize with argument to control VDAQ and NI systems.


fprintf('\n Initializing data recorder \n')
sample_rate = 5000; %samples per second 


target_dir = hSI.hScan2D.logFilePath;
fname = hSI.hScan2D.logFileStem;

% Obtain handle to recorder
hResource = dabs.resources.ResourceStore().filterByName('AnalogDataRecorder');
hResource.sampleRate = sample_rate;
hResource.fileBaseName = fname;
hResource.fileDirectory = target_dir;


%% ensure user functions are enabled.
func_names = {'stop_analog_recording'};
event_names = {'acqModeDone'};
arguments ={{}};
enable_on = {1};
enable_off = {0};
user_func_on = struct('EventName',event_names,'UserFcnName',func_names,'Arguments',arguments,'Enable',enable_on);
user_func_off= struct('EventName',event_names,'UserFcnName',func_names,'Arguments',arguments,'Enable',enable_off);
hSI.hUserFunctions.userFunctionsCfg = user_func_on;