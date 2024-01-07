function util_preview_session_filestructure(app)


%%
util_get_session_parameters(app);
[session_str,session_dir_str]= util_create_session_name(app,0);


%% display tree
str=string; 
level_str = '-> ';
str = append(str, sprintf('%s',app.PROJECT_ROOT_DIR));
% str = append(str, sprintf('\n  %s%s',level_str,session_dir_str));
filedelim_idx = [0 strfind(session_dir_str,filesep) numel(session_dir_str{1})+1];
n_levels = numel(filedelim_idx);


for ii = 1 : n_levels-1
    frmt_str = ['\n' sprintf('%s%s',repmat('  ',1,ii+1),level_str) '%s'];
    dir_str = session_dir_str{1}(filedelim_idx(ii)+1:filedelim_idx(ii+1)-1);
    str = append(str,sprintf(frmt_str,dir_str));
end

%add fixed directories
ii=n_levels;
frmt_str = ['\n' sprintf('%s%s',repmat('  ',1,ii+1),level_str) '%s'];
str = append(str,sprintf(frmt_str,'anat'));
str = append(str,sprintf(frmt_str,'derivates'));
str = append(str,sprintf(frmt_str,'ophys'));

uialert(app.UIFigure,str,'File structure')