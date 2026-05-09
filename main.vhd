library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity main is
    Port ( 
        
        clk      : in  STD_LOGIC;                    
        sw       : in  STD_LOGIC_VECTOR (1 downto 0); 
        sw2       : in  STD_LOGIC_VECTOR (1 downto 0); 
        segments : out STD_LOGIC_VECTOR (6 downto 0); 
        an       : out STD_LOGIC_VECTOR (7 downto 0)
    );
end main;
architecture Behavioral of main is
    -- REPARARE EROARE [Synth 8-274]: Definim tipul fara dimensiune fixa
        type tip_mesaj is array (0 to 7) of std_logic_vector(6 downto 0);
        signal mesaj_activ : tip_mesaj;
        signal Mesaj : tip_mesaj;
constant CHAR_A : std_logic_vector(6 downto 0) := "1110111"; -- A
constant CHAR_B : std_logic_vector(6 downto 0) := "0011111"; -- b (mic)
constant CHAR_D : std_logic_vector(6 downto 0) := "0111101"; -- d (mic)
constant CHAR_E : std_logic_vector(6 downto 0) := "1001111"; -- E
constant CHAR_L : std_logic_vector(6 downto 0) := "0001110"; -- L
constant CHAR_O : std_logic_vector(6 downto 0) := "0011101"; -- o (mic) pentru ROSU
constant CHAR_R : std_logic_vector(6 downto 0) := "0000101"; -- r (mic)
constant CHAR_S : std_logic_vector(6 downto 0) := "1011011"; -- S (5)
constant CHAR_T : std_logic_vector(6 downto 0) := "0001111"; -- t (mic)
constant CHAR_U : std_logic_vector(6 downto 0) := "0111110"; -- U
constant CHAR_V : std_logic_vector(6 downto 0) := "0011100"; -- v (mic) - diferit de U
constant CHAR_SPACE : std_logic_vector(6 downto 0) := "0000000"; -- Spațiu;

    -- Dimensiunea se constrange doar aici la declararea constantei
    constant MESAJ1 : tip_mesaj := (CHAR_A, CHAR_L, CHAR_B, CHAR_A, CHAR_S, CHAR_T, CHAR_R, CHAR_U);
    constant MESAJ2 : tip_mesaj := (CHAR_R, CHAR_O, CHAR_S, CHAR_U, CHAR_SPACE, CHAR_SPACE, CHAR_SPACE, CHAR_SPACE);
    constant MESAJ3 : tip_mesaj := (CHAR_V, CHAR_E, CHAR_R, CHAR_D, CHAR_E, CHAR_SPACE, CHAR_SPACE, CHAR_SPACE);
    constant MESAJ4 : tip_mesaj := (CHAR_A, CHAR_L, CHAR_B, CHAR_SPACE, CHAR_SPACE, CHAR_SPACE, CHAR_SPACE, CHAR_SPACE);

    signal clk_div   : std_logic_vector(27 downto 0) := (others => '0');
    signal digit_sel : std_logic_vector(2 downto 0) := "000"; 
    signal hex_digit : std_logic_vector(6 downto 0);  
begin
     process(sw2)
    begin
        case sw2(1 downto 0) is
            when "00"   => mesaj_activ <= Mesaj1;
            when "01"   => mesaj_activ <= Mesaj2;
            when "10"   => mesaj_activ <= Mesaj3;
            when others => mesaj_activ <= Mesaj4;
        end case;
    end process;
    -- 1. Divizorul de ceas (Clock Divider)
    process(clk)
    begin
        if rising_edge(clk) then
            clk_div <= clk_div + 1;
        end if;
    end process;

    -- Multiplexare: Selectia digit-ului (frecventa de refresh)
    digit_sel <= clk_div(19 downto 17);

    -- 2. Logica pentru Anozi si Regimuri (Multiplexare si Animații)
    process(digit_sel, sw, clk_div,mesaj_activ)
    begin
        MESAJ <= mesaj_activ;
        -- Activarea fizica a anozilor (Anod Comun: '0' = activ)
        case digit_sel is
            when "000" => an <= "11111110"; 
            when "001" => an <= "11111101"; 
            when "010" => an <= "11111011"; 
            when "011" => an <= "11110111"; 
            when "100" => an <= "11101111"; 
            when "101" => an <= "11011111"; 
            when "110" => an <= "10111111"; 
            when "111" => an <= "01111111"; 
            when others => an <= "11111111";
        end case;

        -- Cele 4 regimuri cerute
        case sw is
            when "00" => -- REGIM 1: STATIC
                case digit_sel is
                    when "000" => hex_digit <= MESAJ(0);
                    when "001" => hex_digit <= MESAJ(1);
                    when "010" => hex_digit <= MESAJ(2);
                    when "011" => hex_digit <= MESAJ(3);
                    when "100" => hex_digit <= MESAJ(4);
                    when "101" => hex_digit <= MESAJ(5);
                    when "110" => hex_digit <= MESAJ(6);
                    when "111" => hex_digit <= MESAJ(7);
                    when others => hex_digit <= CHAR_SPACE;
                end case;

            when "01" => -- REGIM 2: PALPAIRE (BLINKING)
                if clk_div(26) = '1' then
                    case digit_sel is
                        when "000" => hex_digit <= MESAJ(0);
                        when "001" => hex_digit <= MESAJ(1);
                        when "010" => hex_digit <= MESAJ(2);
                        when "011" => hex_digit <= MESAJ(3);
                        when "100" => hex_digit <= MESAJ(4);
                        when "101" => hex_digit <= MESAJ(5);
                        when "110" => hex_digit <= MESAJ(6);
                        when "111" => hex_digit <= MESAJ(7);
                        when others => hex_digit <= CHAR_SPACE;
                    end case;
                else
                    an <= "11111111"; -- Stinge afisajul
                    hex_digit <= CHAR_SPACE;
                end if;

            when "10" => -- REGIM 3: CURGERE (Scrolling) - SPRE STANGA
                case (digit_sel + clk_div(27 downto 25)) is
                    when "000" => hex_digit <= MESAJ(0);
                    when "001" => hex_digit <= MESAJ(1);
                    when "010" => hex_digit <= MESAJ(2);
                    when "011" => hex_digit <= MESAJ(3);
                    when "100" => hex_digit <= MESAJ(4);
                    when "101" => hex_digit <= MESAJ(5);
                    when "110" => hex_digit <= MESAJ(6);
                    when "111" => hex_digit <= MESAJ(7);
                    when others => hex_digit <= CHAR_SPACE;
                end case;

            when others => -- REGIM 4: CURGERE (Scrolling) - SPRE DREAPTA
                case (digit_sel - clk_div(27 downto 25)) is
                    when "000" => hex_digit <= MESAJ(0);
                    when "001" => hex_digit <= MESAJ(1);
                    when "010" => hex_digit <= MESAJ(2);
                    when "011" => hex_digit <= MESAJ(3);
                    when "100" => hex_digit <= MESAJ(4);
                    when "101" => hex_digit <= MESAJ(5);
                    when "110" => hex_digit <= MESAJ(6);
                    when "111" => hex_digit <= MESAJ(7);
                    when others => hex_digit <= CHAR_SPACE;
                end case;
        end case;
    end process; 

    segments <= not hex_digit;
    
end Behavioral;