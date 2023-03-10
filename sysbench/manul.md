#1.sysbench 介绍
sysbench 是一个基于 LuaJIT 的可编写脚本的多线程基准测试工具。 它最常用于数据库基准测试，可以用来进行CPU、内存、磁盘 I/O、线程、数据库的性能测试。
sysbench 的测试主要包括以下几个方面：
● 磁盘 I/O 性能
● CPU 性能
● 内存
● 线程
● 调度程序性能
● 数据库 OLTP 性能

#2.安装 sysbench
##2.1快速安装说明
* Debian/Ubuntu 环境

```
curl -s https://packagecloud.io/install/repositories/akopytov/sysbench/script.deb.sh | sudo bash
sudo apt -y install sysbench
```

* RHEL/CentOS 环境

```
curl -s https://packagecloud.io/install/repositories/akopytov/sysbench/script.rpm.sh | sudo bash
sudo yum -y install sysbench
```
##2.2 编译安装

```
yum install gcc gcc-c++ autoconf automake make libtool bzr mysql-devel git mysql
##从 Git 中下载 sysbench
git clone https://github.com/akopytov/sysbench.git
cd sysbench
git checkout 1.0.18
## 运行 autogen.sh
./autogen.sh
./configure --prefix=$WROKSPACE/sysbench/ --mandir=/usr/share/man
## 编译
make
make install
```
#3.sysbench 参数说明

|  参数   | 说明  | 
|  ----  | ----  | 
|db-driver			| 数据库驱动。|
|mysql-host			| 测试实例连接地址。|
|mysql-port			|测试实例连接端口。|
|mysql-user			|测试实例账号。|
|mysql-password		|测试实例账号对应的密码。|
|mysql-db			|测试实例数据库名。|
|table_size			|测试表大小。|
|tables				|测试表数量。|
|events				|测试请求数量。|
|time				|测试时间。|
|threads			|测试线程数。|
|percentile			|需要统计的百分比，默认值为 95%，即请求在 95% 的情况下的执行时间。|
|report-interval	|测试报告输出时间间隔。0 表示关闭测试进度报告输出，仅输出最终的报告结果。|
|skip-trx			|是否跳过事务。|
|					|	1：跳过|
|					|	0：不跳过|
|mysql-socket		|本地的实例可以指定 socket 文件。|
|create_secondary	|是否创建二级索引，默认为 true。                                    |

#4.OLTP 基准测试

```
#sysbench --test=oltp help 
参数详解：
  --oltp-test-mode=STRING    执行模式{simple,complex(advanced transactional),nontrx(non-transactional),sp}。默认是complex
  --oltp-reconnect-mode=STRING 重新连接模式{session(不使用重新连接。每个线程断开只在测试结束),transaction(在每次事务结束后重新连接),query (在每个SQL语句执行完重新连接),random (对于每个事务随机选择以上重新连接模式)}。默认是 session
  --oltp-sp-name=STRING   存储过程的名称。默认为空。
  --oltp-read-only=[on|off]  只读模式。Update，delete，insert 语句不可执行。默认是 off。
  --oltp-skip-trx=[on|off]   省略 begin/commit 语句。默认是 off。
  --oltp-range-size=N      查询范围。默认是 100。
  --oltp-point-selects=N          number of point selects [10]
  --oltp-simple-ranges=N          number of simple ranges [1]
  --oltp-sum-ranges=N             number of sum ranges [1]
  --oltp-order-ranges=N           number of ordered ranges [1]
  --oltp-distinct-ranges=N        number of distinct ranges [1]
  --oltp-index-updates=N          number of index update [1]
  --oltp-non-index-updates=N      number of non-index updates [1]
  --oltp-nontrx-mode=STRING   查询类型对于非事务执行模式 {select, update_key, update_nokey, insert, delete} [select]
  --oltp-auto-inc=[on|off]      AUTO_INCREMENT 是否开启。默认是 on。
  --oltp-connect-delay=N     在多少微秒后连接数据库。默认是 10000。
  --oltp-user-delay-min=N    每个请求最短等待时间。单位是 ms。默认是 0。
  --oltp-user-delay-max=N    每个请求最长等待时间。单位是 ms。默认是 0。
  --oltp-table-name=STRING  测试时使用到的表名。默认是 sbtest。
  --oltp-table-size=N         测试表的记录数。默认是 10000。
  --oltp-dist-type=STRING    分布的随机数{uniform(均匀分布),Gaussian(高斯分布),special(空间分布)}。默认是special
  --oltp-dist-iter=N    产生数的迭代次数。默认是 12。
  --oltp-dist-pct=N    值的百分比被视为'special' (for special distribution)。默认是 1。
  --oltp-dist-res=N    ‘special’的百分比值。默认是 75。
```
#5.测试说明

