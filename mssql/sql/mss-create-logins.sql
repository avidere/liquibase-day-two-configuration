--liquibase formatted sql

--------------------------------------------------------------------------------
--changeset Alembic_0002:Create_Sysdba_Login
--comment:Create sysdba login

USE [master];
CREATE LOGIN [sysdba] WITH PASSWORD = 'SysDba@2026Q';

--rollback DROP LOGIN [sysdba];

--------------------------------------------------------------------------------
--changeset Alembic_0003:Create_Liquibase_Logins
--comment:Create Liquibase logins

USE [master];

CREATE LOGIN [liquibase_dba]
WITH PASSWORD = 'LiqDba@2026X';

CREATE LOGIN [liquibase_dare]
WITH PASSWORD = 'LiqDare@2026Y';

CREATE LOGIN [liquibase_deploy]
WITH PASSWORD = 'LiqDeploy@2026Z';

--rollback DROP LOGIN [liquibase_deploy];
--rollback DROP LOGIN [liquibase_dare];
--rollback DROP LOGIN [liquibase_dba];

--------------------------------------------------------------------------------
--changeset Alembic_0004:Create_App_Logins
--comment:Create application logins

USE [master];

CREATE LOGIN [app_ro]
WITH PASSWORD = 'AppRO@2026E';

CREATE LOGIN [app_rw]
WITH PASSWORD = 'AppRW@2026F';

--rollback DROP LOGIN [app_rw];
--rollback DROP LOGIN [app_ro];