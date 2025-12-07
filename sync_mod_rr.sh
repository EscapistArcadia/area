rm -rf ./gemm_sm_rr_mod/gemm_sm_rtl.v
rm -rf ./gemm_sm_rr_mod/v_rtl
scp    shanboz2@denali.cs.illinois.edu:/scratch/shanboz2/esp_accel/accelerators/stratus_hls/gemm_sm_stratus/hw/hls-work-virtexup/bdw_work/modules/gemm_sm/BASIC_DMA64_RR/gemm_sm_rtl.v ./gemm_sm_rr_mod/gemm_sm_rtl.v
scp -r shanboz2@denali.cs.illinois.edu:/scratch/shanboz2/esp_accel/accelerators/stratus_hls/gemm_sm_stratus/hw/hls-work-virtexup/bdw_work/modules/gemm_sm/BASIC_DMA64_RR/v_rtl ./gemm_sm_rr_mod/v_rtl

./area.sh -l ./OpenROAD/TimerCalibration/Free45PDK/gscl45nm.lib -v ./gemm_sm_rr_mod/ -t gemm_sm -o gemm_sm_rr_mod.log