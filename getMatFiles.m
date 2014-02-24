function getMatFiles(path, txtFileName, flightID)
% get all mat files from a given directory and convert them to txt format

list = dir(path);
list([list.isdir])= []; %Remove all directories

% list has name, date, bytes, isdir and datenum fields

for index  = 1 : length(list)
    extnIdx = find(list(index).name == '.', 1, 'last');
    
    totalPath = sprintf('%s/%s', path, list(index).name);
    
    disp(totalPath);
    
    % if it's a *.mat file - then call mat2txt function
    if strcmp(list(index).name(extnIdx : end), '.mat')
        mat2txt(totalPath, txtFileName, flightID);
    end
end

end