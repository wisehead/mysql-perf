#TPCH介绍

TPC-H（商业智能计算测试）是美国交易处理效能委员会（TPC，Transaction Processing Performance Council）组织制定的用来模拟决策支持类应用的一个测试集。目前，学术界和工业界普遍采用 TPC-H 来评价决策支持技术方面应用的性能。这种商业测试可以全方位评测系统的整体商业计算综合能力，对厂商的要求更高，同时也具有普遍的商业实用意义，目前在银行信贷分析和信用卡分析、电信运营分析、税收分析、烟草行业决策分析中都有广泛的应用。
是TPC提供的一个benchmark，用来模拟一个现实中的商业应用，可以生成一堆虚构的数据，且自带一些查询，可以导入到各种数据库中来模拟现实需求，检查性能。
TPC-H官网：https://www.tpc.org/tpch/


#使用方法

由于下载需要注册登录，通过发送下载链接到邮箱后进行下载，所以详细步骤就不多做解释
下载地址：https://www.tpc.org/tpc_documents_current_versions/current_specifications5.asp
上传下载好的zip包到需要测试的服务器上
解压：
```shell
unzip tpc-h-tool.zip
cd TPC-H_Tools_v3.0.0/dbgen/
```

安装gcc
```bash
yum install gcc -y
```

修改（注意提示，HTCP本身是不支持Mysql的，所以咱们需要自己写一个Mysql类型）

```
cp makefile.suite makefile
vim makefile

################
## CHANGE NAME OF ANSI COMPILER HERE
################
CC      = gcc
# Current values for DATABASE are: INFORMIX, DB2, TDAT (Teradata)
#                                  SQLSERVER, SYBASE, ORACLE, VECTORWISE
# Current values for MACHINE are:  ATT, DOS, HP, IBM, ICL, MVS,
#                                  SGI, SUN, U2200, VMS, LINUX, WIN32
# Current values for WORKLOAD are:  TPCH
DATABASE= MYSQL
MACHINE = LINUX
WORKLOAD = TPCH
```

如果上面设置的DATABASE 类型在注释类型中的，则不需要修改tpcd.h文件，如果设置的是Mysql类型，则需在文档空闲地方新增以下格式
```cpp
vim tpcd.h

#ifdef MYSQL
#define GEN_QUERY_PLAN  ""
#define START_TRAN      "START TRANSACTION"
#define END_TRAN        "COMMIT"
#define SET_OUTPUT      ""
#define SET_ROWCOUNT    "limit %d;\n"
#define SET_DBASE       "use %s;\n"
#endif

```

执行make生成dbgen，这个过程中会有一些关于数据类型的警告，一般可以无视。
make完dbgen目录下之后就会多出很多.o（等到你所有事都干完确定这些没有用了不想留着就make clean，或者直接整个文件夹删掉……）和一个叫dbgen的文件

```
make
```


#生成需要的数据

接下来要用dbgen生成数据，一共会生成8个表（.tbl）。
查看README里面有命令行参数解说，这里我们在dbgen目录下用
```
./dbgen -s 1
```

-s 1 表示生成1G的数据 （如果你之前曾经尝试过生成数据，最好先make clean，再重新make，接着到这步加上-f覆盖掉）
生成之后可以用head命令检查一下tbl们，会看到每一行都有一些用“|”隔开的字段。

#生成查询语句

```shell
cp qgen queries
cp dists.dss queries

#!/usr/bin/bash
for i in {1..22}
do  
  ./qgen -d $i -s 100 > db"$i".sql
done
```

修改初始化ddl脚本
压缩包内自带两个脚本
dss.ddl   建表语句
dss.ri      主键外键语句
如果需要修改表名为小写，可以使用

```shell
:%s/TABLE\(.*\)/TABLE\L\1

或者vim 编辑器只读模式下输入ggguG即可所有语句变为小写
```

建表
登录mysql执行

```sql
create database tpch;
use tpch;
. ~/tpch_2_16_1/dbgen/dss.ddl
. ~/tpch_2_16_1/dbgen/dss.ri   
#主键外键导入建议等数据导入完成后操作，否则数据量大的情况下导入会比较慢
```

#导入数据

（可以把这些导入操作放到一个文件中，然后使用source 方式执行，也可以自己写脚本执行）

