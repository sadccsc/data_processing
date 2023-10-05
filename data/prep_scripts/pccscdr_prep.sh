#!/bin/zsh

# Get the grid from target nc file
#cdo griddes data/reanalysis/global/reanalysis/ECMWF/ERA5/day/sadc/pr_day_ECMWF_ERA5_merged.nc > era5_grid

# Remap to resolution of target grid using cdo nearest neighbour

# Observations

home_dir=$( echo /Users/tiro/Google\ Drive/Academic/ATKINS/Activities/Activity_A2.1_b_CSIS/python_scripts/data )

#### persiann

period=$( echo 'day')
domain=$( echo 'global' )
region=$( echo 'sadc')
for institute in persiann ; 
	do
	for dataset in  PCCSCDR;
		do
		#path_observations_native_1=$( echo ../data/MSWEP_V280/Past/Daily/ )
		#path_observations_native_2=$( echo ../data/MSWEP_V280/NRT/Daily/ )
		path_observations_native=$( echo /Volumes/tiro/atkins/activities/activity_2.1b/data/observed/${domain}/gridded/${institute}/${dataset}/${period}/${region}/regridded )
		path_observations_regridded_1=$( echo ../data/observed/${domain}/gridded/${institute}/${dataset}/${period}/${region}/regridded )
		path_observations_regridded=$( echo /Volumes/tiro/atkins/activities/activity_2.1b/data/observed/${domain}/gridded/${institute}/${dataset}/${period}/${region}/regridded )
		
		rm -rf $path_observations_regridded_1
		mkdir -p $path_observations_regridded/temp
		
		test_file=$( echo $path_observations_regridded/indices/eca_r95ptot_${institute}_${dataset}_all_merged_lonlat_era5.nc )
		if [ -f '$test_file' ]; then
			echo '$test_file exists. -- Skipping to the next dataset'
			return
		fi

		
		for year in {1996..2023} ;
			do
			for month in 0{1..9} 1{0..2} ;
				do
				for day in 0{1..9} 1{0..9} 2{0..9} 3{0..1} ;
					do
					wget -c -O  $path_observations_native/PCCSCDR1d${year}${month}${day}.nc https://persiann.eng.uci.edu/CHRSdata/PCCSCDR/ncfiles/daily/PCCSCDR1d${year}${month}${day}.nc
					cdo -L -O sellonlatbox,5,58,-36,8  $path_observations_native/PCCSCDR1d${year}${month}${day}.nc   $path_observations_native/`basename PCCSCDR1d${year}${month}${day}.nc .nc`_SA.nc
					rm  $path_observations_native/PCCSCDR1d${year}${month}${day}.nc
					cdo remapbil,'era5_grid' $path_observations_native/`basename PCCSCDR1d${year}${month}${day}.nc .nc`_SA.nc $path_observations_regridded/`basename PCCSCDR1d${year}${month}${day}.nc .nc`_lonlat_era5.nc
				done
			done
			cdo -L -O mergetime  $path_observations_regridded/*${year}*_lonlat_era5.nc $path_observations_regridded/combined/${year}_${institute}_${dataset}_lonlat_era5.nc
			cdo -L -O mergetime  $path_observations_regridded/*${year}*_SA.nc  $path_observations_regridded/combined/${year}_${institute}_${dataset}_SA_native.nc
			rm $path_observations_regridded/PCC*${year}*_lonlat_era5.nc
			rm $path_observations_regridded/PCC*${year}*_SA.nc
		done 
		
		#rm $path_observations_regridded/{1979..2020}{0..3}{0..5}{1..9}_lonlat_era5.nc
		
		cdo -L -O mergetime  $path_observations_regridded/combined/*_${institute}_${dataset}_lonlat_era5.nc  $path_observations_regridded/pr_day_${institute}_${dataset}_merged_lonlat_era5.nc
		
		#rm $path_observations_regridded/{1979..2020}{0..3}{0..5}{1..9}_SA.nc
		#rm $path_observations_regridded/{1979..2020}{0..3}{0..5}{1..9}_lonlat_era5.nc
		
		#for files in $path_observations_native_1/pr_*era5.nc ;
		#	do
		# 	cdo -L -O mulc,86400  -setattribute,pr@units=mm/dy $path_observations_native/`basename $files .nc`.nc  $path_observations_regridded/`basename $files .nc`_mm.nc
	 	#done 
	 	
	 	cd $path_observations_regridded
	 	
	 #	cdo mergetime pr_day_${institute}_${dataset}_*1231*_lonlat_era5_mm.nc pr_day_${institute}_${dataset}_merged_lonlat_era5.nc
	 	
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
	 	cdo -L -O ydaypctl,95 -selyear,1991/2020  pr_day_${institute}_${dataset}_merged_lonlat_era5.nc -ydaymin  pr_day_${institute}_${dataset}_merged_lonlat_era5.nc -ydaymax  pr_day_${institute}_${dataset}_merged_lonlat_era5.nc  indices/pr_day_${institute}_${dataset}_merged_lonlat_era5_1991_2020_95p.nc
	 	
	 	#rm pr_day_${institute}_${dataset}_*1231*_lonlat_era5_mm.nc
	 	
	 	#rm eca* 
	 	mkdir indices
	 	
	 	for index in eca_cdd eca_cwd eca_rx5day  eca_rx1day eca_rr1 eca_r20mm;
	 	#for index in eca_cdd;
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
			 for index in eca_r${pctl}p  eca_r${pctl}ptot;
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

