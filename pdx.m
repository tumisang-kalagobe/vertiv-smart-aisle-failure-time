classdef pdx < handle 
    %PDX is a class of the cooling unit used in a Vertiv data center
    %   Detailed explanation goes here
    
    properties
        AirInletTemp        % Inlet air temperature [K]
        AirOutletTemp       % Outlet air temperature [K]
        Alt                 % Altitude of the data center [m]
        TempDrop            % Temperature reduction through PDX [K]
        AirFlowRate         % Unit air flow [m3/h]
        CoolCap             % Cooling capacity [kW]
        PressAtm            % Atmospheric pressure [kPa]
        AirMassFlow         % Mass flow rate of air [kg/s]
        Ref                 % Refrigerant used [-]
        Unit 
        CompEff             % Compressor efficiency [-]
        PowerInCirc1
        PowerInCirc2
        COP1
        COP2
        ElapsedTime = 0
        Label
    end
    
    properties %(Hidden) 
        Comp1Circ1Power = false
        Comp2Circ1Power = false
        Comp1Circ2Power = false
        Comp2Circ2Power = false
        FanPower = false
        iComPower = false
        UnitPower = false
        CoolCapComp1 = 0
        CoolCapComp2 = 0
    end
    
    properties (Constant, Hidden)
        GasConst = 8.314e3  % Universal gas constant [J/kmol.K]
        P_STP = 101.325     % Standard pressure at sea level [kPa]
        G_STP = 9.81        % Gravitational acceleration at sea level [m/s2]
        AirM = 28.97        % Molecular mass of air [kg/kmol]
        T_STP = 273.15      % Standard temperature [K]
        AirDensity = 1.1   % Density of air at given altitude [kg/m3]
        SpecHeatAir = 1.0035    % Specific heat capacity of Air [kJ/kg.K]
    end
    
    methods
        function obj = pdx(outletTemp)
            %UNTITLED2 Construct an instance of this class
            %   Detailed explanation goes here
            obj.Ref = 'R410A';
            obj.Unit = 'PX094DA';
            obj.Alt = 1700;
            obj.AirFlowRate = 24535*(12/5); % 12 PDX Units serving 5 Aisles
            obj.PowerInCirc1 = 7.86;
            obj.PowerInCirc2 = 11.56;
            obj.COP1 = 4.38;
            obj.COP2 = 4.72;
            obj.CompEff = 0.85;
            obj.AirOutletTemp = outletTemp;
        end
        
        function set.Alt(obj, altitude)
            obj.Alt = altitude;
            atmospheric_pressure(obj);
        end
        
        function set.AirFlowRate(obj, airFlow)
            obj.AirFlowRate = airFlow./3600;
            mass_flow(obj);
        end
        
        function set.AirInletTemp(obj, val)
            obj.AirInletTemp = val;
            temp_reduction(obj);
        end
        
        function set.Comp1Circ1Power(obj, val)
            obj.Comp1Circ1Power = val;
            compressor1(obj);
            total_cooling(obj);
            temp_reduction(obj);
            outlet_temp(obj);
        end
        
        function set.Comp1Circ2Power(obj, val)
            obj.Comp1Circ2Power = val;
            compressor1(obj);
            total_cooling(obj);
            temp_reduction(obj);
            outlet_temp(obj);
        end
        
        function set.Comp2Circ1Power(obj, val)
            obj.Comp2Circ1Power = val;
            compressor2(obj);
            total_cooling(obj);
            temp_reduction(obj);
            outlet_temp(obj);
        end
        
        function set.Comp2Circ2Power(obj, val)
            obj.Comp2Circ2Power = val;
            compressor2(obj);
            total_cooling(obj);
            temp_reduction(obj);
            outlet_temp(obj);
        end
        
        % copy for other compressors
        
        function compressor1(obj)
            power = obj.PowerInCirc1;
            eff = obj.CompEff;
            cop = obj.COP1;
            if (obj.Comp1Circ1Power == true) && (obj.Comp1Circ2Power ~= true)
                obj.CoolCapComp1 = power.*eff.*cop/2;
            elseif obj.Comp1Circ1Power == true && obj.Comp1Circ2Power == true
                obj.CoolCapComp1 = power.*eff.*cop;
            else 
                obj.CoolCapComp1 = 0;
            end
        end
        
        function compressor2(obj)
            power = obj.PowerInCirc2;
            eff = obj.CompEff;
            cop = obj.COP2;
            if obj.Comp2Circ1Power == true && obj.Comp2Circ2Power ~= true
                obj.CoolCapComp2 = power.*eff.*cop/2;
            elseif obj.Comp2Circ1Power == true && obj.Comp2Circ2Power == true
                obj.CoolCapComp2 = power.*eff.*cop;
            else 
                obj.CoolCapComp2 = 0;
            end
        end
        
        function total_cooling(obj)
            obj.CoolCap = obj.CoolCapComp1 + obj.CoolCapComp2;	
        end
        
        function temp_reduction(obj)
            obj.TempDrop = -obj.CoolCap./(obj.AirMassFlow.*obj.SpecHeatAir);
        end
        
        function outlet_temp(obj)
            obj.AirOutletTemp = cat(2, obj.AirOutletTemp, obj.AirInletTemp(end)...
                + obj.TempDrop);
        end
        
        function mass_flow(obj)
            obj.AirMassFlow = obj.AirDensity.*obj.AirFlowRate;
        end
        
        function atmospheric_pressure(obj)
            %ATMOSPHERIC_PRESSURE determines the ambient atmospheric
            %pressre, given a change in the altitude
            num = -obj.G_STP.*obj.AirM.*obj.Alt;
            den = obj.GasConst.*obj.T_STP;
            obj.PressAtm = obj.P_STP.*exp(num./den);
        end
        
        function cool_auto(obj)
            % PDX 2 circuits tandem compressors with EEV
            obj.Label = 'Auto Start';
            if (obj.ElapsedTime(end) >= 0) && (obj.ElapsedTime(end) < 35)
                obj.UnitPower = true;
            elseif (obj.ElapsedTime(end) >= 35) && (obj.ElapsedTime(end) < 60)
                obj.UnitPower = true;
                obj.iComPower = true;
            elseif (obj.ElapsedTime(end) >= 60) && (obj.ElapsedTime(end) < 110)
                obj.UnitPower = true;
                obj.iComPower = true;
                obj.FanPower = true;
            elseif (obj.ElapsedTime(end) >= 110) && (obj.ElapsedTime(end) < 120)
                obj.UnitPower = true;
                obj.iComPower = true;
                obj.FanPower = true;
                obj.Comp1Circ1Power = true;
            elseif (obj.ElapsedTime(end) >= 120) && (obj.ElapsedTime(end) < 290)
                obj.UnitPower = true;
                obj.iComPower = true;
                obj.FanPower = true;
                obj.Comp1Circ1Power = true;
                obj.Comp1Circ2Power = true;
            elseif (obj.ElapsedTime(end) >= 290) && (obj.ElapsedTime(end) < 300)
                obj.UnitPower = true;
                obj.iComPower = true;
                obj.FanPower = true;
                obj.Comp1Circ1Power = true;
                obj.Comp1Circ2Power = true;
                obj.Comp2Circ1Power = true;
            elseif obj.ElapsedTime(end) >= 300
                obj.UnitPower = true;
                obj.iComPower = true;
                obj.FanPower = true;
                obj.Comp1Circ1Power = true;
                obj.Comp1Circ2Power = true;
                obj.Comp2Circ1Power = true;
                obj.Comp2Circ2Power = true;
            end
        end
        
        function cool_user(obj)
            % Fast start in case of No Power (User input feature). PDX 2 circuits tandem compressors:
            obj.Label = 'User Input';
            obj.UnitPower = true;
            obj.iComPower = true;
            obj.FanPower = true;
            if (obj.ElapsedTime(end) >= 15) && (obj.ElapsedTime(end) < 25)
                obj.Comp1Circ1Power = true;
            elseif (obj.ElapsedTime(end) >= 25) && (obj.ElapsedTime(end) < 30)
                obj.Comp1Circ1Power = true;
                obj.Comp1Circ2Power = true;
            elseif (obj.ElapsedTime(end) >= 30) && (obj.ElapsedTime(end) < 40)
                obj.Comp1Circ1Power = true;
                obj.Comp1Circ2Power = true;
                obj.Comp2Circ1Power = true;
            elseif obj.ElapsedTime(end) >= 40
                obj.Comp1Circ1Power = true;
                obj.Comp1Circ2Power = true;
                obj.Comp2Circ1Power = true;
                obj.Comp2Circ2Power = true;
            end
        end
        
        function cool_no_ultracap(obj)
            % In case of Ultracap, No Power Full, (iCom micro only is powered) 
            % the EEV board reboot time has to be added.
            obj.Label = 'Ultracap, No Power';
            obj.UnitPower = true;
            obj.iComPower = true;
            if obj.ElapsedTime >= 10
                obj.FanPower = true;
            elseif obj.ElapsedTime >= 50
                obj.FanPower = true;
                obj.Comp1Circ1Power = true;
            elseif obj.ElapsedTime >= 60
                obj.FanPower = true;
                obj.Comp1Circ1Power = true;
                obj.Comp1Circ2Power = true;
            elseif obj.ElapsedTime >= 65
                obj.FanPower = true;
                obj.Comp1Circ1Power = true;
                obj.Comp1Circ2Power = true;
                obj.Comp2Circ1Power = true;
            elseif obj.ElapsedTime >= 75
                obj.FanPower = true;
                obj.Comp1Circ1Power = true;
                obj.Comp1Circ2Power = true;
                obj.Comp2Circ1Power = true;
                obj.Comp2Circ2Power = true;
            end
        end
    end
end

