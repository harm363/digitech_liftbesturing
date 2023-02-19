library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity elevator_cage is 
port(
    clock, nRESET : in std_logic; --nRESET
    BUTTON_FLOOR_0, BUTTON_FLOOR_1, BUTTON_FLOOR_2: in std_logic; --floor choise buttons for users
    ELEVATOR_ON_FLOOR_0, ELEVATOR_ON_FLOOR_1, ELEVATOR_ON_FLOOR_2: in std_logic; --on wich floor is the cage
    DOOR_OBSTRUCTED, BUTTON_DOOR_CLOSE, BUTTON_DOOR_OPEN: in std_logic; -- door input signals
    DOOR_STATE_OPEN: in std_logic; --door open(1) or closed(0) state
    FLOOR_REQ_0, FLOOR_REQ_1,FLOOR_REQ_2: out std_logic := '0'; --the floor the cage requests the controller to be taken to
    DOOR_REQ_OPEN, DOOR_REQ_CLOSED: out std_logic := '0'; --request door to be opened or closed to the controller
    nELEVATOR_READY: out std_logic := '1' --determines if cage is safe to start moving or 
);
end entity elevator_cage;

architecture cage of elevator_cage is
    signal FLOOR_REQ_HELPER_1_1, FLOOR_REQ_HELPER_1_2: std_logic := '0';
    signal reset_call0, reset_call1, reset_call2: std_logic := '1';

    component SR_FLIPFLOP is 
    port( S, R, clock : in std_logic;
        Q, nQ :out std_logic);
    end component;

    for call0: SR_FLIPFLOP use entity work.SR_FLIPFLOP;
    for call1: SR_FLIPFLOP use entity work.SR_FLIPFLOP;
    for call2: SR_FLIPFLOP use entity work.SR_FLIPFLOP;

    begin
        call0: SR_FLIPFLOP port map (S=> BUTTON_FLOOR_0, R => reset_call0, Q=> FLOOR_REQ_0, clock => clock);
        call1: SR_FLIPFLOP port map (S=> BUTTON_FLOOR_1, R => reset_call1, Q=> FLOOR_REQ_1, clock => clock);
        call2: SR_FLIPFLOP port map (S=> BUTTON_FLOOR_2, R => reset_call2, Q=> FLOOR_REQ_2, clock => clock);

        --reset_call0 <= ELEVATOR_ON_FLOOR_0 or not nRESET;
        --reset_call1 <= ELEVATOR_ON_FLOOR_1 or not nRESET;
        --reset_call2 <= ELEVATOR_ON_FLOOR_2 or not nRESET;

        main: process(clock, nRESET)
        begin
            if RISING_EDGE(clock) then
            --DOOR REQ SIGNALS
                nELEVATOR_READY <= DOOR_OBSTRUCTED or DOOR_STATE_OPEN or not (ELEVATOR_ON_FLOOR_0 xor ELEVATOR_ON_FLOOR_1 xor ELEVATOR_ON_FLOOR_2); 
                DOOR_REQ_OPEN <= not DOOR_OBSTRUCTED and BUTTON_DOOR_OPEN and (ELEVATOR_ON_FLOOR_0 xor ELEVATOR_ON_FLOOR_1 xor ELEVATOR_ON_FLOOR_2);
                DOOR_REQ_CLOSED <= not DOOR_OBSTRUCTED and BUTTON_DOOR_CLOSE and (ELEVATOR_ON_FLOOR_0 xor ELEVATOR_ON_FLOOR_1 xor ELEVATOR_ON_FLOOR_2);
            end if;
            reset_call0 <= ELEVATOR_ON_FLOOR_0 or not nRESET;
            reset_call1 <= ELEVATOR_ON_FLOOR_1 or not nRESET;
            reset_call2 <= ELEVATOR_ON_FLOOR_2 or not nRESET;
        end process;
end architecture; -- elevator_cage



library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
entity cage_tb is
end cage_tb ;

