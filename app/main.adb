with Ada.Text_IO;
with Ada.Command_Line;
with Ufo_System;

procedure Main is
   -- Terminal application to demonstrate UFO System functionality
   
   package IO renames Ada.Text_IO;
   
   State : Ufo_System.UAP_State;
   
   procedure Print_State (S : Ufo_System.UAP_State) is
   begin
      IO.Put_Line("=== Current UFO State ===");
      IO.Put_Line("Is Rotating:    " & Boolean'Image(S.Is_Rotating));
      IO.Put_Line("Current Wind:   " & Ufo_System.Knots'Image(S.Current_Wind) & " knots");
      IO.Put_Line("Propulsion:     " & Ufo_System.Propulsion_Mode'Image(S.Mode));
      IO.Put_Line("Hull Integrity: " & Integer'Image(S.Hull_Integrity) & "%");
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
   begin
      IO.Put_Line("=== UFO System Demonstration ===");
      IO.New_Line;
      
      -- Initialize state
      State := (
         Is_Rotating    => False,
         Current_Wind   => 0,
         Mode           => Ufo_System.Atmospheric_Cruise,
         Hull_Integrity => 100
      );
      
      IO.Put_Line("Initial state:");
      Print_State(State);
      
      -- Engage rotation
      IO.Put_Line("Engaging rotation...");
      Ufo_System.Engage_Rotation(State);
      Print_State(State);
      
      -- Change propulsion mode
      IO.Put_Line("Switching to Hover mode...");
      State.Mode := Ufo_System.Hover;
      Print_State(State);
      
      -- Compensate wind
      IO.Put_Line("Compensating for 100 knots wind...");
      Ufo_System.Compensate_Wind(State, 100);
      Print_State(State);
      
      -- Switch to interstellar
      IO.Put_Line("Switching to Interstellar mode...");
      State.Mode := Ufo_System.Interstellar;
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
      
      IO.Put_Line("=== Demonstration Complete ===");
   end Run_Demo;
   
   procedure Run_Interactive is
      Input : String(1..100);
      Last  : Integer;
   begin
      IO.Put_Line("=== UFO System Interactive Mode ===");
      IO.Put_Line("Commands: state, rotate, wind <knots>, mode <hover|interstellar|cruise>, " & 
                  "damage <percent>, repair <percent>, help, quit");
      IO.New_Line;
      
      -- Initialize state
      State := (
         Is_Rotating    => False,
         Current_Wind   => 0,
         Mode           => Ufo_System.Atmospheric_Cruise,
         Hull_Integrity => 100
      );
      
      loop
         IO.Put("> ");
         Ada.Text_IO.Get_Line(Input, Last);
         
         declare
            Command : String := Input(1..Last);
            Tokens  : constant Integer := Count_Tokens(Command);
         begin
            if Tokens = 0 then
               null;
            elsif Token(Command, 1) = "quit" or Token(Command, 1) = "exit" then
               IO.Put_Line("Exiting...");
               exit;
            elsif Token(Command, 1) = "help" then
               IO.Put_Line("Available commands:");
               IO.Put_Line("  state              - Show current state");
               IO.Put_Line("  rotate             - Engage rotation");
               IO.Put_Line("  wind <knots>       - Compensate for wind");
               IO.Put_Line("  mode <m>           - Set propulsion mode (hover, interstellar, cruise)");
               IO.Put_Line("  damage <percent>   - Damage hull by percentage");
               IO.Put_Line("  repair <percent>   - Repair hull by percentage");
               IO.Put_Line("  help               - Show this help");
               IO.Put_Line("  quit               - Exit");
            elsif Token(Command, 1) = "state" then
               Print_State(State);
            elsif Token(Command, 1) = "rotate" then
               Ufo_System.Engage_Rotation(State);
               IO.Put_Line("Rotation engaged!");
            elsif Token(Command, 1) = "wind" and Tokens >= 2 then
               declare
                  Wind_Speed : Integer;
               begin
                  Wind_Speed := Integer'Value(Token(Command, 2));
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
            elsif Token(Command, 1) = "mode" and Tokens >= 2 then
               declare
                  Mode_Str : String := To_Lower(Token(Command, 2));
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
            elsif Token(Command, 1) = "damage" and Tokens >= 2 then
               declare
                  Damage : Integer;
               begin
                  Damage := Integer'Value(Token(Command, 2));
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
            elsif Token(Command, 1) = "repair" and Tokens >= 2 then
               declare
                  Repair : Integer;
               begin
                  Repair := Integer'Value(Token(Command, 2));
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
         Arg : String := Ada.Command_Line.Argument(1);
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
