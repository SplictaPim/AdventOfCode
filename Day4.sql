------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- Prepare data
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
DECLARE @CrLf CHAR(2) = CHAR(13) + CHAR(10)
DECLARE @BulkColumn VARCHAR(max)
DECLARE @CurrentCardId int = 1
DECLARE @MaxCardId int
DECLARE @AddCard int
DECLARE @WinningCards int

DROP TABLE IF EXISTS [Input].[Day4]
DROP TABLE IF EXISTS #input
DROP TABLE IF EXISTS [dbo].[Day4WinningNumber]
DROP TABLE IF EXISTS [dbo].[Day4GivenNumber]
DROP TABLE IF EXISTS [dbo].[Day4TotalCards]

CREATE TABLE [dbo].[Day4WinningNumber] (
	[CardId] varchar(20) NOT NULL,
	[WinningNumber] int NOT NULL
)
CREATE TABLE [dbo].[Day4GivenNumber] (
	[CardId] varchar(20) NOT NULL,
	[GivenNumber] int NOT NULL
)
CREATE TABLE [dbo].[Day4TotalCards] (
	[CardId] int NOT NULL,
	[WinningCards] int NULL,
	[Total] int NULL
)
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- Read file into table
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
SELECT @BulkColumn = replace(BulkColumn, @CrLf, '~')
FROM OPENROWSET(BULK 'C:\Users\**\Day4.txt', SINGLE_CLOB) MyFile

SELECT REPLACE([value], '|', '|' + SUBSTRING([value], 1, CHARINDEX(':', [value]))) AS [Substring]
INTO #input
FROM string_split(@BulkColumn, '~')
WHERE [value] != ''
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- Parse data into a winning numbers table and a given numbers table
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
INSERT INTO [dbo].[Day4WinningNumber] ([CardId], [WinningNumber])
SELECT [CardId], TRY_CONVERT(int, [value])
FROM (
	SELECT REPLACE(SUBSTRING(SUBSTRING([Substring], 1, CHARINDEX('|', [Substring]) - 1), 1, CHARINDEX(':', [Substring]) - 1), ' ', '') AS [CardId]
		,SUBSTRING(SUBSTRING([Substring], 1, CHARINDEX('|', [Substring]) - 1), CHARINDEX(':', [Substring]) + 1, CHARINDEX('|', [Substring])) AS [WinningNumber]
		, [Substring]
	FROM #input
) A
CROSS APPLY string_split(A.[WinningNumber], ' ')
WHERE [Value] != ''

INSERT INTO [dbo].[Day4GivenNumber] ([CardId], [GivenNumber])
SELECT [CardId], convert(int, [value])
FROM (
	SELECT 
		REPLACE(SUBSTRING(SUBSTRING([Substring], CHARINDEX('|', [Substring]) + 1, LEN([Substring])), 1, CHARINDEX(':', [Substring]) - 1), ' ', '') AS [CardId]
		,SUBSTRING(SUBSTRING([Substring], CHARINDEX('|', [Substring]) + 1, LEN([Substring])), CHARINDEX(':', [Substring]) + 1, LEN([Substring])) AS [GivenNumber]
	, [Substring]
	FROM #input
) A
CROSS APPLY string_split(A.[GivenNumber], ' ')
WHERE [value] != ''
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- Part 1: 23941
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
;WITH NrWinningNumber AS (
	SELECT [CardId], MAX([NumberWinningTicket]) AS [NumberWinningTicket]
	FROM(
	SELECT t1.[CardId], t1.[WinningNumber]
		  ,ROW_NUMBER() OVER (PARTITION BY t1.[CardId] ORDER BY [WinningNumber]) AS [NumberWinningTicket]
	FROM [dbo].[Day4WinningNumber] t1
	INNER JOIN [dbo].[Day4GivenNumber] t2
		ON t2.[CardId] = t1.[CardId]
		AND t2.[GivenNumber] = t1.[WinningNumber]
	) A
	GROUP BY [CardId]
)
SELECT SUM(POWER(2, [NumberWinningTicket]-1))
FROM NrWinningNumber
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- Part 2:
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- Create table to perform calculations
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
;WITH NrWinningNumber AS (
	SELECT CONVERT(int, REPLACE([CardId], 'Card', '')) AS [CardId]
		  ,MAX([NumberWinningTicket]) AS [NumberWinningTicket]
	FROM(
		SELECT t1.[CardId], t1.[WinningNumber]
			  ,ROW_NUMBER() OVER (PARTITION BY t1.[CardId] ORDER BY [WinningNumber]) AS [NumberWinningTicket]
		FROM [dbo].[Day4WinningNumber] t1
		INNER JOIN [dbo].[Day4GivenNumber] t2
			ON t2.[CardId] = t1.[CardId]
			AND t2.[GivenNumber] = t1.[WinningNumber]
	) A
	GROUP BY [CardId]
)
INSERT INTO [dbo].[Day4TotalCards] ([CardId], [WinningCards], [Total])
SELECT DISTINCT CONVERT(int, REPLACE(t1.[CardId], 'Card', '')) AS [CardId]
	  ,ISNULL(t2.[NumberWinningTicket], 0) AS [NumberWinningTicket]
	  ,1 AS [Total]
FROM [dbo].[Day4WinningNumber] t1
FULL OUTER JOIN NrWinningNumber t2
	ON t2.[CardId] = CONVERT(int, REPLACE(t1.[CardId], 'Card', ''))
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- Calculate running ticket numbers
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
SET @MaxCardId = (select max([CardId]) from [Day4TotalCards]) 

WHILE @CurrentCardId <= @MaxCardId
BEGIN
	
	SET @AddCard = (select [Total] from  [dbo].[Day4TotalCards] where [CardId] = @CurrentCardId)
	SET @WinningCards = (select [WinningCards] from  [dbo].[Day4TotalCards] where [CardId] = @CurrentCardId)

	UPDATE [dbo].[Day4TotalCards]
	SET [Total] += @AddCard
	WHERE [CardId] > @CurrentCardId
		AND [CardId] <= @CurrentCardId + @WinningCards

	SET @CurrentCardId += 1
END
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- Final answer
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
SELECT SUM([Total])
FROM [dbo].[Day4TotalCards]
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------