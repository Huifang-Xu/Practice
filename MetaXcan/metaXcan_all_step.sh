#!/bin/bash
#SBATCH --job-name=MetaXcan          # Job name (testBowtie2)
#SBATCH --partition=batch               # Partition name (batch, highmem_p, or gpu_p)
#SBATCH --ntasks=1                      # Run job in single task, by default using 1 CPU core on a single node
#SBATCH --cpus-per-task=4               # CPU core count per task, by default 1 CPU core per task
#SBATCH --mem=20G                        # Memory per node (4GB); by default using M as unit
#SBATCH --time=48:00:00                  # Time limit hrs:min:sec or days-hours:minutes:seconds
#SBATCH --export=NONE                   # Do not export any user’s explicit environment variables to compute node
#SBATCH --output=%x_%j.out              # Standard output log, e.g., testBowtie2_12345.out
#SBATCH --error=%x_%j.err               # Standard error log, e.g., testBowtie2_12345.err
#SBATCH --mail-user=username@uga.edu    # Where to send mail
#SBATCH --mail-type=END,FAIL            # Mail events (BEGIN, END, FAIL, ALL)


source activate imlabtools

inputFile=("/scratch/hx37930/rotation_ky/MetaXcan/Omega_3/w3FA_NMR_TFAP_resinv.M1.txt")
outputDir=("/scratch/hx37930/rotation_ky/MetaXcan/Omega_3")
prefix="w3FA_NMR_TFAP_resinv.M1"

step1="YES"
step2="YES"
step3="YES"
step4="YES"
step5="YES"

##############################################
#Step 1: run gwas_parsing to harmonize gwas summary statistics
##############################################
if [[ "$step1" == YES ]];
then
	python /scratch/hx37930/rotation_ky/summary-gwas-imputation/src/gwas_parsing.py \
		-gwas_file ${inputFile} \
		-liftover /scratch/hx37930/rotation_ky/MetaXcan/data_set/liftover/hg19ToHg38.over.chain.gz \
		-snp_reference_metadata /scratch/hx37930/rotation_ky/MetaXcan/data_set/reference_panel_1000G/variant_metadata.txt.gz METADATA \
		-output_column_map SNP variant_id \
		-output_column_map A1 effect_allele \
		-output_column_map A2 non_effect_allele \
		-output_column_map BETA effect_size \
		-output_column_map P pvalue \
		-output_column_map CHR chromosome \
		--chromosome_format \
		-output_column_map BP position \
		-output_column_map FRQ frequency \
		--insert_value sample_size 114999 --insert_value n_cases 114999 \
		-output_order variant_id panel_variant_id chromosome position effect_allele non_effect_allele frequency pvalue zscore effect_size standard_error sample_size n_cases \
		-output ${outputDir}/01.gwas_parsing.${prefix}.txt.gz
	echo "Done:Step 1"
fi

##############################################
#Step 2: Imputation takes all variants from the GTEx reference in a chromosomal region and impute missing GWAS variants
##############################################
if [[ "$step2" == YES ]];
then
	mkdir -p ${outputDir}/02.summary_imputation
	for i in {1..22}
	do
		python /scratch/hx37930/rotation_ky/summary-gwas-imputation/src/gwas_summary_imputation.py \
			-by_region_file /scratch/hx37930/rotation_ky/MetaXcan/data_set/eur_ld.bed.gz \
			-gwas_file ${outputDir}/01.gwas_parsing.${prefix}.txt.gz \
			-parquet_genotype /scratch/hx37930/rotation_ky/MetaXcan/data_set/reference_panel_1000G/chr${i}.variants.parquet \
			-parquet_genotype_metadata /scratch/hx37930/rotation_ky/MetaXcan/data_set/reference_panel_1000G/variant_metadata.parquet \
			-window 100000 \
			-parsimony 7 \
			-chromosome ${i} \
			-regularization 0.1 \
			-frequency_filter 0.01 \
			-sub_batches 10 \
			-sub_batch 0 \
			--standardise_dosages \
			-output ${outputDir}/02.summary_imputation/${prefix}_chr${i}_sb0_reg0.1_ff0.01_by_region.txt.gz
	done
	echo "Done:Step 2"
fi

##############################################
#Step 3: Imputation post-processing
##############################################
if [[ "$step3" == YES ]];
then
	python /scratch/hx37930/rotation_ky/summary-gwas-imputation/src/gwas_summary_imputation_postprocess.py \
		-gwas_file ${outputDir}/01.gwas_parsing.${prefix}.txt.gz \
		-folder ${outputDir}/02.summary_imputation \
		-pattern ${prefix}_* \
		-parsimony 7 \
		-output ${outputDir}/03.imputed_${prefix}.txt.gz
	echo "Done:Step 3"
fi

##############################################
#Step 4: run SPrediXcan.py for one tissue
##############################################
if [[ "$step4" == YES ]];
then
	mkdir -p ${outputDir}/04.SPrediXcan_tissues
	for tissue in `cat /scratch/hx37930/rotation_ky/MetaXcan/shell/tissue.list`
	do
		python /scratch/hx37930/rotation_ky/MetaXcan/software/SPrediXcan.py \
			--gwas_file ${outputDir}/03.imputed_${prefix}.txt.gz \
			--snp_column panel_variant_id \
			--effect_allele_column effect_allele \
			--non_effect_allele_column non_effect_allele \
			--zscore_column zscore \
			--model_db_path /scratch/hx37930/rotation_ky/MetaXcan/data_set/models/eqtl/mashr/mashr_${tissue}.db \
			--covariance /scratch/hx37930/rotation_ky/MetaXcan/data_set/models/eqtl/mashr/mashr_${tissue}.txt.gz \
			--keep_non_rsid \
			--additional_output \
			--model_db_snp_key varID \
			--throw \
			--output_file ${outputDir}/04.SPrediXcan_tissues/${prefix}__PM__${tissue}.csv
	done
	echo "Done:Step 4"
fi

##############################################
#Step 5: run SMulTiXcan combining all tissues
##############################################
if [[ "$step5" == YES ]];
	then
		python /scratch/hx37930/rotation_ky/MetaXcan/software/SMulTiXcan.py \
		--models_folder /scratch/hx37930/rotation_ky/MetaXcan/data_set/models/eqtl/mashr \
		--models_name_pattern "mashr_(.*).db" \
		--snp_covariance /scratch/hx37930/rotation_ky/MetaXcan/data_set/models/gtex_v8_expression_mashr_snp_smultixcan_covariance.txt.gz \
		--metaxcan_folder ${outputDir}/04.SPrediXcan_tissues/ \
		--metaxcan_filter "${prefix}__PM__(.*).csv" \
		--metaxcan_file_name_parse_pattern "(.*)__PM__(.*).csv" \
		--gwas_file ${outputDir}/03.imputed_${prefix}.txt.gz \
		--snp_column panel_variant_id \
		--effect_allele_column effect_allele \
		--non_effect_allele_column non_effect_allele \
		--zscore_column zscore \
		--keep_non_rsid \
		--model_db_snp_key varID \
		--cutoff_condition_number 30 \
		--verbosity 7 \
		--throw \
		--output ${outputDir}/05.${prefix}_smultixcan.txt
	echo "Done:Step 5"
fi
