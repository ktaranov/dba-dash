﻿CREATE PARTITION FUNCTION PF_SessionWaits(DATETIME2 (7))
    AS RANGE RIGHT
    FOR VALUES ()