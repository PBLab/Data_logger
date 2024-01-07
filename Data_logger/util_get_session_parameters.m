function util_get_session_parameters(app)
%update app properties
app.PROJECT_ROOT_DIR = app.Project_homedirectoryEditField.Value;
app.SUBJECT_ID = app.SessionsubjectDropDown.Value;
app.TIMEPOINT = app.TimePointSpinner.Value;
app.CONDITION = app.ConditionDropDown.Value;
app.ANESTHESIA = app.AnesthesiaDropDown.Value;
app.FOV = app.FOVSpinner.Value;
app.LABELING = app.LabelingDropDown.Value;
app.PHARMACOL = app.PharmacolDropDown.Value;
app.STIM = app.StimDropDown.Value;
end