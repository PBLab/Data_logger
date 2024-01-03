function status = util_log_session(app)
%UTIL_LOG_SESSION Summary of this function goes here
%   Detailed explanation goes here
if isempty(app.SessionDescription);app.SessionDescription={};end
this_session = struct(...
    'session_id',app.SESSION_ID,...
    'acquisition_id',app.ACQ_ID,...
    'project_id',app.PROJECT_ID,...
    'subject_id',app.SUBJECT_ID,...
    'condition',app.CONDITION,...
    'fov',app.FOV,...
    'timepoint',app.TIMEPOINT,...,
    'anesthesia',app.ANESTHESIA,...
    'labeling',app.LABELING,...
    'pharmacology',app.PHARMACOL,...
    'description',app.SessionDescription.Value);
%     'description',app.);

if ~numel(this_session.description);this_session.description={'None'};end

%the following fields are used to post-acquisition quality assesment
this_session.keep_session_for_analysis = {'TBD'};
this_session.comments = {'None'};

this_session_table=struct2table(this_session,'AsArray',true);
status = 1;

%% load file if exists, create otherwise
path_to_sessions = fullfile(app.PROJECT_ROOT_DIR,'sessions.csv');
if isfile(path_to_sessions)
    sessions = readtable(path_to_sessions);
    sessions_ids = sessions.session_id;
    if ~ismember(sessions_ids,this_session.session_id)
        sessions = [sessions;this_session_table];
        writetable(sessions,path_to_sessions)
    end %do nothing otherwise, session already in table
    
else
    writetable(this_session_table,path_to_sessions);
end

end

