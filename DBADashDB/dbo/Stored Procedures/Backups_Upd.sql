﻿CREATE PROC dbo.Backups_Upd(
	@Backups Backups READONLY,
	@InstanceID INT,
	@SnapshotDate DATETIME2(2)
)
AS
SET XACT_ABORT ON
DECLARE @Ref VARCHAR(30)='Backups'
IF NOT EXISTS(SELECT 1 FROM dbo.CollectionDates WHERE SnapshotDate>=@SnapshotDate AND InstanceID = @InstanceID AND Reference=@Ref)
BEGIN
	BEGIN TRAN

	DELETE B 
	FROM dbo.Backups B 
	WHERE EXISTS(
		SELECT 1
		FROM @Backups t 
		JOIN dbo.Databases d ON d.name = t.database_name
		AND d.IsActive=1
		AND d.InstanceID=@InstanceID
		AND B.DatabaseID = d.DatabaseID
		AND B.type = t.type
		) 

	INSERT INTO dbo.Backups(DatabaseID,
					type,
					backup_start_date,
					backup_finish_date,
					backup_set_id,
					time_zone,
					backup_size,
					is_password_protected,
					recovery_model,
					has_bulk_logged_data,
					is_snapshot,
					is_readonly,
					is_single_user,
					has_backup_checksums,
					is_damaged,
					has_incomplete_metadata,
					is_force_offline,
					is_copy_only,
					database_guid,
					family_guid,
					compressed_backup_size,
					key_algorithm,
					encryptor_type)
	SELECT			d.DatabaseID,
					t.type,
					t.backup_start_date,
					t.backup_finish_date,
					t.backup_set_id,
					t.time_zone,
					t.backup_size,
					t.is_password_protected,
					t.recovery_model,
					t.has_bulk_logged_data,
					t.is_snapshot,
					t.is_readonly,
					t.is_single_user,
					t.has_backup_checksums,
					t.is_damaged,
					t.has_incomplete_metadata,
					t.is_force_offline,
					t.is_copy_only,
					t.database_guid,
					t.family_guid,
					t.compressed_backup_size,
					t.key_algorithm,
					t.encryptor_type 
	FROM @Backups t 
	JOIN dbo.Databases d ON d.name = t.database_name
	AND d.IsActive=1
	AND d.InstanceID=@InstanceID

	EXEC dbo.CollectionDates_Upd @InstanceID = @InstanceID,  
	                             @Reference = @Ref,
	                             @SnapshotDate = @SnapshotDate
	COMMIT
END
	