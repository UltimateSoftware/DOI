USE [master]

/****** Object:  Database [DOIUnitTests]    Script Date: 7/2/2020 2:01:04 PM ******/
IF NOT EXISTS(SELECT 'True' FROM sys.databases WHERE name = 'DOIUnitTests')
BEGIN
    CREATE DATABASE [DOIUnitTests]
        CONTAINMENT = PARTIAL
            ON  PRIMARY (   NAME = N'DOIUnitTests', 
                            FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\DOIUnitTests.mdf' , 
                            SIZE = 8192KB , 
                            MAXSIZE = UNLIMITED, 
                            FILEGROWTH = 65536KB )
        LOG ON (    NAME = N'DOIUnitTests_log', 
                    FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\DOIUnitTests_log.ldf' , 
                    SIZE = 66560KB , 
                    MAXSIZE = 2048GB , 
                    FILEGROWTH = 65536KB )
END

INSERT INTO DOI.DOI.Databases(DatabaseName, OnlineOperations)
VALUES(N'DOIUnitTests', 1)

EXEC DOI.DOI.spRefreshMetadata_System_SysDatabases @DatabaseName = 'DOIUnitTests'