cd "1_R_scripts"
echo "Start Model Reference analysis"
echo "Start 1.R_Analyses_data.R"
R CMD BATCH 1.R_Analyses_data.R
echo "Start 2.R_Analyses_Model_data.R" 
R CMD BATCH 2.R_Analyses_Model_data.R
echo "Start 3.R_Analyses_Validation_data.R"
R CMD BATCH 3.R_Analyses_Validation_data.R
echo "Done."
pause