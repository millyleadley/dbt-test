SELECT * EXCEPT (rn) from
    (
    SELECT
    * EXCEPT (supplierhistory,
        orderstatushistory),
    row_number() OVER (PARTITION BY orderid ORDER BY time DESC) rn
    FROM

    {{ source("clean_eu", "live_full_order_dedup") }}, UNNEST(supplierhistory)

    WHERE
    clientid = '{{ var("client") }}'
    AND partitiontime >= '{{ var("partition") }}'
    AND CAST(eventtime as string) >= FORMAT_DATE("%Y-%m-%d",
                            DATE_SUB(current_date, INTERVAL {{ var("period") }} DAY))
    AND CAST(createdat as string) >= FORMAT_DATE("%Y-%m-%d",
                            DATE_SUB(current_date, INTERVAL {{ var("period") }} DAY))
    )
where rn = 1