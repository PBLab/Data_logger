# Data_logger
ScanImage automatization of data structure and project logging

This Matlab app allows to keep track of data acquired for a given project. This include description of subjects and acquisition sessions as well as creating a metadata wildcard for each piece of data acquired. The app is intended as an extension for ScanImage but can be used only for maintaining the data structure / directories.

The following tables (plain text, csv) are maintained by the app:

**subjects** - info about each experimental subject (species, strain, surgery / virus types, dob, etc).

**sessions** - describes experiment conditions (anesthesia, stimulus, field of views, timeopoints etc) as well as a unique acquisition_id to link to acquisition parameters. A relative path to the data is stored here too making it easier to move to the entire project tree to a different location while preserving access details to data. Post-acquisition details (quality estimation and notes are also stored here).

**acquisitions** - settings related to the type of acquisition perfomred (Movie/Stack/Arbitrary scan, frame rate, size, magnification etc).

# Installation
Simple clone repo (or just download and extract code) and add directory to Matlab path.

# Creating a project
Project settings are stored in a yaml file called ['project.yml'](project.yml). This file goes under PROJECT_ROOT_DIR/ which can be any directory of your choice. Fields in the 'project.yml' file are used to populate fields in the app tabs related to project (experimenter, project name, etc) and session (conditions, anesthetics, viruses, etc). Check the file to see supported options.

# Dependencies
Install [yaml tools](https://www.mathworks.com/matlabcentral/fileexchange/106765-yaml) and add to Matlab path.

If running on Matlab prior to 2020b, install [xml_io_tools]((https://www.mathworks.com/matlabcentral/fileexchange/12907-xml_io_tools) and add to Matlab path.
