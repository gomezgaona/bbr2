# An Emulation-based Evaluation of TCP BBRv2 Alpha for Wired Broadband (scripts)
This repository contains the scripts that run the tests reported in the paper "An Emulation-based Evaluation of TCP BBRv2 Alpha for Wired Broadband" (link_to_the_paper).

## Usage

## Create a virtual machine with the following characteristics:
  - Hardware requirement:
    - CPU count: 8 (recommended)
    - Memory: 16GB
    - Storage: 100GB
 - Software requirements:
    - OS: Lubuntu 19.04
    - Kernel version: 5.2.0-rc3+
    - BBRv2 alpha: https://github.com/google/bbr/blob/v2alpha/README.md
    - Mininet: http://mininet.org/download/
    - iperf3
    - plot_iperf3: https://github.com/ekfoury/iperf3_plotter
    
## Running a test:
  1. Navigate into a foler (i.e., heatmap_test)
  2. Open a terminal 
  3. Run the Mininet topology by issuing the following command: **sudo python topo.py**
  4. Run the test by issuing the following command: **./start.sh**
  6. After the test is done, the results will be reported in the Desktop folder in a file called out.csv
