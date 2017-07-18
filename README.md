# TMSEEG
An online repository of the TMSEEG toolbox (http://www.tmseeg.com)

INTRODUCTION
-------------------
TMSEEG is a Matlab App designed for streamlined processing of EEG data 
collected during TMS application.  Processing steps are presented using a
GUI format with modularity.  

REQUIREMENTS
--------------------
TMSEEG was built on MATLAB v2013a, with use of EEGLAB v12.0.2.6b.  Both
EEGLAB and MATLAB support backward compatibility with more recent releases.

* MATLAB  - http://www.mathworks.com/products/matlab/
* EEGLAB  - http://sccn.ucsd.edu/eeglab/downloadtoolbox.php
* FASTICA - http://research.ics.aalto.fi/ica/fastica/code/dlcode.shtml
* tight_subplot.m - http://www.mathworks.com/matlabcentral/fileexchange/27991-tight-subplot-nh--nw--gap--marg-h--marg-w-

INSTALLATION
---------------------

TMSEEG is packages as a MATLAB App for easy installation.  For further 
instruction: 
http://www.mathworks.com/videos/packaging-and-installing-matlab-apps-70404.html

* Ensure that the MATLAB signal processing toolkit has path priority

MAINTAINER
--------------

Current Maintainers: 
* Matthew Frehlichx 
* Sravye Atluri

REPOSITORY WORKFLOW
--------------

We follow the GitHub workflow guidelines summarized by [Ben Sandofsky](https://sandofsky.com/blog/git-workflow.html). Please contact @cogsmac about significant changes you intend to make to local branches. 


GETTING STARTED
--------------

Visit the [wiki page](https://github.com/cogsmac/TMSEEG/wiki/Getting-Started) for links to [sample data sets](http://www.tmseeg.com/wp-content/uploads/2016/05/SampleData.zip) and the [offical tutorial](http://www.tmseeg.com/wp-content/uploads/2016/05/TMSEEG-Tutorial-v3.pdf). A couple main things to keep in mind  

1) TMSEEG toolbox requires [EEGLAB](https://sccn.ucsd.edu/eeglab/downloadtoolbox.php) to be installed
2) MATLAB is picky about [paths](http://www.mathworks.com/help/matlab/ref/path.html?s_tid=gn_loc_drop). After download, pay attention to how the paths are set as indicated by the tutorial and documentation. If you receive an error that a file is missing it is probably because either the dependencies are not installed or because the paths are not set correctly
3) If you don't want to install Git on your machine, you may download a .zip file of this whole repository. To download a .zip, clock the "download" button on the home page for this project. Extract the .zip file in a directory that is on your MATLAB path (for example, on a PC C:\Users\cogsmac\Documents\MATLAB or on a MAC ~/Documents/MATLAB). 
