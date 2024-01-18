function T1 = append_uneven_tables(T1,T2)
%append_uneven_tables matches the columns and append tables
%   Append tables with different number of columns by padding with empty
%   values.
%
%Inputs
%T1 tables with less columns
%T2 table with more columns
%
%Output
%T1 with T2 appended at the bottom, new columns are appended to the "right"
%of the last T1 column. We assume the order of the matching columns is
%identical.
%

%% check that the name of first n-columns is identical

T1_col_names = T1.Properties.VariableNames
T2_col_names = T2.Properties.VariableNames;
T2_col_type = varfun(@class, T2, 'OutputFormat', 'cell');

n_original_cols = numel(T1_col_names);
if any(~strcmp(T1_col_names,T2_col_names(1:n_original_cols)))
    error('Column names do not match')
end

n_col_diff = numel(T2_col_names)-n_original_cols;
n_T1_rows = size(T1,1);
for ci = 1:n_col_diff
    
    switch T2_col_type{n_original_cols+ci}
        case 'double'
            empty_val = NaN;
        case 'timestamp'
            empty_val = NaT;
        case 'categorical'
            empty_val = 'None';
    end
    empty_col = repmat(empty_val,n_T1_rows,1);
    T1.(T2_col_names{n_original_cols+ci}) = empty_col;
    
end