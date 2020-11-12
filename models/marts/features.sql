{{ config(materialized='table', sort='supplierid') }}

WITH

repeat_customer as (
    SELECT * FROM {{ ref("repeat_customer") }}
),

repeat_item as (
    SELECT * FROM {{ ref("repeat_item") }}
)

SELECT
repeat_customer.*,
repeat_item.* EXCEPT(supplierid)

FROM repeat_customer
LEFT JOIN repeat_item
USING (supplierid)

