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

