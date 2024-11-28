function [prjwin_opt,prjwin_info] = input_prjwin()
% Dialog box for projection window paramameters
% 
% Output arguments:
%   prjwin_opt:   projection window definition
%                   1: based on feature's linearity
%                   2: based on window size
%   prjwin_info:  projection window parameters


%number of samples
dlgtitle = 'Projection Window';
quest = 'Projection Window Definition:';
btn1 = 'Feature Linearity';
btn2 = 'Feature Size';
%projection window selection
answer = questdlg(quest,dlgtitle,btn1,btn2,btn1);

switch answer
    case btn1
        prjwin_opt = 1;
        prjwin_info = input_prjwinlin();
    case btn2
        prjwin_opt = 2;
        prjwin_info = input_prjwinsize();
end

end