建表语句

···
CREATE TABLE `sbtest` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `k` int(11) NOT NULL DEFAULT '0',
  `c` char(120) NOT NULL DEFAULT '',
  `pad` char(60) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=TIANMU AUTO_INCREMENT=800001 DEFAULT CHARSET=utf8;
···

SQL 请求比例（只读测试方案下所有的请求都是读操作，不涉及写操作）：


|SQL 类型 |执行比例	|SQL 语句示例
|  ----  | ----  | ---- |
|point_selects			|10		|SELECT c FROM sbtest%u WHERE id=?
|simple_ranges			|1		|SELECT c FROM sbtest%u WHERE id BETWEEN ? AND ?
|sum_ranges				|1		|SELECT SUM(k) FROM sbtest%u WHERE id BETWEEN ? AND ?
|order_ranges			|1		|SELECT c FROM sbtest%u WHERE id BETWEEN ? AND ? ORDER BY c
|distinct_ranges			|1		|SELECT DISTINCT c FROM sbtest%u WHERE id BETWEEN ? AND ? ORDER BY c
|index_updates（StoneDB 无需二级索引，所以不用添加二级索引，等同于 non_index_updates）	|1	|UPDATE sbtest%u SET k=k+1 WHERE id=?
|non_index_updates		|1	|UPDATE sbtest%u SET c=? WHERE id=?

#6.衡量指标

每秒执行事务数 TPS（Transactions Per Second）数据库每秒执行的事务数，以 COMMIT 成功次数为准。
每秒执行请求数 QPS（Queries Per Second）数据库每秒执行的 SQL 数，包含 INSERT、SELECT、UPDATE、DETELE 等。

测试语句示例
测试数据准备，执行，数据清理：

```
cd $WROKSPACE/sysbench/
# 准备数据
bin/sysbench --db-driver=mysql --mysql-host=xx.xx.xx.xx --mysql-port=3306 --mysql-user=xxx --mysql-password=xxxxxx --mysql-db=sbtest --table_size=800000 --tables=230 --time=600 --mysql_storage_engine=tianmu --create_secondary=false --test=src/lua/oltp_read_only.lua prepare

# 运行 workload
bin/sysbench --db-driver=mysql --mysql-host=xx.xx.xx.xx --mysql-port=3306 --mysql-user=xxx --mysql-password=xxxxxx  --mysql-db=sbtest --table_size=800000 --tables=230 --events=0 --time=600 --mysql_storage_engine=tianmu  --threads=8 --percentile=95  --range_selects=0 --skip-trx=1 --report-interval=1 --test=src/lua/oltp_read_only.lua run

# 清理压测数据
bin/sysbench --db-driver=mysql --mysql-host=xx.xx.xx.xx --mysql-port=3306 --mysql-user=xxx --mysql-password=xxxxxx  --mysql-db=sbtest --table_size=800000 --tables=230 --events=0 --time=600 --mysql_storage_engine=tianmu  --threads=8 --percentile=95  --range_selects=0 --skip-trx=1 --report-interval=1 --test=src/lua/oltp_read_only.lua cleanup
```



