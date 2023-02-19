library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity level_entity is
  port(
    clock, nRESET : in std_logic; -- reset = low active
    button_elevator_call : in std_logic; --user activated
    elevator_called_to_level : out std_logic;
    elevator_on_this_level: in std_logic;
    button_emercency: in std_logic --low active
    );
end level_entity;

architecture level_arch of level_entity is

  signal called_feedback :std_logic := '0';
  
begin
  test: process(clock) --, reset, button_elevator_call, elevator_on_this_level, button_emercency)  
  begin
    --if rising_edge(clock) then
      called_feedback <= (nRESET and button_emercency and ((called_feedback and not elevator_on_this_level) or button_elevator_call));
      elevator_called_to_level<= called_feedback;
    --end if;
  end process;
end architecture;
