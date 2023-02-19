library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


entity elevator_tb is
end entity;

architecture test_bench of elevator_tb is
component liftschacht 
    port(
        --signals descriped on assignment:
        keuze_0_hal, keuze_1_hal, keuze_2_hal : in std_logic; --call cage buttons on their respective levels.
        keuze_0_lift, keuze_1_lift, keuze_2_lift : in std_logic;
        lamp_0, lamp_1, lamp_2: out std_logic; --light to indicate which level is chosen.
        positie_0, positie_1, positie_2: in std_logic;  --high depending on wich floor the cage is positioned
        lftdr: out std_logic; --liftdoor is open(1) or closed (0)
        lift_ready: in std_logic; --slightly misleading name IMO, if 1 door cannot close because an obstruction.
        deur_open, deur_dicht: in std_logic; --buttons to open or close the door (if save to do so)
        noodstop_lift: in std_logic; -- emercency stop
        nRESET: in std_logic; --reset elevator signal.
        op, neer, noodstop: out std_logic; --motor control signals
        clock: in std_logic --master clock signal
    );
    end component;
    for lift: liftschacht use entity work.liftschacht;

    signal keuze_0_hal, keuze_1_hal, keuze_2_hal : std_logic; --call cage buttons on their respective levels.
    signal keuze_0_lift, keuze_1_lift, keuze_2_lift : std_logic;
    signal lamp_0, lamp_1, lamp_2: std_logic; --light to indicate which level is chosen.
    signal positie_0, positie_1, positie_2: std_logic:= '0';  --high depending on wich floor the cage is positioned
    signal lftdr: std_logic; --liftdoor is open(1) or closed (0)
    signal lift_ready: std_logic:= '1'; --slightly misleading name IMO, if 1 door cannot close because an obstruction.
    signal deur_open, deur_dicht: std_logic; --buttons to open or close the door (if save to do so)
    signal noodstop_lift: std_logic; -- emercency stop
    signal nRESET: std_logic; --reset elevator signal.
    signal op, neer, noodstop: std_logic; --motor control signals
    signal clock: std_logic; --master clock signal

    signal cage_height: std_logic_vector( 35 downto 0 ) := x"200000000"; 
    signal tmp : std_logic_vector( 35 downto 0 ) := cage_height; 
    --constants that define the bit location that represent a floor.
    constant cage_height_2 : std_logic_vector ( 35 downto 0 ) := x"200000000";
    constant cage_height_1 : std_logic_vector ( 35 downto 0 ) := x"000020000";
    constant cage_height_0 : std_logic_vector ( 35 downto 0 ) := x"000000002";
    constant cage_safe_hight : std_logic_vector (35 downto 0) := x"3fffffffe";

