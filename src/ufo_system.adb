package body Ufo_System with SPARK_Mode is

   procedure Engage_Rotation (State : in out UAP_State) is
   begin
      State.Is_Rotating := True;
      -- Later this would call the anti-gravity API
   end Engage_Rotation;

   procedure Compensate_Wind (State : in out UAP_State; Wind_Speed : Knots) is
   begin
      State.Current_Wind := Wind_Speed;
      -- Algorithm calculates vector to maintain exact position
   end Compensate_Wind;

   procedure Set_Speed (State : in out UAP_State; Speed : Knots) is
   begin
      State.Current_Speed := Speed;
   end Set_Speed;

   procedure Set_Altitude (State : in out UAP_State; Altitude : Feet) is
   begin
      State.Current_Altitude := Altitude;
   end Set_Altitude;

   procedure Set_Heading (State : in out UAP_State; Heading : Degrees) is
   begin
      State.Current_Heading := Heading;
   end Set_Heading;

   procedure Set_Environment (State : in out UAP_State; Env : Environment_State) is
   begin
      State.Environment := Env;
   end Set_Environment;

   procedure Set_Temperature (State : in out UAP_State; Temp : Temperature_Celsius) is
   begin
      State.Core_Temperature := Temp;
   end Set_Temperature;

   -- Emergency routine: Overheating - drop into the sea
   -- When core temperature exceeds 150C, the craft must descend to sea level
   -- to prevent catastrophic failure. Only works near celestial bodies with atmosphere.
   procedure Emergency_Cooling (State : in out UAP_State) is
   begin
      -- Descend to sea level (0 feet) for emergency cooling
      State.Current_Altitude := 0;
      -- Note: In a real implementation, this would also trigger cooling systems
      -- and potentially alert ground control
   end Emergency_Cooling;

   -- Emergency routine: Adjust speed and altitude for propulsion mode
   -- Different propulsion modes have different optimal speed/altitude ranges:
   -- - Hover: Low speed (0-100 knots), low altitude (0-1000 ft)
   -- - Atmospheric_Cruise: Medium speed (100-1000 knots), medium altitude (1000-30000 ft)
   -- - Interstellar: High speed (1000+ knots), high altitude (30000+ ft or deep space)
   -- This procedure automatically adjusts to safe parameters based on environment
   procedure Adjust_To_Environment (State : in out UAP_State) is
      Safe_Speed : Knots;
      Safe_Altitude : Feet;
   begin
      case State.Mode is
         when Hover =>
            -- Hover mode: low and slow
            Safe_Speed := Knots'Min(State.Current_Speed, 100);
            if State.Environment.Body_Type = Deep_Space then
               Safe_Altitude := 0;  -- No meaningful altitude in deep space
            else
               Safe_Altitude := Feet'Min(State.Current_Altitude, 1000);
            end if;
            
         when Atmospheric_Cruise =>
            -- Atmospheric cruise: medium speed and altitude
            -- Adjust based on atmospheric pressure
            if State.Environment.Atmospheric_Pressure > 500.0 then
               -- Dense atmosphere (near sea level)
               Safe_Speed := Knots'Min(State.Current_Speed, 800);
               Safe_Altitude := Feet'Min(State.Current_Altitude, 10000);
            elsif State.Environment.Atmospheric_Pressure > 100.0 then
               -- Medium atmosphere
               Safe_Speed := Knots'Min(State.Current_Speed, 1000);
               Safe_Altitude := Feet'Min(State.Current_Altitude, 30000);
            else
               -- Thin atmosphere or near space
               Safe_Speed := Knots'Min(State.Current_Speed, 1200);
               Safe_Altitude := Feet'Min(State.Current_Altitude, 50000);
            end if;
            
         when Interstellar =>
            -- Interstellar mode: high speed, high altitude or deep space
            if State.Environment.Body_Type = Deep_Space then
               Safe_Speed := Knots'Max(State.Current_Speed, 1000);
               Safe_Altitude := 0;  -- No meaningful altitude in deep space
            elsif State.Environment.Relative_Distance > 1_000_000 then
               -- Far from celestial body - can go fast
               Safe_Speed := Knots'Max(State.Current_Speed, 2000);
               Safe_Altitude := Feet'Max(State.Current_Altitude, 100_000);
            else
               -- Near a celestial body - adjust based on distance
               Safe_Speed := Knots'Min(Knots'Max(State.Current_Speed, 1000), 
                                       Knots(Float'Floor(Float(State.Environment.Relative_Distance) / 100.0)));
               Safe_Altitude := Feet'Min(Feet'Max(State.Current_Altitude, 30_000), 
                                         Feet(Float'Floor(Float(State.Environment.Relative_Distance) / 10.0)));
            end if;
      end case;
      
      -- Apply safe values
      State.Current_Speed := Safe_Speed;
      State.Current_Altitude := Safe_Altitude;
      
   end Adjust_To_Environment;

end Ufo_System;
