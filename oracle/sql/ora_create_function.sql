--liquibase formatted sql

--changeset Day2_Create_Function:Password_Verify_Function runOnChange:true runWith:sqlplus
--comment:Create PASSWORD_COMPLEXITY_FUNCTION

ALTER SESSION SET CURRENT_SCHEMA=SYFADMIN;

CREATE OR REPLACE NONEDITIONABLE FUNCTION "PASSWORD_COMPLEXITY_FUNCTION"
(
    username     VARCHAR2,
    password     VARCHAR2,
    old_password VARCHAR2)
RETURN BOOLEAN
IS
    n                 BOOLEAN;
    m                 INTEGER;
    differ            INTEGER;
    isdigit           BOOLEAN;
    isupperchar       BOOLEAN;
    islowerchar       BOOLEAN;
    ispunct           BOOLEAN;
    db_name           VARCHAR2(40);
    digitarray        VARCHAR2(20);
    punctarray        VARCHAR2(25);
    chararray         VARCHAR2(52);
    i_char            VARCHAR2(10);
    simple_password   VARCHAR2(10);
    reverse_user      VARCHAR2(32);
    complexitysum     INTEGER;
    lowerchararray    VARCHAR2(26);
    upperchararray    VARCHAR2(26);
    upperarray        VARCHAR2(26);
    isdigit_counter   NUMBER;
    isdigit_bookend   BOOLEAN;
    iscontained       INTEGER;
    isrevcontained    INTEGER;
    isdigit_consective BOOLEAN;
