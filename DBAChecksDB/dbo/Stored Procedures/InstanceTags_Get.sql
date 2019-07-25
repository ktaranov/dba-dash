﻿CREATE PROC InstanceTags_Get(@InstanceID INT)
AS
SELECT T.TagID,T.Tag,CASE WHEN IT.TagID IS NULL THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END AS Checked 
FROM dbo.Tags T
LEFT JOIN dbo.InstanceTag IT ON IT.TagID = T.TagID AND IT.InstanceID = @InstanceID
WHERE T.TagID>0
ORDER BY T.Tag