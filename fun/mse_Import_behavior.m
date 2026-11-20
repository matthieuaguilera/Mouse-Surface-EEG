function mse_Import_behavior(Mouse_ID, Input)

% FUNCTION mse_Import_behavior(Mouse_ID, Input)
% This function create  EEGData
% containing raw data
% Made for running different mice in parpool
% INPUTS:
%   - Mouse_ID: ID of the animal
%   - Input: Input structure containing informations for loops about task,
%     phase and stage, this structure is detailed in Import Behavior EEG
%     pipeline
% OUTPUTS:
%   EEGData structure will automatically be saved in a file per mouse, task,
%   stage, phase in the path already indicated in Input structure
% FUNCTION
%   First loop is Mouse loop; the mouse ID is put in param structure that
%   will be the input structure for loops
%   if Mouse ID is numeric, it will be converted in string
% Use this following functions: mse_findEphy, mse_RHD2EEGData, mse_preprocflt
%
% NEED UPDATE WITH LAST VERSION OF mse_RHD2EEGDATA
    
param.Mouse_ID = []; % Reset the variable in param structure at each iteration, avoiding misoverwriting errors
    
    if isnumeric(Mouse_ID) == 1
        param.Mouse_ID = num2str(Mouse_ID);
    else
        param.Mouse_ID = Mouse_ID;
    end

for Ta = 1:numel(Input.Task)
    param.Task = [];
    param.Task = Input.Task{Ta};

    Folder_Task = [];
    Folder_Task = [Input.Path, filesep, param.Mouse_ID, filesep, param.Task];

    if ~exist(Folder_Task, 'file')
        mkdir(Folder_Task);
    end

    % STARTING CONDITIONNAL LOOPS STAGE AND PHASE

    % When there is no Stage or Phase
    if ~isfield(Input, 'Stage') && ~isfield(Input, 'Phase')

        ephy_file = mse_findEphy(Input.Path, param.Mouse_ID, param.Task); % finding the raw .rhd file of the recording based on inputsVector Excel

        EEGData = [];
        [EEGData, ~] = mse_RHD2EEGData(ephy_file, param, 'time_buffer', 'y', 'Record_length', Input.Task_length{Ta}); % Create EEGData structure from the raw Data

        filename = [Folder_Task, filesep, 'ID', param.Mouse_ID, '_', param.Task, '_EEG'];

        save(filename, 'EEGData', '-v7.3')

    % When there is Stage but no Phase
    elseif isfield(Input, 'Stage') && ~isfield(Input, 'Phase')

        for St = 1:numel(Input.Stage)
            param.Stage = [];
            param.Stage = Input.Stage{St};

            Folder_Stage = [];
            Folder_Stage = [Folder_Task, filesep, param.Stage];

            if ~exist(Folder_Stage, 'file')
                mkdir(Folder_Stage);
            end

            ephy_file = [];
            ephy_file = mse_findEphy(Input.Path, param.Mouse_ID, param.Task, 'Stage', param.Stage); % finding the raw .rhd file of the recording based on inputsVector Excel

            EEGData = [];
            [EEGData, ~] = mse_RHD2EEGData(ephy_file, param, 'time_buffer', 'y', 'Record_length', Input.Task_length{Ta}); % Create EEGData structure from the raw Data

            filename = [Folder_Stage, filesep, 'ID', param.Mouse_ID, '_', param.Task, '_', param.Stage, '_EEG'];

            save(filename, 'EEGData', '-v7.3')
        end

    % When there is Phase but no Stage    
    elseif  ~isfield(Input, 'Stage') && isfield(Input, 'Phase')

        disp('Script not adapted yet for these conditions, need review')

            for Ph = 1:numel(Input.Phase)
                param.Phase = [];
                param.Phase = Input.Phase{St};
                
                Folder_Phase = [];
                Folder_Phase = [Folder_Task, filesep, param.Phase];
                
                if ~exist(Folder_Phase, 'file')
                    mkdir(Folder_Phase);
                end
                
                ephy_file = mse_findEphy(Input.Path, param.Mouse_ID, param.Task, 'Phase', param.Phase); % finding the raw .rhd file of the recording based on inputsVector Excel
            
                EEGData = [];
                [EEGData, ~] = mse_RHD2EEGData(ephy_file, param, 'time_buffer', 'y', 'Record_length', Input.Task_length{Ta});; % Create EEGData structure from the raw Data
            
                filename = [Folder_Phase, filesep, 'ID', param.Mouse_ID, '_', param.Task, '_', param.Phase, '_EEG'];
                
                save(filename, 'EEGData', '-v7.3')
            end

    elseif isfield(Input, 'Stage') && isfield(Input, 'Phase')

        % Create Stage folder
        for St = 1:numel(Input.Stage)
            param.Stage = [];
            param.Stage = Input.Stage{St};

            Folder_Stage = [];
            Folder_Stage = [Folder_Task, filesep, param.Stage];

            if ~exist(Folder_Stage, 'file')
                mkdir(Folder_Stage);
            end

            % Create Phase folder and EEGData
            for Ph = 1:numel(Input.Phase)
                param.Phase = [];
                param.Phase = Input.Phase{Ph};

                Folder_Phase = [];
                Folder_Phase = [Folder_Stage, filesep, param.Phase];

                if ~exist(Folder_Phase, 'file')
                    mkdir(Folder_Phase);
                end

                ephy_file = [];
                ephy_file = mse_findEphy(Input.Path, param.Mouse_ID, param.Task, 'Stage', param.Stage, 'Phase', param.Phase); % finding the raw .rhd file of the recording based on inputsVector Excel

                EEGData = [];
                [EEGData, ~] = mse_RHD2EEGData(ephy_file, param, 'time_buffer', 'y', 'Record_length', Input.Task_length{Ta}); % Create EEGData structure from the raw Data

                filename = [Folder_Phase, filesep, 'ID', param.Mouse_ID, '_', param.Task, '_', param.Stage, '_', param.Phase, '_EEG'];
                %filename = ['C:\Users\electrophy7\Desktop\Test_function', filesep, 'ID', param.Mouse_ID, '_', param.Task, '_', param.Stage, '_', param.Phase, '_EEG'];
                save(filename, 'EEGData', '-v7.3')

            end
        end

    end
end