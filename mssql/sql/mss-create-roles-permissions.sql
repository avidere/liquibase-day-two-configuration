--liquibase formatted sql

--------------------------------------------------------------------------------
--changeset Alembic_0002:Create_DBA_Server_Role splitStatements:false
--comment:Create DBA server role
USE [master];
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'DBA_Role' AND type = 'R')
    CREATE SERVER ROLE [DBA_Role];

--rollback USE [master];
--rollback IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'DBA_Role' AND type = 'R') DROP SERVER ROLE [DBA_Role];

--------------------------------------------------------------------------------
--changeset Alembic_0003:Create_Deploy_Server_Role splitStatements:false
--comment:Create Deploy server role
USE [master];
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'Deploy_Role' AND type = 'R')
    CREATE SERVER ROLE [Deploy_Role];

--rollback USE [master];
--rollback IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'Deploy_Role' AND type = 'R') DROP SERVER ROLE [Deploy_Role];

--------------------------------------------------------------------------------
--changeset Alembic_0004:Create_Application_Roles splitStatements:false
--comment:Create application database roles
USE [appdb];
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'app_ro_role' AND type = 'R') CREATE ROLE [app_ro_role];
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'app_rw_role' AND type = 'R') CREATE ROLE [app_rw_role];

--rollback USE [appdb];
--rollback IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'app_rw_role' AND type = 'R') DROP ROLE [app_rw_role];
--rollback IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'app_ro_role' AND type = 'R') DROP ROLE [app_ro_role];

--------------------------------------------------------------------------------
--changeset Alembic_0002:Grant_DBA_Role_Permissions splitStatements:false
--comment:Grant permissions to DBA_Role
USE [master];
GRANT ALTER ANY LOGIN TO [DBA_Role];
GRANT ALTER ANY LINKED SERVER TO [DBA_Role];
GRANT ALTER ANY CONNECTION TO [DBA_Role];
GRANT ALTER ANY SERVER ROLE TO [DBA_Role];
GRANT VIEW ANY DATABASE TO [DBA_Role];
GRANT VIEW ANY DEFINITION TO [DBA_Role];
GRANT VIEW SERVER STATE TO [DBA_Role];
GRANT CREATE ANY DATABASE TO [DBA_Role];

--rollback USE [master];
--rollback REVOKE CREATE ANY DATABASE FROM [DBA_Role];
--rollback REVOKE VIEW SERVER STATE FROM [DBA_Role];
--rollback REVOKE VIEW ANY DEFINITION FROM [DBA_Role];
--rollback REVOKE VIEW ANY DATABASE FROM [DBA_Role];
--rollback REVOKE ALTER ANY SERVER ROLE FROM [DBA_Role];
--rollback REVOKE ALTER ANY CONNECTION FROM [DBA_Role];
--rollback REVOKE ALTER ANY LINKED SERVER FROM [DBA_Role];
--rollback REVOKE ALTER ANY LOGIN FROM [DBA_Role];

--------------------------------------------------------------------------------
--changeset Alembic_0003:Grant_Deploy_Role_Permissions splitStatements:false
--comment:Grant permissions to Deploy users
USE [master];
GRANT CREATE ANY DATABASE, VIEW ANY DATABASE, VIEW ANY DEFINITION, VIEW SERVER STATE, ALTER ANY LOGIN TO [liquibase_dba];
GRANT CREATE ANY DATABASE, VIEW ANY DATABASE, VIEW ANY DEFINITION, VIEW SERVER STATE, ALTER ANY LOGIN TO [liquibase_dare];
GRANT CREATE ANY DATABASE, VIEW ANY DATABASE, VIEW ANY DEFINITION, VIEW SERVER STATE, ALTER ANY LOGIN TO [liquibase_deploy];

--rollback USE [master];
--rollback REVOKE CREATE ANY DATABASE, VIEW ANY DATABASE, VIEW ANY DEFINITION, VIEW SERVER STATE, ALTER ANY LOGIN FROM [liquibase_deploy];
--rollback REVOKE CREATE ANY DATABASE, VIEW ANY DATABASE, VIEW ANY DEFINITION, VIEW SERVER STATE, ALTER ANY LOGIN FROM [liquibase_dare];
--rollback REVOKE CREATE ANY DATABASE, VIEW ANY DATABASE, VIEW ANY DEFINITION, VIEW SERVER STATE, ALTER ANY LOGIN FROM [liquibase_dba];

