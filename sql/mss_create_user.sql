--liquibase formatted sql

--changeset Day2_Create_User:DBA-LIQ runOnChange:true
--comment:Liquibase DBA user creation
USE [master];
CREATE LOGIN [${DBA_LIQUIBASE_USER}] WITH PASSWORD = '${DBA_LIQUIBASE_PASS}';
CREATE USER [${DBA_LIQUIBASE_USER}] FOR LOGIN [${DBA_LIQUIBASE_USER}];

--rollback DROP USER [${DBA_LIQUIBASE_USER}];
--rollback DROP LOGIN [${DBA_LIQUIBASE_USER}];

--------------------------------------------------------------------------------

--changeset Day2_Create_User:DARE-LIQ runOnChange:true
--comment:Liquibase DARE user creation
USE [master];
CREATE LOGIN [${DARE_LIQUIBASE_USER}] WITH PASSWORD = '${DARE_LIQUIBASE_PASS}';
CREATE USER [${DARE_LIQUIBASE_USER}] FOR LOGIN [${DARE_LIQUIBASE_USER}];

--rollback DROP USER [${DARE_LIQUIBASE_USER}];
--rollback DROP LOGIN [${DARE_LIQUIBASE_USER}];

--------------------------------------------------------------------------------

--changeset Day2_Create_User:APP-LIQ runOnChange:true
--comment:Liquibase App user creation
USE [master];
CREATE LOGIN [${APP_LIQUIBASE_USER}] WITH PASSWORD = '${APP_LIQUIBASE_PASS}';
CREATE USER [${APP_LIQUIBASE_USER}] FOR LOGIN [${APP_LIQUIBASE_USER}];

--rollback DROP USER [${APP_LIQUIBASE_USER}];
--rollback DROP LOGIN [${APP_LIQUIBASE_USER}];

--------------------------------------------------------------------------------

--changeset Day2_Create_User:DBA runOnChange:true
--comment:DBA user creation for admin operations
USE [master];
CREATE LOGIN [${SYSDBA_USER}] WITH PASSWORD = '${SYSDBA_PASS}';
CREATE USER [${SYSDBA_USER}] FOR LOGIN [${SYSDBA_USER}];

--rollback DROP USER [${SYSDBA_USER}];
--rollback DROP LOGIN [${SYSDBA_USER}];

--------------------------------------------------------------------------------

--changeset Day2_Create_User:DBA-VAULT runOnChange:true
--comment:User to setup vault credential rotation for master user
USE [master];
CREATE LOGIN [${VAULT_ADMIN_USER}] WITH PASSWORD = '${VAULT_ADMIN_PASS}';
CREATE USER [${VAULT_ADMIN_USER}] FOR LOGIN [${VAULT_ADMIN_USER}];

--rollback DROP USER [${VAULT_ADMIN_USER}];
--rollback DROP LOGIN [${VAULT_ADMIN_USER}];

--------------------------------------------------------------------------------

--changeset Day2_Create_User:Devops-VAULT runOnChange:true
--comment:User to setup vault credential rotation for master user
USE [master];
CREATE LOGIN [${DEVOPS_VAULT_USER}] WITH PASSWORD = '${DEVOPS_VAULT_PASS}';
CREATE USER [${DEVOPS_VAULT_USER}] FOR LOGIN [${DEVOPS_VAULT_USER}];

--rollback DROP USER [${DEVOPS_VAULT_USER}];
--rollback DROP LOGIN [${DEVOPS_VAULT_USER}];

--------------------------------------------------------------------------------

--changeset Day2_Create_User:BIGID runOnChange:true
--comment:User for BigID Team
USE [master];
CREATE LOGIN [${BIGID_USER}] WITH PASSWORD = '${BIGID_PASS}';
CREATE USER [${BIGID_USER}] FOR LOGIN [${BIGID_USER}];

--rollback DROP USER [${BIGID_USER}];
--rollback DROP LOGIN [${BIGID_USER}];

--------------------------------------------------------------------------------

--changeset Day2_Create_User:METADATAQ runOnChange:true
--comment:User for DataOffice Team
USE [master];
CREATE LOGIN [${METADATAQ_USER}] WITH PASSWORD = '${METADATAQ_PASS}';
CREATE USER [${METADATAQ_USER}] FOR LOGIN [${METADATAQ_USER}];

--rollback DROP USER [${METADATAQ_USER}];
--rollback DROP LOGIN [${METADATAQ_USER}];
