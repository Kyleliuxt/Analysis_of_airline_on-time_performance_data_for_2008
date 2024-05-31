raw_data = LOAD '/user/maria_dev/lxt/2008.csv' USING PigStorage(',')
    AS (
        year:int, month:int, day_of_month:int, day_of_week:int, dep_time:int,
        crs_dep_time:int, arr_time:int, crs_arr_time:int, unique_carrier:chararray, flight_num:int,
        tail_num:chararray, actual_elapsed_time:int, crs_elapsed_time:int, air_time:int,
        arr_delay:int, dep_delay:int, origin:chararray, dest:chararray, distance:int,
        cancelled:int, cancellation_code:chararray, diverted:int
    );

-- Filter out records with missing or irrelevant data
clean_data = FILTER raw_data BY dep_time IS NOT NULL AND arr_time IS NOT NULL;

-- Group data by day of week to find average delays
delays_by_day = GROUP clean_data BY day_of_week;
avg_delays_by_day = FOREACH delays_by_day GENERATE group AS day_of_week, AVG(clean_data.dep_delay) AS avg_dep_delay;

-- Store the average delays per day data 
STORE avg_delays_by_day INTO '/user/maria_dev/lxt/avg_delays_by_day.csv' USING PigStorage(',');

-- Example of analyzing delay by departure time
delays_by_time = GROUP clean_data BY crs_dep_time;
avg_delays_by_time = FOREACH delays_by_time GENERATE group AS dep_time, AVG(clean_data.dep_delay) AS avg_dep_delay;

-- Store the average delays by departure time data
STORE avg_delays_by_time INTO '/user/maria_dev/lxt/avg_delays_by_time.csv' USING PigStorage(',');

-- Group data by cancellation code
cancellations_by_code = GROUP clean_data BY cancellation_code;
count_cancellations = FOREACH cancellations_by_code GENERATE group AS code, COUNT(clean_data) AS total_cancellations;

-- Store cancellation statistics by code
STORE count_cancellations INTO '/user/maria_dev/lxt/cancellations_by_code.csv' USING PigStorage(',');

-- Calculate frequency of delays and cancellations for each flight
flight_problems = GROUP clean_data BY (unique_carrier, flight_num);
flight_stats = FOREACH flight_problems GENERATE group AS flight, COUNT(clean_data.cancelled) AS total_cancelled, AVG(clean_data.dep_delay) AS avg_delay;

-- Store the statistics of flight problems 
STORE flight_stats INTO '/user/maria_dev/lxt/flight_problems.csv' USING PigStorage(',');