--------------------------------------------------------------------------------
--changeset Alembic_0002:Assign_Server_Roles splitStatements:false
--comment:Assign members to server roles
USE [master];
ALTER SERVER ROLE [DBA_Role] ADD MEMBER [sysdba];
ALTER SERVER ROLE [Deploy_Role] ADD MEMBER [liquibase_dba];
ALTER SERVER ROLE [Deploy_Role] ADD MEMBER [liquibase_dare];
ALTER SERVER ROLE [Deploy_Role] ADD MEMBER [liquibase_deploy];
ALTER SERVER ROLE [processadmin] ADD MEMBER [DBA_Role];
ALTER SERVER ROLE [setupadmin] ADD MEMBER [DBA_Role];
ALTER SERVER ROLE [processadmin] ADD MEMBER [sysdba];
ALTER SERVER ROLE [setupadmin] ADD MEMBER [sysdba];
ALTER SERVER ROLE [processadmin] ADD MEMBER [liquibase_dba];
ALTER SERVER ROLE [processadmin] ADD MEMBER [liquibase_dare];
ALTER SERVER ROLE [processadmin] ADD MEMBER [liquibase_deploy];
ALTER SERVER ROLE [setupadmin] ADD MEMBER [liquibase_dba];
ALTER SERVER ROLE [setupadmin] ADD MEMBER [liquibase_dare];
ALTER SERVER ROLE [setupadmin] ADD MEMBER [liquibase_deploy];

--rollback USE [master];
--rollback ALTER SERVER ROLE [setupadmin] DROP MEMBER [liquibase_deploy];
--rollback ALTER SERVER ROLE [setupadmin] DROP MEMBER [liquibase_dare];
--rollback ALTER SERVER ROLE [setupadmin] DROP MEMBER [liquibase_dba];
--rollback ALTER SERVER ROLE [processadmin] DROP MEMBER [liquibase_deploy];
--rollback ALTER SERVER ROLE [processadmin] DROP MEMBER [liquibase_dare];
--rollback ALTER SERVER ROLE [processadmin] DROP MEMBER [liquibase_dba];
--rollback ALTER SERVER ROLE [setupadmin] DROP MEMBER [sysdba];
--rollback ALTER SERVER ROLE [processadmin] DROP MEMBER [sysdba];
--rollback ALTER SERVER ROLE [setupadmin] DROP MEMBER [DBA_Role];
--rollback ALTER SERVER ROLE [processadmin] DROP MEMBER [DBA_Role];
--rollback ALTER SERVER ROLE [Deploy_Role] DROP MEMBER [liquibase_deploy];
--rollback ALTER SERVER ROLE [Deploy_Role] DROP MEMBER [liquibase_dare];
--rollback ALTER SERVER ROLE [Deploy_Role] DROP MEMBER [liquibase_dba];
--rollback ALTER SERVER ROLE [DBA_Role] DROP MEMBER [sysdba];

--------------------------------------------------------------------------------
--changeset Alembic_0002:MSDB_SQLAgent_Roles splitStatements:false
--comment:Grant SQL Agent permissions
USE [msdb];
ALTER ROLE [SQLAgentUserRole] ADD MEMBER [sysdba];
ALTER ROLE [SQLAgentOperatorRole] ADD MEMBER [sysdba];
GRANT SELECT ON dbo.sysjobhistory TO [sysdba];
GRANT SELECT ON dbo.sysjobactivity TO [sysdba];

--rollback USE [msdb];
--rollback REVOKE SELECT ON dbo.sysjobactivity FROM [sysdba];
--rollback REVOKE SELECT ON dbo.sysjobhistory FROM [sysdba];
--rollback ALTER ROLE [SQLAgentOperatorRole] DROP MEMBER [sysdba];
--rollback ALTER ROLE [SQLAgentUserRole] DROP MEMBER [sysdba];

--------------------------------------------------------------------------------
--changeset Alembic_0003:Liquibase_DB_Roles splitStatements:false
--comment:Assign db_owner to Liquibase users
USE [liquibase];
ALTER ROLE [db_owner] ADD MEMBER [liquibase_dba];
ALTER ROLE [db_owner] ADD MEMBER [liquibase_dare];
ALTER ROLE [db_owner] ADD MEMBER [liquibase_deploy];
USE [appdb];
ALTER ROLE [db_owner] ADD MEMBER [liquibase_dba];
ALTER ROLE [db_owner] ADD MEMBER [liquibase_dare];
ALTER ROLE [db_owner] ADD MEMBER [liquibase_deploy];

--rollback USE [appdb];
--rollback ALTER ROLE [db_owner] DROP MEMBER [liquibase_deploy];
--rollback ALTER ROLE [db_owner] DROP MEMBER [liquibase_dare];
--rollback ALTER ROLE [db_owner] DROP MEMBER [liquibase_dba];
--rollback USE [liquibase];
--rollback ALTER ROLE [db_owner] DROP MEMBER [liquibase_deploy];
--rollback ALTER ROLE [db_owner] DROP MEMBER [liquibase_dare];
--rollback ALTER ROLE [db_owner] DROP MEMBER [liquibase_dba];
