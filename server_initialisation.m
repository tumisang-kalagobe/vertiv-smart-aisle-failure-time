function [dell, ibm, hp] = server_initialisation(crac)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
dell = server();
dell.Name = 'Dell PowerEdge R710';
dell.PressAtm = crac.PressAtm;
dell.InletTemp = crac.AirOutletTemp;
dell.FailureTemp = 308;
dell.HeatDiss = 0.57;
dell.NoServers = 290;
dell.AirFlowRate = 5*0.04861;

ibm = server();
ibm.Name = 'IBM x3850 M2';
ibm.PressAtm = crac.PressAtm;
ibm.InletTemp = crac.AirOutletTemp;
ibm.FailureTemp = 305;
ibm.HeatDiss = .8;
ibm.NoServers = 174;
ibm.AirFlowRate = 5*0.04861;

hp = server();
hp.Name = 'HP ProLiant DL380 G5';
hp.PressAtm = crac.PressAtm;
hp.InletTemp = crac.AirOutletTemp;
hp.FailureTemp = 308;
hp.HeatDiss = .85;
hp.NoServers = 290;
hp.AirFlowRate = 5*0.04861;

end

