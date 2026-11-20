# Mouse Surface EEG

MATLAB functions and apps to preprocess signals recorded with a **Neuronexus H32 EEG probe** in mice.

> **Note:** the pipeline is currently tailored to recordings made during specific behavioral tasks and will be made more versatile over time. In the meantime, the inner functions can be reused to build new pipelines.

## Associated publication

This code was designed and used for:

Aguilera M, Mathis C, Herbeaux K, Isik A, Faranda D, Battaglia D, Goutagny R. *40 Hz light stimulation restores early brain dynamics alterations and associative memory in Alzheimer's disease model mice.* Imaging Neuroscience 2025; 3: IMAG.a.70. [doi:10.1162/IMAG.a.70](https://doi.org/10.1162/IMAG.a.70)

## Prerequisites

- **MATLAB** with the Parallel Computing Toolbox (`parpool`/`parfor`)
- **Chronux toolbox**, required by some functions: https://chronux.org
- **One `input_Vector` Excel file per animal**, summarizing all information about each recording. It is loaded in MATLAB to generate the correct data files.

## Import and preprocessing pipeline

This pipeline imports EEG data recorded during behavioral tasks. For each mouse, it creates a folder organized by **Task / Phase / Stage**.

### 1. Create the `Input` structure

This structure holds the information needed to run all following scripts on the right recordings.

```matlab
Vector_Mouse_ID = {ID1, ID2, ID3, ID4};

Input.Task        = {'Novel_Object_Recognition'}; % Task names (cell array)
Input.Task_length = {600};                        % OPTIONAL: task duration (s), used if a time buffer is needed
Input.Path        = 'Path/to/data';               % Folder containing the mouse folders with the input_Vector Excel files;
                                                  % imported data will be saved here too
Input.Phase       = {'Sampling','Test'};          % OPTIONAL: for tasks split into phases (e.g. learning / recall)
Input.Stage       = {'4_months'};                 % OPTIONAL: for longitudinal tasks (e.g. {'4_months','postflickering'})
Input.Corenum     = feature('numcores');
```

### 2. Import the raw data

Raw `.rhd` files are imported and saved as MATLAB files, with channels ordered according to the H32 probe layout.

```matlab
parpool(Input.Corenum - 14); % Parallel pool; adjust to leave some cores free

Total_Start = tic;
parfor ID = 1:numel(Vector_Mouse_ID)
    mouse_start = tic;
    mse_Import_behavior(Vector_Mouse_ID{ID}, Input);
    mouse_end = toc(mouse_start);
    disp(['Mouse ', num2str(Vector_Mouse_ID{ID}), ' done in ', num2str(mouse_end/60), ' min'])
end
Total_end = toc(Total_Start);
disp(['Total time spent: ', num2str(Total_end/3600), ' hours'])
```

### 3. Select good channels

This step excludes faulty or noisy channels and creates a `ch_info` vector, which is then used to load the data in all further steps.

> In our study, a recording was discarded if more than 5 of the 30 channels were too noisy.

```matlab
for ID = 1:numel(Vector_Mouse_ID)
    mse_chinfo(Vector_Mouse_ID{ID}, Input);
end
```

### 4. Low-pass filter at 100 Hz

```matlab
parpool(16);

parfor ID = 1:numel(Vector_Mouse_ID)
    mse_lowpass(Vector_Mouse_ID{ID}, Input);
end
```

### 5. ICA cleaning

The 30 channels are decomposed into 20 independent components (ICs) to identify artifacts spread across several or all channels, such as movement artifacts. A dedicated app lets you select the noisy ICs, which are then removed from the signal.

```matlab
for ID = 1:numel(Vector_Mouse_ID)
    mse_ICA_lowpass_EEGcleaning(Vector_Mouse_ID{ID}, Input);
end
```

## Analyses

The ICA-cleaned signal was used for the analyses in Aguilera et al., 2025. Some of the analysis code is available here: https://github.com/FunSyCNRS/FunSy_Dynamics_fluidity.git

## Roadmap

This repository will be updated to make the code more versatile.
