with Ufo_System;
with Ufo_System_Tests;

procedure Test_Ufo_System is
   -- Test cases for UFO System package
   
   package Ufo renames Ufo_System;
   package Tests renames Ufo_System_Tests;
   
   Default_Env : Ufo.Environment_State := (
      Relative_Distance => 10,  -- 10 km from Earth
      Body_Type => Ufo.Earth,
      Atmospheric_Pressure => 1013.25,
      Has_Obstacle => Ufo.No_Obstacle,
      Obstacle_Distance => 0
   );
   
   -- Test 1: Initial state values
   procedure Test_Initial_State is
      State : Ufo.UAP_State;
   begin
      -- Default initialized state
      State := (False, 0, Ufo.Atmospheric_Cruise, 0, 0, 0, 0, 22, Default_Env, 0);
      
      Tests.Assert(State.Is_Rotating = False, "Initial Is_Rotating should be False");
      Tests.Assert_Equal(State.Current_Wind, 0, "Initial Current_Wind should be 0");
      Tests.Assert(State.Mode = Ufo.Atmospheric_Cruise, "Initial Mode should be Atmospheric_Cruise");
      Tests.Assert_Equal(State.Hull_Integrity, 0, "Initial Hull_Integrity should be 0");
      Tests.Assert_Equal(State.Current_Speed, 0, "Initial Current_Speed should be 0");
      Tests.Assert_Equal(State.Current_Altitude, 0, "Initial Current_Altitude should be 0");
      Tests.Assert_Equal(State.Current_Heading, 0, "Initial Current_Heading should be 0");
      Tests.Assert_Equal(State.Core_Temperature, 22, "Initial Core_Temperature should be 22");
      Tests.Assert_Equal(State.Target_Speed, 0, "Initial Target_Speed should be 0");
   end Test_Initial_State;
   
   -- Test 2: Engage_Rotation sets Is_Rotating to True
   procedure Test_Engage_Rotation is
      State : Ufo.UAP_State := (False, 0, Ufo.Atmospheric_Cruise, 100, 0, 0, 0, 22, Default_Env, 0);
   begin
      Tests.Assert(State.Is_Rotating = False, "Precondition: Is_Rotating should be False");
      
      Ufo.Engage_Rotation(State);
      
      Tests.Assert(State.Is_Rotating = True, "After Engage_Rotation, Is_Rotating should be True");
      Tests.Assert_Equal(State.Current_Wind, 0, "Engage_Rotation should not change Current_Wind");
      Tests.Assert(State.Mode = Ufo.Atmospheric_Cruise, "Engage_Rotation should not change Mode");
      Tests.Assert_Equal(State.Hull_Integrity, 100, "Engage_Rotation should not change Hull_Integrity");
   end Test_Engage_Rotation;
   
   -- Test 3: Compensate_Wind sets Current_Wind
   procedure Test_Compensate_Wind is
      State : Ufo.UAP_State := (False, 0, Ufo.Atmospheric_Cruise, 100, 0, 0, 0, 22, Default_Env, 0);
   begin
      Tests.Assert_Equal(State.Current_Wind, 0, "Precondition: Current_Wind should be 0");
      Tests.Assert(State.Hull_Integrity > 50, "Precondition: Hull_Integrity must be > 50");
      
      Ufo.Compensate_Wind(State, 150);
      
      Tests.Assert_Equal(State.Current_Wind, 150, "After Compensate_Wind(150), Current_Wind should be 150");
   end Test_Compensate_Wind;
   
   -- Test 4: Compensate_Wind with zero wind
   procedure Test_Compensate_Wind_Zero is
      State : Ufo.UAP_State := (False, 100, Ufo.Atmospheric_Cruise, 100, 0, 0, 0, 22, Default_Env, 0);
   begin
      Ufo.Compensate_Wind(State, 0);
      Tests.Assert_Equal(State.Current_Wind, 0, "Compensate_Wind(0) should set Current_Wind to 0");
   end Test_Compensate_Wind_Zero;
   
   -- Test 5: Compensate_Wind with maximum wind
   procedure Test_Compensate_Wind_Max is
      State : Ufo.UAP_State := (False, 0, Ufo.Atmospheric_Cruise, 100, 0, 0, 0, 22, Default_Env, 0);
   begin
      Ufo.Compensate_Wind(State, 5000);
      Tests.Assert_Equal(State.Current_Wind, 5000, "Compensate_Wind(5000) should work");
   end Test_Compensate_Wind_Max;
   
   -- Test 6: Compensate_Wind fails with low hull integrity (SPARK pre-condition)
   procedure Test_Compensate_Wind_Low_Hull is
      State : Ufo.UAP_State := (False, 0, Ufo.Atmospheric_Cruise, 40, 0, 0, 0, 22, Default_Env, 0);
      Wind_Speed : Ufo.Knots := 100;
   begin
      Tests.Assert(State.Hull_Integrity <= 50, "Precondition: Hull_Integrity should be <= 50");
      
      -- This should raise Constraint_Error due to SPARK pre-condition
      begin
         Ufo.Compensate_Wind(State, Wind_Speed);
         Tests.Assert(False, "Compensate_Wind should have raised Constraint_Error");
      exception
         when Constraint_Error =>
            Tests.Assert(True, "Compensate_Wind correctly raised Constraint_Error for low hull integrity");
      end;
   end Test_Compensate_Wind_Low_Hull;
   
   -- Test 7: Propulsion modes
   procedure Test_Propulsion_Modes is
      State : Ufo.UAP_State := (False, 0, Ufo.Atmospheric_Cruise, 100, 0, 0, 0, 22, Default_Env, 0);
   begin
      -- Test Hover mode
      State.Mode := Ufo.Hover;
      Tests.Assert(State.Mode = Ufo.Hover, "Mode should be Hover");
      
      -- Test Interstellar mode
      State.Mode := Ufo.Interstellar;
      Tests.Assert(State.Mode = Ufo.Interstellar, "Mode should be Interstellar");
      
      -- Test Atmospheric_Cruise mode
      State.Mode := Ufo.Atmospheric_Cruise;
      Tests.Assert(State.Mode = Ufo.Atmospheric_Cruise, "Mode should be Atmospheric_Cruise");
   end Test_Propulsion_Modes;
   
   -- Test 8: Hull integrity range
   procedure Test_Hull_Integrity_Range is
      State : Ufo.UAP_State := (False, 0, Ufo.Atmospheric_Cruise, 0, 0, 0, 0, 22, Default_Env, 0);
   begin
      -- Test minimum hull integrity
      State.Hull_Integrity := 0;
      Tests.Assert_Equal(State.Hull_Integrity, 0, "Hull_Integrity can be 0");
      
      -- Test maximum hull integrity
      State.Hull_Integrity := 100;
      Tests.Assert_Equal(State.Hull_Integrity, 100, "Hull_Integrity can be 100");
      
      -- Test mid-range
      State.Hull_Integrity := 50;
      Tests.Assert_Equal(State.Hull_Integrity, 50, "Hull_Integrity can be 50");
   end Test_Hull_Integrity_Range;
   
   -- Test 9: Wind speed range
   procedure Test_Wind_Speed_Range is
      State : Ufo.UAP_State := (False, 0, Ufo.Atmospheric_Cruise, 100, 0, 0, 0, 22, Default_Env, 0);
   begin
      -- Test various wind speeds
      Ufo.Compensate_Wind(State, 0);
      Tests.Assert_Equal(State.Current_Wind, 0, "Wind speed 0 is valid");
      
      Ufo.Compensate_Wind(State, 100);
      Tests.Assert_Equal(State.Current_Wind, 100, "Wind speed 100 is valid");
      
      Ufo.Compensate_Wind(State, 1000);
      Tests.Assert_Equal(State.Current_Wind, 1000, "Wind speed 1000 is valid");
      
      Ufo.Compensate_Wind(State, 5000);
      Tests.Assert_Equal(State.Current_Wind, 5000, "Wind speed 5000 is valid");
   end Test_Wind_Speed_Range;
   
   -- Test 10: Set_Speed procedure (in m/s)
   procedure Test_Set_Speed is
      State : Ufo.UAP_State := (False, 0, Ufo.Atmospheric_Cruise, 100, 0, 0, 0, 22, Default_Env, 0);
   begin
      Tests.Assert_Equal(State.Current_Speed, 0, "Initial speed should be 0");
      
      Ufo.Set_Speed(State, 150);
      Tests.Assert_Equal(State.Current_Speed, 150, "Speed should be set to 150 m/s");
      
      Ufo.Set_Speed(State, 0);
      Tests.Assert_Equal(State.Current_Speed, 0, "Speed should be set to 0");
      
      Ufo.Set_Speed(State, 10_000);
      Tests.Assert_Equal(State.Current_Speed, 10_000, "Speed should be set to 10000 m/s");
   end Test_Set_Speed;
   
   -- Test 11: Set_Altitude procedure (in km)
   procedure Test_Set_Altitude is
      State : Ufo.UAP_State := (False, 0, Ufo.Atmospheric_Cruise, 100, 0, 0, 0, 22, Default_Env, 0);
   begin
      Tests.Assert_Equal(State.Current_Altitude, 0, "Initial altitude should be 0");
      
      Ufo.Set_Altitude(State, 5);
      Tests.Assert_Equal(State.Current_Altitude, 5, "Altitude should be set to 5 km");
      
      Ufo.Set_Altitude(State, 0);
      Tests.Assert_Equal(State.Current_Altitude, 0, "Altitude should be set to 0");
      
      Ufo.Set_Altitude(State, 100_000);
      Tests.Assert_Equal(State.Current_Altitude, 100_000, "Altitude should be set to 100000 km");
   end Test_Set_Altitude;
   
   -- Test 12: Set_Heading procedure
   procedure Test_Set_Heading is
      State : Ufo.UAP_State := (False, 0, Ufo.Atmospheric_Cruise, 100, 0, 0, 0, 22, Default_Env, 0);
   begin
      Tests.Assert_Equal(State.Current_Heading, 0, "Initial heading should be 0");
      
      Ufo.Set_Heading(State, 90);
      Tests.Assert_Equal(State.Current_Heading, 90, "Heading should be set to 90");
      
      Ufo.Set_Heading(State, 180);
      Tests.Assert_Equal(State.Current_Heading, 180, "Heading should be set to 180");
      
      Ufo.Set_Heading(State, 359);
      Tests.Assert_Equal(State.Current_Heading, 359, "Heading should be set to 359");
   end Test_Set_Heading;
   
   -- Test 13: Set_Temperature procedure
   procedure Test_Set_Temperature is
      State : Ufo.UAP_State := (False, 0, Ufo.Atmospheric_Cruise, 100, 0, 0, 0, 22, Default_Env, 0);
   begin
      Tests.Assert_Equal(State.Core_Temperature, 22, "Initial temperature should be 22");
      
      Ufo.Set_Temperature(State, 20);
      Tests.Assert_Equal(State.Core_Temperature, 20, "Temperature should be set to 20");
      
      Ufo.Set_Temperature(State, 18);
      Tests.Assert_Equal(State.Core_Temperature, 18, "Temperature should be set to 18 (min human comfort)");
      
      Ufo.Set_Temperature(State, 25);
      Tests.Assert_Equal(State.Core_Temperature, 25, "Temperature should be set to 25 (max human comfort)");
   end Test_Set_Temperature;
   
   -- Test 14: Set_Environment procedure
   procedure Test_Set_Environment is
      State : Ufo.UAP_State := (False, 0, Ufo.Atmospheric_Cruise, 100, 0, 0, 0, 22, Default_Env, 0);
      New_Env : Ufo.Environment_State;
   begin
      New_Env := (
         Relative_Distance => 100_000,
         Body_Type => Ufo.Mars,
         Atmospheric_Pressure => 600.0,
         Has_Obstacle => Ufo.No_Obstacle,
         Obstacle_Distance => 0
      );
      
      Ufo.Set_Environment(State, New_Env);
      Tests.Assert(State.Environment.Body_Type = Ufo.Mars, "Body type should be Mars");
      Tests.Assert_Equal(State.Environment.Relative_Distance, 100_000, "Distance should be 100000 km");
      Tests.Assert(State.Environment.Atmospheric_Pressure = 600.0, "Pressure should be 600.0 hPa");
   end Test_Set_Environment;
   
   -- Test 15: Set_Obstacle procedure
   procedure Test_Set_Obstacle is
      State : Ufo.UAP_State := (False, 0, Ufo.Atmospheric_Cruise, 100, 0, 0, 0, 22, Default_Env, 0);
   begin
      Tests.Assert(State.Environment.Has_Obstacle = Ufo.No_Obstacle, "Initial obstacle state should be No_Obstacle");
      
      Ufo.Set_Obstacle(State, Ufo.Obstacle_Detected, 500);
      Tests.Assert(State.Environment.Has_Obstacle = Ufo.Obstacle_Detected, "Obstacle should be detected");
      Tests.Assert_Equal(State.Environment.Obstacle_Distance, 500, "Obstacle distance should be 500 km");
      
      Ufo.Set_Obstacle(State, Ufo.No_Obstacle, 0);
      Tests.Assert(State.Environment.Has_Obstacle = Ufo.No_Obstacle, "Obstacle should be cleared");
      Tests.Assert_Equal(State.Environment.Obstacle_Distance, 0, "Obstacle distance should be 0");
   end Test_Set_Obstacle;
   
   -- Test 16: Regulate_Temperature for low temperature
   procedure Test_Regulate_Temperature_Low is
      State : Ufo.UAP_State := (False, 0, Ufo.Atmospheric_Cruise, 100, 0, 0, 0, 15, Default_Env, 0);
   begin
      Tests.Assert(State.Core_Temperature < Ufo.Human_Min_Temp, "Precondition: Temperature below minimum");
      
      Ufo.Regulate_Temperature(State);
      
      Tests.Assert_Equal(State.Core_Temperature, Ufo.Human_Min_Temp, "Temperature should be raised to minimum");
   end Test_Regulate_Temperature_Low;
   
   -- Test 17: Regulate_Temperature for high temperature (not critical)
   procedure Test_Regulate_Temperature_High is
      State : Ufo.UAP_State := (False, 0, Ufo.Atmospheric_Cruise, 100, 0, 0, 0, 28, Default_Env, 0);
   begin
      Tests.Assert(State.Core_Temperature > Ufo.Human_Max_Temp and State.Core_Temperature <= Ufo.Human_Critical_Temp, 
                   "Precondition: Temperature above max but not critical");
      
      Ufo.Regulate_Temperature(State);
      
      Tests.Assert_Equal(State.Core_Temperature, Ufo.Human_Max_Temp, "Temperature should be lowered to maximum");
   end Test_Regulate_Temperature_High;
   
   -- Test 18: Emergency_Cooling procedure (critical temperature)
   procedure Test_Emergency_Cooling is
      State : Ufo.UAP_State := (False, 0, Ufo.Atmospheric_Cruise, 100, 0, 0, 0, 35, Default_Env, 0);
   begin
      Tests.Assert(State.Core_Temperature > Ufo.Human_Critical_Temp, "Precondition: Temperature must be > 30C");
      
      Ufo.Emergency_Cooling(State);
      
      Tests.Assert(State.Core_Temperature <= Ufo.Human_Critical_Temp, "After emergency cooling, temperature should be <= 30C");
      Tests.Assert(State.Core_Temperature >= Ufo.Human_Max_Temp, "After emergency cooling, temperature should be >= 25C");
   end Test_Emergency_Cooling;
   
   -- Test 19: Emergency_Cooling fails when temperature is not critical
   procedure Test_Emergency_Cooling_Not_Triggered is
      State : Ufo.UAP_State := (False, 0, Ufo.Atmospheric_Cruise, 100, 0, 0, 0, 28, Default_Env, 0);
   begin
      Tests.Assert(State.Core_Temperature <= Ufo.Human_Critical_Temp, "Precondition: Temperature should be <= 30C");
      
      -- This should raise Constraint_Error due to SPARK pre-condition
      begin
         Ufo.Emergency_Cooling(State);
         Tests.Assert(False, "Emergency_Cooling should have raised Constraint_Error");
      exception
         when Constraint_Error =>
            Tests.Assert(True, "Emergency_Cooling correctly raised Constraint_Error for non-critical temperature");
      end;
   end Test_Emergency_Cooling_Not_Triggered;
   
   -- Test 20: Calculate_Target_Speed for Atmospheric_Cruise (should be escape velocity)
   procedure Test_Calculate_Target_Speed_Atmospheric is
      State : Ufo.UAP_State := (False, 0, Ufo.Atmospheric_Cruise, 100, 0, 0, 0, 22, Default_Env, 0);
   begin
      Ufo.Calculate_Target_Speed(State);
      Tests.Assert_Equal(State.Target_Speed, Ufo.Earth_Escape_Velocity, 
                        "Target speed should be Earth escape velocity in Atmospheric Cruise");
   end Test_Calculate_Target_Speed_Atmospheric;
   
   -- Test 21: Calculate_Target_Speed for Interstellar in deep space (should be light speed)
   procedure Test_Calculate_Target_Speed_Interstellar is
      State : Ufo.UAP_State;
      Space_Env : Ufo.Environment_State := (
         Relative_Distance => 1_000_000,
         Body_Type => Ufo.Deep_Space,
         Atmospheric_Pressure => 0.0,
         Has_Obstacle => Ufo.No_Obstacle,
         Obstacle_Distance => 0
      );
   begin
      State := (False, 0, Ufo.Interstellar, 100, 0, 0, 0, 22, Space_Env, 0);
      
      Ufo.Calculate_Target_Speed(State);
      Tests.Assert_Equal(State.Target_Speed, Ufo.Max_Achievable_Speed, 
                        "Target speed should be light speed in deep space");
   end Test_Calculate_Target_Speed_Interstellar;
   
   -- Test 22: Calculate_Target_Speed with obstacle (should reduce speed)
   procedure Test_Calculate_Target_Speed_With_Obstacle is
      State : Ufo.UAP_State;
      Space_Env : Ufo.Environment_State := (
         Relative_Distance => 1_000_000,
         Body_Type => Ufo.Deep_Space,
         Atmospheric_Pressure => 0.0,
         Has_Obstacle => Ufo.Obstacle_Detected,
         Obstacle_Distance => 500
      );
   begin
      State := (False, 0, Ufo.Interstellar, 100, 0, 0, 0, 22, Space_Env, 0);
      
      Ufo.Calculate_Target_Speed(State);
      Tests.Assert(State.Target_Speed <= Ufo.Max_Achievable_Speed, 
                   "Target speed should be less than light speed with obstacle");
      Tests.Assert_Equal(State.Target_Speed, 1_000, 
                        "Target speed should be 1000 m/s for 500 km obstacle");
   end Test_Calculate_Target_Speed_With_Obstacle;
   
   -- Test 23: Adjust_To_Environment for Hover mode
   procedure Test_Adjust_To_Environment_Hover is
      State : Ufo.UAP_State;
   begin
      State := (
         Is_Rotating => False,
         Current_Wind => 0,
         Mode => Ufo.Hover,
         Hull_Integrity => 100,
         Current_Speed => 100,  -- Too fast for hover (50 m/s max)
         Current_Altitude => 10,  -- Too high for hover (1 km max)
         Current_Heading => 0,
         Core_Temperature => 22,
         Environment => Default_Env,
         Target_Speed => 0
      );
      
      Ufo.Adjust_To_Environment(State);
      
      -- Hover mode should limit speed to 50 m/s and altitude to 1 km
      Tests.Assert(State.Current_Speed <= 50, "Hover mode should limit speed to <= 50 m/s");
      Tests.Assert(State.Current_Altitude <= 1, "Hover mode should limit altitude to <= 1 km");
      -- Temperature should be regulated to human comfort range
      Tests.Assert(State.Core_Temperature >= Ufo.Human_Min_Temp and State.Core_Temperature <= Ufo.Human_Max_Temp,
                   "Temperature should be in human comfort range");
   end Test_Adjust_To_Environment_Hover;
   
   -- Test 24: Adjust_To_Environment for Interstellar mode in deep space
   procedure Test_Adjust_To_Environment_Interstellar is
      State : Ufo.UAP_State;
      Space_Env : Ufo.Environment_State := (
         Relative_Distance => 1_000_000,
         Body_Type => Ufo.Deep_Space,
         Atmospheric_Pressure => 0.0,
         Has_Obstacle => Ufo.No_Obstacle,
         Obstacle_Distance => 0
      );
   begin
      State := (
         Is_Rotating => False,
         Current_Wind => 0,
         Mode => Ufo.Interstellar,
         Hull_Integrity => 100,
         Current_Speed => 100,  -- Too slow for interstellar (need > escape velocity)
         Current_Altitude => 10,  -- Too low for deep space (need >= 16,000 km)
         Current_Heading => 0,
         Core_Temperature => 22,
         Environment => Space_Env,
         Target_Speed => 0
      );
      
      Ufo.Adjust_To_Environment(State);
      
      -- Interstellar mode in deep space should increase speed toward light speed
      Tests.Assert(State.Current_Speed >= 10_000, "Interstellar mode in deep space should set speed >= 10000 m/s");
      -- And maintain minimum deep space altitude
      Tests.Assert(State.Current_Altitude >= Ufo.Deep_Space_Min_Altitude, 
                   "Altitude should be >= 16000 km in deep space");
      -- Temperature should be regulated
      Tests.Assert(State.Core_Temperature >= Ufo.Human_Min_Temp and State.Core_Temperature <= Ufo.Human_Max_Temp,
                   "Temperature should be in human comfort range");
   end Test_Adjust_To_Environment_Interstellar;
   
   -- Test 25: Adjust_To_Environment for Atmospheric_Cruise with dense atmosphere
   procedure Test_Adjust_To_Environment_Atmospheric_Dense is
      State : Ufo.UAP_State;
      Dense_Env : Ufo.Environment_State := (
         Relative_Distance => 5,
         Body_Type => Ufo.Earth,
         Atmospheric_Pressure => 1050.0,  -- High pressure (near sea level)
         Has_Obstacle => Ufo.No_Obstacle,
         Obstacle_Distance => 0
      );
   begin
      State := (
         Is_Rotating => False,
         Current_Wind => 0,
         Mode => Ufo.Atmospheric_Cruise,
         Hull_Integrity => 100,
         Current_Speed => 500,  -- Too fast for dense atmosphere
         Current_Altitude => 20,  -- Too high for dense atmosphere
         Current_Heading => 0,
         Core_Temperature => 22,
         Environment => Dense_Env,
         Target_Speed => 0
      );
      
      Ufo.Adjust_To_Environment(State);
      
      -- Dense atmosphere should limit speed and altitude
      Tests.Assert(State.Current_Speed <= 150, "Dense atmosphere should limit speed to <= 150 m/s");
      Tests.Assert(State.Current_Altitude <= 5, "Dense atmosphere should limit altitude to <= 5 km");
      -- Temperature should be regulated
      Tests.Assert(State.Core_Temperature >= Ufo.Human_Min_Temp and State.Core_Temperature <= Ufo.Human_Max_Temp,
                   "Temperature should be in human comfort range");
   end Test_Adjust_To_Environment_Atmospheric_Dense;
   
   -- Test 26: Sequential operations with new features
   procedure Test_Sequential_Operations is
      State : Ufo.UAP_State := (False, 0, Ufo.Atmospheric_Cruise, 100, 0, 0, 0, 22, Default_Env, 0);
   begin
      -- Start with initial state
      Tests.Assert(State.Is_Rotating = False, "Initial Is_Rotating is False");
      Tests.Assert_Equal(State.Current_Wind, 0, "Initial Current_Wind is 0");
      Tests.Assert_Equal(State.Current_Speed, 0, "Initial Current_Speed is 0");
      
      -- Set speed and altitude
      Ufo.Set_Speed(State, 150);
      Tests.Assert_Equal(State.Current_Speed, 150, "Speed set to 150 m/s");
      
      Ufo.Set_Altitude(State, 10);
      Tests.Assert_Equal(State.Current_Altitude, 10, "Altitude set to 10 km");
      
      -- Engage rotation
      Ufo.Engage_Rotation(State);
      Tests.Assert(State.Is_Rotating = True, "After rotation, Is_Rotating is True");
      
      -- Compensate wind
      Ufo.Compensate_Wind(State, 200);
      Tests.Assert_Equal(State.Current_Wind, 200, "After wind compensation, Current_Wind is 200");
      
      -- Change mode
      State.Mode := Ufo.Hover;
      Tests.Assert(State.Mode = Ufo.Hover, "Mode changed to Hover");
      
      -- Adjust to environment
      Ufo.Adjust_To_Environment(State);
      Tests.Assert(State.Current_Speed <= 50, "After adjustment, speed should be <= 50 m/s for hover");
      Tests.Assert(State.Current_Altitude <= 1, "After adjustment, altitude should be <= 1 km for hover");
      
      -- Damage hull
      State.Hull_Integrity := 60;
      Tests.Assert_Equal(State.Hull_Integrity, 60, "Hull integrity reduced to 60");
      
      -- Still can compensate wind (60 > 50)
      Ufo.Compensate_Wind(State, 50);
      Tests.Assert_Equal(State.Current_Wind, 50, "Can still compensate wind with hull at 60");
      
      -- Damage hull below threshold
      State.Hull_Integrity := 40;
      Tests.Assert_Equal(State.Hull_Integrity, 40, "Hull integrity reduced to 40");
      
      -- Cannot compensate wind now
      begin
         Ufo.Compensate_Wind(State, 10);
         Tests.Assert(False, "Should not be able to compensate wind with hull at 40");
      exception
         when Constraint_Error =>
            Tests.Assert(True, "Correctly prevented wind compensation with low hull");
      end;
      
      -- Set high temperature and trigger regulation
      Ufo.Set_Temperature(State, 28);
      Tests.Assert(State.Core_Temperature > Ufo.Human_Max_Temp, "Temperature set above 25C");
      
      Ufo.Regulate_Temperature(State);
      Tests.Assert_Equal(State.Core_Temperature, Ufo.Human_Max_Temp, "Temperature regulated to 25C");
      
      -- Set critical temperature and trigger emergency cooling
      Ufo.Set_Temperature(State, 35);
      Tests.Assert(State.Core_Temperature > Ufo.Human_Critical_Temp, "Temperature set above 30C");
      
      Ufo.Emergency_Cooling(State);
      Tests.Assert(State.Core_Temperature <= Ufo.Human_Critical_Temp, "Emergency cooling reduced temperature");
   end Test_Sequential_Operations;
   
   -- Test 27: Rotation doesn't affect other state
   procedure Test_Rotation_Isolation is
      State : Ufo.UAP_State := (False, 150, Ufo.Interstellar, 75, 10_000, 16_000, 45, 22, 
                                (1_000_000, Ufo.Deep_Space, 0.0, Ufo.No_Obstacle, 0), 10_000);
   begin
      Tests.Assert_Equal(State.Current_Wind, 150, "Pre: Current_Wind is 150");
      Tests.Assert(State.Mode = Ufo.Interstellar, "Pre: Mode is Interstellar");
      Tests.Assert_Equal(State.Hull_Integrity, 75, "Pre: Hull_Integrity is 75");
      Tests.Assert_Equal(State.Current_Speed, 10_000, "Pre: Current_Speed is 10000");
      Tests.Assert_Equal(State.Current_Altitude, 16_000, "Pre: Current_Altitude is 16000");
      Tests.Assert_Equal(State.Current_Heading, 45, "Pre: Current_Heading is 45");
      
      Ufo.Engage_Rotation(State);
      
      Tests.Assert(State.Is_Rotating = True, "Post: Is_Rotating is True");
      Tests.Assert_Equal(State.Current_Wind, 150, "Post: Current_Wind unchanged at 150");
      Tests.Assert(State.Mode = Ufo.Interstellar, "Post: Mode unchanged at Interstellar");
      Tests.Assert_Equal(State.Hull_Integrity, 75, "Post: Hull_Integrity unchanged at 75");
      Tests.Assert_Equal(State.Current_Speed, 10_000, "Post: Current_Speed unchanged at 10000");
      Tests.Assert_Equal(State.Current_Altitude, 16_000, "Post: Current_Altitude unchanged at 16000");
      Tests.Assert_Equal(State.Current_Heading, 45, "Post: Current_Heading unchanged at 45");
   end Test_Rotation_Isolation;
   
   -- Test 28: Wind compensation doesn't affect rotation or mode
   procedure Test_Wind_Compensation_Isolation is
      State : Ufo.UAP_State := (True, 0, Ufo.Hover, 100, 50, 1, 90, 22, Default_Env, 50);
   begin
      Tests.Assert(State.Is_Rotating = True, "Pre: Is_Rotating is True");
      Tests.Assert(State.Mode = Ufo.Hover, "Pre: Mode is Hover");
      Tests.Assert_Equal(State.Current_Speed, 50, "Pre: Current_Speed is 50");
      Tests.Assert_Equal(State.Current_Altitude, 1, "Pre: Current_Altitude is 1");
      Tests.Assert_Equal(State.Current_Heading, 90, "Pre: Current_Heading is 90");
      
      Ufo.Compensate_Wind(State, 300);
      
      Tests.Assert(State.Is_Rotating = True, "Post: Is_Rotating unchanged at True");
      Tests.Assert(State.Mode = Ufo.Hover, "Post: Mode unchanged at Hover");
      Tests.Assert_Equal(State.Current_Wind, 300, "Post: Current_Wind is 300");
      Tests.Assert_Equal(State.Current_Speed, 50, "Post: Current_Speed unchanged at 50");
      Tests.Assert_Equal(State.Current_Altitude, 1, "Post: Current_Altitude unchanged at 1");
      Tests.Assert_Equal(State.Current_Heading, 90, "Post: Current_Heading unchanged at 90");
   end Test_Wind_Compensation_Isolation;

