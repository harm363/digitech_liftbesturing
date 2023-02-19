library ieee;
use ieee.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use ieee.STD_LOGIC_UNSIGNED.all;

--entitity and architecture that connects the different sub entities for total simulation

entity liftschacht is 
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
end liftschacht;

architecture testing of liftschacht is
begin
    test: process (clock)
    begin
        lamp_0 <= clock;
    end process;
end architecture;

-- library IEEE;
-- use IEEE.std_logic_1164.all;
-- use IEEE.numeric_std.all;
-- use IEEE.STD_LOGIC_UNSIGNED.all;


-- entity elevator_tb is
-- end entity;

-- architecture test_bench2 of elevator_tb is
-- component liftschacht 
--     port(
--         --signals descriped on assignment:
--         keuze_0_hal, keuze_1_hal, keuze_2_hal : in std_logic; --call cage buttons on their respective levels.
--         keuze_0_lift, keuze_1_lift, keuze_2_lift : in std_logic;
--         lamp_0, lamp_1, lamp_2: out std_logic; --light to indicate which level is chosen.
--         positie_0, positie_1, positie_2: in std_logic;  --high depending on wich floor the cage is positioned
--         lftdr: out std_logic; --liftdoor is open(1) or closed (0)
--         lift_ready: in std_logic; --slightly misleading name IMO, if 1 door cannot close because an obstruction.
--         deur_open, deur_dicht: in std_logic; --buttons to open or close the door (if save to do so)
--         noodstop_lift: in std_logic; -- emercency stop
--         nRESET: in std_logic; --reset elevator signal.
--         op, neer, noodstop: out std_logic; --motor control signals
--         clock: in std_logic --master clock signal
--     );
--     end component;
--     for lift: liftschacht use entity work.liftschacht;

--     signal keuze_0_hal, keuze_1_hal, keuze_2_hal : std_logic; --call cage buttons on their respective levels.
--     signal keuze_0_lift, keuze_1_lift, keuze_2_lift : std_logic;
--     signal lamp_0, lamp_1, lamp_2: std_logic; --light to indicate which level is chosen.
--     signal positie_0, positie_1, positie_2: std_logic;  --high depending on wich floor the cage is positioned
--     signal lftdr: std_logic; --liftdoor is open(1) or closed (0)
--     signal lift_ready: std_logic; --slightly misleading name IMO, if 1 door cannot close because an obstruction.
--     signal deur_open, deur_dicht: std_logic; --buttons to open or close the door (if save to do so)
--     signal noodstop_lift: std_logic; -- emercency stop
--     signal nRESET: std_logic; --reset elevator signal.
--     signal op, neer, noodstop: std_logic; --motor control signals
--     signal clock: std_logic; --master clock signal

--     signal cage_hight: std_logic_vector( 35 downto 0 ) := x"000000002"; 
--     signal tmp : std_logic_vector( 35 downto 0 ) := x"000000002"; 
--     --constants that define the bit location that represent a floor.
--     constant cage_hight_2 : std_logic_vector ( 35 downto 0 ) := x"200000000";
--     constant cage_hight_1 : std_logic_vector ( 35 downto 0 ) := x"000020000";
--     constant cage_hight_0 : std_logic_vector ( 35 downto 0 ) := x"000000002";
--     constant cage_safe_hight : std_logic_vector (35 downto 0):= x"2fffffff2";

-- begin
--     lift: liftschacht port map( keuze_0_hal=> keuze_0_hal, keuze_1_hal=> keuze_1_hal, keuze_2_hal => keuze_2_hal,
--     keuze_0_lift=> keuze_0_lift, keuze_1_lift => keuze_1_lift, keuze_2_lift =>keuze_2_lift,
--     lamp_0 => lamp_0, lamp_1 => lamp_1, lamp_2 =>lamp_2,
--     positie_0 => positie_0, positie_1 => positie_1, positie_2 =>positie_2,
--     lftdr => lftdr, lift_ready => lift_ready, deur_open => deur_open, deur_dicht=> deur_dicht,
--     noodstop_lift => noodstop_lift, nRESET => nRESET, op =>op, neer => neer, noodstop=> noodstop, clock => clock);

--     clk: process
--     begin
--         clock <= '1';
--         wait for 5 ns ;
--         clock <= '0';
--         wait for 5 ns;

--     end process;
-- end architecture;
