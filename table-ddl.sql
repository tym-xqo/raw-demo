create table ride (
    id integer generated always as identity primary key,
    ride_id text,
    rideable_type text,
    started_at timestamp without time zone,
    ended_at timestamp without time zone,
    start_station_name text,
    start_station_id integer,
    end_station_name text,
    end_station_id integer,
    start_lat double precision,
    start_lng double precision,
    end_lat double precision,
    end_lng double precision,
    member_casual text
);

-- Then get CSVs from https://divvy-tripdata.s3.amazonaws.com/index.html
-- and `copy` ahoy!
