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

architecture liftschacht_arch of liftschacht is
    component elevator_cage is
        port (
            clock, nRESET : in std_logic; --nRESET
            BUTTON_FLOOR_0, BUTTON_FLOOR_1, BUTTON_FLOOR_2: in std_logic; --floor choise buttons for users
            ELEVATOR_ON_FLOOR_0, ELEVATOR_ON_FLOOR_1, ELEVATOR_ON_FLOOR_2: in std_logic; --on wich floor is the cage
            DOOR_OBSTRUCTED, BUTTON_DOOR_CLOSE, BUTTON_DOOR_OPEN: in std_logic; -- door input signals
            DOOR_STATE_OPEN: in std_logic; --door open(1) or closed(0) state
            FLOOR_REQ_0, FLOOR_REQ_1,FLOOR_REQ_2: out std_logic;-- := '0'; --the floor the cage requests the controller to be taken to
            DOOR_REQ_OPEN, DOOR_REQ_CLOSED: out std_logic;-- := '0'; --request door to be opened or closed to the controller
            nELEVATOR_READY: out std_logic-- := '0' --determines if cage is safe to start moving or 
        );
        end component;
    for cage: elevator_cage use entity work.elevator_cage;

    component elevator_control
        port(
            clock, nRESET : in std_logic; -- reset = low active
            elevator_called_to_level0, elevator_called_to_level1,elevator_called_to_level2 : in std_logic; --activated on the different levels and inside the cage
            elevator_arrived_on_level0, elevator_arrived_on_level1, elevator_arrived_on_level2  : in std_logic; --comes from the elevatorshaft
            cage_safe : in std_logic; --tels control lift is secure and ready to move.
            control_door_open_req, control_door_closed_req: in std_logic;
            control_lftdr :out std_logic; -- control signal to open the door
            control_motor_up, control_motor_down, control_motor_emercency:out std_logic;
            light0, light1,light2: out std_logic; --controls the ligths that signal wich levels are called.
            control_door_state_open: in std_logic; --door open(1) or closed(0) state
            control_door_obstructed: in std_logic;
            emercency: in std_logic

            );
    end component;
    for controller: elevator_control use entity work.elevator_control;

    component level_entity 
        port(
            clock, nRESET : in std_logic; -- reset = low active
            button_elevator_call : in std_logic; --user activated
            elevator_called_to_level : out std_logic;
            elevator_on_this_level: in std_logic;
            button_emercency: in std_logic --low active
        );
    end component;
    --declare 3 levels:
    for level0: level_entity use entity work.level_entity;
    for level1: level_entity use entity work.level_entity;
    for level2: level_entity use entity work.level_entity;
    
    signal master_level_req0, level_level_req0, cage_level_req0: std_logic;
    signal master_level_req1, level_level_req1, cage_level_req1: std_logic;
    signal master_level_req2, level_level_req2, cage_level_req2: std_logic;
    
    signal master_door_open_req, master_door_closed_req: std_logic;
    signal master_elevator_ready: std_logic;
    signal master_door_state_open: std_logic;

begin
    level0: level_entity port map ( 
        clock => clock, nRESET => nRESET, button_elevator_call => keuze_0_hal, 
        elevator_called_to_level => level_level_req0, elevator_on_this_level => positie_0,
        button_emercency => noodstop_lift);
    level1: level_entity port map ( 
        clock => clock, nRESET => nRESET, button_elevator_call => keuze_1_hal, 
        elevator_called_to_level => level_level_req1, elevator_on_this_level => positie_1,
        button_emercency => noodstop_lift);
    level2: level_entity port map ( 
        clock => clock, nRESET => nRESET, button_elevator_call => keuze_2_hal, 
        elevator_called_to_level => level_level_req2, elevator_on_this_level => positie_2,
        button_emercency => noodstop_lift);

    cage: elevator_cage port map (
        clock => clock, nRESET => nRESET, 
        BUTTON_FLOOR_0 => keuze_0_lift, BUTTON_FLOOR_1 => keuze_1_lift, BUTTON_FLOOR_2 => keuze_2_lift,
        ELEVATOR_ON_FLOOR_0 => positie_0, ELEVATOR_ON_FLOOR_1 => positie_1, ELEVATOR_ON_FLOOR_2 => positie_2,
        DOOR_OBSTRUCTED => lift_ready, BUTTON_DOOR_CLOSE => deur_dicht, BUTTON_DOOR_OPEN => deur_open,
        DOOR_STATE_OPEN => master_door_state_open, 
        FLOOR_REQ_0 => cage_level_req0, FLOOR_REQ_1 => cage_level_req1, FLOOR_REQ_2 => cage_level_req2,
        DOOR_REQ_OPEN => master_door_open_req, DOOR_REQ_CLOSED => master_door_closed_req, --extra signals needed between components?
        nELEVATOR_READY => master_elevator_ready
    );

    
    controller: elevator_control port map(
        clock => clock, nRESET => nRESET,
        elevator_called_to_level0 => master_level_req0, elevator_called_to_level1 => master_level_req1, elevator_called_to_level2 => master_level_req2,
        elevator_arrived_on_level0 => positie_0, elevator_arrived_on_level1 => positie_1, elevator_arrived_on_level2 => positie_2,
        light0 => lamp_0, light1 => lamp_1, light2 => lamp_2, 
        control_door_open_req => master_door_open_req, control_door_closed_req => master_door_closed_req,
        cage_safe => master_elevator_ready, control_lftdr =>master_door_state_open, control_door_state_open => master_door_state_open,
        control_motor_up => op, control_motor_down => neer, control_motor_emercency => noodstop,
        control_door_obstructed => lift_ready, emercency => noodstop_lift
    );
            master_level_req0 <= level_level_req0 or cage_level_req0;
            master_level_req1 <= level_level_req1 or cage_level_req1;
            master_level_req2 <= level_level_req2 or cage_level_req2;
            lftdr <= master_door_state_open;

end architecture ; --liftschacht_arch
