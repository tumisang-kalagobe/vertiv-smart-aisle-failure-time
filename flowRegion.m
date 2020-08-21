classdef flowRegion < handle
    %FLOWREGION is a class of rectangular prism through which air flows
    %   Used to define the floor and ceiling spaces in the data center
    %   analysis that is conducted.
    
    properties
        Width
        Height
        Length
        FlowRate
    end
    
    properties (Dependent)
        Time
    end
    
    methods
        function obj = flowRegion(w, h, l, f)
            %UNTITLED2 Construct an instance of this class
            %   Detailed explanation goes here
            obj.Width = w;
            obj.Height = h;
            obj.Length = l;
            obj.FlowRate = f;
        end
        
        function obj = get.Time(obj)
            obj = (obj.Width.*obj.Height.*obj.Length)./obj.FlowRate;
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

