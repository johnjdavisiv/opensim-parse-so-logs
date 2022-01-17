# Parse OpenSim static optimization logs

This repo showcases a simple demo of a function I wrote to identify when static optimization fails when calling it through the MATLAB API. It is useful for batch processing in big for-loops.  

The demo data is from the Rajagopal 2015 model and I tweaked the setup to ensure that it fails on some, but not all, frames: it uses raw, unfiltered IK data, and tries to minimize the third power of muscle activation (which seems to induce more numerical instability and cause more optimizer failures).  

This script leverages the Logger() class introduced recently, so it may not work with older versions of OpenSim.

`parse_so_log.m` reads a .osim log file and spits out a .csv file with a column indicating which timesteps had static optimization failures. 
