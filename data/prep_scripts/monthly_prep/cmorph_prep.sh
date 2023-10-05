#!/bin/zsh

# Get the grid from target nc file
#cdo griddes data/reanalysis/global/reanalysis/ECMWF/ERA5/day/sadc/pr_day_ECMWF_ERA5_merged.nc > era5_grid

# Remap to resolution of target grid using cdo nearest neighbour

# Observations

home_dir=$( echo /Users/tiro/Google\ Drive/Academic/ATKINS/Activities/Activity_A2.1_b_CSIS/python_scripts/data )

#### CMORPH

period='day'
domain='global'
region='sadc'
for institute in NOAA-CPC; 
        do
        for dataset in CMORPH-CDR;
		do
		path_observations_regridded_day=$( echo /Volumes/tiro/atkins/activities/activity_2.1b/data/observed/${domain}/gridded/${institute}/${dataset}/day/${region} )
		path_observations_regridded=$( echo /Volumes/tiro/atkins/activities/activity_2.1b/data/observed/${domain}/gridded/${institute}/${dataset}/${period}/${region}/regridded )
		
		mkdir -p $path_observations_regridded/spi
		
		for files in $path_observations_regridded_day/pr_*era5.nc ;
			do
			cdo -L -O monsum -setattribute,pr@units=mm -chname,latitude,lat -chname,longitude,lon $files $path_observations_regridded/pr_mon_${institute}_${dataset}_merged_lonlat_era5.nc	 	
		 	ncks -C -O -x -v time_bnds $path_observations_regridded/pr_mon_${institute}_${dataset}_merged_lonlat_era5.nc $path_observations_regridded/pr_mon_${institute}_${dataset}_merged_lonlat_era5_1.nc
			cdo -L -O chname,longitude,lon -chname,latitude,lat $path_observations_regridded/pr_mon_${institute}_${dataset}_merged_lonlat_era5_1.nc $path_observations_regridded/pr_mon_${institute}_${dataset}_merged_lonlat_era5_2.nc
			mv $path_observations_regridded/pr_mon_${institute}_${dataset}_merged_lonlat_era5_2.nc $path_observations_regridded/pr_mon_${institute}_${dataset}_merged_lonlat_era5_1.nc
			ncpdq -O -a lat,lon,time $path_observations_regridded/pr_mon_${institute}_${dataset}_merged_lonlat_era5_1.nc $path_observations_regridded/pr_mon_${institute}_${dataset}_merged_lonlat_era5_2.nc
			mv $path_observations_regridded/pr_mon_${institute}_${dataset}_merged_lonlat_era5_2.nc $path_observations_regridded/pr_mon_${institute}_${dataset}_merged_lonlat_era5_1.nc
		 	ncks -O --fix_rec_dmn lat $path_observations_regridded/pr_mon_${institute}_${dataset}_merged_lonlat_era5_1.nc $path_observations_regridded/pr_mon_${institute}_${dataset}_merged_lonlat_era5_2.nc
		 	mv $path_observations_regridded/pr_mon_${institute}_${dataset}_merged_lonlat_era5_2.nc $path_observations_regridded/pr_mon_${institute}_${dataset}_merged_lonlat_era5_1.nc
			ncks -O --mk_rec_dmn time $path_observations_regridded/pr_mon_${institute}_${dataset}_merged_lonlat_era5_1.nc $path_observations_regridded/pr_mon_${institute}_${dataset}_merged_lonlat_era5_2.nc
			mv $path_observations_regridded/pr_mon_${institute}_${dataset}_merged_lonlat_era5_2.nc $path_observations_regridded/pr_mon_${institute}_${dataset}_merged_lonlat_era5_1.nc
			
			rm $path_observations_regridded/spi/*.nc			
			spi --periodicity monthly --scales 1 3 6 --calibration_start_year 1991 --calibration_end_year 2020 --netcdf_precip $path_observations_regridded/pr_mon_${institute}_${dataset}_merged_lonlat_era5_1.nc --var_name_precip pr --output_file_base $path_observations_regridded/spi/${institute}_${dataset} --multiprocessing all
		 	
			for spi_file in $path_observations_regridded/spi/*.nc;
				do

		 		ncpdq -O -a time,lat,lon $spi_file $path_observations_regridded/spi/`basename $spi_file .nc`_1.nc
				ncks -O --mk_rec_dmn time $path_observations_regridded/spi/`basename $spi_file .nc`_1.nc $path_observations_regridded/spi/`basename $spi_file .nc`.nc
				rm $path_observations_regridded/spi/`basename $spi_file .nc`_1.nc
			done 
		 	
		 done
		 
		 #cd $home_dir
	 done
done

