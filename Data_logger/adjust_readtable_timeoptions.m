function    opts = adjust_readtable_timeoptions(path_to_table,table_vars,fmt)
%modify table time reading format

%%

opts = detectImportOptions(path_to_table);
opts = setvaropts(opts,table_vars,...
    'DatetimeFormat',fmt);



