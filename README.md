# SRT_App
Internship Project<br>
Made by Thijs Weenink

# Requirements
Java is used for the interface, R is required to be installed on the pc.

## R packages
dplyr - 1.0.7
stringr - 1.4.0
collections - 0.3.5
tidyr - 1.2.0
xlsx - 0.6.5
config - 0.3.1

# Usage
## Location
The application only works if it's in the same folder as "Configs" and "RCode". A warning message will show if the config.yml file or any of the R scripts can't be found. However, there are no checka in place in the case one of both of the .xlsx files are missing.

## How to use
- On start-up, there is 1 button available: "Select...". Pressing this button opens a windows that allows for selection of 1 or more files.
- When there are files selected, the second button unlocks: "Process".
- The files get processed by the R script when the the second button gets pressed.
- At the bottom of the screen, there is an area displaying the status of the application. It displays the current files being processed and once the R script is finished, it displays if the processing of the file has been succesful or if there was an error.

## Configuration
To edit the configuration file, click the "Config" menu at the top of the screen. Here you can edit the config.yml file from within the application itself. You can still change the config.yml file manually, but it won't update when opening the configuration window in the application again, while the application is still running.
