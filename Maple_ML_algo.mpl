calc_integral := proc(expr, prediction_vector, idx)
    print(idx):
	# given an expression in prefix notation and a vector of probabilities, try sub-algorithm with highest probability until success 
	local indexes, algos, num_attempts, algo_order, i, result, start_time, end_time;

	indexes := [seq(i,i=1..9)]:
	algos := table(zip(`=`,indexes, [default, derivativedivides, parts, risch, norman, trager, parallelrisch, meijerg, gosper])):

#	expr := prefix_to_maple(prefix_expr);
	num_attempts := 1;
	algo_order := sort(prediction_vector, `>`, output=permutation);
	start_time := time();


	for i from 1 to 9 do
		try
			result := timelimit(20, int(expr, x, method=algos[algo_order[i]]));
		catch:
			next;
		end try:
      	if not has(result, int) then # algorithm was successful at integrating
			break;
      	end if:
		num_attempts += 1; # algorithm was not successful
	end do;
	end_time := time() - start_time;
	
	if i=10 then # failed integrating
		return [convert(Int(expr,x), string), [0, "FAIL"], 10, end_time];
	else:	
		return [convert(result, string), [algo_order[i], convert(algos[algo_order[i]], string)], num_attempts, end_time];
	end if;	
end proc:

print("start"):
currentdir(homedir):
# QUICK TEST DATA
# bwd := Import("Dataset/Test/BWD_test.json"):
# fwd := Import("Dataset/Test/FWD_test.json"):
# ibp := Import("Dataset/Test/IBP_test.json"):
# sub := Import("Dataset/Test/SUB_test.json"):
# risch := Import("Dataset/Test/RISCH_test.json"):

# test_data := [op(bwd), op(fwd), op(ibp), op(sub), op(risch)]:

# MAPLE TEST SUITE
test_data := Import("/home/barketr/TreeLSTM/Data/Maple Test Suite/Maple_test_suite_prefix.json"):

ML_results := Import("/home/barketr/TreeLSTM/Probabilities/Small Data/Maple Test Suite/TreeLSTM_probs.json"):
ML_results := ListTools:-Transpose(ML_results):  # changes results from a per-algorithm level to a per expression level

print("done reading"):

X := map(x->x[1], test_data):
print("numelems beginning", numelems(X)):
# y := map(x->x[3], test_data):

# # remove lookup, and elliptic
# y_test := map2(subsop,8=NULL,y):
# y_test := map2(subsop,9=NULL,y):
# y_test := map2(subsop,10=NULL,y):

# Convert Prefix to Maple
X_test := [Grid:-Seq(parse(X[i]), i=1..numelems(X))]:  

print("done converting"):

ints_TreeLSTM_regression := CodeTools:-Usage([Grid:-Seq(calc_integral(X_test[i], ML_results[i], i), i = 1 .. numelems(X_test))]):
print("numelems end", numelems(ints_TreeLSTM_regression)):
# print(ints_TreeLSTM_regression);
# save ints_TreeLSTM_regression, "/home/barketr/TreeLSTM/Data/Quick Test Data/Regression/test_results_MAPE.m":
Export("/home/barketr/TreeLSTM/Results/Small Data/Maple Test Suite/TreeLSTM_results.json", ints_TreeLSTM_regression):
print("Done"):