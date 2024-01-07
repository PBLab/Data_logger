function status = util_validate_yml_in_rootdir(app)
%function ensures we have an yaml file in the project root folder
path_to_yml = fullfile(app.PROJECT_ROOT_DIR,'project.yml');
if isfile(path_to_yml)
    %project = readstruct(path_to_xml);
    status = 1;
else
    uialert(app.UIFigure,sprintf("No project.yml file in %s",app.PROJECT_ROOT_DIR),'Error initializing');
    status = 0;
    return
end