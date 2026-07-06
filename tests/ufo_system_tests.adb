with Ada.Text_IO;

package body Ufo_System_Tests is

   package IO renames Ada.Text_IO;
   
   -- Maximum number of test cases
   Max_Tests : constant Integer := 100;
   
   -- Test registry
   type Test_Entry is record
      Name : String(1..100);
      Name_Length : Integer;
      Case : Test_Case;
   end record;
   
   Test_Registry : array (1..Max_Tests) of Test_Entry;
   Test_Count : Integer := 0;
   
   -- Current test statistics
   Stats : Test_Statistics := (0, 0, 0, 0);
   
   -- Current test name (for error reporting)
   Current_Test_Name : String(1..100);
   Current_Test_Name_Length : Integer := 0;
   
   -- Last assertion result
   Last_Assertion_Passed : Boolean := True;
   
   procedure Register_Test (Name : String; Case : Test_Case) is
   begin
      if Test_Count < Max_Tests then
         Test_Count := Test_Count + 1;
         Test_Registry(Test_Count).Name_Length := Name'Length;
         Test_Registry(Test_Count).Name(1..Name'Length) := Name;
         Test_Registry(Test_Count).Case := Case;
      else
         IO.Put_Line("ERROR: Maximum number of tests exceeded!");
      end if;
   end Register_Test;
   
   procedure Run_All_Tests is
   begin
      Stats := (0, 0, 0, 0);
      
      IO.Put_Line("=== Running UFO System Tests ===");
      IO.New_Line;
      
      for I in 1..Test_Count loop
         Current_Test_Name_Length := Test_Registry(I).Name_Length;
         Current_Test_Name(1..Current_Test_Name_Length) := Test_Registry(I).Name(1..Current_Test_Name_Length);
         Stats.Total := Stats.Total + 1;
         
         IO.Put("Test " & Integer'Image(I) & ": " & 
                Test_Registry(I).Name(1..Test_Registry(I).Name_Length) & " ... ");
         
         begin
            Test_Registry(I).Case.all;
            
            if Last_Assertion_Passed then
               IO.Put_Line("PASS");
               Stats.Passed := Stats.Passed + 1;
            else
               IO.Put_Line("FAIL");
               Stats.Failed := Stats.Failed + 1;
            end if;
         exception
            when others =>
               IO.Put_Line("ERROR");
               Stats.Errors := Stats.Errors + 1;
         end;
         
         Last_Assertion_Passed := True;
      end loop;
      
      IO.New_Line;
      IO.Put_Line("=== Test Summary ===");
      IO.Put_Line("Total:  " & Integer'Image(Stats.Total));
      IO.Put_Line("Passed: " & Integer'Image(Stats.Passed));
      IO.Put_Line("Failed: " & Integer'Image(Stats.Failed));
      IO.Put_Line("Errors: " & Integer'Image(Stats.Errors));
      
      if Stats.Failed > 0 or Stats.Errors > 0 then
         IO.Put_Line("RESULT: FAILED");
      else
         IO.Put_Line("RESULT: ALL TESTS PASSED");
      end if;
   end Run_All_Tests;
   
   function Get_Statistics return Test_Statistics is
   begin
      return Stats;
   end Get_Statistics;
   
   procedure Assert (Condition : Boolean; Message : String) is
   begin
      if not Condition then
         Last_Assertion_Passed := False;
         IO.Put_Line("  ASSERTION FAILED: " & Message);
      end if;
   end Assert;
   
   procedure Assert_Equal (Left, Right : Integer; Message : String) is
   begin
      if Left /= Right then
         Last_Assertion_Passed := False;
         IO.Put_Line("  ASSERTION FAILED: " & Message);
         IO.Put_Line("    Expected: " & Integer'Image(Right) & ", Got: " & Integer'Image(Left));
      end if;
   end Assert_Equal;
   
   procedure Assert_Equal (Left, Right : Boolean; Message : String) is
   begin
      if Left /= Right then
         Last_Assertion_Passed := False;
         IO.Put_Line("  ASSERTION FAILED: " & Message);
         IO.Put_Line("    Expected: " & Boolean'Image(Right) & ", Got: " & Boolean'Image(Left));
      end if;
   end Assert_Equal;
   
   procedure Initialize_Tests is
   begin
      Test_Count := 0;
      Stats := (0, 0, 0, 0);
   end Initialize_Tests;

end Ufo_System_Tests;
