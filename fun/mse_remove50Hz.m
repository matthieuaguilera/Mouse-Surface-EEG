function mse_remove50Hz(Mouse_ID, Input, varargin)

% FUNCTION mse_remove50Hz(Mouse_ID, Input, varargin)
%
% This function will filter 50, 100 & 150Hz from signals
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

        filename_reref = [];

        filename_reref = [Folder_Task, filesep, 'ID', param.Mouse_ID, '_', param.Task, '_lowpass_EEG'];

        ch_info = []; lowpass_EEG = [];

        load(filename_reref); %Import re referenced EEG

        load([Folder_Task, filesep, 'ID', param.Mouse_ID, '_', param.Task, '_ch_Info']); % Import ch_info structure


        % Create EEG matrix for Laplacian Input
        EEG_flt = [];

        for ch = 1:numel(ch_info.ch_Vector)
            EEG_flt{ch} = lowpass_EEG.ch.(['ch',num2str(ch_info.ch_Vector(ch))]).EEG;
        end

        % Filter electric noise of Laplacian (50, 100, 150, 200 & 250Hz)

        params_remov50Hz = [];
        params_remov50Hz = struct(...
            'method', 'rmlinesmovingwinc from Chronux',...
            'removedFreq',[50 100 150],...
            'tapers',[3 5],...
            'Fs', lowpass_EEG.info.frequency_parameters.amplifier_sample_rate,...
            'fpass',[0 500],...
            'pad',1,...
            'tau',1,...
            'movingWindow', [4, 2.5, 2],...
            'win_step', [0.5, 0.5, 0.5] );

        for ch = 1:numel(ch_info.ch_Vector)
            for f = 1:numel(params_remov50Hz.removedFreq)
                EEG_flt{ch}=rmlinesmovingwinc(EEG_flt{ch}, [params_remov50Hz.movingWindow(f),params_remov50Hz.win_step(f)], 10, params_remov50Hz,[],'n',params_remov50Hz.removedFreq(f));
            end
        end

        % Create Laplacian_EEG structure

        lowpass_EEG.info.params_remov50Hz = params_remov50Hz;

        for ch = 1:numel(ch_info.ch_Vector)
            lowpass_EEG.ch.(['ch', num2str(ch_info.ch_Vector(ch))]).flt_EEG = EEG_flt{ch};
        end

        % Saving Laplacian_EEG structure
        save(filename_reref, 'lowpass_EEG', '-v7.3')

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % When there is Stage but no Phase
    elseif isfield(Input, 'Stage') && ~isfield(Input, 'Phase')

        for St = 1:numel(Input.Stage)
            param.Stage = [];
            param.Stage = Input.Stage{St};

            Folder_Stage = [];
            Folder_Stage = [Folder_Task, filesep, param.Stage];

            filename_reref = [];

            filename_reref = [Folder_Stage, filesep, 'ID', param.Mouse_ID, '_', param.Task, '_', param.Stage, '_lowpass_EEG'];

            ch_info = []; lowpass_EEG = [];

            load(filename_reref);

            load([Folder_Stage, filesep, 'ID', param.Mouse_ID, '_', param.Task, '_', param.Stage, '_ch_Info']); % Import ch_info structure


            % Create EEG matrix for Laplacian Input
            EEG_flt = [];

            for ch = 1:numel(ch_info.ch_Vector)
                EEG_flt{ch} = lowpass_EEG.ch.(['ch',num2str(ch_info.ch_Vector(ch))]).EEG;
            end

            % Filter electric noise of Laplacian (50, 100, 150, 200 & 250Hz)

            params_remov50Hz = [];
            params_remov50Hz = struct(...
                'method', 'rmlinesmovingwinc from Chronux',...
                'removedFreq',[50 100 ],...
                'tapers',[3 5],...
                'Fs', lowpass_EEG.info.frequency_parameters.amplifier_sample_rate,...
                'fpass',[0 500],...
                'pad',1,...
                'tau',1,...
                'movingWindow', [4, 2.5],...
                'win_step', [0.5, 0.5] );

            for ch = 1:numel(ch_info.ch_Vector)
                for f = 1:numel(params_remov50Hz.removedFreq)
                    EEG_flt{ch}=rmlinesmovingwinc(EEG_flt{ch}, [params_remov50Hz.movingWindow(f),params_remov50Hz.win_step(f)], 10, params_remov50Hz,[],'n',params_remov50Hz.removedFreq(f));
                end
            end

            % Create Laplacian_EEG structure

            lowpass_EEG.info.params_remov50Hz = params_remov50Hz;

            for ch = 1:numel(ch_info.ch_Vector)
                lowpass_EEG.ch.(['ch', num2str(ch_info.ch_Vector(ch))]).flt_EEG = EEG_flt{ch};
            end

            % Saving Laplacian_EEG structure
            save(filename_reref, 'lowpass_EEG', '-v7.3')
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % When there is Phase but no Stage
    elseif  ~isfield(Input, 'Stage') && isfield(Input, 'Phase')


        for Ph = 1:numel(Input.Phase)
            param.Phase = [];
            param.Phase = Input.Phase{St};

            Folder_Phase = [];
            Folder_Phase = [Folder_Task, filesep, param.Phase];

            filename_reref = [];

            filename_reref = [Folder_Phase, filesep, 'ID', param.Mouse_ID, '_', param.Task, '_', param.Phase, '_lowpass_EEG'];

            ch_info = []; lowpass_EEG = [];

            load(filename_reref);

            load([Folder_Phase, filesep, 'ID', param.Mouse_ID, '_', param.Task, '_', param.Phase, '_ch_Info']); % Import ch_info structure


            % Create EEG matrix for Laplacian Input
            EEG_flt = [];

            for ch = 1:numel(ch_info.ch_Vector)
                EEG_flt{ch} = lowpass_EEG.ch.(['ch',num2str(ch_info.ch_Vector(ch))]).EEG;
            end

            % Filter electric noise of Laplacian (50, 100, 150, 200 & 250Hz)

            params_remov50Hz = [];
            params_remov50Hz = struct(...
                'method', 'rmlinesmovingwinc from Chronux',...
                'removedFreq',[50 100],...
                'tapers',[3 5],...
                'Fs', lowpass_EEG.info.frequency_parameters.amplifier_sample_rate,...
                'fpass',[0 500],...
                'pad',1,...
                'tau',1,...
                'movingWindow', [4, 2.5],...
                'win_step', [0.5, 0.5] );

            for ch = 1:numel(ch_info.ch_Vector)
                for f = 1:numel(params_remov50Hz.removedFreq)
                    EEG_flt{ch}=rmlinesmovingwinc(EEG_flt{ch}, [params_remov50Hz.movingWindow(f),params_remov50Hz.win_step(f)], 10, params_remov50Hz,[],'n',params_remov50Hz.removedFreq(f));
                end
            end

            % Create Laplacian_EEG structure

            lowpass_EEG.info.params_remov50Hz = params_remov50Hz;

            for ch = 1:numel(ch_info.ch_Vector)
                lowpass_EEG.ch.(['ch', num2str(ch_info.ch_Vector(ch))]).flt_EEG = EEG_flt{ch};
            end

            % Saving Laplacian_EEG structure
            save(filename_reref, 'lowpass_EEG', '-v7.3')
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
                param.Phase = [];
                param.Phase = Input.Phase{Ph};

                Folder_Phase = [];
                Folder_Phase = [Folder_Stage, filesep, param.Phase];

                Start_trial = tic;

                filename_reref = [];

                filename_reref = [Folder_Phase, filesep, 'ID', param.Mouse_ID, '_', param.Task, '_', param.Stage, '_', param.Phase,'_lowpass_EEG'];

                ch_info = []; lowpass_EEG = [];

                load(filename_reref);

                load([Folder_Phase, filesep, 'ID', param.Mouse_ID, '_', param.Task, '_', param.Stage, '_', param.Phase, '_ch_Info']); % Import ch_info structure


                % Create EEG matrix for Laplacian Input
                EEG_flt = [];

                for ch = 1:numel(ch_info.ch_Vector)
                    EEG_flt{ch} = lowpass_EEG.ch.(['ch',num2str(ch_info.ch_Vector(ch))]).EEG;
                end

                % Filter electric noise of Laplacian (50, 100, 150, 200 & 250Hz)

                params_remov50Hz = [];
                params_remov50Hz = struct(...
                    'method', 'rmlinesmovingwinc from Chronux',...
                    'removedFreq',[50 100],...
                    'tapers',[3 5],...
                    'Fs', lowpass_EEG.info.frequency_parameters.amplifier_sample_rate,...
                    'fpass',[0 500],...
                    'pad',1,...
                    'tau',1,...
                    'movingWindow', [4, 2.5],...
                    'win_step', [0.5, 0.5] );

                for ch = 1:numel(ch_info.ch_Vector)
                    for f = 1:numel(params_remov50Hz.removedFreq)
                        EEG_flt{ch}=rmlinesmovingwinc(EEG_flt{ch}, [params_remov50Hz.movingWindow(f),params_remov50Hz.win_step(f)], 10, params_remov50Hz,[],'n',params_remov50Hz.removedFreq(f));
                    end
                end

                % Create Laplacian_EEG structure

                lowpass_EEG.info.params_remov50Hz = params_remov50Hz;

                for ch = 1:numel(ch_info.ch_Vector)
                    lowpass_EEG.ch.(['ch', num2str(ch_info.ch_Vector(ch))]).flt_EEG = EEG_flt{ch};
                end

                % Saving Laplacian_EEG structure
                save(filename_reref, 'lowpass_EEG', '-v7.3')

                Stop_trial = toc(Start_trial);

                disp(['Mouse ',param.Mouse_ID,' ',param.Stage,' ',param.Phase, ' done in ', num2str(Stop_trial/60),'min'])

            end
        end

    end
end