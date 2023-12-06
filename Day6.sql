------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- Prepare data
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
DECLARE @CrLf CHAR(2) = CHAR(13) + CHAR(10)
DECLARE @BulkColumn VARCHAR(max)
DECLARE @Race bigint
DECLARE @PressButton bigint
DECLARE @Time bigint
DECLARE @Distance bigint
DECLARE @Try bigint
DECLARE @RaceNumber bigint

DROP TABLE IF EXISTS #Input
DROP TABLE IF EXISTS #Race

CREATE TABLE #Race (
	[RaceNumber] int NOT NULL,
	[Time] int NOT NULL,
	[Distance] bigint NOT NULL,
	[Try] int NULL
)
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- Read file into table
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
SELECT @BulkColumn = replace(BulkColumn, @CrLf, '~')
FROM OPENROWSET(BULK 'C:\Users**\input\Day6.txt', SINGLE_CLOB) MyFile

SELECT [value] AS [Rows]
INTO #input
FROM string_split(@BulkColumn, '~')
WHERE [value] != ''
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- Part 1: 
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
;WITH RaceTime AS (
	SELECT ROW_NUMBER() OVER(ORDER BY (select NULL)) AS [RaceNumber]
		,TRY_CONVERT(int, [value]) AS [Time]
	FROM #input
	CROSS APPLY string_split([rows], ' ')
	WHERE [value] != ''
		AND [Rows] LIKE 'Time:%'
		AND TRY_CONVERT(int, [value]) IS NOT NULL
)
, [Distance] AS (
	SELECT ROW_NUMBER() OVER(ORDER BY (select NULL)) AS [RaceNumber]
		,TRY_CONVERT(int, [value]) AS [Distance]
	FROM #input
	CROSS APPLY string_split([rows], ' ')
	WHERE [value] != ''
		AND [Rows] LIKE 'Distance:%'
		AND TRY_CONVERT(int, [value]) IS NOT NULL
)
INSERT INTO #Race ([RaceNumber], [Time], [Distance], [Try])
SELECT t1.[RaceNumber], t1.[Time], t2.[Distance], 0
FROM RaceTime t1
INNER JOIN [Distance] t2
	ON t2.[RaceNumber] = t1.[RaceNumber]

DECLARE Race_cursor CURSOR FOR
SELECT [RaceNumber], [Time], [Distance], [Try]
FROM #Race

OPEN Race_cursor
FETCH NEXT FROM Race_cursor
INTO @RaceNumber, @Time, @Distance, @Try

WHILE @@FETCH_STATUS = 0
BEGIN
	
	SET @Race = 0

	WHILE @Race <= @Time
	BEGIN
	
		SET @PressButton = @Time - @Race
		
		IF (SELECT @PressButton * (@Time - @PressButton)) > @Distance
		BEGIN 
			SET @Try += 1
		END
	
		SET @Race += 1
	END 

	UPDATE #Race
	SET [Try] = @Try
	WHERE [RaceNumber] = @RaceNumber

	FETCH NEXT FROM Race_cursor
	INTO @RaceNumber, @Time, @Distance, @Try
END

CLOSE Race_cursor
DEALLOCATE Race_cursor
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- Final Answer:
SELECT ROUND(EXP(SUM(LOG([Try]))),1) FROM #Race
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- Part 2: 
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
TRUNCATE TABLE #Race

;WITH RaceTime AS (
	SELECT ROW_NUMBER() OVER(ORDER BY (select NULL)) AS [RaceNumber]
		,TRY_CONVERT(int, SUBSTRING(REPLACE([Rows], ' ', ''), CHARINDEX(':', REPLACE([Rows], ' ', '')) + 1, LEN([Rows]))) AS [Time]
	FROM #input
	WHERE [Rows] LIKE 'Time:%'
)
, [Distance] AS (
	SELECT ROW_NUMBER() OVER(ORDER BY (select NULL)) AS [RaceNumber]
		,TRY_CONVERT(bigint, SUBSTRING(REPLACE([Rows], ' ', ''), CHARINDEX(':', REPLACE([Rows], ' ', '')) + 1, LEN([Rows]))) AS [Distance]
	FROM #input
	WHERE [Rows] LIKE 'Distance:%'
)
INSERT INTO #Race ([RaceNumber], [Time], [Distance], [Try])
SELECT t1.[RaceNumber], t1.[Time], t2.[Distance], 0
FROM RaceTime t1
INNER JOIN [Distance] t2
	ON t2.[RaceNumber] = t1.[RaceNumber]


SET @Race = 0
SET @Try = 0
SET @Distance = (select [Distance] FROM #Race)
SET @Time = (select [Time] FROM #Race)

WHILE @Race <= @Time
BEGIN

	SET @PressButton = @Time - @Race
	
	IF (SELECT @PressButton * (@Time - @PressButton)) > @Distance
	BEGIN 
		SET @Try += 1
	END

	SET @Race += 1
END 
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- Finale Answer:
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
SELECT @Try
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------