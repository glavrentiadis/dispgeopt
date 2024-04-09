function [df_profs,fname,fpath] = open_dfprofinfo()
%UI to read slip profiles' data frame

%file extension
f_ext = {'*.txt;*.csv', 'Slip Profile Files (*.txt,*.csv)'
         '*.txt',       'Text Files (*.txt)';
         '*.csv',       'CSV Files (*.csv)';
         '*.*',         'All Files (*.*)'};

%ui file selection 
[fname, fpath] = uigetfile(f_ext, "Select Profile's Dataframe");
if fname == 0; error('User canceled the operation.'); end

%profile dataframe
df_profs = readtable(fullfile(fpath,fname));

end