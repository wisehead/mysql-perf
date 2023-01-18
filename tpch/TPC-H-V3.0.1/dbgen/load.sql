#load data local INFILE '/data/github/mysql-perf/tpch/TPC-H-V3.0.1/dbgen/customer.tbl' INTO TABLE customer FIELDS TERMINATED BY '|';
load data local INFILE '/data/github/mysql-perf/tpch/TPC-H-V3.0.1/dbgen/region.tbl' INTO TABLE region FIELDS TERMINATED BY '|';
load data local INFILE '/data/github/mysql-perf/tpch/TPC-H-V3.0.1/dbgen/nation.tbl' INTO TABLE nation FIELDS TERMINATED BY '|';
load data local INFILE '/data/github/mysql-perf/tpch/TPC-H-V3.0.1/dbgen/supplier.tbl' INTO TABLE supplier FIELDS TERMINATED BY '|';
load data local INFILE '/data/github/mysql-perf/tpch/TPC-H-V3.0.1/dbgen/part.tbl' INTO TABLE part FIELDS TERMINATED BY '|';
load data local INFILE '/data/github/mysql-perf/tpch/TPC-H-V3.0.1/dbgen/partsupp.tbl' INTO TABLE partsupp FIELDS TERMINATED BY '|';
load data local INFILE '/data/github/mysql-perf/tpch/TPC-H-V3.0.1/dbgen/orders.tbl' INTO TABLE orders FIELDS TERMINATED BY '|';
load data local INFILE '/data/github/mysql-perf/tpch/TPC-H-V3.0.1/dbgen/lineitem.tbl' INTO TABLE lineitem FIELDS TERMINATED BY '|';
