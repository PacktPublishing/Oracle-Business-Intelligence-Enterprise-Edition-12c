@ECHO OFF

@REM Uploads the main rpd
@REM 

SETLOCAL

cd C:\Dropbox\obiee_12c_book\system\obiee_book\

set DOMAIN_HOME=C:\fmw_book\Oracle_home\user_projects\domains\bi

call "C:\fmw_book\Oracle_home\bi\modules\oracle.bi.commandline.tools\scripts\datamodel.cmd" uploadrpd -I obiee_book.rpd -W Obiee=123 -U biadmin -P Obiee_123 -SI ssi -S localhost

ENDLOCAL