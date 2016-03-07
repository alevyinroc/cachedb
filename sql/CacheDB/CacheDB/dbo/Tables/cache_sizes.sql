﻿CREATE TABLE [dbo].[cache_sizes] (
    [sizeid]   INT          CONSTRAINT [DF_cachesizes_sizeid] DEFAULT (NEXT VALUE FOR [CacheSizeId]) NOT NULL,
    [sizename] VARCHAR (16) NULL,
    CONSTRAINT [PK_CacheSizes] PRIMARY KEY NONCLUSTERED ([sizeid] ASC)
);



