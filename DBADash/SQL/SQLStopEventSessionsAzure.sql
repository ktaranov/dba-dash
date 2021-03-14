﻿IF EXISTS(
	SELECT * 
	FROM sys.dm_xe_database_sessions
	WHERE name = 'DBADash_1'
	)
BEGIN
	ALTER EVENT SESSION DBADash_1
	ON DATABASE
	State = STOP
END
IF EXISTS(
	SELECT * 
	FROM sys.dm_xe_database_sessions
	WHERE name = 'DBADash_2'
	)
BEGIN
	ALTER EVENT SESSION DBADash_2
	ON DATABASE
	State = STOP
END