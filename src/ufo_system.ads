package Ufo_System with SPARK_Mode is

   -- Data types based on observations from F/A-18 pilots
   type Knots is range 0 .. 5000;
   type Degrees is range 0 .. 359;
   type Feet is range 0 .. 500_000;  -- Altitude in feet
   type Meters is range 0 .. 1_000_000;  -- Distance in meters
   type Temperature_Celsius is range -100 .. 2000;  -- Temperature range

   type Propulsion_Mode is (Hover, Interstellar, Atmospheric_Cruise);

   -- Environment types for celestial body proximity
   type Celestial_Body_Type is (Earth, Moon, Mars, Deep_Space, Other);
   
   type Environment_State is record
      Relative_Distance : Meters;  -- Distance to nearest celestial body
      Body_Type : Celestial_Body_Type;
      Atmospheric_Pressure : Float;  -- in hPa
   end record;

   type UAP_State is record
      Is_Rotating     : Boolean;
      Current_Wind    : Knots;
      Mode            : Propulsion_Mode;
      Hull_Integrity  : Integer range 0 .. 100;
      Current_Speed   : Knots;  -- Current speed of the craft
      Current_Altitude : Feet;  -- Current altitude
      Current_Heading : Degrees;  -- Current direction
      Core_Temperature : Temperature_Celsius;  -- Core system temperature
      Environment     : Environment_State;  -- Current environment
   end record;

   -- Procedure to engage the "Gimbal" rotation observed by pilots.
   -- Contract: Only modifies state and enforces that rotation is engaged afterward.
   procedure Engage_Rotation (State : in out UAP_State)
     with Depends => (State => State),
          Post    => State.Is_Rotating = True;

   -- Compensate for up to 120 knots wind (and more).
   -- Contract: The system can only compensate for wind when hull integrity is sufficient (Pre).
   -- Afterward, our internal vector matches the headwind (Post).
   procedure Compensate_Wind (State : in out UAP_State; Wind_Speed : Knots)
     with Depends => (State => (State, Wind_Speed)),
          Pre     => State.Hull_Integrity > 50,
          Post    => State.Current_Wind = Wind_Speed;

   -- Set the speed of the craft manually or via board computer
   procedure Set_Speed (State : in out UAP_State; Speed : Knots)
     with Depends => (State => (State, Speed)),
          Post    => State.Current_Speed = Speed;

   -- Set the altitude of the craft manually or via board computer
   procedure Set_Altitude (State : in out UAP_State; Altitude : Feet)
     with Depends => (State => (State, Altitude)),
          Post    => State.Current_Altitude = Altitude;

   -- Set the heading/direction of the craft manually or via board computer
   procedure Set_Heading (State : in out UAP_State; Heading : Degrees)
     with Depends => (State => (State, Heading)),
          Post    => State.Current_Heading = Heading;

   -- Set the environment state (distance to celestial body, body type, pressure)
   procedure Set_Environment (State : in out UAP_State; Env : Environment_State)
     with Depends => (State => (State, Env)),
          Post    => State.Environment = Env;

   -- Set core temperature (can be set manually or by board computer)
   procedure Set_Temperature (State : in out UAP_State; Temp : Temperature_Celsius)
     with Depends => (State => (State, Temp)),
          Post    => State.Core_Temperature = Temp;

   -- Emergency routine: Overheating detected - drop into the sea to cool down
   -- Pre: Temperature must be above critical threshold
   -- Post: Altitude is set to sea level (0 feet) if near a body with atmosphere
   procedure Emergency_Cooling (State : in out UAP_State)
     with Depends => (State => State),
          Pre     => State.Core_Temperature > 150,
          Post    => State.Current_Altitude = 0;

   -- Emergency routine: Adjust speed and altitude for current propulsion mode
   -- This ensures the craft operates within safe parameters for its mode
   -- Pre: Environment must be valid (distance > 0 or in deep space)
   procedure Adjust_To_Environment (State : in out UAP_State)
     with Depends => (State => State),
          Pre     => State.Environment.Relative_Distance >= 0;

end Ufo_System;
