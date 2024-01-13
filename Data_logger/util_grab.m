function status = util_grab(app)
%check that session tree is ready
if sum(app.Lamp.Color == app.lamp_off_color) == 3
    warndlg('Must initialize session','Session not ready','non-modal')
    return
end

util_get_session_parameters(app);
app.BASE_FILE_NAME = util_create_filename(app);

%determine type of data (this might be automated from SI
data_type = app.DatatypeDropDown.Value;
switch data_type
    case {'Movie'}
        app.PATH_TO_DATA = fullfile(app.PATH_TO_SESSION_DATA_OPHYS,app.BASE_FILE_NAME.append('_00001.tif'));
        si_path_to_data = app.PATH_TO_SESSION_DATA_OPHYS;
    case {'Arbitrary Scan'}
        app.PATH_TO_DATA = fullfile(app.PATH_TO_SESSION_DATA_OPHYS,app.BASE_FILE_NAME.append('_00001.dat'));
        si_path_to_data =  app.PATH_TO_SESSION_DATA_OPHYS;
    case 'Stack'
        app.PATH_TO_DATA = fullfile(app.PATH_TO_SESSION_DATA_ANAT,app.BASE_FILE_NAME.append('_00001.tif'));
        si_path_to_data = app.PATH_TO_SESSION_DATA_ANAT;
end
app.PATH_TO_DATA_REL = app.PATH_TO_DATA.erase(app.PROJECT_ROOT_DIR);

%% SI interface
%update SI data logging fields
%update filename and directory
cmd = sprintf("hSI.hScan2D.logFilePath='%s';",si_path_to_data);
evalin('base',cmd);
cmd = sprintf("hSI.hScan2D.logFileStem='%s';",app.BASE_FILE_NAME);
evalin('base',cmd);
cmd = ['hSI.hChannels.loggingEnable=1;hSI.hScan2D.logFileCounter=1;' ...
    'hSI.hScan2D.logOverwriteWarn=1;'];
evalin('base',cmd);
%%
grab_start_timestamp = datestr(now);
switch app.APP_MODE
    case 'SI-Online'
        if  app.AcquireanalogdataCheckBox.Value
            switch app.DAQDropDown.Value
                case 'NI'
                    evalin ('base','data_logger_init_analog_acq_ni');
                case 'VDAQ'
                    evalin ('base','data_logger_init_analog_acq_vdaq;');
                    evalin('base','hSI.startGrab')
            end

        else
            evalin('base','hSI.startGrab')
        end
        cmd = 'hSI.hChannels.loggingEnable=0;';
        evalin('base',cmd)
end %APP_MODE


session = util_log_session(app);
acquisition = util_log_acquisition(app,grab_start_timestamp);
util_write_metadata_to_xml(app,session,acquisition);

%if we got here, increase acq_id counter by one
app.ACQ_ID = app.ACQ_ID + 1;
app.AcquisitionIDTextArea.Value=sprintf("%05d",app.ACQ_ID);
status = 1;