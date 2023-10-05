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
		path_observations_native=$( echo /Volumes/nkemelang/atkins/activities/activity_2.1b/data/observed/${domain}/gridded/${institute}/${dataset}/${period}/${region}/native )
    path_observations_regridded=$( echo /Volumes/nkemelang/atkins/activities/activity_2.1b/data/observed/${domain}/gridded/${institute}/${dataset}/${period}/${region}/regridded )

		path_observations_native_monthly=$( echo /Volumes/nkemelang/atkins/activities/activity_2.1b/data/observed/${domain}/gridded/${institute}/${dataset}/mon/${region}/native )
		path_observations_regridded_monthly=$( echo /Volumes/nkemelang/atkins/activities/activity_2.1b/data/observed/${domain}/gridded/${institute}/${dataset}/mon/${region}/regridded )

		mkdir -p $path_observations_native/temp
		mkdir -p $path_observations_native_monthly/temp
		mkdir -p $path_observations_regridded/temp
		mkdir -p $path_observations_regridded_monthly/temp

		# Get the latest file for the current year

		for year in {1981..2022} ;
			do
				URL=$( echo https://data.chc.ucsb.edu/products/CHIRPS-2.0/global_daily/netcdf/p25/chirps-v2.0.${year}.days_p25.nc )
				wget -c -O  $path_observations_native/temp/chirps-v2.0.${year}.days_p25.nc $URL
				cdo -L -O sellonlatbox,5,55,-36,8 -chname,precip,pr $path_observations_native/temp/chirps-v2.0.${year}.days_p25.nc  $path_observations_native/temp/`basename chirps-v2.0.${year}.days_p25.nc .nc`_SA_1.nc
				ncatted -O -a units,time,o,c,'days since 1980-1-1 12:00:00' $path_observations_native/temp/`basename chirps-v2.0.${year}.days_p25.nc .nc`_SA_1.nc $path_observations_native/temp/`basename chirps-v2.0.${year}.days_p25.nc .nc`_SA.nc
				rm $path_observations_native/temp/`basename chirps-v2.0.${year}.days_p25.nc .nc`_SA_1.nc $path_observations_native/temp/chirps-v2.0.${year}.days_p25.nc
		done

		cdo -L -O mergetime $path_observations_native/temp/`basename chirps-v2.0.${year}.days_p25.nc .nc`_SA.nc $path_observations_native/pr_day_${institute}_${dataset}_merged_new.nc

		this_year=$(date +'%Y' )
		last_year=$((this_year-1 ))
		URL=$( echo https://data.chc.ucsb.edu/products/CHIRPS-2.0/global_daily/netcdf/p25/chirps-v2.0.${this_year}.days_p25.nc )

		wget -c -O  $path_observations_native/temp/chirps-v2.0.${this_year}.days_p25.nc $URL
		cdo -L -O sellonlatbox,5,55,-36,8 -chname,precip,pr $path_observations_native/temp/chirps-v2.0.${this_year}.days_p25.nc  $path_observations_native/temp/`basename chirps-v2.0.${this_year}.days_p25.nc .nc`_SA_1.nc

		previous_file=$( echo $path_observations_native/pr_day_${institute}_${dataset}_merged_new.nc )

		#cdo griddes $previous_file > $path_observations_native/native_grid

		grid_file=$( echo $path_observations_native/native_grid )

		cdo remapbil,$grid_file $path_observations_native/temp/`basename chirps-v2.0.${this_year}.days_p25.nc .nc`_SA_1.nc $path_observations_native/temp/`basename chirps-v2.0.${this_year}.days_p25.nc .nc`_SA.nc
		ncatted -O -a units,time,o,c,'days since 1980-1-1 12:00:00' $path_observations_native/temp/`basename chirps-v2.0.${this_year}.days_p25.nc .nc`_SA.nc $path_observations_native/temp/`basename chirps-v2.0.${this_year}.days_p25.nc .nc`_SA_1.nc

		mv $path_observations_native/temp/`basename chirps-v2.0.${this_year}.days_p25.nc .nc`_SA_1.nc $path_observations_native/temp/`basename chirps-v2.0.${this_year}.days_p25.nc .nc`_SA.nc

		cdo -L -O selyear,1981/${last_year} $previous_file $path_observations_native/temp/pr_day_${institute}_${dataset}_merged_last.nc
		previous_file_2=$( echo $path_observations_native/temp/pr_day_${institute}_${dataset}_merged_last.nc )

		cdo -L -O mulc,86400 -setattribute,pr@units=mm/day ${previous_file_2} $path_observations_native/temp/pr_day_${institute}_${dataset}_merged_last_1.nc

		mv $path_observations_native/temp/pr_day_${institute}_${dataset}_merged_last_1.nc ${previous_file_2}

		ncks -C -O -x -v time_bnds ${previous_file_2} $path_observations_native/temp/pr_day_${institute}_${dataset}_merged_last_1.nc

		mv $path_observations_native/temp/pr_day_${institute}_${dataset}_merged_last_1.nc ${previous_file_2}

		cdo -L -O mergetime ${previous_file_2} $path_observations_native/temp/`basename chirps-v2.0.${this_year}.days_p25.nc .nc`_SA.nc $path_observations_native/pr_day_${institute}_${dataset}_merged_latest.nc

		ncrename -O -d longitude,lon -d latitude,lat $path_observations_native/pr_day_${institute}_${dataset}_merged_latest.nc $path_observations_native/pr_day_${institute}_${dataset}_merged_latest2.nc
		mv $path_observations_native/pr_day_${institute}_${dataset}_merged_latest2.nc $path_observations_native/pr_day_${institute}_${dataset}_merged_latest.nc
		#rm $path_observations_native/temp/`basename chirps-v2.0.${this_year}.days_p25.nc .nc`_SA*.nc ${previous_file_2}

		cdo -L -O monsum $path_observations_native/pr_day_${institute}_${dataset}_merged_latest.nc $path_observations_native_monthly/pr_mon_${institute}_${dataset}_merged.nc
		#cdo remapbil,$grid_file $path_observations_native_monthly/pr_mon_${institute}_${dataset}_merged_1.nc $path_observations_native_monthly/pr_mon_${institute}_${dataset}_merged.nc

	 done
done
