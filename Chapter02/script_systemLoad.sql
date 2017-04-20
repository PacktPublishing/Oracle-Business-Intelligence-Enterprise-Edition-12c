SET VERIFY OFF;

CREATE  TABLESPACE "TESTONE_BIPLATFORM" EXTENT MANAGEMENT LOCAL  AUTOALLOCATE  SEGMENT SPACE MANAGEMENT  AUTO  DATAFILE 'C:\ORACLEXE\APP\ORACLE\ORADATA\XE/TESTONE_biplatform.dbf' SIZE 64M REUSE  AUTOEXTEND ON NEXT 16M MAXSIZE 1024M ;

CREATE  TEMPORARY  TABLESPACE "TESTONE_IAS_TEMP" EXTENT MANAGEMENT LOCAL  TEMPFILE 'C:\ORACLEXE\APP\ORACLE\ORADATA\XE/TESTONE_iastemp.dbf' SIZE 100M REUSE  AUTOEXTEND ON NEXT 50M MAXSIZE  UNLIMITED  ;

CREATE  TABLESPACE "TESTONE_STB" EXTENT MANAGEMENT LOCAL  AUTOALLOCATE  SEGMENT SPACE MANAGEMENT  AUTO  DATAFILE 'C:\ORACLEXE\APP\ORACLE\ORADATA\XE/TESTONE_svctbl.dbf' SIZE 10M REUSE  AUTOEXTEND ON NEXT 2M MAXSIZE  UNLIMITED  ;

CREATE  TABLESPACE "TESTONE_WLS" EXTENT MANAGEMENT LOCAL  AUTOALLOCATE  SEGMENT SPACE MANAGEMENT  AUTO  DATAFILE 'C:\ORACLEXE\APP\ORACLE\ORADATA\XE/TESTONE_wlsservices.dbf' SIZE 60M REUSE  AUTOEXTEND ON NEXT 10M MAXSIZE  UNLIMITED  ;

CREATE  TABLESPACE "TESTONE_IAS_OPSS" EXTENT MANAGEMENT LOCAL  AUTOALLOCATE  SEGMENT SPACE MANAGEMENT  AUTO  DATAFILE 'C:\ORACLEXE\APP\ORACLE\ORADATA\XE/TESTONE_ias_opss.dbf' SIZE 60M REUSE  AUTOEXTEND ON NEXT 10240K MAXSIZE  UNLIMITED  ;

CREATE  TABLESPACE "TESTONE_IAU" EXTENT MANAGEMENT LOCAL  AUTOALLOCATE  SEGMENT SPACE MANAGEMENT  AUTO  DATAFILE 'C:\ORACLEXE\APP\ORACLE\ORADATA\XE/TESTONE_iau.dbf' SIZE 60M REUSE  AUTOEXTEND ON NEXT 10240K MAXSIZE  UNLIMITED  ;

CREATE  TABLESPACE "TESTONE_MDS" EXTENT MANAGEMENT LOCAL  AUTOALLOCATE  SEGMENT SPACE MANAGEMENT  AUTO  DATAFILE 'C:\ORACLEXE\APP\ORACLE\ORADATA\XE/TESTONE_mds.dbf' SIZE 100M REUSE  AUTOEXTEND ON NEXT 50M MAXSIZE 1000M ;

CREATE  TABLESPACE "TESTONE_IAS_UMS" EXTENT MANAGEMENT LOCAL  AUTOALLOCATE  SEGMENT SPACE MANAGEMENT  AUTO  DATAFILE 'C:\ORACLEXE\APP\ORACLE\ORADATA\XE/TESTONE_UMS.dbf' SIZE 100M REUSE  AUTOEXTEND ON NEXT 30M MAXSIZE  UNLIMITED  ;

---------------------------------------------------------
---------- MDS(Metadata Services) SECTION STARTS ----------
---------------------------------------------------------


DECLARE
BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE SYSTEM.SCHEMA_VERSION_REGISTRY$ ADD EDITION VARCHAR2(30)';
EXCEPTION WHEN OTHERS THEN  NULL;
END;
/

DECLARE
compCnt NUMBER;
BEGIN
  SELECT COUNT(*) INTO compCnt FROM SCHEMA_VERSION_REGISTRY
  WHERE MRC_NAME='TESTONE' and COMP_ID='MDS';
  IF compCnt = 0 THEN
  INSERT INTO SYSTEM.SCHEMA_VERSION_REGISTRY$   (comp_id, comp_name, mrc_name, mr_name,  mr_type, owner, version, status, edition, custom1)   VALUES ('MDS', 'Metadata Services', 'TESTONE', 'MDS', 'MDS', 'TESTONE_MDS', '12.2.1.0.0', 'LOADING', '', 8192);
  END IF;
END;

/

DECLARE
BEGIN
    EXECUTE IMMEDIATE 'CREATE ROLE REGISTRYACCESS';
EXCEPTION WHEN OTHERS THEN  NULL;
END;
/

GRANT SELECT, INSERT, UPDATE, DELETE ON SYSTEM.SCHEMA_VERSION_REGISTRY$ TO REGISTRYACCESS
/

GRANT SELECT, INSERT, UPDATE, DELETE ON SYSTEM.SCHEMA_VERSION_REGISTRY TO REGISTRYACCESS
/

accept SCHEMA_PASSWORD char prompt "Enter the schema password : " hide;
begin
 execute immediate 'CREATE USER TESTONE_MDS IDENTIFIED BY "&SCHEMA_PASSWORD" DEFAULT TABLESPACE TESTONE_MDS TEMPORARY TABLESPACE TESTONE_IAS_TEMP'; 
end;

/

GRANT connect TO TESTONE_MDS
/

GRANT create type TO TESTONE_MDS
/

GRANT create procedure TO TESTONE_MDS
/

GRANT create table TO TESTONE_MDS
/

GRANT create sequence TO TESTONE_MDS
/

GRANT execute on dbms_lob to TESTONE_MDS
/

ALTER USER TESTONE_MDS QUOTA unlimited ON TESTONE_MDS
/

DECLARE
    cnt           NUMBER;

    package_not_found EXCEPTION;
    PRAGMA EXCEPTION_INIT(package_not_found, -00942);

    insufficient_privs EXCEPTION;
    PRAGMA EXCEPTION_INIT(insufficient_privs, -01031);
BEGIN

    cnt := 0;
    SELECT count(*) INTO cnt FROM dba_tab_privs WHERE grantee = 'PUBLIC'
               AND owner='SYS' AND table_name='DBMS_OUTPUT'
               AND privilege='EXECUTE';
    IF (cnt = 0) THEN
        -- Grant MDS user execute on dbms_output only if PUBLIC
        -- doesn't have the privilege.
        EXECUTE IMMEDIATE 'GRANT execute ON dbms_output TO TESTONE_MDS';
    END IF;

    cnt := 0;
    SELECT count(*) INTO cnt FROM dba_tab_privs WHERE grantee = 'PUBLIC'
               AND owner='SYS' AND table_name='DBMS_STATS'
               AND privilege='EXECUTE';
    IF (cnt = 0) THEN
        -- Grant MDS user execute on dbms_stats only if PUBLIC
        -- doesn't have the privilege.
        EXECUTE IMMEDIATE 'GRANT execute ON dbms_stats TO TESTONE_MDS';
    END IF;

    EXCEPTION
       -- If the user doesn't have privilege to access dbms_* package,
       -- database will report that the package cannot be found. RCU
       -- even doesn't throw the exception to the user, since ORA-00942
       -- is an ignored error defined in its global configuration xml
      -- file. 
       WHEN package_not_found THEN
           RAISE insufficient_privs;
       WHEN OTHERS THEN
           RAISE;
END;

/

UPDATE SYSTEM.SCHEMA_VERSION_REGISTRY SET status='LOADED' WHERE comp_id='MDS'  AND mrc_name='TESTONE'
/

GRANT REGISTRYACCESS TO TESTONE_MDS
/

---------------------------------------------------------
---------- MDS(Metadata Services) SECTION ENDS ----------
---------------------------------------------------------


---------------------------------------------------------
---------- WLS(WebLogic Services) SECTION STARTS ----------
---------------------------------------------------------


DECLARE
BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE SYSTEM.SCHEMA_VERSION_REGISTRY$ ADD EDITION VARCHAR2(30)';
EXCEPTION WHEN OTHERS THEN  NULL;
END;
/

DECLARE
compCnt NUMBER;
BEGIN
  SELECT COUNT(*) INTO compCnt FROM SCHEMA_VERSION_REGISTRY
  WHERE MRC_NAME='TESTONE' and COMP_ID='WLS';
  IF compCnt = 0 THEN
  INSERT INTO SYSTEM.SCHEMA_VERSION_REGISTRY$   (comp_id, comp_name, mrc_name, mr_name,  mr_type, owner, version, status, edition, custom1)   VALUES ('WLS', 'WebLogic Services', 'TESTONE', 'WLS', 'WLS', 'TESTONE_WLS', '12.2.1.0.0', 'LOADING', '', 0);
  END IF;
END;

/

DECLARE
BEGIN
    EXECUTE IMMEDIATE 'CREATE ROLE REGISTRYACCESS';
EXCEPTION WHEN OTHERS THEN  NULL;
END;
/

GRANT SELECT, INSERT, UPDATE, DELETE ON SYSTEM.SCHEMA_VERSION_REGISTRY$ TO REGISTRYACCESS
/

GRANT SELECT, INSERT, UPDATE, DELETE ON SYSTEM.SCHEMA_VERSION_REGISTRY TO REGISTRYACCESS
/

accept SCHEMA_PASSWORD char prompt "Enter the schema password : " hide;
begin
 execute immediate 'CREATE USER TESTONE_WLS IDENTIFIED BY &SCHEMA_PASSWORD DEFAULT TABLESPACE TESTONE_WLS TEMPORARY TABLESPACE TESTONE_IAS_TEMP'; 
end;

/

GRANT connect TO TESTONE_WLS
/

GRANT create type TO TESTONE_WLS
/

GRANT create procedure TO TESTONE_WLS
/

GRANT create table TO TESTONE_WLS
/

GRANT create sequence TO TESTONE_WLS
/

GRANT create any index to TESTONE_WLS
/

GRANT create any trigger to TESTONE_WLS
/

GRANT create any table to TESTONE_WLS
/

GRANT create any view to TESTONE_WLS
/

ALTER USER TESTONE_WLS QUOTA unlimited ON TESTONE_WLS
/

accept SCHEMA_PASSWORD char prompt "Enter the schema password : " hide;
begin
 execute immediate 'CREATE USER TESTONE_WLS_RUNTIME IDENTIFIED BY &ADDITIONAL_SCHEMA_PASSWORD1 DEFAULT TABLESPACE TESTONE_WLS TEMPORARY TABLESPACE TESTONE_IAS_TEMP'; 
end;

/

GRANT connect TO TESTONE_WLS_RUNTIME
/

GRANT create type TO TESTONE_WLS_RUNTIME
/

GRANT create procedure TO TESTONE_WLS_RUNTIME
/

GRANT create table TO TESTONE_WLS_RUNTIME
/

GRANT create sequence TO TESTONE_WLS_RUNTIME
/

GRANT create any index to TESTONE_WLS_RUNTIME
/

GRANT create any trigger to TESTONE_WLS_RUNTIME
/

ALTER USER TESTONE_WLS_RUNTIME QUOTA unlimited ON TESTONE_WLS
/

UPDATE SYSTEM.SCHEMA_VERSION_REGISTRY SET status='LOADED' WHERE comp_id='WLS'  AND mrc_name='TESTONE'
/

GRANT REGISTRYACCESS TO TESTONE_WLS
/

---------------------------------------------------------
---------- WLS(WebLogic Services) SECTION ENDS ----------
---------------------------------------------------------


---------------------------------------------------------
---------- STB(Common Infrastructure Services) SECTION STARTS ----------
---------------------------------------------------------


DECLARE
BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE SYSTEM.SCHEMA_VERSION_REGISTRY$ ADD EDITION VARCHAR2(30)';
EXCEPTION WHEN OTHERS THEN  NULL;
END;
/

DECLARE
compCnt NUMBER;
BEGIN
  SELECT COUNT(*) INTO compCnt FROM SCHEMA_VERSION_REGISTRY
  WHERE MRC_NAME='TESTONE' and COMP_ID='STB';
  IF compCnt = 0 THEN
  INSERT INTO SYSTEM.SCHEMA_VERSION_REGISTRY$   (comp_id, comp_name, mrc_name, mr_name,  mr_type, owner, version, status, edition, custom1)   VALUES ('STB', 'Service Table', 'TESTONE', 'STB', 'STB', 'TESTONE_STB', '12.1.3.0.0', 'LOADING', '', 8192);
  END IF;
END;

/

DECLARE
BEGIN
    EXECUTE IMMEDIATE 'CREATE ROLE REGISTRYACCESS';
EXCEPTION WHEN OTHERS THEN  NULL;
END;
/

GRANT SELECT, INSERT, UPDATE, DELETE ON SYSTEM.SCHEMA_VERSION_REGISTRY$ TO REGISTRYACCESS
/

GRANT SELECT, INSERT, UPDATE, DELETE ON SYSTEM.SCHEMA_VERSION_REGISTRY TO REGISTRYACCESS
/

accept SCHEMA_PASSWORD char prompt "Enter the schema password : " hide;
begin
 execute immediate 'CREATE USER TESTONE_STB IDENTIFIED BY &SCHEMA_PASSWORD DEFAULT TABLESPACE TESTONE_STB TEMPORARY TABLESPACE TESTONE_IAS_TEMP'; 
end;

/

GRANT connect TO TESTONE_STB
/

GRANT create type TO TESTONE_STB
/

GRANT create procedure TO TESTONE_STB
/

GRANT create table TO TESTONE_STB
/

GRANT create sequence TO TESTONE_STB
/

GRANT create any index to TESTONE_STB
/

GRANT create any trigger to TESTONE_STB
/

GRANT select on schema_version_registry to TESTONE_STB
/

ALTER USER TESTONE_STB QUOTA unlimited ON TESTONE_STB
/

DECLARE
BEGIN
    EXECUTE IMMEDIATE 'CREATE ROLE STBROLE';
EXCEPTION
    WHEN OTHERS THEN  NULL;
END;

/

SET ECHO ON
/

SET FEEDBACK 1
/

SET NUMWIDTH 10
/

SET LINESIZE 80
/

SET TRIMSPOOL ON
/

SET TAB OFF
/

SET PAGESIZE 100
/

ALTER SESSION SET CURRENT_SCHEMA=TESTONE_STB
/

CREATE TABLE "SERVICETABLE"
(
  "ID" VARCHAR2(50) PRIMARY KEY,
  "STYPE" VARCHAR2(50) NOT NULL,
  "ENDPOINT" CLOB NOT NULL,
  "LASTUPDATED" TIMESTAMP NOT NULL,
  "PROMOTED" CHAR(1) check (PROMOTED in ( 'Y', 'N' )) NOT NULL,
  "VALID" CHAR(1) check (VALID in ( 'Y', 'N' )) NOT NULL
)
/

CREATE INDEX SERVICETABLE_IDX ON SERVICETABLE(STYPE)
/

CREATE TABLE "COMPONENT_SCHEMA_INFO"
(
  "SCHEMA_USER"     VARCHAR2(100) NOT NULL,
  "SCHEMA_PASSWORD" BLOB ,
  "COMP_ID" VARCHAR2(100) NOT NULL,
  "PREFIX_NAME"     VARCHAR2(100) ,
  "DB_HOSTNAME"     VARCHAR2(255) ,
  "DB_SERVICE"      VARCHAR2(200) ,
  "DB_PORTNUMBER"   VARCHAR2(10),
  "DATABASE_NAME"   VARCHAR2(200),
  "STATUS"          VARCHAR2(20)
)
/

CREATE INDEX COMPONENT_SCHEMA_INFO_IDX ON COMPONENT_SCHEMA_INFO(SCHEMA_USER)
/


GRANT SELECT, INSERT, UPDATE, DELETE ON TESTONE_STB.COMPONENT_SCHEMA_INFO TO STBROLE

/

UPDATE SYSTEM.SCHEMA_VERSION_REGISTRY SET status='LOADED' WHERE comp_id='STB'  AND mrc_name='TESTONE'
/

GRANT REGISTRYACCESS TO TESTONE_STB
/

---------------------------------------------------------
---------- STB(Common Infrastructure Services) SECTION ENDS ----------
---------------------------------------------------------


---------------------------------------------------------
---------- IAU_APPEND(Audit Services Append) SECTION STARTS ----------
---------------------------------------------------------


DECLARE
BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE SYSTEM.SCHEMA_VERSION_REGISTRY$ ADD EDITION VARCHAR2(30)';
EXCEPTION WHEN OTHERS THEN  NULL;
END;
/

DECLARE
compCnt NUMBER;
BEGIN
  SELECT COUNT(*) INTO compCnt FROM SCHEMA_VERSION_REGISTRY
  WHERE MRC_NAME='TESTONE' and COMP_ID='IAU_APPEND';
  IF compCnt = 0 THEN
  INSERT INTO SYSTEM.SCHEMA_VERSION_REGISTRY$   (comp_id, comp_name, mrc_name, mr_name,  mr_type, owner, version, status, edition, custom1)   VALUES ('IAU_APPEND', 'Audit Service Append', 'TESTONE', 'IAU_APPEND', 'IAU_APPEND', 'TESTONE_IAU_APPEND', '12.2.1.0.0', 'LOADING', '', 0);
  END IF;
END;

/

DECLARE
BEGIN
    EXECUTE IMMEDIATE 'CREATE ROLE REGISTRYACCESS';
EXCEPTION WHEN OTHERS THEN  NULL;
END;
/

GRANT SELECT, INSERT, UPDATE, DELETE ON SYSTEM.SCHEMA_VERSION_REGISTRY$ TO REGISTRYACCESS
/

GRANT SELECT, INSERT, UPDATE, DELETE ON SYSTEM.SCHEMA_VERSION_REGISTRY TO REGISTRYACCESS
/

SET ECHO ON
/

SET FEEDBACK 1
/

SET NUMWIDTH 10
/

SET LINESIZE 80
/

SET TRIMSPOOL ON
/

SET TAB OFF
/

SET PAGESIZE 100
/

accept SCHEMA_PASSWORD char prompt "Enter the schema password : " hide;
begin
 execute immediate 'CREATE USER TESTONE_IAU_APPEND
IDENTIFIED BY &SCHEMA_PASSWORD
DEFAULT TABLESPACE TESTONE_IAU
TEMPORARY TABLESPACE TESTONE_IAS_TEMP'; 
end;

/

GRANT RESOURCE TO TESTONE_IAU_APPEND
/

GRANT UNLIMITED TABLESPACE to TESTONE_IAU_APPEND
/

GRANT CONNECT to TESTONE_IAU_APPEND
/

GRANT CREATE TABLE TO TESTONE_IAU_APPEND
/

GRANT CREATE MATERIALIZED VIEW TO TESTONE_IAU_APPEND
/

UPDATE SYSTEM.SCHEMA_VERSION_REGISTRY SET status='LOADED' WHERE comp_id='IAU_APPEND'  AND mrc_name='TESTONE'
/

GRANT REGISTRYACCESS TO TESTONE_IAU_APPEND
/

---------------------------------------------------------
---------- IAU_APPEND(Audit Services Append) SECTION ENDS ----------
---------------------------------------------------------


---------------------------------------------------------
---------- IAU_VIEWER(Audit Services Viewer) SECTION STARTS ----------
---------------------------------------------------------


DECLARE
BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE SYSTEM.SCHEMA_VERSION_REGISTRY$ ADD EDITION VARCHAR2(30)';
EXCEPTION WHEN OTHERS THEN  NULL;
END;
/

DECLARE
compCnt NUMBER;
BEGIN
  SELECT COUNT(*) INTO compCnt FROM SCHEMA_VERSION_REGISTRY
  WHERE MRC_NAME='TESTONE' and COMP_ID='IAU_VIEWER';
  IF compCnt = 0 THEN
  INSERT INTO SYSTEM.SCHEMA_VERSION_REGISTRY$   (comp_id, comp_name, mrc_name, mr_name,  mr_type, owner, version, status, edition, custom1)   VALUES ('IAU_VIEWER', 'Audit Service Viewer', 'TESTONE', 'IAU_VIEWER', 'IAU_VIEWER', 'TESTONE_IAU_VIEWER', '12.2.1.0.0', 'LOADING', '', 0);
  END IF;
END;

/

DECLARE
BEGIN
    EXECUTE IMMEDIATE 'CREATE ROLE REGISTRYACCESS';
EXCEPTION WHEN OTHERS THEN  NULL;
END;
/

GRANT SELECT, INSERT, UPDATE, DELETE ON SYSTEM.SCHEMA_VERSION_REGISTRY$ TO REGISTRYACCESS
/

GRANT SELECT, INSERT, UPDATE, DELETE ON SYSTEM.SCHEMA_VERSION_REGISTRY TO REGISTRYACCESS
/

accept SCHEMA_PASSWORD char prompt "Enter the schema password : " hide;
begin
 execute immediate 'CREATE USER TESTONE_IAU_VIEWER
IDENTIFIED BY &SCHEMA_PASSWORD
DEFAULT TABLESPACE TESTONE_IAU
TEMPORARY TABLESPACE TESTONE_IAS_TEMP'; 
end;

/

GRANT RESOURCE TO TESTONE_IAU_VIEWER
/

GRANT UNLIMITED TABLESPACE to TESTONE_IAU_VIEWER
/

GRANT CONNECT to TESTONE_IAU_VIEWER
/

GRANT CREATE VIEW to TESTONE_IAU_VIEWER
/

GRANT CREATE SYNONYM TO TESTONE_IAU_VIEWER
/

UPDATE SYSTEM.SCHEMA_VERSION_REGISTRY SET status='LOADED' WHERE comp_id='IAU_VIEWER'  AND mrc_name='TESTONE'
/

GRANT REGISTRYACCESS TO TESTONE_IAU_VIEWER
/

---------------------------------------------------------
---------- IAU_VIEWER(Audit Services Viewer) SECTION ENDS ----------
---------------------------------------------------------


---------------------------------------------------------
---------- UCSUMS(User Messaging Service) SECTION STARTS ----------
---------------------------------------------------------


DECLARE
BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE SYSTEM.SCHEMA_VERSION_REGISTRY$ ADD EDITION VARCHAR2(30)';
EXCEPTION WHEN OTHERS THEN  NULL;
END;
/

DECLARE
compCnt NUMBER;
BEGIN
  SELECT COUNT(*) INTO compCnt FROM SCHEMA_VERSION_REGISTRY
  WHERE MRC_NAME='TESTONE' and COMP_ID='UCSUMS';
  IF compCnt = 0 THEN
  INSERT INTO SYSTEM.SCHEMA_VERSION_REGISTRY$   (comp_id, comp_name, mrc_name, mr_name,  mr_type, owner, version, status, edition, custom1)   VALUES ('UCSUMS', 'User Messaging Service', 'TESTONE', 'UCSUMS', 'UCSUMS', 'TESTONE_UMS', '12.2.1.0.0', 'LOADING', '', 8192);
  END IF;
END;

/

DECLARE
BEGIN
    EXECUTE IMMEDIATE 'CREATE ROLE REGISTRYACCESS';
EXCEPTION WHEN OTHERS THEN  NULL;
END;
/

GRANT SELECT, INSERT, UPDATE, DELETE ON SYSTEM.SCHEMA_VERSION_REGISTRY$ TO REGISTRYACCESS
/

GRANT SELECT, INSERT, UPDATE, DELETE ON SYSTEM.SCHEMA_VERSION_REGISTRY TO REGISTRYACCESS
/

define schema_user = TESTONE_UMS

define schema_password = &SCHEMA_PASSWORD

define default_tablespace = TESTONE_IAS_UMS

define temp_tablespace = TESTONE_IAS_TEMP

accept SCHEMA_PASSWORD char prompt "Enter the schema password : " hide;
begin
 execute immediate 'create user TESTONE_UMS identified by &SCHEMA_PASSWORD'; 
end;

/

alter user TESTONE_UMS default tablespace TESTONE_IAS_UMS
/

alter user TESTONE_UMS temporary tablespace TESTONE_IAS_TEMP
/

alter user TESTONE_UMS quota unlimited on TESTONE_IAS_UMS
/

grant CREATE SESSION to TESTONE_UMS
/

grant CREATE TABLE to TESTONE_UMS
/

grant execute on sys.dbms_aq to TESTONE_UMS
/

grant execute on sys.dbms_aqadm to TESTONE_UMS
/

grant aq_administrator_role to TESTONE_UMS
/

grant aq_user_role to TESTONE_UMS
/

ALTER SESSION SET CURRENT_SCHEMA=TESTONE_UMS

/

CREATE TABLE ACCESS_POINT
(
    IDENTIFIER VARCHAR2(512) NOT NULL,
    AP_TYPE VARCHAR2(32),
    DELIVERY_TYPE VARCHAR2(32) NOT NULL,
    ADDRESS_VALUE VARCHAR2(512) NOT NULL,
    KEYWORD VARCHAR2(350),
    METADATA BLOB
)
/

ALTER TABLE ACCESS_POINT
    ADD CONSTRAINT ACCESS_POINT_PK PRIMARY KEY (IDENTIFIER)
/

CREATE TABLE ADDRESS
(
    ADDR_ID VARCHAR2(64) NOT NULL,
    DELIVERY_TYPE VARCHAR2(32),
    FAILOVER_ADDRESS_ID VARCHAR2(64),
    METADATA BLOB,
    ORIGINAL_RECIPIENT VARCHAR2(64),
    SUCCESS_STATUS VARCHAR2(128),
    TIMEOUT NUMBER,
    TYPE VARCHAR2(32),
    VALUE VARCHAR2(512),
    RECIPIENT_ID VARCHAR2(64),
    ADDRESS_STRING VARCHAR2(512),
    CREATION_DATE TIMESTAMP
)
/

ALTER TABLE ADDRESS
    ADD CONSTRAINT ADDRESS_PK PRIMARY KEY (ADDR_ID)
/

CREATE INDEX ADDRESS_FAILOVER_ADDRESS_IDX ON ADDRESS
    (FAILOVER_ADDRESS_ID )
/

CREATE TABLE CLIENT
(
    APPLICATION_NAME VARCHAR2(128) NOT NULL,
    TIME_STAMP TIMESTAMP,
    LOCK_VERSION NUMBER(12,0),
    AUTHORIZATION_ID VARCHAR2(128)
)
/

ALTER TABLE CLIENT
    ADD CONSTRAINT CLIENT_PK PRIMARY KEY (APPLICATION_NAME)
/

CREATE TABLE CLIENT_ACCESS_POINT
(
    ACCESS_POINT VARCHAR2(512) NOT NULL,
    APPLICATION_NAME VARCHAR2(128) NOT NULL,
    APPLICATION_INSTANCE_NAME VARCHAR2(128) NOT NULL,
    AUTHORIZATION_ID VARCHAR2(128)
)
/

ALTER TABLE CLIENT_ACCESS_POINT
    ADD CONSTRAINT CLIENT_ACCESS_POINT_PK PRIMARY KEY (ACCESS_POINT, APPLICATION_INSTANCE_NAME)
/

CREATE TABLE CLIENT_INSTANCE
(
    ID VARCHAR2(256) NOT NULL,
    CLIENT_ID VARCHAR2(128),
    INSTANCE_NAME VARCHAR2(256)
)
/

ALTER TABLE CLIENT_INSTANCE
    ADD CONSTRAINT CLIENT_INSTANCE_PK PRIMARY KEY (ID)
/

CREATE TABLE CLIENT_PARAMETER
(
    CLIENT_ID VARCHAR2(128) NOT NULL,
    PARAMETER_ID VARCHAR2(256) NOT NULL
)
/

ALTER TABLE CLIENT_PARAMETER ADD CONSTRAINT CLIENT_PARAMETER_PARAM_ID_UQ UNIQUE
    (PARAMETER_ID )
/

CREATE TABLE CLIENT_QUEUE
(
    APPLICATION_NAME VARCHAR2(128),
    QUEUE_ID VARCHAR2(128)
)
/

CREATE TABLE CLIENT_SESSION
(
    APPLICATION_NAME VARCHAR2(128) NOT NULL,
    INSTANCE_NAME VARCHAR2(256),
    ADDRESS VARCHAR2(512) NOT NULL,
    EXPIRATION TIMESTAMP
)
/

ALTER TABLE CLIENT_SESSION
    ADD CONSTRAINT CLIENT_SESSION_PK PRIMARY KEY (APPLICATION_NAME, ADDRESS)
/

CREATE TABLE DELIVERY_ATTEMPT
(
    ADDR_CHAIN_ID VARCHAR2(128),
    ADDRESS_ID VARCHAR2(128),
    CURRENT_STATUS_ID VARCHAR2(128),
    DELIVERY_ID VARCHAR2(1024) NOT NULL,
    DELIVERY_STATE VARCHAR2(32),
    FAILOVER_ORDER NUMBER,
    GMID VARCHAR2(512),
    HEAD_FLAG NUMBER(1),
    MID VARCHAR2(512),
    NEXT_DELIVERY VARCHAR2(512),
    ORIGINAL_RECIPIENT VARCHAR2(64),
    SENDER_ADDRESS VARCHAR2(128),
    TIME_STAMP TIMESTAMP,
    TOTAL_FAILOVERS NUMBER,
    CURRENT_RESEND NUMBER,
    MAX_RESEND NUMBER
)

/

ALTER TABLE DELIVERY_ATTEMPT
    ADD CONSTRAINT DELIVERY_ATTEMPT_PK PRIMARY KEY (DELIVERY_ID)
/

CREATE INDEX DELIVERY_ATTEMPT_MID_IDX ON DELIVERY_ATTEMPT
    (MID )
/

CREATE UNIQUE INDEX DELIVERY_ATTEMPT_GMID_UQ ON DELIVERY_ATTEMPT
    (GMID )
/

CREATE TABLE DELIVERY_CONTEXT
(
    MID VARCHAR2(512) NOT NULL,
    NS_INSTANCE VARCHAR2(128),
    APPLICATION VARCHAR2(128),
    APPLICATION_INSTANCE VARCHAR2(256),
    DRIVER VARCHAR2(512),
    OPERATION VARCHAR2(64),
    TIME_STAMP TIMESTAMP
)
/

ALTER TABLE DELIVERY_CONTEXT
    ADD CONSTRAINT DELIVERY_CONTEXT_PK PRIMARY KEY (MID)
/

