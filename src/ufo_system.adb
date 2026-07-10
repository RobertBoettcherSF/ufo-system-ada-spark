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

   procedure Set_Speed (State : in out UAP_State; Speed : Meters_Per_Second) is
   begin
      State.Current_Speed := Speed;
   end Set_Speed;

   procedure Set_Altitude (State : in out UAP_State; Altitude : Kilometers) is
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

   procedure Set_Obstacle (State : in out UAP_State; Has_Obstacle : Obstacle_State; Distance : Kilometers) is
   begin
      State.Environment.Has_Obstacle := Has_Obstacle;
      State.Environment.Obstacle_Distance := Distance;
   end Set_Obstacle;

   -- Temperature regulation: maintain human comfort range (18-25C)
   -- If temperature is too low, increase it toward minimum
   -- If temperature is too high but not critical, decrease it toward maximum
   -- If temperature is critically high, trigger emergency cooling
   procedure Regulate_Temperature (State : in out UAP_State) is
   begin
      -- If temperature is too low, increase it toward minimum
      if State.Core_Temperature < Human_Min_Temp then
         State.Core_Temperature := Human_Min_Temp;
         -- In real implementation: activate heating systems
      
      -- If temperature is too high but not critical, decrease it toward maximum
      elsif State.Core_Temperature > Human_Max_Temp and State.Core_Temperature <= Human_Critical_Temp then
         State.Core_Temperature := Human_Max_Temp;
         -- In real implementation: activate enhanced cooling systems
      
      -- If temperature is critically high, trigger emergency cooling
      elsif State.Core_Temperature > Human_Critical_Temp then
         Emergency_Cooling(State);
      end if;
      
      -- Temperature is within safe range, no action needed
   end Regulate_Temperature;

   -- Emergency cooling: when temperature exceeds critical threshold (30C)
   -- Activates all cooling systems to protect human life
   -- Reduces temperature toward safe range
   procedure Emergency_Cooling (State : in out UAP_State) is
   begin
      -- Activate emergency cooling systems
      -- Reduce temperature by 5C (simulating cooling system effect)
      -- In real implementation, this would also:
      -- - Activate backup cooling systems
      -- - Alert crew
      -- - Redirect power to life support
      if State.Core_Temperature > Human_Critical_Temp then
         State.Core_Temperature := Temperature_Celsius'Max(Human_Max_Temp, State.Core_Temperature - 5);
      end if;
   end Emergency_Cooling;

   -- Calculate target speed based on current mode and environment
   -- This sets the Target_Speed field which the board computer will work toward
   -- IMPORTANT: Target speed NEVER exceeds Max_Achievable_Speed (99.9% of light speed)
   -- as nothing with mass can reach or exceed light speed
   procedure Calculate_Target_Speed (State : in out UAP_State) is
      Target : Meters_Per_Second;
   begin
      case State.Mode is
         when Hover =>
            -- Hover mode: low speed, can be 0 but target is minimal for stability
            Target := 10;  -- 10 m/s for stability
            
         when Atmospheric_Cruise =>
            -- Atmospheric cruise: target is escape velocity of current body
            -- This allows instant escape if threat detected
            case State.Environment.Body_Type is
               when Earth =>
                  Target := Earth_Escape_Velocity;
               when Moon =>
                  Target := Moon_Escape_Velocity;
               when Mars =>
                  Target := Mars_Escape_Velocity;
               when others =>
                  Target := Earth_Escape_Velocity;
            end case;
            
         when Interstellar =>
            -- Interstellar mode: depends on environment
            if State.Environment.Body_Type = Deep_Space then
               if State.Environment.Has_Obstacle = Obstacle_Detected then
                  -- Obstacle detected: reduce speed for evasion
                  -- Target speed based on distance to obstacle
                  if State.Environment.Obstacle_Distance > 1000 then
                     Target := 10_000;  -- 10 km/s for long-range evasion
                  elsif State.Environment.Obstacle_Distance > 100 then
                     Target := 1_000;   -- 1 km/s for medium-range evasion
                  else
                     Target := 100;     -- 100 m/s for close evasion
                  end if;
               else
                  -- No obstacles: accelerate toward maximum achievable speed
                  -- This is 99.9% of light speed, NOT light speed itself
                  -- Nothing with mass can reach light speed
                  Target := Max_Achievable_Speed;
               end if;
            elsif State.Environment.Relative_Distance > Atmosphere_Boundary then
               -- Above atmosphere: target is escape velocity or higher
               case State.Environment.Body_Type is
                  when Earth =>
                     Target := Meters_Per_Second'Max(Earth_Escape_Velocity, State.Current_Speed);
                  when Moon =>
                     Target := Meters_Per_Second'Max(Moon_Escape_Velocity, State.Current_Speed);
                  when Mars =>
                     Target := Meters_Per_Second'Max(Mars_Escape_Velocity, State.Current_Speed);
                  when others =>
                     Target := Meters_Per_Second'Max(Earth_Escape_Velocity, State.Current_Speed);
               end case;
            else
               -- In atmosphere: target is escape velocity
               case State.Environment.Body_Type is
                  when Earth =>
                     Target := Earth_Escape_Velocity;
                  when Moon =>
                     Target := Moon_Escape_Velocity;
                  when Mars =>
                     Target := Mars_Escape_Velocity;
                  when others =>
                     Target := Earth_Escape_Velocity;
               end case;
            end if;
      end case;
      
      -- Ensure target never exceeds maximum achievable speed (99.9% of light speed)
      if Target > Max_Achievable_Speed then
         Target := Max_Achievable_Speed;
      end if;
      
      State.Target_Speed := Target;
   end Calculate_Target_Speed;

   -- Emergency routine: Adjust speed and altitude for propulsion mode
   -- Different propulsion modes have different optimal speed/altitude ranges:
   -- - Hover: Low speed (0-50 m/s), low altitude (0-1 km)
   -- - Atmospheric_Cruise: Speed toward escape velocity, altitude flexible (0-15 km)
   -- - Interstellar: High speed (toward Max_Achievable_Speed), high altitude (16,000+ km in deep space)
   -- This procedure automatically adjusts to safe parameters based on environment
   -- IMPORTANT: Speed NEVER exceeds Max_Achievable_Speed (99.9% of light speed)
   procedure Adjust_To_Environment (State : in out UAP_State) is
      Safe_Speed : Meters_Per_Second;
      Safe_Altitude : Kilometers;
      Min_Safe_Speed : Meters_Per_Second;
   begin
      -- First calculate what the target speed should be
      Calculate_Target_Speed(State);
      
      case State.Mode is
         when Hover =>
            -- Hover mode: low and slow
            -- Max speed: 50 m/s (~100 knots)
            -- Max altitude: 1 km
            Safe_Speed := Meters_Per_Second'Min(State.Current_Speed, 50);
            Safe_Altitude := Kilometers'Min(State.Current_Altitude, 1);
            
         when Atmospheric_Cruise =>
            -- Atmospheric cruise: can go from 0 up to escape velocity
            -- Altitude: 0 to 15 km based on atmospheric pressure
            -- Speed: work toward escape velocity (Target_Speed)
            
            -- Adjust altitude based on pressure
            if State.Environment.Atmospheric_Pressure > 500.0 then
               -- Dense atmosphere (near sea level)
               Safe_Altitude := Kilometers'Min(State.Current_Altitude, 5);  -- 5 km
            elsif State.Environment.Atmospheric_Pressure > 100.0 then
               -- Medium atmosphere
               Safe_Altitude := Kilometers'Min(State.Current_Altitude, 12);  -- 12 km
            else
               -- Thin atmosphere or near space
               Safe_Altitude := Kilometers'Min(State.Current_Altitude, 15);  -- 15 km
            end if;
            
            -- Speed: work toward target (escape velocity)
            -- Allow current speed to be lower (pilot can go slower)
            -- But don't exceed escape velocity in atmosphere
            if State.Environment.Atmospheric_Pressure > 0.0 then
               -- In atmosphere: limit to escape velocity
               case State.Environment.Body_Type is
                  when Earth =>
                     Safe_Speed := Meters_Per_Second'Min(State.Current_Speed, Earth_Escape_Velocity);
                  when Moon =>
                     Safe_Speed := Meters_Per_Second'Min(State.Current_Speed, Moon_Escape_Velocity);
                  when Mars =>
                     Safe_Speed := Meters_Per_Second'Min(State.Current_Speed, Mars_Escape_Velocity);
                  when others =>
                     Safe_Speed := Meters_Per_Second'Min(State.Current_Speed, Earth_Escape_Velocity);
               end case;
            else
               -- No atmosphere: can go up to target speed
               Safe_Speed := Meters_Per_Second'Min(State.Current_Speed, State.Target_Speed);
            end if;
            
         when Interstellar =>
            -- Interstellar mode: high speed, high altitude or deep space
            -- Must maintain speed toward target (Max_Achievable_Speed or escape velocity)
            -- Must maintain altitude above 16,000 km in deep space
            
            if State.Environment.Body_Type = Deep_Space then
               -- In deep space: maintain high speed and altitude
               Min_Safe_Speed := 10_000;  -- 10 km/s minimum in deep space
               
               if State.Environment.Has_Obstacle = Obstacle_Detected then
                  -- Obstacle detected: reduce speed based on distance
                  if State.Environment.Obstacle_Distance > 1000 then
                     Safe_Speed := Meters_Per_Second'Min(State.Current_Speed, 10_000);
                  elsif State.Environment.Obstacle_Distance > 100 then
                     Safe_Speed := Meters_Per_Second'Min(State.Current_Speed, 1_000);
                  else
                     Safe_Speed := Meters_Per_Second'Min(State.Current_Speed, 100);
                  end if;
               else
                  -- No obstacles: work toward Max_Achievable_Speed (99.9% of light speed)
                  Safe_Speed := Meters_Per_Second'Min(State.Current_Speed, State.Target_Speed);
               end if;
               
               Safe_Altitude := Kilometers'Max(State.Current_Altitude, Deep_Space_Min_Altitude);
               
            elsif State.Environment.Relative_Distance > Atmosphere_Boundary then
               -- Above atmosphere but near a body
               -- Use escape velocity of the nearest body
               case State.Environment.Body_Type is
                  when Earth =>
                     Min_Safe_Speed := Earth_Escape_Velocity;
                  when Moon =>
                     Min_Safe_Speed := Moon_Escape_Velocity;
                  when Mars =>
                     Min_Safe_Speed := Mars_Escape_Velocity;
                  when others =>
                     Min_Safe_Speed := Earth_Escape_Velocity;
               end case;
               
               Safe_Speed := Meters_Per_Second'Max(State.Current_Speed, Min_Safe_Speed);
               Safe_Altitude := Kilometers'Max(State.Current_Altitude, LEO_Min_Altitude);
               
            else
               -- In atmosphere: maintain escape velocity
               case State.Environment.Body_Type is
                  when Earth =>
                     Min_Safe_Speed := Earth_Escape_Velocity;
                  when Moon =>
                     Min_Safe_Speed := Moon_Escape_Velocity;
                  when Mars =>
                     Min_Safe_Speed := Mars_Escape_Velocity;
                  when others =>
                     Min_Safe_Speed := Earth_Escape_Velocity;
               end case;
               
               Safe_Speed := Meters_Per_Second'Max(State.Current_Speed, Min_Safe_Speed);
               Safe_Altitude := Kilometers'Min(State.Current_Altitude, 15);
            end if;
      end case;
      
      -- Apply safe values
      State.Current_Speed := Safe_Speed;
      State.Current_Altitude := Safe_Altitude;
      
      -- Also regulate temperature for human safety
      Regulate_Temperature(State);
      
   end Adjust_To_Environment;

end Ufo_System;