begin
   -- Register all test cases
   Tests.Initialize_Tests;
   
   Tests.Register_Test("Initial State", Test_Initial_State'Access);
   Tests.Register_Test("Engage Rotation", Test_Engage_Rotation'Access);
   Tests.Register_Test("Compensate Wind", Test_Compensate_Wind'Access);
   Tests.Register_Test("Compensate Wind Zero", Test_Compensate_Wind_Zero'Access);
   Tests.Register_Test("Compensate Wind Max", Test_Compensate_Wind_Max'Access);
   Tests.Register_Test("Compensate Wind Low Hull", Test_Compensate_Wind_Low_Hull'Access);
   Tests.Register_Test("Propulsion Modes", Test_Propulsion_Modes'Access);
   Tests.Register_Test("Hull Integrity Range", Test_Hull_Integrity_Range'Access);
   Tests.Register_Test("Wind Speed Range", Test_Wind_Speed_Range'Access);
   Tests.Register_Test("Set Speed", Test_Set_Speed'Access);
   Tests.Register_Test("Set Altitude", Test_Set_Altitude'Access);
   Tests.Register_Test("Set Heading", Test_Set_Heading'Access);
   Tests.Register_Test("Set Temperature", Test_Set_Temperature'Access);
   Tests.Register_Test("Set Environment", Test_Set_Environment'Access);
   Tests.Register_Test("Set Obstacle", Test_Set_Obstacle'Access);
   Tests.Register_Test("Regulate Temperature Low", Test_Regulate_Temperature_Low'Access);
   Tests.Register_Test("Regulate Temperature High", Test_Regulate_Temperature_High'Access);
   Tests.Register_Test("Emergency Cooling", Test_Emergency_Cooling'Access);
   Tests.Register_Test("Emergency Cooling Not Triggered", Test_Emergency_Cooling_Not_Triggered'Access);
   Tests.Register_Test("Calculate Target Speed Atmospheric", Test_Calculate_Target_Speed_Atmospheric'Access);
   Tests.Register_Test("Calculate Target Speed Interstellar", Test_Calculate_Target_Speed_Interstellar'Access);
   Tests.Register_Test("Calculate Target Speed With Obstacle", Test_Calculate_Target_Speed_With_Obstacle'Access);
   Tests.Register_Test("Adjust Environment Hover", Test_Adjust_To_Environment_Hover'Access);
   Tests.Register_Test("Adjust Environment Interstellar", Test_Adjust_To_Environment_Interstellar'Access);
   Tests.Register_Test("Adjust Environment Atmospheric Dense", Test_Adjust_To_Environment_Atmospheric_Dense'Access);
   Tests.Register_Test("Sequential Operations", Test_Sequential_Operations'Access);
   Tests.Register_Test("Rotation Isolation", Test_Rotation_Isolation'Access);
   Tests.Register_Test("Wind Compensation Isolation", Test_Wind_Compensation_Isolation'Access);
   
   -- Run all tests
   Tests.Run_All_Tests;
end Test_Ufo_System;
