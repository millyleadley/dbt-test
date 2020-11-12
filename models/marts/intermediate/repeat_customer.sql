SELECT
  supplierid,
  max(customercount) as maxOrdersWSameCustomer,
  avg(customercount) as avgOrdersWSameCustomer,
  sum(case when customercount > 1 then 1 else 0 end) as nRepeatCustomers,
  COALESCE(safe_divide(sum(case when customercount > 1 then 1 else 0 end),
      COUNT(DISTINCT customerid)), 0) as pctRepeatCustomers,
  CASE WHEN MAX(orderexamples) IS not NULL THEN STRING_AGG(orderexamples, ', ' LIMIT {{ var("limit") }})
    ELSE "" END as examplesRepeatCustomer

      FROM
      --- count number of times each supplier-customer pair have ever ordered together
        (SELECT
        o.supplierid,
        o.customerid,
        count(distinct o.orderid) as customercount,
        CASE WHEN count(distinct o.orderid) > 1 THEN
            CONCAT(o.customerid, ": [", STRING_AGG(orderid, ', ' LIMIT {{ var("limit") }}), "]")
            eLSE NULL END AS orderexamples

        FROM

        {{ ref("stg_orders") }} o

        WHERE o.supplierid is not null
        GROUP BY
        1,2)

      GROUP BY 1