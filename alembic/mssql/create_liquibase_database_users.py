"""Create MSSQL logins and liquibase database

Revision ID: 0003
Revises: 0002
Create Date: 2026-04-06 10:00:00.000000

"""

from alembic import op, context
from sqlalchemy.sql import text
from shared.utils.secretsmanager import get_random_password
from shared.utils.logging_config import logger
import shared.utils.vault_utils as vault

revision = "0003"
down_revision = "0002"
branch_labels = None
depends_on = None

vault_details = context.config.attributes.get("vault_details")
vault_secret_path = context.config.attributes.get("vault_secret_path")
environment = context.config.attributes.get("environment")

liquibase_role = 'Deploy_Role'
liquibase_users = ['liquibase_dba', 'liquibase_dare', 'liquibase_deploy']
# Databases to create and use for liquibase users
databases = ['liquibase', 'appdb']


def upgrade():
    """
    Create MSSQL logins, server roles, database users, and databases required for Liquibase.
    Credentials for new users are stored in Vault.
    """
    conn = op.get_bind()

    # Use autocommit_block to escape implicit transactions for CREATE DATABASE
    # This is the ONLY reliable way to run CREATE DATABASE in MSSQL via Alembic
    with op.get_context().autocommit_block():
        # Force switch to master before checking/creating
        conn.execute(text("USE [master]"))
        for db in databases:
            try:
                db_exists = conn.execute(text(f"SELECT COUNT(*) FROM sys.databases WHERE name = '{db}'")).scalar()
                if db_exists:
                    logger.info(f"Database '{db}' already exists, skipping creation.")
                else:
                    conn.execute(text(f"CREATE DATABASE [{db}]"))
                    logger.info(f"Database '{db}' created successfully")
            except Exception as e:
                logger.warning(f"Database '{db}' creation warning: {str(e)}")

    # Define users to create with sysadmin role
    user_pwd_map = {user: get_random_password() for user in liquibase_users}

    # Create MSSQL logins and assign sysadmin role
    for user, paswd in user_pwd_map.items():
        # Escape percent signs for pymssql and single quotes for MSSQL string literals
        escaped_paswd = paswd.replace("%", "%%").replace("'", "''")
        login_created = False

        # Create login in MSSQL if it doesn't exist
        login_exists = conn.execute(text(f"SELECT COUNT(*) FROM sys.server_principals WHERE name = '{user}'")).scalar()
        if not login_exists:
            conn.execute(text(f"USE [master]; CREATE LOGIN [{user}] WITH PASSWORD = '{escaped_paswd}';"))
            logger.info(f"Login '{user}' created")
            login_created = True
        else:
            logger.info(f"Login '{user}' already exists")

        # Note: Cannot assign sysadmin in AWS RDS. Use processadmin and setupadmin instead.
        # For liquibase deployment users, these logins can be granted specific permissions as needed.

        # Store credentials in Vault if available
        if vault_details and vault_secret_path and login_created:
            try:
                secret = {
                    "username": user,
                    "password": paswd
                }
                vault.put_secret_to_vault(vault_details, f"{vault_secret_path}/{user}", secret)
                vault.update_metadata(vault_details, f"{vault_secret_path}/{user}")
                logger.info(f"User '{user}' created and credentials stored in Vault")
            except Exception as e:
                logger.warning(f"Could not store credentials for '{user}' in Vault: {str(e)}")
        elif vault_details and vault_secret_path:
            logger.info(f"Login '{user}' already exists, skipping Vault update")
        else:
            logger.info(f"Vault details not provided, skipping secret storage for '{user}'")

    # Create liquibase_role
    role_exists = conn.execute(text(f"SELECT COUNT(*) FROM sys.server_principals WHERE name = '{liquibase_role}' AND type = 'R'")).scalar()
    if not role_exists:
        conn.execute(text(f"USE [master]; CREATE SERVER ROLE [{liquibase_role}];"))
        logger.info(f"'{liquibase_role}' created")
    else:
        logger.info(f"Server role '{liquibase_role}' already exists")

    # Assign all liquibase_users to liquibase_role, fixed server roles, and grant permissions
    for user in liquibase_users:
        # Add user to liquibase_role
        conn.execute(text(f"USE [master]; ALTER SERVER ROLE [{liquibase_role}] ADD MEMBER [{user}];"))
        logger.info(f"User '{user}' assigned to {liquibase_role}")

        # Add user to fixed server roles
        conn.execute(text(f"USE [master]; ALTER SERVER ROLE [processadmin] ADD MEMBER [{user}];"))
        conn.execute(text(f"USE [master]; ALTER SERVER ROLE [setupadmin] ADD MEMBER [{user}];"))
        logger.info(f"User '{user}' assigned to processadmin and setupadmin roles")

        # Grant server-level permissions for schema automation
        conn.execute(text(f"USE [master]; GRANT CREATE ANY DATABASE TO [{user}];"))
        conn.execute(text(f"USE [master]; GRANT VIEW ANY DATABASE TO [{user}];"))
        conn.execute(text(f"USE [master]; GRANT VIEW ANY DEFINITION TO [{user}];"))
        conn.execute(text(f"USE [master]; GRANT VIEW SERVER STATE TO [{user}];"))
        conn.execute(text(f"USE [master]; GRANT ALTER ANY LOGIN TO [{user}];"))
        logger.info(f"Server-level permissions granted to '{user}'")

    target_db = "appdb"
    logger.info(f"Using target database: {target_db}")

    # Create database users in all databases for each login
    for db in databases:
        for user in liquibase_users:
            try:
                batch_sql = f"USE [{db}]; CREATE USER [{user}] FOR LOGIN [{user}];"
                batch_sql += f"\nALTER ROLE [db_owner] ADD MEMBER [{user}];"
                conn.execute(text(batch_sql))
                logger.info(f"Database user '{user}' created in {db} database and assigned to db_owner role")
            except Exception as e:
                if "already exists" in str(e).lower():
                    logger.info(f"Database user '{user}' already exists in {db}")
                else:
                    logger.warning(f"Could not create database user '{user}' in {db}: {str(e)}")

    conn.execute(text("USE [alembic];"))
    logger.info("Switched back to alembic database")


