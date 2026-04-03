#!/usr/bin/env bash

if [ $# -lt 1 ]; then
    echo "Usage: $0 <area>"
    exit 1
fi

LIBRARY_FILE=$(realpath "./OpenROAD/TimerCalibration/Free45PDK/gscl45nm.lib")
VERILOG_ROOT=$(realpath "./rtl")
VERBOSE=0
OUTPUT_FILE=""
DRY_RUN=0
MODE=""
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -l|--library)
            LIBRARY_FILE=$(realpath "$2")
            shift 2
            ;;
        -v|--verilog)
            VERILOG_ROOT=$(realpath "$2")
            shift 2
            ;;
        -t|--top)
            TOP_MODULE="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_FILE=$(realpath "$2")
            shift 2
            ;;
        -V|--verbose)
            VERBOSE=1
            OUTPUT_FILE=$(realpath "$2")
            shift 2
            ;;
        --dry)
            DRY_RUN=1
            shift
            ;;
        -m|--mode)
            MODE="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $key"
            exit 1
            ;;
    esac
done

# set -x

VERILOG_FILES=$(find "$VERILOG_ROOT" -type f -name "*.v" | tr '\n' ' ')
LIBERTIES_FILES="$LIBRARY_FILE $(find "$PWD/sram" -type f -name "*.lib" | tr '\n' ' ')"
LIBERTIES_FILES_WITH_LABEL="-liberty $LIBRARY_FILE $(find "$PWD/sram" -type f -name "*.lib" | sed 's/^/-liberty /' | tr '\n' ' ')"

YOSYS_DIR=$(realpath "./yosys")
YOSOS=$YOSYS_DIR/yosys

if [ $DRY_RUN -eq 1 ]; then
    if [[ $MODE == "asic" ]]; then
        echo "$YOSOS -p \"read_liberty -lib $LIBERTIES_FILES; read_verilog $VERILOG_FILES; hierarchy -check -top $TOP_MODULE; synth -top $TOP_MODULE; dfflibmap $LIBERTIES_FILES_WITH_LABEL; abc $LIBERTIES_FILES_WITH_LABEL; check; stat $LIBERTIES_FILES_WITH_LABEL\""
    elif [[ $MODE == "fpga" ]]; then
        echo "$YOSOS -p \"read_verilog $VERILOG_FILES; hierarchy -check -top $TOP_MODULE; synth_xilinx -top $TOP_MODULE -family xcup; stat\""
    fi
    exit 0
fi

if [[ ! -d "$YOSYS_DIR" ]]; then
    echo "Yosys directory not found at $YOSYS_DIR"
    git submodule update --init --recursive --progress
fi

if [[ ! -f "$YOSOS" ]]; then
    echo "Yosys executable not found. Building Yosys..."

    cd "$YOSYS_DIR"
    curl -LsSf https://astral.sh/uv/install.sh | sh > /dev/null
    make clean > /dev/null
    make -j `nproc` > /dev/null
    cd -
fi

# echo "Running Yosys ..."
if [[ $MODE == "asic" ]]; then
    YOSYS_COMMAND="$YOSOS -p \"read_liberty -lib $LIBERTIES_FILES; read_verilog $VERILOG_FILES; hierarchy -check -top $TOP_MODULE; synth -top $TOP_MODULE; dfflibmap $LIBERTIES_FILES_WITH_LABEL; abc $LIBERTIES_FILES_WITH_LABEL; check; stat $LIBERTIES_FILES_WITH_LABEL\""
elif [[ $MODE == "fpga" ]]; then
    YOSYS_COMMAND="$YOSOS -p \"read_verilog $VERILOG_FILES; hierarchy -check -top $TOP_MODULE; synth_xilinx -top $TOP_MODULE -family xcup; stat\""
else
    echo "Unknown mode: $MODE. Use --mode asic or --mode fpga."
    exit 1
fi

if [[ $VERBOSE -eq 1 ]]; then
    if [ -z "$OUTPUT_FILE" ]; then
        eval $YOSYS_COMMAND
    else
        eval $YOSYS_COMMAND | tee $OUTPUT_FILE
    fi
else
    if [ -z "$OUTPUT_FILE" ]; then
        eval $YOSYS_COMMAND > /dev/null
    else
        eval $YOSYS_COMMAND > $OUTPUT_FILE
    fi
fi
