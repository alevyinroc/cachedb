SELECT * FROM OPENQUERY([SQLite3 Datasource], 'select * from caches') UNION ALL
SELECT * FROM OPENQUERY([GSAKMain], 'select * from caches') UNION ALL
SELECT * FROM OPENQUERY([Far-off puzzles], 'select * from caches') UNION ALL
SELECT * FROM OPENQUERY([Home200], 'select * from caches') UNION ALL
SELECT * FROM OPENQUERY([My Finds], 'select * from caches') UNION ALL
SELECT * FROM OPENQUERY([My Hides], 'select * from caches') UNION ALL
SELECT * FROM OPENQUERY([New England], 'select * from caches') UNION ALL
SELECT * FROM OPENQUERY([Niagara Falls], 'select * from caches') UNION ALL
SELECT * FROM OPENQUERY([NJ], 'select * from caches') UNION ALL
SELECT * FROM OPENQUERY([Seattle], 'select * from caches') 
