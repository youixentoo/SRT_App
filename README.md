# SRT_App
Internship Project<br>
Made by Thijs Weenink

### Download
Download the latest zip from releases or click [here](https://github.com/youixentoo/SRT_App/releases/latest/download/SRT_app.zip)

# Requirements
- Java version 17*
- R version 4.1.3

#### Java version
A custom java environment is provided. If it doesn't work, you need to install Java 17.<br>
To download Java 17, you need to download the Java 17 JDK installed. <br>The download page can be found here: https://www.oracle.com/java/technologies/downloads/#jdk17-windows


### R packages
- abind - 1.4.5
- collections - 0.3.5
- config - 0.3.1
- dplyr - 1.0.7
- stringr - 1.4.0
- tidyr - 1.2.0
- tidyverse - 1.3.1
- tools - 4.1.3
- xlsx - 0.6.5

## Description
This application processes the raw .txt files from SRT-monitors and outputs 5 calculations and 2 sets of probabilities. 

#### 5 calculations 
- Total sleep time (TST)
- Sleep episode duration (SED)
- Number of sleep bouts (NoSB)
- Sleep onset latency (SOL)
- Wake after sleep onset (WASO). 
The calculation data is grouped by genotype and averaged over day 3 and day 4.<br>

#### 2 sets of probabilities
- The probability that the fly switches from inactive to active (Pwake) 
- The probability that the fly switches from active to inactive (Pdoze) 

Different from the 5 calculations, the probabilities are calculated for day 1 through 4, the average of day 1 and day 2, the average of day 3 and day 4, and the average of all days.

#### Storage
Every calculation is stored separately from eachother in a folder corresponding to the calculation (TST, SED, NoSB, SOL, WASO), the filename is the monitor that got processed. In the case of the probabilities, they are stored under folders called Pwake and Pdoze, but as there are 7 output files for each monitor, they all get placed in a second folder named after the corresponding monitor. The filenames here are the different days and averages.

## How to use
- On start-up, there is 1 button available: "Select...". Pressing this button opens a windows that allows for selection of 1 or more files.
- When there are files selected, the second button unlocks: "Process".
- The files get processed by the R script when the the second button gets pressed.
- At the bottom of the screen, there is an area displaying the status of the application. It displays the current files being processed and once the R script is finished, it displays if the processing of the file has been successful or if there was an error.

### Location
The application only works if it's in the same folder as "Configs" and "RCode". A warning message will show if the config.yml file or any of the R scripts can't be found. However, there are no checks in place in the case one of both of the .xlsx files are missing.

### Configuration
To edit the configuration file, click the "Config" menu at the top of the screen. Here you can edit the config.yml file from within the application itself. You can still change the config.yml file manually, but it won't update when opening the configuration window in the application again, while the application is still running.

#### Excel files
The 2 excel files determine extra configuration settings.
- "day3_monitors.xlsx" determines when the third day is for each monitor file.
- "genotypes_per_monitor.xlsx" determines which genotype belongs to which channel for each monitor file.

**When adding more entries, it is very important to keep the same (date) formatting as the 2 files given.**
