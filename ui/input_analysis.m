function [flag_analysis] = input_analysis(inputArg1,inputArg2)
%UI for analysis option

%window options
dlgtitle  = 'Analysis Options';
dlgprompt = 'Select analysis mode:';
%analysis options
list_opt = {'Deterministic Slip Measurement';'Probabilistic Slip Measurement';'Slip Uncertainty Quantification'};

%open list window
[flag_analysis] = listdlg('ListString',list_opt,'PromptString',dlgprompt,'Name',dlgtitle, ...
                    'SelectionMode','single','ListSize',[250,100]);

end