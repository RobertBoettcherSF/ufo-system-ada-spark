package body Ufo_System with SPARK_Mode is

   procedure Engage_Rotation (State : in out UAP_State) is
   begin
      State.Is_Rotating := True;
      -- Hier würde später der Aufruf an die Antigravitations-API folgen
   end Engage_Rotation;

   procedure Compensate_Wind (State : in out UAP_State; Wind_Speed : Knots) is
   begin
      State.Current_Wind := Wind_Speed;
      -- Hier berechnet der Algorithmus den Vektor, um die Position exakt zu halten
   end Compensate_Wind;

end Ufo_System;
