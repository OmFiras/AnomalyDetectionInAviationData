function mat2txt(matFile, filename, flightID)
mat = load(matFile);
fieldNames = fieldnames(mat);

oneD = {};
k = 1;
moreD = {};
l = 1;

% append data to the file
fileID = fopen(filename, 'at');

% loop to find out which elements are of oneD
for index = 1 : numel(fieldNames)
    if strcmp(fieldNames{index}, 'StartTimeVec') || strcmp(fieldNames{index}, 'BITARRAY1') || strcmp(fieldNames{index}, 'BITARRAY2') ...
            || strcmp(fieldNames{index}, 'noScale')
        continue;
    end
    %     X = sprintf('Looking at %s', fieldNames{index});
    %     disp(X);
    stuff = mat.(fieldNames{index});
    if size(stuff.data, 2) == 1
        % write the feature item to a txt file in the format to be loaded
        % in DB
        oneD{k} = fieldNames{index};
        k = k + 1;
    else
        moreD{l} = fieldNames{index};
        l = l + 1;
    end
end

innerFields = {'data', 'scale',  'offset', 'Rate', 'Type',  'Units', 'Description', 'Alpha'};

% denotes NULL in sql
slashN = '\N';

% field order in feature table - DB
% fname, data, scale, offset, Rate, Type, Units, Description, Alpha,
% flightID

for index = 1 : length(oneD)
    innerStructure = mat.(oneD{index});
    str = sprintf('%s', oneD{index});
    for i = 1 : length(innerFields)
        if isfield(innerStructure, innerFields{i})
            
            value = innerStructure.(innerFields{i});
            
            % convert everything to string - dep on the type of 'value'
            % i == 1 means that it's the data matrix
            if i == 1
                value = mat2str(value, 'class');
            elseif isnumeric(value)
                value = num2str(value);
            end
            
            newline = sprintf('\n');
            % do this only for items that are NOT 'data'
            if i ~= 1
                % replace new line characters, if any, in 'value'
                value = strrep(value, newline, ' ');
            end
            
            if ~strcmp(value, '')
                str = sprintf('%s~~~%s', str, value);
            else
                str = sprintf('%s~~~%s', str, slashN);
            end
        else
            str = sprintf('%s~~~%s', str, slashN);
        end
    end
    str = sprintf('%s~~~%s', str, num2str(flightID));
    fprintf(fileID, '%s\r\n', str);
end

fclose(fileID);

end