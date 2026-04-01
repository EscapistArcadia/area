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
        *)
            echo "Unknown option: $key"
            exit 1
            ;;
    esac
done

# set -x

YOSYS_DIR=$(realpath "./yosys")
YOSOS=$YOSYS_DIR/yosys
if [[ ! -d "$YOSYS_DIR" ]]; then
    echo "Error: Yosys directory not found at $YOSYS_DIR"
    exit 1
fi

if [ $DRY_RUN -eq 1 ]; then
    echo "$YOSYS_DIR/yosys -p \"read_liberty -lib $LIBRARY_FILE; read_verilog $VERILOG_ROOT/*.v; read_verilog $VERILOG_ROOT/*/*.v; hierarchy -check -top $TOP_MODULE; synth -top $TOP_MODULE; dfflibmap -liberty $LIBRARY_FILE; abc -liberty $LIBRARY_FILE; stat -liberty $LIBRARY_FILE\""
    exit 0
fi

if [[ ! -f "$YOSOS" ]]; then
    echo "Yosys executable not found. Building Yosys..."

    cd "$YOSYS_DIR"
    curl -LsSf https://astral.sh/uv/install.sh | sh > /dev/null
    make clean > /dev/null
    make -j `nproc` > /dev/null
    cd -
fi

echo "Running Yosys ..."
if [[ $VERBOSE -eq 1 ]]; then
    if [ -z "$OUTPUT_FILE" ]; then
        $YOSYS_DIR/yosys -p "read_liberty -lib $LIBRARY_FILE; read_verilog $VERILOG_ROOT/*.v; read_verilog $VERILOG_ROOT/*/*.v; hierarchy -check -top $TOP_MODULE; synth -top $TOP_MODULE; dfflibmap -liberty $LIBRARY_FILE; abc -liberty $LIBRARY_FILE; stat -liberty $LIBRARY_FILE"
    else
        $YOSYS_DIR/yosys -p "read_liberty -lib $LIBRARY_FILE; read_verilog $VERILOG_ROOT/*.v; read_verilog $VERILOG_ROOT/*/*.v; hierarchy -check -top $TOP_MODULE; synth -top $TOP_MODULE; dfflibmap -liberty $LIBRARY_FILE; abc -liberty $LIBRARY_FILE; stat -liberty $LIBRARY_FILE" | tee $OUTPUT_FILE
    fi
else
    if [ -z "$OUTPUT_FILE" ]; then
        $YOSYS_DIR/yosys -p "read_liberty -lib $LIBRARY_FILE; read_verilog $VERILOG_ROOT/*.v; read_verilog $VERILOG_ROOT/*/*.v; hierarchy -check -top $TOP_MODULE; synth -top $TOP_MODULE; dfflibmap -liberty $LIBRARY_FILE; abc -liberty $LIBRARY_FILE; stat -liberty $LIBRARY_FILE" > /dev/null
    else
        $YOSYS_DIR/yosys -p "read_liberty -lib $LIBRARY_FILE; read_verilog $VERILOG_ROOT/*.v; read_verilog $VERILOG_ROOT/*/*.v; hierarchy -check -top $TOP_MODULE; synth -top $TOP_MODULE; dfflibmap -liberty $LIBRARY_FILE; abc -liberty $LIBRARY_FILE; stat -liberty $LIBRARY_FILE" > $OUTPUT_FILE
    fi
fi
   

