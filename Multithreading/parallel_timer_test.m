clust = parcluster('local');


%% timer parameter
period1=0.05;
period2=0.25;
% Time to keep loops running
abstime=1;

%% create tasks
% job object = batch(cluster object, @function_name, n_output_arg, {x1, x2,
% xn} input_arg, batch_parameters);
obj1 = batch(clust, @timerfun_new, 1, {period1, abstime});
obj2 = batch(clust, @timerfun_new, 1, {period2, abstime});


%% submit

% Wait for the first job to complete
wait(obj1);
r1=fetchOutputs(obj1);
r1{1}
wait(obj2);
r2=fetchOutputs(obj2);
r2{1}



%% clean up
destroy(obj1);
destroy(obj2);
