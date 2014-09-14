QuickSphinx
===========

Assuming you're running Docker, here is a really quick and easy way to get started playing around with Sphinx (using a MySQL datasource).

To follow along, create a database called sphinxy. Then, get this SQL file [here](https://github.com/adriannuta/SphinxAutocompleteExample/blob/master/scripts/docs.tar.gz). It will build a table full of text from the Sphinx documentation (this table is used by 'gosphinx.conf'). 

Import it:
```
mysql -uadmin -p sphinxy < docs.sql
```

Build the image:
```
docker build -t quick/sphinx .
```

And, when starting the container, just pass in necessary parameters:
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
