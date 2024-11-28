function [flag_select] = input_pointselect()
%UI for specifing method for point selection


%window options
dlgtitle  = 'Selection Method';
dlgprompt = 'Select method of choosing points:';
%analysis options
list_opt = {'Manual (each iteration)';'Feature Length';'Feature Linearity'};

%open list window
flag_select = listdlg('ListString',list_opt,'PromptString',dlgprompt,'Name',dlgtitle, ...
                      'SelectionMode','single','ListSize',[250,100]);


end