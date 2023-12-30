# Data_logger
ScanImage automatization of data structure and project logging

This Matlab app allows to keep track of data acquired for a given project. This include description of subjects and acquisition sessions as well as creating a metadata wildcard for each piece of data acquired. The app is intended as an extension for ScanImage but can be used only for maintaining the data structure / directories.

# Installation
Simple clone repo (or just download and extract code) and add directory to Matlab path.

# Creating a project
Project settings are stored in a yaml file called ['project.yml'](project.yml). This file goes under PROJECT_ROOT_DIR/ which can be any directory of your choice. Fields in the 'project.yml' file are used to populate fields in the app tabs related to project (experimenter, project name, etc) and session (conditions, anesthetics, viruses, etc). Check the file to see supported options.

# Dependencies
Install [yaml tools](https://www.mathworks.com/matlabcentral/fileexchange/106765-yaml) and add to Matlab path.
