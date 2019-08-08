#!/bin/bash

### IMPORTANT: To run this code on a Mac OS, the following files need to be included within the home folder—1. the sampling bias file (.asc); 2. Species occurrence file (.csv); 3. folder containing the full set of variables to be analysed (.asc); 4. This shell/bash script (AutoForTuneAndEval.sh) and AutoForVariableRemoval.sh; 5. ENMTools_1.3 downloaded from “http://enmtools.blogspot.sg/“ (Warren et al. 2010); 6. maxent.jar and maxent.bat downloaded from “https://www.cs.princeton.edu/~schapire/maxent/“ (Phillips et al., 2006, 2008). To perform the analyses (on Mac OS), open terminal and type “./AutoForVariableRemoval.sh” followed by the enter key. If permission is required, type “chmod +x” enter, then “./AutoForVariableRemoval.sh” enter again. Email zengyiwen@u.nus.edu for further clarification ####

mkdir outputs
mkdir iteration_info
ENMTOOLS_HOME=ENMTools_1.4.4
speciesname=Bombus_monticola
samplesfile=B.monticola.csv # input the name of .csv species occurrence file here. format within this file should typical maxent format #
fadebyclamping=true 
outputformat=raw # raw format required to calculate AICc values #
models_csv=model_selection_sample.csv
simplification_csv=model_simplification_process.csv
envlayer=variables  # folder created which contains all the environmental variables (in .asc format) to run the reiterative variable removal process on #


# this is to run MaxEnt #
	for betamultiplier in $(seq 0.5 0.5 10)
	do
		for linear in {true,false}
		do
			for quadratic in {true,false}
			do
				for product in {true,false}
				do
					for threshold in {true,false}
					do
						for hinge in {true,false}
						do
							if [ $linear != "false" ] ||  \
								[ $quadratic != "false" ] || \
								[ $product != "false" ] || \
								[ $threshold != "false" ] || \
								[ $hinge != "false" ];
							then
							outputdir="outputs/env-$envlayer-beta-$betamultiplier-l-$linear-q-$quadratic-p-$product-t-$threshold-h-$hinge"
							mkdir -p $outputdir
								java -mx512m -jar maxent.jar \
									samplesfile=$samplesfile \
									environmentallayers=$envlayer \
									outputdirectory=$outputdir \
									betamultiplier=$betamultiplier \
									outputformat=$outputformat \
									linear=$linear \
									quadratic=$quadratic \
									product=$product \
									threshold=$threshold \
									hinge=$hinge \
									fadebyclamping=$fadebyclamping \
									-a -r

									col1=$(pwd)/$samplesfile
									col2=$outputdir/${speciesname}.asc
									col3=$outputdir/${speciesname}.lambdas
									echo $col1,$col2,$col3, >> $models_csv
							fi
						done
					done
				done
			done
		done
	done

# this is to run ENMTOOLS #
perl $ENMTOOLS_HOME/ENMTools_1.4.4.pl $models_csv

# this is to sort important variables
model_selection_csv=${models_csv%%.csv}_model_selection.csv
best_model=$(tail -n+2 $model_selection_csv | sort -n -t',' -k7 | head -n1)
best_model_score=$(echo $best_model | cut -d',' -f7)
best_model_dir=`dirname $(echo $best_model | cut -d',' -f2)`
echo "Best model score:" $best_model_score
echo "Directory:"  $best_model_dir
echo $best_model_score > iteration_info/best_model_score
echo $best_model_dir   > iteration_info/best_model_dir.txt
paste \
	<(head -n1 $best_model_dir/maxentResults.csv | tr , '\n' ) \
	<(tail -n1 $best_model_dir/maxentResults.csv | tr , '\n')  \
	| grep contribution \
	| sort -t$'\t' -k2 -n -r \
	| sed -e 's/ contribution.*//g' > iteration_info/attribute_order

# this is to write model simplification process #
col1=$envlayer/$(tail -n1 iteration_info/attribute_order)
col2=$best_model_dir
col3=$best_model_score
echo $col1,$col2,$col3, >> $simplification_csv