CREATE TABLE DRIVER
(
    CAPABILITY VARCHAR2(64),
    DRIVER_NAME VARCHAR2(512) NOT NULL,
    LOCK_VERSION NUMBER(12,0),
    SPEED NUMBER,
    COST NUMBER,
    SUPPORTS_CANCEL NUMBER(1),
    SUPPORTS_REPLACE NUMBER(1),
    SUPPORTS_STATUS_POLLING NUMBER(1),
    SUPPORTS_TRACKING NUMBER(1),
    CHECKSUM NUMBER,
    DEFAULT_SENDER VARCHAR2(128),
    MIME_TYPES VARCHAR2(512),
    ENCODINGS VARCHAR2(512),
    PROTOCOLS VARCHAR2(512),
    CARRIERS VARCHAR2(512),
    DELIVERY_TYPES VARCHAR2(512),
    STATUS_TYPES VARCHAR2(1024),
    SENDER_ADDRESSES VARCHAR2(1024)
)
/

ALTER TABLE DRIVER
    ADD CONSTRAINT DRIVER_PK PRIMARY KEY (DRIVER_NAME)
/

CREATE TABLE DRIVER_QUEUE
(
    DRIVER_NAME VARCHAR2(512),
    QUEUE_ID VARCHAR2(128)
)
/

CREATE TABLE DRIVER_SESSION
(
    DRIVER_NAME VARCHAR2(512),
    ADDRESS VARCHAR2(512) NOT NULL,
    EXPIRATION TIMESTAMP
)
/

ALTER TABLE DRIVER_SESSION
    ADD CONSTRAINT DRIVER_SESSION_PK PRIMARY KEY (ADDRESS)
/

CREATE TABLE FILTER
(
    PATTERN VARCHAR2(1024),
    FIELD_TYPE VARCHAR2(64),
    FIELD_NAME VARCHAR2(128),
    ACTION VARCHAR2(64),
    APPLICATION_NAME VARCHAR2(128) NOT NULL,
    ORDINAL NUMBER NOT NULL
)
/

ALTER TABLE FILTER
    ADD CONSTRAINT FILTER_PK PRIMARY KEY (APPLICATION_NAME, ORDINAL)
/

CREATE TABLE MESSAGE
(
    INFO_ACCEPT_DATE TIMESTAMP,
    INFO_APPLICATION_NAME VARCHAR2(128),
    INFO_CARRIER_NAME VARCHAR2(128),
    INFO_CHUNK_SIZE NUMBER,
    INFO_CORRELATION_ID VARCHAR2(128),
    INFO_COST_LEVEL NUMBER,
    INFO_DELAY NUMBER,
    INFO_DELIVERY_TYPE VARCHAR2(64),
    INFO_DRIVER VARCHAR2(512),
    INFO_EXPIRATION NUMBER,
    INFO_FROM_ADDRESS VARCHAR2(512),
    INFO_GATEWAY_ID VARCHAR2(512),
    INFO_INSTANCE_NAME VARCHAR2(256),
    INFO_MAX_CHUNKS NUMBER,
    INFO_PRIORITY VARCHAR2(64),
    INFO_PROTOCOL VARCHAR2(64),
    INFO_RELIABILITY VARCHAR2(64),
    INFO_SESSION_TYPE VARCHAR2(64),
    INFO_SPEED_LEVEL NUMBER,
    INFO_STATUS_LEVEL VARCHAR2(64),
    INFO_TRACKING VARCHAR2(64),
    INFO_MAX_RESEND NUMBER,
    INFO_PROFILE_ID VARCHAR2(128),
    MESSAGE_ID VARCHAR2(512) NOT NULL,
    MESSAGE_OBJECT BLOB,
    VALID_FLAG VARCHAR2(20),
    MESSAGE_AUTH_ID VARCHAR2(128),
    CREATION_DATE TIMESTAMP
)
/

ALTER TABLE MESSAGE
    ADD CONSTRAINT MESSAGE_PK PRIMARY KEY (MESSAGE_ID)
/

CREATE TABLE MESSAGE_TRANSFORM
(
    TRANSFORM_KEY VARCHAR2(144) NOT NULL,
    TRANSFORM_MESSAGE_ID VARCHAR2(512) NOT NULL
)
/

ALTER TABLE MESSAGE_TRANSFORM
    ADD CONSTRAINT MESSAGE_TRANSFORM_PK PRIMARY KEY (TRANSFORM_KEY)
/

ALTER TABLE MESSAGE_TRANSFORM ADD CONSTRAINT MESSAGE_TRANSFORM_MSG_ID_UQ UNIQUE
    (TRANSFORM_MESSAGE_ID )
/

CREATE TABLE PARAMETER
(
    ID VARCHAR2(256) NOT NULL,
    PARAM_NAME VARCHAR2(128) NOT NULL,
    PARAM_VALUE VARCHAR2(256)
)
/

ALTER TABLE PARAMETER
    ADD CONSTRAINT PARAMETER_PK PRIMARY KEY (ID)
/

CREATE TABLE QUEUE
(
    QCF_JNDI_NAME VARCHAR2(256),
    QCF_OBJECT BLOB,
    QUEUE_JNDI_NAME VARCHAR2(256),
    QUEUE_OBJECT BLOB,
    QUEUE_ID VARCHAR2(128) NOT NULL
)
/

ALTER TABLE QUEUE
    ADD CONSTRAINT QUEUE_PK PRIMARY KEY (QUEUE_ID)
/

CREATE TABLE STATUS
(
    ADDRESS_ID VARCHAR2(128),
    CONTENT VARCHAR2(1024),
    DRIVER VARCHAR2(512),
    FAILOVER_ORDER NUMBER,
    FAILOVER_STATUS_ID VARCHAR2(128),
    GATEWAY_ID VARCHAR2(512),
    MESSAGE_ID VARCHAR2(512),
    METADATA BLOB,
    RECIPIENT_ID VARCHAR2(128),
    STATUS_DATE TIMESTAMP,
    STATUS_ID VARCHAR2(128) NOT NULL,
    TOTAL_FAILOVERS NUMBER,
    MAX_RESEND NUMBER,
    CURRENT_RESEND NUMBER,
    TYPE VARCHAR2(128)
)
/

ALTER TABLE STATUS
    ADD CONSTRAINT STATUS_PK PRIMARY KEY (STATUS_ID)
/

CREATE TABLE STATUS_ORPHAN
(
    GMID VARCHAR2(512) NOT NULL,
    STATUS_ID VARCHAR2(128) NOT NULL
)
/

CREATE INDEX STATUS_ORPHAN_GMID_IDX ON STATUS_ORPHAN
    (GMID )
/

CREATE TABLE DEVICE_ADDRESS
(
    ID VARCHAR2(128) NOT NULL,
    USER_GUID VARCHAR2(128) NOT NULL,
    NAME VARCHAR2(128) NOT NULL,
    ADDRESS VARCHAR2(512) NOT NULL,
    DEFAULT_ADDRESS VARCHAR2(1) DEFAULT 'N',
    CARRIER VARCHAR2(256),
    ENCODING VARCHAR2(64),
    DELIVERY_INFO VARCHAR2(64),
    DELIVERY_MODE VARCHAR2(64) NOT NULL,
    DESCRIPTION VARCHAR2(2000),
    CREATED TIMESTAMP,
    LAST_MODIFIED TIMESTAMP,
    VERSION NUMBER(10,0),
    VALID VARCHAR2(1) DEFAULT 'N',
    UDEV_ID VARCHAR2(128),
    TYPE VARCHAR2(10) DEFAULT 'UCP',
    REFERENCE_KEY VARCHAR2(256),
    METADATA BLOB,
    EXT_DATE TIMESTAMP,
    EXT_CHAR1 VARCHAR2(2000),
    EXT_CHAR2 VARCHAR2(2000),
    EXT_CHAR3 VARCHAR2(2000)
)
/

ALTER TABLE DEVICE_ADDRESS
    ADD CONSTRAINT DEVICE_ADDRESS_PK PRIMARY KEY (ID)
/

ALTER TABLE DEVICE_ADDRESS ADD CONSTRAINT DEVICE_ADDRESS_ADDRS_DELIV_UQ UNIQUE
    (ADDRESS , DELIVERY_MODE )
/

ALTER TABLE DEVICE_ADDRESS ADD CONSTRAINT DEVICE_ADDRESS_USER_NAME_UQ UNIQUE
    (USER_GUID , NAME )
/

CREATE INDEX DEVICE_ADDRESS_UDEV_ID_IDX ON DEVICE_ADDRESS
    (UDEV_ID )
/

ALTER TABLE DEVICE_ADDRESS
    ADD CONSTRAINT DEVICE_ADDRESS_VALID_CK CHECK (VALID IN ('Y', 'N'))
/

ALTER TABLE DEVICE_ADDRESS
    ADD CONSTRAINT DEVICE_ADDRESS_DEFAULT_ADDR_CK CHECK (DEFAULT_ADDRESS IN ('Y', 'N'))
/

ALTER TABLE DEVICE_ADDRESS
    ADD CONSTRAINT DEVICE_ADDRESS_TYPE_CK CHECK (TYPE IN ('UCP', 'IDM'))
/

CREATE TABLE RULE_SET
(
    USER_GUID VARCHAR2(128) NOT NULL,
    PROFILE_ID VARCHAR2(128) DEFAULT 'defaultId' NOT NULL,
    MEDIA_TYPE_ID NUMBER(3) DEFAULT 1 NOT NULL,
    FILTER_XML CLOB,
    FILTER_XML_UCP CLOB,
    RL CLOB,
    RULE_SESSION BLOB,
    DESCRIPTION VARCHAR2(2000),
    CREATED TIMESTAMP,
    LAST_MODIFIED TIMESTAMP,
    VERSION NUMBER(10,0),
    VALID VARCHAR2(1) DEFAULT 'N',
    EXT_DATE TIMESTAMP,
    EXT_CHAR1 VARCHAR2(2000),
    EXT_CHAR2 VARCHAR2(2000),
    EXT_CHAR3 VARCHAR2(2000)
)
/

ALTER TABLE RULE_SET
    ADD CONSTRAINT RULE_SET_PK PRIMARY KEY (USER_GUID, PROFILE_ID, MEDIA_TYPE_ID)
/

ALTER TABLE RULE_SET
    ADD CONSTRAINT RULE_SET_VALID_CK CHECK (VALID IN ('Y', 'N'))
/

CREATE TABLE UCP_MEDIA_TYPE
(
    ID NUMBER(3) NOT NULL,
    NAME VARCHAR2(32) NOT NULL
)
/

ALTER TABLE UCP_MEDIA_TYPE
    ADD CONSTRAINT UCP_MEDIA_TYPE_PK PRIMARY KEY (ID)
/

CREATE TABLE UCP_USER_ATTRIBUTE
(
    USER_GUID VARCHAR2(128) NOT NULL,
    NAME VARCHAR2(256) NOT NULL,
    VALUE VARCHAR2(2000),
    CREATED TIMESTAMP,
    LAST_MODIFIED TIMESTAMP,
    VERSION NUMBER(10,0)
)
/

ALTER TABLE UCP_USER_ATTRIBUTE
    ADD CONSTRAINT UCP_USER_ATTRIBUTE_PK PRIMARY KEY (USER_GUID, NAME)
/

CREATE TABLE USER_DEVICE
(
    ID VARCHAR2(128) NOT NULL,
    USER_GUID VARCHAR2(128) NOT NULL,
    NAME VARCHAR2(128) NOT NULL,
    DESCRIPTION VARCHAR2(2000),
    CREATED TIMESTAMP,
    LAST_MODIFIED TIMESTAMP,
    VERSION NUMBER(10,0),
    VALID VARCHAR2(1) DEFAULT 'N'
)
/

ALTER TABLE USER_DEVICE
    ADD CONSTRAINT USER_DEVICE_PK PRIMARY KEY (ID)
/

ALTER TABLE USER_DEVICE ADD CONSTRAINT USER_DEVICE_USER_GUID_NAME_UQ UNIQUE
    (USER_GUID , NAME )
/

ALTER TABLE USER_DEVICE
    ADD CONSTRAINT USER_DEVICE_VALID_CK CHECK (VALID IN ('Y', 'N'))
/

ALTER TABLE ADDRESS
    ADD CONSTRAINT ADDRESS_FAILOVER_ADDRESS FOREIGN KEY (FAILOVER_ADDRESS_ID) REFERENCES ADDRESS (ADDR_ID)
/

ALTER TABLE RULE_SET
    ADD CONSTRAINT RULE_SET_FK2 FOREIGN KEY (MEDIA_TYPE_ID) REFERENCES UCP_MEDIA_TYPE (ID)
/

INSERT INTO UCP_MEDIA_TYPE (ID, NAME) VALUES(1,'MESSAGING')

/

INSERT INTO UCP_MEDIA_TYPE (ID, NAME) VALUES(2,'VOICE_CALL')

/

DEFINE schema_user = TESTONE_UMS

ALTER SESSION SET CURRENT_SCHEMA=TESTONE_UMS
/

BEGIN
DBMS_AQADM.CREATE_QUEUE_TABLE(
	queue_table => 'TESTONE_UMS' || '.OraSDPMAppDefRcvT1',
	queue_payload_type => 'SYS.AQ$_JMS_MESSAGE',
	sort_list => 'PRIORITY,ENQ_TIME',
	multiple_consumers => false,
	compatible => '10.0');
DBMS_AQADM.CREATE_QUEUE( queue_name => 'TESTONE_UMS' || '.OraSDPMAppDefRcvQ1', queue_table => 'TESTONE_UMS' || '.OraSDPMAppDefRcvT1' , max_retries => 2);

DBMS_AQADM.CREATE_QUEUE_TABLE(
	queue_table => 'TESTONE_UMS' || '.OraSDPMEngineCmdT',
	queue_payload_type => 'SYS.AQ$_JMS_MESSAGE',
	sort_list => 'PRIORITY,ENQ_TIME',
	multiple_consumers => false,
	compatible => '10.0');
DBMS_AQADM.CREATE_QUEUE( queue_name => 'TESTONE_UMS' || '.OraSDPMEngineCmdQ', queue_table => 'TESTONE_UMS' || '.OraSDPMEngineCmdT', max_retries => 2);

DBMS_AQADM.CREATE_QUEUE_TABLE(
	queue_table => 'TESTONE_UMS' || '.OraSDPMEngineSndT1',
	queue_payload_type => 'SYS.AQ$_JMS_MESSAGE',
	sort_list => 'PRIORITY,ENQ_TIME',
	multiple_consumers => false,
	compatible => '10.0');
DBMS_AQADM.CREATE_QUEUE( queue_name => 'TESTONE_UMS' || '.OraSDPMEngineSndQ1', queue_table => 'TESTONE_UMS' || '.OraSDPMEngineSndT1', max_retries => 2);

DBMS_AQADM.CREATE_QUEUE_TABLE(
	queue_table => 'TESTONE_UMS' || '.OraSDPMEngineRcvT1',
	queue_payload_type => 'SYS.AQ$_JMS_MESSAGE',
	sort_list => 'PRIORITY,ENQ_TIME',
	multiple_consumers => false,
	compatible => '10.0');
DBMS_AQADM.CREATE_QUEUE( queue_name => 'TESTONE_UMS' || '.OraSDPMEngineRcvQ1', queue_table => 'TESTONE_UMS' || '.OraSDPMEngineRcvT1', max_retries => 2);


DBMS_AQADM.CREATE_QUEUE_TABLE(
	queue_table => 'TESTONE_UMS' || '.OraSDPMWSRcvT1',
	queue_payload_type => 'SYS.AQ$_JMS_MESSAGE',
	sort_list => 'PRIORITY,ENQ_TIME',
	multiple_consumers => false,
	compatible => '10.0');
DBMS_AQADM.CREATE_QUEUE( queue_name => 'TESTONE_UMS' || '.OraSDPMWSRcvQ1', queue_table => 'TESTONE_UMS' || '.OraSDPMWSRcvT1', max_retries => 2);

DBMS_AQADM.CREATE_QUEUE_TABLE(
	queue_table => 'TESTONE_UMS' || '.OraSDPMDriverDefSndT1',
	queue_payload_type => 'SYS.AQ$_JMS_MESSAGE',
	sort_list => 'PRIORITY,ENQ_TIME',
	multiple_consumers => false,
	compatible => '10.0');
DBMS_AQADM.CREATE_QUEUE( queue_name => 'TESTONE_UMS' || '.OraSDPMDriverDefSndQ1', queue_table => 'TESTONE_UMS' || '.OraSDPMDriverDefSndT1', max_retries => 2);

DBMS_AQADM.CREATE_QUEUE_TABLE(
    queue_table => 'TESTONE_UMS' || '.OraSDPMEnginePendRcvQT',
    queue_payload_type => 'SYS.AQ$_JMS_MESSAGE',
    sort_list => 'PRIORITY,ENQ_TIME',
    multiple_consumers => false,
    compatible => '10.0');
DBMS_AQADM.CREATE_QUEUE( queue_name => 'TESTONE_UMS' || '.OraSDPMEnginePendingRcvQ', queue_table => 'TESTONE_UMS' || '.OraSDPMEnginePendRcvQT', max_retries => 2);

DBMS_AQADM.START_QUEUE(queue_name => 'TESTONE_UMS' || '.OraSDPMAppDefRcvQ1');
DBMS_AQADM.START_QUEUE(queue_name => 'TESTONE_UMS' || '.AQ$_OraSDPMAppDefRcvT1_E', dequeue => TRUE, enqueue => FALSE);
DBMS_AQADM.START_QUEUE(queue_name => 'TESTONE_UMS' || '.OraSDPMEngineCmdQ');
DBMS_AQADM.START_QUEUE(queue_name => 'TESTONE_UMS' || '.OraSDPMEngineSndQ1');
DBMS_AQADM.START_QUEUE(queue_name => 'TESTONE_UMS' || '.OraSDPMEngineRcvQ1');
DBMS_AQADM.START_QUEUE(queue_name => 'TESTONE_UMS' || '.OraSDPMEnginePendingRcvQ');
DBMS_AQADM.START_QUEUE(queue_name => 'TESTONE_UMS' || '.OraSDPMWSRcvQ1');

DBMS_AQADM.START_QUEUE(queue_name => 'TESTONE_UMS' || '.OraSDPMDriverDefSndQ1');
END;

/

DEFINE schema_user = TESTONE_UMS

ALTER SESSION SET CURRENT_SCHEMA=TESTONE_UMS
/

CREATE OR REPLACE PACKAGE UMS_CLEANUP AS

	-- Main purge procedure
	PROCEDURE PURGE (days_of_retention IN NUMBER);

	-- procedure to update MESSGAGE, DELIVERY_CONTEXT, and ADDRESS tables
	procedure update_message_date(cut_off_time IN date);

	-- Procedure to purge MESSAGE table
	procedure purge_message(cut_off_time IN date);

	-- procedures to update ADRESS table failoverchains
	procedure update_failover_address(cut_off_time IN date);
	
	procedure update_failover_address2(cut_off_time IN date);
	
	-- procedure to decouple adresses from failover addresses in ADDRESS table
	procedure decouple_failover_address(cut_off_time IN date);
	
	-- procedure to purge ADDRESS table
	procedure purge_address(cut_off_time IN date);
	
	-- procedure to purge STATUS table
	procedure purge_status(cut_off_time IN date);
	
	-- procedure to purge DELIVERY_CONTEXT table
	procedure purge_delivery_context(cut_off_time IN date);
	
	-- procedure to purge DELIVERY_ATTEMPT table
	procedure purge_delivery_attempt(cut_off_time IN date);


END UMS_CLEANUP;

/

show errors;
/

CREATE OR REPLACE PACKAGE BODY UMS_CLEANUP AS

	-- Main purge procedure
	PROCEDURE PURGE (days_of_retention IN NUMBER) AS

		cut_off_date DATE;
		nrows	NUMBER;

		BEGIN

		DBMS_OUTPUT.put_line(CHR(10));

		if(days_of_retention < 7) then
			DBMS_OUTPUT.put_line('ERROR:  Parameter "days_of_retention" is too short. The minimum value allowed is 7 days.');
			goto endp;		
		end if;

		DBMS_OUTPUT.put_line('------ Before Purge ---------');
		DBMS_OUTPUT.put_line(CHR(10));

		select count(1) into nrows from MESSAGE;
		DBMS_OUTPUT.put_line('MESSAGE table:'|| CHR(9) || nrows || ' rows');

		nrows := 0;
		select count(1) into nrows from ADDRESS;
		DBMS_OUTPUT.put_line('ADDRESS table:'|| CHR(9) || nrows || ' rows');

		nrows := 0;
		select count(1) into nrows from DELIVERY_ATTEMPT;
		DBMS_OUTPUT.put_line('DELIVERY_ATTEMPT table:'|| CHR(9) || nrows || ' rows');

		nrows := 0;
		select count(1) into nrows from STATUS;
		DBMS_OUTPUT.put_line('STATUS table:'|| CHR(9) || nrows || ' rows');

		nrows := 0;
		select count(1) into nrows from DELIVERY_CONTEXT;
		DBMS_OUTPUT.put_line('DELIVERY_CONTEXT table:'|| CHR(9) || nrows || ' rows');

		cut_off_date := sysdate - days_of_retention;

		DBMS_OUTPUT.put_line(CHR(10));

		DBMS_OUTPUT.put_line('Cut-off date/time is:  ' || to_char(cut_off_date, 'YYYY-MM-DD HH24:MI:SS'));
		DBMS_OUTPUT.put_line('All records created prior to that point will be DELETED permanently.');

		-- -------------------- Update MESSAGE table ---------------------
		DBMS_OUTPUT.put_line('**** Update MESSAGE, CONTEXT, ADDRESS table for different times. Please wait ...');
		update_message_date(cut_off_date);

		-- -------------------- Purge MESSAGE table ---------------------
		DBMS_OUTPUT.put_line('**** Purging MESSAGE table. Please wait ...');
		purge_message(cut_off_date);

		-- -------------------- Purge ADDRESS table ---------------------
		DBMS_OUTPUT.put_line('**** Purging ADDRESS table. Please wait ...');

		update DELIVERY_ATTEMPT set time_stamp = cut_off_date - 1
		where MID in (select unique MID from DELIVERY_CONTEXT where TIME_STAMP < cut_off_date)
		  and time_stamp is null;

		-- -------------------- Delete addresses ---------------------	
		update_failover_address(cut_off_date);
		update_failover_address2(cut_off_date);
		decouple_failover_address(cut_off_date);
		purge_address(cut_off_date);

		-- -------------------- Purge DELIVERY_ATTEMPT table ---------------------
		DBMS_OUTPUT.put_line('**** Purging DELIVERY_ATTEMPT table. Please wait ...');
		purge_delivery_attempt(cut_off_date);

		-- -------------------- Purge STATUS table ---------------------
		DBMS_OUTPUT.put_line('**** Purging STATUS table. Please wait ...');
		purge_status(cut_off_date);

		-- -------------------- Purge DELIVERY_CONTEXT table ---------------------
		DBMS_OUTPUT.put_line('**** Purging DELIVERY_CONTEXT table. Please wait ...');
		purge_delivery_context(cut_off_date);

		DBMS_OUTPUT.put_line('**** Purge completed.');
		DBMS_OUTPUT.put_line(CHR(10));
		DBMS_OUTPUT.put_line('------ After Purge ---------');
		DBMS_OUTPUT.put_line(CHR(10));

		nrows := 0;
		select count(1) into nrows from MESSAGE;
		DBMS_OUTPUT.put_line('MESSAGE table:'|| CHR(9) || nrows || ' rows');

		nrows := 0;
		select count(1) into nrows from ADDRESS;
		DBMS_OUTPUT.put_line('ADDRESS table:'|| CHR(9) || nrows || ' rows');

		nrows := 0;
		select count(1) into nrows from DELIVERY_ATTEMPT;
		DBMS_OUTPUT.put_line('DELIVERY_ATTEMPT table:'|| CHR(9) || nrows || ' rows');

		nrows := 0;
		select count(1) into nrows from STATUS;
		DBMS_OUTPUT.put_line('STATUS table:'|| CHR(9) || nrows || ' rows');

		nrows := 0;
		select count(1) into nrows from DELIVERY_CONTEXT;
		DBMS_OUTPUT.put_line('DELIVERY_CONTEXT table:'|| CHR(9) || nrows || ' rows');

	<<endp>>	
		DBMS_OUTPUT.put_line(CHR(10));

		END PURGE;

        -- Procedure to change date/timestamp to ATTEMPT timestamp for inconsistent dates
        procedure update_message_date(cut_off_time IN date) IS
                CURSOR C1 is
                    select da.mid, da.TIME_STAMP, da.sender_address, da.address_id from 
                        DELIVERY_ATTEMPT da, DELIVERY_CONTEXT dc where
                        da.mid = dc.mid and da.TIME_STAMP >= cut_off_time and dc.TIME_STAMP < cut_off_time;

                CURSOR C2 IS
                    Select da.mid, da.TIME_STAMP, da.sender_address, da.address_id from 
                        DELIVERY_ATTEMPT da, MESSAGE msg where
			msg.CREATION_DATE is null;

                msg_id  VARCHAR2(128);
                msg_time TIMESTAMP(6);
                sender_addr VARCHAR2(128);
                recip_addr VARCHAR2(128);
                lv_commit_size NUMBER := 100;
                lv_count NUMBER := 0;

        BEGIN

                FOR record IN C1 LOOP
                    msg_id := record.mid;
                    msg_time := record.TIME_STAMP;
                    sender_addr := record.sender_address;
                    recip_addr := record.address_id;

                    update DELIVERY_CONTEXT set TIME_STAMP = msg_time where
                        mid = msg_id;

                    update MESSAGE set CREATION_DATE = msg_time where 
                        message_id = msg_id;

                    update ADDRESS set CREATION_DATE = msg_time where
                        addr_id = sender_addr;

                    update ADDRESS set CREATION_DATE = msg_time where
                        addr_id = recip_addr;

		    lv_count := lv_count + 1;
		    if mod(lv_count, lv_commit_size) = 0 then
			commit;

			DBMS_OUTPUT.put_line(lv_count);

		    end if;            

		END LOOP;

		FOR record IN C2 LOOP

                    msg_id := record.mid;
                    msg_time := record.TIME_STAMP;
                    sender_addr := record.sender_address;
                    recip_addr := record.address_id;


                    update MESSAGE set CREATION_DATE = msg_time where 
                        message_id = msg_id;

                    update ADDRESS set CREATION_DATE = msg_time where
                        addr_id = sender_addr;

                    update ADDRESS set CREATION_DATE = msg_time where
                        addr_id = recip_addr;
		    lv_count := lv_count + 1;
		    if mod(lv_count, lv_commit_size) = 0 then
			commit;

			DBMS_OUTPUT.put_line(lv_count);

		    end if;            

		END LOOP;
		commit;	
	
		DBMS_OUTPUT.put_line(lv_count);

	END update_message_date;

 
	-- Procedure to purge MESSAGE table
	procedure purge_message(cut_off_time IN date) IS
		CURSOR C1 is
		    Select m.message_id from MESSAGE m, DELIVERY_CONTEXT dc where
			m.message_id = dc.mid and dc.TIME_STAMP < cut_off_time;

		msg_id	VARCHAR2(128);
		lv_commit_size NUMBER := 100;
		lv_count NUMBER := 0;		

	BEGIN

		FOR record IN C1 LOOP
		    msg_id := record.message_id;

		    delete from MESSAGE where message_id = msg_id;

		    lv_count := lv_count + 1;
		    if mod(lv_count, lv_commit_size) = 0 then
			commit;

			DBMS_OUTPUT.put_line(lv_count);

		    end if;            

		END LOOP;
		commit;		
		DBMS_OUTPUT.put_line(lv_count);

	END purge_message;
	

	-- Procedure to change date/timestamp to preserve failoverchains
  	procedure update_failover_address(cut_off_time IN date) IS
  
		CURSOR C1 IS
			select unique addr_id from ADDRESS where failover_address_id in (select unique addr_id from ADDRESS where creation_date > cut_off_time) and creation_date < cut_off_time;

		a_id	VARCHAR2(64);
		lv_commit_size NUMBER := 100;
		lv_count NUMBER := 0;		
	BEGIN

		DBMS_OUTPUT.put_line('Update addresses...');

		FOR record IN C1 LOOP
		    a_id := record.addr_id;
		    update ADDRESS set CREATION_DATE = cut_off_time + 1 where addr_id = a_id;

		    lv_count := lv_count + 1;
		    if mod(lv_count, lv_commit_size) = 0 then
			commit;

			DBMS_OUTPUT.put_line(lv_count);

		    end if;            

		END LOOP;
		commit;		
		DBMS_OUTPUT.put_line(lv_count);

	END update_failover_address;

  procedure update_failover_address2(cut_off_time IN date) IS
  
		CURSOR C1 IS
        	select unique addr_id from ADDRESS where failover_address_id is null and addr_id in (select unique failover_address_id from ADDRESS where creation_date > cut_off_time) and creation_date < cut_off_time;

		a_id	VARCHAR2(64);
		lv_commit_size NUMBER := 100;
		lv_count NUMBER := 0;		
	BEGIN

		DBMS_OUTPUT.put_line('Update addresses 2...');

		FOR record IN C1 LOOP
		    a_id := record.addr_id;
		    update ADDRESS set CREATION_DATE = cut_off_time + 1 where addr_id = a_id;

		    lv_count := lv_count + 1;
		    if mod(lv_count, lv_commit_size) = 0 then
          		commit;

          		DBMS_OUTPUT.put_line(lv_count);

		    end if;            

		END LOOP;
		commit;		
		DBMS_OUTPUT.put_line(lv_count);


	END update_failover_address2;

	-- procedure to decouple adresses from failover addresses in ADDRESS table
	procedure decouple_failover_address(cut_off_time IN date) IS

		CURSOR C1 IS
			select addr_id from address where
                            failover_address_id is not null and CREATION_DATE < cut_off_time;

		a_id	VARCHAR2(64);
		lv_commit_size NUMBER := 100;
		lv_count NUMBER := 0;		
	BEGIN

		DBMS_OUTPUT.put_line('Decouple adresses from failover addresses...');

		FOR record IN C1 LOOP
		    a_id := record.addr_id;
        update ADDRESS set failover_address_id = null where addr_id = a_id;

		    lv_count := lv_count + 1;
		    if mod(lv_count, lv_commit_size) = 0 then
			commit;

			DBMS_OUTPUT.put_line(lv_count);

		    end if;            

		END LOOP;
		commit;		
		DBMS_OUTPUT.put_line(lv_count);

	END decouple_failover_address;
	
	-- procedure to purge senders from ADDRESS table
	procedure purge_address(cut_off_time IN date) IS

		CURSOR C1 IS
			Select addr_id from address where
                            CREATION_DATE < cut_off_time;

		a_id	VARCHAR2(64);
		lv_commit_size NUMBER := 100;
		lv_count NUMBER := 0;		
	BEGIN

		DBMS_OUTPUT.put_line('Deleting addresses from ADDRESS table...');

		FOR record IN C1 LOOP
		    a_id := record.addr_id;

		    delete from ADDRESS where addr_id = a_id;

		    lv_count := lv_count + 1;
		    if mod(lv_count, lv_commit_size) = 0 then
			commit;

			DBMS_OUTPUT.put_line(lv_count);

		    end if;            

		END LOOP;
		commit;		
		DBMS_OUTPUT.put_line(lv_count);

	END purge_address;
	

	-- procedure to purge STATUS table
	procedure purge_status(cut_off_time IN date) IS

		CURSOR C1 IS
			Select STATUS_ID from status 
			where STATUS_DATE < cut_off_time;


		s_id	VARCHAR2(128);
		lv_commit_size NUMBER := 100;
		lv_count NUMBER := 0;		
	BEGIN

		FOR record IN C1 LOOP
		    s_id := record.status_id;

		    delete from status where status_id = s_id;

		    lv_count := lv_count + 1;
		    if mod(lv_count, lv_commit_size) = 0 then
			commit;

			DBMS_OUTPUT.put_line(lv_count);

		    end if;            

		END LOOP;
		commit;		

		DBMS_OUTPUT.put_line(lv_count);

	END purge_status;
	
	-- procedure to purge DELIVERY_CONTEXT table
	procedure purge_delivery_context(cut_off_time IN date) IS

		CURSOR C1 IS
			Select MID from DELIVERY_CONTEXT 
			where TIME_STAMP < cut_off_time;


		id	VARCHAR2(128);
		lv_commit_size NUMBER := 100;
		lv_count NUMBER := 0;		
	BEGIN

		FOR record IN C1 LOOP
		    id := record.mid;

		    delete from DELIVERY_CONTEXT where mid = id;

		    lv_count := lv_count + 1;
		    if mod(lv_count, lv_commit_size) = 0 then
			commit;

			DBMS_OUTPUT.put_line(lv_count);

		    end if;            

		END LOOP;
		commit;		

		DBMS_OUTPUT.put_line(lv_count);

	END purge_delivery_context;
	

	-- procedure to purge DELIVERY_ATTEMPT table
	procedure purge_delivery_attempt(cut_off_time IN date) IS

		CURSOR C1 IS
			Select DELIVERY_ID from DELIVERY_ATTEMPT 
			where TIME_STAMP < cut_off_time;


		id	VARCHAR2(256);
		lv_commit_size NUMBER := 100;
		lv_count NUMBER := 0;		
	BEGIN

		FOR record IN C1 LOOP
		    id := record.DELIVERY_ID;

		    delete from DELIVERY_ATTEMPT where DELIVERY_ID = id;

		    lv_count := lv_count + 1;
		    if mod(lv_count, lv_commit_size) = 0 then
			commit;

			DBMS_OUTPUT.put_line(lv_count);

		    end if;            

		END LOOP;
		commit;		

		DBMS_OUTPUT.put_line(lv_count);

	END purge_delivery_attempt;
	

