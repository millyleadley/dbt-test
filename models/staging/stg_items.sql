SELECT * FROM

{{ source("clean_eu", "live_full_item_dedup")}}

WHERE clientid = '{{ var("client") }}'
AND partitiontime >= '{{ var("partition") }}'