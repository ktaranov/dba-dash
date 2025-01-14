﻿CREATE PROC dbo.WaitsSummary_Get(
	@InstanceID INT,
	@FromDate DATETIME2(2),
	@ToDate DATETIME2(2),
	@Use60MIN BIT=NULL
)
AS
IF @Use60MIN IS NULL
BEGIN
	SELECT @Use60MIN = CASE WHEN DATEDIFF(hh,@FromDate,@ToDate)>24 THEN 1
						WHEN DATEPART(mi,@FromDate)+DATEPART(s,@FromDate)+DATEPART(ms,@FromDate)=0 
							AND (DATEPART(mi,@ToDate)+DATEPART(s,@ToDate)+DATEPART(ms,@ToDate)=0 
									OR @ToDate>=DATEADD(s,-2,GETUTCDATE())
								)
						THEN 1
						ELSE 0 END
END
DECLARE @SQL NVARCHAR(MAX)
SET @SQL = N'
SELECT  WT.WaitType,
		WT.Description,
		SUM(W.wait_time_ms)/1000.0 AS TotalWaitSec,
		SUM(W.signal_wait_time_ms)/1000.0 AS SignalWaitSec,
		SUM(W.signal_wait_time_ms*1.0)/NULLIF(SUM(W.wait_time_ms),0) AS SignalWaitPct,
		SUM(W.wait_time_ms)/NULLIF(MAX(SUM(W.sample_ms_diff/1000.0)) OVER(),0) WaitTimeMsPerSec,
		SUM(W.wait_time_ms)/NULLIF(MAX(SUM(W.sample_ms_diff/1000.0)) OVER(),0)/I.scheduler_count WaitTimeMsPerCorePerSec,
		SUM(W.waiting_tasks_count) as WaitingTasksCount,
		SUM(W.wait_time_ms)/ISNULL(NULLIF(SUM(W.waiting_tasks_count),0.0),1.0) AS AvgWaitTimeMs,
		MAX(SUM(CAST(W.sample_ms_diff AS BIGINT))/1000) OVER() SampleDurationSec,
		MAX(CAST(WT.IsCriticalWait AS INT)) CriticalWait,
		I.scheduler_count
FROM dbo.Waits' + CASE WHEN @Use60MIN=1 THEN '_60MIN' ELSE '' END  + ' W
JOIN dbo.WaitType WT ON WT.WaitTypeID = W.WaitTypeID
JOIN dbo.Instances I ON I.InstanceID = W.InstanceID
WHERE W.InstanceID=@InstanceID
AND W.SnapshotDate>=@FromDate
AND W.SnapshotDate<@ToDate
AND WT.IsExcluded=0
GROUP BY WT.WaitType,I.scheduler_count,WT.Description
ORDER BY WaitTimeMsPerSec DESC'

EXEC sp_executesql @SQL,N'@InstanceID INT,@FromDate DATETIME2(2),@ToDate DATETIME2(2)',@InstanceID,@FromDate,@ToDate