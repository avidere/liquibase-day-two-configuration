--liquibase formatted sql

--changeset Day2_Create_Role:APP-RW-liquibase-ROLE runOnChange:true
--comment:Create schema specific App Read Write Role
USE [liquibase];
CREATE ROLE [liquibase_rw];
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE, ALTER ON SCHEMA::[dbo] TO [liquibase_rw];

ALTER ROLE [liquibase_rw] ADD MEMBER [app_liquibase_rw];

--rollback ALTER ROLE [liquibase_rw] DROP MEMBER [app_liquibase_rw];
--rollback DROP ROLE [liquibase_rw];

--------------------------------------------------------------------------------

--changeset Day2_Create_Role:APP-RO-liquibase-ROLE runOnChange:true
--comment:Create schema specific App Read Only Role
USE [liquibase];
CREATE ROLE [liquibase_ro];
GRANT SELECT ON SCHEMA::[dbo] TO [liquibase_ro];

ALTER ROLE [liquibase_ro] ADD MEMBER [app_liquibase_ro];

--rollback ALTER ROLE [liquibase_ro] DROP MEMBER [app_liquibase_ro];
--rollback DROP ROLE [liquibase_ro];

