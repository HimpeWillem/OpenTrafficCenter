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

Run the main file VISUALIZECORRIDOR.m or VISUALIZECORRIDOR_no.m to start the application.
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