architecture  test of cage_tb is
    component elevator_cage
    port(
        clock, nRESET : in std_logic; --nRESET
        BUTTON_FLOOR_0, BUTTON_FLOOR_1, BUTTON_FLOOR_2: in std_logic; --floor choise buttons for users
        ELEVATOR_ON_FLOOR_0, ELEVATOR_ON_FLOOR_1, ELEVATOR_ON_FLOOR_2: in std_logic; --on wich floor is the cage
        DOOR_OBSTRUCTED, BUTTON_DOOR_CLOSE, BUTTON_DOOR_OPEN: in std_logic; -- door input signals
        DOOR_STATE_OPEN: in std_logic; --door open(1) or closed(0) state
        FLOOR_REQ_0, FLOOR_REQ_1,FLOOR_REQ_2: out std_logic; --the floor the cage requests the controller to be taken to
        DOOR_REQ_OPEN, DOOR_REQ_CLOSED: out std_logic; --request door to be opened or closed to the controller
        nELEVATOR_READY: out std_logic
    );
    end component;
    for cage_test: elevator_cage use entity work.elevator_cage;

    signal clock, nRESET : std_logic; -- reset = low active
    signal BUTTON_FLOOR_0, BUTTON_FLOOR_1, BUTTON_FLOOR_2: std_logic; --floor choise buttons for users
    signal ELEVATOR_ON_FLOOR_0, ELEVATOR_ON_FLOOR_1, ELEVATOR_ON_FLOOR_2: std_logic; --on wich floor is the cage
    signal DOOR_OBSTRUCTED, BUTTON_DOOR_CLOSE, BUTTON_DOOR_OPEN: std_logic; -- door input signals
    signal DOOR_STATE_OPEN: std_logic; --door open(1) or closed(0) state
    signal FLOOR_REQ_0, FLOOR_REQ_1,FLOOR_REQ_2: std_logic; --the floor the cage requests the controller to be taken to
    signal DOOR_REQ_OPEN, DOOR_REQ_CLOSED: std_logic; --request door to be opened or closed to the controller
    signal nELEVATOR_READY: std_logic;

begin 
    cage_test: elevator_cage port map (clock => clock, nRESET=>nRESET, 
    ELEVATOR_ON_FLOOR_0 => ELEVATOR_ON_FLOOR_0, ELEVATOR_ON_FLOOR_1=> ELEVATOR_ON_FLOOR_1, ELEVATOR_ON_FLOOR_2 => ELEVATOR_ON_FLOOR_2, 
    BUTTON_FLOOR_0=> BUTTON_FLOOR_0, BUTTON_FLOOR_1=>BUTTON_FLOOR_1, BUTTON_FLOOR_2=>BUTTON_FLOOR_2,
    FLOOR_REQ_0=>FLOOR_REQ_0, FLOOR_REQ_1=>FLOOR_REQ_1,FLOOR_REQ_2=>FLOOR_REQ_2,
    DOOR_OBSTRUCTED => DOOR_OBSTRUCTED, BUTTON_DOOR_OPEN => BUTTON_DOOR_OPEN, BUTTON_DOOR_CLOSE => BUTTON_DOOR_CLOSE,
    DOOR_STATE_OPEN=>DOOR_STATE_OPEN, DOOR_REQ_OPEN=>DOOR_REQ_OPEN, DOOR_REQ_CLOSED=>DOOR_REQ_CLOSED,
    nELEVATOR_READY => nELEVATOR_READY);
    
    

    test: process 
    begin
        --setup
        ELEVATOR_ON_FLOOR_0 <= '0';
        ELEVATOR_ON_FLOOR_1 <= '0';
        ELEVATOR_ON_FLOOR_2 <= '0';
        DOOR_OBSTRUCTED <= '0';
        BUTTON_DOOR_CLOSE <= '0';
        BUTTON_DOOR_OPEN <= '0';
        BUTTON_FLOOR_0 <= '0';
        BUTTON_FLOOR_1 <= '0';
        BUTTON_FLOOR_2 <= '0';
        DOOR_STATE_OPEN <= '0';
        wait for 50 ns;
        report "start sim" severity note;
        --first call cage to floor 0
        BUTTON_FLOOR_0 <= '1';
        wait for 50 ns;
        assert FLOOR_REQ_0  <= '1' report "floor 0 request didnt go trough" severity warning;
        BUTTON_FLOOR_0 <= '0';
        wait for 50 ns;
        ELEVATOR_ON_FLOOR_0 <= '1';
        wait for 50 ns;
        assert FLOOR_REQ_0 = '0' report "floor request didnt stop" severity warning;
        assert nELEVATOR_READY = '0' report "cage is in safe state were it shouldn't" severity warning;
        --controller opens door
        DOOR_STATE_OPEN <= '1';
        wait for 50 ns;
        assert nELEVATOR_READY = '1' report "cage is in unsafe state were it shouldn't" severity warning;
        --test some door actions
        BUTTON_DOOR_CLOSE <= '1';
        wait for 50 ns; 
        assert DOOR_REQ_CLOSED = '1' report "door didnt close" severity warning;
        DOOR_STATE_OPEN <= '0';
        BUTTON_DOOR_CLOSE <= '0';
        wait for 50 ns;
        --lets place the elevator in floor limbo and try to open the door 
        assert nELEVATOR_READY = '0' report "cage is in safe state were it shouldn't" severity warning;
        ELEVATOR_ON_FLOOR_0 <= '0';
        ELEVATOR_ON_FLOOR_1 <= '0';
        ELEVATOR_ON_FLOOR_2 <= '0';
        wait for 50 ns;
        BUTTON_DOOR_OPEN <= '1';
        wait for 50 ns;
        assert DOOR_REQ_OPEN = '0' report "door open request came trough, while is shouldn't be" severity warning;
        BUTTON_DOOR_OPEN <= '0';
        wait for 50 ns;
        --lets place cage on floor1 open the door an obstructd it.

        report "end of sim" severity failure;
    end process;
end architecture;