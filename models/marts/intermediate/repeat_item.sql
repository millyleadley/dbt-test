SELECT
    supplierid,
    MAX(sameItemCount) AS maxOrdersWSameItem,
    CASE WHEN max(sameItemCount) > 1 THEN
    safe_divide(max(sameItemCount), count(*))
        ELSE 0 END AS pctOrdersWSameItem,
    CASE WHEN MAX(orderexamples) IS not NULL THEN STRING_AGG(orderexamples, ', ' LIMIT {{ var("limit") }})
    ELSE "" END as examplesRepeatItem
    FROM (
        SELECT
            o.supplierid,
            i.name,
            COUNT(distinct CASE WHEN i.name is not null THEN o.orderId ELSE "" END) as sameItemCount,
            CASE WHEN (count(distinct o.orderid) > 1 AND i.name is not null) THEN
            CONCAT(i.name, ": [", STRING_AGG(o.orderid, ', ' LIMIT {{ var("limit") }}), "]")
            eLSE NULL END AS orderexamples

        FROM
            {{ ref("stg_orders") }} o
        LEFT JOIN
            {{ ref("stg_items") }} i

        ON i.orderid = o.orderid
        AND i.customerid = o.customerid
        WHERE o.supplierid IS NOT NULL
        GROUP BY 1,2
        )
    GROUP BY
    1