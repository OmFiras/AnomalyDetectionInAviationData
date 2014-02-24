function fexists = fieldexists(thestruct, thefield)

if ischar(thestruct)
    %could use [ string1 string2 ]; might be faster.
    todo = sprintf('getfield(%s,''%s'');', thestruct, thefield);
    fexists = 1; evalin('caller', todo, 'fexists=0;');
else
    %another poster suggested this: (seems to work faster when profiled)
    
    fexists = any( strcmp(fieldnames(thestruct), thefield) );
    
    % i happen to like this
    
    fexists = 1; eval('getfield(thestruct, thefield);', 'fexists=0;');
end;
