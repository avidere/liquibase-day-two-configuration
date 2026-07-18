--liquibase formatted sql

--changeset Day2_Create_User:APP-RW-liquibase-USER runOnChange:true
--comment:Create database specific App Read Write User
USE [master];
CREATE LOGIN [app_liquibase_rw] WITH PASSWORD = 'apprw@2026X';
USE [liquibase];
CREATE USER [app_liquibase_rw] FOR LOGIN [app_liquibase_rw];

--rollback USE [liquibase];
--rollback DROP USER [app_liquibase_rw];
--rollback USE [master];
--rollback DROP LOGIN [app_liquibase_rw];

--------------------------------------------------------------------------------

--changeset Day2_Create_User:APP-RO-liquibase-USER runOnChange:true
--comment:Create database specific App Read Only User
USE [master];
CREATE LOGIN [app_liquibase_ro] WITH PASSWORD = 'appro@2026X';
USE [liquibase];
CREATE USER [app_liquibase_ro] FOR LOGIN [app_liquibase_ro];

--rollback USE [liquibase];
--rollback DROP USER [app_liquibase_ro];
--rollback USE [master];
--rollback DROP LOGIN [app_liquibase_ro];
