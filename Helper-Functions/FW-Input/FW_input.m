function FW_input(FW,path)
    %%% Add path to Input Comments
    %addpath('../Helper-Functions/FW-Input-Comments/')
    
    %%% Create file
    fid = fopen(path, 'w');

    %%% Loop through elements in FW
    % Get all field names
        fields = fieldnames(FW);

    %%% Loop
    for j = 1:numel(fields)
        %%% Get name of parameter and associated value
            param = fields{j};
            value = FW.(param);

        %%% Cases: Double, Int, String, or Header (Logical) Text
            % Case 1: Is an integer (ie- params that must be an int)
            if isa(value, 'int64') || isa(value, 'int8')
                line = strcat(param, " = ",string(value),"\n");
                fprintf(fid,line);
           
            % Case 2: Is a string/character
            elseif isstring(value)||ischar(value)||iscellstr(value)
                line = strcat(param, " = ",string(value),"\n");
                fprintf(fid,line);

            % Case 3: Is a double (ie- params that must be a double)
            elseif isa(value, 'double')
                % Need to ensure decimal place for FORTRN
                    value_s = string(value);
                    if ~contains(value_s, '.')
                       value_s = strcat(value_s, '.0');
                    end
                % Add to line after a adjusment
                line = strcat(param, " = ",value_s,"\n");
                fprintf(fid,line);

            % Class 4: Is a header (see functions in Helper-Functions) 
            elseif value == true
                feval(param(2:end),fid)

            else
                disp(['Could not write', char(param)']);
            end      
    end

    %%% Create file
        fclose(fid);
end