BEGIN
    digitarray      := '0123456789';
    complexitysum   := 0;
    chararray       := 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    punctarray      := '!"#$%&()*+,-./:;<=>?_';
    lowerchararray  := 'abcdefghijklmnopqrstuvwxyz';
    upperchararray  := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    upperarray      := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

    -- Check for the minimum length of the password
    IF LENGTH(password) < 8 THEN
        raise_application_error(-20001, 'Password must be at least 8 character long,can not contain username or username reverse,must contain atleast one upper case letter and one lower case letter,must contain at least two digits but not consective, and one special character,and number in password can not be the first or last character ');
    END IF;

    -- Check if the password contains username or username reverse
    FOR i IN REVERSE 1..length(username)
    LOOP
        reverse_user := reverse_user || SUBSTR(username, i, 1);
    END LOOP;

    SELECT instr(lower(password),lower(username)) INTO iscontained FROM dual;
    SELECT instr(lower(password),lower(reverse_user)) INTO isrevcontained FROM dual;

    IF (iscontained > 0 OR isrevcontained > 0) THEN
        raise_application_error(-20001, 'Password must be at least 8 character long,can not contain username or username reverse,must contain atleast one upper case letter and one lower case letter,must contain at least two digits but not consective, and one special character,and number in password can not be the first or last character ');
    END IF;

    --Check for at least one upper case letter
    isupperchar := FALSE;
    m           := LENGTH(password);
    FOR i IN 1..length(upperchararray)
    LOOP
        FOR j IN 1..m
        LOOP
            IF SUBSTR(password,j,1) = SUBSTR(upperchararray,i,1) THEN
                isupperchar := TRUE;
                GOTO endupperchar;
            END IF;
        END LOOP;
    END LOOP;
    <<endupperchar>>

    IF isupperchar = FALSE THEN
        raise_application_error(-20001, 'Password must be at least 8 character long,can not contain username or username reverse,must contain atleast one upper case letter and one lower case letter,must contain at least two digits but not consective, and one special character,and number in password can not be the first or last character ');
    END IF;

    --Check for at least one lower case letter
    islowerchar := FALSE;
    m           := LENGTH(password);
    FOR i IN 1..length(lowerchararray)
    LOOP
        FOR j IN 1..m
        LOOP
            IF SUBSTR(password,j,1) = SUBSTR(lowerchararray,i,1) THEN
                islowerchar := TRUE;
                GOTO endlowerchar;
            END IF;
        END LOOP;
    END LOOP;
    <<endlowerchar>>

    IF islowerchar = FALSE THEN
        raise_application_error(-20001, 'Password must be at least 8 character long,can not contain username or username reverse,must contain atleast one upper case letter and one lower case letter,must contain at least two digits but not consective, and one special character,and number in password can not be the first or last character ');
    END IF;

    -- Check to make sure that first or last characters are not digits
    isdigit_bookend := FALSE;
    m               := LENGTH(password);
    FOR i IN 1..10
    LOOP
        IF ( SUBSTR(password,m,1) = SUBSTR(digitarray,i,1) ) THEN
            isdigit_bookend := TRUE;
            GOTO numends;
        END IF;
    END LOOP;

    FOR i IN 1..10
    LOOP
        IF ( SUBSTR(password,1,1) = SUBSTR(digitarray,i,1) ) THEN
            isdigit_bookend := TRUE;
            GOTO numends;
        END IF;
    END LOOP;
    <<numends>>

    IF isdigit_bookend = TRUE THEN
        raise_application_error(-20001, 'Password must be at least 8 character long,can not contain username or username reverse,must contain atleast one upper case letter and one lower case letter,must contain at least two digits but not consective, and one special character,and number in password can not be the first or last character ');
    END IF;

    -- Check if the password contains at least two digits but not consective, and one special cha
    -- 1. Check for 2 digits
    isdigit         := FALSE;
    isdigit_counter := 0;
    m               := LENGTH(password);
    FOR i IN 1..10
    LOOP
        FOR j IN 1..m
        LOOP
            IF SUBSTR(password,j,1) = SUBSTR(digitarray,i,1) THEN
                isdigit_counter := isdigit_counter + 1;
                IF isdigit_counter >= 2 THEN
                    isdigit := TRUE;
                    GOTO findpunct;
                END IF;
            END IF;
        END LOOP;
    END LOOP;

    IF isdigit = FALSE THEN
        raise_application_error(-20001, 'Password must be at least 8 character long,can not contain username or username reverse,must contain atleast one upper case letter and one lower case letter,must contain at least two digits but not consective, and one special character,and number in password can not be the first or last character ');
    END IF;

    --2. Check for the punctuation
    <<findpunct>>
    ispunct := FALSE;
    FOR i IN 1..length(punctarray)
    LOOP
        FOR j IN 1..m
        LOOP
            IF SUBSTR(password,j,1) = SUBSTR(punctarray,i,1) THEN
                ispunct := TRUE;
                GOTO findconsective;
            END IF;
        END LOOP;
    END LOOP;

    IF ispunct = FALSE THEN
        raise_application_error(-20001, 'Password must be at least 8 character long,can not contain username or username reverse,must contain atleast one upper case letter and one lower case letter,must contain at least two digits but not consective, and one special character,and number in password can not be the first or last character ');
    END IF;

    --3. check if contains consective digits
    <<findconsective>>
    isdigit_consective := FALSE;
    m                  := LENGTH(password);
    FOR i IN 1..m
    LOOP
        IF SUBSTR(password,i,2) IN ('01','12','23','34','45','56','67','78','89') THEN
            isdigit_consective := TRUE;
            raise_application_error(-20001, 'Password must be at least 8 character long,can not contain username or username reverse,must contain atleast one upper case letter and one lower case letter,must contain at least two digits but not consective, and one special character,and number in password can not be the first or last character ');
        END IF;
    END LOOP;

    -- Everything is fine; return TRUE ;
    <<endcheck>>
    RETURN(TRUE);
END;
/

--rollback DROP FUNCTION SYFADMIN.PASSWORD_COMPLEXITY_FUNCTION;

--------------------------------------------------------------------------------

--changeset Day2_Create_Function:RDS_Password_Verify_Function runOnChange:true runWith:sqlplus
--comment:Create RDS PASSWORD_COMPLEXITY_FUNCTION

ALTER SESSION SET CURRENT_SCHEMA=SYS;

begin
rdsadmin.rdsadmin_password_verify.create_passthrough_verify_fcn(
p_verify_function_name => 'PASSWORD_COMPLEXITY_FUNCTION',
p_target_owner         => 'SYFADMIN',
p_target_function_name => 'PASSWORD_COMPLEXITY_FUNCTION');
end;
/

ALTER PROFILE DEFAULT LIMIT PASSWORD_VERIFY_FUNCTION PASSWORD_COMPLEXITY_FUNCTION;

--rollback not required