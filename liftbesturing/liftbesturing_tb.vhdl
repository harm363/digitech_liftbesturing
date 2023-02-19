library ieee;
use ieee.STD_LOGIC_1164.all;
use ieee.numeric_bit.all;
use ieee.STD_LOGIC_UNSIGNED.all;

entity liftbesturing_tb is 
end liftbesturing_tb;

architecture test of liftbesturing_tb is
    component elevator_control
        port ( 
            clock, nRESET : in std_logic; -- reset = low active
            elevator_called_to_level0, elevator_called_to_level1,elevator_called_to_level2 : in std_logic; --activated on the different levels and inside the cage
            elevator_arrived_on_level0, elevator_arrived_on_level1, elevator_arrived_on_level2  : in std_logic; --comes from the elevatorshaft
            cage_safe : in std_logic; --tels control lift is secure and ready to move.
            control_door_open_req, control_door_closed_req: in std_logic;
            control_lftdr :out std_logic; -- control signal to open the door
            control_motor_up, control_motor_down, control_motor_emercency:out std_logic;
            light0, light1,ligth2: out std_logic; --controls the ligths that signal
                                              --wich levels are called.
            control_door_state_open: in std_logic; --door open(1) or closed(0) state
            control_door_obstructed:in std_logical
                                              --wich levels are called.
        );
        end component;
        for control_test: elevator_control use entity work.elevator_control;
begin
    --control_test: elevator_control port map(lock=> lock);
    main: process
        begin
        report "end of test" severity failure;
        end process;        

    clk: process
    begin
        clock <= '1';
        wait for 10 ns;
        clock <= '0';
        wait for 10 ns;
        end process;

end architecture;