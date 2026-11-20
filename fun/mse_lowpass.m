function mse_lowpass(Mouse_ID, Input, varargin)

% FUNCTION mse_reref_lowpass(Mouse_ID, Input, varargin)
%
% This function will lowpass filter the EEG signal under 100Hz 
%
% INPUTS:
%   - Mouse_ID: ID of the animal
%   - Input: Input structure containing informations for loops about task,
%     phase and stage, this structure is detailed in Import Behavior EEG
%     pipeline
% OUTPUTS:
%   - reref_EEG: structure organized like EEGData but comporting the
%     filtered EEG
%     Saved automatically in the same folder as EEGData


% Varargin parameters
% p = inputParser;
%
% addParameter(p, 'ICA', 'n');
%
% parse(p, varargin{:});
%
% Inparam = p.Results;

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

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % When there is no Stage or Phase
    if ~isfield(Input, 'Stage') && ~isfield(Input, 'Phase')

        ch_info = [];

        EEGData = [];
        load([Folder_Task, filesep, 'ID', param.Mouse_ID, '_', param.Task, '_EEG']); % Import EEGData structure

        load([Folder_Task, filesep, 'ID', param.Mouse_ID, '_', param.Task, '_ch_Info']); % Import ch_info structure


        % Create EEG matrix for Laplacian Input
        EEG_mat = [];

        for ch = 1:numel(ch_info.ch_Vector)
            EEG_mat(ch,:) = EEGData.ch.(['ch',num2str(ch_info.ch_Vector(ch))]).raw_EEG;
        end

        % Lowpass Filter the Signal
        lowfilter = fir1(30, [100/500], 'low');

        for ch = 1:numel(ch_info.ch_Vector)
            EEG_flt(ch,:) = filtfilt(lowfilter, 1, EEG_mat(ch,:));
        end


        % Create Laplacian_EEG structure
        lowpass_EEG = [];
        lowpass_EEG.info = EEGData.info;


        for ch = 1:numel(ch_info.ch_Vector)
            lowpass_EEG.ch.(['ch', num2str(ch_info.ch_Vector(ch))]).EEG = EEG_flt(ch,:);
            %Reref_EEG.ch.(['ch', num2str(ch_info.ch_Vector(ch))]).flt_Lap = filtfilt(filt, 1, flt_Lap{ch}); % Filtering between 0.1 and 250Hz de denoised Laplacian
        end



        % Saving Laplacian_EEG structure
        filename = [];

        filename = [Folder_Task, filesep, 'ID', param.Mouse_ID, '_', param.Task, '_lowpass_EEG'];


        save(filename, 'lowpass_EEG', '-v7.3')

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % When there is Stage but no Phase
    elseif isfield(Input, 'Stage') && ~isfield(Input, 'Phase')

        for St = 1:numel(Input.Stage)
            param.Stage = [];
            param.Stage = Input.Stage{St};

            Folder_Stage = [];
            Folder_Stage = [Folder_Task, filesep, param.Stage];

            ch_info = [];

            EEGData = [];
            load([Folder_Stage, filesep, 'ID', param.Mouse_ID, '_', param.Task, '_', param.Stage, '_EEG']); % Import EEGData structure

            load([Folder_Stage, filesep, 'ID', param.Mouse_ID, '_', param.Task, '_', param.Stage, '_ch_Info']); % Import ch_info structure


            % Create EEG matrix for Laplacian Input
            EEG_mat = [];

            for ch = 1:numel(ch_info.ch_Vector)
                EEG_mat(ch,:) = EEGData.ch.(['ch',num2str(ch_info.ch_Vector(ch))]).raw_EEG;
            end

            % Lowpass Filter the Signal
            lowfilter = fir1(30, [100/500], 'low');

            for ch = 1:numel(ch_info.ch_Vector)
                EEG_flt(ch,:) = filtfilt(lowfilter, 1, EEG_mat(ch,:));
            end

            % rerefenricing EEG by substracting the mean of all channels


            % Create Laplacian_EEG structure
            lowpass_EEG = [];
            lowpass_EEG.info = EEGData.info;


            for ch = 1:numel(ch_info.ch_Vector)
                lowpass_EEG.ch.(['ch', num2str(ch_info.ch_Vector(ch))]).EEG = EEG_flt(ch,:);
                %Reref_EEG.ch.(['ch', num2str(ch_info.ch_Vector(ch))]).flt_Lap = filtfilt(filt, 1, flt_Lap{ch}); % Filtering between 0.1 and 250Hz de denoised Laplacian
            end

            % Saving ch_info structure
            filename = [];

            filename = [Folder_Stage, filesep, 'ID', param.Mouse_ID, '_', param.Task, '_', param.Stage, '_lowpass_EEG'];


            save(filename, 'lowpass_EEG', '-v7.3')
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % When there is Phase but no Stage
    elseif  ~isfield(Input, 'Stage') && isfield(Input, 'Phase')


        for Ph = 1:numel(Input.Phase)
            param.Phase = [];
            param.Phase = Input.Phase{St};

            Folder_Phase = [];
            Folder_Phase = [Folder_Task, filesep, param.Phase];

            ch_info = [];

            EEGData = [];
            load([Folder_Phase, filesep, 'ID', param.Mouse_ID, '_', param.Task, '_', param.Phase, '_EEG']); % Import EEGData structure

            load([Folder_Phase, filesep, 'ID', param.Mouse_ID, '_', param.Task, '_', param.Phase, '_ch_Info']); % Import ch_info structure


            % Create EEG matrix for Laplacian Input
            EEG_mat = [];

            for ch = 1:numel(ch_info.ch_Vector)
                EEG_mat(ch,:) = EEGData.ch.(['ch',num2str(ch_info.ch_Vector(ch))]).raw_EEG;
            end

            % Lowpass Filter the Signal
            lowfilter = fir1(30, [100/500], 'low');

            for ch = 1:numel(ch_info.ch_Vector)
                EEG_flt(ch,:) = filtfilt(lowfilter, 1, EEG_mat(ch,:));
            end

            % Create Laplacian_EEG structure
            lowpass_EEG = [];
            lowpass_EEG.info = EEGData.info;


            for ch = 1:numel(ch_info.ch_Vector)
                lowpass_EEG.ch.(['ch', num2str(ch_info.ch_Vector(ch))]).EEG = EEG_flt(ch,:);
                %Reref_EEG.ch.(['ch', num2str(ch_info.ch_Vector(ch))]).flt_Lap = filtfilt(filt, 1, flt_Lap{ch}); % Filtering between 0.1 and 250Hz de denoised Laplacian
            end



            % Saving ch_info structure
            filename = [];

            filename = [Folder_Phase, filesep, 'ID', param.Mouse_ID, '_', param.Task, '_', param.Phase, '_lowpass_EEG'];


            save(filename, 'lowpass_EEG', '-v7.3')
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
                try
                param.Phase = [];
                param.Phase = Input.Phase{Ph};

                Folder_Phase = [];
                Folder_Phase = [Folder_Stage, filesep, param.Phase];

                Start_trial = tic;

                ch_info = []; EEGData = [];

                load([Folder_Phase, filesep, 'ID', param.Mouse_ID, '_', param.Task, '_', param.Stage, '_', param.Phase, '_EEG']); % Import EEGData structure

                load([Folder_Phase, filesep, 'ID', param.Mouse_ID, '_', param.Task, '_', param.Stage, '_', param.Phase, '_ch_Info']); % Import ch_info structure


                % Create EEG matrix for Laplacian Input
                EEG_mat = [];

                for ch = 1:numel(ch_info.ch_Vector)
                    EEG_mat(ch,:) = EEGData.ch.(['ch',num2str(ch_info.ch_Vector(ch))]).raw_EEG;
                end

                % Lowpass Filter the Signal
                lowfilter = fir1(30, [100/500], 'low');

                for ch = 1:numel(ch_info.ch_Vector)
                    EEG_flt(ch,:) = filtfilt(lowfilter, 1, EEG_mat(ch,:));
                end


                % Create Laplacian_EEG structure
                lowpass_EEG = [];
                lowpass_EEG.info = EEGData.info;


                for ch = 1:numel(ch_info.ch_Vector)
                    lowpass_EEG.ch.(['ch', num2str(ch_info.ch_Vector(ch))]).EEG = EEG_flt(ch,:);
                    %Reref_EEG.ch.(['ch', num2str(ch_info.ch_Vector(ch))]).flt_Lap = filtfilt(filt, 1, flt_Lap{ch}); % Filtering between 0.1 and 250Hz de denoised Laplacian
                end

                % Saving ch_info structure
                filename = [];

                filename = [Folder_Phase, filesep, 'ID', param.Mouse_ID, '_', param.Task, '_', param.Stage, '_', param.Phase, '_lowpass_EEG'];


                save(filename, 'lowpass_EEG', '-v7.3')

                Stop_trial = toc(Start_trial);

                disp(['Mouse ',param.Mouse_ID,' ',param.Stage,' ',param.Phase, ' done in ', num2str(Stop_trial/60),'min'])

                catch
                    disp(['Error occured for mouse ',param.Mouse_ID,' ',param.Task,' ',param.Stage,' ',param.Phase])
                    continue
                end
            end
        end

    end
end