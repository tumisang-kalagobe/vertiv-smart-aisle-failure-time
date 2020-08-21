function servers = data_center(servers, coolingUnit, ceiling, floor, scenario)
%DATA_CENTER Executes an analysis of a data center, given the server, PDX,
%floor space and ceiling space objects
% disp(scenario)
for i = 1:length(servers)
    while servers(i).FailureNotice == false
        if (coolingUnit.AirOutletTemp(end) < servers(i).FailureTemp(end)) && (coolingUnit.AirOutletTemp(end) >= coolingUnit.AirOutletTemp(1))
            % air entering and leaving the server
            servers(i).InletTemp = cat(2, servers(i).InletTemp, coolingUnit.AirOutletTemp(end));
            % cooling in the crac unit
            coolingUnit.AirInletTemp = servers(i).OutletTemp;
            % flow through ceiling and floor spaces
            coolingUnit.ElapsedTime = cat(2, coolingUnit.ElapsedTime, coolingUnit.ElapsedTime(end) + floor.Time + ceiling.Time);
            coolingUnit.AirOutletTemp = coolingUnit.AirInletTemp;
            if scenario == 1
                servers(i).RebootMethod = '2 Circuits Tandem Compressors with EEV';
                coolingUnit.cool_auto();
            elseif scenario == 2
                servers(i).RebootMethod = 'Fast Start User Input Reboot';
                coolingUnit.cool_user();
            elseif scenario == 3
                servers(i).RebootMethod = 'No Ultracap Reboot with iCom Micro Energised';
                coolingUnit.cool_no_ultracap();
            end
%             disp(coolingUnit.TempDrop)
%             disp(coolingUnit.CoolCap)
%             disp(coolingUnit.AirMassFlow)
        else
            servers(i).FailureNotice = true;
            servers(i).FailureTime = coolingUnit.ElapsedTime(end);
            servers(i).ElapsedTime = coolingUnit.ElapsedTime;
        end
    end
    
   
    % reset inlet air temperature
    if i ~= 3
        coolingUnit.AirOutletTemp = 288.7;
        coolingUnit.ElapsedTime = 0;
    end
end
end

