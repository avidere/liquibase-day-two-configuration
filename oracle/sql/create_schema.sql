--liquibase formatted sql

--changeset Day2_Create_Schema:SYFADMIN-SCHEMA runOnChange:true runWith:sqlplus
--comment:Create SYFADMIN schema to store DBA objects

ALTER PROFILE DEFAULT LIMIT PASSWORD_VERIFY_FUNCTION NULL;
CREATE USER SYFADMIN IDENTIFIED BY "${SYFADMIN_PASS}";
GRANT DBA TO SYFADMIN;
ALTER USER SYFADMIN DEFAULT ROLE ALL;

--rollback DROP USER SYFADMIN CASCADE;

--------------------------------------------------------------------------------

--changeset Day2_Create_Tablespace:TOOLS-Tablespace runOnChange:true runWith:sqlplus
--comment:Create TOOLS tablespace

CREATE TABLESPACE tools
DATAFILE SIZE 1G
AUTOEXTEND ON NEXT 100M MAXSIZE UNLIMITED;

--rollback DROP TABLESPACE TOOLS;