function mse_ICA_lowpass_EEGcleaning(Mouse_ID, Input)

% FUNCTION ch_info = mse_ICA_EEGcleaning(Mouse_ID, Input)
% This function will allow to perform ICA on raw EEG to remove ICs related
% to noise/movements
% INPUTS:
%   - Mouse_ID: ID of the animal
%   - Input: Input structure containing informations for loops about task,
%     phase and stage, this structure is detailed in Import Behavior EEG
%     pipeline
% OUTPUTS:
%   - ICA_EEG: Structure containing:
%       - info : different infos of the recording
%       - ch : ICA cleaned EEG signal for each channel
% The ch_info structure is automatically saved in the same file as EEGData
%
% Use this following App mse_ICA_cleaning

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

    % STARTING CONDITIONNAL LOOPS STAGE AND PHASE

    % When there is no Stage or Phase
    if ~isfield(Input, 'Stage') && ~isfield(Input, 'Phase')

        load([Folder_Task, filesep, 'ID', param.Mouse_ID, '_', param.Task, '_lowpass_EEG']); % Import EEGData structure
        load([Folder_Task, filesep, 'ID', param.Mouse_ID, '_', param.Task, '_ch_Info']); % Import ch_info structure
        assignin('base', 'lowpass_EEG', lowpass_EEG);
        assignin('base', 'ch_info', ch_info);

        waitfor(mse_ICA_cleaning_lowpass_EEG) % Run the app to select the faulty channels

        clean_EEG = evalin('base', 'clean_EEG');

        % Create ICA_EEG Structure
        ICA_EEG.info = lowpass_EEG.info;
        ICA_EEG.info.Signal_cleaned = 'lowpass';

        for ch = 1:numel(ch_info.ch_Vector)
            ICA_EEG.ch.(['ch',num2str(ch_info.ch_Vector(ch))]) = clean_EEG(ch,:);
        end


        % Saving ICA_EEG structure
        filename = [];
        filename = [Folder_Task, filesep, 'ID', param.Mouse_ID, '_', param.Task, '_ICA_EEG'];

        save(filename, 'ICA_EEG', '-v7.3')
        evalin('base', 'clear lowpass_EEG');
        evalin('base', 'clear ch_info');
        evalin('base', 'clear clean_EEG');

        % When there is Stage but no Phase
    elseif isfield(Input, 'Stage') && ~isfield(Input, 'Phase')

        for St = 1:numel(Input.Stage)
            param.Stage = [];
            param.Stage = Input.Stage{St};

            Folder_Stage = [];
            Folder_Stage = [Folder_Task, filesep, param.Stage];

            load([Folder_Stage, filesep, 'ID', param.Mouse_ID, '_', param.Task, '_', param.Stage, '_lowpass_EEG']); % Import EEGData structure
            load([Folder_Stage, filesep, 'ID', param.Mouse_ID, '_', param.Task, '_', param.Stage, '_ch_Info']); % Import ch_info structure
            assignin('base', 'lowpass_EEG', lowpass_EEG);
            assignin('base', 'ch_info', ch_info);

            waitfor(mse_ICA_cleaning_lowpass_EEG) % Run the app to select the faulty channels

            clean_EEG = evalin('base', 'clean_EEG');

            % Create ICA_EEG Structure
            ICA_EEG.info = lowpass_EEG.info;
            ICA_EEG.info.Signal_cleaned = 'lowpass';

            for ch = 1:numel(ch_info.ch_Vector)
                ICA_EEG.ch.(['ch',num2str(ch_info.ch_Vector(ch))]) = clean_EEG(ch,:);
            end


            % Saving ICA_EEG structure
            filename = [];
            filename = [Folder_Stage, filesep, 'ID', param.Mouse_ID, '_', param.Task, '_', param.Stage, '_ICA_EEG'];

            save(filename, 'ICA_EEG', '-v7.3')
            evalin('base', 'clear lowpass_EEG');
            evalin('base', 'clear ch_info');
            evalin('base', 'clear clean_EEG');
        end

        % When there is Phase but no Stage
    elseif  ~isfield(Input, 'Stage') && isfield(Input, 'Phase')


        for Ph = 1:numel(Input.Phase)
            param.Phase = [];
            param.Phase = Input.Phase{St};

            Folder_Phase = [];
            Folder_Phase = [Folder_Task, filesep, param.Phase];

            load([Folder_Phase, filesep, 'ID', param.Mouse_ID, '_', param.Task, '_', param.Phase, '_lowpass_EEG']); % Import EEGData structure
            load([Folder_Phase, filesep, 'ID', param.Mouse_ID, '_', param.Task, '_', param.Phase, '_ch_Info']); % Import ch_info structure
            assignin('base', 'lowpass_EEG', lowpass_EEG);
            assignin('base', 'ch_info', ch_info);

            waitfor(mse_ICA_cleaning_lowpass_EEG) % Run the app to select the faulty channels

            clean_EEG = evalin('base', 'clean_EEG');

            % Create ICA_EEG Structure
            ICA_EEG.info = lowpass_EEG.info;
            ICA_EEG.info.Signal_cleaned = 'lowpass';

            for ch = 1:numel(ch_info.ch_Vector)
                ICA_EEG.ch.(['ch',num2str(ch_info.ch_Vector(ch))]) = clean_EEG(ch,:);
            end


            % Saving ICA_EEG structure
            filename = [];
            filename = [Folder_Phase, filesep, 'ID', param.Mouse_ID, '_', param.Task, '_', param.Phase, '_ICA_EEG'];

            save(filename, 'ICA_EEG', '-v7.3')
            evalin('base', 'clear lowpass_EEG');
            evalin('base', 'clear ch_info');
            evalin('base', 'clear clean_EEG');
        end

        % When there is Phase and Stage
    elseif isfield(Input, 'Stage') && isfield(Input, 'Phase')

        % Create Stage folder
        for St = 1:numel(Input.Stage)
            param.Stage = [];
            param.Stage = Input.Stage{St};

            Folder_Stage = [];
            Folder_Stage = [Folder_Task, filesep, param.Stage];

            % Create Phase folder and EEGData
            for Ph = 1:numel(Input.Phase)
                param.Phase = [];
                param.Phase = Input.Phase{Ph};

                Folder_Phase = [];
                Folder_Phase = [Folder_Stage, filesep, param.Phase];

                load([Folder_Phase, filesep, 'ID', param.Mouse_ID, '_', param.Task, '_', param.Stage, '_', param.Phase, '_lowpass_EEG']); % Import EEGData structure
                load([Folder_Phase, filesep, 'ID', param.Mouse_ID, '_', param.Task, '_', param.Stage, '_', param.Phase, '_ch_Info']); % Import ch_info structure
                assignin('base', 'lowpass_EEG', lowpass_EEG);
                assignin('base', 'ch_info', ch_info);

                waitfor(mse_ICA_cleaning_lowpass_EEG) % Run the app to select the faulty channels

                clean_EEG = evalin('base', 'clean_EEG');

                % Create ICA_EEG Structure
                ICA_EEG.info = lowpass_EEG.info;
                ICA_EEG.info.Signal_cleaned = 'lowpass';

                for ch = 1:numel(ch_info.ch_Vector)
                    ICA_EEG.ch.(['ch',num2str(ch_info.ch_Vector(ch))]) = clean_EEG(ch,:);
                end


                % Saving ICA_EEG structure
                filename = [];
                filename = [Folder_Phase, filesep, 'ID', param.Mouse_ID, '_', param.Task, '_', param.Stage, '_', param.Phase, '_ICA_EEG'];

                save(filename, 'ICA_EEG', '-v7.3')
                evalin('base', 'clear lowpass_EEG');
                evalin('base', 'clear ch_info');
                evalin('base', 'clear clean_EEG');
            end
        end

    end
end




