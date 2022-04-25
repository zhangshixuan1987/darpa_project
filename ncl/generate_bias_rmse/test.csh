#!/bin/csh

  set BASE_DIR = "/compyfs/zhan391/darpa_scratch/post_process/data"
  set models   = ( "NONDG" )
  set lenm     = $#models

  set var      = ("CLDTOT" "LWP" "IWP" "PRECL" "PRECC" "PSL" "STRESS_MAG" \
                  "TREFHT" "TS" "U200" "U500" "U850" "Z500" \
                  "LHFLX" "SHFLX" "PRECT" "TMQ" "AODVIS" \
                  "FLNT" "FSNT" "FNET" "NETCF" "LWCF" "SWCF" \
                  "FLUT" "FLDS" "FLNS" "FLUTC" "FLNTC" "FSNS" "FSNTOAC")
  set lenv     = $#var

  set obdat    = ("ERA5" "ERA5" "ERA5" "ERA5" "ERA5" "ERA5" "ERA5" \
                  "ERA5" "ERA5" "ERA5" "ERA5" "ERA5" "ERA5" \
                  "ERA5" "ERA5" "GPCP" "REMSS"  "ERA5" \
                  "CERES_EBAF" "CERES_EBAF" "CERES_EBAF" "CERES_EBAF" "CERES_EBAF" "CERES_EBAF" \
                  "CERES_EBAF" "CERES_EBAF" "CERES_EBAF" "CERES_EBAF" "CERES_EBAF" "CERES_EBAF" "CERES_EBAF" )
  set leno     = $#obdat

  set outdir = "./output" 
  if( ! -d $outdir ) then
    mkdir -p  $outdir
  endif

  foreach i (`seq 1 1 $lenm`)

    setenv MODEL_NAME $models[$i]
    setenv INPUT      $BASE_DIR
    setenv model      $models[$i]
    setenv yst        "200912"
    setenv yed        "201002"
 
    set outfile = "${outdir}/${MODEL_NAME}_clim_output.txt" 
    rm -rvf ${outfile}

    foreach j (`seq 1 1 $lenv`)
      setenv OBS_NAME $obdat[$j]
      setenv VAR      $var[$j]
      ncl 2D_CLIM_RMSE_CORR_CALC.ncl
    end

    echo "Calculate climo mean done..."

  end 

