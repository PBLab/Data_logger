function status = util_post_acq_update(app)
%update user comments - requires loading and writting entire session table.

path_to_sessions = fullfile(app.PROJECT_ROOT_DIR,'sessions.csv');

sessions_table = readtable(path_to_sessions);
acq_ids = sessions_table.acquisition_id;
acq_id = str2double( app.AcquisitionIDDropDown.Value);
if ~ismember(acq_ids,acq_id)
    
end

%%
row_id = acq_ids==acq_id;
sessions_table(row_id,'comments') = app.CommentsTextArea.Value;
sessions_table(row_id,'keep_session_for_analysis') = {app.UseforanalysisDropDown.Value};
writetable(sessions_table,path_to_sessions)

status = 1;