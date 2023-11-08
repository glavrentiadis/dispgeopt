function [rup_loc_std,rup_ax_ratio] = input_rupture_loc_unc(flag_ax_ratio)
% Dialog box for rupture location uncertainty
%
% Input arguments:
%   flag_ax_ratio (boolean): rupture location axes ratio
%
% Output arguments:
%   rup_loc_std    (double):   rupture location uncertainty (m)
%   rup_ax_ratio   (double):   principal rupture axes ratio

%default input
if nargin < 1; flag_ax_ratio=False; end

%window name
dlgtitle = 'Ruprue Location Input';

%input options
switch flag_ax_ratio
    case 0  %rupture location uncertainty
        prompt   = {'Enter rupture location uncertainty (m):'
                    'Enter along/perpendicular to strike ratio'};
        definput = {'1.0','1.0'};
        dims     = [1, 45; 1, 45];
        inpt     = inputdlg(prompt, dlgtitle, dims, definput);
        rup_loc_std    = str2double(inpt{1});
        rup_ax_ratio   = 1;
    case 1 %rupture location uncertainty and axes ratio
        prompt   = {'Enter rupture location uncertainty (m):'
                    'Enter along/perpendicular to strike ratio'};
        definput = {'1.0','1.0'};
        dims     = [1, 45; 1, 45];
        inpt     = inputdlg(prompt, dlgtitle, dims, definput);
        rup_loc_std    = str2double(inpt{1});
        rup_ax_ratio   = str2double(inpt{2});
end

end
