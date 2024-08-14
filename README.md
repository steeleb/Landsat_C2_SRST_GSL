# Landsat Collection 2 Surface Reflectance and Temperature Acquisition hub

Workflow to acquire Landsat Collection 2 Surface Reflectance and Surface Temperature 
products for lakes and reservoirs from point locations or lake polygons. The output 
of this workflow is stored in your Google Drive as tabular summaries of band data 
for your area of interest.

This repository is covered by the MIT use license. We request that all downstream 
uses of this work be available to the public when possible.

Primary repository contact: B Steele <b dot steele at colostate dot edu>

## Repository Overview

This repository is powered by {targets}, an r-based workflow manager. In order 
to use this workflow, you must have a [Google Earth Engine account](https://earthengine.google.com/signup/) 
and have configured a [Google Cloud Project](https://developers.google.com/earth-engine/cloud/projects) 
and you will need to 
[download, install, and initialize gcloud](https://cloud.google.com/sdk/docs/install). 

## Confirm `gcloud` function

It is recommended to run the following command in your **zsh** terminal and 
follow the prompts in  your browser to ensure that your gcloud is set up correctly.

`earthengine authenticate`

Follow the prompts in your browser. When completed in the browser, your terminal 
will also read:

`Successfully saved authorization token.`

This token is valid for 7 days from the time of authentication. If this fails,
see the [common issues](https://github.com/rossyndicate/ROSS_RS_mini_tools/blob/main/helps/CommonIssues.md) or contact B for help troubleshooting.

## Completing the config.yml file

Configuration of the config.yml file is necessary for this workflow to function.
There is an example of a config file within the example_yml folder. See the comments within
the config.yml file for guidance on parameter definitions and how to format each
parameter.

## Running the workflow

When your configuration file is complete and you have successfully authenticated 
your Earth Engine account, you are ready to run the {targets} pipeline! There are 
two steps to this:

1.  update line 5 of the `_targets.R` file with the name of your config file

2.  run the `run_targets.Rmd` file

## Workflow output

This workflow will output one file for each spatial extent and each DSWE setting.
These data have not been filtered for basic QAQC of the Rrs values, for an example 
of that workflow, see this function. Additionally, inter-mission handoff corrections
have not yet been applied. These data should not be used for timeseries analysis
if you are including data from both the Landsat 4/5/7 era and Landsat 8/9 era without 
handoff coefficients applied. See XXX for examples of how to apply intermission 
handoffs for timeseries analysis.

## Folder architecture

 * _targets contains output of the _targets.R package and can be ignored.
 * example_yml contains some example yml files for running this workflow
 * data_acquisition contains the sourced functions in the _targets.R workflow, as well as an
   `in` and `out` folder which store end-user's data, though these files are not tracked (other
   than the WRS2 shapefile) by GitHub.