END UMS_CLEANUP;


/

show errors;
/

UPDATE SYSTEM.SCHEMA_VERSION_REGISTRY SET status='LOADED' WHERE comp_id='UCSUMS'  AND mrc_name='TESTONE'
/

GRANT REGISTRYACCESS TO TESTONE_UMS
/

---------------------------------------------------------
---------- UCSUMS(User Messaging Service) SECTION ENDS ----------
---------------------------------------------------------


---------------------------------------------------------
---------- IAU(Audit Services) SECTION STARTS ----------
---------------------------------------------------------


DECLARE
BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE SYSTEM.SCHEMA_VERSION_REGISTRY$ ADD EDITION VARCHAR2(30)';
EXCEPTION WHEN OTHERS THEN  NULL;
END;
/

DECLARE
compCnt NUMBER;
BEGIN
  SELECT COUNT(*) INTO compCnt FROM SCHEMA_VERSION_REGISTRY
  WHERE MRC_NAME='TESTONE' and COMP_ID='IAU';
  IF compCnt = 0 THEN
  INSERT INTO SYSTEM.SCHEMA_VERSION_REGISTRY$   (comp_id, comp_name, mrc_name, mr_name,  mr_type, owner, version, status, edition, custom1)   VALUES ('IAU', 'Audit Service', 'TESTONE', 'IAU', 'IAU', 'TESTONE_IAU', '12.2.1.0.0', 'LOADING', '', 0);
  END IF;
END;

/

DECLARE
BEGIN
    EXECUTE IMMEDIATE 'CREATE ROLE REGISTRYACCESS';
EXCEPTION WHEN OTHERS THEN  NULL;
END;
/

GRANT SELECT, INSERT, UPDATE, DELETE ON SYSTEM.SCHEMA_VERSION_REGISTRY$ TO REGISTRYACCESS
/

GRANT SELECT, INSERT, UPDATE, DELETE ON SYSTEM.SCHEMA_VERSION_REGISTRY TO REGISTRYACCESS
/

accept SCHEMA_PASSWORD char prompt "Enter the schema password : " hide;
begin
 execute immediate 'CREATE USER TESTONE_IAU 
    IDENTIFIED BY &SCHEMA_PASSWORD 
    DEFAULT TABLESPACE TESTONE_IAU 
    TEMPORARY TABLESPACE TESTONE_IAS_TEMP'; 
end;

/

GRANT RESOURCE TO TESTONE_IAU
/

GRANT UNLIMITED TABLESPACE to TESTONE_IAU
/

GRANT CONNECT TO TESTONE_IAU
/

GRANT CREATE TYPE TO TESTONE_IAU
/

GRANT CREATE PROCEDURE TO TESTONE_IAU
/

GRANT CREATE TABLE TO TESTONE_IAU
/

GRANT CREATE SEQUENCE TO TESTONE_IAU
/

GRANT CREATE SESSION TO TESTONE_IAU
/

GRANT CREATE INDEXTYPE TO TESTONE_IAU
/

GRANT CREATE SYNONYM TO TESTONE_IAU
/

GRANT SELECT_CATALOG_ROLE to TESTONE_IAU
/

GRANT SELECT ANY DICTIONARY TO TESTONE_IAU
/

GRANT SELECT ON SCHEMA_VERSION_REGISTRY TO TESTONE_IAU
/

CREATE or replace SYNONYM TESTONE_IAU_VIEWER.IAU_BASE FOR TESTONE_IAU.IAU_BASE
/

CREATE or replace SYNONYM TESTONE_IAU_APPEND.IAU_BASE FOR TESTONE_IAU.IAU_BASE
/

CREATE or replace SYNONYM TESTONE_IAU_VIEWER.AdminServer FOR TESTONE_IAU.AdminServer
/

CREATE or replace SYNONYM TESTONE_IAU_APPEND.AdminServer FOR TESTONE_IAU.AdminServer
/

CREATE OR REPLACE SYNONYM TESTONE_IAU_VIEWER.DIP FOR TESTONE_IAU.DIP
/

CREATE OR REPLACE SYNONYM TESTONE_IAU_APPEND.DIP FOR TESTONE_IAU.DIP
/

CREATE OR REPLACE SYNONYM TESTONE_IAU_VIEWER.JPS FOR TESTONE_IAU.JPS
/

CREATE OR REPLACE SYNONYM TESTONE_IAU_APPEND.JPS FOR TESTONE_IAU.JPS
/

CREATE OR REPLACE SYNONYM TESTONE_IAU_VIEWER.OAAM FOR TESTONE_IAU.OAAM
/

CREATE OR REPLACE SYNONYM TESTONE_IAU_APPEND.OAAM FOR TESTONE_IAU.OAAM
/

CREATE OR REPLACE SYNONYM TESTONE_IAU_VIEWER.OAM FOR TESTONE_IAU.OAM
/

CREATE OR REPLACE SYNONYM TESTONE_IAU_APPEND.OAM FOR TESTONE_IAU.OAM
/

CREATE OR REPLACE SYNONYM TESTONE_IAU_VIEWER.OHSComponent FOR TESTONE_IAU.OHSComponent
/

CREATE OR REPLACE SYNONYM TESTONE_IAU_APPEND.OHSComponent FOR TESTONE_IAU.OHSComponent
/

CREATE OR REPLACE SYNONYM TESTONE_IAU_VIEWER.OIDComponent FOR TESTONE_IAU.OIDComponent
/

CREATE OR REPLACE SYNONYM TESTONE_IAU_APPEND.OIDComponent FOR TESTONE_IAU.OIDComponent
/

CREATE OR REPLACE SYNONYM TESTONE_IAU_VIEWER.OIF FOR TESTONE_IAU.OIF
/

CREATE OR REPLACE SYNONYM TESTONE_IAU_APPEND.OIF FOR TESTONE_IAU.OIF
/

CREATE OR REPLACE SYNONYM TESTONE_IAU_VIEWER.OVDComponent FOR TESTONE_IAU.OVDComponent
/

CREATE OR REPLACE SYNONYM TESTONE_IAU_APPEND.OVDComponent FOR TESTONE_IAU.OVDComponent
/

CREATE OR REPLACE SYNONYM TESTONE_IAU_VIEWER.OWSM_AGENT FOR TESTONE_IAU.OWSM_AGENT
/

CREATE OR REPLACE SYNONYM TESTONE_IAU_APPEND.OWSM_AGENT FOR TESTONE_IAU.OWSM_AGENT
/

CREATE OR REPLACE SYNONYM TESTONE_IAU_VIEWER.OWSM_PM_EJB FOR TESTONE_IAU.OWSM_PM_EJB
/

CREATE OR REPLACE SYNONYM TESTONE_IAU_APPEND.OWSM_PM_EJB FOR TESTONE_IAU.OWSM_PM_EJB
/

CREATE OR REPLACE SYNONYM TESTONE_IAU_VIEWER.ReportsServerComponent FOR TESTONE_IAU.ReportsServerComponent
/

CREATE OR REPLACE SYNONYM TESTONE_IAU_APPEND.ReportsServerComponent FOR TESTONE_IAU.ReportsServerComponent
/

CREATE OR REPLACE SYNONYM TESTONE_IAU_VIEWER.SOA_B2B FOR TESTONE_IAU.SOA_B2B
/

CREATE OR REPLACE SYNONYM TESTONE_IAU_APPEND.SOA_B2B FOR TESTONE_IAU.SOA_B2B
/

CREATE OR REPLACE SYNONYM TESTONE_IAU_VIEWER.SOA_HCFP FOR TESTONE_IAU.SOA_HCFP
/

CREATE OR REPLACE SYNONYM TESTONE_IAU_APPEND.SOA_HCFP FOR TESTONE_IAU.SOA_HCFP
/

CREATE OR REPLACE SYNONYM TESTONE_IAU_VIEWER.STS FOR TESTONE_IAU.STS
/

CREATE OR REPLACE SYNONYM TESTONE_IAU_APPEND.STS FOR TESTONE_IAU.STS
/

CREATE OR REPLACE SYNONYM TESTONE_IAU_VIEWER.WS_PolicyAttachment FOR TESTONE_IAU.WS_PolicyAttachment
/

CREATE OR REPLACE SYNONYM TESTONE_IAU_APPEND.WS_PolicyAttachment FOR TESTONE_IAU.WS_PolicyAttachment
/

CREATE OR REPLACE SYNONYM TESTONE_IAU_VIEWER.WebCacheComponent FOR TESTONE_IAU.WebCacheComponent
/

CREATE OR REPLACE SYNONYM TESTONE_IAU_APPEND.WebCacheComponent FOR TESTONE_IAU.WebCacheComponent
/

CREATE OR REPLACE SYNONYM TESTONE_IAU_VIEWER.WebServices FOR TESTONE_IAU.WebServices
/

CREATE OR REPLACE SYNONYM TESTONE_IAU_APPEND.WebServices FOR TESTONE_IAU.WebServices
/

CREATE OR REPLACE SYNONYM TESTONE_IAU_VIEWER.xmlpserver FOR TESTONE_IAU.xmlpserver
/

CREATE OR REPLACE SYNONYM TESTONE_IAU_APPEND.xmlpserver FOR TESTONE_IAU.xmlpserver
/

CREATE or replace SYNONYM TESTONE_IAU_VIEWER.IAU_COMMON FOR TESTONE_IAU.IAU_COMMON
/

CREATE or replace SYNONYM TESTONE_IAU_APPEND.IAU_COMMON FOR TESTONE_IAU.IAU_COMMON
/

CREATE or replace SYNONYM TESTONE_IAU_VIEWER.IAU_CUSTOM FOR TESTONE_IAU.IAU_CUSTOM
/

CREATE or replace SYNONYM TESTONE_IAU_APPEND.IAU_CUSTOM FOR TESTONE_IAU.IAU_CUSTOM
/

CREATE or replace SYNONYM TESTONE_IAU_VIEWER.IAU_CUSTOM_01 FOR TESTONE_IAU.IAU_CUSTOM_01
/

CREATE or replace SYNONYM TESTONE_IAU_APPEND.IAU_CUSTOM_01 FOR TESTONE_IAU.IAU_CUSTOM_01
/

CREATE or replace SYNONYM TESTONE_IAU_VIEWER.IAU_SCHEMA_VERSION FOR TESTONE_IAU.IAU_SCHEMA_VERSION
/

CREATE or replace SYNONYM TESTONE_IAU_APPEND.IAU_SCHEMA_VERSION FOR TESTONE_IAU.IAU_SCHEMA_VERSION
/

CREATE or replace SYNONYM TESTONE_IAU_VIEWER.IAU_USERSESSION FOR TESTONE_IAU.IAU_USERSESSION
/

CREATE or replace SYNONYM TESTONE_IAU_APPEND.IAU_USERSESSION FOR TESTONE_IAU.IAU_USERSESSION
/

CREATE or replace SYNONYM TESTONE_IAU_VIEWER.IAU_AUDITSERVICE FOR TESTONE_IAU.IAU_AUDITSERVICE
/

CREATE or replace SYNONYM TESTONE_IAU_APPEND.IAU_AUDITSERVICE FOR TESTONE_IAU.IAU_AUDITSERVICE
/

create or replace synonym TESTONE_IAU_VIEWER.list_of_components for TESTONE_IAU.list_of_components
/

create or replace synonym TESTONE_IAU_APPEND.list_of_components for TESTONE_IAU.list_of_components
/

create or replace synonym TESTONE_IAU_VIEWER.attribute_value_pairs for TESTONE_IAU.attribute_value_pairs
/

create or replace synonym TESTONE_IAU_APPEND.attribute_value_pairs for TESTONE_IAU.attribute_value_pairs
/

create or replace synonym TESTONE_IAU_VIEWER.auditreports_pkg for TESTONE_IAU.auditreports_pkg
/

create or replace synonym TESTONE_IAU_APPEND.auditreports_pkg for TESTONE_IAU.auditreports_pkg
/

create or replace synonym TESTONE_IAU_VIEWER.list_of_events for TESTONE_IAU.list_of_events
/

create or replace synonym TESTONE_IAU_APPEND.list_of_events for TESTONE_IAU.list_of_events
/

create or replace synonym TESTONE_IAU_VIEWER.auditschema_pkg for TESTONE_IAU.auditschema_pkg
/

create or replace synonym TESTONE_IAU_APPEND.auditschema_pkg for TESTONE_IAU.auditschema_pkg
/

CREATE or replace SYNONYM TESTONE_IAU_APPEND.ID_SEQ FOR TESTONE_IAU.ID_SEQ
/

CREATE or REPLACE SYNONYM TESTONE_IAU_VIEWER.IAU_DISP_NAMES_TL FOR TESTONE_IAU.IAU_DISP_NAMES_TL
/

CREATE or REPLACE SYNONYM TESTONE_IAU_APPEND.IAU_DISP_NAMES_TL FOR TESTONE_IAU.IAU_DISP_NAMES_TL
/

CREATE or REPLACE SYNONYM TESTONE_IAU_VIEWER.IAU_LOCALE_MAP_TL FOR TESTONE_IAU.IAU_LOCALE_MAP_TL
/

CREATE or REPLACE SYNONYM TESTONE_IAU_APPEND.IAU_LOCALE_MAP_TL FOR TESTONE_IAU.IAU_LOCALE_MAP_TL
/

UPDATE SYSTEM.SCHEMA_VERSION_REGISTRY SET status='LOADED' WHERE comp_id='IAU'  AND mrc_name='TESTONE'
/

GRANT REGISTRYACCESS TO TESTONE_IAU
/

---------------------------------------------------------
---------- IAU(Audit Services) SECTION ENDS ----------
---------------------------------------------------------


---------------------------------------------------------
---------- OPSS(Oracle Platform Security Services) SECTION STARTS ----------
---------------------------------------------------------


DECLARE
BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE SYSTEM.SCHEMA_VERSION_REGISTRY$ ADD EDITION VARCHAR2(30)';
EXCEPTION WHEN OTHERS THEN  NULL;
END;
/

DECLARE
compCnt NUMBER;
BEGIN
  SELECT COUNT(*) INTO compCnt FROM SCHEMA_VERSION_REGISTRY
  WHERE MRC_NAME='TESTONE' and COMP_ID='OPSS';
  IF compCnt = 0 THEN
  INSERT INTO SYSTEM.SCHEMA_VERSION_REGISTRY$   (comp_id, comp_name, mrc_name, mr_name,  mr_type, owner, version, status, edition, custom1)   VALUES ('OPSS', 'Oracle Platform Security Services', 'TESTONE', 'OPSS', 'OPSS', 'TESTONE_OPSS', '12.2.1.0.0', 'LOADING', '', 0);
  END IF;
END;

/

DECLARE
BEGIN
    EXECUTE IMMEDIATE 'CREATE ROLE REGISTRYACCESS';
EXCEPTION WHEN OTHERS THEN  NULL;
END;
/

GRANT SELECT, INSERT, UPDATE, DELETE ON SYSTEM.SCHEMA_VERSION_REGISTRY$ TO REGISTRYACCESS
/

GRANT SELECT, INSERT, UPDATE, DELETE ON SYSTEM.SCHEMA_VERSION_REGISTRY TO REGISTRYACCESS
/

accept SCHEMA_PASSWORD char prompt "Enter the schema password : " hide;
begin
 execute immediate 'CREATE USER TESTONE_OPSS 
    IDENTIFIED BY "&SCHEMA_PASSWORD" 
    DEFAULT TABLESPACE TESTONE_IAS_OPSS 
    TEMPORARY TABLESPACE TESTONE_IAS_TEMP '; 
end;

/

GRANT CREATE CLUSTER, 
    CREATE INDEXTYPE, 
    CREATE OPERATOR, 
    CREATE PROCEDURE,
    CREATE SEQUENCE,
    CREATE SESSION,
    CREATE TABLE,
    CREATE TRIGGER,
    CREATE TYPE,
    CREATE VIEW TO TESTONE_OPSS 
/

ALTER USER TESTONE_OPSS QUOTA UNLIMITED ON TESTONE_IAS_OPSS 
/

UPDATE SYSTEM.SCHEMA_VERSION_REGISTRY SET status='LOADED' WHERE comp_id='OPSS'  AND mrc_name='TESTONE'
/

GRANT REGISTRYACCESS TO TESTONE_OPSS
/

---------------------------------------------------------
---------- OPSS(Oracle Platform Security Services) SECTION ENDS ----------
---------------------------------------------------------


---------------------------------------------------------
---------- BIPLATFORM(Business Intelligence Platform) SECTION STARTS ----------
---------------------------------------------------------


DECLARE
BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE SYSTEM.SCHEMA_VERSION_REGISTRY$ ADD EDITION VARCHAR2(30)';
EXCEPTION WHEN OTHERS THEN  NULL;
END;
/

DECLARE
compCnt NUMBER;
BEGIN
  SELECT COUNT(*) INTO compCnt FROM SCHEMA_VERSION_REGISTRY
  WHERE MRC_NAME='TESTONE' and COMP_ID='BIPLATFORM';
  IF compCnt = 0 THEN
  INSERT INTO SYSTEM.SCHEMA_VERSION_REGISTRY$   (comp_id, comp_name, mrc_name, mr_name,  mr_type, owner, version, status, edition, custom1)   VALUES ('BIPLATFORM', 'OracleBI and EPM', 'TESTONE', 'BIPLATFORM', 'BIPLATFORM', 'TESTONE_BIPLATFORM', '12.2.1.0.0', 'LOADING', '', 8192);
  END IF;
END;

/

DECLARE
BEGIN
    EXECUTE IMMEDIATE 'CREATE ROLE REGISTRYACCESS';
EXCEPTION WHEN OTHERS THEN  NULL;
END;
/

GRANT SELECT, INSERT, UPDATE, DELETE ON SYSTEM.SCHEMA_VERSION_REGISTRY$ TO REGISTRYACCESS
/

GRANT SELECT, INSERT, UPDATE, DELETE ON SYSTEM.SCHEMA_VERSION_REGISTRY TO REGISTRYACCESS
/

accept SCHEMA_PASSWORD char prompt "Enter the schema password : " hide;
begin
 execute immediate 'CREATE USER TESTONE_BIPLATFORM identified by &SCHEMA_PASSWORD default tablespace TESTONE_BIPLATFORM temporary tablespace TESTONE_IAS_TEMP'; 
end;

/

grant resource to TESTONE_BIPLATFORM
/

grant connect to TESTONE_BIPLATFORM
/

grant create sequence to TESTONE_BIPLATFORM
/

grant unlimited tablespace TO TESTONE_BIPLATFORM
/

grant create trigger to TESTONE_BIPLATFORM
/

grant administer database trigger to TESTONE_BIPLATFORM
/

grant create view to TESTONE_BIPLATFORM
/

SET ECHO ON
/

SET FEEDBACK 1
/

SET NUMWIDTH 10
/

SET LINESIZE 80
/

SET TRIMSPOOL ON
/

SET TAB OFF
/

SET PAGESIZE 100
/

ALTER SESSION SET CURRENT_SCHEMA=TESTONE_BIPLATFORM
/

CREATE TABLE qrtz_job_details
  (
    JOB_NAME  VARCHAR2(200) NOT NULL,
    JOB_GROUP VARCHAR2(200) NOT NULL,
    DESCRIPTION VARCHAR2(250) NULL,
    JOB_CLASS_NAME   VARCHAR2(250) NOT NULL, 
    IS_DURABLE VARCHAR2(1) NOT NULL,
    IS_VOLATILE VARCHAR2(1) NOT NULL,
    IS_STATEFUL VARCHAR2(1) NOT NULL,
    REQUESTS_RECOVERY VARCHAR2(1) NOT NULL,
    JOB_DATA BLOB NULL,
    PRIMARY KEY (JOB_NAME,JOB_GROUP)
)
/

CREATE TABLE qrtz_job_listeners
  (
    JOB_NAME  VARCHAR2(200) NOT NULL, 
    JOB_GROUP VARCHAR2(200) NOT NULL,
    JOB_LISTENER VARCHAR2(200) NOT NULL,
    PRIMARY KEY (JOB_NAME,JOB_GROUP,JOB_LISTENER),
    FOREIGN KEY (JOB_NAME,JOB_GROUP) 
	REFERENCES QRTZ_JOB_DETAILS(JOB_NAME,JOB_GROUP)
)
/

CREATE TABLE qrtz_triggers
  (
    TRIGGER_NAME VARCHAR2(200) NOT NULL,
    TRIGGER_GROUP VARCHAR2(200) NOT NULL,
    JOB_NAME  VARCHAR2(200) NOT NULL, 
    JOB_GROUP VARCHAR2(200) NOT NULL,
    IS_VOLATILE VARCHAR2(1) NOT NULL,
    DESCRIPTION VARCHAR2(250) NULL,
    NEXT_FIRE_TIME NUMBER(13) NULL,
    PREV_FIRE_TIME NUMBER(13) NULL,
    PRIORITY NUMBER(13) NULL,
    TRIGGER_STATE VARCHAR2(16) NOT NULL,
    TRIGGER_TYPE VARCHAR2(8) NOT NULL,
    START_TIME NUMBER(13) NOT NULL,
    END_TIME NUMBER(13) NULL,
    CALENDAR_NAME VARCHAR2(200) NULL,
    MISFIRE_INSTR NUMBER(2) NULL,
    JOB_DATA BLOB NULL,
    PRIMARY KEY (TRIGGER_NAME,TRIGGER_GROUP),
    FOREIGN KEY (JOB_NAME,JOB_GROUP) 
	REFERENCES QRTZ_JOB_DETAILS(JOB_NAME,JOB_GROUP) 
)
/

CREATE TABLE qrtz_simple_triggers
  (
    TRIGGER_NAME VARCHAR2(200) NOT NULL,
    TRIGGER_GROUP VARCHAR2(200) NOT NULL,
    REPEAT_COUNT NUMBER(7) NOT NULL,
    REPEAT_INTERVAL NUMBER(12) NOT NULL,
    TIMES_TRIGGERED NUMBER(10) NOT NULL,
    PRIMARY KEY (TRIGGER_NAME,TRIGGER_GROUP),
    FOREIGN KEY (TRIGGER_NAME,TRIGGER_GROUP) 
	REFERENCES QRTZ_TRIGGERS(TRIGGER_NAME,TRIGGER_GROUP)
)
/

CREATE TABLE qrtz_cron_triggers
  (
    TRIGGER_NAME VARCHAR2(200) NOT NULL,
    TRIGGER_GROUP VARCHAR2(200) NOT NULL,
    CRON_EXPRESSION VARCHAR2(120) NOT NULL,
    TIME_ZONE_ID VARCHAR2(80),
    PRIMARY KEY (TRIGGER_NAME,TRIGGER_GROUP),
    FOREIGN KEY (TRIGGER_NAME,TRIGGER_GROUP) 
	REFERENCES QRTZ_TRIGGERS(TRIGGER_NAME,TRIGGER_GROUP)
)
/

CREATE TABLE qrtz_blob_triggers
  (
    TRIGGER_NAME VARCHAR2(200) NOT NULL,
    TRIGGER_GROUP VARCHAR2(200) NOT NULL,
    BLOB_DATA BLOB NULL,
    PRIMARY KEY (TRIGGER_NAME,TRIGGER_GROUP),
    FOREIGN KEY (TRIGGER_NAME,TRIGGER_GROUP) 
        REFERENCES QRTZ_TRIGGERS(TRIGGER_NAME,TRIGGER_GROUP)
)
/

CREATE TABLE qrtz_trigger_listeners
  (
    TRIGGER_NAME  VARCHAR2(200) NOT NULL, 
    TRIGGER_GROUP VARCHAR2(200) NOT NULL,
    TRIGGER_LISTENER VARCHAR2(200) NOT NULL,
    PRIMARY KEY (TRIGGER_NAME,TRIGGER_GROUP,TRIGGER_LISTENER),
    FOREIGN KEY (TRIGGER_NAME,TRIGGER_GROUP) 
	REFERENCES QRTZ_TRIGGERS(TRIGGER_NAME,TRIGGER_GROUP)
)
/

CREATE TABLE qrtz_calendars
  (
    CALENDAR_NAME  VARCHAR2(200) NOT NULL, 
    CALENDAR BLOB NOT NULL,
    PRIMARY KEY (CALENDAR_NAME)
)
/

CREATE TABLE qrtz_paused_trigger_grps
  (
    TRIGGER_GROUP  VARCHAR2(200) NOT NULL, 
    PRIMARY KEY (TRIGGER_GROUP)
)
/

CREATE TABLE qrtz_fired_triggers 
  (
    ENTRY_ID VARCHAR2(95) NOT NULL,
    TRIGGER_NAME VARCHAR2(200) NOT NULL,
    TRIGGER_GROUP VARCHAR2(200) NOT NULL,
    IS_VOLATILE VARCHAR2(1) NOT NULL,
    INSTANCE_NAME VARCHAR2(200) NOT NULL,
    FIRED_TIME NUMBER(13) NOT NULL,
    PRIORITY NUMBER(13) NOT NULL,
    STATE VARCHAR2(16) NOT NULL,
    JOB_NAME VARCHAR2(200) NULL,
    JOB_GROUP VARCHAR2(200) NULL,
    IS_STATEFUL VARCHAR2(1) NULL,
    REQUESTS_RECOVERY VARCHAR2(1) NULL,
    PRIMARY KEY (ENTRY_ID)
)
/

CREATE TABLE qrtz_scheduler_state 
  (
    INSTANCE_NAME VARCHAR2(200) NOT NULL,
    LAST_CHECKIN_TIME NUMBER(13) NOT NULL,
    CHECKIN_INTERVAL NUMBER(13) NOT NULL,
    PRIMARY KEY (INSTANCE_NAME)
)
/

CREATE TABLE qrtz_locks
  (
    LOCK_NAME  VARCHAR2(40) NOT NULL, 
    PRIMARY KEY (LOCK_NAME)
)
/

INSERT INTO qrtz_locks values('TRIGGER_ACCESS')
/

INSERT INTO qrtz_locks values('JOB_ACCESS')
/

INSERT INTO qrtz_locks values('CALENDAR_ACCESS')
/

INSERT INTO qrtz_locks values('STATE_ACCESS')
/

INSERT INTO qrtz_locks values('MISFIRE_ACCESS')
/

create index idx_qrtz_j_req_recovery on qrtz_job_details(REQUESTS_RECOVERY)
/

create index idx_qrtz_t_next_fire_time on qrtz_triggers(NEXT_FIRE_TIME)
/

create index idx_qrtz_t_state on qrtz_triggers(TRIGGER_STATE)
/

create index idx_qrtz_t_nft_st on qrtz_triggers(NEXT_FIRE_TIME,TRIGGER_STATE)
/

create index idx_qrtz_t_volatile on qrtz_triggers(IS_VOLATILE)
/

create index idx_qrtz_ft_trig_name on qrtz_fired_triggers(TRIGGER_NAME)
/

create index idx_qrtz_ft_trig_group on qrtz_fired_triggers(TRIGGER_GROUP)
/

create index idx_qrtz_ft_trig_nm_gp on qrtz_fired_triggers(TRIGGER_NAME,TRIGGER_GROUP)
/

create index idx_qrtz_ft_trig_volatile on qrtz_fired_triggers(IS_VOLATILE)
/

create index idx_qrtz_ft_trig_inst_name on qrtz_fired_triggers(INSTANCE_NAME)
/

create index idx_qrtz_ft_job_name on qrtz_fired_triggers(JOB_NAME)
/

create index idx_qrtz_ft_job_group on qrtz_fired_triggers(JOB_GROUP)
/

create index idx_qrtz_ft_job_stateful on qrtz_fired_triggers(IS_STATEFUL)
/

create index idx_qrtz_ft_job_req_recovery on qrtz_fired_triggers(REQUESTS_RECOVERY)
/

CREATE TABLE "SEQUENCE" 
(
"SEQ_NAME" VARCHAR2(50) NOT NULL ENABLE, 
"SEQ_COUNT" NUMBER(38,0)
)
/

ALTER TABLE "SEQUENCE" ADD PRIMARY KEY ("SEQ_NAME") ENABLE
/

Insert into SEQUENCE ("SEQ_NAME","SEQ_COUNT") values ('OUTPUT_ID_SEQ',1000)
/

Insert into SEQUENCE ("SEQ_NAME","SEQ_COUNT") values ('JOB_ID_SEQ', 1000)
/

