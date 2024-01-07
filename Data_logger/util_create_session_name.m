function [session_str,session_dir_str]= util_create_session_name(app,create_directories)
%setup recording path based on session parameters - Make
%compliant with [partial] BIDS and thinking of future NWB
%📂 MyProject
%└── 📂 sub-A2929
%       └── 📂
%       ses-A2929-200711-acq_0000x-[cond_xx]-[T_xx]-[FOV_xx]-[anes_xxx]-[pharm_xxx]
%              └── 📂 ophys %optical physiology (Movies, arbitrary scans and analog data)
%              └── 📂 anat  %anatomical stuff (3D stacks, overviews etc)
%              └── 📂 derivates
%  project.yml or project.xml (supported)
%  sessions.csv
%  acquisitions.csv
%  subjects.csv
%
% Inputs:
% app - calling gui app
% create_directories - 0 or 1  setting to create data directory


%% gather info about what goes into session name based on check
%boxes state

session_str = string(sprintf('ses-%s-%s',app.SUBJECT_ID,datestr(now,'YYYYmmDD')));

if app.CheckBox_Condition.Value
    session_str = session_str.append(sprintf("-cond_%s",app.CONDITION));
end

if app.CheckBox_FOV.Value
    session_str = session_str.append(sprintf("-FOV_%02d",app.FOV));
end

if app.CheckBox_Timepoint.Value
    session_str = session_str.append(sprintf("-T_%02d",app.TIMEPOINT));
end


if app.CheckBox_Anesthesia.Value
    session_str = session_str.append(sprintf("-anes_%s",app.ANESTHESIA));
end

if app.CheckBox_Pharmacology.Value
    session_str = session_str.append(sprintf("-pharm_%s",app.PHARMACOL));
end

if app.CheckBox_Stim.Value
    session_str = session_str.append(sprintf("-stim_%s",app.STIM));
end

app.SESSION_ID = session_str;
app.SessionIDTextArea.Value = app.SESSION_ID;



%%
% session_dir_str = string(sprintf('ses-%s-%s',app.SUBJECT_ID,datestr(now,'YYYYmmDD')));
session_dir_str = app.SESSION_ID;
if app.CheckBox_Condition_dir.Value
    session_dir_str = session_dir_str.append(sprintf("%s%s",filesep,app.CONDITION));
end

if app.CheckBox_FOV_dir.Value
    session_dir_str = session_dir_str.append(sprintf("%sFOV_%02d",filesep,app.FOV));
end

if app.CheckBox_Timepoint_dir.Value
    session_dir_str = session_dir_str.append(sprintf("%sT_%02d",filesep,app.TIMEPOINT));
end

if app.CheckBox_Anesthesia_dir.Value
    session_dir_str = session_dir_str.append(sprintf("%s%s",filesep,app.ANESTHESIA));
end

if app.CheckBox_Pharmacology_dir.Value
    session_dir_str = session_dir_str.append(sprintf("%s%s",filesep,app.PHARMACOL));
end

if app.CheckBox_Stim_dir.Value
    session_dir_str = session_dir_str.append(sprintf("%s%s",filesep,app.STIM));
end

session_dir_str = session_dir_str.insertBefore(1,[app.SUBJECT_ID filesep]);
path_to_session= fullfile(app.PROJECT_ROOT_DIR,session_dir_str);

%%
app.PATH_TO_SESSION_DATA_OPHYS = fullfile(path_to_session,'ophys');
app.PATH_TO_SESSION_DATA_ANAT = fullfile(path_to_session,'anat');
app.PATH_TO_SESSION_DERIVATIVES = fullfile(path_to_session,'derivates');

if create_directories
    try
        %create data structure
        fprintf('\n\tInitializing session directory.\n')
        if ~isfolder(app.PATH_TO_SESSION_DATA_OPHYS);mkdir(app.PATH_TO_SESSION_DATA_OPHYS);end
        if ~isfolder(app.PATH_TO_SESSION_DATA_ANAT);mkdir(app.PATH_TO_SESSION_DATA_ANAT);end
        if ~isfolder(app.PATH_TO_SESSION_DERIVATIVES);mkdir(app.PATH_TO_SESSION_DERIVATIVES);end
    catch
        warndlg('Failed to initialize session data structure')
        return
    end
end