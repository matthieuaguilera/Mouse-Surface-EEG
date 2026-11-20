function [EEGData, Multiport] = mse_RHD2EEGData(ephy_file, param, varargin)

% FUNCTION [EEGData, Multiport] = mse_RHD2EEGData(ephy_file, param, 'n_mice_recorded', 'probe_vector', 'time_buffer', 'Record_length')
% Will return a EEGData structure with raw EEG channel organized and info
% part recapitulating important information about the recording
% INPUTS:
%   - ephy_file: .rhd file path of the recording, output of mse_findEphy
%   - param: param structure created in IMPORT pipeline where details of the
%     task are summarized
%   OPTIONAL INPUTS:
%   For Optionnal input, write 'optionalParam', 'value'.
%   - n_mice_recorded = if it's a simultaneous recording of several mices,
%     specify the number of mices recorded; Defaut is 1 for single mouse
%     recording
%   - probe_vector = if the channel were not rearranged on Intan recording
%     software; Specify the vector for rearranging channel order; Replace
%     Intan customOrder
%     A custom Order adapted to H32EEG recorded with INTAN 32ch pre_amp is
%     available in the Toolbox named as H32EEG_customOrder
%   - time_buffer: 'y' or 'n', specify if a buffer is applied to the
%     recording at the beginning and end for example if 'trigger' is used in
%     Intan to record, default is 'n'
%   - Record_length: if time_buffer = 'y'; Duration of recording/Task in second to be able to
%     remove the end buffer
% OUTPUTS:
%   - EEGData: Asking when single mice recording structure containing info and raw EEG organized in good channel order
%   - Multiport: Asking when n_mice_recorded > 1, structure containing
%   EEGData structure of the different mice recorded, called by their ID
%
% Last Update: 18/10/2022
% Matthieu Aguilera 

% Varargin parameters
p = inputParser;

addParameter(p, 'n_mice_recorded', 1);
addParameter(p, 'probe_vector', nan);
addParameter(p, 'time_buffer', 'n');
addParameter(p, 'Record_length', nan);
addParameter(p, 'DesiredFS', 1000);
%addParameter(p, 'TimePeriod', nan);

parse(p, varargin{:});

Inparam = p.Results;

if strcmp(Inparam.time_buffer, 'y') && isnan(Inparam.Record_length)
    disp('Specify Record_length please')
    return
end

% Create chanList

chanOrderSuperf2Deep = single( 1:30 ) ;
nberChans = 30;

% Channel names    (--> structure organisation)
chanList = {};
for i=1:numel(chanOrderSuperf2Deep)
    chanList{i,1} = strcat('ch', num2str(chanOrderSuperf2Deep(i)) ) ;
end

% Open rhd file
[amplifier_channels, amplifier_data, t_board_adc, board_adc_data, t_amplifier, frequency_parameters, aux_input_channels, aux_input_data ,t_aux_input,...
    t_supply_voltage, supply_voltage_data, t_dig, board_dig_in_data] = mse_read_Intan_RHD2000_file_batch(ephy_file);

% Create Output
EEGData = []; Multiport = [];

