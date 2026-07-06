package Ufo_System with SPARK_Mode is

   -- Datentypen basierend auf den Beobachtungen der F/A-18 Piloten
   type Knots is range 0 .. 5000;
   type Degrees is range 0 .. 359;

   type Propulsion_Mode is (Hover, Interstellar, Atmospheric_Cruise);

   type UAP_State is record
      Is_Rotating     : Boolean;
      Current_Wind    : Knots;
      Mode            : Propulsion_Mode;
      Hull_Integrity  : Integer range 0 .. 100;
   end record;

   -- Prozedur, um die von den Piloten beobachtete "Gimbal"-Rotation zu aktivieren.
   -- Contract: Ändert nur den State und erzwingt, dass danach rotiert wird.
   procedure Engage_Rotation (State : in out UAP_State)
     with Depends => (State => State),
          Post    => State.Is_Rotating = True;

   -- Ausgleich von bis zu 120 Knoten Wind (und mehr).
   -- Contract: Das System darf nur gegen Wind ankämpfen, wenn die Hülle intakt ist (Pre).
   -- Danach entspricht unser interner Vektor dem Gegenwind (Post).
   procedure Compensate_Wind (State : in out UAP_State; Wind_Speed : Knots)
     with Depends => (State => (State, Wind_Speed)),
          Pre     => State.Hull_Integrity > 50,
          Post    => State.Current_Wind = Wind_Speed;

end Ufo_System;
