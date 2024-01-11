function status = util_write_metadata_to_xml(app,session,acq_params)
%functions dumps an NWB-like xml file with pertinent data

%% Gater info to dump into xml
session = rmfield(session,'keep_session_for_analysis');
session.experimenter = app.ExperimenterTextArea.Value;

%%
project  = struct('project_name',app.PROJECT_ID,...
    'lab',app.LabTextArea.Value,...
    'institution',app.InstitutionTextArea.Value,...
    'protocol_num',app.ProtocolTextArea.Value,...
    'description',app.Project_description.Value);


%%
path_to_subject_table = fullfile(app.PROJECT_ROOT_DIR,'subjects.csv');
opts = adjust_readtable_timeoptions(path_to_subject_table,{'dob','surgery_date','surgery_date'},'dd-MMM-yyyy');
subjects_table = readtable(path_to_subject_table,opts);
row = ismember(subjects_table.id,session.subject_id);
subject  = table2struct( subjects_table(row,:));
%% concatenate into single structure

xml_dump.project = project;
xml_dump.subject = subject;
xml_dump.session = session;
xml_dump.acq_params = acq_params;

%%
[file_root,file_name] = fileparts(session.path_to_data);
path_to_xml = fullfile(app.PROJECT_ROOT_DIR, file_root,file_name.append(".xml"));

writestruct(xml_dump,path_to_xml,"StructNodeName","Data")