Insert into SEQUENCE ("SEQ_NAME","SEQ_COUNT") values ('DELIVERY_ID_SEQ',1000)
/

Insert into SEQUENCE ("SEQ_NAME","SEQ_COUNT") values ('DATA_ID_SEQ', 1000)
/

CREATE TABLE "XMLP_APPINFO" 
(
"COMPONENT" VARCHAR2(100) NOT NULL ENABLE, 
"NAME" VARCHAR2(100) NOT NULL ENABLE, 
"VALUE" VARCHAR2(1000)
)
/

Insert into XMLP_APPINFO ("COMPONENT","NAME","VALUE") values ('SCHEDULER','QUARTZ_VERSION','1.6.6')
/

Insert into XMLP_APPINFO ("COMPONENT","NAME","VALUE") values ('SCHEDULER','SCHEMA_VERSION','11.1.01')
/

CREATE TABLE "XMLP_SCHED_JOB" 
(
"JOB_ID" NUMBER(12,0) NOT NULL ENABLE,
"JOB_TYPE" CHAR(1) NOT NULL ENABLE,
"DELETED" CHAR(1), 
"STATUS" CHAR(1),
"STATUS_DETAIL" VARCHAR2(1000),
"INSTANCE_ID" NUMBER(12,0) DEFAULT 0 NOT NULL ENABLE,
"LAST_UPDATED" TIMESTAMP (6), 
"CREATED" TIMESTAMP (6), 
"BURSTING_PARAMETERS"     BLOB, 
"DELIVERY_PARAMETERS"     BLOB, 
"SCHEDULE_PARAMETERS"     BLOB, 
"REPORT_PARAMETERS"       BLOB, 
"NOTIFICATION_PARAMETERS" BLOB, 
"XSCHURL" VARCHAR2(4000), 
"DELIVERY_DESCRIPTION" VARCHAR2(4000), 
"SCHEDULE_DESCRIPTION" VARCHAR2(100), 
"END_DATE" TIMESTAMP (6), 
"START_DATE" TIMESTAMP (6), 
"BURSTING" CHAR(1), 
"SHARED_OPTION" CHAR(1), 
"RUN_TYPE" CHAR(1), 
"USER_DESCRIPTION" VARCHAR2(4000), 
"USER_JOB_NAME" VARCHAR2(1000), 
"ISSUER" VARCHAR2(100) NOT NULL ENABLE, 
"OWNER" VARCHAR2(100) NOT NULL ENABLE, 
"REPORT_URL" VARCHAR2(1000) NOT NULL ENABLE, 
"JOB_GROUP" VARCHAR2(1000) NOT NULL ENABLE,
"JOB_SET_ID" NUMBER(12,0),
"PARENT_JOB_ID" NUMBER(12,0),
"SCHEDULE_SOURCE" VARCHAR2(100),
"SCHEDULE_CONTEXT" VARCHAR2(1000),
"XML_DATA_AVAILABLE" CHAR(1), 
"XML_DATA_COMPRESSED" CHAR(1), 
"XML_DATA_CONTENT_TYPE" VARCHAR2(100),
"STORAGE_TYPE"     VARCHAR2(100) DEFAULT 'db',
"DATA_LOCATOR"     VARCHAR2(1000)
) 
/

ALTER TABLE "XMLP_SCHED_JOB" ADD PRIMARY KEY ("JOB_ID") ENABLE
/

CREATE TABLE "XMLP_SCHED_OUTPUT" 
(	
"OUTPUT_ID" NUMBER(12,0) NOT NULL ENABLE, 
"DELETED" CHAR(1), 
"LAST_UPDATED" TIMESTAMP (6), 
"CREATED" TIMESTAMP (6), 
"DOCUMENT_DATA_AVAILABLE" CHAR(1), 
"DOCUMENT_DATA_COMPRESSED" CHAR(1), 
"DOCUMENT_DATA_CONTENT_TYPE" VARCHAR2(100), 
"OUTPUT_PARAMETERS" BLOB, 
"STATUS" CHAR(1), 
"STATUS_DETAIL" VARCHAR2(1000),
"JOB_ID" NUMBER(12,0) NOT NULL ENABLE,
"PARENT_OUTPUT_ID" NUMBER(12,0), 
"JOB_NAME" VARCHAR2(1000), 
"OUTPUT_NAME" VARCHAR2(100),
"STORAGE_TYPE"     VARCHAR2(100) DEFAULT 'db',
"DOCUMENT_LOCATOR" VARCHAR2(1000)
) 
/

ALTER TABLE "XMLP_SCHED_OUTPUT" ADD PRIMARY KEY ("OUTPUT_ID") ENABLE
/

CREATE TABLE "XMLP_SCHED_DELIVERY" 
(	
"DELIVERY_ID"         NUMBER(12,0) NOT NULL ENABLE, 
"OUTPUT_ID"           NUMBER(12,0) NOT NULL ENABLE, 
"PARENT_DELIVERY_ID"  NUMBER(12,0), 
"LAST_UPDATED"        TIMESTAMP (6), 
"CREATED"             TIMESTAMP (6),
"STATUS"              CHAR(1), 
"STATUS_DETAIL"       VARCHAR2(1000), 
"DELIVERY_PARAMETERS" BLOB	
) 
/

ALTER TABLE "XMLP_SCHED_DELIVERY" ADD PRIMARY KEY ("DELIVERY_ID") ENABLE
/

CREATE TABLE "XMLP_SCHED_DATA" 
(	
"DATA_ID"      NUMBER(12,0) NOT NULL ENABLE,
"NEXT_DATA_ID" NUMBER(12,0),
"LAST_UPDATED" TIMESTAMP (6), 
"CREATED"      TIMESTAMP (6),
"DATA_SIZE"    NUMBER(12,0),
"CHUNK_SIZE"   NUMBER(12,0),
"DATA"         BLOB	
) 
/

ALTER TABLE "XMLP_SCHED_DATA" ADD PRIMARY KEY ("DATA_ID") ENABLE
/

CREATE INDEX IDX_XMLP_JOB_JTYP ON XMLP_SCHED_JOB(JOB_TYPE)
/

CREATE INDEX IDX_XMLP_JOB_OWNE ON XMLP_SCHED_JOB(OWNER)
/

CREATE INDEX IDX_XMLP_JOB_PJID ON XMLP_SCHED_JOB(PARENT_JOB_ID)
/

CREATE INDEX IDX_XMLP_JOB_SOPT ON XMLP_SCHED_JOB(SHARED_OPTION)
/

CREATE INDEX IDX_XMLP_JOB_SDAT ON XMLP_SCHED_JOB(START_DATE)
/

CREATE INDEX IDX_XMLP_JOB_EDAT ON XMLP_SCHED_JOB(END_DATE)
/

CREATE INDEX IDX_XMLP_JOB_UJNA ON XMLP_SCHED_JOB(USER_JOB_NAME)
/

CREATE INDEX IDX_XMLP_JOB_RURL ON XMLP_SCHED_JOB(REPORT_URL)
/

CREATE INDEX IDX_XMLP_JOB_CREA ON XMLP_SCHED_JOB(CREATED)
/

CREATE INDEX IDX_XMLP_JOB_INID ON XMLP_SCHED_JOB(INSTANCE_ID)
/

CREATE INDEX IDX_XMLP_JOB_DELE ON XMLP_SCHED_JOB(DELETED)
/

CREATE INDEX IDX_XMLP_JOB_STAT ON XMLP_SCHED_JOB(STATUS)
/

CREATE INDEX IDX_XMLP_JOB_SSRC ON XMLP_SCHED_JOB(SCHEDULE_SOURCE)
/

CREATE INDEX IDX_XMLP_JOB_SCTX ON XMLP_SCHED_JOB(SCHEDULE_CONTEXT)
/

CREATE INDEX IDX_XMLP_OUT_JOID ON XMLP_SCHED_OUTPUT(JOB_ID)
/

CREATE INDEX IDX_XMLP_OUT_DELE ON XMLP_SCHED_OUTPUT(DELETED)
/

CREATE INDEX IDX_XMLP_OUT_JNAM ON XMLP_SCHED_OUTPUT(JOB_NAME)
/

CREATE INDEX IDX_XMLP_OUT_STAT ON XMLP_SCHED_OUTPUT(STATUS)
/

CREATE INDEX IDX_XMLP_DEL_OUID ON XMLP_SCHED_DELIVERY(OUTPUT_ID)
/

CREATE INDEX IDX_XMLP_DEL_STAT ON XMLP_SCHED_DELIVERY(STATUS)
/

CREATE INDEX IDX_XMLP_DAT_NDID ON XMLP_SCHED_DATA(NEXT_DATA_ID)
/


ALTER SESSION SET CURRENT_SCHEMA=TESTONE_BIPLATFORM
/

CREATE TABLE S_NQ_JOB
(
	JOB_ID			NUMBER(10,0)	not null,
	NAME 			NVARCHAR2(50),  -- Use NVARCHAR2 for support of unicode Agent names and char length semantics (Bug 6194918)
	DESC_TEXT		VARCHAR2(255),
	SCRIPT_TYPE 		VARCHAR2(20),
	SCRIPT 			VARCHAR2(255),
	MAX_RUNTIME_MS 		NUMBER(10,0),
	USER_ID 		VARCHAR2(128),
	NEXT_RUNTIME_TS		DATE,
	LAST_RUNTIME_TS		DATE,
	MAX_CNCURRENT_INST	NUMBER(10,0),
	BEGIN_YEAR 		NUMBER(10,0),
	BEGIN_MONTH 		NUMBER(10,0),
	BEGIN_DAY		NUMBER(10,0),
	END_YEAR		NUMBER(10,0),
	END_MONTH		NUMBER(10,0),
	END_DAY			NUMBER(10,0),
	START_HOUR		NUMBER(10,0),
	START_MINUTE		NUMBER(10,0),
	END_HOUR		NUMBER(10,0),
	END_MINUTE		NUMBER(10,0),
	INTERVAL_MINUTE		NUMBER(10,0),
	TRIGGER_TYPE 		NUMBER(10,0),
	TRIGGER_DAY_INT 	NUMBER(10,0),
	TRIGGER_WEEK_INT 	NUMBER(10,0),
	TRIGGER_RANGE_DOW 	NUMBER(10,0),
	TRIGGER_RANGE_DOM 	NUMBER(10,0),
	TRIGGER_RANGE_MTH 	NUMBER(10,0),
	TRIG_RANGE_DAY_OCC 	NUMBER(10,0),
	DELETE_DONE_FLG 	NUMBER(10,0)	not null,
	DISABLE_FLG 		NUMBER(10,0)	not null,
	HAS_END_DT_FLG 		NUMBER(10,0)	not null,
	EXEC_WHEN_MISS_FLG 	NUMBER(10,0)	not null,
	DEL_SCPT_DONE_FLG 	NUMBER(10,0)	not null,
	PATH_IN_SCPT_FLG	NUMBER(10,0)	not null,
	ISUSER_SCPT_FLG 	NUMBER(10,0)	not null,
	DELETE_FLG 		NUMBER(10,0)	not null,
	TZ_NAME			VARCHAR2(100),
	SERVICE         VARCHAR2(128)  not null
)
/

create unique index S_NQ_JOB_P1 on S_NQ_JOB
(JOB_ID)
/

create index S_NQ_JOB_M1 on S_NQ_JOB
(NEXT_RUNTIME_TS)
/

create index S_NQ_JOB_M2 on S_NQ_JOB
(USER_ID)
/

create index S_NQ_JOB_M3 ON S_NQ_JOB 
(SERVICE)
/

CREATE TABLE S_NQ_JOB_PARAM
(
	JOB_ID	 		NUMBER(10,0) 	not null,
	RELATIVE_ORDER 		NUMBER(10,0)	not null,
	JOB_PARAM 		VARCHAR2(255),
	DELETE_FLG 		NUMBER(10,0)	not null
)
/

CREATE TABLE S_NQ_SERVICE (
       SERVICE VARCHAR2(128) NOT NULL,       
       SUSPENDED_FLG NUMBER(10,0) NOT NULL
)
/

create unique index S_NQ_SERVICE_P1 on S_NQ_SERVICE
(SERVICE)
/

CREATE TABLE S_NQ_INSTANCE
(
	JOB_ID	 		NUMBER(10,0)	not null,
	INSTANCE_ID		NUMBER(20,0)	not null,
	STATUS			NUMBER(10,0),
	BEGIN_TS		DATE,
	END_TS			DATE,
	EXIT_CODE		NUMBER(10,0),
	DELETE_FLG		NUMBER(10,0) 	not null,
	ERROR_MSG_FLG		NUMBER(10,0) 	not null
)
/

create unique index S_NQ_INSTANCE_U1 on S_NQ_INSTANCE
(JOB_ID,INSTANCE_ID)
/

CREATE INDEX S_NQ_INSTANCE_M1 ON S_NQ_INSTANCE (END_TS, STATUS, INSTANCE_ID)
/

CREATE INDEX S_NQ_INSTANCE_M2 ON S_NQ_INSTANCE (BEGIN_TS, STATUS, INSTANCE_ID)
/

CREATE INDEX S_NQ_INSTANCE_M3 ON S_NQ_INSTANCE (INSTANCE_ID, DELETE_FLG)
/

CREATE INDEX S_NQ_INSTANCE_M4 ON S_NQ_INSTANCE (JOB_ID, INSTANCE_ID, STATUS, DELETE_FLG)
/

CREATE INDEX S_NQ_INSTANCE_M5 ON S_NQ_INSTANCE (STATUS, DELETE_FLG)
/

CREATE TABLE S_NQ_ERR_MSG
(
	JOB_ID	 		NUMBER(10,0) 	not null,
	INSTANCE_ID 		NUMBER(20,0) 	not null,
	RELATIVE_ORDER 		NUMBER(10,0)	not null,
	ERROR_MSG_TEXT	 	VARCHAR2(255),
	DELETE_FLG		NUMBER(10,0)	not null
)
/

create unique index S_NQ_ERR_MSG_U1 on S_NQ_ERR_MSG
(JOB_ID,INSTANCE_ID,RELATIVE_ORDER)
/

CREATE INDEX S_NQ_ERR_MSG_F1 ON S_NQ_ERR_MSG (INSTANCE_ID)
/

COMMIT
/

COMMIT
/

COMMIT
/

SET ECHO ON
/

SET FEEDBACK 1
/

SET NUMWIDTH 10
/

SET LINESIZE 80
/

SET TRIMSPOOL ON
/

SET TAB OFF
/

SET PAGESIZE 100
/

ALTER SESSION SET CURRENT_SCHEMA=TESTONE_BIPLATFORM
/

CREATE TABLE TESTONE_BIPLATFORM."ANNOTATIONS" 
   (	"OBJECT_ID" VARCHAR2(400), 
	"GRAIN_HASH_KEY" VARCHAR2(50), 
	"QDR_HASH_KEY" VARCHAR2(50), 
	"OBJECT_KEY" VARCHAR2(600),
	"ENTRY_TIME" TIMESTAMP (6), 
	"SUBJECT" VARCHAR2(400), 
	"NOTES" VARCHAR2(1500), 
	"USER_INFO" VARCHAR2(400) NOT NULL ENABLE, 
	"ITEM" VARCHAR2(50), 
	"ANNOTATION_ID" VARCHAR2(50) NOT NULL ENABLE, 
	"PARENT_ANNOTATION_ID" VARCHAR2(50),
	"TENANT" VARCHAR2(50)
   ) 
/

ALTER TABLE TESTONE_BIPLATFORM."ANNOTATIONS" ADD PRIMARY KEY ("OBJECT_ID", "ITEM", "GRAIN_HASH_KEY", "QDR_HASH_KEY", "ENTRY_TIME") ENABLE
/

ALTER TABLE TESTONE_BIPLATFORM."ANNOTATIONS" ADD UNIQUE ("ANNOTATION_ID") ENABLE
/

CREATE INDEX TESTONE_BIPLATFORM."ANNOTATIONS_INDEX" ON TESTONE_BIPLATFORM."ANNOTATIONS" ("OBJECT_KEY")
/

CREATE TABLE TESTONE_BIPLATFORM."ASSESSMENT_OVERRIDES" 
   (	"OBJECT_ID" VARCHAR2(400), 
	"GRAIN_HASH_KEY" VARCHAR2(50), 
	"QDR_HASH_KEY" VARCHAR2(50), 
	"OBJECT_KEY" VARCHAR2(600),
	"ENTRY_TIME" TIMESTAMP (6), 
	"SUBJECT" VARCHAR2(400), 
	"NOTES" VARCHAR2(1500), 
	"USER_INFO" VARCHAR2(400) NOT NULL ENABLE, 
	"ITEM" VARCHAR2(50), 
	"OVERRIDE_ID" VARCHAR2(50) NOT NULL ENABLE, 
	"ORIGINAL_ASSESSMENT" NUMBER(5,2), 
	"OVERRIDDEN_ASSESSMENT" NUMBER(5,2),
	"TENANT" VARCHAR2(50)
   ) 
/

ALTER TABLE TESTONE_BIPLATFORM."ASSESSMENT_OVERRIDES" ADD PRIMARY KEY ("OBJECT_ID", "ITEM", "GRAIN_HASH_KEY", "QDR_HASH_KEY", "ENTRY_TIME") ENABLE
/

ALTER TABLE TESTONE_BIPLATFORM."ASSESSMENT_OVERRIDES" ADD UNIQUE ("OVERRIDE_ID") ENABLE
/

CREATE INDEX TESTONE_BIPLATFORM."ASSESSMENT_OVERRIDES_INDEX" ON TESTONE_BIPLATFORM."ASSESSMENT_OVERRIDES" ("OBJECT_KEY")
/

CREATE TABLE TESTONE_BIPLATFORM."SCORECARD_REGISTRY" 
   (	"PLATFORM" VARCHAR2(50), 
		"VERSION" VARCHAR2(50)
   ) 
/

insert into TESTONE_BIPLATFORM."SCORECARD_REGISTRY" ("PLATFORM", "VERSION") values ('ORACLE', '11.1.1.2.0')
/

COMMIT
/

COMMIT
/

COMMIT
/


ALTER SESSION SET CURRENT_SCHEMA=TESTONE_BIPLATFORM
/

create table S_NQ_ACCT
(
	USER_NAME		VARCHAR2(128),
	REPOSITORY_NAME		VARCHAR2(128),
	SUBJECT_AREA_NAME    	VARCHAR2(128),
	NODE_ID			VARCHAR2(100),
	START_TS		DATE,
	START_DT		DATE,
	START_HOUR_MIN		CHAR(5),
	END_TS			DATE,
	END_DT			DATE,
	END_HOUR_MIN		CHAR(5),
	QUERY_TEXT          	VARCHAR2(1024),
	QUERY_BLOB          	CLOB,
	QUERY_KEY	        VARCHAR2(128),
	SUCCESS_FLG		NUMBER(10,0),
	ROW_COUNT		NUMBER(20,0),
	TOTAL_TIME_SEC		NUMBER(10,0),
	COMPILE_TIME_SEC  	NUMBER(10,0),
	NUM_DB_QUERY       	NUMBER(10,0),
	CUM_DB_TIME_SEC    	NUMBER(10,0),
	CUM_NUM_DB_ROW        	NUMBER(20,0),
	CACHE_IND_FLG		CHAR(1) default 'N' not null,
	QUERY_SRC_CD		VARCHAR2(30) default '',
	SAW_SRC_PATH		VARCHAR2(250) default '',
	SAW_DASHBOARD		VARCHAR2(150) default '',
	SAW_DASHBOARD_PG	VARCHAR2(150) default '',
	PRESENTATION_NAME	VARCHAR2(128) default '',
	ERROR_TEXT		VARCHAR2(250) default '',
	IMPERSONATOR_USER_NAME	VARCHAR2(128) default '',
	NUM_CACHE_INSERTED	NUMBER(10,0) default null,
	NUM_CACHE_HITS		NUMBER(10,0) default null,
	ID	        	VARCHAR2(50),
	ECID 			VARCHAR2(1024),
	TENANT_ID		VARCHAR2(128),
	SERVICE_NAME		VARCHAR2(128),
	SESSION_ID		NUMBER(10),
	HASH_ID			VARCHAR2(128),
	TOTAL_TEMP_KB		NUMBER(20,0) default null,
	RESP_TIME_SEC		NUMBER(10,0) default null,
	CONSTRAINT S_NQ_ACCT_pk PRIMARY KEY (ID)
)
/

create index S_NQ_ACCT_M1 on S_NQ_ACCT
(START_DT, START_HOUR_MIN, USER_NAME)
/

create index S_NQ_ACCT_M2 on S_NQ_ACCT
(START_HOUR_MIN, USER_NAME)
/

create index S_NQ_ACCT_M3 on S_NQ_ACCT
(USER_NAME)
/

create table S_NQ_DB_ACCT
(
        ID                      NUMBER(10,0),
        LOGICAL_QUERY_ID        VARCHAR2(50),
        QUERY_TEXT              VARCHAR2(1024),
        QUERY_BLOB              CLOB,
        TIME_SEC                NUMBER(10,0),
        ROW_COUNT               NUMBER(20,0),
        START_TS                DATE,
        START_DT                DATE,
        START_HOUR_MIN          CHAR(5),
        END_TS                  DATE,
        END_DT                  DATE,
        END_HOUR_MIN            CHAR(5),
	HASH_ID                 VARCHAR2(128),
	PHYSICAL_HASH_ID        VARCHAR2(128),
	CONSTRAINT fk_S_NQ_DB_ACCT  FOREIGN KEY (LOGICAL_QUERY_ID)  REFERENCES S_NQ_ACCT(ID) ON DELETE CASCADE
)
/

create index S_NQ_DB_ACCT_I1 on S_NQ_DB_ACCT (LOGICAL_QUERY_ID)
/

ALTER SESSION SET CURRENT_SCHEMA=TESTONE_BIPLATFORM
/

CREATE TABLE S_NQ_SUMMARY_ADVISOR
(
	Version CHAR(32) default '' NOT NULL,
	LogicalFactTableID CHAR(255) default '' NOT NULL,
	LogicalTableSourceIDVector	varchar2(4000),
	ProcessingTimeInMilliSec	NUMBER(10,0) default 0	NOT NULL,
	QueryLevelIDvector	CLOB,
	SourceCellLevelIDvector	CLOB,
	LOGICAL_QUERY_ID	VARCHAR2(50),
	QueryStatus	NUMBER(10,0) default 0 NOT NULL,
	GROUPBYCOLUMNIDVECTOR 	CLOB,
	MEASURECOLUMNIDVECTOR	CLOB,
	ROW_COUNT	NUMBER(20,0) default 0 NOT NULL,
	CONSTRAINT fk_S_NQ_SUMMARY_ADVISOR  FOREIGN KEY (LOGICAL_QUERY_ID)  REFERENCES S_NQ_ACCT(ID) ON DELETE CASCADE
)
/

create index S_NQ_SUMMARY_ADVISOR_I1 on S_NQ_SUMMARY_ADVISOR (LOGICAL_QUERY_ID)
/

ALTER SESSION SET CURRENT_SCHEMA=TESTONE_BIPLATFORM
/

CREATE TABLE S_NQ_EPT (
  UPDATE_TYPE    DECIMAL(10,0)  DEFAULT 1       NOT NULL,
  UPDATE_TS      TIMESTAMP(3) DEFAULT SYSTIMESTAMP NOT NULL,
  DATABASE_NAME  VARCHAR2(120)                      NULL,
  CATALOG_NAME   VARCHAR2(120)                      NULL,
  SCHEMA_NAME    VARCHAR2(120)                      NULL,
  TABLE_NAME     VARCHAR2(120)                  NOT NULL,
  OTHER_RESERVED VARCHAR2(120)  DEFAULT NULL        NULL 
) 
/

ALTER SESSION SET CURRENT_SCHEMA=TESTONE_BIPLATFORM
/

CREATE TABLE S_NQ_INITBLOCK
(
    USER_NAME           VARCHAR2(128),
    REPOSITORY_NAME     VARCHAR2(128),
    TENANT_ID           VARCHAR2(128),
    SERVICE_NAME        VARCHAR2(128),
    ECID                VARCHAR2(1024),
    SESSION_ID          NUMBER(10),
    BLOCK_NAME          VARCHAR2(128),
    START_TS            TIMESTAMP,
    END_TS              TIMESTAMP,
    DURATION            NUMBER(13,3),
    NOTES               VARCHAR2(1024)
)
/

ALTER SESSION SET CURRENT_SCHEMA=TESTONE_BIPLATFORM
/

CREATE TABLE CALCMGRCONFIG 
( CONFIGKEY NVARCHAR2(50) NULL,
 CONFIGVALUE NVARCHAR2(255) NULL 
) 

/

CREATE TABLE CALCMGRRULES 
( 
 ID NUMBER(10,0) NOT NULL,
 NAME NVARCHAR2(512) NOT NULL,
 UPPERNAME NVARCHAR2(512) NOT NULL,
 DESCRIPTION NVARCHAR2(255) NULL,
 OWNER NVARCHAR2(255) NULL,
 CREATED timestamp DEFAULT systimestamp NOT NULL,
 MODIFIEDBY NVARCHAR2(255) NULL,
 LASTMODIFIED timestamp NULL,
 LOCKEDBY NVARCHAR2(255) NULL,
 OPENFOREDITINGBY NVARCHAR2(255) NULL,
 ISOPENFOREDITING NUMBER(3,0) NULL,
 OBJECTTYPEID NUMBER(10,0) NOT NULL,
 PRODUCTTYPE NUMBER(10,0) NOT NULL,
 PROPERTY BLOB NULL,
 BODY BLOB NULL,
 LOCATION NVARCHAR2(255) NULL,
 LOCATIONSUBTYPE NVARCHAR2(255) NULL,
 VALIDATESTATUS NUMBER(3,0) NULL,
 DEPLOYSTATUS NUMBER(3,0) NULL 
) 

/

create sequence seq_CALCMGRRULES start with 1 increment by 1 order

/

alter table CALCMGRRULES add constraint pkCALCMGRRULES1 primary key(ID)

/

alter table CALCMGRRULES add constraint ukCALCMGRRULES1 unique(NAME,LOCATION)

/

CREATE TABLE CALCMGRSEQUENCES 
( 
 ID NUMBER(10,0) NOT NULL,
 NAME NVARCHAR2(512) NOT NULL,
 UPPERNAME NVARCHAR2(512) NOT NULL,
 DESCRIPTION NVARCHAR2(255) NULL,
 OWNER NVARCHAR2(255) NULL,
 CREATED timestamp DEFAULT systimestamp NOT NULL,
 MODIFIEDBY NVARCHAR2(255) NULL,
 LASTMODIFIED timestamp NULL,
 LOCKEDBY NVARCHAR2(255) NULL,
 OPENFOREDITINGBY NVARCHAR2(255) NULL,
 ISOPENFOREDITING NUMBER(3,0) NULL,
 OBJECTTYPEID NUMBER(10,0) NOT NULL,
 PRODUCTTYPE NUMBER(10,0) NOT NULL,
 PROPERTY BLOB NULL,
 BODY BLOB NULL,
 LOCATION NVARCHAR2(255) NULL,
 LOCATIONSUBTYPE NVARCHAR2(255) NULL,
 VALIDATESTATUS NUMBER(3,0) NULL,
 DEPLOYSTATUS NUMBER(3,0) NULL 
) 

/

create sequence seq_CALCMGRSEQUENCES start with 1 increment by 1 order

/

alter table CALCMGRSEQUENCES add constraint pkCALCMGRSEQUENCES1 primary key(ID)

/

alter table CALCMGRSEQUENCES add constraint ukCALCMGRSEQUENCES1 unique(NAME,LOCATION)

/

CREATE TABLE CALCMGRVARIABLES 
( 
 ID NUMBER(10,0) NOT NULL,
 NAME NVARCHAR2(512) NOT NULL,
 UPPERNAME NVARCHAR2(512) NOT NULL,
 DESCRIPTION NVARCHAR2(255) NULL,
 OWNER NVARCHAR2(255) NULL,
 CREATED timestamp DEFAULT systimestamp NOT NULL,
 MODIFIEDBY NVARCHAR2(255) NULL,
 LASTMODIFIED timestamp NULL,
 LOCKEDBY NVARCHAR2(255) NULL,
 OPENFOREDITINGBY NVARCHAR2(255) NULL,
 ISOPENFOREDITING NUMBER(3,0) NULL,
 OBJECTTYPEID NUMBER(10,0) NOT NULL,
 PRODUCTTYPE NUMBER(10,0) NOT NULL,
 PROPERTY BLOB NULL,
 BODY BLOB NULL,
 LOCATION NVARCHAR2(255) NULL,
 LOCATIONSUBTYPE NVARCHAR2(255) NULL,
 VALIDATESTATUS NUMBER(3,0) NULL,
 DEPLOYSTATUS NUMBER(3,0) NULL,
 PARENTID NUMBER(10,0) NULL,
 PARENTTYPE NUMBER(10,0) NULL 
) 

/

create sequence seq_CALCMGRVARIABLES start with 1 increment by 1 order

/

alter table CALCMGRVARIABLES add constraint pkCALCMGRVARIABLES1 primary key(ID)

/

alter table CALCMGRVARIABLES add constraint ukCALCMGRVARIABLES1 unique(PRODUCTTYPE,NAME,LOCATION,LOCATIONSUBTYPE,PARENTID,PARENTTYPE)

/

CREATE TABLE CALCMGRCACHEEVENTS 
( 
 ACTION NVARCHAR2(10) NOT NULL,
 ACTIONTIME timestamp DEFAULT systimestamp NOT NULL,
 CACHENAME NVARCHAR2(512) NOT NULL,
 CLASSNAME NVARCHAR2(255) NOT NULL,
 KEYDEF BLOB NULL,
 DATA BLOB NULL,
 SOURCE NVARCHAR2(512) NULL 
) 

/

CREATE INDEX idxCALCMGRCACHEEVENTS1 ON CALCMGRCACHEEVENTS ( ACTIONTIME  )

/

CREATE TABLE CALCMGRCOMPONENTS 
( 
 ID NUMBER(10,0) NOT NULL,
 NAME NVARCHAR2(512) NOT NULL,
 UPPERNAME NVARCHAR2(512) NOT NULL,
 DESCRIPTION NVARCHAR2(255) NULL,
 OWNER NVARCHAR2(255) NULL,
 CREATED timestamp DEFAULT systimestamp NOT NULL,
 MODIFIEDBY NVARCHAR2(255) NULL,
 LASTMODIFIED timestamp NULL,
 LOCKEDBY NVARCHAR2(255) NULL,
 OPENFOREDITINGBY NVARCHAR2(255) NULL,
 ISOPENFOREDITING NUMBER(3,0) NULL,
 OBJECTTYPEID NUMBER(10,0) NOT NULL,
 PRODUCTTYPE NUMBER(10,0) NOT NULL,
 PROPERTY BLOB NULL,
 BODY BLOB NULL,
 LOCATION NVARCHAR2(255) NULL,
 LOCATIONSUBTYPE NVARCHAR2(255) NULL,
 VALIDATESTATUS NUMBER(3,0) NULL,
 DEPLOYSTATUS NUMBER(3,0) NULL 
) 

