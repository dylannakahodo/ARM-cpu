# ARM-cpu
An ARM CPU written in Verilog.

Assignment for Digital Systems and Computer Design class. Implements a 16-bit ARM CPU, nicknamed LEGv8, to execute a simplified version of the ARM instruction set. The CPU was designed in Verilog and currently has basic functionality. The testbench used to test the functionality of the cpu is an assembly program that multiplies two numbers together.

**Disclaimer**: These files were tested in an older version of Vivado, there is no guarantee that they work in newer versions.

## Running
### Pre-reqs
1. These files were created and run using Vivado WebPACK.  This can be downloaded [here](https://www.xilinx.com/support/download.html). (You will need to create an account with Xilinx and fill out some survey information before downloading the software)
2. Install Vivado WebPACK, it may take a while.
3. Download the Verilog files and save to a directory.

### Running Simulation in Vivado
1. Open Vivado > Create Project
2. Follow the steps in the New Project Wizard.
- Name your project and choose a location to create the directory, Click Next
- Select RTL Project, Click Next
- Add all the Verilog files you downloaded earlier, Click Next
- Don't add any Constraints
- Keep whatever part is selected by default. (It doesn't matter since these files are just meant to run in the simulation)
3. Run a Behavioral Simulation
- Flow/Flow Navigator > Run Simulation > Run Behavioral Simulation
4. Output of the testbench can be observed in the Tcl Console on the bottom of the screen.

