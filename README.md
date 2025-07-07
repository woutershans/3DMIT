# 3D-Matrix Inductor Transformer (3D-MIT)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

<img src="3DMIT.jpg" alt="3D-MIT" width="450"/>


MATLAB implementation for the 3D-Matrix Inductor Transformer to be published in IEEE JESTPE. Provides all analytical models, derivations, datasets, design steps, and visualisations for the 3D-MIT.

## License
MIT Licensed - See [LICENSE](LICENSE)

## Citation
DOI: 10.1109/JESTPE.2025.3587336
_Citation will be added upon publication_

## Contents
- 3D-MIT flux and inductance model derivation, validation, and visualisation
- CLLC converter resonant tank design
- Parametric optimisation based on analytical and Ansys Maxwell results
- Data and visualisation of various experiments related to the 3D-MIT and the CLLC converter

## Key Features
- Reproducible analytical models
- Open datasets for verification
- Adaptable to other converter designs

## Repository Structure
- `/data`: All measurement and simulation datasets
- `/code/*.m files`: Analysis scripts ordered by paper sequence
- `run_all.m`: Master script to run all analyses sequentially
- `run.sh`: Code Ocean executable script (for capsule)
- `LICENSE`: MIT License terms

## Requirements
- MATLAB 2024a
- Global Optimization Toolbox (required for parametric optimisation)

## Usage

### Individual Script Execution
1. Clone repository
2. Run any `.m` file in MATLAB 2024a
   - Files follow paper's sequence
   - Executable independently

### Full Reproducible Run
```bash
# Run all analyses sequentially
matlab -batch "run_all"
