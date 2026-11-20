function ephy_file = mse_findEphy(File_path, Mouse_ID, Task, varargin)

% FUNCTION ephy_file = mse_findEphy(File_path, Mouse_ID, Task, Stage, Phase)
% Extract the .rhd file path of the trial corresponding to inputs from the
% inputsVector excel file
% INPUTS:
%   - File_path: path to the folder where there is all mice folder each
%     containing inputsVector
%   - Mouse_ID: Identification of the mouse
%   - Task: Behavioral Task you want to import, specified in inputs_Vector
%     table
%   Optionnal:
%    - 'Stage', 'value'
%    - 'Phase', 'value'
% OUTPUT:
%   - Path to the .rhd file containing raw data of the trial
% IMPORTANT
%   Inputs of the function need to indicate a single specific file to import
%   in inputsVector
%
% Matthieu Aguilera

% Varagin parameters
p = inputParser;

addParameter(p, 'Stage', nan);
addParameter(p, 'Phase', nan);

parse(p, varargin{:});

Inparam = p.Results;


% Control if the good number of inputs is given
if nargin < 3
    disp('Provide Good number of inputs');
    return
end
% elseif nargin > 5
%     disp('Provide Good number of inputs');
%     return
% end

% Import inputsVector excel table
trialList = readtable([File_path, filesep, Mouse_ID, filesep, [Mouse_ID,'_inputsVector']], 'VariableNamingRule', 'preserve');

% select the line of the table corresponding to inputs parameters

% if 3 parameters, select THE line corresponding to the task
if anynan(Inparam.Stage) && anynan(Inparam.Phase)
    trial_row = find(ismember(trialList.Task, Task));

    % if 4 parameters, select THE line corresponding to the task and phase or stage
elseif ~anynan(Inparam.Stage) && anynan(Inparam.Phase)
    trial_row = find(ismember(trialList.Task, Task) & ismember(trialList.Stage, Inparam.Stage));

elseif anynan(Inparam.Stage) && ~anynan(Inparam.Phase)
    trial_row = find(ismember(trialList.Task, Task) & ismember(trialList.Phase, Inparam.Phase));    
    
    % if 5 parameters, select THE line corresponding to the task and phase and stage
elseif ~anynan(Inparam.Stage) && ~anynan(Inparam.Phase)
    trial_row = find(ismember(trialList.Task, Task) & ismember(trialList.Stage, Inparam.Stage) & ismember(trialList.Phase, Inparam.Phase));
end

if numel(trial_row)> 1
    disp('Lack inputs to identify good trial');
    return
end

ephy_file = trialList.FilePath_ePhysData{trial_row};
end
