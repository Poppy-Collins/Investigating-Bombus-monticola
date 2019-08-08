#!/bin/bash

### IMPORTANT: To run this code on a Mac OS, the following files need to be included within the home folder—1. the sampling bias file (.asc); 2. Species occurrence file (.csv); 3. folder containing the full set of variables to be analysed (.asc); 4. This shell/bash script (AutoForTuneAndEval.sh) and AutoForVariableRemoval.sh; 5. ENMTools_1.3 downloaded from “http://enmtools.blogspot.sg/“ (Warren et al. 2010); 6. maxent.jar and maxent.bat downloaded from “https://www.cs.princeton.edu/~schapire/maxent/“ (Phillips et al., 2006, 2008). To perform the analyses (on Mac OS), open terminal and type “./AutoForVariableRemoval.sh” followed by the enter key. If permission is required, type “chmod +x” enter, then “./AutoForVariableRemoval.sh” enter again. Email zengyiwen@u.nus.edu for further clarification ####

mkdir best_iterated_models
envlayer=variables  # folder created which contains all the environmental variables (in .asc format) to run the reiterative variable removal process on #
models_csv=model_selection_sample.csv
prev_score=10000000
score=$(echo $prev_score - 1 | bc)
count=1

while [ $(echo "$score < $prev_score" | bc) -le 1 ] 
do
	echo "$score newScore vs oldScore $prev_score - Keep going."
	prev_score=$score
	./AutoForVariableSelection.sh
	score=$(cat iteration_info/best_model_score)
	echo $score
	echo $envlayer/$(tail -n1 iteration_info/attribute_order)

	# remove the stupidest attribute
	rm $envlayer/$(tail -n1 iteration_info/attribute_order).asc
	rm $models_csv

	# this is to save the model projections and stuff #
	cp -R -n $(cat iteration_info/best_model_dir.txt) best_iterated_models/$count
	count=`expr $count + 1`

done

