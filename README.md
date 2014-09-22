QuickSphinx
===========
Using [Docker](https://www.docker.com/)? If so, here's a really quick and easy way to get started playing around with Sphinx!

###Build###
Go to the folder where you downloaded these files, and:
```
docker build -t quick/sphinx .
```
###Run###
```
docker run -d -p 9311:9306 quick/sphinx /sbin/my_init
```

I put a little tsv file in there, so now you can just open up the command line interface and start searching.

####There's a [JSON attribute](http://sphinxsearch.com/blog/2013/08/08/full-json-support-in-trunk/) in this index, so you might try some things like...####

Find documents from Washington State:
```
mysql> select title, body from tsv_test where json.state='wa';
+--------------------------+-------------------------------------------+
| title                    | body                                      |
+--------------------------+-------------------------------------------+
| How to Search Sphinx     | SELECT * FROM test WHERE MATCH('search'); |
| Why does it always rain? | Because!                                  |
| Why is everything dry?   | Because!                                  |
+--------------------------+-------------------------------------------+
3 rows in set (0.00 sec)
```
Find documents from Yakima, Wa:
```
mysql> select title, body from tsv_test where json.state='wa' and json.city='yakima';
+------------------------+----------+
| title                  | body     |
+------------------------+----------+
| Why is everything dry? | Because! |
+------------------------+----------+
1 row in set (0.00 sec)
```
Find documents that Steve has authored:
```
mysql> SELECT title,body FROM tsv_test WHERE json.people.author='steve';
+--------------------------+-----------------+
| title                    | body            |
+--------------------------+-----------------+
| Why does it always rain? | Because!        |
| Rap song                 | Rhymes and such |
+--------------------------+-----------------+
2 rows in set (0.00 sec)
```
Find documents that Snoop has authored and Dre has edited:
```
mysql> SELECT title,body FROM tsv_test WHERE json.people.author='snoop' AND json.people.editor='dre';
+-------------------------+----------------------------------------------------------------------------+
| title                   | body                                                                       |
+-------------------------+----------------------------------------------------------------------------+
| Nuthin' but a 'G' Thang | One, two, three and to the fo' Snoop Doggy Dogg and Dr. Dre are at the do' |
+-------------------------+----------------------------------------------------------------------------+
1 row in set (0.02 sec)
```
####There's also a multi-value attribute####

So, find documents in some category:
```
mysql> SELECT title,body FROM tsv_test WHERE categories = 2;
+-------------------------+----------------------------------------------------------------------------+
| title                   | body                                                                       |
+-------------------------+----------------------------------------------------------------------------+
| How to Search Sphinx    | SELECT * FROM test WHERE MATCH('search');                                  |
| Nuthin' but a 'G' Thang | One, two, three and to the fo' Snoop Doggy Dogg and Dr. Dre are at the do' |
| Such a great title      | Some groundbreaking buzz fang                                              |
+-------------------------+----------------------------------------------------------------------------+
3 rows in set (0.00 sec)
```
Or, filter documents by multiple categories:
```
mysql> SELECT title,body FROM tsv_test WHERE categories =2 AND categories = 3;
+----------------------+-------------------------------------------+
| title                | body                                      |
+----------------------+-------------------------------------------+
| How to Search Sphinx | SELECT * FROM test WHERE MATCH('search'); |
+----------------------+-------------------------------------------+
1 row in set (0.00 sec)
```

####Regular ol' text search####
Learn about all the fulltext search operators and modifiers [here](http://sphinxsearch.com/docs/current.html#extended-syntax). Then, try something like... MAYBE:
```
mysql> SELECT title,body, weight() FROM tsv_test WHERE MATCH('How MAYBE index');
+------------------------+-------------------------------------------+----------+
| title                  | body                                      | weight() |
+------------------------+-------------------------------------------+----------+
| How to Index TSV files | Use TSVpipe!                              |     1666 |
| How to Search Sphinx   | SELECT * FROM test WHERE MATCH('search'); |     1560 |
+------------------------+-------------------------------------------+----------+
2 rows in set (0.00 sec)
```
Or, try searching specific fields (and, notice that in the second example, the document with 'index' in the title field gets a heavier weight!):
```
mysql> SELECT title,body, weight() FROM tsv_test WHERE MATCH('@title How MAYBE @body index');
+------------------------+-------------------------------------------+----------+
| title                  | body                                      | weight() |
+------------------------+-------------------------------------------+----------+
| How to Search Sphinx   | SELECT * FROM test WHERE MATCH('search'); |     1560 |
| How to Index TSV files | Use TSVpipe!                              |     1560 |
+------------------------+-------------------------------------------+----------+
2 rows in set (0.00 sec)

mysql> SELECT title,body, weight() FROM tsv_test WHERE MATCH('@title How MAYBE @title index');
+------------------------+-------------------------------------------+----------+
| title                  | body                                      | weight() |
+------------------------+-------------------------------------------+----------+
| How to Index TSV files | Use TSVpipe!                              |     1666 |
| How to Search Sphinx   | SELECT * FROM test WHERE MATCH('search'); |     1560 |
+------------------------+-------------------------------------------+----------+
2 rows in set (0.00 sec)
```

###Point to your MySQL DB###
If you don't want to edit the config file I've included, then just use [this sample data](https://github.com/adriannuta/SphinxAutocompleteExample/blob/master/scripts/docs.tar.gz). Import it into your database. Then, just pass in necessary parameters to Sphinx when starting the container, which are:
SQL_HOST, SQL_PORT, SQL_USER, SQL_PASS, and SQL_DB. gosphinx.conf will pick up the environment variables and build an index using the database you point to.

Like this:
```
docker run -d -p 9311:9306 -e SQL_DB="test" -e SQL_HOST="172.17.0.2" -e SQL_PASS="password" -e SQL_PORT="3307" -e SQL_USER="admin" quick/sphinx /sbin/my_init
```


The "-p 9311:9306" means that we've got Sphinx listening to 9306 from within the container, but we'll access Sphinx on 9311 from the host machine. And, in case you're wondering, /sbin/my_init will run 'indexandsearch.sh'.

So, after changing the "-e"s to match your setup, run that command, open up the command line interface, and start Sphinx searching!!
```
mysql -h0 -P9311
SELECT *, weight() FROM test WHERE MATCH('@title distributed') \G
```

Then, go to http://sphinxsearch.com to read more about Sphinx.

I'll be tweaking this configuration (to enable some cool features). When I do, I'll update this readme to show them off. 

For now, you can do wildcard searches because I've set 'min_infix_len=3'. 

Like this:
```
mysql> select *, weight() from test where match('@title *hos*') \G
*************************** 1. row ***************************
      id: 134
   title: sql_host 
 content: <div class="titlepage"><div><div><h3 class="title"><a name="conf-sql-host"></a>11.1.2. sql_host</h3></div></div></div> <p> SQL server host to connect to. Mandatory, no default value. Applies to SQL source types (<code class="option">mysql</code>, <code class="option">pgsql</code>, <code class="option">mssql</code>) only. </p><p> In the simplest case when Sphinx resides on the same host with your MySQL or PostgreSQL installation, you would simply specify "localhost". Note that MySQL client library chooses whether to connect over TCP/IP or over UNIX socket based on the host name. Specifically "localhost" will force it to use UNIX socket (this is the default and generally recommended mode) and "127.0.0.1" will force TCP/IP usage. Refer to <a href="http://dev.mysql.com/doc/refman/5.0/en/mysql-real-connect.html" target="_top">MySQL manual</a> for more details. </p><h4>Example:</h4><pre class="programlisting"> sql_host = localhost </pre>
weight(): 1727
1 row in set (0.00 sec)
```
