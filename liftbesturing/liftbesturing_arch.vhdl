library ieee;
use ieee.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use ieee.STD_LOGIC_UNSIGNED.all;

entity elevator_control is
  port(
    clock, nRESET : in std_logic; -- reset = low active
    elevator_called_to_level0, elevator_called_to_level1,elevator_called_to_level2 : in std_logic; --activated on the different levels and inside the cage
    elevator_arrived_on_level0, elevator_arrived_on_level1, elevator_arrived_on_level2  : in std_logic; --comes from the elevatorshaft
    cage_safe : in std_logic; --tels control lift is secure and ready to move.
    control_door_open_req, control_door_closed_req: in std_logic;
    control_lftdr :out std_logic := '1'; -- control signal to open the door
    control_motor_up, control_motor_down, control_motor_emercency:out std_logic;
    light0, light1,light2: out std_logic; --controls the ligths that signal
                                      --wich levels are called.
    control_door_state_open: in std_logic; --door open(1) or closed(0) state
    control_door_obstructed:in std_logic;
    emercency: in std_logic
    );
end elevator_control;
 
architecture liftcontrol of elevator_control is
    constant MAX_STATES :integer := 4;
    --motor states
    constant NO_MOVEMENT: integer := 0;
    constant UP : integer := 1;
    constant DOWN : integer  :=2;
    constant LEAVE_LEVEL: integer := 3; --start leave procedure
    constant ARRIVE_LEVEL: integer := 4; --arrive on level procedure
    constant RESET : integer := 5;
    constant EMERGENCY :integer := 6;
    -- --elevator states
    -- constant cage_on_level: integer :=0;
    -- constant cage_on level_below: integer := 1;
    -- constant cage_on_level_above: integer := 2;
    constant delay_reset: integer := 10; -- number is clokcycles for countdowns
    constant delay_reset_leave_level: integer := 2;

    signal elevator_current_state, elevator_next_state, elevator_previous_state, elevator_last_movement : integer := RESET; --could be interesting to put one off them in the port list for debug reasons
    signal door_open_req, door_closed_req: std_logic := '0'; --internal door controls, used between processes
    signal delay_close_door: integer:= delay_reset;
    signal delay_leave_level: integer:= delay_reset_leave_level;

    begin
        main: process (clock, elevator_current_state, nRESET,elevator_arrived_on_level0, elevator_arrived_on_level1, elevator_arrived_on_level2)  --elevator_called_to_level0, elevator_called_to_level1,elevator_called_to_level2, cage_safe, elevator_arrived_on_level0, elevator_arrived_on_level1, elevator_arrived_on_level2)
        begin 
            if nRESET = '0' then
                elevator_next_state <= RESET;
            end if;
     
            case elevator_current_state is
                when EMERGENCY =>
                    if nRESET = '0' then
                        elevator_next_state <= RESET;
                    else 
                        elevator_next_state <= EMERGENCY;
                    end if;
                    control_motor_up <= '0';
                    control_motor_down <= '0';
                    control_motor_emercency <= '0';
                    --no next elevator state because controller stays in emergency until reset is pressed


                when LEAVE_LEVEL => 
                    --delay closing of the door to 5 clockcycles
                    if rising_edge(clock) and cage_safe = '1' then
                        delay_leave_level <= delay_leave_level -1;
                    end if;
                    if delay_leave_level = 0 then
                        door_open_req <= '0';
                        door_closed_req <= '1'; --ask to close the door
                        delay_leave_level <= delay_reset_leave_level;
                    end if;
                    
                    if cage_safe = '0' then --cage is in save state (closed door etc.)
                        door_closed_req <= '0';
                        --choose up or down depending on active level request signal
                        if elevator_arrived_on_Level0 = '1' then
                            if elevator_called_to_level1 = '1' or elevator_called_to_level2 = '1' then
                                elevator_next_state <= UP;
                            end if;
                            if elevator_called_to_level0 = '1' then --when called to a level the cage already is on: open the door
                                elevator_next_state <= ARRIVE_LEVEL;
                            end if;
                        end if;
                       
                        if elevator_arrived_on_Level1 = '1' then
                            if elevator_called_to_level1 = '1' then --when called to a level the cage already is on: open the door
                            elevator_next_state <= ARRIVE_LEVEL;
                            end if;
                            if elevator_called_to_level2 = '1' then
                                elevator_next_state <= UP;
                            end if;
                            if elevator_called_to_Level0 = '1' then
                                    elevator_next_state <= DOWN;
                            end if;
                            if elevator_called_to_level2 = '1' and elevator_called_to_Level0 = '1' then
                                if elevator_last_movement = UP then --make sure to follow earlier movement when there are multiple requests
                                    elevator_next_state <= UP;
                                end if;
                                if elevator_last_movement = DOWN then
                                    elevator_next_state <= DOWN;
                                end if; 
                            end if;

                        end if;
                        if elevator_arrived_on_Level2 = '1' then
                            if elevator_called_to_level2 = '1' then --when called to a level the cage already is on: open the door
                                elevator_next_state <= ARRIVE_LEVEL;
                            end if;
                            if elevator_called_to_level1 = '1' or elevator_called_to_level0 = '1' then
                                elevator_next_state <= DOWN;
                            end if;
                        end if;
                    end if;
                when DOWN =>
                    --lock doors
                    --set motor down
                    --wait until cage arrives
                    if cage_safe ='0' then --if it is safe to start the motor
                        control_motor_down <= '1';
                        elevator_last_movement <= DOWN;
                    end if;
                    if (elevator_arrived_on_level0  = '1' and elevator_called_to_level0 =  '1') or (elevator_arrived_on_level1 = '1' and elevator_called_to_level1 = '1' ) then
                        control_motor_down <= '0';
                        elevator_next_state <= ARRIVE_LEVEL;
                    end if; 
                when UP =>
                    --lock doors
                    --set motor up
                    --wait until cage arrives
                    if cage_safe ='0' then --if it is safe to start the motor
                        control_motor_up <= '1';
                        elevator_last_movement <= UP;
                    end if;
                    if (elevator_arrived_on_level1  = '1' and elevator_called_to_level1 =  '1') or (elevator_arrived_on_level2 = '1' and elevator_called_to_level2 = '1' ) then
                        control_motor_up <= '0';
                        elevator_next_state <= ARRIVE_LEVEL;
                    end if; 
                when ARRIVE_LEVEL =>
                    -- arrive on level procedure
                    if cage_safe = '0' then
                        door_open_req <= '1';
                        elevator_next_state <= NO_MOVEMENT;
                    end if;
                when NO_MOVEMENT =>
                    --wait on orders / do nothing
                    if elevator_called_to_level0 ='1' or elevator_called_to_level1 = '1' or elevator_called_to_level2 ='1' then
                        elevator_next_state <= LEAVE_LEVEL;
                        delay_close_door <= delay_reset;
                    end if;
                    --after timeout close door
                    if rising_edge(clock) then
                        if control_door_state_open = '1' then
                            door_open_req <= '0';
                            delay_close_door <= delay_close_door -1;
                        end if; 
                    
                        if delay_close_door = 0 then
                            door_closed_req <= '1';
                            delay_close_door <= delay_reset;
                        end if;
                        if cage_safe = '0' then 
                            door_closed_req <= '0';
                            delay_close_door <= delay_reset;
                        end if;
                    end if;
                    --after timeout close door

                when RESET =>
                    if control_door_state_open = '1' then --cage door is open
                        door_closed_req <= '1';
                        door_open_req <= '0';
                    end if;
                    if control_door_state_open = '0' then --ignore safe state because cage is unsafe when not on any level
                        door_closed_req <= '0';
                        control_motor_up <= '0';
                        control_motor_down <= '1';
                        control_motor_emercency <= '1';
                    end if;
                    if elevator_arrived_on_level0 ='1' then
                        control_motor_down <= '0';
                        elevator_next_state <= ARRIVE_LEVEL;
                    end if;                    
                when OTHERs => 
                    --set everything to error state
                    elevator_next_state <= RESET;
            end case;
        end process;

        --todo: make some kind of delay 
        door: process (clock)--, control_door_open_req, control_door_closed_req, door_open_req, door_closed_req)
        begin
        if rising_edge(clock) then
            if cage_safe = '0' and (control_door_open_req = '1' or door_open_req = '1') then --see if it save to close the door
                control_lftdr <= '1'; --open door
            end if;
            if (control_door_closed_req = '1' or door_closed_req = '1') and control_door_obstructed = '0' then
                control_lftdr <= '0'; --close door
            end if;
        end if;
        end process;
        
        lights: process (elevator_called_to_level0, elevator_called_to_level1,elevator_called_to_level2)
        begin
            light0 <= elevator_called_to_level0;
            light1 <= elevator_called_to_level1;
            light2 <= elevator_called_to_level2;
        end process;

        --changes states on clock signal 
        state: process( clock, elevator_next_state, emercency)
        begin
            if falling_edge(emercency) then --emercency button is pressed
                elevator_current_state <= EMERGENCY;
            end if;
            if RISING_EDGE(clock) then
                if elevator_current_state /= elevator_next_state then
                    elevator_previous_state <= elevator_current_state;
                    elevator_current_state <= elevator_next_state;
                end if;
            end if;
        end process;