def downgrade():
    conn = op.get_bind()

    logger.info(f"Cleaning up databases: {databases}")

    # Drop database users from all databases
    for db in databases:
        for user in liquibase_users:
            try:
                batch_sql = f"""USE [{db}];
DROP USER [{user}];"""
                conn.execute(text(batch_sql))
                logger.info(f"Database user '{user}' dropped from {db} database")
            except Exception as e:
                logger.warning(f"Could not drop database user '{user}' from {db}: {str(e)}")

    # Remove all liquibase_users from liquibase_role
    try:
        for user in liquibase_users:
            conn.execute(text(f"USE [master]; ALTER SERVER ROLE [{liquibase_role}] DROP MEMBER [{user}];"))
            logger.info(f"User '{user}' removed from {liquibase_role}")
    except Exception as e:
        logger.warning(f"Could not remove liquibase_users from {liquibase_role}: {str(e)}")

    # Remove all liquibase_users from fixed server roles
    try:
        for user in liquibase_users:
            conn.execute(text(f"USE [master]; ALTER SERVER ROLE [processadmin] DROP MEMBER [{user}];"))
            conn.execute(text(f"USE [master]; ALTER SERVER ROLE [setupadmin] DROP MEMBER [{user}];"))
            logger.info(f"User '{user}' removed from processadmin and setupadmin roles")
    except Exception as e:
        logger.warning(f"Could not remove liquibase_users from fixed roles: {str(e)}")

    # Drop liquibase_role
    try:
        conn.execute(text(f"USE [master]; DROP SERVER ROLE [{liquibase_role}];"))
        logger.info(f"'{liquibase_role}' dropped")
    except Exception as e:
        logger.warning(f"Could not drop {liquibase_role}: {str(e)}")

    # Drop liquibase and appdb databases - set to single user mode first to close connections
    with op.get_context().autocommit_block():
        conn.execute(text("USE [master]"))
        for db in databases:
            try:
                conn.execute(text(f"ALTER DATABASE [{db}] SET SINGLE_USER WITH ROLLBACK IMMEDIATE"))
                conn.execute(text(f"DROP DATABASE [{db}]"))
                logger.info(f"Database '{db}' dropped")
            except Exception as e:
                logger.warning(f"Could not drop database '{db}': {str(e)}")

    # Drop logins
    for user in liquibase_users:
        try:
            conn.execute(text(f"USE [master]; DROP LOGIN [{user}];"))
            logger.info(f"Login '{user}' dropped")
        except Exception as e:
            logger.warning(f"Could not drop login '{user}': {str(e)}")

    # Delete user credentials from vault if available
    if vault_details and vault_secret_path:
        for user in liquibase_users:
            try:
                vault.delete_secret(vault_details, f"{vault_secret_path}/{user}")
                logger.info(f"Deleted user {user} credentials from vault")
            except Exception as e:
                logger.warning(f"Could not delete '{user}' from vault: {str(e)}")

    # CRITICAL: Switch back to the alembic database so the tool can update its version table
    conn.execute(text("USE [alembic];"))
    logger.info("Downgrade completed and switched back to alembic database")