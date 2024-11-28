function [flag_samp,names_samp,list_opt] = input_uncertainty_opt(flag_rup_unc)
% List UI to select uncertainty options

%default input
if nargin < 1; flag_rup_unc = true; end

%window options
dlgtitle  = 'Uncertainty Options';
dlgprompt = 'Select uncertainty components:';
%uncertainty options
list_opt = {'Projection Points';'Projection Window';'Horizontal Location';'Vertical Location';'Rupture Location';'Rupture Azimuth'};

%input rupture uncertainty
if ~flag_rup_unc; list_opt = list_opt(1:4); end

%open list window
[indx,tf] = listdlg('ListString',list_opt,'PromptString',dlgprompt,'Name',dlgtitle, ...
                    'CancelString','No Selection','ListSize',[250,100]);

%initialize
flag_samp = false(1,6);
%update selection
if tf; flag_samp(indx) = true; end

%names of selected uncertainty options
names_samp = list_opt(flag_samp);
%names of selected uncertainty options
list_opt = list_opt';

end