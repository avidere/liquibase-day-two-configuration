--liquibase formatted sql

--changeset Day2_Create_User:APP-RW-${DATABASE}-USER runOnChange:true
--comment:Create database specific App Read Write User
USE [master];
CREATE LOGIN [${APP_RW_USER}] WITH PASSWORD = '${APP_RW_PASS}';
USE [${DATABASE}];
CREATE USER [${APP_RW_USER}] FOR LOGIN [${APP_RW_USER}];

--rollback DROP USER [${APP_RW_USER}];
--rollback DROP LOGIN [${APP_RW_USER}];

--------------------------------------------------------------------------------

--changeset Day2_Create_User:APP-RO-${DATABASE}-USER runOnChange:true
--comment:Create database specific App Read Only User
USE [master];
CREATE LOGIN [${APP_RO_USER}] WITH PASSWORD = '${APP_RO_PASS}';
USE [${DATABASE}];
CREATE USER [${APP_RO_USER}] FOR LOGIN [${APP_RO_USER}];

--rollback DROP USER [${APP_RO_USER}];
--rollback DROP LOGIN [${APP_RO_USER}];