begin
    lift: liftschacht port map( keuze_0_hal=> keuze_0_hal, keuze_1_hal=> keuze_1_hal, keuze_2_hal => keuze_2_hal,
    keuze_0_lift=> keuze_0_lift, keuze_1_lift => keuze_1_lift, keuze_2_lift =>keuze_2_lift,
    lamp_0 => lamp_0, lamp_1 => lamp_1, lamp_2 =>lamp_2,
    positie_0 => positie_0, positie_1 => positie_1, positie_2 =>positie_2,
    lftdr => lftdr, lift_ready => lift_ready, deur_open => deur_open, deur_dicht=> deur_dicht,
    noodstop_lift => noodstop_lift, nRESET => nRESET, op =>op, neer => neer, noodstop=> noodstop, clock => clock);

    clk: process
    begin
        clock <= '1';
        wait for 5 ns ;
        clock <= '0';
        wait for 5 ns;
    end process;

    --proces that simulates movement of the cage in the shaft according to the engine state by the controller
    engine: process 
    begin
        wait until rising_edge(clock); 
        --raise or lower elevator in shaft.
        if op = '1' and noodstop = '1'  then --engine cannot move with breaks applied
            cage_height <= cage_height( 34 DOWNTO 0) & '0';
        end if;
        if neer = '1' and noodstop = '1' then
            cage_height <=  '0' & cage_height(35 DOWNTO 1);
        end if;
        if (op = '1' or neer = '1') and noodstop = '0' then
            report "tried to move engine with breaks applied" severity failure;
        --if cage height bit false outside safe hight range stop simulation
        end if;
        assert (cage_height and not cage_safe_hight) = x"00000000" report "cage crashed, a lot of people died" severity failure;
    end process;

    cage2: process(cage_height) --determine if cage is on a level, proces runs on changing of cage heigth
    begin      
    if cage_height = cage_height_0 then
        positie_0 <= '1';
    else
        positie_0 <= '0';
    end if;
    if cage_height = cage_height_1 then
        positie_1 <= '1';
    else
        positie_1 <= '0';
    end if;
    if cage_height = cage_height_2 then
        positie_2 <= '1';
    else
        positie_2 <= '0';
    end if;
    end process;
    
    -- process to generate reports on edges of signals
    reports: process( positie_0, positie_1, positie_2, lftdr, keuze_0_hal, keuze_1_hal, keuze_2_hal, 
                    keuze_0_lift, keuze_1_lift, keuze_2_lift, lamp_0, lamp_1, lamp_2, op, neer, noodstop, deur_open, deur_dicht)
    begin
        if rising_edge(positie_0) then 
            report "elevator on ground floor" severity note;
        end if;
        if rising_edge(positie_1) then 
            report "elevator on first floor" severity note;
        end if;
        if rising_edge(positie_2) then 
            report "elevator on second floor" severity note;
        end if;
        if rising_edge(lftdr) then 
            report "elevator door open" severity note;
        end if;
        if falling_edge(lftdr) then
            report "elevator door closed" severity note;
        end if;
        if rising_edge(keuze_0_hal) then
            report "elevator call from ground floor" severity note;
        end if;
        if rising_edge(keuze_1_hal) then
            report "elevator call from first floor" severity note;
        end if;
        if rising_edge(keuze_2_hal) then
            report "elevator call from second floor" severity note;
        end if;
        if rising_edge(keuze_0_lift) then
            report "user wants to go to the ground floor" severity note;
        end if;
        if rising_edge(keuze_1_lift) then
            report "user wants to go to the first floor" severity note;
        end if;
        if rising_edge(keuze_2_lift) then
            report "user wants to go to the second floor" severity note;
        end if;
        if rising_edge(lamp_0) then
            report "light for ground floor sitched on" severity note;
        end if;
        if falling_edge(lamp_0) then
            report "light for ground floor sitched off" severity note;
        end if;
        if rising_edge(lamp_1) then
            report "light for first floor sitched on" severity note;
        end if;
        if falling_edge(lamp_1) then
            report "light for first floor sitched off" severity note;
        end if;
        if rising_edge(lamp_2) then
            report "light for second floor sitched on" severity note;
        end if;
        if falling_edge(lamp_2) then
            report "light for second floor sitched off" severity note;
        end if;
        if rising_edge(op) then
            report "cage is raised" severity note;
        end if;
        if falling_edge(op) then
            report "cage is no longer raised" severity note;
        end if;
        if rising_edge(neer) then
            report "cage is lowered" severity note;
        end if;
        if falling_edge(neer) then
            report "cage is no longer lowered" severity note;
        end if;
        if falling_edge(noodstop) then
            report "elevator engine has performed an emercency brake" severity note;
        end if; 
        if rising_edge(noodstop) then
            report "elevator engine emercency brake is released" severity note;
        end if; 
        if rising_edge(deur_open) then
            report "door open button is pushed" severity note;
        end if; 
        if rising_edge(deur_dicht) then
            report "door close button is pushed" severity note;
        end if; 
    end process;

    main: process
     begin
        report "start of sim" severity note;

        nRESET <= '1';
        noodstop_lift <= '1';
        --above signals are low active
        keuze_0_hal <= '0';
        keuze_1_hal <= '0';
        keuze_2_hal <= '0';
        keuze_0_lift <= '0';
        keuze_1_lift <= '0';
        keuze_2_lift <= '0';
        deur_open <= '0';
        deur_dicht <= '0';
        lift_ready <= '0';        
        --after reset lift goes to startting position
        report "scenario 1" severity warning;
        wait until positie_0 = '1';
        wait until lftdr = '1'; --wait until liftdoor has opened
        wait until rising_edge (clock); --give controller some time to change states
        --lets try to go to level 1
        keuze_1_hal <= '1';
        wait until rising_edge (clock); --give controller some time to change states
        wait until rising_edge (clock); --give controller some time to change states
        keuze_1_hal <= '0';
        wait until positie_1 = '1';
        wait until lftdr = '1';
        wait until rising_edge(clock);
        wait until rising_edge(clock);
        keuze_0_lift <= '1';
        wait for 20 ns;
        keuze_0_lift <= '0';
        wait until positie_0 = '1';
        wait until lftdr = '1';
        wait until rising_edge(clock);
        wait until rising_edge(clock);
        wait for 200 ns;


        report "scenario 2" severity warning;
        --user wants to go to 2 from 0, another user calls from 1 that want to got to 0
        report "an user calls elevator to gnd floor" severity note;
        keuze_0_hal <= '1';
        wait for 15 ns;
        keuze_0_hal <= '0';
        wait until rising_edge(clock);
        --passenger entered
        wait until lftdr = '1';
        lift_ready <= '1';
        wait for 15 ns;
        lift_ready <= '0';
        wait for 5 ns;
        keuze_2_lift <= '1';
        wait for 15 ns;
        keuze_2_lift <= '0';
        wait until falling_edge(positie_0);
        --when cage is underway to level 2, a new passenger calls for cage on level 1
        wait until rising_edge(clock);
        keuze_1_hal <= '1';
        wait for 15 ns;
        keuze_1_hal <= '0';
        wait until rising_edge(lftdr);
        assert positie_1 = '1' report "elevator did not stop on first floor to let another user in" severity error ;
        --lift_ready <= '1';
        wait for 15 ns;
        lift_ready <= '1';
        wait for 20 ns; --time to let passenger on board, should be no problem since liftdoor should stay open for 5 clockcycli before moving on to the next floor;
        keuze_0_lift <= '1';
        wait for 15 ns;
        keuze_0_lift <= '0';
        wait for 500 ns; 
        report "new passanger had door obstructed, it is removed now" severity note;
        lift_ready <= '0';
        wait until rising_edge(positie_0);
        --wait until lftdr = '1';
        wait until falling_edge(lftdr);
        wait until rising_edge(clock);
        report "user was busy playing with it's phone, so the door should be closed by now" severity note;
        deur_open <= '1';
        wait for 15 ns;
        deur_open <= '0';
        wait until lftdr = '1'; 
        wait for 10 ns;
        assert lftdr = '1' report "door is closed when it should be open" severity error;
        lift_ready <= '1';
        wait for 15 ns;
        lift_ready <= '0';
        --wait for 50 ns;
        wait for 20 ns;
        deur_dicht <= '1';
        wait for 15 ns;
        deur_dicht <= '0';
        wait for 200 ns; 


        report "scenario emerency break with reset" severity warning;
        keuze_2_lift <= '1';
        wait for 15 ns;
        keuze_2_lift <= '0';
        wait until rising_edge(positie_1);
        -- wait for 5 clocksignals to confirm that the elevator in the middle of 2 floors
        wait until rising_edge(clock);
        wait until rising_edge(clock);
        wait until rising_edge(clock);
        wait until rising_edge(clock);
        wait until rising_edge(clock);
        report "emergcency button is pushed!" severity note;
        noodstop_lift <= '0';
        wait for 15 ns;
        noodstop_lift <= '1';
        wait for 30 ns; --wait some time and press floor choise again to confirm elevator is going nowhere.
        keuze_2_lift <= '1';
        wait for 15 ns;
        keuze_2_lift <= '0';
        --wait for 2 clocksignals to give the controller the change to change states
        wait until rising_edge(clock);
        wait until rising_edge(clock);
        assert noodstop = '0' report "elevator engine should still be on emergency break" severity error;
        --reset controller, elevator should go to the ground floor
        report "push reset button" severity note;
        nRESET <= '0';
        wait for 15 ns;
        nRESET <='1';
        wait until rising_edge(positie_0);
        wait until lftdr = '1'; --wait until liftdoor has opened
        wait for 200 ns;
        wait until rising_edge (clock); --give controller some time to change states

        report "end of sim" severity failure;
     end process;
end architecture;