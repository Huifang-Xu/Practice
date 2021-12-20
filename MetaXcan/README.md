# Introduction
This repo is used to document the steps and documentation for installing and running MetaXcan

# Installation
1. Install MetaXcan
```
cd $work_dict
mkdir MetaXcan
git clone https://github.com/hakyimlab/MetaXcan 
```
2. Install summary-gwas-imputation
```
mkdir summary-gwas-imputation
cd summary-gwas-imputation
git clone https://github.com/hakyimlab/summary-gwas-imputation
```
3. Conda activate environment
```
conda env create -f /scratch/hx37930/rotation_ky/MetaXcan/software/conda_env.yaml
conda activate imlabtools
```
# Download data
1. CAD test data (for run)
 ```
mkdir $CAD_testData
cd $CAD_testData
wget https://uchicago.app.box.com/s/us7qhue3juubq66tktpogeansahxszg9
tar -xzvpf sample_data.tar.gz
```
2. Data set (including all required data, models, and test data)
```
wget  https://zenodo.org/record/3657902/files/sample_data.tar?download=1
tar -xvpf sample_data.tar\?download\=1
mv sample_data.tar\?download\=1 data_set
```
3.Omega3 real data
```
cp /project/kylab/lab_shared/PUFA-GWAS/output/PUFA-GWAS/BOLT-LMM/results/M2/w3FA_NMR_resinv/BOLT1-statsFile-BgenSnps-m2 /scratch/hx37930/rotation_ky/MetaXcan/Omega_3
cp /project/kylab/lab_shared/PUFA-GWAS/output/PUFA-GWAS/PUFA-GWAS-replication/munge/UKB/w3FA_NMR_TFAP_resinv.M1.txt /scratch/hx37930/rotation_ky/MetaXcan/Omega_3 
```
# Tutorial of MetaXcan
1. Install MetaXcan: https://github.com/hakyimlab/MetaXcan
2. Run software: https://github.com/hakyimlab/MetaXcan/wiki/Tutorial:-GTEx-v8-MASH-models-integration-with-a-Coronary-Artery-Disease-GWAS
