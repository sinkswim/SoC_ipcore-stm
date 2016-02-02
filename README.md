# SoC_ipcore-stm
VHDL files of a SoC for testing Xilinx Coregen Multiplier core.  Although the test is performed on a specific core, the purpose is to provide a general overview of a circuit in charge of testing a car's infotainment module.

The self-test module (STM) is comprised of:
    - ECU
    - ROM
    - RAM
    - Multiplier IP core

The multiplier and memory blocks have been generated via Coregen.
Two .coe files are provided for the ROM (golden_rom.coe and faulted_rom.coe) and one for the RAM (ram_init.coe).

## Details
The ECU is in charge of:
    1. Reading input patterns from the lower-half of the ROM and sending them to the multiplier.
    2. The result is then compared with the expected result (upper-half of the ROM).  
    3. If results are different the erroneous one is stored in RAM.
    4. After all patterns have been applied the system responds with an OK signal or with a FAULT signal 
    and outputs all wrong results on the debug port.
    
## Testbenches
Besides the testbench to test the overall system (STM_tb.vhd), tb for all 4 modules are provided.  
All have been tested using iSim.

## Synthesis
The STM is synthesizable and has been programmed successfully on an Artix-7 FPGA.
