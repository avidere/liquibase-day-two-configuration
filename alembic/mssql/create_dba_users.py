"""Create sysdba, bigid and app accounts

Revision ID: 0002
Revises: 0001
Create Date: 2026-04-06 10:00:00.000000

"""

from alembic import op, context
from sqlalchemy.sql import text
from shared.utils.secretsmanager import get_random_password
from shared.utils.logging_config import logger
import shared.utils.vault_utils as vault

revision = "0002"
down_revision = "0001"
branch_labels = None
depends_on = None

vault_details = context.config.attributes.get("vault_details")
vault_secret_path = context.config.attributes.get("vault_secret_path")
environment = context.config.attributes.get("environment")

# sysdba is the super admin user
sysadmin_user = 'sysdba'
sysadmin_role = 'DBA_Role'  # Custom role to mimic sysadmin permissions in AWS RDS


def upgrade():
    conn = op.get_bind()

    # Define super admin user to create with custom DBA_Role (AWS RDS compatible - no sysadmin)
    paswd = get_random_password()
    escaped_paswd = paswd.replace("%", "%%").replace("'", "''")

    # Create MSSQL login for sysdba
    conn.execute(text(f"USE [master]; CREATE LOGIN [{sysadmin_user}] WITH PASSWORD = '{escaped_paswd}';"))
    logger.info(f"Login '{sysadmin_user}' created")

    # Store credentials in Vault if available
    if vault_details and vault_secret_path:
        try:
            secret = {
                "username": sysadmin_user,
                "password": paswd
            }
            vault.put_secret_to_vault(vault_details, f"{vault_secret_path}/{sysadmin_user}", secret)
            vault.update_metadata(vault_details, f"{vault_secret_path}/{sysadmin_user}")
            logger.info(f"User '{sysadmin_user}' credentials stored in Vault")
        except Exception as e:
            logger.warning(f"Could not store credentials for '{sysadmin_user}' in Vault: {str(e)}")

    # Create DBA_Role custom server role (AWS RDS compatible alternative to sysadmin)
    conn.execute(text(f"USE [master]; CREATE SERVER ROLE [{sysadmin_role}];"))
    logger.info(f"Server role '{sysadmin_role}' created")

    # Grant permissions to DBA_Role
    conn.execute(text(f"USE [master]; GRANT ALTER ANY LOGIN TO [{sysadmin_role}];"))
    conn.execute(text(f"USE [master]; GRANT ALTER ANY LINKED SERVER TO [{sysadmin_role}];"))
    conn.execute(text(f"USE [master]; GRANT ALTER ANY CONNECTION TO [{sysadmin_role}];"))
    conn.execute(text(f"USE [master]; GRANT ALTER ANY SERVER ROLE TO [{sysadmin_role}];"))
    conn.execute(text(f"USE [master]; GRANT VIEW ANY DATABASE TO [{sysadmin_role}];"))
    conn.execute(text(f"USE [master]; GRANT VIEW ANY DEFINITION TO [{sysadmin_role}];"))
    conn.execute(text(f"USE [master]; GRANT VIEW SERVER STATE TO [{sysadmin_role}];"))
    conn.execute(text(f"USE [master]; GRANT CREATE ANY DATABASE TO [{sysadmin_role}];"))
    logger.info("DBA_Role permissions granted")

    # Add DBA_Role to fixed server roles (processadmin and setupadmin are available in AWS RDS)
    conn.execute(text(f"USE [master]; ALTER SERVER ROLE [processadmin] ADD MEMBER [{sysadmin_role}];"))
    conn.execute(text(f"USE [master]; ALTER SERVER ROLE [setupadmin] ADD MEMBER [{sysadmin_role}];"))
    logger.info("DBA_Role added to processadmin and setupadmin fixed roles")

    # Add user directly to processadmin and setupadmin
    conn.execute(text(f"USE [master]; ALTER SERVER ROLE [processadmin] ADD MEMBER [{sysadmin_user}];"))
    conn.execute(text(f"USE [master]; ALTER SERVER ROLE [setupadmin] ADD MEMBER [{sysadmin_user}];"))
    logger.info("User 'sysdba' added to processadmin and setupadmin fixed roles")

    # Add sysdba to DBA_Role
    conn.execute(text(f"USE [master]; ALTER SERVER ROLE [{sysadmin_role}] ADD MEMBER [{sysadmin_user}];"))
    logger.info("User 'sysdba' added to DBA_Role")

    # Create user in msdb and assign SQL Agent roles
    batch_sql = f"""USE [msdb];
CREATE USER [{sysadmin_user}] FOR LOGIN [{sysadmin_user}];
ALTER ROLE [SQLAgentUserRole] ADD MEMBER [{sysadmin_user}];
ALTER ROLE [SQLAgentOperatorRole] ADD MEMBER [{sysadmin_user}];
GRANT SELECT ON dbo.sysjobhistory TO [{sysadmin_user}];
GRANT SELECT ON dbo.sysjobactivity TO [{sysadmin_user}];"""
    conn.execute(text(batch_sql))
    logger.info(f"User '{sysadmin_user}' created in msdb with SQLAgent roles and permissions granted")

    conn.execute(text("USE [alembic];"))
    logger.info("Switched back to alembic database")


