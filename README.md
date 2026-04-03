# Overview

This repository is designed to measure the hardware design area of any hardware design implemented in Verilog. It provides a framework for synthesizing the design and measuring the area using Yosys tool. The repository includes a script `area.sh` that automates the process of synthesizing the design and extracting the area information and a sample library of standard cells `FreePDK45` for synthesis.

# Prerequisites

To measure the area, you need to have a library of all cells involved in the design. This repository includes the `FreePDK45` library, which is a commonly used standard cell library for synthesis. You can also use your own library if you have one.

There might be some cells in the design that are not present in the library. In such cases, you must add the missing cells to the library before running the area measurement script. This ensures that the synthesis process can accurately measure the area of the design.

Other than libraries, you also need to have the Yosys built. We have involved the Yosys tool in this repository as a submodule. The build process of Yosys has been included in the `area.sh` script, so you don't need to worry about it. Just run the script, and it will take care of building Yosys for you.

# Usage

At first, you need to clone the repository and initialize the submodules:

```bash
git clone --recursive git@github.com:EscapistArcadia/area.git
cd area
```

or 

```bash
git clone git@github.com:EscapistArcadia/area.git
cd area
git submodule update --init --recursive --progress
```

Then, you can run the `area.sh` script to measure the area.

```bash
./area.sh -m {fpga|asic} [-f family] -l library1 [library2 ...] -v verilog_root_dir -t top_module_name [-o output_log] [-V] [--dry]
```
The script takes several arguments:
- `-m`: Specifies the target technology for synthesis. You can choose either `fpga` or `asic` depending on your design requirements.
- `-f`: Specifies the family of the target technology, valid only when `-m` is `fpga`.
- `-l`: Specifies the list of libraries to be used for synthesis. By default, the script will use the `FreePDK45` library included in the repository (`./OpenROAD/TimerCalibration/Free45PDK/gscl45nm.lib`). You can specify more than one library if needed.
- `-v`: Specifies the root directory of the Verilog files. If your verilog files are organized in multiple directories, you can specify the root directory, and the script will search for all Verilog files under that directory. It is ok to have unused Verilog files.
- `-t`: Specifies the name of the top module to be synthesized.
- `-o`: (Optional) Specifies the file to which the output log will be written. If not specified, the output will be discarded.
- `-V`: (Optional) Enables output log to the console.
- `--dry`: Performs a dry run without actually synthesizing the design.

PS: some functions of the script are still under development, so you may encounter some issues when running the script. If you have any questions or suggestions, please feel free to open an issue or contact me directly.
