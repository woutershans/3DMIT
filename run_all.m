% Master script for reproducible execution
function run_all

    % Clean environment
    close all;
    clc;
    warning('off', 'all');  % Turn off warnings (optional)

    % Add current project
    addpath(genpath(pwd));

    % Add Global Optimization Toolbox
    global_optim_path = fullfile(matlabroot, 'toolbox', 'globaloptim');
    if isfolder(global_optim_path)
        addpath(genpath(global_optim_path));
    else
        error('Global Optimization Toolbox not found at: %s', global_optim_path);
    end
    
    % List of all analysis scripts in execution order
    scripts = {
        'MIT_v0_DowellEquationModel'
        'MIT_v1a_InductanceModelDerivation'
        'MIT_v1b_InductanceModelValidation'
        'MIT_v1c_FluxWaveformsExample'
        'MIT_v2a_ConverterFHA'
        'MIT_v2b_InductancesOverview'
        'MIT_v2c_InductanceDesignCLLC'
        'MIT_v3a_ParametricOptimisationMatlab'
        'MIT_v3b_ParametricOptimisationAnsys'
        'MIT_v4a_ExperimentImpedances'
        'MIT_v4b_ExperimentConverterWaveforms'
        'MIT_v4c_ExperimentThermalProfile'
        'MIT_v4d_ExperimentConverterEfficiency'
    };
    
    % Run all scripts sequentially
    for i = 1:length(scripts)
        fprintf('Running %s...\n', scripts{i});
        run(scripts{i});
    end
    fprintf('All scripts completed successfully!\n');

    warning('on', 'all');  % Turn warnings back on
end