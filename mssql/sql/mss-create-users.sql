--liquibase formatted sql

--------------------------------------------------------------------------------
--changeset Alembic_0002:Create_Sysdba_User splitStatements:false stripComments:false
--comment:Create sysdba user in msdb
USE [msdb];
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'sysdba')
    CREATE USER [sysdba] FOR LOGIN [sysdba];

--rollback USE [msdb];
--rollback IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'sysdba') DROP USER [sysdba];

--------------------------------------------------------------------------------
--changeset Alembic_0003:Create_Liquibase_Users splitStatements:false stripComments:false
--comment:Create Liquibase users
USE [liquibase];
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'liquibase_dba') CREATE USER [liquibase_dba] FOR LOGIN [liquibase_dba];
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'liquibase_dare') CREATE USER [liquibase_dare] FOR LOGIN [liquibase_dare];
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'liquibase_deploy') CREATE USER [liquibase_deploy] FOR LOGIN [liquibase_deploy];

USE [appdb];
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'liquibase_dba') CREATE USER [liquibase_dba] FOR LOGIN [liquibase_dba];
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'liquibase_dare') CREATE USER [liquibase_dare] FOR LOGIN [liquibase_dare];
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'liquibase_deploy') CREATE USER [liquibase_deploy] FOR LOGIN [liquibase_deploy];

--rollback USE [appdb];
--rollback IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'liquibase_deploy') DROP USER [liquibase_deploy];
--rollback IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'liquibase_dare') DROP USER [liquibase_dare];
--rollback IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'liquibase_dba') DROP USER [liquibase_dba];
--rollback USE [liquibase];
--rollback IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'liquibase_deploy') DROP USER [liquibase_deploy];
--rollback IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'liquibase_dare') DROP USER [liquibase_dare];
--rollback IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'liquibase_dba') DROP USER [liquibase_dba];

--------------------------------------------------------------------------------
--changeset Alembic_0004:Create_App_Users splitStatements:false stripComments:false
--comment:Create application users
USE [appdb];
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'app_ro') CREATE USER [app_ro] FOR LOGIN [app_ro];
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'app_rw') CREATE USER [app_rw] FOR LOGIN [app_rw];

--rollback USE [appdb];
--rollback IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'app_rw') DROP USER [app_rw];
--rollback IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'app_ro') DROP USER [app_ro];
