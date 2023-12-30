function status = util_project_load(app)

%attempt to load project.yml, if successful populate project
%fields in gui
%path_to_xml = fullfile(app.PROJECT_ROOT_DIR,'project.xml');
path_to_yml = fullfile(app.PROJECT_ROOT_DIR,'project.yml');
if isfile(path_to_yml)
    %project = readstruct(path_to_xml);
    project = yaml.loadFile(path_to_yml,"ConvertToArray", true);
else
    warndlg (sprintf("No project.yml file in %s",app.PROJECT_ROOT_DIR));
end

%populate Project tab
app.PROJECT_ID = project.id;
app.ProjectNameTextArea.Value = project.id;
app.LabTextArea.Value = project.lab;
app.InstitutionTextArea.Value = project.institution;
app.ExperimenterTextArea.Value = project.experimenter;
app.Project_description.Value = project.description;
app.ProtocolTextArea.Value = project.protocol_id;

%populate Session tab (Conditions)
if isfield(project,'conditions')
    app.ConditionDropDown.Items=project.conditions;
end

%populate Subject tab
if isfield(project,'genotype')
    app.GenotypeDropDown.Items=project.genotype;
end

if isfield(project,'virus')
    app.VirusDropDown.Items=project.virus;
end

if isfield(project,'anesthesia')
    app.AnesthesiaDropDown.Items=project.anesthesia;
end

if isfield(project,'labeling')
    app.LabelingDropDown.Items=project.labeling;
end

if isfield(project,'pharmacology')
    app.PharmacolDropDown.Items=project.pharmacology;
end
%check if subjects table exits, load and populate fields
path_to_subject_table = fullfile(app.PROJECT_ROOT_DIR,'subjects.csv');
if isfile(path_to_subject_table)
    subjects_table = readtable(path_to_subject_table);
    subjects_in_table = unique(subjects_table.id);
    populate_session_subject_dropdown(app,subjects_table.id);
end

status = 1;