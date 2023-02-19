library ieee;
use ieee.STD_LOGIC_1164.all;
use ieee.numeric_bit.all;
use ieee.STD_LOGIC_UNSIGNED.all;

entity level_tb is
end level_tb;

architecture test of level_tb is
  component level_entity
  port(
    clock, nRESET : in std_logic; -- reset = low active
    button_elevator_call : in std_logic; --user activated
    elevator_called_to_level : out std_logic;
    elevator_on_this_level: in std_logic;
    button_emercency: in std_logic --low active
    );
  end component;
  for level_test: level_entity use entity work.level_entity;

  signal clock, nRESET : std_logic; -- reset = low active
  signal button_elevator_call :  std_logic; --user activated
  signal elevator_called_to_level : std_logic;
  signal elevator_on_this_level: std_logic;
  signal button_emercency: std_logic; --low active
  signal looping : std_logic_vector(4 downto 0) := "00000";
  
begin
  level_test: level_entity port map ( clock => clock, nRESET => nRESET, button_elevator_call => button_elevator_call, elevator_called_to_level => elevator_called_to_level, elevator_on_this_level => elevator_on_this_level, button_emercency =>button_emercency);
  
  process
  begin
      looping <= looping + 1;
      button_emercency <= looping(3);
      nRESET <= looping(2);
      elevator_on_this_level <= looping(1);
      button_elevator_call <= looping(0);
      for rounds in 0 to 10 loop
        clock <= '1';
        wait for 50 ns;
        clock <= '0';
        wait for 50 ns;
--          elevator_on_this_level <= '0';
      button_elevator_call <= '0';
      end loop;
      if (looping = "10000")then
        clock <= '1';
        wait for 50 ns;
        clock <= '0';
        report "end of sim" severity failure;
      end if;
    end process;
  end architecture;
  
        
