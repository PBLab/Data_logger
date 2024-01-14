function str = util_validate_description_text(ori_str)

%% remove multiple lines and commas from text.
str = string( ori_str);
str = str.replace(",",";");
str = str.append(". ");
str = [str{:} ] ;

