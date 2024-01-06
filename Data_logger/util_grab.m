function status = util_grab(app)
%check that session tree is ready
if sum(app.Lamp.Color == app.lamp_off_color) == 3
    warndlg('Must initialize session','Session not ready','non-modal')
    return
end

get_session_parameters(app);
app.BASE_FILE_NAME = util_create_filename(app);

%determine type of data (this might be automated from SI
data_type = app.DatatypeDropDown.Value;
switch data_type
    case {'Movie'}
        app.PATH_TO_DATA = fullfile(app.PATH_TO_SESSION_DATA_OPHYS,app.BASE_FILE_NAME.append('.tif'));
    case {'Arbitrary Scan'}
        app.PATH_TO_DATA = fullfile(app.PATH_TO_SESSION_DATA_OPHYS,app.BASE_FILE_NAME.append('.dat'));
    case 'Stack'
        app.PATH_TO_DATA = fullfile(app.PATH_TO_SESSION_DATA_ANAT,app.BASE_FILE_NAME.append('.tif'));
end
app.PATH_TO_DATA_REL = app.PATH_TO_DATA.erase(app.PROJECT_ROOT_DIR);

%update SI data logging fields
%update filename and directory

grab_start_timestamp = datestr(now);

if  app.AcquireanalogdataCheckBox.Value
    switch app.DAQDropDown.Value
        case 'NI'
             %evalin ('base','data_logger_init_analog_acq_ni'); 
        case 'VDAQ'
             %evalin ('base','data_logger_init_analog_acq_vdaq'); 
    end
   
    %set analog acquisition
end

% evalin('base','hSI.startGrab')
session = util_log_session(app);
acquisition = util_log_acquisition(app,grab_start_timestamp);
util_write_metadata_to_xml(app,session,acquisition);

%if we got here, increase acq_id counter by one
app.ACQ_ID = app.ACQ_ID + 1;
app.AcquisitionIDTextArea.Value=sprintf("%05d",app.ACQ_ID);
status = 1;