if Inparam.n_mice_recorded == 1
    % IMPORT data
    EEGData={};

    % Organize EEGData structure
    EEGData.info.Animal_ID = param.Mouse_ID;

    % Summarize the task in one sentence in info structure
    if isfield(param, 'Task')
        if ~isfield(param, 'Stage') && ~isfield(param, 'Phase')
            EEGData.info.Experiment = param.Task;
        elseif ~isfield(param, 'Stage') && isfield(param, 'Phase')
            EEGData.info.Experiment = [param.Task,'_',param.Phase];
        elseif ~isfield(param, 'Phase') && isfield(param, 'Stage')
            EEGData.info.Experiment = [param.Task,'_',param.Stage];
        elseif isfield(param, 'Stage') && isfield(param, 'Phase')
            EEGData.info.Experiment = [param.Task,'_',param.Stage,'_',param.Phase];
        end
    end

    % Extract time and frequency parameters
    % Note that time variable like t_amplifier or t_aux_data still have the
    % buffer which is already removed in EEG and AUX data
    EEGData.info.frequency_parameters = frequency_parameters;
    EEGData.info.time.t_amplifier = t_amplifier;
    EEGData.info.time.t_aux_input = t_aux_input;
    EEGData.info.time.t_supply_voltage = t_supply_voltage;
    EEGData.supply.supply = supply_voltage_data;
    EEGData.info.time.t_board_adc = t_board_adc;
    EEGData.info.time.t_board_dig = t_dig;
    EEGData.board.board_adc_data = board_adc_data;
    EEGData.board.board_dig_in_data = board_dig_in_data;

    % Extract corrected Time when buffer is removed
    if strcmp(Inparam.time_buffer, 'y')
        EEGData.info.BufferCorrected_time.t_amplifier = t_amplifier([find(t_amplifier == 0):find(t_amplifier == Inparam.Record_length)]);
        EEGData.info.BufferCorrected_time.t_aux_input = t_aux_input([find(t_aux_input >= 0, 1, 'first'):find(t_aux_input <= Inparam.Record_length,1,'last')]);
    end

    % Extract Gyroscope data for head movement
    if strcmp(Inparam.time_buffer, 'y')
        for ax = 1:3
            EEGData.aux.(['AUX', num2str(ax)])= aux_input_data(ax,[find(t_aux_input >= 0, 1, 'first'):find(t_aux_input <= Inparam.Record_length,1,'last')]); % Buffer removed by indexing start and end on time variable
        end
    else
        for ax = 1:3
            EEGData.aux.(['AUX', num2str(ax)])= aux_input_data(ax,:);
        end
    end

    % Extract native order and custom order from INTAN metaData
    nativeOrder = [];
    for i=1:numel(amplifier_channels); nativeOrder(i,1) = amplifier_channels(i).native_order ; end
    customOrder = [];
    if ~isnan(Inparam.probe_vector)
        customOrder = Inparam.probe_vector;
    else
        for i=1:numel(amplifier_channels); customOrder(i,1) = amplifier_channels(i).custom_order ; end
    end

    % Reorganize EEG channels based on custom order from INTAN recording software
    for i=1:numel(chanList)
        % copy & transfo from microvolts to millivolts (/1000)
        if strcmp(Inparam.time_buffer, 'y')
            EEGData.ch.(chanList{i}).raw_EEG = amplifier_data(find( customOrder == nativeOrder(i)),[find(t_amplifier == 0):find(t_amplifier == Inparam.Record_length)])./1000; % Buffer removed by indexing start and end on time variable
        else
            EEGData.ch.(chanList{i}).raw_EEG = amplifier_data(find( customOrder == nativeOrder(i)),:)./1000;
        end
        EEGData.ch.(chanList{i}).nativeOrder = amplifier_channels(find( customOrder == nativeOrder(i))).native_order ;
    end

    % Sampling Frequency Correction if needed
    if Inparam.DesiredFS < EEGData.info.frequency_parameters.amplifier_sample_rate
        Ratio = EEGData.info.frequency_parameters.amplifier_sample_rate/Inparam.DesiredFS;

        for i=1:numel(chanList)
            EEGData.ch.(chanList{i}).raw_EEG = resample(EEGData.ch.(chanList{i}).raw_EEG, 1, Ratio);
        end

        for ax = 1:3
            EEGData.aux.(['AUX', num2str(ax)])= resample(EEGData.aux.(['AUX', num2str(ax)]), 1, Ratio);
        end

        EEGData.info.BufferCorrected_time.t_amplifier = downsample(EEGData.info.BufferCorrected_time.t_amplifier, Ratio);
        EEGData.info.BufferCorrected_time.t_aux_input = downsample(EEGData.info.BufferCorrected_time.t_aux_input, Ratio);
    end

