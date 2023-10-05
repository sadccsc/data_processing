#!/bin/zsh

# Get the grid from target nc file
#cdo griddes data/reanalysis/global/reanalysis/ECMWF/ERA5/day/sadc/pr_day_ECMWF_ERA5_merged.nc > era5_grid

# Remap to resolution of target grid using cdo nearest neighbour

# Observations

home_dir=$( echo /Users/tiro/Google\ Drive/Academic/ATKINS/Activities/Activity_A2.1_b_CSIS/python_scripts/data )

#### CHIRPS

period=$( echo 'day')
domain=$( echo 'global' )
region=$( echo 'sadc')
for institute in CHC ; 
	do
	for dataset in  CHIRPS-2.0-0p25;
		do
		path_observations_native=$( echo data/observed/${domain}/gridded/${institute}/${dataset}/${period}/${region} )
		path_observations_regridded=$( echo data/observed/${domain}/gridded/${institute}/${dataset}/${period}/${region}/regridded )
		
		mkdir -p $path_observations_regridded/temp
		
		for files in $path_observations_native/pr_*merged.nc ;
			do
			#cdo -L -O mulc,86400  -setattribute,pr@units=mm/dy $path_observations_native/`basename $files .nc`.nc  $path_observations_native/`basename $files .nc`_mm.nc
			#cdo setattribute,pr@units=mm/dy  $path_observations_native/`basename $files .nc`.nc  $path_observations_native/`basename $files .nc`_mmdy.nc
		 	#cdo remapbil,'era5_grid' $path_observations_native/`basename $files .nc`_mm.nc $path_observations_regridded/`basename $files .nc`_lonlat_era5.nc
	 	done 
	 	
	 	cd $path_observations_regridded
	 	
	 	for index in eca_cdd eca_r99p eca_cwd eca_rx5day  eca_rx1day;
	 		do
		 	for year in {1980..1985};
		 		do
		 		#cdo -L -O $index -selyear,$year pr_day_${institute}_${dataset}_merged_lonlat_era5.nc temp/${index}_${institute}_${dataset}_${year}_merged_lonlat_era5.nc	
		 	done
		 	#cdo -L mergetime  temp/${index}_${institute}_${dataset}_*_merged_lonlat_era5.nc ${index}_${institute}_${dataset}_all_merged_lonlat_era5.nc
		 	#rm  temp/${index}_${institute}_${dataset}_*_merged_lonlat_era5.nc
		 done
		 cd $home_dir
	 done
done


#### TAMSAT

