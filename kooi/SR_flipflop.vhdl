library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity SR_FLIPFLOP is
    port(
        S, R : in std_logic;
        Q: out std_logic := '0'; 
        nQ : out std_logic := '0';
        clock: in std_logic
    );
    end entity SR_FLIPFLOP;

architecture behaviour of SR_FLIPFLOP is
    begin
        process (clock, S,R)
        begin
            if rising_edge(clock) then
                if (S /= R) then
                    Q <= S;
                    nQ <= R;
                end if;
            end if;
        end process;
end architecture;