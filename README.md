# KSQLDB ETL Demo

## Purpose

The aim of this demo is to show how to leverage KSQLDB to stream changes from a 3NF model to a more BI focused model and to spot the differences between Stream - Table joins and Table - Table joins.  

It puts on the scene a KSQLDB server on top of a basic Apache Kafka platform in order to streams changes from a MySQL DB with a CDC solution provided by Debezium. 

All data coming in and out is managed by Kafka connect, with Debezium as source and JDBC-connector as a sink.

**Nota bene:** This is definitely not a production ready set up, it's designed to run on a single laptop and to show the value that KSQLDB can bring.

## Prerequisites

The runtime platform for this PoC is Docker and `docker-compose`, so check that your Docker daemon is up and that `docker-compose` command is in your path.
The starting procedure is based on a Bash script and it uses `tr` command. 

## Procedure

You only have to run `./start.sh` script in a shell.  It starts all the components and checks that they are ready to run all along the procedure.  
It declares all the stream processing queries in the KSQLDB server and initializes the MySQL database. 

A few seconds after the end of the procedure, you should be able to check that the `OPPORTUNITY_FACT2` table is populated with data from the `opportunity`, `customer` and `product` tables. Any change that occurs on that tables will be propagated within seconds and it can be checked with the following statement:

```bash
$ docker-compose exec  mysql mysql -uroot -pconfluent -Dksql_poc
mysql: [Warning] Using a password on the command line interface can be insecure.
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 35
Server version: 5.7.27-log MySQL Community Server (GPL)

Copyright (c) 2000, 2019, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> select * from OPPORTUNITY_FACT2;
+----+------------------------------------------+----------------------------------------------------+-----------------------------------+-------+-------------+-------------+------------+
| id | opportunity_name                         | product_name                                       | customer_name                     | price | status      | customer_id | product_id |
+----+------------------------------------------+----------------------------------------------------+-----------------------------------+-------+-------------+-------------+------------+
|  1 | Estate high-level Palestinian Territory  | Generic Steel Tuna                                 | Assistant                         | 28210 | CLOSED_LOST |           1 |          1 |
|  2 | application white Borders                | website calculating                                | Generic heuristic                 | 32588 | CLOSED_WON  |           2 |          2 |
|  3 | Officer Rustic Keyboard                  | cross-platform support                             | program orchid Investment Account | 66233 | CLOSED_WON  |           3 |          3 |
|  4 | Baby driver indigo                       | navigate wireless Chilean Peso Unidades de fomento | Security                          | 14437 | CLOSED_LOST |           4 |          4 |
|  5 | grey RAM                                 | reboot                                             | Team-oriented                     | 80218 | CLOSED_LOST |           5 |          5 |
|  6 | card violet Checking Account             | Dynamic magenta Track                              | pricing structure                 |  1799 | OPENED      |           6 |          6 |
|  7 | payment                                  | actuating THX                                      | mission-critical auxiliary        | 34369 | CLOSED_LOST |           7 |          7 |
|  8 | Balanced Forward                         | Division                                           | functionalities                   | 76958 | CLOSED_LOST |           8 |          8 |
|  9 | architecture                             | Steel                                              | sky blue Consultant Malta         | 70397 | OPENED      |           9 |          9 |
| 10 | Customer Comoro Franc                    | Kina networks                                      | alarm Licensed Rubber Bacon       | 63673 | CLOSED_LOST |          10 |         10 |
+----+------------------------------------------+----------------------------------------------------+-----------------------------------+-------+-------------+-------------+------------+
10 rows in set (0.00 sec)

mysql> update customer set name='Assistant 2' where id=1;
Query OK, 1 row affected (0.00 sec)
Rows matched: 1  Changed: 1  Warnings: 0

mysql> select * from OPPORTUNITY_FACT2;
+----+-----------------------------------------+----------------------------------------------------+-----------------------------------+-------+-------------+-------------+------------+
| id | opportunity_name                        | product_name                                       | customer_name                     | price | status      | customer_id | product_id |
+----+-----------------------------------------+----------------------------------------------------+-----------------------------------+-------+-------------+-------------+------------+
|  1 | Estate high-level Palestinian Territory | Generic Steel Tuna                                 | Assistant 2                       | 28210 | CLOSED_LOST |           1 |          1 |
|  2 | application white Borders               | website calculating                                | Generic heuristic                 | 32588 | CLOSED_WON  |           2 |          2 |
|  3 | Officer Rustic Keyboard                 | cross-platform support                             | program orchid Investment Account | 66233 | CLOSED_WON  |           3 |          3 |
|  4 | Baby driver indigo                      | navigate wireless Chilean Peso Unidades de fomento | Security                          | 14437 | CLOSED_LOST |           4 |          4 |
|  5 | grey RAM                                | reboot                                             | Team-oriented                     | 80218 | CLOSED_LOST |           5 |          5 |
|  6 | card violet Checking Account            | Dynamic magenta Track                              | pricing structure                 |  1799 | OPENED      |           6 |          6 |
|  7 | payment                                 | actuating THX                                      | mission-critical auxiliary        | 34369 | CLOSED_LOST |           7 |          7 |
|  8 | Balanced Forward                        | Division                                           | functionalities                   | 76958 | CLOSED_LOST |           8 |          8 |
|  9 | architecture                            | Steel                                              | sky blue Consultant Malta         | 70397 | OPENED      |           9 |          9 |
| 10 | Customer Comoro Franc                   | Kina networks                                      | alarm Licensed Rubber Bacon       | 63673 | CLOSED_LOST |          10 |         10 |
+----+-----------------------------------------+----------------------------------------------------+-----------------------------------+-------+-------------+-------------+------------+
10 rows in set (0.00 sec)

mysql>
```

If you want to dig in a more interactive way with KSQLDB, you can start the KSQLDB CLI console qith the following command:

```bash
$ docker exec -it ksqldb-cli ksql http://ksqldb-server:8088

                  ===========================================
                  =       _              _ ____  ____       =
                  =      | | _____  __ _| |  _ \| __ )      =
                  =      | |/ / __|/ _` | | | | |  _ \      =
                  =      |   <\__ \ (_| | | |_| | |_) |     =
                  =      |_|\_\___/\__, |_|____/|____/      =
                  =                   |_|                   =
                  =  Event Streaming Database purpose-built =
                  =        for stream processing apps       =
                  ===========================================

Copyright 2017-2019 Confluent Inc.

CLI v0.7.1, Server v0.7.1 located at http://ksqldb-server:8088

Having trouble? Type 'help' (case-insensitive) for a rundown of how things work!

ksql>
```
