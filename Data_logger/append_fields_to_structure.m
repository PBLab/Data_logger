function s1 = append_fields_to_structure(s1,s2)
%functions appends fields of scalar arrays.

%% append fields form s2 into s1
f_names = fieldnames(s2);
for fi = 1 :numel(f_names)
    this_fieldname=f_names{fi};
    s1.(this_fieldname) = s2.(this_fieldname);
end