period=$( echo 'day')
domain=$( echo 'africa' )
region=$( echo 'sadc')
for institute in TAMSAT ; 
	do
	for dataset in  RFE-filled-V3.1;
		do
		path_observations_native=$( echo /Volumes/tiro/PhD/data/Gridded_Observations/pr/TAMSAT/regridded )
		path_observations_regridded=$( echo data/observed/${domain}/gridded/${institute}/${dataset}/${period}/${region}/regridded )
		
		mkdir -p $path_observations_regridded/temp
		
		for files in $path_observations_native/pr_*era5.nc ;
			do
		 	#cdo -L -O mulc,86400  -setattribute,pr@units=mm/dy $path_observations_native/`basename $files .nc`.nc  $path_observations_regridded/`basename $files .nc`_mm.nc
	 	done 
	 	
	 	cd $path_observations_regridded
	 	
	 	#cdo mergetime pr_day_${institute}_${dataset}_*1231*_lonlat_era5_mm.nc pr_day_${institute}_${dataset}_merged_lonlat_era5.nc
	 	
	 	## Compute Annual Climatology
	 	cdo -L -O yearsum -setattribute,pr@units=mm/yy  pr_day_${institute}_${dataset}_merged_lonlat_era5.nc  pr_day_${institute}_${dataset}_merged_lonlat_era5_ann.nc
	 	cdo -L -O timmean -selyear,1991/2020  pr_day_${institute}_${dataset}_merged_lonlat_era5_ann.nc pr_day_${institute}_${dataset}_merged_lonlat_era5_1991_2020_ann_clim.nc
	 	
	 	## Compute Seasonal Climatology
	 	cdo -L -O seassum -setattribute,pr@units=mm/seas pr_day_${institute}_${dataset}_merged_lonlat_era5.nc  pr_day_${institute}_${dataset}_merged_lonlat_era5_seas.nc
	 	cdo -L -O timmean -selyear,1991/2020  pr_day_${institute}_${dataset}_merged_lonlat_era5_seas.nc pr_day_${institute}_${dataset}_merged_lonlat_era5_1991_2020_seas_clim.nc
	 	
	 	cdo -L -O selseas,DJF pr_day_${institute}_${dataset}_merged_lonlat_era5_seas.nc  pr_day_${institute}_${dataset}_merged_lonlat_era5_DJF.nc
	 	cdo -L -O selseas,MAM pr_day_${institute}_${dataset}_merged_lonlat_era5_seas.nc  pr_day_${institute}_${dataset}_merged_lonlat_era5_MAM.nc
	 	cdo -L -O selseas,JJA pr_day_${institute}_${dataset}_merged_lonlat_era5_seas.nc  pr_day_${institute}_${dataset}_merged_lonlat_era5_JJA.nc
	 	cdo -L -O selseas,OND pr_day_${institute}_${dataset}_merged_lonlat_era5_seas.nc  pr_day_${institute}_${dataset}_merged_lonlat_era5_OND.nc
	 	
	 	## Compute climatological extremes
	 	cdo -L -O ydaypctl,99 -selyear,1991/2020  pr_day_${institute}_${dataset}_merged_lonlat_era5.nc -ydaymin  pr_day_${institute}_${dataset}_merged_lonlat_era5.nc -ydaymax  pr_day_${institute}_${dataset}_merged_lonlat_era5.nc  indices/pr_day_${institute}_${dataset}_merged_lonlat_era5_1991_2020_99p.nc
	 	cdo -L -O ydaypctl,99 -selyear,1991/2020  pr_day_${institute}_${dataset}_merged_lonlat_era5.nc -ydaymin  pr_day_${institute}_${dataset}_merged_lonlat_era5.nc -ydaymax  pr_day_${institute}_${dataset}_merged_lonlat_era5.nc  indices/pr_day_${institute}_${dataset}_merged_lonlat_era5_1991_2020_95p.nc
	 	
	 	#rm pr_day_${institute}_${dataset}_*1231*_lonlat_era5_mm.nc
	 	
	 	#rm eca* 
	 	mkdir indices
	 	
	 	#for index in eca_cdd eca_cwd eca_rx5day  eca_rx1day;
	 	for index in eca_cdd;
	 		do
		 	for year in {1980..2022};
		 		do
		 		cdo -L -O $index -selyear,$year pr_day_${institute}_${dataset}_merged_lonlat_era5.nc temp/${index}_${institute}_${dataset}_${year}_merged_lonlat_era5.nc
		 		
		 		cdo -L -O select,season=SOND -selyear,$year pr_day_${institute}_${dataset}_merged_lonlat_era5.nc temp/tempfile_1a.nc
		 		cdo -L -O select,season=JFMA -selyear,$(($year + 1 )) pr_day_${institute}_${dataset}_merged_lonlat_era5.nc temp/tempfile_2a.nc
		 		cdo -L -O mergetime temp/tempfile_*a.nc temp/tempfile_merged.nc
		 		cdo -L -O $index temp/tempfile_merged.nc temp/${index}_${institute}_${dataset}_${year}_merged_lonlat_era5_seas.nc
		 		#rm  temp/*	
		 	done
		 	cdo -L -O mergetime  temp/${index}_${institute}_${dataset}_*_merged_lonlat_era5.nc indices/${index}_${institute}_${dataset}_all_merged_lonlat_era5.nc
		 	cdo -L -O mergetime  temp/${index}_${institute}_${dataset}_*_merged_lonlat_era5_seas.nc indices/${index}_${institute}_${dataset}_all_merged_lonlat_era5_seas.nc

		 	rm  temp/*
		 done
		 
		 for pctl in 99 95;
		 do 
			 for index in eca_r${pctl}p;
		 		do
			 	for year in {1983..2022};
			 		do
			 		cdo -L -O $index -selyear,$year  pr_day_${institute}_${dataset}_merged_lonlat_era5.nc  indices/pr_day_${institute}_${dataset}_merged_lonlat_era5_1991_2020_${pctl}p.nc temp/${index}_${institute}_${dataset}_${year}_merged_lonlat_era5.nc
			 		
			 	done
			 	cdo -L -O mergetime  temp/${index}_${institute}_${dataset}_*_merged_lonlat_era5.nc indices/${index}_${institute}_${dataset}_all_merged_lonlat_era5.nc
			 	rm  temp/*
			 done
		 done
		 
		 cd $home_dir
	 done
done



#### CMORPH

period='day'
domain='global'
region='sadc'
for institute in NOAA_CPC; 
	do
	for dataset in CMORPH-CDR;
		do

	 done
done
	 		
