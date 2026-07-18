--liquibase formatted sql

--changeset Day2_Create_Role:APP-RW-${DATABASE}-ROLE runOnChange:true
--comment:Create schema specific App Read Write Role
USE [${DATABASE}];
CREATE ROLE [${APP_RW_ROLE}];
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE, ALTER ON SCHEMA::[dbo] TO [${APP_RW_ROLE}];

ALTER ROLE [${APP_RW_ROLE}] ADD MEMBER [${APP_RW_USER}];

--rollback DROP ROLE [${APP_RW_ROLE}];

--------------------------------------------------------------------------------

--changeset Day2_Create_Role:APP-RO-${DATABASE}-ROLE runOnChange:true
--comment:Create schema specific App Read Only Role
USE [${DATABASE}];
CREATE ROLE [${APP_RO_ROLE}];
GRANT SELECT ON SCHEMA::[dbo] TO [${APP_RO_ROLE}];

ALTER ROLE [${APP_RO_ROLE}] ADD MEMBER [${APP_RO_USER}];

--rollback DROP ROLE [${APP_RO_ROLE}];

