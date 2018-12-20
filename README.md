# OpenTrafficCenter

A basic implementation of a traffic monitoring and control center of the Flemish Highway system in Matlab.


## Introduction

The application allows users to visualize traffic data and create a simple traffic model for any corridor along the highways of Flanders (Belgium). The application can be easily extended to visualize the impact of different traffic management scenarios such as the opening of a peak hour lane.

The traffic data is provided by the open data platform of Flanders.
The application uses live traffic data observed by double loop detectors along highway roads. 
It is externally repackaged and made available on http://www.itscrealab.be as a direct download or through Matlab's SQL interface.

The road network was created by combining a reference map of Flanders (GRB) and extracts from https://www.openstreetmap.org.

The application is built in two phases

1)	Select and visualize data along a selected corridor
2)	Setup and run a dynamic traffic model


## Detailed description

### Select and visualize data along a selected corridor

Run the main file  **VISUALIZECORRIDOR.m** or  **VISUALIZECORRIDOR_noDB.m** to start the application.
It is recommended to run this file section by section following the inline instructions, the outprints displayed in the command window or the text inside pop-up figures.

The general steps of phase 1 are:
1) Load the network into Matlab
2) Select a corridor (route between 2 points on the network)
3) Select a time window for the observations
4) Create a network model (add on/off-ramps to the selected corridor) and collect the data 
5) Visualize traffic state on the corridor in a space time diagram
6) Visualize the on-ramps
7) Visualize the off-ramps

### Setup and run a dynamic traffic model
After collecting and visualizing the traffic data a simple dynamic traffic model can be built using the CREATEMODEL.m file.
It is recommended to run this file section by section following the inline instructions, the printouts displayed in the command window or the text inside pop-up figures.

The traffic simulation is based first order kinematic wave theory of a single commodity flow. The application implements the Link Transmission Model of the KULeuven (https://www.mech.kuleuven.be/en/cib/traffic/downloads).

The general steps of phase 2 are:
1) Derive Demand matrices and turning fractions
2) Set simulation time interval
3) Set standard parameters of the traffic model 
4) Refine the capacity at specific locations (bottlenecks)
5) Run the simulation
6) Visualize the simulated traffic state on the corridor in a space time diagram
7) Compare simulated travel times with observed travel times
8) Animate the result
9) Visualize flows and counts for observed roads

## Example: some notes

### Data gathering
Extract the csv data files and place them in your working directory allong with all the matlab files.
### Main file
Run the file VISUALIZECORRIDOR_NoDB.m in matlab. For more control Run this file section by section.
```MATLAB
  VISUALIZECORRIDOR_NoDB
```
### Select a corridor
- When prompted to select points select  **From a List**. 

![alt text](https://github.com/HimpeWillem/OpenTrafficCenter/blob/master/FIGURES/SelectPoints.PNG)

- Pick the first corridor (**E314 Leuven Lummen**)

![alt text](https://github.com/HimpeWillem/OpenTrafficCenter/blob/master/FIGURES/SelectCorridor.PNG)

### Select a time window
The supplied data is gathered on 11th of December 2018. Pick the appropriate time for the evening peak (**15:00** to **20:00**). Data for different dates can be found on http://db.itscrealab.be/download/loop_detectors/ 

![alt text](https://github.com/HimpeWillem/OpenTrafficCenter/blob/master/FIGURES/SelectTime.PNG)

### Identifying bad detector locations
- Scroll through the data detector location by location and observe that for **location #7** no data is available

![alt text](https://github.com/HimpeWillem/OpenTrafficCenter/blob/master/FIGURES/NoData.PNG)

- Close the window with the data and select **From a List** when prompted to remove a detector

![alt text](https://github.com/HimpeWillem/OpenTrafficCenter/blob/master/FIGURES/RemoveDetector.PNG)

- Select detector location #7 named **Complex nr 20 ? Wilsele ? De Vunt** and click on **ok**

![alt text](https://github.com/HimpeWillem/OpenTrafficCenter/blob/master/FIGURES/RemoveLocation7.PNG)

- No other detectors should be removed

![alt text](https://github.com/HimpeWillem/OpenTrafficCenter/blob/master/FIGURES/NoMoreDetToDel.PNG)


### Visualizing the processed data
Next 6 figures are plotted of the selected corridor.

1) An overiew of the corridor on the map. Click on the blue diamont points to get an overview of the data for the detectors at that specific location

![alt text](https://github.com/HimpeWillem/OpenTrafficCenter/blob/master/FIGURES/SelectDataAtDetector.PNG)

2) A smoothed space-time diagram of speeds allong the corridor. This is an excellent way of visualizing the congestion patterns allong the corridor. The black horizontal lines are detector locations. Inbetween detector locations data is interpolated using a filtering technique that takes into account spatio-temporal relations in traffic (according to Treiber-Helbing 2002).

![alt text](https://github.com/HimpeWillem/OpenTrafficCenter/blob/master/FIGURES/Speed_Observations.PNG)

3) A smoothed space-time diagram of flows allong the corridor.

![alt text](https://github.com/HimpeWillem/OpenTrafficCenter/blob/master/FIGURES/Flow_Observations.PNG)

4) An interactive overview of all detectors on the main corridor 

![alt text](https://github.com/HimpeWillem/OpenTrafficCenter/blob/master/FIGURES/ObservationsMain.PNG)

5) An interactive overview of all detectors on the on-ramps

![alt text](https://github.com/HimpeWillem/OpenTrafficCenter/blob/master/FIGURES/ObservationsOnRamp.PNG)

6) An interactive overview of all detectors on the off-ramps

![alt text](https://github.com/HimpeWillem/OpenTrafficCenter/blob/master/FIGURES/ObservationsOff.PNG)

### Create demand 
Now open the file CREATEMODEL.m. All of the data is processed and is used in this m-file to create a model representation of the selected corridor. For more control Run this file section by section.
```MATLAB
  CREATEMODEL
```
The model uses the detector counts to create demand at each origin (source) and splitting rates at every diverge node in the network.

### Setting the standard values of the supply
The model recuires additional attributes for every link. Based on the number of lanes, a standard capacity and jam density is assigned to each link (line 28 & 29 in the code). The maximum spillback speed is derived from these values to conform the assumption of a triangular diagram. Additionally you can set the capacity of specific links manually (for example by looking at capacity outflow in the data).
```MATLAB
capacity_per_lane = 2100;
kjam_per_lane = 100;
```
When promped to change the capacity of link click on **No** such that only the standard values are used

### Running the simulation and inspecting the result
After the model is finished different different figures are opened to visualize the result:
1) On top is an animation of the density in the network over time. Press space-bar to start the animation. If you close the figure the animation is stopped and the next figure is highlighted 
2) An overview of detector locations in the network. Zoom into a specific zone, hit any key on the keyboard and click on a link to visualize the difference between the observations and simulation at a specific location. A new figure will be opened for each link that you click
3) A comparison between simulated travel times and observed travel times allong the corridor
4) A smoothed space-time diagram of flows allong the corridor.
5) A smoothed space-time diagram of speeds allong the corridor.


