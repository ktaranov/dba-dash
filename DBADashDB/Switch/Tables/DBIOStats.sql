﻿CREATE TABLE [Switch].[DBIOStats] (
    [InstanceID]           INT           NOT NULL,
    [DatabaseID]           INT           NOT NULL,
    [Drive]                CHAR (1)      NOT NULL,
    [FileID]               INT           NOT NULL,
    [SnapshotDate]         DATETIME2 (2) NOT NULL,
    [num_of_reads]         BIGINT        NOT NULL,
    [num_of_writes]        BIGINT        NOT NULL,
    [num_of_bytes_read]    BIGINT        NOT NULL,
    [num_of_bytes_written] BIGINT        NOT NULL,
    [io_stall_read_ms]     BIGINT        NOT NULL,
    [io_stall_write_ms]    BIGINT        NOT NULL,
    [sample_ms_diff]       BIGINT        NOT NULL,
    [size_on_disk_bytes]   BIGINT        NOT NULL,
    [MaxIOPs]              AS            (([num_of_reads]+[num_of_writes])/([sample_ms_diff]/(1000.0))),
    [MaxReadIOPs]          AS            ([num_of_reads]/([sample_ms_diff]/(1000.0))),
    [MaxWriteIOPs]         AS            ([num_of_writes]/([sample_ms_diff]/(1000.0))),
    [MaxMBsec]             AS            ((([num_of_bytes_read]+[num_of_bytes_written])/power((1024.0),(2)))/([sample_ms_diff]/(1000.0))),
    [MaxReadMBsec]         AS            (([num_of_bytes_read]/power((1024.0),(2)))/([sample_ms_diff]/(1000.0))),
    [MaxWriteMBsec]        AS            (([num_of_bytes_written]/power((1024.0),(2)))/([sample_ms_diff]/(1000.0))),
    [MaxReadLatency]       AS            (isnull([io_stall_read_ms]/nullif([num_of_reads]*(1.0),(0)),(0))),
    [MaxWriteLatency]      AS            (isnull([io_stall_write_ms]/nullif([num_of_writes]*(1.0),(0)),(0))),
    [MaxLatency]           AS            (isnull(([io_stall_read_ms]+[io_stall_write_ms])/nullif([num_of_writes]+[num_of_reads]*(1.0),(0)),(0))),
    CONSTRAINT [PK_DBIOStats] PRIMARY KEY CLUSTERED ([InstanceID] ASC, [DatabaseID] ASC, [FileID] ASC, [Drive] ASC, [SnapshotDate] ASC) WITH (DATA_COMPRESSION = PAGE) 
) ;

