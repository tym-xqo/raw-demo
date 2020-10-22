select count(1) as total_rides
     , avg(extract('epoch' from age(ended_at, started_at))) as average_ride_time
     , max(extract('epoch' from age(ended_at, started_at))) as longest_ride_time
     , rideable_type
     , date_trunc('day', started_at)::text as trip_date
  from ride
{% if type %}
 where rideable_type = :type
{% endif %}
 group by rideable_type
        , trip_date
 order by trip_date;