```sql
load data local INFILE 'customer.tbl' INTO TABLE customer FIELDS TERMINATED BY '|';
load data local INFILE 'region.tbl' INTO TABLE region FIELDS TERMINATED BY '|';
load data local INFILE 'nation.tbl' INTO TABLE nation FIELDS TERMINATED BY '|';
load data local INFILE 'supplier.tbl' INTO TABLE supplier FIELDS TERMINATED BY '|';
load data local INFILE 'part.tbl' INTO TABLE part FIELDS TERMINATED BY '|';
load data local INFILE 'partsupp.tbl' INTO TABLE partsupp FIELDS TERMINATED BY '|';
load data local INFILE 'orders.tbl' INTO TABLE orders FIELDS TERMINATED BY '|';
load data local INFILE 'lineitem.tbl' INTO TABLE lineitem FIELDS TERMINATED BY '|';
```

比较大的表可以使用脚本导入
```shell
#! /bin/bash
#文件名不带.tbl ！！！,即对应表名
#read -p "please input filename: " filename
filename=orders      # 修改处1：替换文件名orders、partsupp、lineitem、

#数据库配置
db_host=xxx.xxx.xxx.xx
db_port=3306
db_pwd=xxxxxxx
db_user=xxxx
#tpch 生成数据的目录
sql_dir=/root/tpch-mysql/dbgen


#获取原文件总行数totalline
totalline=$(cat $filename.tbl | wc -l)
echo totalline=$totalline
#要分割成的每个小文件的行数line
line=1000000   
a=`expr $totalline / $line`    
b=`expr $totalline % $line` 
#获取小文件个数filenum
if (( $b==0 ))   
then
    filenum=$a
else
    filenum=`expr $a + 1`
fi
echo filenum=$filenum
#进行文件分割,分割后第一个小文件名后缀为i,i最小值为1
i=1        # 修改处2：38 修改为1
while(( i<=$filenum ))
do
#每个小文件要截取行数在原文件范围min,max 
    p=`expr $i - 1`
    min=`expr $p \* $line + 1`
    max=`expr $i \* $line`
    sed -n "$min,$max"p ./$filename.tbl > ./$filename.tbl.$i
#将小文件导入数据库，mysql登录信息及小文件路径根据实际修改       # 修改处3：mysql连接信息（加了--local-infile）
#根据自己创建的数据库的用户名、密码、数据库实例的ip、端口号、已经tpc安装包的路径信息进行修改。
    mysql -u${db_user} -p${db_pwd} -h${db_host} -P${db_user} --local-infile -Dtpcd -e "load data local infile '${sql_dir}/$filename.tbl.$i' into table $filename fields terminated by '|';"
    i=`expr $i + 1`
done
```

检查导入结果
```sql
SHOW TABLE STATUS FROM tpch;
```

修改执行测试脚本
```shell
#!/bin/sh
PATH=$PATH:/usr/local/bin
export PATH
#set -u
#set -x
#set -e
. ~/.bash_profile > /dev/null 2>&1
exec 3>&1 4>&2 1>> tpch-benchmark-olap-`date +'%Y%m%d%H%M%S'`.log 2>&1
I=1
II=3
while [ $I -le $II ]
do
N=1
T=23
while [ $N -lt $T ]
do
  if [ $N -lt 10 ] ; then
    NN='0'$N
  else
    NN=$N
  fi
  echo "query $NN starting"
# /etc/init.d/mysql restart           # 修改这里mysql连接信息
  time mysql -h10.185.147.201 -P32307 -umyroot -p****** -Dtpcd < ./queries/db${NN}.sql
  echo "query $NN ended!"
  N=`expr $N + 1`
  echo -e
  echo -e
done
 I=`expr $I + 1`
done

```

补充下另一种测试脚本
```shell
#!/usr/bin/env bash
host=$1
port=$2
user=$3
password=$4
database=$5
resfile=$6
echo "start test run at"`date "+%Y-%m-%d %H:%M:%S"`|tee -a ${resfile}.out
for (( i=1; i<=22;i=i+1 ))
do
queryfile="Q"${i}".sql"
start_time=`date "+%s.%N"`
echo "run query ${i}"|tee -a ${resfile}.out
mysql -h ${host}  -P${port} -u${user} -p${password} $database -e" source $queryfile;" |tee -a ${resfile}.out
end_time=`date "+%s.%N"`
start_s=${start_time%.*}
start_nanos=${start_time#*.}
end_s=${end_time%.*}
end_nanos=${end_time#*.}
if [ "$end_nanos" -lt "$start_nanos" ];then
        end_s=$(( 10#$end_s -1 ))
        end_nanos=$(( 10#$end_nanos + 10 ** 9))
fi
time=$(( 10#$end_s - 10#$start_s )).`printf "%03d\n" $(( (10#$end_nanos - 10#$start_nanos)/10**6 ))`
echo ${queryfile} "the "${j}" run cost "${time}" second start at"`date -d @$start_time "+%Y-%m-%d %H:%M:%S"`" stop at"`date -d @$end_time "+%Y-%m-%d %H:%M:%S"` >> ${resfile}.time
done
```