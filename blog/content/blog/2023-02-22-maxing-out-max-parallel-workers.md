+++
title = "Maxing out max_parallel_workers in Postgres"
[taxonomies]
tags = [ "Postgres" ]
+++

There are a number of articles which discuss how to force the postgres query planner into a certain amount of parallelism ([1], [2]). Today I was trying to get a query to run with up to 64 parallel workers (for reasons), but ran into something which the other articles didn't mention explicitly.

To recap, there are a number of postgres parameters which affect parallelism:
- [`max_worker_processes`](https://postgresqlco.nf/doc/en/param/max_worker_processes/): A server-wide limit on the number of processes which can be created for parallelism. This must be configured in `postgresql.conf`, and requires a restart to be applied.
- [`max_parallel_workers`](https://postgresqlco.nf/doc/en/param/max_parallel_workers/): This is a global limit on how much parallelism is possible in the database system at once (across all simultaneously-executing queries).
- [`max_parallel_workers_per_gather`](https://postgresqlco.nf/doc/en/param/max_parallel_workers_per_gather/): This effectively sets an upper limit on parallelism per query (this is probably not entirely correct - presumably it's possible to have multiple gathers running in parallel, but I haven't experimented with this).
- [`parallel_leader_participation`](https://postgresqlco.nf/doc/en/param/parallel_leader_participation/): This determines whether the leader process will participate in the parallel execution of a query.
- [`parallel_tuple_cost`](https://postgresqlco.nf/doc/en/param/parallel_tuple_cost/): A planner cost estimate on how expensive it is to pass tuples from the parallel worker to the leader.
- [`parallel_setup_cost`](https://postgresqlco.nf/doc/en/param/parallel_setup_cost/): A planner cost estimate on how expensive it is to start up a worker process for a parallel query.
- [`min_parallel_table_scan_size`](https://postgresqlco.nf/doc/en/param/min_parallel_table_scan_size/): The minimum table size to begin using a parallel scan.

Note: throughout this post I'm assuming that `max_worker_processes` is already set to be greater or equal to whatever we configure `max_parallel_workers` or `max_parallel_workers_per_gather` to.

The easiest way to enforce parallelism (in this case 8-way) is to set:

```sql
SET max_parallel_workers = 8;
SET max_parallel_workers_per_gather = 8;
SET parallel_leader_participation = off;
SET parallel_tuple_cost = 0; 
SET parallel_setup_cost = 0;
SET min_parallel_table_scan_size = 0;
```

This effectively tells the planner "don't worry, parallelism never costs anything" (which is not strictly true), and "please use up to 8 workers".

We can set these settings in a connection, and validate that they're working with the following:

```sql
CREATE TABLE data(val INTEGER);
INSERT INTO data (val) SELECT * FROM generate_series(1, 1000000) as val;
```

Now run:
```sql
EXPLAIN (ANALYZE) SELECT sum(val) FROM data;
```

```
                                                              QUERY PLAN
--------------------------------------------------------------------------------------------------------------------------------------
 Finalize Aggregate  (cost=5987.53..5987.54 rows=1 width=8) (actual time=20.987..24.387 rows=1 loops=1)
   ->  Gather  (cost=5987.50..5987.51 rows=8 width=8) (actual time=20.923..24.381 rows=8 loops=1)
         Workers Planned: 8
         Workers Launched: 8
         ->  Partial Aggregate  (cost=5987.50..5987.51 rows=1 width=8) (actual time=15.873..15.874 rows=1 loops=8)
               ->  Parallel Seq Scan on data  (cost=0.00..5675.00 rows=125000 width=4) (actual time=0.007..7.945 rows=125000 loops=8)
 Planning Time: 0.055 ms
 Execution Time: 24.413 ms
(8 rows)
```

So far, nothing new - we're just rehashing what others have said.

At this point, you may run into a wall. This is determined by the number of disk pages used by the table (`relpages` in postgres-speak). The actual parallelism can be determined by taking the logarithm (base 3) of `relpages` for the table being scanned (for more details, take a look at the [postgres sources](https://github.com/postgres/postgres/blob/576b25bfd0e9a1d5bbc54931e888135bc6da8a2f/src/backend/optimizer/path/allpaths.c#L4165-L4181)). In the example that I constructed above, we didn't notice this wall.

To see the wall, let's now set:

```sql
SET max_parallel_workers = 16;
SET max_parallel_workers_per_gather = 16;
```

```sql
EXPLAIN (ANALYZE) SELECT sum(val) FROM data;
```

```
                                                              QUERY PLAN
--------------------------------------------------------------------------------------------------------------------------------------
 Finalize Aggregate  (cost=5987.53..5987.54 rows=1 width=8) (actual time=21.166..24.509 rows=1 loops=1)
   ->  Gather  (cost=5987.50..5987.51 rows=8 width=8) (actual time=21.099..24.501 rows=8 loops=1)
         Workers Planned: 8
         Workers Launched: 8
         ->  Partial Aggregate  (cost=5987.50..5987.51 rows=1 width=8) (actual time=16.004..16.004 rows=1 loops=8)
               ->  Parallel Seq Scan on data  (cost=0.00..5675.00 rows=125000 width=4) (actual time=0.008..7.929 rows=125000 loops=8)
 Planning Time: 0.051 ms
 Execution Time: 24.535 ms
(8 rows)
```

Hmmm... There it is. It seems as though we can't get more than 8 parallel workers.

We can run the following query to understand the current upper limit on parallel workers for our table:

```sql
SELECT ceil(log(3, relpages)) FROM pg_class WHERE relname = 'data';
```

```
 ceil
------
    8
(1 row)
```

Note: `relpages` is an approximation, and is updated when an `ANALYZE` is run on the table. If you're following along and get an error like `ERROR:  cannot take logarithm of zero`, you need to run `VACUUME ANALYZE data;` and then rerun the query above.

To get over this, we can override the number of parallel workers on a per-table basis, by setting:

```sql
ALTER TABLE data SET (parallel_workers = 64);
```

Now let's max it out:

```sql
SET max_parallel_workers = 64;
SET max_parallel_workers_per_gather = 64;
```


```sql
EXPLAIN (ANALYZE) SELECT sum(val) FROM data;
```

```
                                                             QUERY PLAN
-------------------------------------------------------------------------------------------------------------------------------------
 Finalize Aggregate  (cost=4620.48..4620.49 rows=1 width=8) (actual time=47.768..49.222 rows=1 loops=1)
   ->  Gather  (cost=4620.31..4620.32 rows=64 width=8) (actual time=14.635..49.192 rows=64 loops=1)
         Workers Planned: 64
         Workers Launched: 64
         ->  Partial Aggregate  (cost=4620.31..4620.32 rows=1 width=8) (actual time=1.957..1.958 rows=1 loops=64)
               ->  Parallel Seq Scan on data  (cost=0.00..4581.25 rows=15625 width=4) (actual time=0.003..1.000 rows=15625 loops=64)
 Planning Time: 0.051 ms
 Execution Time: 49.251 ms
(8 rows)
```

Whether this is actually sensible or not is an entirely different matter, but if you were wondering how it's done - now you know!

[1]: https://www.pgmustard.com/blog/max-parallel-workers-per-gather
[2]: https://swarm64.com/post/increase-postgresql-parallelism/
