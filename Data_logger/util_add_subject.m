function status = util_add_subject(app)
%keep track of project subjects in table (csv format).

%validate filled mandatory  fields - TO DO
current_subject_id = app.AnimalIDTextArea.Value;
if isempty(current_subject_id{1})
    warndlg("Animal ID, species, sex and DOB are mandatory.")
    return
end

path_to_subject_table = fullfile(app.PROJECT_ROOT_DIR,'subjects.csv');
if isfile(path_to_subject_table)
    subjects_table = readtable(path_to_subject_table);
    %                 subjects_table.Properties.RowNames = "id";
    subjects_in_table = unique(subjects_table.id);
else
    subjects_in_table={};
    subjects_table=table();
end

%check to see if current id already in table
if any(ismember(subjects_in_table,current_subject_id))
    warndlg('Animal id already exists in table');
    return
else
    subject = get_subject(app);
    subjects_table = [subjects_table;struct2table(subject,'AsArray',true)];
    writetable(subjects_table,path_to_subject_table)
end
populate_session_subject_dropdown(app,subjects_table.id);

status = 1;