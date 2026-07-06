with Ada.Text_IO;
with Ada.Command_Line;
with Test_Ufo_System;

procedure Run_Tests is
   -- Simple test runner that executes all UFO System tests
   package IO renames Ada.Text_IO;
begin
   IO.Put_Line("========================================");
   IO.Put_Line("UFO System - Comprehensive Test Suite");
   IO.Put_Line("========================================");
   IO.New_Line;
   
   -- Run the main test procedure
   Test_Ufo_System;
   
   IO.New_Line;
   IO.Put_Line("========================================");
   IO.Put_Line("Test execution complete.");
   IO.Put_Line("========================================");
end Run_Tests;
