--liquibase formatted sql

--changeset Alembic_0002:Create_DBA_Role runOnChange:true
--comment:Create DBA_Role and assign sysdba to fixed server roles
USE [master];
CREATE SERVER ROLE [DBA_Role];
GRANT ALTER ANY LOGIN TO [DBA_Role];
GRANT ALTER ANY LINKED SERVER TO [DBA_Role];
GRANT ALTER ANY CONNECTION TO [DBA_Role];
GRANT ALTER ANY SERVER ROLE TO [DBA_Role];
GRANT VIEW ANY DATABASE TO [DBA_Role];
GRANT VIEW ANY DEFINITION TO [DBA_Role];
GRANT VIEW SERVER STATE TO [DBA_Role];
GRANT CREATE ANY DATABASE TO [DBA_Role];

ALTER SERVER ROLE [processadmin] ADD MEMBER [DBA_Role];
ALTER SERVER ROLE [setupadmin] ADD MEMBER [DBA_Role];
ALTER SERVER ROLE [processadmin] ADD MEMBER [sysdba];
ALTER SERVER ROLE [setupadmin] ADD MEMBER [sysdba];
ALTER SERVER ROLE [DBA_Role] ADD MEMBER [sysdba];

--rollback ALTER SERVER ROLE [DBA_Role] DROP MEMBER [sysdba];
--rollback ALTER SERVER ROLE [processadmin] DROP MEMBER [sysdba];
--rollback ALTER SERVER ROLE [setupadmin] DROP MEMBER [sysdba];
--rollback ALTER SERVER ROLE [processadmin] DROP MEMBER [DBA_Role];
--rollback ALTER SERVER ROLE [setupadmin] DROP MEMBER [DBA_Role];
--rollback DROP SERVER ROLE [DBA_Role];

--------------------------------------------------------------------------------

--changeset Alembic_0003:Create_Deploy_Role runOnChange:true
--comment:Create Deploy_Role and grant liquibase permissions
USE [master];
CREATE SERVER ROLE [Deploy_Role];
GRANT CREATE ANY DATABASE TO [Deploy_Role];
GRANT ALTER ANY DATABASE TO [Deploy_Role];
GRANT VIEW ANY DATABASE TO [Deploy_Role];
GRANT VIEW ANY DEFINITION TO [Deploy_Role];
GRANT VIEW SERVER STATE TO [Deploy_Role];
GRANT ALTER ANY LOGIN TO [Deploy_Role];

ALTER SERVER ROLE [Deploy_Role] ADD MEMBER [liquibase_dba];
ALTER SERVER ROLE [Deploy_Role] ADD MEMBER [liquibase_dare];
ALTER SERVER ROLE [Deploy_Role] ADD MEMBER [liquibase_deploy];

GRANT CREATE ANY DATABASE TO [liquibase_dba];
GRANT VIEW ANY DATABASE TO [liquibase_dba];
GRANT VIEW ANY DEFINITION TO [liquibase_dba];
GRANT VIEW SERVER STATE TO [liquibase_dba];
GRANT ALTER ANY LOGIN TO [liquibase_dba];

GRANT CREATE ANY DATABASE TO [liquibase_dare];
GRANT VIEW ANY DATABASE TO [liquibase_dare];
GRANT VIEW ANY DEFINITION TO [liquibase_dare];
GRANT VIEW SERVER STATE TO [liquibase_dare];
GRANT ALTER ANY LOGIN TO [liquibase_dare];

GRANT CREATE ANY DATABASE TO [liquibase_deploy];
GRANT VIEW ANY DATABASE TO [liquibase_deploy];
GRANT VIEW ANY DEFINITION TO [liquibase_deploy];
GRANT VIEW SERVER STATE TO [liquibase_deploy];
GRANT ALTER ANY LOGIN TO [liquibase_deploy];

--rollback ALTER SERVER ROLE [Deploy_Role] DROP MEMBER [liquibase_deploy];
--rollback ALTER SERVER ROLE [Deploy_Role] DROP MEMBER [liquibase_dare];
--rollback ALTER SERVER ROLE [Deploy_Role] DROP MEMBER [liquibase_dba];
--rollback DROP SERVER ROLE [Deploy_Role];

--------------------------------------------------------------------------------

--changeset Alembic_0003_Liquibase:Create_Database_Users_In_Liquibase runOnChange:true
--comment:Create database users for liquibase logins in liquibase database
USE [master];
CREATE USER [liquibase_dba] FOR LOGIN [liquibase_dba];
CREATE USER [liquibase_dare] FOR LOGIN [liquibase_dare];
CREATE USER [liquibase_deploy] FOR LOGIN [liquibase_deploy];
ALTER ROLE [db_owner] ADD MEMBER [liquibase_dba];
ALTER ROLE [db_owner] ADD MEMBER [liquibase_dare];
ALTER ROLE [db_owner] ADD MEMBER [liquibase_deploy];

--rollback ALTER ROLE [db_owner] DROP MEMBER [liquibase_dba];
--rollback ALTER ROLE [db_owner] DROP MEMBER [liquibase_dare];
--rollback ALTER ROLE [db_owner] DROP MEMBER [liquibase_deploy];
--rollback DROP USER [liquibase_dba];
--rollback DROP USER [liquibase_dare];
--rollback DROP USER [liquibase_deploy];

--changeset Alembic_0004_AppRoles:Create_App_Roles runOnChange:true
--comment:Create application roles in appdb database
USE [master];
CREATE ROLE [app_ro_role];
CREATE ROLE [app_rw_role];
ALTER ROLE [db_datareader] ADD MEMBER [app_ro_role];
ALTER ROLE [db_datareader] ADD MEMBER [app_rw_role];
ALTER ROLE [db_datawriter] ADD MEMBER [app_rw_role];
GRANT EXECUTE ON SCHEMA::[dbo] TO [app_ro_role];
GRANT EXECUTE ON SCHEMA::[dbo] TO [app_rw_role];

--rollback ALTER ROLE [db_datareader] DROP MEMBER [app_ro_role];
--rollback ALTER ROLE [db_datareader] DROP MEMBER [app_rw_role];
--rollback ALTER ROLE [db_datawriter] DROP MEMBER [app_rw_role];
--rollback DROP ROLE [app_ro_role];
--rollback DROP ROLE [app_rw_role];