end architecture;

-- library ieee;
-- use ieee.STD_LOGIC_1164.all;
-- use ieee.numeric_std.all;
-- use ieee.STD_LOGIC_UNSIGNED.all;

-- entity test_tb is
--     end entity;

-- architecture bla_tb of test_tb is 
-- component elevator_control 
--    port(
--     clock, nRESET : in std_logic; -- reset = low active
--     elevator_called_to_level0, elevator_called_to_level1,elevator_called_to_level2 : in std_logic; --activated on the different levels and inside the cage
--     elevator_arrived_on_level0, elevator_arrived_on_level1, elevator_arrived_on_level2  : in std_logic; --comes from the elevatorshaft
--     cage_safe : in std_logic; --tels control lift is secure and ready to move.
--     control_door_open_req, control_door_closed_req: in std_logic;
--     control_lftdr :out std_logic; -- control signal to open the door
--     control_motor_up, control_motor_down, control_motor_emercency:out std_logic;
--     --light0, light1,ligth2: out std_logic; --controls the ligths that signal
--                                       --wich levels are called.
--     control_door_state_open: in std_logic; --door open(1) or closed(0) state
--     control_door_obstructed:in std_logic
--     );
-- end component;

-- for controller: elevator_control use entity work.elevator_control;

-- signal clock, nRESET: std_logic; -- reset = low active
-- signal elevator_called_to_level0, elevator_called_to_level1,elevator_called_to_level2 : std_logic; --activated on the different levels and inside the cage
-- signal elevator_arrived_on_level0, elevator_arrived_on_level1, elevator_arrived_on_level2  : std_logic; --comes from the elevatorshaft
-- signal cage_safe : std_logic; --tels control lift is secure and ready to move.
-- signal control_door_open_req, control_door_closed_req: std_logic;
-- signal control_lftdr: std_logic; -- control signal to open the door
-- signal control_motor_up, control_motor_down, control_motor_emercency: std_logic;
-- --light0, light1,ligth2: out std_logic; --controls the ligths that signal
--                                   --wich levels are called.
-- signal control_door_state_open: std_logic; --door open(1) or closed(0) state
-- signal control_door_obstructed: std_logic;

-- begin 

-- controller: elevator_control port map(
--     clock => clock, nRESET => nRESET, elevator_called_to_level0 => elevator_called_to_level0, elevator_called_to_level1 => elevator_called_to_level1 ,elevator_called_to_level2 => elevator_called_to_level2,
--     elevator_arrived_on_level0 => elevator_arrived_on_level0, elevator_arrived_on_level1 => elevator_arrived_on_level1, elevator_arrived_on_level2 => elevator_arrived_on_level2,
--     cage_safe => cage_safe, control_door_open_req => control_door_open_req , control_door_closed_req => control_door_closed_req, control_lftdr => control_lftdr,
--     control_motor_up => control_motor_up, control_motor_down => control_motor_down, control_motor_emercency => control_motor_emercency,
--     control_door_state_open => control_door_state_open, control_door_obstructed => control_door_obstructed
--     );

-- clk: process
-- begin
--     clock <= '1';
--     wait for 5 ns ;
--     clock <= '0';
--     wait for 5 ns;
-- end process;

-- end architecture;