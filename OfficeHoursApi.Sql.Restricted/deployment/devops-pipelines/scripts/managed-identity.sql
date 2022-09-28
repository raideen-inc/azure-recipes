CREATE USER [$(newUserName)] WITH default_schema=[dbo], SID=$(identitySid), TYPE=[E];
GO
EXEC sp_addrolemember 'db_datawriter','$(newUserName)'
EXEC sp_addrolemember 'db_datareader','$(newUserName)'
EXEC sp_addrolemember 'db_ddladmin','$(newUserName)'
GO