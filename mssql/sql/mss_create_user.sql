--liquibase formatted sql

--changeset Alembic_0002:Create_Sysdba_Login runOnChange:true
--comment:Create sysdba login in master
USE [master];
CREATE LOGIN [sysdba] WITH PASSWORD = 'SysDba@2026Q';

--rollback DROP LOGIN [sysdba];

--------------------------------------------------------------------------------

--changeset Alembic_0003:Create_Liquibase_Logins runOnChange:true
--comment:Create liquibase logins in master
USE [master];
CREATE LOGIN [liquibase_dba] WITH PASSWORD = 'LiqDba@2026X';
CREATE LOGIN [liquibase_dare] WITH PASSWORD = 'LiqDare@2026Y';
CREATE LOGIN [liquibase_deploy] WITH PASSWORD = 'LiqDeploy@2026Z';

--rollback DROP LOGIN [liquibase_deploy];
--rollback DROP LOGIN [liquibase_dare];
--rollback DROP LOGIN [liquibase_dba];

--------------------------------------------------------------------------------

--changeset Alembic_0004:Create_App_Logins runOnChange:true
--comment:Create app logins in master
USE [master];
CREATE LOGIN [app_ro] WITH PASSWORD = 'AppRO@2026E';
CREATE LOGIN [app_rw] WITH PASSWORD = 'AppRW@2026F';

--rollback DROP LOGIN [app_rw];
--rollback DROP LOGIN [app_ro];

--------------------------------------------------------------------------------

--changeset Alembic_0002_Vault:Create_Vault_Logins runOnChange:true
--comment:Create vault logins in master
USE [master];
CREATE LOGIN [vault_admin] WITH PASSWORD = 'VaultAdmin@2026A';
CREATE LOGIN [vault_rotate] WITH PASSWORD = 'VaultRotate@2026B';

--rollback DROP LOGIN [vault_rotate];
--rollback DROP LOGIN [vault_admin];

--------------------------------------------------------------------------------

--changeset Alembic_0002_BigID:Create_BigID_Login runOnChange:true
--comment:Create BigID login in master
USE [master];
CREATE LOGIN [bigidscan] WITH PASSWORD = 'BigIdScan@2026C';

--rollback DROP LOGIN [bigidscan];

--------------------------------------------------------------------------------

--changeset Alembic_0002_MetadataQ:Create_MetadataQ_Login runOnChange:true
--comment:Create MetadataQ login in master
USE [master];
CREATE LOGIN [metadatadq] WITH PASSWORD = 'MetaDataQ@2026D';

--rollback DROP LOGIN [metadatadq];