elseif Inparam.n_mice_recorded > 1
    %disp('Function not adapted yet for multimouse recording')
    %return

    % Determine list of ports for further separate data depending on the
    % recording port
    Port = {'A', 'B', 'C', 'D'};
    amp_portList = []; aux_portList = [];
    for p = 1:numel(amplifier_channels)
        amp_portList{p} = amplifier_channels(p).port_prefix;
    end
    for p = 1:numel(aux_input_channels)
        aux_portList{p} = aux_input_channels(p).port_prefix;
    end

    Multiport = [];

    for ID = 1:numel(param.Mouse_ID)
        % Extract time and frequency parameters
        Multiport.(['ID',param.Mouse_ID{ID}]).info.frequency_parameters = frequency_parameters;
        Multiport.(['ID',param.Mouse_ID{ID}]).info.time.t_amplifier = t_amplifier;
        Multiport.(['ID',param.Mouse_ID{ID}]).info.time.t_aux_input = t_aux_input;
        Multiport.(['ID',param.Mouse_ID{ID}]).info.time.t_supply_voltage = t_supply_voltage;
        Multiport.(['ID',param.Mouse_ID{ID}]).supply.supply = supply_voltage_data;
        Multiport.(['ID',param.Mouse_ID{ID}]).info.time.t_board_adc = t_board_adc;
        Multiport.(['ID',param.Mouse_ID{ID}]).info.time.t_board_dig = t_dig;
        Multiport.(['ID',param.Mouse_ID{ID}]).board.board_adc_data = board_adc_data;
        Multiport.(['ID',param.Mouse_ID{ID}]).board.board_dig_in_data = board_dig_in_data;

        % Extract corrected Time when buffer is removed
        if strcmp(Inparam.time_buffer, 'y')
            Multiport.(['ID',param.Mouse_ID{ID}]).info.BufferCorrected_time.t_amplifier = t_amplifier([find(t_amplifier == 0):find(t_amplifier == Inparam.Record_length)]);
            Multiport.(['ID',param.Mouse_ID{ID}]).info.BufferCorrected_time.t_aux_input = t_aux_input([find(t_aux_input >= 0, 1, 'first'):find(t_aux_input <= Inparam.Record_length,1,'last')]);
        end

        % Extract data for only this mouse
        temp_amplifier_channels = []; temp_amplifier_data = []; temp_aux_input_channels = []; temp_aux_input_data = [];

        temp_amplifier_channels = amplifier_channels(strcmp(amp_portList, Port{ID}) == 1);
        temp_amplifier_data = amplifier_data(strcmp(amp_portList, Port{ID}) == 1,:);
        temp_aux_input_channels = aux_input_channels(strcmp(aux_portList, Port{ID}) == 1);
        temp_aux_input_data = aux_input_data(strcmp(aux_portList, Port{ID}) == 1,:);


        % Extract Gyroscope data for head movement
        for ax = 1:numel(temp_aux_input_channels)
            if strcmp(Inparam.time_buffer, 'y')
                Multiport.(['ID',param.Mouse_ID{ID}]).aux.(['AUX', num2str(ax)])= temp_aux_input_data(ax,[find(t_aux_input >= 0, 1, 'first'):find(t_aux_input <= Inparam.Record_length,1,'last')]);
            else
                Multiport.(['ID',param.Mouse_ID{ID}]).aux.(['AUX', num2str(ax)])= temp_aux_input_data(ax,:);
            end
        end

        % Extract native order and custom order from INTAN metaData
        nativeOrder = [];
        for i=1:numel(temp_amplifier_channels); nativeOrder(i,1) = temp_amplifier_channels(i).native_order ; end
        customOrder = [];
        if ~isnan(Inparam.probe_vector)
            customOrder = Inparam.probe_vector;
        else
            for i=1:numel(temp_amplifier_channels); customOrder(i,1) = temp_amplifier_channels(i).custom_order ; end
        end


        % Reorganize EEG channels based on custom order from INTAN recording software
        for i=1:numel(chanList)
            % copy & transfo from microvolts to millivolts (/1000)
            if strcmp(Inparam.time_buffer, 'y')
                Multiport.(['ID',param.Mouse_ID{ID}]).ch.(chanList{i}).raw_EEG = temp_amplifier_data(find( customOrder == nativeOrder(i)),[find(t_amplifier == 0):find(t_amplifier == Inparam.Record_length)])./1000;
            else
                Multiport.(['ID',param.Mouse_ID{ID}]).ch.(chanList{i}).raw_EEG = temp_amplifier_data(find( customOrder == nativeOrder(i)),:)./1000;
            end
            Multiport.(['ID',param.Mouse_ID{ID}]).ch.(chanList{i}).nativeOrder = temp_amplifier_channels(find( customOrder == nativeOrder(i))).native_order ;
        end
    end

   % % Sampling Frequency Correction if needed
   %  if Inparam.DesiredFS < EEGData.info.frequency_parameters.amplifier_sample_rate
   %      Ratio = EEGData.info.frequency_parameters.amplifier_sample_rate/Inparam.DesiredFS;
   % 
   %      for i=1:numel(chanList)
   %          EEGData.ch.(chanList{i}).raw_EEG = resample(EEGData.ch.(chanList{i}).raw_EEG, 1, Ratio);
   %      end
   % 
   %      for ax = 1:3
   %          EEGData.aux.(['AUX', num2str(ax)])= resample(EEGData.aux.(['AUX', num2str(ax)]), 1, Ratio);
   %      end
   % 
   %      EEGData.info.BufferCorrected_time.t_amplifier = downsample(EEGData.info.BufferCorrected_time.t_amplifier, Ratio);
   %      EEGData.info.BufferCorrected_time.t_aux_input = downsample(EEGData.info.BufferCorrected_time.t_aux_input, Ratio);
   %  end


end

end

