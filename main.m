%% Preamble
%{
Author:             Tumisang Kalagobe
Data finalised:     19/08/2020
Course:             MECN1999 - Vacation Work II
Company:            Vertiv South Africa
Description:        Determination of the heat build up in a data center,
                    given a loss of power from the grid. The data center
                    has 3 primary methods of rebooting, all of which are
                    considered for 3 different server brands. It is desired
                    to determine the time to server failure temperature due
                    to heat build up as the cooling units come back online.
%}

clc
clear
%% Cooling Unit Definition
crac = pdx(288.7);

%% Ceiling and Floor Space Definition
ceiling = flowRegion(11.63/5, 1, 10.65, crac.AirFlowRate);
floor = flowRegion(0.6, 0.6, 10.65, crac.AirFlowRate);

%% Heat build Up
crac = pdx(288.7);
[dell, ibm, hp] = server_initialisation(crac);
servers = [dell, ibm, hp];
autoBootServers = data_center(servers, crac, ceiling, floor, 1);
% server.plot_and_save(autoBootServers)

crac = pdx(288.7);
[dell, ibm, hp] = server_initialisation(crac);
servers = [dell, ibm, hp];
userBootServers = data_center(servers, crac, ceiling, floor, 2);
server.plot_and_save(userBootServers)

crac = pdx(288.7);
[dell, ibm, hp] = server_initialisation(crac);
servers = [dell, ibm, hp];
ultraCapBootServers = data_center(servers, crac, ceiling, floor, 3);
% server.plot_and_save(ultraCapBootServers)

