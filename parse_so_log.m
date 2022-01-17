function parse_so_log(log_name)
%Quick parser for log files from static optimization
%JJD

%Basics first
fid = fopen(log_name);
log_c = textscan(fid, '%s', 'delimiter', '\r');
log_c = log_c{1};
fclose(fid);

warn_ix = contains(log_c, '[warning]');
warn_msg = log_c(warn_ix);

%In parfor you can get mesh path warnings that dont' matter
warn_flag = any(contains(log_c, '[warning] StaticOptimization'));

%Check for failures, parse
if warn_flag
    warning('Some optimizer failures detected. Analyzing logs...');  
    t_fail_c = cell(length(warn_msg),1);
    t_fail_c(:) = {''};
    
    so_fail_msg = warn_msg(contains(warn_msg, '[warning] StaticOptimization.record:'));
    for a=1:length(so_fail_msg)
        t_fail = textscan(so_fail_msg{a}, '%s', 'delimiter', '=');
        t_fail_c{a} = strip(t_fail{1}{2}, '.'); %actually want as string, I think
    end
end

cout_ix = contains(log_c, '[cout] [info]');
cout_msg = log_c(cout_ix);

%Preallocate
timestep = nan(length(cout_msg),1);
constraint_violation = nan(length(cout_msg),1);
performance = nan(length(cout_msg),1);
converge_fail = nan(length(cout_msg),1);

for a=1:length(cout_msg)
    %In which my regexp weakness is glaringly obvious
    line_str = textscan(cout_msg{a}, '%s', 'delimiter', ' ', 'MultipleDelimsAsOne',1);
    timestep(a) = str2double(line_str{1}{7});
    performance(a) = str2double(line_str{1}{10});
    constraint_violation(a) = str2double(line_str{1}{14});
    %Check for this timestep in failures
    if warn_flag && any(contains(t_fail_c, line_str{1}{7}))
        converge_fail(a) = 1;
    else
        converge_fail(a) = 0;
    end
end

%Assemble and write
save_name = strrep(log_name, '.log', '_parsed.csv');
so_log_T = table(timestep, performance, constraint_violation, converge_fail);
writetable(so_log_T, save_name);
disp('Parsed and saved optimizer logs.');

