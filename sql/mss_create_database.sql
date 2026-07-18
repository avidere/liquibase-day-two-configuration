--liquibase formatted sql

--changeset Day2_Create_Database:${DATABASE} runOnChange:true
--comment:Create Database
USE [master];
CREATE DATABASE [${DATABASE}];

--rollback DROP DATABASE [${DATABASE}];

