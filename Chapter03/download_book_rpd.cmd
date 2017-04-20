@ECHO OFF

@REM WARNING: This file is created by the Configuration Wizard.
@REM Any changes to this script may be lost when adding extensions to this configuration.

SETLOCAL

cd C:\Dropbox\obiee_12c_book\system\obiee_book\

set DOMAIN_HOME=C:\fmw_book\Oracle_home\user_projects\domains\bi

call "C:\fmw_book\Oracle_home\bi\modules\oracle.bi.commandline.tools\scripts\datamodel.cmd" downloadrpd -O obiee_book_20161013.rpd -W Obiee=123 -U biadmin -P Obiee_123 -SI ssi -S localhost -Y

ENDLOCAL