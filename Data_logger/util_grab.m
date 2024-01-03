function status = util_grab(app)
%check that session tree is ready
if sum(app.Lamp.Color == app.lamp_off_color) == 3
    warndlg('Must initialize session','Session not ready','non-modal')
    return
end

get_session_parameters(app);
%determine type of data (this might be automated from SI
data_type = app.DatatypeDropDown.Value;
switch data_type
    case {'Movie','Arbitrary Scan'}
        app.PATH_TO_SESSION_DATA_OPHYS
    case 'Stack'
        app.PATH_TO_SESSION_DATA_ANAT
end

%update SI data logging fields

if  app.AcquireanalogdataCheckBox.Value
    %evalin ('base','data_logger_init_analog_acq');
    %set analog acquisition
end

% evalin('base','hSI.startGrab')

%if we got here, increase acq_id counter by one
app.ACQ_ID = app.ACQ_ID + 1;
app.AcquisitionIDTextArea.Value=sprintf("%05d",app.ACQ_ID);
status = 1;