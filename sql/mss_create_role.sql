--liquibase formatted sql

--changeset Day2_Create_Role:DBA-Role runOnChange:true
--comment:Create DBA Role
USE [master];
CREATE SERVER ROLE [${DBA_ROLE}];
GRANT ALTER ANY LOGIN TO [${DBA_ROLE}];
GRANT ALTER ANY LINKED SERVER TO [${DBA_ROLE}];
GRANT ALTER ANY CONNECTION TO [${DBA_ROLE}];
GRANT ALTER ANY SERVER ROLE TO [${DBA_ROLE}];
GRANT VIEW ANY DATABASE TO [${DBA_ROLE}];
GRANT VIEW ANY DEFINITION TO [${DBA_ROLE}];
GRANT VIEW SERVER STATE TO [${DBA_ROLE}];
GRANT CREATE ANY DATABASE TO [${DBA_ROLE}];

ALTER SERVER ROLE [${DBA_ROLE}] ADD MEMBER [${DBA_LIQUIBASE_USER}];
ALTER SERVER ROLE [${DBA_ROLE}] ADD MEMBER [${DARE_LIQUIBASE_USER}];
ALTER SERVER ROLE [${DBA_ROLE}] ADD MEMBER [${SYSDBA_USER}];

--rollback DROP SERVER ROLE [${DBA_ROLE}];

--------------------------------------------------------------------------------

--changeset Day2_Create_Role:Vault-Cred-Rotation-Role runOnChange:true
--comment:Create Vault Credential Rotation Role
USE [master];
CREATE SERVER ROLE [${VAULT_ROLE}];
GRANT ALTER ANY LOGIN TO [${VAULT_ROLE}];

ALTER SERVER ROLE [${VAULT_ROLE}] ADD MEMBER [${VAULT_ADMIN_USER}];
ALTER SERVER ROLE [${VAULT_ROLE}] ADD MEMBER [${DEVOPS_VAULT_USER}];

--rollback DROP SERVER ROLE [${VAULT_ROLE}];

--------------------------------------------------------------------------------

--changeset Day2_Create_Role:Deploy-Role runOnChange:true
--comment:Create Deploy Role
USE [master];
CREATE SERVER ROLE [${DEPLOY_ROLE}];
GRANT CREATE ANY DATABASE TO [${DEPLOY_ROLE}];
GRANT ALTER ANY DATABASE TO [${DEPLOY_ROLE}];
GRANT VIEW ANY DATABASE TO [${DEPLOY_ROLE}];
GRANT VIEW ANY DEFINITION TO [${DEPLOY_ROLE}];
GRANT VIEW SERVER STATE TO [${DEPLOY_ROLE}];
GRANT ALTER ANY SCHEMA TO [${DEPLOY_ROLE}];
GRANT CREATE ANY PROCEDURE TO [${DEPLOY_ROLE}];
GRANT CREATE ANY TABLE TO [${DEPLOY_ROLE}];
GRANT ALTER ANY TABLE TO [${DEPLOY_ROLE}];
GRANT ALTER ANY PROCEDURE TO [${DEPLOY_ROLE}];

ALTER SERVER ROLE [${DEPLOY_ROLE}] ADD MEMBER [${APP_LIQUIBASE_USER}];

--rollback DROP SERVER ROLE [${DEPLOY_ROLE}];

--------------------------------------------------------------------------------

--changeset Day2_Create_Role:DARE-Role runOnChange:true
--comment:Create DARE Team Role
USE [master];
CREATE SERVER ROLE [${DARE_ROLE}];
GRANT CONTROL SERVER TO [${DARE_ROLE}];
GRANT ALTER ANY LOGIN TO [${DARE_ROLE}];
GRANT VIEW ANY DATABASE TO [${DARE_ROLE}];
GRANT VIEW ANY DEFINITION TO [${DARE_ROLE}];
GRANT VIEW SERVER STATE TO [${DARE_ROLE}];
GRANT ALTER ANY SERVER ROLE TO [${DARE_ROLE}];
GRANT CREATE ANY DATABASE TO [${DARE_ROLE}];

--rollback DROP SERVER ROLE [${DARE_ROLE}];

--------------------------------------------------------------------------------

--changeset Day2_Create_Role:BigID-Role runOnChange:true
--comment:Create BigID User Role
USE [master];
CREATE SERVER ROLE [${BIGID_ROLE}];
GRANT VIEW ANY DATABASE TO [${BIGID_ROLE}];
GRANT VIEW ANY DEFINITION TO [${BIGID_ROLE}];

ALTER SERVER ROLE [${BIGID_ROLE}] ADD MEMBER [${BIGID_USER}];

--rollback DROP SERVER ROLE [${BIGID_ROLE}];

--------------------------------------------------------------------------------

--changeset Day2_Create_Role:Metadataq-Role runOnChange:true
--comment:Create Metadataq User Role
USE [master];
CREATE SERVER ROLE [${METADATAQ_ROLE}];
GRANT VIEW ANY DATABASE TO [${METADATAQ_ROLE}];
GRANT VIEW ANY DEFINITION TO [${METADATAQ_ROLE}];

ALTER SERVER ROLE [${METADATAQ_ROLE}] ADD MEMBER [${METADATAQ_USER}];

--rollback DROP SERVER ROLE [${METADATAQ_ROLE}];
