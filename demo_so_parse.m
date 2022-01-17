%Run static optimization on Rajagopal 2015 data and parse log file to find
%failure cases. 

%John J Davis IV
%IU Biomechanics Lab

import org.opensim.modeling.* 

so_config_file = 'so_setup.xml';
log_name = 'so_osimlog.log';

%Setup the Logger class to dump the log data to a file
Logger.addFileSink(log_name);

fprintf('Running static optimization: will take a bit because of the (intentional) optimizer failures...\n');
%SO will take much longer when there are many failures to converge

analyze_tool = AnalyzeTool(so_config_file);
tic;
analyze_tool.run();
toc;

%To clear for next file (necessary in a for loop over many files)
Logger.removeFileSink(); 

%Once in a while this can run into permission issues in parfor loops so a
%try-catch block helps avoid crashes.
try
   parse_so_log(log_name);
catch
   warning('Could not parse opensim log file!');
end


