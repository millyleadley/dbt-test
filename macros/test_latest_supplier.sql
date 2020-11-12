{% macro test_latest_supplier(model, column_name) %}
-- gets all the suppliers that are assigned to an order earlier on and ensures
-- they are not in the results

WITH
earlier_suppliers as (
  SELECT * FROM (
      SELECT
      orderid,
      supplierid,
      time,
      ROW_NUMBER() over (partition by orderid order by time desc) as rn
      FROM
        {{ ref("live_full_order_dedup") }}, UNNEST(supplierhistory)
  )
  where rn > 1
),

actual_suppliers as (
  SELECT * FROM {{ model }}
),

errors as (
  SELECT * FROM
  earlier_suppliers INNER JOIN actual_suppliers
  USING (supplierid, orderid)
)

SELECT count(*) from errors


{% endmacro %}