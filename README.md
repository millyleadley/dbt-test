# Using DBT to create features for machine learning

## What
An example of how we might make feature queries written in SQL easier to read, better documented and testable.
I have created fictious order + item data related to 40 orders, as per `mock_dbt_data.ipynb`. Then uplodaed
these as tables into an empty project associated with my gmail. A service account connects this google project
with this dbt project, so the queries in this repo are testable on my local.

## Project structure
This project structure was created when dbt was initialised (ignore `analysis/`, `data/`, `snapshots/`, `tests/` which were not used).
`models/` contains all the .sql files that do transformations:
* Models in `models/staging` are 1:1 with the source tables and do basic cleaning and filtering (ie. get data for the particular client over particular days) for each source table.
* Models in `models/marts` select from staging models and calculate business logic. I have created a sub folder `intermediate/` to hold intermediate transformations. `features.sql` represents the model that joins all
the features from the intermediate sub queries.
* `schema.yml` files accompany models in these directories, and contain descriptions for each model along with the necessary tests that should be called.
The naming is consistent with how dbt names their project but in reality is flexible, more info here: https://discourse.getdbt.com/t/how-we-structure-our-dbt-projects/355

## What example am I showing
In the supplier pipeline we calculate a number of features about a supplier. Each subquery aggrgeates a bunch of statistics about a supplier, which we join at the end. We have `repeat_customer` features that describe how often a supplier re-delivers to their customers, and `repeat_item` features that describe how often a supplier re-delivers the same items.
Here I have shown the queries & structure we require to a) clean the order + item source tables, b) calculate the `repeat_customer` and `repeat_item` intermediate subqueries, c) join the results into a feature struct.

## Functionality I want to showcase
1. Under the `models` section in `dbt_project.yml`, I have declared that all query results should be expressed as views in bigquery, but the feature struct should be created as a table. In reality we'd probably want all the models apart from `features` to be materialised as `empheral` which means they aren't built into the database (its unlikely we'd ever need to query them). See figure 1.
2. Under the `vars` section in `dbt_project.yml`, I have declared the variables we want to format the jinja templates with, but these could also be called from the command line.
3. In `models/staging/schema.yml` we define the source tables (containing mock data) that exist in the project. We also define some tests for the two staging tables; that the primary key of `stg_orders` and `stg_items` is unique and non-null. I've included an example of a custom test called `latest_supplier` built for `stg_orders`, which can be found in `macros/test_latest_supplier.sql`; it will return the number of rows that fail the test, so a result of 0 means the test passes.
4. The `description` fields in all the schema yamls means that when we generate documentation each model / column can include a human readable string to explain it. See figure 2 and 3.

![bq structure](/images/bq_structure.png)
**Figure 1:** In the bq project, data was uploaded into the `clean_eu` dataset and models are materialised into the `dbt_milly` dataset.

![dbt documentation](/images/dbt_documentation.png)
**Figure 2:** The html documentation that is produced when `dbt docs generate` is followed by `dbt docs serve`.

![dbt lineage graph](/images/dbt_lineage_graph.png)
**Figure 3:** The lineage graph that is produced in the documentation. Green blocks indicate source tables and the purple block indicates the final "mart" model. To calculate all features, we'd expect there to be about 8 entity source tables to start with, the same number of staging models, then many (30+) intermediate models which are combined into the final `features` model.

## Usage
This repo cannot be ran locally without the necessary dbt user credentials on disk, but the main two "jobs" for dbt are `run` (materialise all the models in your warehouse) and `test` (check that the materialised models fulfill some criteria). See figure 4 and 5 for what local outputs look like.

![dbt run](/images/dbt_run.png)
**Figure 4:** Output of `dbt run`.

![dbt test](/images/dbt_test.png)
**Figure 5:** Output of `dbt test`.

In a real life scenario, these two jobs can be scheduled via dbt cloud, which connects to bigquery and the dbt repository, so updated code and data will be used every time a `run` or `test` job is due to take place. However for feature generation, we might not require scheduled jobs and just use dbt to build our feature queries offline whenever we run a pipeline.

