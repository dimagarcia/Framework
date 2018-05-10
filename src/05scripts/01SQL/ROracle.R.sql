library(ORE)
ore.connect(user="RQUSER", password="Hasting2016", conn_string="//192.168.56.105:1523/PDBORCL")
ore.connect(user="RQUSER", host="192.168.56.105", password="Hasting2016", service_name="PDBORCL")
ore.connect(user="RQUSER", sid="pdborcl", host="192.168.56.105", password="Hasting2016",port=1523, all=TRUE)

ore.is.connected()

ore.ls()

cars <- ore.push(cars)

head(cars)

##--------------------------- 05-APR-2017
library(ROracle)
drv <- dbDriver("Oracle")
con <- dbConnect(drv, username = "rquser", password = "Hasting2016", dbname = "orcl")
## Run a SQL statement by creating first a resultSet object.
rs <- dbSendQuery(con, "select * from test where id = 2")
## We now fetch records from the resultSet into a data.frame.
data <- fetch(rs)
## extract all rows
dim(data)

# clear the result
dbClearResult(rs)
# disconnect from the database
dbDisconnect(con)
# free the driver object
dbUnloadDriver(drv)
## ---------------------------------------------------------------------------------
## Not run:
drv <- dbDriver("Oracle")
# con1 <- dbConnect(drv, "scott", "tiger")
con1 <- dbConnect(drv, username = "rquser", password = "Hasting2016", dbname = "orcl")
# res1 <- dbSendQuery(con1, "select * from emp where deptno = 10")
# res2 <- dbSendQuery(con1, "select * from emp where deptno = 20")
res1 <- dbSendQuery(con1, "select * from test where id = 2")
# con2 <- dbConnect(drv, "scott", "tiger")
# res3 <- dbSendQuery(con2, "select * from dept")
## get all active statements
for(con in dbListConnections(drv))
  for (res in dbListResults(con))
    print(dbGetStatement(res))
## End(Not run)
## ---------------------------------------------------------------------------------
drv <- dbDriver("Oracle")
con <- dbConnect(drv, username = "rquser", password = "Hasting2016", dbname = "orcl")
# A table is created using:
createTab <- "create table RORACLE_TEST(row_num number, id1 date,
id2 timestamp, id3 timestamp with time zone,
id4 timestamp with local time zone )"
dbGetQuery(con, createTab)

# Insert statement.
insStr <- "insert into RORACLE_TEST values(:1, :2, :3, :4, :5)";

# Insert time stamp without time values in POSIXct form.
x <- 1;
y <- "2012-06-05";
y <- as.POSIXct(y);
dbGetQuery(con, insStr, data.frame(x, y, y, y, y));
Sys.setenv(TZ = "EST5EDT")

# Insert list of date objects in POSIXct form.
x <- c(3, 4, 5, 6);
y <- c('2012-01-05', '2011-01-05', '2013-01-05', '2020-01-05');
y <- as.POSIXct(y);
dbGetQuery(con, insStr, data.frame(x, y, y, y, y));
dbCommit (con)

# --
library(ROracle)
drv <- dbDriver("Oracle")
con <- dbConnect(drv, username = "rquser", password = "Hasting2016", dbname = "orcl")

# Insert statement.
insStr <- "insert into test values(:1, :2)";
# Insert time stamp without time values in POSIXct form.
x <- 4;
y <- "Four";
dbGetQuery(con, insStr, data.frame(x, y));
dbCommit (con)
# Select statement.
selStr <- "select * from test";
# Selecting data and displaying it.
res <- dbGetQuery(con, selStr)

res[,1]
res[,2]

##########################################################################################
library(ORE)
ore.connect(user="RQUSER", sid="orcl", host="10.0.0.43", password="Hasting2016",
            port=1521, all=TRUE)
ore.is.connected()
ore.ls()
ore.doEval(function() { 123 })
Error in .oci.GetQuery(conn, statement, data = data, prefetch = prefetch,  : ORA-20000: RQuery internal error [rqetPrepare, 2, 24323, 0]
                       
RandomRedDots <- function(divisor = 100){
id<- 1:10
plot(1:100, rnorm(100), pch = 21, bg = "red", cex = 2 )
data.frame(id=id, val=id / divisor)
}
ore.doEval(RandomRedDots)


install.packages("/home/dgarcia/Downloads/Oracle11204/OracleR/supporting/ROracle_1.2-1_R_x86_64-unknown-linux-gnu.tar.gz", repos=NULL)
install.packages("/home/dgarcia/Downloads/Oracle11204/OracleR/supporting/DBI_0.3.1_R_x86_64-unknown-linux-gnu.tar.gz", repos=NULL)
install.packages("/home/dgarcia/Downloads/Oracle11204/OracleR/supporting/png_0.1-7_R_x86_64-unknown-linux-gnu.tar.gz", repos=NULL)
install.packages("/home/dgarcia/Downloads/Oracle11204/OracleR/supporting/Cairo_1.5-8_R_x86_64-unknown-linux-gnu.tar.gz", repos=NULL)
install.packages("/home/dgarcia/Downloads/Oracle11204/OracleR/supporting/arules_1.1-9_R_x86_64-unknown-linux-gnu.tar.gz", repos=NULL)
install.packages("/home/dgarcia/Downloads/Oracle11204/OracleR/supporting/randomForest_4.6-10_R_x86_64-unknown-linux-gnu.tar.gz", repos=NULL)
install.packages("/home/dgarcia/Downloads/Oracle11204/OracleR/supporting/statmod_1.4.21_R_x86_64-unknown-linux-gnu.tar.gz", repos=NULL)