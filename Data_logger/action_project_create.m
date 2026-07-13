function status = action_project_create(app)
%ACTION_PROJECT_CREATE creates project settings from parameters in
%corresponding tab and saves to yaml
%   Detailed explanation goes here
try
    %gather all pertinent fields into structure an save as .yml
    path_to_yml = fullfile(app.PROJECT_ROOT_DIR,'project.yml');
    if isfile(path_to_yml)
        warndlg('Project already exists; use Update instead');
        status = 0;
        return
    end

    id = app.ProjectNameTextArea.Value{1};
    lab = app.LabTextArea.Value{1};
    institution = app.InstitutionTextArea.Value{1};
    experimenter = app.ExperimenterTextArea.Value{1};
    protocol_id = app.ProtocolTextArea.Value{1};
    description = app.Project_description.Value{1};
    project = struct('id',id,'institution',institution,'lab',lab, ...
        'experimenter',experimenter,'protocol_id',protocol_id,...
        'description',description,'app_mode',app.APP_MODE);
    path_to_yml = fullfile(app.PROJECT_ROOT_DIR,'project.yml');
    yaml.dumpFile(path_to_yml,project,'block')
    status = 1;
catch
    status = -1;
end


