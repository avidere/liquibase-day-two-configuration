--liquibase formatted sql

--changeset Day2_Create_Database:liquibase runOnChange:true
--comment:Create Database
USE [master];
CREATE DATABASE [liquibase];

--rollback DROP DATABASE [liquibase];

