-- Test suite specification for UFO System
-- This file contains the test framework and test case declarations

package Ufo_System_Tests is

   -- Test result type
   type Test_Result is (Pass, Fail, Error);
   
   -- Test case type - a procedure that takes no parameters and returns a Test_Result
   type Test_Case is access procedure;
   
   -- Test statistics
   type Test_Statistics is record
      Total  : Integer := 0;
      Passed : Integer := 0;
      Failed : Integer := 0;
      Errors : Integer := 0;
   end record;
   
   -- Register a test case
   procedure Register_Test (Name : String; Case : Test_Case);
   
   -- Run all registered tests
   procedure Run_All_Tests;
   
   -- Get test statistics
   function Get_Statistics return Test_Statistics;
   
   -- Assertion procedures
   procedure Assert (Condition : Boolean; Message : String);
   procedure Assert_Equal (Left, Right : Integer; Message : String);
   procedure Assert_Equal (Left, Right : Boolean; Message : String);
   
   -- Test initialization
   procedure Initialize_Tests;

end Ufo_System_Tests;