/

create sequence seq_CALCMGRCOMPONENTS start with 1 increment by 1 order

/

alter table CALCMGRCOMPONENTS add constraint pkCALCMGRCOMPONENTS1 primary key(ID)

/

alter table CALCMGRCOMPONENTS add constraint ukCALCMGRCOMPONENTS1 unique(NAME,LOCATION,LOCATIONSUBTYPE)

/

CREATE TABLE CALCMGROBJECTLINKS 
( 
 PARENTID NUMBER(10,0) NOT NULL,
 PARENTTYPE NUMBER(10,0) NOT NULL,
 CHILDID NUMBER(10,0) NOT NULL,
 CHILDTYPE NUMBER(10,0) NOT NULL,
 CHILDINDEX NUMBER(10,0) NOT NULL 
) 

/

CREATE INDEX idxCALCMGROBJECTLINKS1 ON CALCMGROBJECTLINKS ( PARENTID , PARENTTYPE  )

/

CREATE INDEX idxCALCMGROBJECTLINKS2 ON CALCMGROBJECTLINKS ( CHILDID , CHILDTYPE  )

/

alter table CALCMGROBJECTLINKS add constraint ukCALCMGROBJECTLINKS1 unique(PARENTID,PARENTTYPE,CHILDID,CHILDTYPE,CHILDINDEX)

/

CREATE TABLE CALCMGRFOLDERS 
( 
 ID NUMBER(10,0) NOT NULL,
 NAME NVARCHAR2(512) NOT NULL,
 UPPERNAME NVARCHAR2(512) NOT NULL,
 DESCRIPTION NVARCHAR2(255) NULL,
 OWNER NVARCHAR2(255) NULL,
 CREATED timestamp DEFAULT systimestamp NOT NULL,
 MODIFIEDBY NVARCHAR2(255) NULL,
 LASTMODIFIED timestamp NULL,
 LOCKEDBY NVARCHAR2(255) NULL,
 OPENFOREDITINGBY NVARCHAR2(255) NULL,
 ISOPENFOREDITING NUMBER(3,0) NULL,
 OBJECTTYPEID NUMBER(10,0) NOT NULL,
 PRODUCTTYPE NUMBER(10,0) NOT NULL,
 PROPERTY BLOB NULL,
 BODY BLOB NULL,
 LOCATION NVARCHAR2(255) NULL,
 LOCATIONSUBTYPE NVARCHAR2(255) NULL,
 VALIDATESTATUS NUMBER(3,0) NULL,
 DEPLOYSTATUS NUMBER(3,0) NULL 
) 

/

create sequence seq_CALCMGRFOLDERS start with 1 increment by 1 order

/

alter table CALCMGRFOLDERS add constraint pkCALCMGRFOLDERS1 primary key(ID)

/

alter table CALCMGRFOLDERS add constraint ukCALCMGRFOLDERS1 unique(NAME,LOCATION,LOCATIONSUBTYPE)

/

CREATE TABLE CALCMGRUSERSETTINGS 
( 
 USERID NVARCHAR2(256) NULL,
 NAME NVARCHAR2(50) NULL,
 SETTINGS BLOB NULL 
) 

/

alter table CALCMGRUSERSETTINGS add constraint ukCALCMGRUSERSETTINGS1 unique(USERID,NAME)

/

CREATE TABLE CALCMGRTEMPLATES 
( 
 ID NUMBER(10,0) NOT NULL,
 NAME NVARCHAR2(512) NOT NULL,
 UPPERNAME NVARCHAR2(512) NOT NULL,
 DESCRIPTION NVARCHAR2(255) NULL,
 OWNER NVARCHAR2(255) NULL,
 CREATED timestamp DEFAULT systimestamp NOT NULL,
 MODIFIEDBY NVARCHAR2(255) NULL,
 LASTMODIFIED timestamp NULL,
 LOCKEDBY NVARCHAR2(255) NULL,
 OPENFOREDITINGBY NVARCHAR2(255) NULL,
 ISOPENFOREDITING NUMBER(3,0) NULL,
 OBJECTTYPEID NUMBER(10,0) NOT NULL,
 PRODUCTTYPE NUMBER(10,0) NOT NULL,
 PROPERTY BLOB NULL,
 BODY BLOB NULL,
 LOCATION NVARCHAR2(255) NULL,
 LOCATIONSUBTYPE NVARCHAR2(255) NULL,
 VALIDATESTATUS NUMBER(3,0) NULL,
 DEPLOYSTATUS NUMBER(3,0) NULL 
) 

/

create sequence seq_CALCMGRTEMPLATES start with 1 increment by 1 order

/

alter table CALCMGRTEMPLATES add constraint pkCALCMGRTEMPLATES1 primary key(ID)

/

alter table CALCMGRTEMPLATES add constraint ukCALCMGRTEMPLATES1 unique(NAME,LOCATION,LOCATIONSUBTYPE)

/

CREATE TABLE CALCMGRDEPLOYDETAILS 
( 
 OBJECTID NUMBER(10,0) NOT NULL,
 OBJECTTYPE NUMBER(10,0) NOT NULL,
 APPLICATION NVARCHAR2(30) NULL,
 APPLICATIONID NUMBER(10,0) NOT NULL,
 APPLICATIONTYPE NVARCHAR2(30) NULL,
 DEPLOYTIME timestamp DEFAULT systimestamp NULL 
) 

/

CREATE INDEX idxCALCMGRDEPLOYDETAILS1 ON CALCMGRDEPLOYDETAILS ( OBJECTID , OBJECTTYPE  )

/

CREATE INDEX idxCALCMGRDEPLOYDETAILS2 ON CALCMGRDEPLOYDETAILS ( APPLICATION  )

/

CREATE INDEX idxCALCMGRDEPLOYDETAILS3 ON CALCMGRDEPLOYDETAILS ( APPLICATIONID  )

/

alter table CALCMGRDEPLOYDETAILS add constraint ukCALCMGRDEPLOYDETAILS1 unique(OBJECTID,OBJECTTYPE,APPLICATIONID,APPLICATION,APPLICATIONTYPE)

/

CREATE TABLE CALCMGRDEPLOYVIEW 
( 
 PRODUCTTYPE NUMBER(10,0) NOT NULL,
 APPLICATIONNAME NVARCHAR2(50) NOT NULL,
 APPLICATIONID NUMBER(10,0) NULL,
 PLANTYPE NVARCHAR2(50) NULL,
 CALCTYPE NVARCHAR2(50) NULL,
 OBJECTID NUMBER(10,0) NOT NULL,
 OBJECTTYPE NUMBER(10,0) NOT NULL,
 NAME NVARCHAR2(50) NOT NULL,
 DEPLOYTIME timestamp NULL,
 BODY BLOB NULL 
) 

/

CREATE INDEX idxCALCMGRDEPLOYVIEW1 ON CALCMGRDEPLOYVIEW ( OBJECTID , OBJECTTYPE  )

/

CREATE INDEX idxCALCMGRDEPLOYVIEW2 ON CALCMGRDEPLOYVIEW ( PRODUCTTYPE , APPLICATIONNAME , PLANTYPE  )

/

alter table CALCMGRDEPLOYVIEW add constraint ukCALCMGRDEPLOYVIEW1 unique(PRODUCTTYPE,APPLICATIONNAME,APPLICATIONID,PLANTYPE,OBJECTID,OBJECTTYPE)

/

CREATE TABLE CALCMGRDEPLOYEDVIEW 
( 
 PRODUCTTYPE NUMBER(10,0) NOT NULL,
 APPLICATIONNAME NVARCHAR2(50) NOT NULL,
 APPLICATIONID NUMBER(10,0) NULL,
 PLANTYPE NVARCHAR2(50) NULL,
 CALCTYPE NVARCHAR2(50) NULL,
 OBJECTID NUMBER(10,0) NOT NULL,
 OBJECTTYPE NUMBER(10,0) NOT NULL,
 NAME NVARCHAR2(50) NOT NULL,
 DEPLOYTIME timestamp NULL,
 BODY BLOB NULL 
) 

/

CREATE INDEX idxCALCMGRDEPLOYEDVIEW1 ON CALCMGRDEPLOYEDVIEW ( OBJECTID , OBJECTTYPE  )

/

CREATE INDEX idxCALCMGRDEPLOYEDVIEW2 ON CALCMGRDEPLOYEDVIEW ( PRODUCTTYPE , APPLICATIONNAME , PLANTYPE  )

/

alter table CALCMGRDEPLOYEDVIEW add constraint ukCALCMGRDEPLOYEDVIEW1 unique(PRODUCTTYPE,APPLICATIONNAME,APPLICATIONID,PLANTYPE,OBJECTID,OBJECTTYPE)

/

CREATE TABLE CALCMGROBJECTACCESS 
( 
 PRODUCTTYPE NUMBER(10,0) NOT NULL,
 APPLICATION NVARCHAR2(255) NOT NULL,
 PLANTYPE NVARCHAR2(50) NULL,
 OBJECTID NVARCHAR2(50) NOT NULL,
 OBJECTTYPE NUMBER(10,0) NOT NULL,
 ACCESSTYPE NUMBER(10,0) NOT NULL,
 USERID NUMBER(10,0) NOT NULL,
 USERACCESS NUMBER(10,0) NOT NULL 
) 

/

CREATE INDEX idxCALCMGROBJECTACCESS1 ON CALCMGROBJECTACCESS ( OBJECTID , OBJECTTYPE  )

/

CREATE INDEX idxCALCMGROBJECTACCESS2 ON CALCMGROBJECTACCESS ( USERID  )

/

alter table CALCMGROBJECTACCESS add constraint ukCALCMGROBJECTACCESS1 unique(APPLICATION,PLANTYPE,OBJECTID,OBJECTTYPE,ACCESSTYPE,USERID)

/

CREATE TABLE CALCMGRUSERS 
( 
 ID NUMBER(10,0) NOT NULL,
 NAME NVARCHAR2(128) NOT NULL,
 UIDENTITY NVARCHAR2(256) NOT NULL,
 TYPE NUMBER(10,0) NOT NULL 
) 

/

CREATE INDEX idxCALCMGRUSERS1 ON CALCMGRUSERS ( UIDENTITY  )

/

alter table CALCMGRUSERS add constraint pkCALCMGRUSERS1 primary key(ID)

/

CREATE TABLE CALCMGRSHORTCUTS 
( 
 PRODUCT NUMBER(10,0) NOT NULL,
 APPLICATIONNAME NVARCHAR2(50) NOT NULL,
 APPLICATIONID NUMBER(10,0) NULL,
 PLANTYPE NVARCHAR2(50) NULL,
 OBJECTID NUMBER(10,0) NOT NULL,
 OBJECTTYPE NUMBER(10,0) NOT NULL,
 NAME NVARCHAR2(50) NOT NULL,
 VALIDATESTATUS NUMBER(3,0) NULL,
 DEPLOYSTATUS NUMBER(3,0) NULL 
) 

/

CREATE INDEX idxCALCMGRSHORTCUTS1 ON CALCMGRSHORTCUTS ( OBJECTID , OBJECTTYPE  )

/

CREATE TABLE CALCMGRFUNCTIONS 
( 
 APPLICATIONNAME NVARCHAR2(50) NOT NULL,
 PLANTYPE NVARCHAR2(50) NULL,
 BODY BLOB NULL 
) 

/

alter table CALCMGRFUNCTIONS add constraint ukCALCMGRFUNCTIONS1 unique(APPLICATIONNAME,PLANTYPE)

/

CREATE TABLE "ANNOT_CONTEXTS"  (
		  "SET_ID"                  NUMBER(11,0)        NOT NULL,
		  "ELEMENT_VALUE_ID_LIST"     VARCHAR2(512)   NOT NULL,
		  "ANNOTATION_ID"           VARCHAR2(512)    NOT NULL,
        CONSTRAINT "PK_ANNOTATIONCONTEXT" PRIMARY KEY ("SET_ID", "ELEMENT_VALUE_ID_LIST", "ANNOTATION_ID")
)

/

CREATE TABLE "ANNOT_ELEMENTS"  (
		  "ELEMENT_ID"              NUMBER(11,0)        NOT NULL,
		  "ELEMENT_NAME"            VARCHAR2(256)   NOT NULL,
		  "SOURCE"                 VARCHAR2(256)   NOT NULL,
         CONSTRAINT "PK_CONTEXTELEMENT" PRIMARY KEY ("ELEMENT_ID", "ELEMENT_NAME", "SOURCE")
)

/

CREATE TABLE "ANNOT_ELEMENT_GROUPS"  (
		  "SET_ID"                  NUMBER(11,0)        NOT NULL,
		  "ELEMENT_ID"              NUMBER(11,0)        NOT NULL,
		  "ORDINAL"                 NUMBER(11,0)        NOT NULL,
         CONSTRAINT "PK_CONTEXTELEMENTGROUP" PRIMARY KEY ("SET_ID", "ELEMENT_ID", "ORDINAL")
)

/

CREATE TABLE "ANNOT_ELEMENT_GROUP1"  (
		  "SET_ID"                    NUMBER(11,0)        NOT NULL,
		  "ELEMENT_VALUE_ID1"         NUMBER(11,0)        NOT NULL,
		  "ELEMENT_VALUE_ID_LIST"     VARCHAR2(512)   NOT NULL,
         CONSTRAINT "PK_CONTEXTELEMENTGROUP1" PRIMARY KEY ("SET_ID", "ELEMENT_VALUE_ID1", "ELEMENT_VALUE_ID_LIST")
)

/

CREATE TABLE "ANNOT_ELEMENT_GROUP2"  (
		  "SET_ID"                    NUMBER(11,0)        NOT NULL,
		  "ELEMENT_VALUE_ID1"         NUMBER(11,0)        NOT NULL,
		  "ELEMENT_VALUE_ID2"         NUMBER(11,0)        NOT NULL,
		  "ELEMENT_VALUE_ID_LIST"     VARCHAR2(512)   NOT NULL,
         CONSTRAINT "PK_CONTEXTELEMENTGROUP2" PRIMARY KEY ("SET_ID", "ELEMENT_VALUE_ID1", "ELEMENT_VALUE_ID2", "ELEMENT_VALUE_ID_LIST")
)

/

CREATE TABLE "ANNOT_ELEMENT_GROUP3"  (
		  "SET_ID"                    NUMBER(11,0)        NOT NULL,
		  "ELEMENT_VALUE_ID1"         NUMBER(11,0)        NOT NULL,
		  "ELEMENT_VALUE_ID2"         NUMBER(11,0)        NOT NULL,
		  "ELEMENT_VALUE_ID3"         NUMBER(11,0)        NOT NULL,
		  "ELEMENT_VALUE_ID_LIST"     VARCHAR2(512)   NOT NULL,
         CONSTRAINT "PK_CONTEXTELEMENTGROUP3" PRIMARY KEY ("SET_ID", "ELEMENT_VALUE_ID1", "ELEMENT_VALUE_ID2", "ELEMENT_VALUE_ID3", "ELEMENT_VALUE_ID_LIST")
)

/

CREATE TABLE "ANNOT_ELEMENT_SETS"  (
		  "SET_ID"                  NUMBER(11,0)        NOT NULL,
		  "ORDINAL"                NUMBER(11,0)        NOT NULL,
		  "ELEMENT_ID"              NUMBER(11,0)        NOT NULL,
        CONSTRAINT "PK_CONTEXTELEMENTSET" PRIMARY KEY 	("SET_ID", "ORDINAL", "ELEMENT_ID")
)

/

CREATE TABLE "ANNOT_ELEMENT_VALUES"  (
		  "ELEMENT_ID"              NUMBER(11,0)        NOT NULL,
		  "SET_ID"                  NUMBER(11,0)        NOT NULL,
		  "ELEMENT_VALUE_ID"         NUMBER(11,0)        NOT NULL,
		  "ELEMENT_VALUE"           VARCHAR2(256)   NOT NULL,
        CONSTRAINT "PK_CONTEXTELEMENTVALUE" PRIMARY KEY ("ELEMENT_ID", "SET_ID", "ELEMENT_VALUE_ID", "ELEMENT_VALUE")
)

/

CREATE INDEX "AC_ELEMENTVALUEIDLIST" ON "ANNOT_CONTEXTS" ("ELEMENT_VALUE_ID_LIST")

/

CREATE INDEX "AEV_ELEMENTVALUE" ON "ANNOT_ELEMENT_VALUES" ("ELEMENT_VALUE")

/

CREATE TABLE "FR_SCHEDULER_DATA"  (
    "JOB_ID" VARCHAR2(128)   NOT NULL,
    "STATE"  NUMBER(11,0)    NOT NULL,
    "XML"    BLOB    NOT NULL,
    "START_TIME"    DATE,
	"END_TIME"  DATE,
	"LAST_UPDATED" DATE,
    CONSTRAINT "PK_FR_SCHEDULER_DATA" PRIMARY KEY ("JOB_ID")
)

/

CREATE TABLE WKS_IDENTITY (ID NUMBER(10) NOT NULL, TYPE VARCHAR2(1) NOT NULL, MODIFIED VARCHAR2(255) NOT NULL, PRIMARY KEY (ID))

/

CREATE TABLE WKS_IDENTITY_XREF (SOURCE_ID NUMBER(10) NOT NULL, TARGET_ID NUMBER(10) NOT NULL, PRIMARY KEY (SOURCE_ID, TARGET_ID))

/

CREATE TABLE WKS_VERSION (ID NUMBER(10) NOT NULL, INFO VARCHAR2(255) NOT NULL, PRIMARY KEY (ID))

/

CREATE TABLE WKS_SUBJECT (ID NUMBER(10) NOT NULL, NAME VARCHAR2(255) NOT NULL, PRIMARY KEY (ID))

/

CREATE TABLE WKS_USER (ID NUMBER(10) NOT NULL, PRIMARY KEY (ID))

/

CREATE TABLE WKS_GROUP (ID NUMBER(10) NOT NULL, PRIMARY KEY (ID))

/

CREATE TABLE WKS_ROLE (ID NUMBER(10) NOT NULL, PRIMARY KEY (ID))

/

CREATE TABLE WKS_PROPERTY (ID NUMBER(10) NOT NULL, NAME VARCHAR2(255) NOT NULL, VAL CLOB NOT NULL, ORD NUMBER(10) NOT NULL, PRIMARY KEY (ID))

/

ALTER TABLE WKS_IDENTITY_XREF ADD CONSTRAINT FK_WKS_IDENTITY_XREF_SOURCE_ID FOREIGN KEY (SOURCE_ID) REFERENCES WKS_IDENTITY (ID)

/

ALTER TABLE WKS_IDENTITY_XREF ADD CONSTRAINT FK_WKS_IDENTITY_XREF_TARGET_ID FOREIGN KEY (TARGET_ID) REFERENCES WKS_IDENTITY (ID)

/

ALTER TABLE WKS_VERSION ADD CONSTRAINT FK_WKS_VERSION_ID FOREIGN KEY (ID) REFERENCES WKS_IDENTITY (ID)

/

ALTER TABLE WKS_SUBJECT ADD CONSTRAINT FK_WKS_SUBJECT_ID FOREIGN KEY (ID) REFERENCES WKS_IDENTITY (ID)

/

ALTER TABLE WKS_USER ADD CONSTRAINT FK_WKS_USER_ID FOREIGN KEY (ID) REFERENCES WKS_IDENTITY (ID)

/

ALTER TABLE WKS_GROUP ADD CONSTRAINT FK_WKS_GROUP_ID FOREIGN KEY (ID) REFERENCES WKS_IDENTITY (ID)

/

ALTER TABLE WKS_ROLE ADD CONSTRAINT FK_WKS_ROLE_ID FOREIGN KEY (ID) REFERENCES WKS_IDENTITY (ID)

/

ALTER TABLE WKS_PROPERTY ADD CONSTRAINT FK_WKS_PROPERTY_ID FOREIGN KEY (ID) REFERENCES WKS_IDENTITY (ID)

/

CREATE SEQUENCE WKS_IDENTITY_SEQ START WITH 1

/

COMMENT ON TABLE WKS_IDENTITY IS 'Stores an identity'

/

COMMENT ON COLUMN WKS_IDENTITY.ID IS 'An identifier which is unique across all tables'

/

COMMENT ON COLUMN WKS_IDENTITY.TYPE IS 'The identity type is a (V)ersion, (P)roperty, (S)ubject, (U)ser, (G)roup, (R)ole'

/

COMMENT ON COLUMN WKS_IDENTITY.MODIFIED IS 'The information detailing by whom and when modified the identity last'

/

COMMENT ON TABLE WKS_IDENTITY_XREF IS 'Stores the relationship between two identities'

/

COMMENT ON COLUMN WKS_IDENTITY_XREF.SOURCE_ID IS 'The source identity identifier which is unique across all tables'

/

COMMENT ON COLUMN WKS_IDENTITY_XREF.TARGET_ID IS 'The target identity identifier which is unique across all tables'

/

COMMENT ON TABLE WKS_VERSION IS 'Stores version information for maintenance and upgrades'

/

COMMENT ON COLUMN WKS_VERSION.ID IS 'An identifier which is unique across all tables'

/

COMMENT ON COLUMN WKS_VERSION.INFO IS 'The version information'

/

COMMENT ON TABLE WKS_SUBJECT IS 'Stores a subject in the CSS system'

/

COMMENT ON COLUMN WKS_SUBJECT.ID IS 'An identifier which is unique across all tables'

/

COMMENT ON COLUMN WKS_SUBJECT.NAME IS 'The subject name which is a CSS identity'

/

COMMENT ON TABLE WKS_USER IS 'Stores a user in the CSS system'

/

COMMENT ON COLUMN WKS_USER.ID IS 'An identifier which is unique across all tables'

/

COMMENT ON TABLE WKS_GROUP IS 'Stores a group in the CSS system'

/

COMMENT ON COLUMN WKS_GROUP.ID IS 'An identifier which is unique across all tables'

/

COMMENT ON TABLE WKS_ROLE IS 'Stores a role in the CSS system'

/

COMMENT ON COLUMN WKS_ROLE.ID IS 'An identifier which is unique across all tables'

/

COMMENT ON TABLE WKS_PROPERTY IS 'Stores a property for a subject in the CSS system'

/

COMMENT ON COLUMN WKS_PROPERTY.ID IS 'An identifier which is unique across all tables'

/

COMMENT ON COLUMN WKS_PROPERTY.NAME IS 'The property name'

/

COMMENT ON COLUMN WKS_PROPERTY.VAL IS 'The property value'

/

COMMENT ON COLUMN WKS_PROPERTY.ORD IS 'The property order is -1 for single-valued, otherwise 0-based for multi-valued'

/

ALTER SESSION SET CURRENT_SCHEMA=TESTONE_BIPLATFORM
/

CREATE SEQUENCE S_NQ_DSS_PROVIDER_SEQ
	START WITH 100
/

CREATE TABLE S_NQ_DSS_PROVIDER_INSTANCES
(
	PROVIDER_ID						NUMBER PRIMARY KEY,
	STRIPE_ID						NUMBER, -- NULLABLE
	INSTANCE_NAME					VARCHAR2(20) NOT NULL UNIQUE,
	RESOURCE_NAME					VARCHAR2(20) NOT NULL,
	PROVIDER_TYPE					VARCHAR2(20) NOT NULL,
	CONFIGURATION_VALUE_1			VARCHAR2(200)
)
/

INSERT INTO S_NQ_DSS_PROVIDER_INSTANCES ( PROVIDER_ID, INSTANCE_NAME, RESOURCE_NAME, PROVIDER_TYPE ) VALUES ( 1, '<noprovider>', 'managed', 'none' )
/

INSERT INTO S_NQ_DSS_PROVIDER_INSTANCES ( PROVIDER_ID, INSTANCE_NAME, RESOURCE_NAME, PROVIDER_TYPE ) VALUES ( 2, 'dbstore1', 'managed', 'db' )
/

INSERT INTO S_NQ_DSS_PROVIDER_INSTANCES ( PROVIDER_ID, INSTANCE_NAME, RESOURCE_NAME, PROVIDER_TYPE, CONFIGURATION_VALUE_1 ) VALUES ( 3, 'defaultstore', 'managed', 'file',NULL)
/

CREATE SEQUENCE S_NQ_DSS_SERVICE_STRIPE_SEQ
	START WITH 100
/

CREATE TABLE S_NQ_DSS_SERVICE_STRIPES
(
	STRIPE_ID						NUMBER NOT NULL PRIMARY KEY,
	STRIPE_NAME						VARCHAR2(256) NOT NULL UNIQUE,
	GUID_PREFIX						VARCHAR2(11) NOT NULL,
	PROVISIONING_VERSION			VARCHAR2(50),
	PROVISIONED_DATE				TIMESTAMP,
	MANAGED_PROVIDER_ID				NUMBER REFERENCES S_NQ_DSS_PROVIDER_INSTANCES(PROVIDER_ID),
	QUOTA_KILOBYTE_LIMIT			NUMBER NOT NULL,
	FILE_KILOBYTE_LIMIT				NUMBER NOT NULL,
	USER_QUOTA_KILOBYTE_LIMIT		NUMBER NOT NULL,
	USED_QUOTA_KILOBYTES			NUMBER DEFAULT 0 NOT NULL 
)
/

CREATE SEQUENCE S_NQ_DSS_IDENTITY_SEQ
	START WITH 100
/

CREATE TABLE S_NQ_DSS_IDENTITIES
(
	IDENTITY_ID						NUMBER NOT NULL PRIMARY KEY,
	STRIPE_ID						NUMBER NOT NULL REFERENCES S_NQ_DSS_SERVICE_STRIPES(STRIPE_ID),
	TYPE							CHAR CHECK (TYPE IN ('r','g','s','u')), -- 'r' == ROLE, 'g' GROUP, 's' SPECIAL 'u' USER
	ROLE_OR_GUID					VARCHAR2(256) NOT NULL, 
	LAST_KNOWN_NAME					VARCHAR2(256), -- FOR LCM PURPOSES ONLY
	QUOTA_KILOBYTE_LIMIT			NUMBER,
	FILE_KILOBYTE_LIMIT				NUMBER,
	CREATED_DATE					TIMESTAMP,
	USED_QUOTA_KILOBYTES			NUMBER DEFAULT 0 NOT NULL 
)
/

ALTER TABLE S_NQ_DSS_IDENTITIES ADD CONSTRAINT S_NQ_DSS_UNIQ_IDENTITIES UNIQUE (STRIPE_ID,ROLE_OR_GUID)
/

CREATE SEQUENCE S_NQ_DSS_ACL_SEQ
	START WITH 100
/

CREATE TABLE S_NQ_DSS_ACLS
(
	ACL_ID							NUMBER NOT NULL PRIMARY KEY,
	STRIPE_ID						NUMBER NOT NULL REFERENCES S_NQ_DSS_SERVICE_STRIPES(STRIPE_ID),
	ACL_NAME						VARCHAR2(50),
	ACL_OWNER_ID					NUMBER NOT NULL REFERENCES S_NQ_DSS_IDENTITIES(IDENTITY_ID), -- SET TO NOOWNER ID WHEN NAME IS NULL
	LAST_MODIFIED					TIMESTAMP
)
/

CREATE INDEX S_NQ_DSS_ACLS_IDX ON S_NQ_DSS_ACLS ( ACL_ID, STRIPE_ID, ACL_NAME )
/

CREATE TABLE S_NQ_DSS_ACL_ENTRIES
(
	ACL_ID							NUMBER NOT NULL REFERENCES S_NQ_DSS_ACLS(ACL_ID),
	STRIPE_ID						NUMBER NOT NULL REFERENCES S_NQ_DSS_SERVICE_STRIPES(STRIPE_ID),
	IDENTITY_ID						NUMBER NOT NULL REFERENCES S_NQ_DSS_IDENTITIES(IDENTITY_ID),
	LIST_PERM						CHAR, -- 'Y' OR NULL
	READ_PERM						CHAR, -- 'Y' OR NULL
	WRITE_PERM						CHAR,
	EXECUTE_PERM					CHAR,
	DELETE_PERM						CHAR,
	CHANGEPERMISSIONS_PERM			CHAR
)
/

ALTER TABLE S_NQ_DSS_ACL_ENTRIES ADD CONSTRAINT PK_S_NQ_DSS_ACL_ENTRIES PRIMARY KEY (ACL_ID, IDENTITY_ID)
/

CREATE TABLE S_NQ_DSS_FILETYPES
(
	FILETYPE_ID						NUMBER NOT NULL PRIMARY KEY,
	FILETYPE_NAME					VARCHAR2(50) NOT NULL
)
/

INSERT INTO S_NQ_DSS_FILETYPES(FILETYPE_ID,FILETYPE_NAME) VALUES (1,'excel')
/

INSERT INTO S_NQ_DSS_FILETYPES(FILETYPE_ID,FILETYPE_NAME) VALUES (2,'text')
/

CREATE TABLE S_NQ_DSS_SERVICE_INFO
(
	NAME							VARCHAR2(50) NOT NULL PRIMARY KEY,
	VALUE							VARCHAR2(100)
)
/

INSERT INTO S_NQ_DSS_SERVICE_INFO (NAME,VALUE) VALUES ('data','0.4')
/

INSERT INTO S_NQ_DSS_SERVICE_INFO (NAME,VALUE) VALUES ('metadata','0.4')
/

CREATE SEQUENCE S_NQ_DSS_DATASET_SEQ
	START WITH 100
/

CREATE TABLE S_NQ_DSS_DATASETS
(
	DATASET_ID						NUMBER NOT NULL PRIMARY KEY,
	STRIPE_ID						NUMBER NOT NULL REFERENCES S_NQ_DSS_SERVICE_STRIPES(STRIPE_ID),
	DATASET_NAME					VARCHAR2(256) NOT NULL,
	FILESTORE_ID					VARCHAR2(128) NOT NULL,
	ACL_ID							NUMBER REFERENCES S_NQ_DSS_ACLS(ACL_ID),
	FILETYPE_ID						NUMBER NOT NULL REFERENCES S_NQ_DSS_FILETYPES(FILETYPE_ID),
	MIMETYPE						VARCHAR2(25),
	OWNER_ID						NUMBER NOT NULL REFERENCES S_NQ_DSS_IDENTITIES(IDENTITY_ID),
	CREATEDBY_ID					NUMBER REFERENCES S_NQ_DSS_IDENTITIES(IDENTITY_ID),
	PROVIDER_ID						NUMBER REFERENCES S_NQ_DSS_PROVIDER_INSTANCES(PROVIDER_ID) NOT NULL,
	TYPE_OPTIONS_XML				CLOB,
	PROVIDER_OPTIONS_XML			CLOB,
	FILETYPE_KNOBS					CLOB,
	FILE_LENGTH						NUMBER,
	STORAGE_FILE_LENGTH				NUMBER, -- FOR COMPRESSION
	LAST_MODIFIED					TIMESTAMP,
	CREATED_DATE					TIMESTAMP,
	BISERVERMETADATA_LAST_MODIFIED	TIMESTAMP,
	RAWFILE_LAST_MODIFIED			TIMESTAMP,
	IS_EMBRYONIC					CHAR CHECK (IS_EMBRYONIC IN ('y','n')),
	IS_USER_STRIPED					CHAR CHECK (IS_USER_STRIPED IN ('y','n')),
	INTERNAL_ID						VARCHAR2(256) NOT NULL,
	NAMESPACE						VARCHAR2(128) NOT NULL
)
/

