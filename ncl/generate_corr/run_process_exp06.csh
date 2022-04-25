#!/bin/csh
#SBATCH -A e3sm
#SBATCH -q slurm
#SBATCH -t 12:00:00
#SBATCH -N 1
#SBATCH  --job-name=nudge

  set BASE_DIR = "/compyfs/zhan391/darpa_scratch/post_process/data"
  set models   = ( "NDGT" )
  set lenm     = $#models

  set var      = ("U" "V" "T" "Q" "OMEGA" \
                  "OLR" "OLR" "OLR" \
                  "PRECT" "PRECT" "PRECT")
  set lenv     = $#var

  set obdat    = ("ERA5" "ERA5" "ERA5" "ERA5" "ERA5" \
                  "ERA5" "NOAA_AVHRR" "NOAA_HIRS" \
                  "ERA5" "GPCP" "TRMM")
  set leno     = $#obdat

  set plevs    = (1000 925 850 700 600 500 400 300 250 200 150 100 70 50 30 20 10)
  set lenp     = $#plevs

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
 
    foreach j (`seq 1 1 $lenv`)

      setenv OBS_NAME $obdat[$j]
      setenv VAR      $var[$j]
      
      if ( $VAR == "OLR" ) then
        setenv PLEV 1000
        ncl make_sac.ncl & 
        ncl make_sac_3regions.ncl & 
        ncl make_tac.ncl
      else if ( $VAR == "PRECT" ) then
        setenv PLEV 1000
        ncl make_sac.ncl & 
        ncl make_sac_3regions.ncl & 
        ncl make_tac.ncl
      else
        foreach k (`seq 1 1 $lenp`)
          setenv PLEV $plevs[$k]
          ncl make_sac.ncl & 
          ncl make_sac_3regions.ncl & 
          ncl make_tac.ncl
        end
      endif

    end 

    echo "Calculate ACC done..."

  end 

