function y = timerfun_new(period,abstime)
% Calculate number of runs
tx=round(abstime/period);
% Create array
evalin('base','T=[]');
% Set up timer with period and number of runs executing the callback below
t = timer('ExecutionMode','fixedrate', 'Period',period, 'TasksToExecute',tx, 'TimerFcn',@(x,y)timercallback);
% Start timer
start(t);
% Wait for timer to complete all it's runs
wait(t);
% Get T array from worker
y = evalin('base','T');

function timercallback(x,y)
% For every execution, log time
evalin('base','T=[T;datestr(now,''HH:MM:SS.FFF'')]')