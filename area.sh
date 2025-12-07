#!/usr/bin/env bash

if [ $# -lt 1 ]; then
    echo "Usage: $0 <area>"
    exit 1
fi

while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -l|--library)
            LIBRARY_FILE=$(realpath "$2")
            shift 2
            ;;
        -v|--verilog)
            VERILOG_FILE=$(realpath "$2")
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
        *)
            echo "Unknown option: $key"
            exit 1
            ;;
    esac
done

# set -x

yosys -p "read_liberty -lib $LIBRARY_FILE; read_verilog $VERILOG_FILE/*.v; read_verilog $VERILOG_FILE/*/*.v; hierarchy -check -top $TOP_MODULE; synth -top $TOP_MODULE; dfflibmap -liberty $LIBRARY_FILE; abc -liberty $LIBRARY_FILE; stat -liberty $LIBRARY_FILE" | tee $OUTPUT_FILE
