with Ufo_System;
with Ufo_System_Tests;

procedure Test_Ufo_System is
   -- Test cases for UFO System package
   
   package Ufo renames Ufo_System;
   package Tests renames Ufo_System_Tests;
   
   -- Test 1: Initial state values
   procedure Test_Initial_State is
      State : Ufo.UAP_State;
   begin
      -- Default initialized state
      State := (False, 0, Ufo.Atmospheric_Cruise, 0);
      
      Tests.Assert(State.Is_Rotating = False, "Initial Is_Rotating should be False");
      Tests.Assert_Equal(State.Current_Wind, 0, "Initial Current_Wind should be 0");
      Tests.Assert(State.Mode = Ufo.Atmospheric_Cruise, "Initial Mode should be Atmospheric_Cruise");
      Tests.Assert_Equal(State.Hull_Integrity, 0, "Initial Hull_Integrity should be 0");
   end Test_Initial_State;
   
   -- Test 2: Engage_Rotation sets Is_Rotating to True
   procedure Test_Engage_Rotation is
      State : Ufo.UAP_State := (False, 0, Ufo.Atmospheric_Cruise, 100);
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
      State : Ufo.UAP_State := (False, 0, Ufo.Atmospheric_Cruise, 100);
   begin
      Tests.Assert_Equal(State.Current_Wind, 0, "Precondition: Current_Wind should be 0");
      Tests.Assert(State.Hull_Integrity > 50, "Precondition: Hull_Integrity must be > 50");
      
      Ufo.Compensate_Wind(State, 150);
      
      Tests.Assert_Equal(State.Current_Wind, 150, "After Compensate_Wind(150), Current_Wind should be 150");
   end Test_Compensate_Wind;
   
   -- Test 4: Compensate_Wind with zero wind
   procedure Test_Compensate_Wind_Zero is
      State : Ufo.UAP_State := (False, 100, Ufo.Atmospheric_Cruise, 100);
   begin
      Ufo.Compensate_Wind(State, 0);
      Tests.Assert_Equal(State.Current_Wind, 0, "Compensate_Wind(0) should set Current_Wind to 0");
   end Test_Compensate_Wind_Zero;
   
   -- Test 5: Compensate_Wind with maximum wind
   procedure Test_Compensate_Wind_Max is
      State : Ufo.UAP_State := (False, 0, Ufo.Atmospheric_Cruise, 100);
   begin
      Ufo.Compensate_Wind(State, 5000);
      Tests.Assert_Equal(State.Current_Wind, 5000, "Compensate_Wind(5000) should work");
   end Test_Compensate_Wind_Max;
   
   -- Test 6: Compensate_Wind fails with low hull integrity (SPARK pre-condition)
   -- Note: This test verifies the pre-condition is enforced
   procedure Test_Compensate_Wind_Low_Hull is
      State : Ufo.UAP_State := (False, 0, Ufo.Atmospheric_Cruise, 40);
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
      State : Ufo.UAP_State;
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
      State : Ufo.UAP_State;
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
      State : Ufo.UAP_State := (False, 0, Ufo.Atmospheric_Cruise, 100);
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
   
   -- Test 10: Multiple operations in sequence
   procedure Test_Sequential_Operations is
      State : Ufo.UAP_State := (False, 0, Ufo.Atmospheric_Cruise, 100);
   begin
      -- Start with initial state
      Tests.Assert(State.Is_Rotating = False, "Initial Is_Rotating is False");
      Tests.Assert_Equal(State.Current_Wind, 0, "Initial Current_Wind is 0");
      
      -- Engage rotation
      Ufo.Engage_Rotation(State);
      Tests.Assert(State.Is_Rotating = True, "After rotation, Is_Rotating is True");
      
      -- Compensate wind
      Ufo.Compensate_Wind(State, 200);
      Tests.Assert_Equal(State.Current_Wind, 200, "After wind compensation, Current_Wind is 200");
      
      -- Change mode
      State.Mode := Ufo.Hover;
      Tests.Assert(State.Mode = Ufo.Hover, "Mode changed to Hover");
      
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
   end Test_Sequential_Operations;
   
   -- Test 11: Rotation doesn't affect other state
   procedure Test_Rotation_Isolation is
      State : Ufo.UAP_State := (False, 150, Ufo.Interstellar, 75);
   begin
      Tests.Assert_Equal(State.Current_Wind, 150, "Pre: Current_Wind is 150");
      Tests.Assert(State.Mode = Ufo.Interstellar, "Pre: Mode is Interstellar");
      Tests.Assert_Equal(State.Hull_Integrity, 75, "Pre: Hull_Integrity is 75");
      
      Ufo.Engage_Rotation(State);
      
      Tests.Assert(State.Is_Rotating = True, "Post: Is_Rotating is True");
      Tests.Assert_Equal(State.Current_Wind, 150, "Post: Current_Wind unchanged at 150");
      Tests.Assert(State.Mode = Ufo.Interstellar, "Post: Mode unchanged at Interstellar");
      Tests.Assert_Equal(State.Hull_Integrity, 75, "Post: Hull_Integrity unchanged at 75");
   end Test_Rotation_Isolation;
   
   -- Test 12: Wind compensation doesn't affect rotation or mode
   procedure Test_Wind_Compensation_Isolation is
      State : Ufo.UAP_State := (True, 0, Ufo.Hover, 100);
   begin
      Tests.Assert(State.Is_Rotating = True, "Pre: Is_Rotating is True");
      Tests.Assert(State.Mode = Ufo.Hover, "Pre: Mode is Hover");
      
      Ufo.Compensate_Wind(State, 300);
      
      Tests.Assert(State.Is_Rotating = True, "Post: Is_Rotating unchanged at True");
      Tests.Assert(State.Mode = Ufo.Hover, "Post: Mode unchanged at Hover");
      Tests.Assert_Equal(State.Current_Wind, 300, "Post: Current_Wind is 300");
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
   Tests.Register_Test("Sequential Operations", Test_Sequential_Operations'Access);
   Tests.Register_Test("Rotation Isolation", Test_Rotation_Isolation'Access);
   Tests.Register_Test("Wind Compensation Isolation", Test_Wind_Compensation_Isolation'Access);
   
   -- Run all tests
   Tests.Run_All_Tests;
end Test_Ufo_System;
