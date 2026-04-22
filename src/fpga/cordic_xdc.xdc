## CLOCK SIGNAL (onboard 100MHz oscillator - Pin W5)
set_property PACKAGE_PIN W5 [get_ports clk]							
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]
 
## RESET BUTTON (center pushbutton - Pin U18)
set_property PACKAGE_PIN U18 [get_ports rst]						
set_property IOSTANDARD LVCMOS33 [get_ports rst]

## MUX CONTROL BUTTON (left pushbutton - Pin W19)
## Toggles LEDs between sine and cosine results
set_property PACKAGE_PIN W19 [get_ports btn]
set_property IOSTANDARD LVCMOS33 [get_ports btn]

## SWITCHES (16 switches, right to left)
## Sets the 16-bit angle_in value
set_property PACKAGE_PIN V17 [get_ports {angle_in[0]}]
set_property PACKAGE_PIN V16 [get_ports {angle_in[1]}]
set_property PACKAGE_PIN W16 [get_ports {angle_in[2]}]
set_property PACKAGE_PIN W17 [get_ports {angle_in[3]}]
set_property PACKAGE_PIN W15 [get_ports {angle_in[4]}]
set_property PACKAGE_PIN V15 [get_ports {angle_in[5]}]
set_property PACKAGE_PIN W14 [get_ports {angle_in[6]}]
set_property PACKAGE_PIN W13 [get_ports {angle_in[7]}]
set_property PACKAGE_PIN V2  [get_ports {angle_in[8]}]
set_property PACKAGE_PIN T3  [get_ports {angle_in[9]}]
set_property PACKAGE_PIN T2  [get_ports {angle_in[10]}]
set_property PACKAGE_PIN R3  [get_ports {angle_in[11]}]
set_property PACKAGE_PIN W2  [get_ports {angle_in[12]}]
set_property PACKAGE_PIN U1  [get_ports {angle_in[13]}]
set_property PACKAGE_PIN T1  [get_ports {angle_in[14]}]
set_property PACKAGE_PIN R2  [get_ports {angle_in[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {angle_in[*]}]

## LED OUTPUTS (16 LEDs, right to left)
## Displays 16-bit sine or cosine output
set_property PACKAGE_PIN U16 [get_ports {led_out[0]}]
set_property PACKAGE_PIN E19 [get_ports {led_out[1]}]
set_property PACKAGE_PIN U19 [get_ports {led_out[2]}]
set_property PACKAGE_PIN V19 [get_ports {led_out[3]}]
set_property PACKAGE_PIN W18 [get_ports {led_out[4]}]
set_property PACKAGE_PIN U15 [get_ports {led_out[5]}]
set_property PACKAGE_PIN U14 [get_ports {led_out[6]}]
set_property PACKAGE_PIN V14 [get_ports {led_out[7]}]
set_property PACKAGE_PIN V13 [get_ports {led_out[8]}]
set_property PACKAGE_PIN V3  [get_ports {led_out[9]}]
set_property PACKAGE_PIN W3  [get_ports {led_out[10]}]
set_property PACKAGE_PIN U3  [get_ports {led_out[11]}]
set_property PACKAGE_PIN P3  [get_ports {led_out[12]}]
set_property PACKAGE_PIN N3  [get_ports {led_out[13]}]
set_property PACKAGE_PIN P1  [get_ports {led_out[14]}]
set_property PACKAGE_PIN L1  [get_ports {led_out[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_out[*]}]

## CONFIGURATION BITS 
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]