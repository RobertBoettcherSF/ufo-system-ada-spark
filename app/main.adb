with Ada.Text_IO;
with Ada.Command_Line;
with Ufo_System;

procedure Main is
   -- Terminal application to demonstrate UFO System functionality
   
   package IO renames Ada.Text_IO;
   
   State : Ufo_System.UAP_State;
   
   -- Forward declarations for helper functions
   function Count_Tokens (S : String) return Integer;
   function Token (S : String; N : Integer) return String;
   function To_Lower (S : String) return String;

   procedure Print_State (S : Ufo_System.UAP_State) is
      Obstacle_Status : String(1..8);
   begin
      IO.Put_Line("=== Current UFO State ===");
      IO.Put_Line("Is Rotating:      " & Boolean'Image(S.Is_Rotating));
      IO.Put_Line("Current Wind:     " & Ufo_System.Knots'Image(S.Current_Wind) & " knots");
      IO.Put_Line("Propulsion Mode:  " & Ufo_System.Propulsion_Mode'Image(S.Mode));
      IO.Put_Line("Hull Integrity:   " & Integer'Image(S.Hull_Integrity) & "%");
      IO.Put_Line("Current Speed:    " & Ufo_System.Meters_Per_Second'Image(S.Current_Speed) & " m/s");
      IO.Put_Line("Target Speed:     " & Ufo_System.Meters_Per_Second'Image(S.Target_Speed) & " m/s");
      IO.Put_Line("Current Altitude: " & Ufo_System.Kilometers'Image(S.Current_Altitude) & " km");
      IO.Put_Line("Current Heading:  " & Ufo_System.Degrees'Image(S.Current_Heading) & " degrees");
      IO.Put_Line("Core Temperature: " & Ufo_System.Temperature_Celsius'Image(S.Core_Temperature) & " C");
      IO.Put_Line("  (Human comfort: " & Ufo_System.Temperature_Celsius'Image(Ufo_System.Human_Min_Temp) & "-" & 
                  Ufo_System.Temperature_Celsius'Image(Ufo_System.Human_Max_Temp) & " C)");
      IO.Put_Line("Environment:");
      IO.Put_Line("  Body Type: " & Ufo_System.Celestial_Body_Type'Image(S.Environment.Body_Type));
      IO.Put_Line("  Distance:  " & Ufo_System.Kilometers'Image(S.Environment.Relative_Distance) & " km");
      IO.Put_Line("  Pressure:  " & Float'Image(S.Environment.Atmospheric_Pressure) & " hPa");
      
      -- Display obstacle status
      if S.Environment.Has_Obstacle = Ufo_System.Obstacle_Detected then
         Obstacle_Status := "Detected";
      else
         Obstacle_Status := "None    ";
      end if;
      IO.Put_Line("  Obstacle:  " & Obstacle_Status);
      
      if S.Environment.Has_Obstacle = Ufo_System.Obstacle_Detected then
         IO.Put_Line("  Obstacle Distance: " & Ufo_System.Kilometers'Image(S.Environment.Obstacle_Distance) & " km");
      end if;
      IO.New_Line;
   end Print_State;

   begin
      IO.Put_Line("=== Current UFO State ===");
      IO.Put_Line("Is Rotating:      " & Boolean'Image(S.Is_Rotating));
      IO.Put_Line("Current Wind:     " & Ufo_System.Knots'Image(S.Current_Wind) & " knots");
      IO.Put_Line("Propulsion Mode:  " & Ufo_System.Propulsion_Mode'Image(S.Mode));
      IO.Put_Line("Hull Integrity:   " & Integer'Image(S.Hull_Integrity) & "%");
      IO.Put_Line("Current Speed:    " & Ufo_System.Meters_Per_Second'Image(S.Current_Speed) & " m/s");
      IO.Put_Line("Target Speed:     " & Ufo_System.Meters_Per_Second'Image(S.Target_Speed) & " m/s");
      IO.Put_Line("Current Altitude: " & Ufo_System.Kilometers'Image(S.Current_Altitude) & " km");
      IO.Put_Line("Current Heading:  " & Ufo_System.Degrees'Image(S.Current_Heading) & " degrees");
      IO.Put_Line("Core Temperature: " & Ufo_System.Temperature_Celsius'Image(S.Core_Temperature) & " C");
      IO.Put_Line("  (Human comfort: " & Ufo_System.Temperature_Celsius'Image(Ufo_System.Human_Min_Temp) & "-" & 
                  Ufo_System.Temperature_Celsius'Image(Ufo_System.Human_Max_Temp) & " C)");
      IO.Put_Line("Environment:");
      IO.Put_Line("  Body Type: " & Ufo_System.Celestial_Body_Type'Image(S.Environment.Body_Type));
      IO.Put_Line("  Distance:  " & Ufo_System.Kilometers'Image(S.Environment.Relative_Distance) & " km");
      IO.Put_Line("  Pressure:  " & Float'Image(S.Environment.Atmospheric_Pressure) & " hPa");
      IO.Put_Line("  Obstacle:  "       IO.Put_Line("  Obstacle:  "       IO.Put_Line("  Obstacle:  "       IO.Put_Line("  Obstacle:  " & S.Environment.Has_Obstacle'Image(S.Environment.Has_Obstacle)); (if S.Environment.Has_Obstacle = Ufo_System.Obstacle_Detected then "Detected" else "None")); (if S.Environment.Has_Obstacle = Ufo_System.Obstacle_Detected then "Detected" else "None")); (if S.Environment.Has_Obstacle = Ufo_System.Obstacle_Detected then "Detected" else "None"));
      end if;
      IO.New_Line;
   end Print_State;
   
   procedure Print_Help is
   begin
      IO.Put_Line("UFO System Terminal Controller");
      IO.Put_Line("Usage:");
      IO.Put_Line("  main                    - Run interactive mode");
      IO.Put_Line("  main demo               - Run demonstration sequence");
      IO.Put_Line("  main test               - Run built-in tests");
      IO.Put_Line("  main help               - Show this help");
   end Print_Help;
   
   procedure Run_Demo is
      Default_Env : Ufo_System.Environment_State;
   begin
      IO.Put_Line("=== UFO System Demonstration ===");
      IO.New_Line;
      
      -- Initialize state with full environment (using SI units)
      Default_Env := (
         Relative_Distance => 10,  -- 10 km from Earth surface
         Body_Type => Ufo_System.Earth,
         Atmospheric_Pressure => 1013.25,
         Has_Obstacle => Ufo_System.No_Obstacle,
         Obstacle_Distance => 0
      );
      
      State := (
         Is_Rotating    => False,
         Current_Wind   => 0,
         Mode           => Ufo_System.Atmospheric_Cruise,
         Hull_Integrity => 100,
         Current_Speed  => 0,
         Current_Altitude => 0,
         Current_Heading => 0,
         Core_Temperature => 22,  -- Comfortable human temperature
         Environment     => Default_Env,
         Target_Speed    => 0
      );
      
      IO.Put_Line("Initial state:");
      Print_State(State);
      
      -- Engage rotation
      IO.Put_Line("Engaging rotation...");
      Ufo_System.Engage_Rotation(State);
      Print_State(State);
      
      -- Set speed and altitude (using m/s and km)
      IO.Put_Line("Setting speed to 150 m/s (~300 knots)...");
      Ufo_System.Set_Speed(State, 150);
      Print_State(State);
      
      IO.Put_Line("Setting altitude to 5 km...");
      Ufo_System.Set_Altitude(State, 5);
      Print_State(State);
      
      -- Calculate target speed (should be Earth escape velocity: 11,186 m/s)
      IO.Put_Line("Calculating target speed for Atmospheric Cruise mode...");
      Ufo_System.Calculate_Target_Speed(State);
      Print_State(State);
      
      -- Adjust to environment (should work toward escape velocity)
      IO.Put_Line("Adjusting to environment (will work toward escape velocity)...");
      Ufo_System.Adjust_To_Environment(State);
      Print_State(State);
      
      -- Switch to Hover mode
      IO.Put_Line("Switching to Hover mode...");
      State.Mode := Ufo_System.Hover;
      Print_State(State);
      
      -- Adjust to environment for hover (should limit to 50 m/s, 1 km)
      IO.Put_Line("Adjusting to environment for Hover mode...");
      Ufo_System.Adjust_To_Environment(State);
      Print_State(State);
      
      -- Compensate wind
      IO.Put_Line("Compensating for 100 knots wind...");
      Ufo_System.Compensate_Wind(State, 100);
      Print_State(State);
      
      -- Switch to interstellar
      IO.Put_Line("Switching to Interstellar mode...");
      State.Mode := Ufo_System.Interstellar;
      Print_State(State);
      
      -- Update environment for deep space (1,000,000 km from Earth, no obstacles)
      IO.Put_Line("Entering deep space (1,000,000 km from Earth, no obstacles)...");
      State.Environment := (
         Relative_Distance => 1_000_000,
         Body_Type => Ufo_System.Deep_Space,
         Atmospheric_Pressure => 0.0,
         Has_Obstacle => Ufo_System.No_Obstacle,
         Obstacle_Distance => 0
      );
      Print_State(State);
      
      -- Calculate target speed (should be near light speed (99.9% of c))
      IO.Put_Line("Calculating target speed for Interstellar in deep space...");
      Ufo_System.Calculate_Target_Speed(State);
      Print_State(State);
      
      -- Adjust to environment (should work toward near light speed (99.9% of c) and 16,000+ km altitude)
      IO.Put_Line("Adjusting to environment for Interstellar mode in deep space...");
      Ufo_System.Adjust_To_Environment(State);
      Print_State(State);
      
      -- Simulate obstacle detection in deep space
      IO.Put_Line("OBSTACLE DETECTED! Asteroid at 500 km distance...");
      Ufo_System.Set_Obstacle(State, Ufo_System.Obstacle_Detected, 500);
      Print_State(State);
      
      -- Calculate new target speed (should reduce for evasion)
      IO.Put_Line("Calculating new target speed with obstacle...");
      Ufo_System.Calculate_Target_Speed(State);
      Print_State(State);
      
      -- Adjust to environment (should reduce speed for evasion)
      IO.Put_Line("Adjusting speed for obstacle evasion...");
      Ufo_System.Adjust_To_Environment(State);
      Print_State(State);
      
      -- Obstacle cleared
      IO.Put_Line("Obstacle cleared! Resuming normal operations...");
      Ufo_System.Set_Obstacle(State, Ufo_System.No_Obstacle, 0);
      Print_State(State);
      
      -- Simulate temperature increase (but still within human comfort)
      IO.Put_Line("Simulating temperature increase to 28C (above comfort range)...");
      Ufo_System.Set_Temperature(State, 28);
      Print_State(State);
      
      -- Regulate temperature (should cool to 25C)
      IO.Put_Line("Board computer regulating temperature...");
      Ufo_System.Regulate_Temperature(State);
      Print_State(State);
      
      -- Simulate core overheating (35C - critical)
      IO.Put_Line("Simulating core overheating (35C - critical)...");
      Ufo_System.Set_Temperature(State, 35);
      Print_State(State);
      
      -- Emergency cooling should activate
      IO.Put_Line("EMERGENCY: Core temperature critical! Board computer activating emergency cooling...");
      Ufo_System.Regulate_Temperature(State);
      Print_State(State);
      
      -- Damage hull
      IO.Put_Line("Simulating hull damage (40%)...");
      State.Hull_Integrity := 40;
      Print_State(State);
      
      -- Try to compensate wind with damaged hull (should fail with SPARK pre-condition)
      IO.Put_Line("Attempting to compensate 50 knots with damaged hull...");
      begin
         Ufo_System.Compensate_Wind(State, 50);
         IO.Put_Line("Wind compensated successfully!");
      exception
         when others =>
            IO.Put_Line("ERROR: Cannot compensate wind - hull integrity too low!");
            IO.Put_Line("  (SPARK pre-condition prevented operation)");
      end;
      
      -- Return to Earth environment
      IO.Put_Line("Returning to Earth atmosphere...");
      State.Environment := Default_Env;
      State.Mode := Ufo_System.Atmospheric_Cruise;
      State.Hull_Integrity := 100;
      State.Core_Temperature := 22;
      Ufo_System.Set_Speed(State, 150);
      Ufo_System.Set_Altitude(State, 10);
      Print_State(State);
      
      -- Adjust to environment one more time
      IO.Put_Line("Final adjustment to environment...");
      Ufo_System.Adjust_To_Environment(State);
      Print_State(State);
      
      IO.Put_Line("=== Demonstration Complete ===");
   end Run_Demo;
   
   procedure Run_Interactive is
      Input : String(1..100);
      Last  : Integer;
   begin
      IO.Put_Line("=== UFO System Interactive Mode ===");
      IO.Put_Line("Commands: state, rotate, wind <knots>, mode <hover|interstellar|cruise>,");
      IO.Put_Line("         speed <m/s>, altitude <km>, heading <degrees>,");
      IO.Put_Line("         temp <celsius>, env <body> <distance_km> <pressure_hPa>,");
      IO.Put_Line("         obstacle <on|off> <distance_km>, calculate_target, adjust,");
      IO.Put_Line("         regulate_temp, emergency_cool, damage <percent>, repair <percent>,");
      IO.Put_Line("         help, quit");
      IO.New_Line;
      
      -- Initialize state with default environment
      State := (
         Is_Rotating    => False,
         Current_Wind   => 0,
         Mode           => Ufo_System.Atmospheric_Cruise,
         Hull_Integrity => 100,
         Current_Speed  => 0,
         Current_Altitude => 0,
         Current_Heading => 0,
         Core_Temperature => 22,
         Environment     => (
            Relative_Distance => 10,
            Body_Type => Ufo_System.Earth,
            Atmospheric_Pressure => 1013.25,
            Has_Obstacle => Ufo_System.No_Obstacle,
            Obstacle_Distance => 0
         ),
         Target_Speed    => 0
      );
      
      loop
         IO.Put("> ");
         Ada.Text_IO.Get_Line(Input, Last);
         
         declare
            Cmd : constant String := Input(1..Last);
            Tokens  : constant Integer := Count_Tokens(Cmd);
         begin
            if Tokens = 0 then
               null;
            elsif Token(Cmd, 1) = "quit" or Token(Cmd, 1) = "exit" then
               IO.Put_Line("Exiting...");
               exit;
            elsif Token(Cmd, 1) = "help" then
               IO.Put_Line("Available commands:");
               IO.Put_Line("  state              - Show current state");
               IO.Put_Line("  rotate             - Engage rotation");
               IO.Put_Line("  wind <knots>       - Compensate for wind");
               IO.Put_Line("  mode <m>           - Set propulsion mode (hover, interstellar, cruise)");
               IO.Put_Line("  speed <m/s>        - Set speed in meters per second");
               IO.Put_Line("  altitude <km>      - Set altitude in kilometers");
               IO.Put_Line("  heading <degrees>  - Set heading/direction");
               IO.Put_Line("  temp <celsius>     - Set core temperature");
               IO.Put_Line("  env <body> <dist> <press> - Set environment (body: earth/moon/mars/space/other)");
               IO.Put_Line("  obstacle <on|off> <dist> - Set obstacle detection");
               IO.Put_Line("  calculate_target   - Calculate target speed for current mode");
               IO.Put_Line("  adjust             - Auto-adjust speed/altitude to environment");
               IO.Put_Line("  regulate_temp      - Regulate temperature to human comfort range");
               IO.Put_Line("  emergency_cool     - Emergency cooling (requires temp > 30C)");
               IO.Put_Line("  damage <percent>   - Damage hull by percentage");
               IO.Put_Line("  repair <percent>   - Repair hull by percentage");
               IO.Put_Line("  help               - Show this help");
               IO.Put_Line("  quit               - Exit");
            elsif Token(Cmd, 1) = "state" then
               Print_State(State);
            elsif Token(Cmd, 1) = "rotate" then
               Ufo_System.Engage_Rotation(State);
               IO.Put_Line("Rotation engaged!");
            elsif Token(Cmd, 1) = "wind" and Tokens >= 2 then
               declare
                  Wind_Speed : Integer;
               begin
                  Wind_Speed := Integer'Value(Token(Cmd, 2));
                  if Wind_Speed >= 0 and Wind_Speed <= 5000 then
                     begin
                        Ufo_System.Compensate_Wind(State, Ufo_System.Knots(Wind_Speed));
                        IO.Put_Line("Wind compensated to " & Ufo_System.Knots'Image(Ufo_System.Knots(Wind_Speed)));
                     exception
                        when others =>
                           IO.Put_Line("ERROR: Cannot compensate wind - hull integrity too low!");
                           IO.Put_Line("  Current hull integrity: " & Integer'Image(State.Hull_Integrity) & "%");
                           IO.Put_Line("  Minimum required: 50%");
                     end;
                  else
                     IO.Put_Line("ERROR: Wind speed must be 0-5000 knots");
                  end if;
               exception
                  when others =>
                     IO.Put_Line("ERROR: Invalid wind speed value");
               end;
            elsif Token(Cmd, 1) = "mode" and Tokens >= 2 then
               declare
                  Mode_Str : constant String := To_Lower(Token(Cmd, 2));
               begin
                  if Mode_Str = "hover" then
                     State.Mode := Ufo_System.Hover;
                     IO.Put_Line("Propulsion mode set to Hover");
                  elsif Mode_Str = "interstellar" then
                     State.Mode := Ufo_System.Interstellar;
                     IO.Put_Line("Propulsion mode set to Interstellar");
                  elsif Mode_Str = "cruise" or Mode_Str = "atmospheric" then
                     State.Mode := Ufo_System.Atmospheric_Cruise;
                     IO.Put_Line("Propulsion mode set to Atmospheric Cruise");
                  else
                     IO.Put_Line("ERROR: Invalid mode. Use: hover, interstellar, cruise");
                  end if;
               end;
            elsif Token(Cmd, 1) = "speed" and Tokens >= 2 then
               declare
                  Speed : Integer;
               begin
                  Speed := Integer'Value(Token(Cmd, 2));
                  if Speed >= 0 and Speed <= 299_493_155 then
                     Ufo_System.Set_Speed(State, Ufo_System.Meters_Per_Second(Speed));
                     IO.Put_Line("Speed set to " & Ufo_System.Meters_Per_Second'Image(Ufo_System.Meters_Per_Second(Speed)) & " m/s");
                  else
                     IO.Put_Line("ERROR: Speed must be 0-299493155 m/s (near light speed (99.9% of c)))");
                  end if;
               exception
                  when others =>
                     IO.Put_Line("ERROR: Invalid speed value");
               end;
            elsif Token(Cmd, 1) = "altitude" and Tokens >= 2 then
               declare
                  Altitude : Integer;
               begin
                  Altitude := Integer'Value(Token(Cmd, 2));
                  if Altitude >= 0 and Altitude <= 1_000_000_000 then
                     Ufo_System.Set_Altitude(State, Ufo_System.Kilometers(Altitude));
                     IO.Put_Line("Altitude set to " & Ufo_System.Kilometers'Image(Ufo_System.Kilometers(Altitude)) & " km");
                  else
                     IO.Put_Line("ERROR: Altitude must be 0-1000000000 km");
                  end if;
               exception
                  when others =>
                     IO.Put_Line("ERROR: Invalid altitude value");
               end;
            elsif Token(Cmd, 1) = "heading" and Tokens >= 2 then
               declare
                  Heading : Integer;
               begin
                  Heading := Integer'Value(Token(Cmd, 2));
                  if Heading >= 0 and Heading <= 359 then
                     Ufo_System.Set_Heading(State, Ufo_System.Degrees(Heading));
                     IO.Put_Line("Heading set to " & Ufo_System.Degrees'Image(Ufo_System.Degrees(Heading)));
                  else
                     IO.Put_Line("ERROR: Heading must be 0-359 degrees");
                  end if;
               exception
                  when others =>
                     IO.Put_Line("ERROR: Invalid heading value");
               end;
            elsif Token(Cmd, 1) = "temp" and Tokens >= 2 then
               declare
                  Temp : Integer;
               begin
                  Temp := Integer'Value(Token(Cmd, 2));
                  if Temp >= -100 and Temp <= 2000 then
                     Ufo_System.Set_Temperature(State, Ufo_System.Temperature_Celsius(Temp));
                     IO.Put_Line("Core temperature set to " & Ufo_System.Temperature_Celsius'Image(Ufo_System.Temperature_Celsius(Temp)) & " C");
                  else
                     IO.Put_Line("ERROR: Temperature must be -100 to 2000 Celsius");
                  end if;
               exception
                  when others =>
                     IO.Put_Line("ERROR: Invalid temperature value");
               end;
            elsif Token(Cmd, 1) = "env" and Tokens >= 4 then
               declare
                  Body_Str : constant String := To_Lower(Token(Cmd, 2));
                  Distance : Integer;
                  Pressure : Float;
               begin
                  Distance := Integer'Value(Token(Cmd, 3));
                  Pressure := Float'Value(Token(Cmd, 4));
                  
                  -- Parse body type
                  if Body_Str = "earth" then
                     State.Environment.Body_Type := Ufo_System.Earth;
                  elsif Body_Str = "moon" then
                     State.Environment.Body_Type := Ufo_System.Moon;
                  elsif Body_Str = "mars" then
                     State.Environment.Body_Type := Ufo_System.Mars;
                  elsif Body_Str = "space" or Body_Str = "deep" then
                     State.Environment.Body_Type := Ufo_System.Deep_Space;
                  else
                     State.Environment.Body_Type := Ufo_System.Other;
                  end if;
                  
                  State.Environment.Relative_Distance := Ufo_System.Kilometers(Distance);
                  State.Environment.Atmospheric_Pressure := Pressure;
                  
                  IO.Put_Line("Environment set:");
                  IO.Put_Line("  Body: " & Ufo_System.Celestial_Body_Type'Image(State.Environment.Body_Type));
                  IO.Put_Line("  Distance: " & Ufo_System.Kilometers'Image(State.Environment.Relative_Distance) & " km");
                  IO.Put_Line("  Pressure: " & Float'Image(State.Environment.Atmospheric_Pressure) & " hPa");
               exception
                  when others =>
                     IO.Put_Line("ERROR: Invalid environment parameters");
               end;
            elsif Token(Cmd, 1) = "obstacle" and Tokens >= 2 then
               declare
                  Obstacle_Status : constant String := To_Lower(Token(Cmd, 2));
                  Distance : Integer := 0;
               begin
                  if Tokens >= 3 then
                     Distance := Integer'Value(Token(Cmd, 3));
                  end if;
                  
                  if Obstacle_Status = "on" or Obstacle_Status = "yes" or Obstacle_Status = "true" then
                     Ufo_System.Set_Obstacle(State, Ufo_System.Obstacle_Detected, Ufo_System.Kilometers(Distance));
                     IO.Put_Line("Obstacle detected at " & Ufo_System.Kilometers'Image(Ufo_System.Kilometers(Distance)) & " km");
                  elsif Obstacle_Status = "off" or Obstacle_Status = "no" or Obstacle_Status = "false" then
                     Ufo_System.Set_Obstacle(State, Ufo_System.No_Obstacle, 0);
                     IO.Put_Line("No obstacle - clear path");
                  else
                     IO.Put_Line("ERROR: Use 'on' or 'off' for obstacle status");
                  end if;
               exception
                  when others =>
                     IO.Put_Line("ERROR: Invalid obstacle parameters");
               end;
            elsif Token(Cmd, 1) = "calculate_target" then
               begin
                  Ufo_System.Calculate_Target_Speed(State);
                  IO.Put_Line("Target speed calculated: " & Ufo_System.Meters_Per_Second'Image(State.Target_Speed) & " m/s");
               exception
                  when others =>
                     IO.Put_Line("ERROR: Cannot calculate target speed");
               end;
            elsif Token(Cmd, 1) = "adjust" then
               begin
                  Ufo_System.Adjust_To_Environment(State);
                  IO.Put_Line("Adjusted speed and altitude to environment:");
                  IO.Put_Line("  Speed: " & Ufo_System.Meters_Per_Second'Image(State.Current_Speed) & " m/s");
                  IO.Put_Line("  Altitude: " & Ufo_System.Kilometers'Image(State.Current_Altitude) & " km");
               exception
                  when others =>
                     IO.Put_Line("ERROR: Cannot adjust - invalid environment state");
               end;
            elsif Token(Cmd, 1) = "regulate_temp" then
               begin
                  Ufo_System.Regulate_Temperature(State);
                  IO.Put_Line("Temperature regulated to human comfort range");
                  IO.Put_Line("  New temperature: " & Ufo_System.Temperature_Celsius'Image(State.Core_Temperature) & " C");
               exception
                  when others =>
                     IO.Put_Line("ERROR: Temperature regulation failed");
               end;
            elsif Token(Cmd, 1) = "emergency_cool" then
               begin
                  Ufo_System.Emergency_Cooling(State);
                  IO.Put_Line("EMERGENCY: Emergency cooling activated!");
                  IO.Put_Line("  New temperature: " & Ufo_System.Temperature_Celsius'Image(State.Core_Temperature) & " C");
               exception
                  when Constraint_Error =>
                     IO.Put_Line("ERROR: Emergency cooling not triggered - temperature must be > 30C");
                     IO.Put_Line("  Current temperature: " & Ufo_System.Temperature_Celsius'Image(State.Core_Temperature) & " C");
                  when others =>
                     IO.Put_Line("ERROR: Emergency cooling failed");
               end;
            elsif Token(Cmd, 1) = "damage" and Tokens >= 2 then
               declare
                  Damage : Integer;
               begin
                  Damage := Integer'Value(Token(Cmd, 2));
                  if Damage >= 0 and Damage <= 100 then
                     State.Hull_Integrity := Integer'Max(0, State.Hull_Integrity - Damage);
                     IO.Put_Line("Hull damaged by " & Integer'Image(Damage) & "%");
                     IO.Put_Line("  New hull integrity: " & Integer'Image(State.Hull_Integrity) & "%");
                  else
                     IO.Put_Line("ERROR: Damage must be 0-100%");
                  end if;
               exception
                  when others =>
                     IO.Put_Line("ERROR: Invalid damage value");
               end;
            elsif Token(Cmd, 1) = "repair" and Tokens >= 2 then
               declare
                  Repair : Integer;
               begin
                  Repair := Integer'Value(Token(Cmd, 2));
                  if Repair >= 0 and Repair <= 100 then
                     State.Hull_Integrity := Integer'Min(100, State.Hull_Integrity + Repair);
                     IO.Put_Line("Hull repaired by " & Integer'Image(Repair) & "%");
                     IO.Put_Line("  New hull integrity: " & Integer'Image(State.Hull_Integrity) & "%");
                  else
                     IO.Put_Line("ERROR: Repair must be 0-100%");
                  end if;
               exception
                  when others =>
                     IO.Put_Line("ERROR: Invalid repair value");
               end;
            else
               IO.Put_Line("ERROR: Unknown command. Type 'help' for available commands.");
            end if;
         end;
      end loop;
   end Run_Interactive;
   
   -- Helper functions for command parsing
   function Count_Tokens (S : String) return Integer is
      Count : Integer := 0;
      In_Token : Boolean := False;
   begin
      for I in S'Range loop
         if S(I) /= ' ' and not In_Token then
            Count := Count + 1;
            In_Token := True;
         elsif S(I) = ' ' then
            In_Token := False;
         end if;
      end loop;
      return Count;
   end Count_Tokens;
   
   function Token (S : String; N : Integer) return String is
      Count : Integer := 0;
      Start : Integer := S'First;
      Current : Integer := S'First;
   begin
      loop
         -- Skip whitespace
         while Current <= S'Last and S(Current) = ' ' loop
            Current := Current + 1;
         end loop;
         
         if Current > S'Last then
            return "";
         end if;
         
         Count := Count + 1;
         
         if Count = N then
            Start := Current;
            -- Find end of token
            while Current <= S'Last and S(Current) /= ' ' loop
               Current := Current + 1;
            end loop;
            return S(Start..Current-1);
         end if;
         
         -- Skip to next whitespace
         while Current <= S'Last and S(Current) /= ' ' loop
            Current := Current + 1;
         end loop;
      end loop;
   end Token;
   
   function To_Lower (S : String) return String is
      Result : String := S;
   begin
      for I in Result'Range loop
         if Result(I) >= 'A' and Result(I) <= 'Z' then
            Result(I) := Character'Val(Character'Pos(Result(I)) + 32);
         end if;
      end loop;
      return Result;
   end To_Lower;

begin
   if Ada.Command_Line.Argument_Count = 0 then
      Run_Interactive;
   else
      declare
         Arg : constant String := Ada.Command_Line.Argument(1);
      begin
         if Arg = "demo" then
            Run_Demo;
         elsif Arg = "test" then
            IO.Put_Line("Running built-in tests...");
            IO.Put_Line("Note: Comprehensive tests are in the tests/ directory");
            IO.Put_Line("Run 'gnat test' or use the test project file");
         elsif Arg = "help" or Arg = "--help" or Arg = "-h" then
            Print_Help;
         else
            IO.Put_Line("ERROR: Unknown argument '" & Arg & "'");
            IO.New_Line;
            Print_Help;
         end if;
      end;
   end if;
end Main;
