function  [this_acq,status] = util_log_acquisition(app,grab_start_timestamp)
%UTIL_LOG_ACQUISITION gathers acquisition parameters (from SI / other
%imaging app) and write to table

%%  Gather data to log
if ~numel(app.DescriptionAcqTextArea.Value{:});app.DescriptionAcqTextArea.Value={'None'};end
this_acq = struct(...
    'acquisition_id',app.ACQ_ID,...
    'timestamp',grab_start_timestamp,...
    'acquisition_mode',app.DatatypeDropDown.Value,...
    'Scanner',app.ScannerDropDown.Value,...
    'Objective',app.ObjectiveDropDown.Value,...
    'DAQ',app.DAQDropDown.Value,...
    'description',app.DescriptionAcqTextArea.Value...
    );

% if ~numel(this_acq.description);this_acq.description={'None'};end
global acq_settings
switch app.APP_MODE
    case 'SI-Online'
        util_get_si_acq_parameters;
        this_acq = append_fields_to_structure(this_acq,acq_settings);
    otherwise
end

this_acq_table=struct2table(this_acq,'AsArray',true);

%% load file if exists and append (todo - just append w/o loading into table), create otherwise
path_to_acq_table = fullfile(app.PROJECT_ROOT_DIR,'acquisitions.csv');
if isfile(path_to_acq_table)
    opts = adjust_readtable_timeoptions(path_to_acq_table,{'timestamp'},'dd-MMM-yyyy hh:mm:ss');
    acq_table = readtable(path_to_acq_table,opts);
    acq_ids = acq_table.acquisition_id;
    if ~ismember(acq_ids,this_acq.acquisition_id)
        acq_table = [acq_table;this_acq_table];
        acq_ids = acq_table.acquisition_id;
        fprintf('\n\tUpdating acquisition table\n')
        writetable(acq_table,path_to_acq_table)
    end %do nothing otherwise, session already in table
    
else
    fprintf('\n\tCreating acquisition parameters table\n')
    writetable(this_acq_table,path_to_acq_table);
    acq_ids = this_acq_table.acquisition_id;
end

%% update post-acquisition dropdown menu

acq_ids_str = arrayfun(@(x) sprintf('%05d',x),sort(acq_ids,'descend'),'UniformOutput',false);
app.AcquisitionIDDropDown.Items = acq_ids_str;
app.AcquisitionIDDropDown.Value = acq_ids_str(1);
status = 1;