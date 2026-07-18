"""Create app users and required databases

Revision ID: 0004
Revises: 0003
Create Date: 2026-04-06 10:00:00.000000

"""

from alembic import op, context
from sqlalchemy.sql import text
from shared.utils.secretsmanager import get_random_password
from shared.utils.logging_config import logger
import shared.utils.vault_utils as vault

revision = "0004"
down_revision = "0003"
branch_labels = None
depends_on = None

vault_details = context.config.attributes.get("vault_details")
vault_secret_path = context.config.attributes.get("vault_secret_path")
environment = context.config.attributes.get("environment")

# app_users are the application users
app_roles = ['app_ro_role', 'app_rw_role']
app_users = ['app_ro', 'app_rw']


def upgrade():
    conn = op.get_bind()

    target_db = "appdb"
    logger.info(f"Using database: {target_db}")

    # Define app users to create with random passwords
    user_pwd_map = {user: get_random_password() for user in app_users}

    # Create server-level logins for app users
    for user, paswd in user_pwd_map.items():
        # Escape percent signs for pymssql and single quotes for MSSQL string literals
        escaped_paswd = paswd.replace("%", "%%").replace("'", "''")

        # Create login in master database
        conn.execute(text(f"USE [master]; CREATE LOGIN [{user}] WITH PASSWORD = '{escaped_paswd}';"))
        logger.info(f"Login '{user}' created")

        # Store credentials in Vault if available
        if vault_details and vault_secret_path:
            try:
                secret = {
                    "username": user,
                    "password": paswd
                }
                vault.put_secret_to_vault(vault_details, f"{vault_secret_path}/{user}", secret)
                vault.update_metadata(vault_details, f"{vault_secret_path}/{user}")
                logger.info(f"Credentials for '{user}' stored in Vault")
            except Exception as e:
                logger.warning(f"Could not store credentials for '{user}' in Vault: {str(e)}")

    # Create application roles in target database
    batch_sql = f"USE [{target_db}];\n"
    
    for role in app_roles:
        batch_sql += f"CREATE ROLE [{role}];\n"
        
    for i, role in enumerate(app_roles):
        batch_sql += f"ALTER ROLE [db_datareader] ADD MEMBER [{role}];\n"
        if i == 1:
            batch_sql += f"ALTER ROLE [db_datawriter] ADD MEMBER [{role}];\n"
        batch_sql += f"GRANT EXECUTE ON SCHEMA::[dbo] TO [{role}];\n"

    conn.execute(text(batch_sql))
    logger.info(f"Created roles and granted permissions: {', '.join(app_roles)}")

    # Create database users for app users and assign roles
    for user, role in zip(app_users, app_roles):
        batch_sql = f"""USE [{target_db}];
CREATE USER [{user}] FOR LOGIN [{user}];
ALTER ROLE [{role}] ADD MEMBER [{user}];
ALTER ROLE [db_datareader] ADD MEMBER [{user}];"""
        if user == 'app_rw':
            batch_sql += f"\nALTER ROLE [db_datawriter] ADD MEMBER [{user}];"

        conn.execute(text(batch_sql))
        logger.info(f"Database user '{user}' created and assigned to {role}")

    conn.execute(text("USE [alembic];"))
    logger.info("Switched back to alembic database")


def downgrade():
    conn = op.get_bind()

    target_db = "appdb"
    logger.info(f"Using database for cleanup: {target_db}")

    # Drop database users from target database
    for user in app_users:
        try:
            batch_sql = f"""USE [{target_db}];
DROP USER [{user}];"""
            conn.execute(text(batch_sql))
            logger.info(f"Database user '{user}' dropped")
        except Exception as e:
            logger.warning(f"Could not drop database user '{user}': {str(e)}")

    # Remove application roles from fixed database roles before dropping
    try:
        batch_sql = f"""USE [{target_db}];
ALTER ROLE [db_datareader] DROP MEMBER [app_ro_role];
ALTER ROLE [db_datareader] DROP MEMBER [app_rw_role];
ALTER ROLE [db_datawriter] DROP MEMBER [app_rw_role];"""
        conn.execute(text(batch_sql))
        logger.info(f"Removed roles from fixed database roles: {', '.join(app_roles)}")
    except Exception as e:
        logger.warning(f"Could not remove application role memberships: {str(e)}")

    # Drop application roles from target database
    try:
        batch_sql = f"USE [{target_db}];\n"
        for role in app_roles:
            batch_sql += f"DROP ROLE [{role}];\n"
        
        conn.execute(text(batch_sql))
        logger.info(f"Dropped roles: {', '.join(app_roles)}")
    except Exception as e:
        logger.warning(f"Could not drop application roles: {str(e)}")

    # Drop server-level logins
    for user in app_users:
        try:
            conn.execute(text(f"USE [master]; DROP LOGIN [{user}];"))
            logger.info(f"Login '{user}' dropped")
        except Exception as e:
            logger.warning(f"Could not drop login '{user}': {str(e)}")

    # Delete credentials from vault if available and not in prod
    if vault_details and vault_secret_path and environment != "prod":
        for user in app_users:
            try:
                vault.delete_secret(vault_details, f"{vault_secret_path}/{user}")
                logger.info(f"Deleted credentials for '{user}' from Vault")
            except Exception as e:
                logger.warning(f"Could not delete credentials for '{user}' from Vault: {str(e)}")

    conn.execute(text("USE [alembic];"))
    logger.info("Switched back to alembic database")