ALTER TABLE S_NQ_DSS_DATASETS ADD CONSTRAINT S_NQ_DSS_UNIQ_DATASETS UNIQUE (STRIPE_ID, DATASET_NAME,NAMESPACE)
/

CREATE INDEX S_NQ_DSS_DATASETS_INDEX ON S_NQ_DSS_DATASETS ( ACL_ID )
/

CREATE INDEX S_NQ_DSS_DATASETS_INDEX2 ON S_NQ_DSS_DATASETS ( STRIPE_ID, DATASET_NAME, OWNER_ID )
/

CREATE OR REPLACE TRIGGER S_NQ_DSS_DATASETS_TRG
	AFTER DELETE OR INSERT OR UPDATE ON S_NQ_DSS_DATASETS
	FOR EACH ROW
BEGIN
	-- UPDATE or DELETE
	IF (:old.owner_id IS NOT NULL)
	THEN
		UPDATE		s_nq_dss_identities 
		SET			used_quota_kilobytes = used_quota_kilobytes - :old.file_length / 1024
		WHERE		identity_id = :old.owner_id;
		
		UPDATE		s_nq_dss_service_stripes 
		SET			used_quota_kilobytes = used_quota_kilobytes - :old.file_length / 1024
		WHERE		stripe_id = :old.stripe_id;
	END IF;

	-- UPDATE or INSERT
	IF (:new.owner_id IS NOT NULL)
	THEN
		UPDATE		s_nq_dss_identities 
		SET			used_quota_kilobytes = used_quota_kilobytes + :new.file_length / 1024
		WHERE		identity_id = :new.owner_id;
		
		UPDATE		s_nq_dss_service_stripes 
		SET			used_quota_kilobytes = used_quota_kilobytes + :new.file_length / 1024
		WHERE		stripe_id = :new.stripe_id;
	END IF;
END;

/

CREATE TABLE S_NQ_DSS_DATASET_DATASTRIPES
(
	DATASET_ID						NUMBER REFERENCES S_NQ_DSS_DATASETS(DATASET_ID),
	STRIPE_ID						NUMBER NOT NULL REFERENCES S_NQ_DSS_SERVICE_STRIPES(STRIPE_ID),
	USERS_ID						NUMBER REFERENCES S_NQ_DSS_IDENTITIES(IDENTITY_ID), -- NULLABLE
	FILE_ID							VARCHAR2(36) NOT NULL,
	FILE_LENGTH						NUMBER,
	LAST_MODIFIED					TIMESTAMP
)
/

CREATE INDEX S_NQ_DSS_DATASET_DATASTR_INDEX ON S_NQ_DSS_DATASET_DATASTRIPES ( DATASET_ID )
/

CREATE TABLE S_NQ_DSS_DATASET_ALIASES
(
	DATASET_ID						NUMBER NOT NULL REFERENCES S_NQ_DSS_DATASETS(DATASET_ID),
	STRIPE_ID						NUMBER NOT NULL REFERENCES S_NQ_DSS_SERVICE_STRIPES(STRIPE_ID),
	LOCALE							VARCHAR2(5) NOT NULL,
	ALIAS							VARCHAR2(256) NOT NULL,
	NAMESPACE						VARCHAR2(128) NOT NULL
)
/

ALTER TABLE S_NQ_DSS_DATASET_ALIASES ADD CONSTRAINT PK_S_NQ_DSS_DATASET_ALIASES PRIMARY KEY (STRIPE_ID, DATASET_ID, LOCALE)
/

ALTER TABLE S_NQ_DSS_DATASET_ALIASES ADD CONSTRAINT S_NQ_DSS_UNIQ_ALIASES UNIQUE (STRIPE_ID, NAMESPACE, ALIAS, LOCALE)
/

CREATE INDEX S_NQ_DSS_DATASET_ALIASES_INDEX ON S_NQ_DSS_DATASET_ALIASES (DATASET_ID)
/

CREATE TABLE S_NQ_DSS_DATASET_CUSTOM
(
	DATASET_ID						NUMBER NOT NULL REFERENCES S_NQ_DSS_DATASETS(DATASET_ID),
	STRIPE_ID						NUMBER NOT NULL REFERENCES S_NQ_DSS_SERVICE_STRIPES(STRIPE_ID),
	NAME							VARCHAR2(20),
	VALUE							VARCHAR2(100)
)
/

CREATE INDEX S_NQ_DSS_DATASET_CUSTOM_INDEX ON S_NQ_DSS_DATASET_CUSTOM ( DATASET_ID )
/

CREATE TABLE S_NQ_DSS_DATASET_DESCRIPTIONS
(
	DATASET_ID						NUMBER NOT NULL REFERENCES S_NQ_DSS_DATASETS(DATASET_ID),
	STRIPE_ID						NUMBER NOT NULL REFERENCES S_NQ_DSS_SERVICE_STRIPES(STRIPE_ID),
	LOCALE							VARCHAR2(5) NOT NULL,
	DESCRIPTION						VARCHAR2(500)
)
/

ALTER TABLE S_NQ_DSS_DATASET_DESCRIPTIONS ADD CONSTRAINT PK_S_NQ_DSS_DATASET_DESC PRIMARY KEY (STRIPE_ID, DATASET_ID, LOCALE)
/

CREATE INDEX S_NQ_DSS_DATASET_DESC_INDEX ON S_NQ_DSS_DATASET_DESCRIPTIONS ( DATASET_ID )
/

CREATE TABLE S_NQ_DSS_DATASET_ATTRTYPES
(
	ATTRTYPE_ID						NUMBER NOT NULL PRIMARY KEY,
	ATTRTYPE_NAME					VARCHAR2(30) NOT NULL UNIQUE
)
/

INSERT INTO S_NQ_DSS_DATASET_ATTRTYPES(ATTRTYPE_ID, ATTRTYPE_NAME) VALUES (1, 'BUSINESSMODEL')
/

CREATE TABLE S_NQ_DSS_DATASET_ATTRS
(
	DATASET_ID						NUMBER NOT NULL REFERENCES S_NQ_DSS_DATASETS(DATASET_ID),
	STRIPE_ID						NUMBER NOT NULL REFERENCES S_NQ_DSS_SERVICE_STRIPES(STRIPE_ID),
	ATTRTYPE_ID						NUMBER NOT NULL REFERENCES S_NQ_DSS_DATASET_ATTRTYPES(ATTRTYPE_ID),
	VALUE							VARCHAR2(100)
)
/

ALTER TABLE S_NQ_DSS_DATASET_ATTRS ADD CONSTRAINT PK_S_NQ_DSS_DATASET_ATTRS PRIMARY KEY (STRIPE_ID, DATASET_ID, ATTRTYPE_ID)
/

CREATE INDEX S_NQ_DSS_DATASET_ATTRS_INDEX ON S_NQ_DSS_DATASET_ATTRS ( DATASET_ID )
/

CREATE SEQUENCE S_NQ_DSS_DATASET_TAGS_SEQ
	START WITH 100
/

CREATE TABLE S_NQ_DSS_DATASET_TAGS
(
	TAG_ID							NUMBER NOT NULL PRIMARY KEY,
	STRIPE_ID						NUMBER NOT NULL REFERENCES S_NQ_DSS_SERVICE_STRIPES(STRIPE_ID),
	TAG_NAME						VARCHAR2(32),
	TAG_OWNER_ID					NUMBER REFERENCES S_NQ_DSS_IDENTITIES(IDENTITY_ID)	 -- NULLABLE
)
/

CREATE TABLE S_NQ_DSS_DATASET_TAG_MAPPINGS
(
	TAG_ID							NUMBER NOT NULL REFERENCES S_NQ_DSS_DATASET_TAGS(TAG_ID),
	DATASET_ID						NUMBER NOT NULL REFERENCES S_NQ_DSS_DATASETS(DATASET_ID)
)
/

CREATE INDEX S_NQ_DSS_DATASET_TAG_MAP_INDEX ON S_NQ_DSS_DATASET_TAG_MAPPINGS ( DATASET_ID )
/

CREATE SEQUENCE S_NQ_DSS_ENTITY_SEQ
	START WITH 100
/

CREATE TABLE S_NQ_DSS_ENTITIES
(
	ENTITY_ID 						NUMBER PRIMARY KEY,
	STRIPE_ID 						NUMBER NOT NULL REFERENCES S_NQ_DSS_SERVICE_STRIPES(STRIPE_ID),
	ENTITY_NAME 					VARCHAR2(256) NOT NULL,
	ENTITY_SUFFIX 					NUMBER NOT NULL,
	NAMESPACE						VARCHAR2(128) NOT NULL,
	INTERNAL_ID						VARCHAR2(256) NOT NULL,
	OWNER_ID 						NUMBER NOT NULL REFERENCES S_NQ_DSS_IDENTITIES(IDENTITY_ID),
	CREATEDBY_ID 					NUMBER NOT NULL REFERENCES S_NQ_DSS_IDENTITIES(IDENTITY_ID),
	LAST_MODIFIED 					TIMESTAMP,
	CREATED_DATE 					TIMESTAMP
)
/

ALTER TABLE S_NQ_DSS_ENTITIES ADD CONSTRAINT S_NQ_DSS_UNIQ_ENTITIES UNIQUE (STRIPE_ID, ENTITY_NAME, ENTITY_SUFFIX)
/

CREATE SEQUENCE S_NQ_DSS_AUDIT_SEQ
 START WITH 100
/

CREATE TABLE S_NQ_DSS_AUDIT 
(
	EV_ID							NUMBER NOT NULL PRIMARY KEY,
	EV_DATE							TIMESTAMP NOT NULL,
	EV_TYPE							NVARCHAR2(20) NOT NULL,
	STRIPE_NAME						NVARCHAR2(200),
	DATASET_NAME					VARCHAR2(256),
	ALIAS							NVARCHAR2(256),
	IDENTITY_ID						NUMBER,
	IDENTITY_NAME					NVARCHAR2(256),
	EV_SIZE							NUMBER,
	NAMESPACE						VARCHAR2(128) NOT NULL,
	INTERNAL_ID						VARCHAR2(256) NOT NULL 
)
/

CREATE INDEX S_NQ_DSS_AUDIT_IDX_DT ON S_NQ_DSS_AUDIT (EV_DATE)
/

CREATE INDEX S_NQ_DSS_AUDIT_IDX_SID ON S_NQ_DSS_AUDIT (STRIPE_NAME)
/

CREATE INDEX S_NQ_DSS_AUDIT_IDX_DID ON S_NQ_DSS_AUDIT (DATASET_NAME)
/

CREATE INDEX S_NQ_DSS_AUDIT_IDX_UID ON S_NQ_DSS_AUDIT (IDENTITY_ID, IDENTITY_NAME)
/

CREATE SEQUENCE S_NQ_DSS_IMPORT_SESSIONS_SEQ
 START WITH 100
/

CREATE GLOBAL TEMPORARY TABLE S_NQ_DSS_IMPORT_SESSIONS
(
	IMPORT_SESSION_ID				NUMBER NOT NULL PRIMARY KEY,
	STARTED_DATE					TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL 
) ON COMMIT DELETE ROWS
/

CREATE GLOBAL TEMPORARY TABLE S_NQ_DSS_SERVICE_STRIPES_TMP
(
	IMPORT_SESSION_ID				NUMBER NOT NULL,
	STRIPE_NAME						VARCHAR2(256),
	GUID_PREFIX						VARCHAR2(11),
	PROVISIONING_VERSION			VARCHAR2(50),
	PROVISIONED_DATE				TIMESTAMP,
	MANAGED_PROVIDER_ID				NUMBER,
	QUOTA_KILOBYTE_LIMIT			NUMBER,
	FILE_KILOBYTE_LIMIT				NUMBER,
	USER_QUOTA_KILOBYTE_LIMIT		NUMBER,
	USED_QUOTA_KILOBYTES			NUMBER
) ON COMMIT DELETE ROWS
/

CREATE INDEX S_NQ_DSS_SERVICE_STR_TMP_I1 ON S_NQ_DSS_SERVICE_STRIPES_TMP (IMPORT_SESSION_ID)
/

CREATE GLOBAL TEMPORARY TABLE S_NQ_DSS_IDENTITIES_TMP
(
	IMPORT_SESSION_ID				NUMBER NOT NULL,
	IDENTITY_ID						NUMBER,
	TYPE							CHAR,
	ROLE_OR_GUID					VARCHAR2(256),
	LAST_KNOWN_NAME					VARCHAR2(256),
	QUOTA_KILOBYTE_LIMIT			NUMBER,
	FILE_KILOBYTE_LIMIT				NUMBER,
	CREATED_DATE					TIMESTAMP
) ON COMMIT DELETE ROWS
/

CREATE INDEX S_NQ_DSS_IDENTITIES_TMP_I1 ON S_NQ_DSS_IDENTITIES_TMP (IMPORT_SESSION_ID)
/

CREATE GLOBAL TEMPORARY TABLE S_NQ_DSS_ACLS_TMP
(
	IMPORT_SESSION_ID				NUMBER NOT NULL,
	ACL_ID							NUMBER,
	ACL_NAME						VARCHAR2(50),
	ACL_OWNER_ID					NUMBER,
	LAST_MODIFIED					TIMESTAMP
) ON COMMIT DELETE ROWS
/

CREATE INDEX S_NQ_DSS_ACLS_TMP_I1 ON S_NQ_DSS_ACLS_TMP (IMPORT_SESSION_ID)
/

CREATE GLOBAL TEMPORARY TABLE S_NQ_DSS_ACL_ENTRIES_TMP
(
	IMPORT_SESSION_ID				NUMBER NOT NULL,
	ACL_ID							NUMBER,
	IDENTITY_ID						NUMBER,
	LIST_PERM						CHAR,
	READ_PERM						CHAR,
	WRITE_PERM						CHAR,
	EXECUTE_PERM					CHAR,
	DELETE_PERM						CHAR,
	CHANGEPERMISSIONS_PERM			CHAR
) ON COMMIT DELETE ROWS
/

CREATE INDEX S_NQ_DSS_ACL_ENTRIES_TMP_I1 ON S_NQ_DSS_ACL_ENTRIES_TMP (IMPORT_SESSION_ID)
/

CREATE GLOBAL TEMPORARY TABLE S_NQ_DSS_DATASETS_TMP
(
	IMPORT_SESSION_ID				NUMBER NOT NULL,
	DATASET_ID						NUMBER,
	DATASET_NAME					VARCHAR2(256),
	FILESTORE_ID					VARCHAR2(1024),
	ACL_ID							NUMBER,
	FILETYPE_ID						NUMBER,
	MIMETYPE						VARCHAR2(25),
	OWNER_ID						NUMBER, 
	CREATEDBY_ID					NUMBER, 
	PROVIDER_ID						NUMBER,
	TYPE_OPTIONS_XML				CLOB,
	PROVIDER_OPTIONS_XML			CLOB,
	FILETYPE_KNOBS					CLOB,
	FILE_LENGTH						NUMBER,
	STORAGE_FILE_LENGTH				NUMBER,
	LAST_MODIFIED					TIMESTAMP,
	CREATED_DATE					TIMESTAMP,
	BISERVERMETADATA_LAST_MODIFIED	TIMESTAMP,
	RAWFILE_LAST_MODIFIED			TIMESTAMP,
	IS_EMBRYONIC					CHAR,
	IS_USER_STRIPED					CHAR,
	INTERNAL_ID						VARCHAR2(256),
	NAMESPACE						VARCHAR2(128)
) ON COMMIT DELETE ROWS
/

CREATE INDEX S_NQ_DSS_DATASETS_TMP_I1 ON S_NQ_DSS_DATASETS_TMP (IMPORT_SESSION_ID)
/

CREATE GLOBAL TEMPORARY TABLE S_NQ_DSS_DATASET_ALIASES_TMP
(
	IMPORT_SESSION_ID				NUMBER NOT NULL,
	DATASET_ID						NUMBER,
	LOCALE							VARCHAR2(5),
	ALIAS							VARCHAR2(256),
	NAMESPACE						VARCHAR2(128)
) ON COMMIT DELETE ROWS
/

CREATE INDEX S_NQ_DSS_DATASET_ALIAS_TMP_I1 ON S_NQ_DSS_DATASET_ALIASES_TMP (IMPORT_SESSION_ID)
/

CREATE GLOBAL TEMPORARY TABLE S_NQ_DSS_DATASET_DESC_TMP
(
	IMPORT_SESSION_ID				NUMBER NOT NULL,
	DATASET_ID						NUMBER,
	LOCALE							VARCHAR2(5),
	DESCRIPTION						VARCHAR2(500)
) ON COMMIT DELETE ROWS
/

CREATE INDEX S_NQ_DSS_DATASET_DESC_TMP_I1 ON S_NQ_DSS_DATASET_DESC_TMP (IMPORT_SESSION_ID)
/

CREATE GLOBAL TEMPORARY TABLE S_NQ_DSS_DATASET_ATTRS_TMP
(
	IMPORT_SESSION_ID				NUMBER NOT NULL,
	DATASET_ID						NUMBER,
	ATTRTYPE_ID						NUMBER,
	VALUE							VARCHAR2(100)
) ON COMMIT DELETE ROWS
/

CREATE INDEX S_NQ_DSS_DATASET_ATTRS_TMP_I1 ON S_NQ_DSS_DATASET_ATTRS_TMP (IMPORT_SESSION_ID)
/

CREATE GLOBAL TEMPORARY TABLE S_NQ_DSS_AUDIT_TMP 
(
	IMPORT_SESSION_ID				NUMBER NOT NULL,
	EV_ID							NUMBER,
	EV_DATE							TIMESTAMP,
	EV_TYPE							NVARCHAR2(20),
	DATASET_NAME					VARCHAR2(256),
	ALIAS							NVARCHAR2(256),
	IDENTITY_ID						NUMBER,
	IDENTITY_NAME					NVARCHAR2(200),
	EV_SIZE							NUMBER,
	NAMESPACE						VARCHAR2(128),
	INTERNAL_ID						VARCHAR2(256)
) ON COMMIT DELETE ROWS
/

CREATE INDEX S_NQ_DSS_AUDIT_TMP_I1 ON S_NQ_DSS_AUDIT_TMP (IMPORT_SESSION_ID)
/

CREATE GLOBAL TEMPORARY TABLE S_NQ_DSS_ENTITIES_TMP
(
	IMPORT_SESSION_ID				NUMBER NOT NULL,
	ENTITY_ID 						NUMBER,
	ENTITY_NAME 					VARCHAR2(256),
	ENTITY_SUFFIX 					NUMBER,
	NAMESPACE						VARCHAR2(128),
	INTERNAL_ID						VARCHAR2(256),
	OWNER_ID 						NUMBER,
	CREATEDBY_ID 					NUMBER,
	LAST_MODIFIED 					TIMESTAMP,
	CREATED_DATE 					TIMESTAMP
)ON COMMIT DELETE ROWS
/

CREATE INDEX S_NQ_DSS_ENTITIES_TMP_I1 ON S_NQ_DSS_ENTITIES_TMP (IMPORT_SESSION_ID)
/

CREATE GLOBAL TEMPORARY TABLE S_NQ_DSS_ID_MAP_TMP
(
	IMPORT_SESSION_ID				NUMBER NOT NULL,
	TYPE							CHAR NOT NULL,
	OLD_ID							NUMBER NOT NULL,
	NEW_ID							NUMBER NOT NULL,
	PRIMARY KEY(IMPORT_SESSION_ID, TYPE, OLD_ID)
) ON COMMIT DELETE ROWS
/

CREATE GLOBAL TEMPORARY TABLE S_NQ_DSS_ERRLOG
(
	ORA_ERR_NUMBER$					NUMBER,
	ORA_ERR_MESG$					VARCHAR2(2000),
	ORA_ERR_ROWID$					ROWID,
	ORA_ERR_OPTYP$					VARCHAR2(2),
	ORA_ERR_TAG$					VARCHAR2(2000),
	DATASET_ID						NUMBER,
	DATASET_NAME					VARCHAR2(256),
	ACL_ID							NUMBER,
	ROLE_OR_GUID					VARCHAR2(50)
) ON COMMIT PRESERVE ROWS
/

COMMIT
/

COMMIT
/

COMMIT
/

ALTER SESSION SET CURRENT_SCHEMA=TESTONE_BIPLATFORM
/

CREATE TABLE S_NQ_DSS_FS_FILES
(
	STRIPE_NAME						VARCHAR2(256) NOT NULL,
	FILESTORE_ID					VARCHAR2(128) NOT NULL PRIMARY KEY,
	FILE_STORE_TYPE					VARCHAR2(10) DEFAULT 'raw',
	ORPHANED						CHAR DEFAULT 'n' CHECK (ORPHANED IN ('y','n')),
	LAST_MODIFIED					TIMESTAMP,
	CONTENTS						BLOB
)
/

CREATE INDEX S_NQ_DSS_FS_FILES_IDX ON S_NQ_DSS_FS_FILES (STRIPE_NAME, FILESTORE_ID,FILE_STORE_TYPE)
/

COMMIT
/

COMMIT
/

COMMIT
/

ALTER SESSION SET CURRENT_SCHEMA=TESTONE_BIPLATFORM
/

CREATE TABLE S_NQ_SEARCH_CRAWL_CONFIG
			(
				TENANT VARCHAR2(100) NOT NULL, 
				ENABLED INT NOT NULL, 
				CRAWL_CONFIG_PATH VARCHAR2(1024), 
				CRAWL_CONFIG_XML CLOB,
				CONSTRAINT SEARCH_CRAWL_CONFIG_PK PRIMARY KEY 
				( 
					TENANT 
				) ENABLE 
			)
/

CREATE TABLE S_NQ_SEARCH_CRAWL_JOB_INFO 
			(
				CRAWL_JOB_ID VARCHAR2(20) NOT NULL, 
				TENANT VARCHAR2(100) NOT NULL, 
				STATUS VARCHAR2(20) NOT NULL, 
				JOB_SCHEDULE_TIME TIMESTAMP NOT NULL, 			
				JOB_TYPE VARCHAR2(50) NOT NULL, 
				JOB_START_TIME TIMESTAMP, 
				JOB_END_TIME TIMESTAMP, 
				CRAWL_STATISTICS VARCHAR2(4000), 
				MANAGED_SERVER_NODE VARCHAR2(100),
				CRAWL_CONFIG_ID INT NOT NULL,
				CONSTRAINT SEARCH_CRAWL_JOB_INFO_PK PRIMARY KEY 
				(
					CRAWL_JOB_ID 
				) ENABLE 
			)
/

CREATE INDEX S_NQ_SEARCH_CRAWL_JOB_INFO_IDX ON S_NQ_SEARCH_CRAWL_JOB_INFO (TENANT, STATUS, JOB_SCHEDULE_TIME DESC)
/

