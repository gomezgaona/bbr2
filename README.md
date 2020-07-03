# An Emulation-based Evaluation of TCP BBRv2 Alpha for Wired Broadband (scripts)
This repository contains the scripts that run the measurement tests reported in the paper "An Emulation-based Evaluation of TCP BBRv2 Alpha for Wired Broadband" (link_to_the_paper).

## Usage

## Create a virtual machine with the following characteristics:
  - Hardware requirement:
    - CPU count: 8 (recommended).
    - Memory: 16GB.
    - Storage: 100GB.
 - Software requirements:
    - OS: Lubuntu 19.04.
    - Kernel version: 5.2.0-rc3+.
 - Tools and packages:
    - BBRv2 alpha: https://github.com/google/bbr/blob/v2alpha/README.md.
    - Mininet: http://mininet.org/download/.
    - iperf3.
    - plot_iperf3: https://github.com/ekfoury/iperf3_plotter.
## Files description:
Each folder contains the following files:
  - topo.py: this python script creates a Mininet topology to run the corresponding test.
  - start.sh: this script configures the parameters of the devices in the topology and runs the measurement tests.
  - aggregator.sh: this script generates the data produced by the measurement tests and displays them into a .csv file.

You can modify the parameters in the scripts depending on the metrics you want to report.
## Running a test:
  1. Copy the folders into the Linux's home directory.
  2. Navigate into a folder (i.e., link_util).
  3. Open a terminal in that directory.
  4. Run the Mininet topology by issuing the following command: **sudo python topo.py**.
  5. Run the test by issuing the following command: **sudo ./start.sh**.
  6. After the test is done, the results will be reported in the Desktop folder in a file called *out.csv*.
