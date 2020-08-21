classdef server < handle
    %SERVER is a class of servers which are used in a particular data
    %center
    %   Detailed explanation goes here
    
    properties
        Name            % Name of server that is used in the data center [-]
        InletTemp       % Server inlet temperature [K]
        OutletTemp      % Server outlet temperature [K]
        FailureTemp     % Server failure temperature [K]
        MassFlow        % Mass flow rate through the server [kg/s]
        AirFlowRate     % Air Volmetric Flow Rate [m3/s]
        HeatDiss        % Heat dissipation of server [kW]
        NoServers       % Number of servers in the data center [-]
        TempRise        % Temperature rise through the server [K]
        FailureTime     % Time to server failure temperature [s]
        ElapsedTime = 0 % Vector of time elapsed from the instant power is lost [s]
        FailureNotice = false   % State of server inlet temperature (0 if normal and 1 if failed)
        RebootMethod    % The sequence by which the data center reboots after power failure
        PressAtm
    end
    
    properties (Hidden)
        FailureLine
    end
    
    properties (Dependent)
        FailureLegend
        AirDensity
    end
    
    properties (Constant, Hidden)
        SpecHeatAir = 1.0035    % Specific heat capacity of Air [kJ/kg.K]
        GasConst = 8.314e3      % Universal gas constant [J/kmol.K]
        P_STP = 101.325         % Standard pressure at sea level [kPa]
        G_STP = 9.81            % Gravitational acceleration at sea level [m/s2]
        AirM = 28.97            % Molecular mass of air [kg/kmol]
        T_STP = 273.15          % Standard temperature [K]
%         AirDensity = 0.95       % Density of air at given altitude [kg/m3]
    end
    
    methods
        function obj = server()
            % initialisation of the server object
        end
        
        function val = get.AirDensity(obj)
            val = obj.PressAtm.*1000./((obj.GasConst./obj.AirM).*obj.T_STP);
        end
        function value = get.FailureLegend(obj)
            value = strcat(obj.Name, ' failure');
        end
        
        function set.FailureTime(obj, val)
            obj.FailureTime = val;
        end
        
        function set.MassFlow(obj, val)
            obj.MassFlow = val;
            temp_increase(obj);
        end
        
        function set.AirFlowRate(obj, val)
            obj.AirFlowRate = val;
            mass_flow(obj);
        end
        
        function set.InletTemp(obj, val)
            obj.InletTemp = val;
            outlet_temp(obj);
        end
        
        function mass_flow(obj)
            obj.MassFlow = obj.AirDensity.*obj.AirFlowRate;
        end
        
        function temp_increase(obj)
            obj.TempRise = obj.HeatDiss./(obj.MassFlow.*obj.SpecHeatAir);
        end
        
        function outlet_temp(obj)
            obj.OutletTemp = obj.InletTemp + obj.TempRise;
        end
        
        function plot_servers(obj)
            plot(obj.ElapsedTime, obj.InletTemp)
            hold on
            plot(obj.ElapsedTime, obj.FailureTemp.*ones(1, length(obj.ElapsedTime)), '--')
            xlabel('Elapsed Time (s)')
            xlim([0, obj.ElapsedTime(end)*1.05])
            ylim([obj.InletTemp(1), obj.FailureTemp*1.01])
            ylabel('Server Inlet Temperature (K)')
            title(obj.RebootMethod)
            hold on
        end
    end
    
    methods (Static)
        function plot_and_save(servers)
            leg = cell(1, 2*length(servers));
            leg(1:2:end) = {servers.Name};
            leg(2:2:end) = {servers.FailureLegend};
            
            for i = 1:1:3
                servers(i).plot_servers
%                 set(gcf, 'Visible', 'off')
            end
            legend(leg, 'Location', 'southeast', 'FontSize', 5)
            mkdir Graphs
            file = strcat('Graphs/', ...
                servers(1).RebootMethod(~isspace(servers(1).RebootMethod)));
            print(file, '-r500', '-dpng')
            hold off
%             close(gcf)
        end
        
    end
end