ALTER SESSION SET CURRENT_SCHEMA = TESTONE_BIPLATFORM ;
CREATE TABLE "ESSBASE_AGENT_RUNTIME" 
   ("ID" VARCHAR2(255 CHAR), 
	"CREATION_DATE" TIMESTAMP, 
	"AGENT_HOST" NVARCHAR2(512), 
	"AGENT_PORT" NUMBER(11,0), 
	"AGENT_SECUREPORT" NUMBER(11,0), 
	"LAST_MODIFIED_DATE" DATE, 
	"LAST_MODIFIED_TIMESTAMP" NUMBER(11,0), 
	"VERSION_ID" NUMBER(11,0)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE VIEW "ESSBASE_AGENT_RUNTIME_VIEW" AS
   SELECT 
    ID, 
    AGENT_HOST, 
    AGENT_PORT, 
    AGENT_SECUREPORT, 
    LAST_MODIFIED_DATE, 
    TRUNC(((SYSDATE - TO_DATE('01-01-1970 00:00:00', 'DD-MM-YYYY HH24:MI:SS')) * 24 * 60 * 60 
     - (LAST_MODIFIED_DATE - TO_DATE('01-01-1970 00:00:00', 'DD-MM-YYYY HH24:MI:SS')) * 24 * 60 * 60)) HEARTBEAT_ELAP_TIME_IN_SECS
   FROM "ESSBASE_AGENT_RUNTIME"
/

CREATE TABLE "ESSBASE_AGENT_SESSION" 
   (	"ID" VARCHAR2(255 CHAR), 
    "JAGENT_ID" VARCHAR2(255 CHAR),
    "CREATION_DATE" TIMESTAMP, 
	"SESSION_ID" VARCHAR2(255 CHAR), 
	"LAST_MODIFIED_DATE" DATE, 
	"LAST_ALIVE_TIME" DATE, 
	"VERSION_ID" NUMBER(11,0), 
	"AGENT_ID" VARCHAR2(255 CHAR)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE TABLE "ESSBASE_AGENT_SESSION_STATE" 
   (	"ID" VARCHAR2(255 CHAR), 
    "JAGENT_ID" VARCHAR2(255 CHAR),   
	"CREATION_DATE" TIMESTAMP, 
	"DATA_TYPE" VARCHAR2(45 CHAR), 
	"STATE_VALUE" NVARCHAR2(255), 
	"LAST_MODIFIED_DATE" DATE, 
	"STATE_KEY" VARCHAR2(45 CHAR), 
	"VERSION_ID" NUMBER(11,0), 
	"SESSION_ID" VARCHAR2(255 CHAR)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE TABLE "ESSBASE_APPLICATION" 
   (	"ID" VARCHAR2(255 CHAR), 
    "JAGENT_ID" VARCHAR2(255 CHAR),
    "LOCALE_DESCRIPTION" NVARCHAR2(255), 
	"APPLICATION_TYPE" VARCHAR2(45 CHAR), 
	"VERSION_ID" NUMBER(11,0), 
	"CONNECTS_ALLOWED" NUMBER(3,0) DEFAULT '0', 
	"DESCRIPTION" NVARCHAR2(2000), 
	"APPLICATION_NAME" NVARCHAR2(50), 
	"LOCK_TIMEOUT" NUMBER(11,0), 
	"LRO_SIZE_LIMIT" NUMBER(11,0), 
	"COMMANDS_ALLOWED" NUMBER(3,0) DEFAULT '0', 
	"LOADABLE" NUMBER(3,0) DEFAULT '0', 
	"SECURITY_ENABLED" NUMBER(3,0) DEFAULT '0', 
	"APPLICATION_ACCESS" VARCHAR2(45 CHAR), 
	"APPLICATION_HSS_ID" VARCHAR2(512 CHAR), 
	"CREATION_DATE" TIMESTAMP, 
	"FRONTEND_TYPE" VARCHAR2(45 CHAR), 
	"STORAGE_TYPE" VARCHAR2(45 CHAR), 
	"HIDDEN_STATE" NUMBER(3,0) DEFAULT '0', 
	"AUTOLOAD" NUMBER(3,0) DEFAULT '0', 
	"LAST_MODIFIED_DATE" DATE, 
	"UPDATES_ALLOWED" NUMBER(3,0) DEFAULT '0', 
	"APPLICATION_CREATOR" VARCHAR2(255 CHAR)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE TABLE "ESSBASE_CALC" 
   (	"ID" VARCHAR2(255 CHAR), 
    "JAGENT_ID" VARCHAR2(255 CHAR),
    "CREATION_DATE" TIMESTAMP, 
	"CALC_NAME" NVARCHAR2(255), 
	"LAST_MODIFIED_DATE" DATE, 
	"CALC_STRING" CLOB, 
	"VERSION_ID" NUMBER(11,0), 
	"ESSBASE_CUBE" VARCHAR2(255 CHAR), 
	"ESSBASE_APPLICATION" VARCHAR2(255 CHAR)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
/

CREATE TABLE "ESSBASE_CONFIG" 
   (	"ID" VARCHAR2(255 CHAR), 
    "JAGENT_ID" VARCHAR2(255 CHAR),   
	"CREATION_DATE" TIMESTAMP, 
	"DATA_TYPE" VARCHAR2(45 CHAR), 
	"CONFIG_NAME" NVARCHAR2(45), 
	"CONFIG_VALUE" NVARCHAR2(2000), 
	"LAST_MODIFIED_DATE" DATE, 
	"CONFIG_COMMENT" NVARCHAR2(255), 
	"VERSION_ID" NUMBER(11,0)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
/

CREATE TABLE "ESSBASE_DATABASE" 
   (	"ID" VARCHAR2(255 CHAR), 
    "JAGENT_ID" VARCHAR2(255 CHAR),
    "RETRIEVAL_SORT_BUFFER" NUMBER(24,0), 
	"COMMIT_ROW_SIZE" NUMBER(11,0), 
	"CURRENCY_CONVERSION_TYPE" VARCHAR2(45 CHAR), 
	"MAX_INDEX_MEMORY_SIZE" NUMBER(24,0), 
	"INDEX_TYPE" VARCHAR2(45 CHAR), 
	"DESCRIPTION" NVARCHAR2(2000), 
	"CURRENCY_TIME_DIM_MEMBER" NVARCHAR2(255), 
	"MAX_MEM_DATAFILE_CACHE" NUMBER(24,0), 
	"ISOLATION_LEVEL" NVARCHAR2(45), 
	"PAGE_SIZE" NUMBER(24,0), 
	"CALC_NO_AVG_MISSING" NUMBER(3,0) DEFAULT '0', 
	"DATABASE_COMPRESS" NUMBER(3,0) DEFAULT '0', 
	"DATABASE_STATE" VARCHAR2(45 CHAR), 
	"TIME_ELAPSED" DATE, 
	"DATA_STATUS" VARCHAR2(45 CHAR), 
	"CALC_CREATE_BLOCK" NUMBER(3,0) DEFAULT '0', 
	"CALC_NO_AGG_MISSING" NUMBER(3,0) DEFAULT '0', 
	"IO_ACCESS_FLAG_PENDING" VARCHAR2(45 CHAR), 
	"DATABASE_TYPE" VARCHAR2(45 CHAR), 
	"CALC_TWO_PASS" NUMBER(3,0) DEFAULT '0', 
	"LOCKS_COUNT" NUMBER(11,0) DEFAULT '0', 
	"CACHE_MEM_LOCKING" NUMBER(3,0) DEFAULT '0', 
	"VOLUMES_COUNT" NUMBER(11,0) DEFAULT '0', 
	"VERSION_ID" NUMBER(11,0), 
	"CURRENCY_TYPE_MEMBER" NVARCHAR2(255), 
	"DATABASE_NAME" NVARCHAR2(255), 
	"NO_WAIT_IO" NUMBER(3,0) DEFAULT '0', 
	"DIMENSIONS" NUMBER(11,0), 
	"NOTE" CLOB, 
	"DATA_COMPRESS_TYPE" VARCHAR2(45 CHAR), 
	"IO_ACCESS_FLAG_IN_USE" VARCHAR2(45 CHAR), 
	"COMMIT_BLOCKS" NUMBER(11,0), 
	"MAX_MEMORY" NUMBER(24,0), 
	"LOADABLE" NUMBER(3,0) DEFAULT '0', 
	"DATABASE_ACCESS" VARCHAR2(45 CHAR), 
	"CURRENCY_PARTITION_MEMBER" NVARCHAR2(255), 
	"CURRENCY_CATEGORY_DIM_MEMBER" NVARCHAR2(255), 
	"CREATION_DATE" TIMESTAMP, 
	"PRE_IMAGE" NUMBER(3,0) DEFAULT '0', 
	"AUTOLOAD" NUMBER(3,0) DEFAULT '0', 
	"RETRIEVAL_BUFFER" NUMBER(24,0), 
	"LAST_MODIFIED_DATE" DATE, 
	"CURRENCY_COUNTRY_DIM_MEMBER" NVARCHAR2(255), 
	"TIMEOUT_VALUE" NUMBER(11,0), 
	"DATABASE_CREATOR" VARCHAR2(255 CHAR), 
	"CURRENCY_DATABASE" VARCHAR2(255 CHAR), 
	"APPLICATION" VARCHAR2(255 CHAR)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
/

CREATE TABLE "ESSBASE_DISK_VOLUME" 
   (	"ID" VARCHAR2(255 CHAR), 
    "JAGENT_ID" VARCHAR2(255 CHAR),
    "CREATION_DATE" TIMESTAMP, 
	"FILE_TYPE" VARCHAR2(45 CHAR), 
	"LAST_MODIFIED_DATE" DATE, 
	"MAX_FILE_SIZE" NUMBER(24,0), 
	"DISK_PARTITION_SIZE" NUMBER(24,0), 
	"PARTITION_NAME" NVARCHAR2(1024), 
	"VERSION_ID" NUMBER(11,0), 
	"ESSBASE_CUBE" VARCHAR2(255 CHAR)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE TABLE "ESSBASE_FILTER" 
   (	"ID" VARCHAR2(255 CHAR), 
    "JAGENT_ID" VARCHAR2(255 CHAR),
    "CREATION_DATE" TIMESTAMP, 
	"FILTER_NAME" NVARCHAR2(256), 
	"ACTIVE" NUMBER(3,0) DEFAULT '0', 
	"LAST_MODIFIED_DATE" DATE, 
	"VERSION_ID" NUMBER(11,0), 
	"ESSBASE_APPLICATION" VARCHAR2(255 CHAR), 
    "ESSBASE_CUBE" VARCHAR2(255 CHAR),
	"FILTER_TYPE" NUMBER(11,0),
	"FILTER_PROVIDER" VARCHAR2(255 CHAR)
  ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE TABLE "ESSBASE_FUNCTION" 
   (	"ID" VARCHAR2(255 CHAR), 
    "JAGENT_ID" VARCHAR2(255 CHAR),
    "CALC_SPEC_STRING" CLOB, 
	"CREATION_DATE" TIMESTAMP, 
	"FUNCTION_NAME" NVARCHAR2(128), 
	"JAVA_CLASS_METHOD" VARCHAR2(255 CHAR), 
	"LAST_MODIFIED_DATE" DATE, 
	"RUNTIME" NUMBER(3,0) DEFAULT '0', 
	"FUNCTION_COMMENT" NVARCHAR2(2000), 
	"VERSION_ID" NUMBER(11,0), 
	"APPLICATION" VARCHAR2(255 CHAR)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
/

CREATE TABLE "ESSBASE_GLOBAL" 
   (	"ID" VARCHAR2(255 CHAR), 
    "JAGENT_ID" VARCHAR2(255 CHAR),
    "PASSWORD_STORED_COUNT" NUMBER(11,0), 
	"LOGINS_ENABLED" NUMBER(3,0) DEFAULT '0', 
	"INACTIVITY_TIME" NUMBER(11,0), 
	"PASSWORD_EXPIRY_WARN_COUNT" NUMBER(11,0), 
	"VERSION_ID" NUMBER(11,0), 
	"ADMINSVC_LOCATION" NVARCHAR2(512), 
	"CURRENCY_ENABLED" NUMBER(3,0) DEFAULT '0', 
	"INVALID_ATTEMPTS" NUMBER(11,0), 
	"DEFAULT_ACCESS_LEVEL" VARCHAR2(45 CHAR), 
	"SECURITY_MODE" VARCHAR2(255 CHAR), 
	"INACTIVITY_CHECK" NUMBER(11,0), 
	"ESB_LANGUAGE" VARCHAR2(255 CHAR), 
	"HOSTNAME" NVARCHAR2(512), 
	"ESB_LOCATION" NVARCHAR2(512), 
	"SECURITY_ENABLED" NUMBER(3,0) DEFAULT '0', 
	"PASSWORD_VALIDITY" NUMBER(11,0), 
	"CREATION_DATE" TIMESTAMP, 
	"PASSWORD_MIN_LENGTH" NUMBER(11,0), 
	"INVALID_LOCKOUT" NUMBER(11,0), 
	"SSS_NAME" NVARCHAR2(255), 
	"LAST_MODIFIED_DATE" DATE, 
	"PRODUCT_CODE_VERSION" VARCHAR2(50 CHAR), 
	"CSS_MIGRATED" NUMBER(3,0) DEFAULT '0', 
	"HUB_REG_SEQUENCE_NUM" NUMBER(11,0), 
	"LOCALE_CONFIG" NUMBER(11,0)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE TABLE "ESSBASE_LICENSE" 
   (	"ID" VARCHAR2(255 CHAR), 
    "JAGENT_ID" VARCHAR2(255 CHAR),
    "DATAMINING_ENABLED" NUMBER(3,0) DEFAULT '0', 
	"LICENSE_EXPIRY_DATE" DATE, 
	"EDS_ENABLED" NUMBER(3,0) DEFAULT '0', 
	"SPREADSHEET_TOOLKIT" NUMBER(3,0) DEFAULT '0', 
	"BUSINESS_RULES_ENABLED" NUMBER(3,0) DEFAULT '0', 
	"LICENSE_EXPIRING" NUMBER(3,0) DEFAULT '0', 
	"NAMED_USERS_COUNT" NUMBER(11,0), 
	"READ_ONLY_USERS_COUNT" NUMBER(11,0), 
	"ALLOW64BIT" NUMBER(3,0) DEFAULT '0', 
	"ADMIN_USERS_COUNT" NUMBER(11,0), 
	"OBJECTS_ENABLED" NUMBER(3,0) DEFAULT '0', 
	"LIMITED_SKU_APPMAN_ENABLED" NUMBER(3,0) DEFAULT '0', 
	"VERSION_ID" NUMBER(11,0), 
	"LIMITED_SKU_SS_ENABLED" NUMBER(3,0) DEFAULT '0', 
	"TRIGGERS_ENABLED" NUMBER(3,0) DEFAULT '0', 
	"SQL_INTERFACE_ENABLED" NUMBER(3,0) DEFAULT '0', 
	"EIS_ENABLED" NUMBER(3,0) DEFAULT '0', 
	"VIEW_ONLY_USER_COUNT" NUMBER(11,0), 
	"READ_ONLY_SS_ENABLED" NUMBER(3,0) DEFAULT '0', 
	"LICENSE_TYPE" VARCHAR2(45 CHAR), 
	"CRYSTAL_ENABLED" NUMBER(3,0) DEFAULT '0', 
	"MAX_CONNECTIONS" NUMBER(11,0), 
	"SERVER_SOLUTIONS" NUMBER(6,0), 
	"READ_ONLY_SS_TOOLKIT_ENABLED" NUMBER(3,0) DEFAULT '0', 
	"RESTRICTED_PLNG_USERS_COUNT" NUMBER(11,0), 
	"MIGR_TIME" DATE, 
	"CPUS_COUNT" NUMBER(6,0), 
	"SPREADSHEET_ADDIN" NUMBER(3,0) DEFAULT '0', 
	"API_USAGE_ENABLED" NUMBER(3,0) DEFAULT '0', 
	"PORTS_COUNT" NUMBER(11,0), 
	"CREATION_DATE" TIMESTAMP, 
	"VISUAL_EXPLORER_ENABLED" NUMBER(3,0) DEFAULT '0', 
	"APPMAN_EAS_ENABLED" NUMBER(3,0) DEFAULT '0', 
	"MISSED_HEART_BEATS" NUMBER(11,0), 
	"BSO" NUMBER(3,0) DEFAULT '0', 
	"ASO" NUMBER(3,0) DEFAULT '0', 
	"LAST_MODIFIED_DATE" DATE, 
	"CURRENCY_CONVERSION_ENABLED" NUMBER(3,0) DEFAULT '0', 
	"PLANNING_USERS_COUNT" NUMBER(11,0), 
	"REPORTS_ENABLED" NUMBER(3,0) DEFAULT '0', 
	"PARTITION_ENABLED" NUMBER(3,0) DEFAULT '0'
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE TABLE "ESSBASE_LOCALIZED_MESSAGE" 
   (	"ID" VARCHAR2(255 CHAR), 
	"CAUSE" NVARCHAR2(2000), 
	"SEVERITY" VARCHAR2(45 CHAR), 
	"VERSION_ID" NUMBER(11,0), 
	"MESSAGE" NVARCHAR2(2000), 
	"CREATION_DATE" TIMESTAMP, 
	"MESSAGE_ODL_ID" VARCHAR2(45 CHAR), 
	"COMPONENT" VARCHAR2(45 CHAR), 
	"DESCRIPTION" NVARCHAR2(2000), 
	"ACTIONABLE_MSG" NVARCHAR2(2000), 
	"ERROR_CODE" VARCHAR2(45 CHAR), 
	"LAST_MODIFIED_DATE" DATE, 
	"MSG_KEY" VARCHAR2(45 CHAR)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE TABLE "ESSBASE_MACRO" 
   (	"ID" VARCHAR2(255 CHAR), 
    "JAGENT_ID" VARCHAR2(255 CHAR),
    "CALC_SPEC_STRING" NCLOB, 
	"CREATION_DATE" TIMESTAMP, 
	"MACRO_NAME" NVARCHAR2(128), 
	"LAST_MODIFIED_DATE" DATE, 
	"MACRO_COMMENT" NVARCHAR2(2000), 
	"MACRO_EXPANSION" NVARCHAR2(255), 
	"SIGNATURE" NVARCHAR2(255), 
	"VERSION_ID" NUMBER(11,0), 
	"APPLICATION" VARCHAR2(255 CHAR)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
/

CREATE TABLE "ESSBASE_MAXL_AUDIT_TRAIL" 
   (	"ID" VARCHAR2(255 CHAR), 
    "JAGENT_ID" VARCHAR2(255 CHAR),
    "CREATION_DATE" TIMESTAMP, 
	"EXECUTION_TIME_MS" NUMBER(24,0), 
	"MAXL_STATEMENT" CLOB, 
	"ISSUED_TIME" DATE, 
	"LAST_MODIFIED_DATE" DATE, 
	"VERSION_ID" NUMBER(11,0), 
	"ISSUED_BY" VARCHAR2(255 CHAR)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
/

CREATE TABLE "ESSBASE_MESSAGE_TRANSLATION" 
   (	"ID" VARCHAR2(255 CHAR), 
	"CREATION_DATE" TIMESTAMP, 
	"TRANSLATED_ACTION" NVARCHAR2(2000), 
	"TRANSLATED_CAUSE" NVARCHAR2(2000), 
	"TRANSLATED_MESSAGE" NVARCHAR2(2000), 
	"LAST_MODIFIED_DATE" DATE, 
	"TRANSLATION_LANGUAGE" NVARCHAR2(45), 
	"VERSION_ID" NUMBER(11,0), 
	"LOCALIZED_MESSAGE_ID" VARCHAR2(255 CHAR)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE TABLE "ESSBASE_NODE" 
   (	"ID" VARCHAR2(255 CHAR), 
    "JAGENT_ID" VARCHAR2(255 CHAR),
    "CREATION_DATE" TIMESTAMP, 
	"STATUS" NUMBER(11,0), 
	"ISFILTER" NUMBER(3,0) DEFAULT '0', 
	"LAST_MODIFIED_DATE" DATE, 
	"VERSION_ID" NUMBER(11,0), 
	"CALC" VARCHAR2(255 CHAR), 
	"ESSBASE_USER" VARCHAR2(255 CHAR), 
	"ESSBASE_FILTER" VARCHAR2(255 CHAR)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE TABLE "ESSBASE_OBJECT" 
   (	"ID" VARCHAR2(255 CHAR), 
    "JAGENT_ID" VARCHAR2(255 CHAR),
    "TIMESTAMP_VALUE" DATE, 
	"CREATION_DATE" TIMESTAMP, 
	"FILESIZE" NUMBER(24,0), 
	"OBJECT_NAME" NVARCHAR2(255), 
	"LAST_MODIFIED_DATE" DATE, 
	"OBJECT_TYPE" NVARCHAR2(45), 
	"VERSION_ID" NUMBER(11,0), 
	"ESSBASE_APPLICATION" VARCHAR2(255 CHAR), 
	"ESSBASE_USER" VARCHAR2(255 CHAR), 
	"ESSBASE_CUBE" VARCHAR2(255 CHAR)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE TABLE "ESSBASE_PING" 
   (	"ID" VARCHAR2(255 CHAR), 
	"CREATION_DATE" TIMESTAMP, 
	"PING_NAME" NVARCHAR2(45), 
	"PING_VALUE" NVARCHAR2(2000), 
	"LAST_MODIFIED_DATE" DATE, 
	"VERSION_ID" NUMBER(11,0)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE TABLE "ESSBASE_RELATED_USER_GROUPS" 
   (	"ID" VARCHAR2(255 CHAR), 
    "JAGENT_ID" VARCHAR2(255 CHAR),
    "CREATION_DATE" TIMESTAMP, 
	"LAST_MODIFIED_DATE" DATE, 
	"VERSION_ID" NUMBER(11,0), 
	"USER_GROUP_ID" VARCHAR2(255 CHAR), 
	"RELATED_USER_GROUP_ID" VARCHAR2(255 CHAR)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE TABLE "ESSBASE_ROLES" 
   (	"ID" VARCHAR2(255 CHAR), 
    "JAGENT_ID" VARCHAR2(255 CHAR),
    "NATIVE_ROLE" NVARCHAR2(255), 
	"CREATION_DATE" TIMESTAMP, 
	"ROLE_DESCRIPTION" NVARCHAR2(255), 
	"CSS_ROLE_NAME" NVARCHAR2(255), 
	"LAST_MODIFIED_DATE" DATE, 
	"VERSION_ID" NUMBER(11,0)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE TABLE "ESSBASE_ROW" 
   (	"ID" VARCHAR2(255 CHAR), 
    "JAGENT_ID" VARCHAR2(255 CHAR),
    "CREATION_DATE" TIMESTAMP, 
	"ROW_VALUE" CLOB, 
	"LAST_MODIFIED_DATE" DATE, 
	"FILTER_ACCESS" VARCHAR2(45 CHAR), 
	"VERSION_ID" NUMBER(11,0), 
	"ESSBASE_FILTER" VARCHAR2(255 CHAR)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
/

CREATE TABLE "ESSBASE_SECURITY_HEADER" 
   (	"ID" VARCHAR2(255 CHAR), 
    "JAGENT_ID" VARCHAR2(255 CHAR),
    "LOCALE_CONFIG" NUMBER(3,0) DEFAULT '0', 
	"INCREMENT_VALUE" VARCHAR2(10 CHAR), 
	"MY_OLAP_ENABLED" NUMBER(3,0) DEFAULT '0', 
	"PLATFORM_TOKEN" NUMBER(11,0), 
	"AGENT_ID_MIGRATION_STATUS" NUMBER(3,0) DEFAULT '0', 
	"ESSBASE_PASSWORD" VARCHAR2(255 CHAR), 
	"VERSION_ID" NUMBER(11,0), 
	"REVISION" NUMBER(11,0), 
	"CREATION_DATE" TIMESTAMP, 
	"USERNAME" NVARCHAR2(255), 
	"COMPANY" NVARCHAR2(255), 
	"MY_OLAP_INITIALIZED" NUMBER(3,0) DEFAULT '0', 
	"LAST_MODIFIED_DATE" DATE, 
	"DATE_INSTALLED" DATE
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE TABLE "ESSBASE_SERVER_RUNTIME" 
   (	"ID" VARCHAR2(255 CHAR), 
    "JAGENT_ID" VARCHAR2(255 CHAR),
    "CREATION_DATE" TIMESTAMP, 
	"STARTID" NVARCHAR2(255), 
	"CLIENT_NONSECURE_PORT" NUMBER(11,0), 
	"CLIENT_SECURE_PORT" NUMBER(11,0), 
	"SERVER_PORT" NUMBER(11,0), 
	"LAST_MODIFIED_DATE" DATE, 
	"SERVER_HOST" NVARCHAR2(512), 
	"VERSION_ID" NUMBER(11,0),
	"SERVER_STATE" VARCHAR2(50 CHAR),
	"SERVER_PID" NUMBER(11,0)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE VIEW "ESSBASE_SERVER_RUNTIME_VIEW" AS
   SELECT 
    ID, 
    JAGENT_ID, 
    STARTID, 
    SERVER_HOST, 
    SERVER_PORT, 
    SERVER_STATE, 
    SERVER_PID, 
    LAST_MODIFIED_DATE, 
   TRUNC(((SYSDATE - TO_DATE('01-01-1970 00:00:00', 'DD-MM-YYYY HH24:MI:SS')) * 24 * 60 * 60 
     - (LAST_MODIFIED_DATE - TO_DATE('01-01-1970 00:00:00', 'DD-MM-YYYY HH24:MI:SS')) * 24 * 60 * 60)) HEARTBEAT_ELAP_TIME_IN_SECS   
   FROM "ESSBASE_SERVER_RUNTIME"
/

CREATE TABLE "ESSBASE_SUBSTITUTION_VARIABLE" 
   (	"ID" VARCHAR2(255 CHAR), 
    "JAGENT_ID" VARCHAR2(255 CHAR),
    "CREATION_DATE" TIMESTAMP, 
	"VARIABLE_SCOPE" NVARCHAR2(255), 
	"VARIABLE_NAME" NVARCHAR2(1024), 
	"VARIABLE_VALUE" NCLOB, 
	"LAST_MODIFIED_DATE" DATE, 
	"VERSION_ID" NUMBER(11,0), 
	"ESSBASE_APPLICATION" VARCHAR2(255 CHAR), 
	"ESSBASE_CUBE" VARCHAR2(255 CHAR)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE TABLE "ESSBASE_USER_GROUP" 
   (	"ID" VARCHAR2(255 CHAR), 
    "JAGENT_ID" VARCHAR2(255 CHAR),
    "IS_MIGRATED" NUMBER(3,0) DEFAULT '0', 
	"FAILCOUNT" NUMBER(11,0), 
	"SALTED_DIGEST" VARCHAR2(1024 CHAR), 
	"PLATFORM_TOKEN" NUMBER(11,0), 
	"VERSION_ID" NUMBER(11,0), 
	"EMAIL_ID" NVARCHAR2(255), 
	"DESCRIPTION" NVARCHAR2(2000), 
	"NUM_WARNING" NUMBER(11,0), 
	"USER_GROUP_NAME" NVARCHAR2(1024), 
	"IS_GROUP" NUMBER(3,0) DEFAULT '0', 
	"PWD_CHANGE_NEEDED" NUMBER(3,0) DEFAULT '0', 
	"LICENSE_TYPE" NUMBER(11,0), 
	"LAST_PASSWORD_CHANGE" DATE, 
	"EXPIRATION" DATE, 
	"CONNPARAM" VARCHAR2(1024 CHAR), 
	"DELETED" NUMBER(3,0) DEFAULT '0', 
	"AUTHENTICATION_TYPE" VARCHAR2(45 CHAR), 
	"USER_GROUP_ACCESS" NUMBER(3,0) DEFAULT '0', 
	"CREATION_DATE" TIMESTAMP, 
	"LAST_LOGIN" DATE, 
	"LOCKED_OUT" NUMBER(3,0) DEFAULT '0', 
	"LAST_MODIFIED_DATE" DATE, 
	"PASSWORD_EXPIRED_TIME" DATE, 
	"PROVISIONING_STATUS" NUMBER(11,0), 
	"OWNER" VARCHAR2(255 CHAR), 
	"ACCESS_VALUE" NUMBER(24,0)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

COMMENT ON COLUMN "ESSBASE_USER_GROUP"."ACCESS_VALUE" IS 'ORIGINAL NAME:ACCESS'
/

CREATE TABLE "ESSBASE_USER_ROLES" 
   (	"ID" VARCHAR2(255 CHAR), 
    "JAGENT_ID" VARCHAR2(255 CHAR),
    "CREATION_DATE" TIMESTAMP, 
	"LAST_MODIFIED_DATE" DATE, 
	"VERSION_ID" NUMBER(11,0), 
	"ESSBASE_APPLICATION" VARCHAR2(255 CHAR), 
	"ESSBASE_CUBE" VARCHAR2(255 CHAR), 
	"ROLE_ID" VARCHAR2(255 CHAR), 
	"USER_GROUP" VARCHAR2(255 CHAR), 
	"ACCESS_VALUE" NUMBER(24,0), 
	"IS_ALLCALC" NUMBER(3,0) DEFAULT '0'
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

COMMENT ON COLUMN "ESSBASE_USER_ROLES"."ACCESS_VALUE" IS 'ORIGINAL NAME:ACCESS'
/

CREATE TABLE "ESSBASE_VOLUME" 
   (	"ID" VARCHAR2(255 CHAR), 
    "JAGENT_ID" VARCHAR2(255 CHAR),
    "CREATION_DATE" TIMESTAMP, 
	"DRIVE" NVARCHAR2(50), 
	"LAST_MODIFIED_DATE" DATE, 
	"VOLUME_SIZE" NUMBER(24,0), 
	"VERSION_ID" NUMBER(11,0)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE TABLE "NAME_RESOLUTION" 
   (	"ID" NUMBER(10,0), 
	"LOGICAL_NAME" NVARCHAR2(100), 
	"PHYSICAL_NAME" NVARCHAR2(100), 
	"TYPE" VARCHAR2(45 CHAR)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE TABLE "ESSBASE_DATABASE_PROPERTIES" 
   (
	"ID" VARCHAR2(255 CHAR),    
    "DATABASE_ID" VARCHAR2(255 CHAR), 
    "JAGENT_ID" VARCHAR2(255 CHAR),
	"CREATION_DATE" DATE,
	"LAST_MODIFIED_DATE" DATE, 
	"PROPERTY_KEY" VARCHAR2(255 CHAR), 
	"PROPERTY_VALUE" VARCHAR2(255 CHAR), 
	"MIGRATABLE" NUMBER(3,0) DEFAULT '0',
	"VERSION_ID" NUMBER(11,0)	
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE VIEW "ESSBASE_CDF_VIEW_GLOBAL" AS
SELECT  ESSBASE_FUNCTION.ID , 
FUNCTION_NAME, 
CALC_SPEC_STRING , 
JAVA_CLASS_METHOD , 
RUNTIME , 
FUNCTION_COMMENT , 
TRUNC((CAST(ESSBASE_FUNCTION.creation_date as DATE) - to_date('19700101','YYYYMMDD')) * 86400) AS SECS , 
mod(extract(second from essbase_function.creation_date), 1) * 1000000 AS MSECS ,
ESSBASE_FUNCTION.jagent_id AS jagent_id
FROM ESSBASE_FUNCTION
WHERE ESSBASE_FUNCTION.APPLICATION IS NULL

/

CREATE VIEW "ESSBASE_CDM_VIEW_GLOBAL" AS
SELECT  ESSBASE_MACRO.ID , 
MACRO_NAME, 
CALC_SPEC_STRING , 
MACRO_EXPANSION , 
SIGNATURE , 
MACRO_COMMENT ,
TRUNC((CAST(essbase_macro.creation_date as DATE) - to_date('19700101','YYYYMMDD')) * 86400) AS SECS , 
mod(extract(second from essbase_macro.creation_date), 1) * 1000000 AS MSECS ,
ESSBASE_MACRO.jagent_id AS jagent_id
FROM ESSBASE_MACRO
WHERE ESSBASE_MACRO.APPLICATION IS NULL

/

CREATE VIEW "ESSBASE_CDF_VIEW_LOCAL" AS
SELECT  ESSBASE_FUNCTION.ID , 
FUNCTION_NAME, 
CALC_SPEC_STRING , 
JAVA_CLASS_METHOD , 
RUNTIME , 
FUNCTION_COMMENT , 
TRUNC((CAST(ESSBASE_FUNCTION.creation_date as DATE) - to_date('19700101','YYYYMMDD')) * 86400) AS SECS , 
mod(extract(second from essbase_function.creation_date), 1) * 1000000 AS MSECS ,
ESSBASE_FUNCTION.jagent_id AS jagent_id ,
ESSBASE_APPLICATION.APPLICATION_NAME as APPLICATION_NAME
FROM ESSBASE_FUNCTION
JOIN ESSBASE_APPLICATION ON 
ESSBASE_FUNCTION.jagent_id = ESSBASE_APPLICATION.jagent_id AND
ESSBASE_FUNCTION.APPLICATION = ESSBASE_APPLICATION.id

/

CREATE VIEW "ESSBASE_CDM_VIEW_LOCAL" AS
SELECT  ESSBASE_MACRO.ID , 
MACRO_NAME, 
CALC_SPEC_STRING , 
MACRO_EXPANSION , 
SIGNATURE , 
MACRO_COMMENT ,
TRUNC((CAST(essbase_macro.creation_date as DATE) - to_date('19700101','YYYYMMDD')) * 86400) AS SECS , 
mod(extract(second from essbase_macro.creation_date), 1) * 1000000 AS MSECS ,
ESSBASE_MACRO.jagent_id AS jagent_id ,
ESSBASE_APPLICATION.APPLICATION_NAME as APPLICATION_NAME
FROM ESSBASE_MACRO
JOIN ESSBASE_APPLICATION ON 
ESSBASE_MACRO.jagent_id = ESSBASE_APPLICATION.jagent_id AND
ESSBASE_MACRO.APPLICATION = ESSBASE_APPLICATION.id

/

CREATE UNIQUE INDEX "APPLICATION_NAME" ON "ESSBASE_APPLICATION" ("JAGENT_ID", "APPLICATION_NAME") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE UNIQUE INDEX "CSS_ROLE_NAME" ON "ESSBASE_ROLES" ("JAGENT_ID", "CSS_ROLE_NAME") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE INDEX "ESSBASE_MESSAGE_TRANSLATION_LO" ON "ESSBASE_MESSAGE_TRANSLATION" ("LOCALIZED_MESSAGE_ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE INDEX "ESSBASE_RELATED_USER_GROUPS_RE" ON "ESSBASE_RELATED_USER_GROUPS" ("JAGENT_ID", "RELATED_USER_GROUP_ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE INDEX "ESSBASE_SUBSTITUTION_VARIABLE_" ON "ESSBASE_SUBSTITUTION_VARIABLE" ("ESSBASE_APPLICATION") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE INDEX "FK_ESSBASE_AGENT_SESSION_AGENT" ON "ESSBASE_AGENT_SESSION" ("AGENT_ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE INDEX "FK_ESSBASE_AGENT_SESSION_STATE" ON "ESSBASE_AGENT_SESSION_STATE" ("SESSION_ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE INDEX "FK_ESSBASE_APPLICATION_CREATOR" ON "ESSBASE_APPLICATION" ("JAGENT_ID", "APPLICATION_CREATOR") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE INDEX "FK_ESSBASE_CALC_ESSBASE_APPLIC" ON "ESSBASE_CALC" ("ESSBASE_APPLICATION") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE INDEX "FK_ESSBASE_CALC_ESSBASE_CUBE" ON "ESSBASE_CALC" ("ESSBASE_CUBE") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE INDEX "FK_ESSBASE_DATABASE_APPLICATIO" ON "ESSBASE_DATABASE" ("APPLICATION") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE INDEX "FK_ESSBASE_DATABASE_CURRENCY_D" ON "ESSBASE_DATABASE" ("CURRENCY_DATABASE") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE INDEX "FK_ESSBASE_DATABASE_DATABASE_C" ON "ESSBASE_DATABASE" ("JAGENT_ID", "DATABASE_CREATOR") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE INDEX "FK_ESSBASE_DISK_VOLUME_ESSBASE" ON "ESSBASE_DISK_VOLUME" ("ESSBASE_CUBE") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE INDEX "FK_ESS_DB_PROP_ESSBASE_DB" ON "ESSBASE_DATABASE_PROPERTIES" ("DATABASE_ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE INDEX "FK_ESSBASE_FILTER_ESSBASE_APPL" ON "ESSBASE_FILTER" ("ESSBASE_APPLICATION") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE INDEX "FK_ESSBASE_FILTER_ESSBASE_CUBE" ON "ESSBASE_FILTER" ("ESSBASE_CUBE") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE INDEX "FK_ESSBASE_FUNCTION_APPLICATIO" ON "ESSBASE_FUNCTION" ("APPLICATION") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE INDEX "FK_ESSBASE_MACRO_APPLICATION" ON "ESSBASE_MACRO" ("APPLICATION") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE INDEX "FK_ESSBASE_MAXL_AUDIT_TRAIL_IS" ON "ESSBASE_MAXL_AUDIT_TRAIL" ("JAGENT_ID", "ISSUED_BY") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE INDEX "FK_ESSBASE_NODE_CALC" ON "ESSBASE_NODE" ("CALC") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE INDEX "FK_ESSBASE_NODE_ESSBASE_FILTER" ON "ESSBASE_NODE" ("ESSBASE_FILTER") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE INDEX "FK_ESSBASE_NODE_ESSBASE_USER" ON "ESSBASE_NODE" ("JAGENT_ID", "ESSBASE_USER") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE INDEX "FK_ESSBASE_OBJECT_ESSBASE_APPL" ON "ESSBASE_OBJECT" ("ESSBASE_APPLICATION") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE INDEX "FK_ESSBASE_OBJECT_ESSBASE_CUBE" ON "ESSBASE_OBJECT" ("ESSBASE_CUBE") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE INDEX "FK_ESSBASE_OBJECT_ESSBASE_USER" ON "ESSBASE_OBJECT" ("JAGENT_ID", "ESSBASE_USER") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE INDEX "FK_ESSBASE_RELATED_USER_GROUPS" ON "ESSBASE_RELATED_USER_GROUPS" ("JAGENT_ID", "USER_GROUP_ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE INDEX "FK_ESSBASE_ROW_ESSBASE_FILTER" ON "ESSBASE_ROW" ("ESSBASE_FILTER") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE INDEX "FK_ESSBASE_SUBSTITUTION_VARIAB" ON "ESSBASE_SUBSTITUTION_VARIABLE" ("ESSBASE_CUBE") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE INDEX "FK_ESSBASE_USER_GROUP_OWNER" ON "ESSBASE_USER_GROUP" ("JAGENT_ID", "OWNER") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE INDEX "FK_ESSBASE_USER_ROLES_ESSBASE_" ON "ESSBASE_USER_ROLES" ("ESSBASE_APPLICATION") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE INDEX "FK_ESSBASE_USER_ROLES_ESSBAS_1" ON "ESSBASE_USER_ROLES" ("ESSBASE_CUBE") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE INDEX "FK_ESSBASE_USER_ROLES_ROLE_ID" ON "ESSBASE_USER_ROLES" ("ROLE_ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE INDEX "FK_ESSBASE_USER_ROLES_USER_GRO" ON "ESSBASE_USER_ROLES" ("JAGENT_ID", "USER_GROUP") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE UNIQUE INDEX "PRIMARY" ON "ESSBASE_AGENT_RUNTIME" ("ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE UNIQUE INDEX "PRIMARY_10" ON "ESSBASE_GLOBAL" ("JAGENT_ID", "ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE UNIQUE INDEX "PRIMARY_11" ON "ESSBASE_LICENSE" ("ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE UNIQUE INDEX "PRIMARY_12" ON "ESSBASE_LOCALIZED_MESSAGE" ("ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE UNIQUE INDEX "PRIMARY_13" ON "ESSBASE_MACRO" ("ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE UNIQUE INDEX "PRIMARY_14" ON "ESSBASE_MAXL_AUDIT_TRAIL" ("ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE UNIQUE INDEX "PRIMARY_15" ON "ESSBASE_MESSAGE_TRANSLATION" ("ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE UNIQUE INDEX "PRIMARY_16" ON "ESSBASE_NODE" ("ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE UNIQUE INDEX "PRIMARY_17" ON "ESSBASE_OBJECT" ("ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE UNIQUE INDEX "PRIMARY_18" ON "ESSBASE_PING" ("ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE UNIQUE INDEX "PRIMARY_19" ON "ESSBASE_RELATED_USER_GROUPS" ("ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE UNIQUE INDEX "PRIMARY_2" ON "ESSBASE_AGENT_SESSION_STATE" ("ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE UNIQUE INDEX "PRIMARY_20" ON "ESSBASE_ROLES" ("ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE UNIQUE INDEX "PRIMARY_21" ON "ESSBASE_ROW" ("ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE UNIQUE INDEX "PRIMARY_22" ON "ESSBASE_SECURITY_HEADER" ("ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE UNIQUE INDEX "PRIMARY_23" ON "ESSBASE_SERVER_RUNTIME" ("ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE UNIQUE INDEX "PRIMARY_24" ON "ESSBASE_SUBSTITUTION_VARIABLE" ("ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE UNIQUE INDEX "PRIMARY_25" ON "ESSBASE_USER_GROUP" ("ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE UNIQUE INDEX "PRIMARY_26" ON "ESSBASE_USER_ROLES" ("ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE UNIQUE INDEX "PRIMARY_27" ON "ESSBASE_VOLUME" ("ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE UNIQUE INDEX "PRIMARY_28" ON "ESSBASE_AGENT_SESSION" ("ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE UNIQUE INDEX "PRIMARY_3" ON "ESSBASE_APPLICATION" ("ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE UNIQUE INDEX "PRIMARY_4" ON "ESSBASE_CALC" ("ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE UNIQUE INDEX "PRIMARY_5" ON "ESSBASE_CONFIG" ("ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE UNIQUE INDEX "PRIMARY_6" ON "ESSBASE_DATABASE" ("ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE UNIQUE INDEX "PRIMARY_7" ON "ESSBASE_DISK_VOLUME" ("ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE UNIQUE INDEX "PRIMARY_8" ON "ESSBASE_FILTER" ("ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE UNIQUE INDEX "PRIMARY_9" ON "ESSBASE_FUNCTION" ("ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE UNIQUE INDEX "PRIMARY_29" ON "NAME_RESOLUTION" ("ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

CREATE UNIQUE INDEX "PRIMARY_30" ON "ESSBASE_DATABASE_PROPERTIES" ("ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

/

ALTER TABLE "ESSBASE_AGENT_RUNTIME" ADD CONSTRAINT "PRIMARY" PRIMARY KEY ("ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
    ENABLE
/

ALTER TABLE "ESSBASE_AGENT_RUNTIME" MODIFY ("ID" NOT NULL ENABLE)
/

ALTER TABLE "ESSBASE_AGENT_SESSION" ADD CONSTRAINT "PRIMARY_28" PRIMARY KEY ("ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
    ENABLE
/

ALTER TABLE "ESSBASE_AGENT_SESSION" MODIFY ("ID" NOT NULL ENABLE)
/

ALTER TABLE "ESSBASE_AGENT_SESSION_STATE" ADD CONSTRAINT "PRIMARY_2" PRIMARY KEY ("ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
    ENABLE
/

ALTER TABLE "ESSBASE_AGENT_SESSION_STATE" MODIFY ("ID" NOT NULL ENABLE)
/

ALTER TABLE "ESSBASE_APPLICATION" ADD CONSTRAINT "PRIMARY_3" PRIMARY KEY ("ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
    ENABLE
/

ALTER TABLE "ESSBASE_APPLICATION" MODIFY ("ID" NOT NULL ENABLE)
/

ALTER TABLE "ESSBASE_APPLICATION" MODIFY ("APPLICATION_NAME" NOT NULL ENABLE)
/

ALTER TABLE "ESSBASE_CALC" ADD CONSTRAINT "PRIMARY_4" PRIMARY KEY ("ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
    ENABLE
/

ALTER TABLE "ESSBASE_CALC" MODIFY ("ID" NOT NULL ENABLE)
/

ALTER TABLE "ESSBASE_CONFIG" ADD CONSTRAINT "PRIMARY_5" PRIMARY KEY ("ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
    ENABLE
/

ALTER TABLE "ESSBASE_CONFIG" MODIFY ("ID" NOT NULL ENABLE)
/

ALTER TABLE "ESSBASE_DATABASE" ADD CONSTRAINT "PRIMARY_6" PRIMARY KEY ("ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
    ENABLE
/

ALTER TABLE "ESSBASE_DATABASE" MODIFY ("ID" NOT NULL ENABLE)
/

ALTER TABLE "ESSBASE_DATABASE" MODIFY ("DATABASE_NAME" NOT NULL ENABLE)
/

ALTER TABLE "ESSBASE_DATABASE" MODIFY ("APPLICATION" NOT NULL ENABLE)
/

ALTER TABLE "ESSBASE_DISK_VOLUME" ADD CONSTRAINT "PRIMARY_7" PRIMARY KEY ("ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
    ENABLE
/

ALTER TABLE "ESSBASE_DISK_VOLUME" MODIFY ("ID" NOT NULL ENABLE)
/

ALTER TABLE "ESSBASE_DATABASE_PROPERTIES" ADD CONSTRAINT "PRIMARY_30" PRIMARY KEY ("ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
    ENABLE
/

ALTER TABLE "ESSBASE_DATABASE_PROPERTIES" MODIFY ("ID" NOT NULL ENABLE)
/

ALTER TABLE "ESSBASE_FILTER" ADD CONSTRAINT "PRIMARY_8" PRIMARY KEY ("ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
    ENABLE
/

ALTER TABLE "ESSBASE_FILTER" MODIFY ("ID" NOT NULL ENABLE)
/

ALTER TABLE "ESSBASE_FUNCTION" ADD CONSTRAINT "PRIMARY_9" PRIMARY KEY ("ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
    ENABLE
/

ALTER TABLE "ESSBASE_FUNCTION" MODIFY ("ID" NOT NULL ENABLE)
/

ALTER TABLE "ESSBASE_GLOBAL" ADD CONSTRAINT "PRIMARY_10" PRIMARY KEY ("JAGENT_ID", "ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
    ENABLE
/

ALTER TABLE "ESSBASE_GLOBAL" MODIFY ("ID" NOT NULL ENABLE)
/

ALTER TABLE "ESSBASE_LICENSE" ADD CONSTRAINT "PRIMARY_11" PRIMARY KEY ("ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
    ENABLE
/

ALTER TABLE "ESSBASE_LICENSE" MODIFY ("ID" NOT NULL ENABLE)
/

ALTER TABLE "ESSBASE_LOCALIZED_MESSAGE" ADD CONSTRAINT "PRIMARY_12" PRIMARY KEY ("ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
    ENABLE
/

ALTER TABLE "ESSBASE_LOCALIZED_MESSAGE" MODIFY ("ID" NOT NULL ENABLE)
/

ALTER TABLE "ESSBASE_MACRO" ADD CONSTRAINT "PRIMARY_13" PRIMARY KEY ("ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
    ENABLE
/

ALTER TABLE "ESSBASE_MACRO" MODIFY ("ID" NOT NULL ENABLE)
/

ALTER TABLE "ESSBASE_MAXL_AUDIT_TRAIL" ADD CONSTRAINT "PRIMARY_14" PRIMARY KEY ("ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
    ENABLE
/

ALTER TABLE "ESSBASE_MAXL_AUDIT_TRAIL" MODIFY ("ID" NOT NULL ENABLE)
/

ALTER TABLE "ESSBASE_MESSAGE_TRANSLATION" ADD CONSTRAINT "PRIMARY_15" PRIMARY KEY ("ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
    ENABLE
/

ALTER TABLE "ESSBASE_MESSAGE_TRANSLATION" MODIFY ("ID" NOT NULL ENABLE)
/

ALTER TABLE "ESSBASE_NODE" ADD CONSTRAINT "PRIMARY_16" PRIMARY KEY ("ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
    ENABLE
/

ALTER TABLE "ESSBASE_NODE" MODIFY ("ID" NOT NULL ENABLE)
/

ALTER TABLE "ESSBASE_OBJECT" ADD CONSTRAINT "PRIMARY_17" PRIMARY KEY ("ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
    ENABLE
/

ALTER TABLE "ESSBASE_OBJECT" MODIFY ("ID" NOT NULL ENABLE)
/

ALTER TABLE "ESSBASE_OBJECT" MODIFY ("OBJECT_NAME" NOT NULL ENABLE)
/

ALTER TABLE "ESSBASE_OBJECT" MODIFY ("ESSBASE_APPLICATION" NOT NULL ENABLE)
/

ALTER TABLE "ESSBASE_PING" ADD CONSTRAINT "PRIMARY_18" PRIMARY KEY ("ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
    ENABLE
/

ALTER TABLE "ESSBASE_PING" MODIFY ("ID" NOT NULL ENABLE)
/

ALTER TABLE "ESSBASE_RELATED_USER_GROUPS" ADD CONSTRAINT "PRIMARY_19" PRIMARY KEY ("ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
    ENABLE
/

ALTER TABLE "ESSBASE_RELATED_USER_GROUPS" MODIFY ("ID" NOT NULL ENABLE)
/

ALTER TABLE "ESSBASE_ROLES" ADD CONSTRAINT "PRIMARY_20" PRIMARY KEY ("ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
    ENABLE
/

ALTER TABLE "ESSBASE_ROLES" MODIFY ("ID" NOT NULL ENABLE)
/

ALTER TABLE "ESSBASE_ROW" ADD CONSTRAINT "PRIMARY_21" PRIMARY KEY ("ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
    ENABLE
/

ALTER TABLE "ESSBASE_ROW" MODIFY ("ID" NOT NULL ENABLE)
/

ALTER TABLE "ESSBASE_SECURITY_HEADER" ADD CONSTRAINT "PRIMARY_22" PRIMARY KEY ("ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
    ENABLE
/

ALTER TABLE "ESSBASE_SECURITY_HEADER" MODIFY ("ID" NOT NULL ENABLE)
/

ALTER TABLE "ESSBASE_SERVER_RUNTIME" ADD CONSTRAINT "PRIMARY_23" PRIMARY KEY ("ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
    ENABLE
/

ALTER TABLE "ESSBASE_SERVER_RUNTIME" MODIFY ("ID" NOT NULL ENABLE)
/

ALTER TABLE "ESSBASE_SUBSTITUTION_VARIABLE" ADD CONSTRAINT "PRIMARY_24" PRIMARY KEY ("ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
    ENABLE
/

ALTER TABLE "ESSBASE_SUBSTITUTION_VARIABLE" MODIFY ("ID" NOT NULL ENABLE)
/

ALTER TABLE "ESSBASE_SUBSTITUTION_VARIABLE" MODIFY ("VARIABLE_NAME" NOT NULL ENABLE)
/

ALTER TABLE "ESSBASE_USER_GROUP" ADD CONSTRAINT "PRIMARY_25" PRIMARY KEY ("ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
    ENABLE
/

ALTER TABLE "ESSBASE_USER_GROUP" MODIFY ("ID" NOT NULL ENABLE)
/

ALTER TABLE "ESSBASE_USER_ROLES" ADD CONSTRAINT "PRIMARY_26" PRIMARY KEY ("ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
    ENABLE
/

ALTER TABLE "ESSBASE_USER_ROLES" MODIFY ("ID" NOT NULL ENABLE)
/

ALTER TABLE "ESSBASE_USER_ROLES" MODIFY ("USER_GROUP" NOT NULL ENABLE)
/

ALTER TABLE "ESSBASE_VOLUME" ADD CONSTRAINT "PRIMARY_27" PRIMARY KEY ("ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
    ENABLE
/

ALTER TABLE "ESSBASE_VOLUME" MODIFY ("ID" NOT NULL ENABLE)
/

ALTER TABLE "NAME_RESOLUTION" ADD CONSTRAINT "PRIMARY_29" PRIMARY KEY ("ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
    ENABLE
/

ALTER TABLE "NAME_RESOLUTION" MODIFY ("ID" NOT NULL ENABLE)
/

ALTER TABLE "ESSBASE_AGENT_SESSION" ADD CONSTRAINT "FK_ESSBASE_AGENT_SESSION_AGENT" FOREIGN KEY ("AGENT_ID")
	  REFERENCES "ESSBASE_AGENT_RUNTIME" ("ID") ENABLE
/

ALTER TABLE "ESSBASE_AGENT_SESSION_STATE" ADD CONSTRAINT "FK_ESSBASE_AGENT_SESSION_STATE" FOREIGN KEY ("SESSION_ID")
	  REFERENCES "ESSBASE_AGENT_SESSION" ("ID") ENABLE
/

ALTER TABLE "ESSBASE_APPLICATION" ADD CONSTRAINT "FK_ESSBASE_APPLICATION_CREATOR" FOREIGN KEY ("APPLICATION_CREATOR")
	  REFERENCES "ESSBASE_USER_GROUP" ("ID") ENABLE
/

ALTER TABLE "ESSBASE_CALC" ADD CONSTRAINT "FK_ESSBASE_CALC_ESSBASE_APPLIC" FOREIGN KEY ("ESSBASE_APPLICATION")
	  REFERENCES "ESSBASE_APPLICATION" ("ID") ENABLE
/

ALTER TABLE "ESSBASE_CALC" ADD CONSTRAINT "FK_ESSBASE_CALC_ESSBASE_CUBE" FOREIGN KEY ("ESSBASE_CUBE")
	  REFERENCES "ESSBASE_DATABASE" ("ID") ENABLE
/

ALTER TABLE "ESSBASE_DATABASE" ADD CONSTRAINT "FK_ESSBASE_DATABASE_APPLICATIO" FOREIGN KEY ("APPLICATION")
	  REFERENCES "ESSBASE_APPLICATION" ("ID") ENABLE
/

ALTER TABLE "ESSBASE_DATABASE" ADD CONSTRAINT "FK_ESSBASE_DATABASE_CURRENCY_D" FOREIGN KEY ("CURRENCY_DATABASE")
	  REFERENCES "ESSBASE_DATABASE" ("ID") ENABLE
/

ALTER TABLE "ESSBASE_DATABASE" ADD CONSTRAINT "FK_ESSBASE_DATABASE_DATABASE_C" FOREIGN KEY ("DATABASE_CREATOR")
	  REFERENCES "ESSBASE_USER_GROUP" ("ID") ENABLE
/

ALTER TABLE "ESSBASE_DISK_VOLUME" ADD CONSTRAINT "FK_ESSBASE_DISK_VOLUME_ESSBASE" FOREIGN KEY ("ESSBASE_CUBE")
	  REFERENCES "ESSBASE_DATABASE" ("ID") ENABLE
/

ALTER TABLE "ESSBASE_FILTER" ADD CONSTRAINT "FK_ESSBASE_FILTER_ESSBASE_APPL" FOREIGN KEY ("ESSBASE_APPLICATION")
	  REFERENCES "ESSBASE_APPLICATION" ("ID") ENABLE
/

ALTER TABLE "ESSBASE_FILTER" ADD CONSTRAINT "FK_ESSBASE_FILTER_ESSBASE_CUBE" FOREIGN KEY ("ESSBASE_CUBE")
	  REFERENCES "ESSBASE_DATABASE" ("ID") ENABLE
/

ALTER TABLE "ESSBASE_DATABASE_PROPERTIES" ADD CONSTRAINT "FK_ESS_DB_PROP_ESSBASE_DB" FOREIGN KEY ("DATABASE_ID")
	  REFERENCES "ESSBASE_DATABASE" ("ID") ENABLE
/

ALTER TABLE "ESSBASE_FUNCTION" ADD CONSTRAINT "FK_ESSBASE_FUNCTION_APPLICATIO" FOREIGN KEY ("APPLICATION")
	  REFERENCES "ESSBASE_APPLICATION" ("ID") ENABLE
/

ALTER TABLE "ESSBASE_MACRO" ADD CONSTRAINT "FK_ESSBASE_MACRO_APPLICATION" FOREIGN KEY ("APPLICATION")
	  REFERENCES "ESSBASE_APPLICATION" ("ID") ENABLE
/

ALTER TABLE "ESSBASE_MAXL_AUDIT_TRAIL" ADD CONSTRAINT "FK_ESSBASE_MAXL_AUDIT_TRAIL_IS" FOREIGN KEY ("ISSUED_BY")
	  REFERENCES "ESSBASE_USER_GROUP" ("ID") ENABLE
/

ALTER TABLE "ESSBASE_MESSAGE_TRANSLATION" ADD CONSTRAINT "ESSBASE_MESSAGE_TRANSLATION_LO" FOREIGN KEY ("LOCALIZED_MESSAGE_ID")
	  REFERENCES "ESSBASE_LOCALIZED_MESSAGE" ("ID") ENABLE
/

ALTER TABLE "ESSBASE_NODE" ADD CONSTRAINT "FK_ESSBASE_NODE_CALC" FOREIGN KEY ("CALC")
	  REFERENCES "ESSBASE_CALC" ("ID") ENABLE
/

ALTER TABLE "ESSBASE_NODE" ADD CONSTRAINT "FK_ESSBASE_NODE_ESSBASE_FILTER" FOREIGN KEY ("ESSBASE_FILTER")
	  REFERENCES "ESSBASE_FILTER" ("ID") ENABLE
/

ALTER TABLE "ESSBASE_NODE" ADD CONSTRAINT "FK_ESSBASE_NODE_ESSBASE_USER" FOREIGN KEY ("ESSBASE_USER")
	  REFERENCES "ESSBASE_USER_GROUP" ("ID") ENABLE
/

ALTER TABLE "ESSBASE_OBJECT" ADD CONSTRAINT "FK_ESSBASE_OBJECT_ESSBASE_APPL" FOREIGN KEY ("ESSBASE_APPLICATION")
	  REFERENCES "ESSBASE_APPLICATION" ("ID") ENABLE
/

ALTER TABLE "ESSBASE_OBJECT" ADD CONSTRAINT "FK_ESSBASE_OBJECT_ESSBASE_CUBE" FOREIGN KEY ("ESSBASE_CUBE")
	  REFERENCES "ESSBASE_DATABASE" ("ID") ENABLE
/

ALTER TABLE "ESSBASE_OBJECT" ADD CONSTRAINT "FK_ESSBASE_OBJECT_ESSBASE_USER" FOREIGN KEY ("ESSBASE_USER")
	  REFERENCES "ESSBASE_USER_GROUP" ("ID") ENABLE
/

ALTER TABLE "ESSBASE_RELATED_USER_GROUPS" ADD CONSTRAINT "ESSBASE_RELATED_USER_GROUPS_RE" FOREIGN KEY ("RELATED_USER_GROUP_ID")
	  REFERENCES "ESSBASE_USER_GROUP" ("ID") ENABLE
/

ALTER TABLE "ESSBASE_RELATED_USER_GROUPS" ADD CONSTRAINT "FK_ESSBASE_RELATED_USER_GROUPS" FOREIGN KEY ("USER_GROUP_ID")
	  REFERENCES "ESSBASE_USER_GROUP" ("ID") ENABLE
/

ALTER TABLE "ESSBASE_ROW" ADD CONSTRAINT "FK_ESSBASE_ROW_ESSBASE_FILTER" FOREIGN KEY ("ESSBASE_FILTER")
	  REFERENCES "ESSBASE_FILTER" ("ID") ENABLE
/

ALTER TABLE "ESSBASE_SUBSTITUTION_VARIABLE" ADD CONSTRAINT "ESSBASE_SUBSTITUTION_VARIABLE_" FOREIGN KEY ("ESSBASE_APPLICATION")
	  REFERENCES "ESSBASE_APPLICATION" ("ID") ENABLE
/

ALTER TABLE "ESSBASE_SUBSTITUTION_VARIABLE" ADD CONSTRAINT "FK_ESSBASE_SUBSTITUTION_VARIAB" FOREIGN KEY ("ESSBASE_CUBE")
	  REFERENCES "ESSBASE_DATABASE" ("ID") ENABLE
/

ALTER TABLE "ESSBASE_USER_GROUP" ADD CONSTRAINT "FK_ESSBASE_USER_GROUP_OWNER" FOREIGN KEY ("OWNER")
	  REFERENCES "ESSBASE_USER_GROUP" ("ID") ENABLE
/

ALTER TABLE "ESSBASE_USER_ROLES" ADD CONSTRAINT "FK_ESSBASE_USER_ROLES_ESSBASE_" FOREIGN KEY ("ESSBASE_APPLICATION")
	  REFERENCES "ESSBASE_APPLICATION" ("ID") ENABLE
/

ALTER TABLE "ESSBASE_USER_ROLES" ADD CONSTRAINT "FK_ESSBASE_USER_ROLES_ESSBAS_1" FOREIGN KEY ("ESSBASE_CUBE")
	  REFERENCES "ESSBASE_DATABASE" ("ID") ENABLE
/

ALTER TABLE "ESSBASE_USER_ROLES" ADD CONSTRAINT "FK_ESSBASE_USER_ROLES_ROLE_ID" FOREIGN KEY ("ROLE_ID")
	  REFERENCES "ESSBASE_ROLES" ("ID") ENABLE
/

ALTER TABLE "ESSBASE_USER_ROLES" ADD CONSTRAINT "FK_ESSBASE_USER_ROLES_USER_GRO" FOREIGN KEY ("USER_GROUP")
	  REFERENCES "ESSBASE_USER_GROUP" ("ID") ENABLE
/

INSERT INTO ESSBASE_USER_GROUP (ID, JAGENT_ID,IS_MIGRATED,FAILCOUNT,SALTED_DIGEST,PLATFORM_TOKEN,VERSION_ID,EMAIL_ID,DESCRIPTION,NUM_WARNING,USER_GROUP_NAME,IS_GROUP,PWD_CHANGE_NEEDED,LICENSE_TYPE,LAST_PASSWORD_CHANGE,EXPIRATION,CONNPARAM,DELETED,AUTHENTICATION_TYPE,USER_GROUP_ACCESS,CREATION_DATE,LAST_LOGIN,LOCKED_OUT,LAST_MODIFIED_DATE,PASSWORD_EXPIRED_TIME,PROVISIONING_STATUS,OWNER,ACCESS_VALUE) VALUES ('PRIMODIAL_AGENT_ID_BOOTSTRAP_ID','PRIMODIAL_AGENT_ID',0,0,'sQnzu7wkTrgkQZF+0G1hi5AI3Qmzvv0bXgc5THBqi7mAsdd4Xll27ASbRt9fEyavWi6m0QP9B8lT\nhf+rDKy8hg==____LawwcxnvjrHG+Bj/yY7Pu1HK/J8Zz6KjhHnmC5opDlwve7GKbkJQmNgPg5F/wP1jrA7D3nNhHvFcjeJIwp4q8A==',-22,1637,'admin@jagent.com','Administrator',0,'admin',0,0,32,CURRENT_TIMESTAMP,NULL,'1',0,'INTERNAL',1,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,0,CURRENT_TIMESTAMP,NULL,1,'PRIMODIAL_AGENT_ID_BOOTSTRAP_ID',65535)
/

INSERT INTO ESSBASE_AGENT_RUNTIME (ID,CREATION_DATE,AGENT_HOST,AGENT_PORT,AGENT_SECUREPORT,LAST_MODIFIED_DATE,VERSION_ID) VALUES ('PRIMODIAL_AGENT_ID',CURRENT_TIMESTAMP,'localhost','-1','-1',CURRENT_TIMESTAMP,10812)
/

INSERT INTO ESSBASE_GLOBAL (ID,JAGENT_ID,PASSWORD_STORED_COUNT,LOGINS_ENABLED,INACTIVITY_TIME,PASSWORD_EXPIRY_WARN_COUNT,VERSION_ID,ADMINSVC_LOCATION,CURRENCY_ENABLED,INVALID_ATTEMPTS,DEFAULT_ACCESS_LEVEL,SECURITY_MODE,INACTIVITY_CHECK,ESB_LANGUAGE,HOSTNAME,ESB_LOCATION,SECURITY_ENABLED,PASSWORD_VALIDITY,CREATION_DATE,PASSWORD_MIN_LENGTH,INVALID_LOCKOUT,SSS_NAME,LAST_MODIFIED_DATE,PRODUCT_CODE_VERSION,CSS_MIGRATED,HUB_REG_SEQUENCE_NUM,LOCALE_CONFIG) VALUES 
 ('29003b00-b388-11e0-aff2-0800200c9a66','PRIMODIAL_AGENT_ID',6,1,3600,1,20,'',0,0,'SYSTEM_LEVEL_NONE','EPM',300,'','','',1,0,CURRENT_TIMESTAMP,6,0,'',CURRENT_TIMESTAMP,'11.1.2',0,0,1)
/

COMMIT
/

COMMIT
/

COMMIT
/

ALTER SESSION SET CURRENT_SCHEMA = TESTONE_BIPLATFORM ;
CREATE TABLE "CDS_LOAD_STATUS"

  (

    "SERVER"      VARCHAR2(100 BYTE) NOT NULL ENABLE,

    "APPLICATION" VARCHAR2(100 BYTE) NOT NULL ENABLE,

    "DATABASE"    VARCHAR2(100 BYTE) NOT NULL ENABLE,

    "OBJECT" BLOB,

    "DATA_LOAD" NUMBER(1,0) NOT NULL ENABLE,

    CONSTRAINT "CDS_LOAD_STATUS_PK" PRIMARY KEY ("SERVER", "APPLICATION", "DATABASE", "DATA_LOAD"))
/

CREATE TABLE "CDS_OBJECT"

    (

      "SERVER"      VARCHAR2(100 BYTE) NOT NULL ENABLE,

      "APPLICATION" VARCHAR2(100 BYTE) NOT NULL ENABLE,

      "DATABASE"    VARCHAR2(100 BYTE) NOT NULL ENABLE,

      "TYPE"    NUMBER NOT NULL ENABLE,

      "OBJECT" BLOB,

      CONSTRAINT "CDS_OBJ_PK" PRIMARY KEY ("SERVER", "APPLICATION","DATABASE","TYPE"))
/

ALTER SESSION SET CURRENT_SCHEMA = TESTONE_BIPLATFORM ;
CREATE TABLE "BIPAT_TASKS" 
   ("ID" NUMBER(19) NOT NULL PRIMARY KEY, 
	"COMMAND" VARCHAR2(512) NULL, 
	"CREATED_TIME" TIMESTAMP NOT NULL, 
	"END_TIME" TIMESTAMP NULL, 
	"ESB_SESSION" NUMBER(19) NULL, 
	"NAME" VARCHAR2(255) NOT NULL, 
	"RETRY_COUNT" NUMBER(10) NULL, 
	"START_TIME" TIMESTAMP NULL, 
	"STATUS" VARCHAR2(255) NOT NULL, 
	"TYPE" VARCHAR2(255) NOT NULL, 
	"USER_NAME" VARCHAR2(255) NOT NULL, 
	"VERSION" NUMBER(10) NULL 
	) SEGMENT CREATION IMMEDIATE
	PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  
/

CREATE TABLE "BIPAT_TASK_CONN_INFO" 
("CONN_INFO" VARCHAR2(255) NOT NULL,
 "IS_TARGET" NUMBER(5) NOT NULL, 
 "TASK_ID" NUMBER(19) NOT NULL PRIMARY KEY
 ) SEGMENT CREATION IMMEDIATE
	PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  
/

CREATE TABLE "BIPAT_TASK_MESSAGES"
 ("MESSAGE" VARCHAR2(255) NULL,
  "TASK_ID" NUMBER(19) NOT NULL PRIMARY KEY
  ) SEGMENT CREATION IMMEDIATE
	PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  
/

CREATE TABLE "BIPAT_TASK_ID_TAB_GEN"
 ("PRIMARY_KEY_NAME" VARCHAR2(50) NOT NULL PRIMARY KEY,
  "NEXT_ID_VALUE" NUMBER(38) NULL
  )SEGMENT CREATION IMMEDIATE
	PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  
/

ALTER TABLE "BIPAT_TASK_MESSAGES" ADD CONSTRAINT "FK_TASK_MESSAGES_TASK_ID" 
		FOREIGN KEY ("TASK_ID") REFERENCES "BIPAT_TASKS"("ID") ENABLE
/

ALTER TABLE "BIPAT_TASK_CONN_INFO" ADD CONSTRAINT "FK_TASK_CONN_INFO_TASK_ID" 
		FOREIGN KEY ("TASK_ID") REFERENCES "BIPAT_TASKS" ("ID") ENABLE
/

UPDATE SYSTEM.SCHEMA_VERSION_REGISTRY SET status='VALID', modified=CURRENT_TIMESTAMP WHERE comp_id='BIPLATFORM' AND mrc_name='TESTONE'
/

---------------------------------------------------------
---------- BIPLATFORM(Business Intelligence Platform) SECTION ENDS ----------
---------------------------------------------------------


EXIT;