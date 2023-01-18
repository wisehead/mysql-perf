#############################################################
#   File Name: run.sh
#     Autohor: Hui Chen (c) 2023
#        Mail: chenhui13@xxx.com
# Create Time: 2023/01/18-10:54:35
#############################################################
#!/bin/sh 
unzip tpc-h-tool.zip
cd TPC-H_Tools_v3.0.0/dbgen/

cp makefile.suite makefile

#################
### CHANGE NAME OF ANSI COMPILER HERE
#################
#CC      = gcc
## Current values for DATABASE are: INFORMIX, DB2, TDAT (Teradata)
##                                  SQLSERVER, SYBASE, ORACLE, VECTORWISE
## Current values for MACHINE are:  ATT, DOS, HP, IBM, ICL, MVS,
##                                  SGI, SUN, U2200, VMS, LINUX, WIN32
## Current values for WORKLOAD are:  TPCH
#DATABASE= MYSQL
#MACHINE = LINUX
#WORKLOAD = TPCH