def downgrade():
    conn = op.get_bind()

    # Drop user from msdb
    try:
        batch_sql = f"""USE [msdb];
DROP USER [{sysadmin_user}];"""
        conn.execute(text(batch_sql))
        logger.info(f"User '{sysadmin_user}' dropped from msdb")
    except Exception as e:
        logger.warning(f"Could not drop user '{sysadmin_user}' from msdb: {str(e)}")

    # Remove sysdba from fixed server roles before dropping
    try:
        conn.execute(text(f"USE [master]; ALTER SERVER ROLE [processadmin] DROP MEMBER [{sysadmin_user}];"))
        conn.execute(text(f"USE [master]; ALTER SERVER ROLE [setupadmin] DROP MEMBER [{sysadmin_user}];"))
        logger.info(f"User '{sysadmin_user}' removed from processadmin and setupadmin fixed roles")
    except Exception as e:
        logger.warning(f"Could not remove '{sysadmin_user}' from processadmin and setupadmin: {str(e)}")

    # Remove sysdba from DBA_Role before dropping
    try:
        conn.execute(text(f"USE [master]; ALTER SERVER ROLE [{sysadmin_role}] DROP MEMBER [{sysadmin_user}];"))
        logger.info(f"User '{sysadmin_user}' removed from {sysadmin_role}")
    except Exception as e:
        logger.warning(f"Could not remove '{sysadmin_user}' from {sysadmin_role}: {str(e)}")

    # Remove DBA_Role from fixed server roles before dropping
    try:
        conn.execute(text(f"USE [master]; ALTER SERVER ROLE [processadmin] DROP MEMBER [{sysadmin_role}];"))
        conn.execute(text(f"USE [master]; ALTER SERVER ROLE [setupadmin] DROP MEMBER [{sysadmin_role}];"))
        logger.info("DBA_Role removed from processadmin and setupadmin fixed roles")
    except Exception as e:
        logger.warning(f"Could not remove DBA_Role from processadmin and setupadmin: {str(e)}")

    # Drop DBA_Role
    try:
        conn.execute(text(f"USE [master]; DROP SERVER ROLE [{sysadmin_role}];"))
        logger.info("DBA_Role dropped")
    except Exception as e:
        logger.warning(f"Could not drop DBA_Role: {str(e)}")

    # Drop login
    try:
        conn.execute(text(f"USE [master]; DROP LOGIN [{sysadmin_user}];"))
        logger.info(f"Login '{sysadmin_user}' dropped")
    except Exception as e:
        logger.warning(f"Could not drop login '{sysadmin_user}': {str(e)}")

    # Delete user credentials from vault if available
    if vault_details and vault_secret_path:
        try:
            vault.delete_secret(vault_details, f"{vault_secret_path}/{sysadmin_user}")
            logger.info(f"Deleted user {sysadmin_user} credentials from vault")
        except Exception as e:
            logger.warning(f"Could not delete '{sysadmin_user}' from vault: {str(e)}")

    conn.execute(text("USE [alembic];"))
    logger.info("Switched back to alembic database")