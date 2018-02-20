# ARM-cpu
An ARM CPU written in Verilog.

Assignment for Digital Systems and Computer Design class. Implements a 16-bit ARM CPU, nicknamed LEGv8, to execute a simplified version of the ARM instruction set. The CPU was designed in Verilog and currently has basic functionality. The testbench used to test the functionality of the cpu is an assembly program that multiplies two numbers together.

**Disclaimer**: These files were tested in an older version of Vivado, there is no guarantee that they work in newer versions.

The diagram below is the schematic for the CPU that this code is simulating.

![CPU Diagram](/images/cpu-diagram.PNG?raw=true)

## Contents
* IM1.V 
  * Instruction Memory containing assembly program
* LEGLite-Control.V 
  * Control module
* LegLite-PC.V 
  * Program Counter
* LEGLiteSingle.V 
  * CPU
* Parts.V 
  * Various modules for CPU
* testbench-LEGLiteSingle-Stage2.V 
  * Test Bench to run the assembly program on the simulated CPU

## Running
### Pre-reqs
* These files were created and run using Vivado WebPACK.  This can be downloaded [here](https://www.xilinx.com/support/download.html). (You will need to create an account with Xilinx and fill out some survey information before downloading the software)
* Install Vivado WebPACK, it may take a while.
* Download the Verilog files and save to a directory.

### Running Simulation in Vivado
* Open Vivado > Create Project
* Follow the steps in the New Project Wizard.
  - Name your project and choose a location to create the directory, Click Next
  - Select RTL Project, Click Next
  - Click Add Files, Add all the Verilog files you downloaded earlier, Click Next
  - Don't add any Constraints
  - Keep whatever part is selected by default. (It doesn't matter since these files are just meant to run in the simulation)
* Run a Behavioral Simulation
  - Flow/Flow Navigator > Run Simulation > Run Behavioral Simulation
* Output of the testbench can be observed in the Tcl Console on the bottom of the screen.

