package Ufo_System with SPARK_Mode is

   -- Data types based on observations from F/A-18 pilots
   -- Using SI units where possible for scientific accuracy
   
   -- Speed types
   type Knots is range 0 .. 5000;  -- Nautical speed (for compatibility)
   
   -- Maximum speed: 99.9% of light speed (299,493,155 m/s)
   -- Nothing with mass can reach or exceed light speed (299,792,458 m/s)
   -- Define the constant first so it can be used in the type range
   Speed_Of_Light_Const : constant := 299_792_458;
   Max_Achievable_Speed_Const : constant := 299_493_155;  -- 99.9% of light speed
   
   type Meters_Per_Second is range 0 .. Max_Achievable_Speed_Const;
   
   -- Distance/altitude types (using metric)
   type Degrees is range 0 .. 359;
   type Kilometers is range 0 .. 1_000_000_000;  -- Distance in kilometers
   
   -- Temperature with human-safe range
   type Temperature_Celsius is range -100 .. 2000;  -- Temperature range
   
   -- Human comfort temperature range (18-25 C)
   Human_Min_Temp : constant Temperature_Celsius := 18;
   Human_Max_Temp : constant Temperature_Celsius := 25;
   Human_Critical_Temp : constant Temperature_Celsius := 30;  -- Above this, immediate action needed
   
   -- Speed of light in m/s (299,792,458 m/s) - theoretical limit
   Speed_Of_Light : constant Meters_Per_Second := Meters_Per_Second(Speed_Of_Light_Const);
   
   -- Maximum achievable speed: 99.9% of light speed
   -- This is the practical limit for any craft with mass
   Max_Achievable_Speed : constant Meters_Per_Second := Meters_Per_Second(Max_Achievable_Speed_Const);
   
   -- Escape velocities in m/s for different celestial bodies
   Earth_Escape_Velocity : constant Meters_Per_Second := 11_186;  -- 11.2 km/s
   Moon_Escape_Velocity : constant Meters_Per_Second := 2_375;   -- 2.375 km/s
   Mars_Escape_Velocity : constant Meters_Per_Second := 5_027;   -- 5.027 km/s
   
   -- Minimum safe altitude for deep space operations (16,000 km from Earth)
   Deep_Space_Min_Altitude : constant Kilometers := 16_000;
   
   -- Low Earth Orbit altitude range (160-2000 km)
   LEO_Min_Altitude : constant Kilometers := 160;
   LEO_Max_Altitude : constant Kilometers := 2_000;
   
   -- Atmospheric boundary (Karman line: 100 km)
   Atmosphere_Boundary : constant Kilometers := 100;
   
   type Propulsion_Mode is (Hover, Interstellar, Atmospheric_Cruise);

   -- Environment types for celestial body proximity
   type Celestial_Body_Type is (Earth, Moon, Mars, Deep_Space, Other);
   
   -- Obstacle detection state
   type Obstacle_State is (No_Obstacle, Obstacle_Detected);
   
   type Environment_State is record
      Relative_Distance : Kilometers;  -- Distance to nearest celestial body in km
      Body_Type : Celestial_Body_Type;
      Atmospheric_Pressure : Float;  -- in hPa (hectopascals)
      Has_Obstacle : Obstacle_State;  -- Whether an obstacle is detected ahead
      Obstacle_Distance : Kilometers;  -- Distance to obstacle (0 if none)
   end record;

   type UAP_State is record
      Is_Rotating     : Boolean;
      Current_Wind    : Knots;
      Mode            : Propulsion_Mode;
      Hull_Integrity  : Integer range 0 .. 100;
      Current_Speed   : Meters_Per_Second;  -- Current speed in m/s (SI unit)
      Current_Altitude : Kilometers;  -- Current altitude in km (SI unit)
      Current_Heading : Degrees;  -- Current direction
      Core_Temperature : Temperature_Celsius;  -- Core system temperature
      Environment     : Environment_State;  -- Current environment
      Target_Speed    : Meters_Per_Second;  -- Target speed for current mode
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

   -- Set the speed of the craft manually or via board computer (in m/s)
   -- Speed is limited to Max_Achievable_Speed (99.9% of light speed)
   procedure Set_Speed (State : in out UAP_State; Speed : Meters_Per_Second)
     with Depends => (State => (State, Speed)),
          Post    => State.Current_Speed = Speed;

   -- Set the altitude of the craft manually or via board computer (in km)
   procedure Set_Altitude (State : in out UAP_State; Altitude : Kilometers)
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

   -- Set obstacle detection state
   procedure Set_Obstacle (State : in out UAP_State; Has_Obstacle : Obstacle_State; Distance : Kilometers)
     with Depends => (State => (State, Has_Obstacle, Distance)),
          Post    => State.Environment.Has_Obstacle = Has_Obstacle and State.Environment.Obstacle_Distance = Distance;

   -- Temperature regulation: maintain human comfort range (18-25C)
   -- If temperature is below 18C or above 25C, activate climate control
   -- If temperature exceeds 30C (critical), initiate emergency cooling
   procedure Regulate_Temperature (State : in out UAP_State)
     with Depends => (State => State);

   -- Emergency routine: Overheating detected - activate emergency cooling systems
   -- Pre: Temperature must be above critical threshold (30C)
   -- Post: Temperature is reduced toward safe range
   procedure Emergency_Cooling (State : in out UAP_State)
     with Depends => (State => State),
          Pre     => State.Core_Temperature > Human_Critical_Temp;

   -- Calculate target speed based on current mode and environment
   -- In atmosphere: target is escape velocity (can go lower but this is the goal)
   -- In LEO: maintain orbital velocity
   -- In deep space with no obstacles: target is near light speed (Max_Achievable_Speed)
   -- In deep space with obstacles: target is safe evasion speed
   procedure Calculate_Target_Speed (State : in out UAP_State)
     with Depends => (State => State);

   -- Emergency routine: Adjust speed and altitude for current propulsion mode
   -- This ensures the craft operates within safe parameters for its mode
   -- In deep space: maintains speed toward Max_Achievable_Speed, maintains safe altitude
   -- With obstacles: reduces speed for evasion
   -- Pre: Environment must be valid (distance >= 0)
   procedure Adjust_To_Environment (State : in out UAP_State)
     with Depends => (State => State),
          Pre     => State.Environment.Relative_Distance >= 0;

end Ufo_System;
