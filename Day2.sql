------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- Prepare data
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS #GameRow
DROP TABLE IF EXISTS #SubGame
DROP TABLE IF EXISTS #Input
DROP TABLE IF EXISTS [Input].[Day2]

CREATE TABLE [Input].[Day2] (
	[GameId] int NOT NULL,
	[InGameId] varchar(10) NOT NULL,
	[Quantity] int NOT NULL,
	[Color] varchar(5) NOT NULL
)

DECLARE @CrLf CHAR(2) = CHAR(13) + CHAR(10)
DECLARE @BulkColumn VARCHAR(max)

SELECT @BulkColumn = replace(BulkColumn, 'Game ', '~')
FROM OPENROWSET(BULK 'C:\Users\pim\OneDrive\Documenten\Training\Advent of Code\2023\Input\Day2.txt', SINGLE_CLOB) MyFile

;WITH GameRow AS (
	SELECT CONVERT(int, SUBSTRING([value], 1, CHARINDEX(':', [value])-1)) AS [GameId], 
		REPLACE([value], SUBSTRING([value], 1, CHARINDEX(':', [value])), '') AS [Game]
	FROM string_split(@BulkColumn, '~')
	WHERE [value] != ''
)
, Subgame AS (
	SELECT [GameId], [value] AS [SubGame], 
		convert(varchar(10), [GameId]) + '_' + CONVERT(varchar(10), ROW_NUMBER() OVER(PARTITION BY [GameId] ORDER BY (select NULL))) AS [InGameId]
	FROM GameRow
	CROSS APPLY string_split([Game], ';')
)
INSERT INTO [Input].[Day2] (
	[GameId],
	[InGameId],
	[Quantity],
	[Color]
)
SELECT [GameId], [InGameId]
	,convert(int, SUBSTRING([value], 1, CHARINDEX(' ', [value], PATINDEX('%[0-9]%', [value])))) AS [Quantity]
	,CASE 
		WHEN [value] LIKE '%blue%' THEN RTRIM(LTRIM((SUBSTRING([value], CHARINDEX(' ', [value], PATINDEX('%[0-9]%', [value])), 5)))) 
		WHEN [value] LIKE '%green%' THEN RTRIM(LTRIM((SUBSTRING([value], CHARINDEX(' ', [value], PATINDEX('%[0-9]%', [value])), 6)))) 
		WHEN [value] LIKE '%red%' THEN RTRIM(LTRIM((SUBSTRING([value], CHARINDEX(' ', [value], PATINDEX('%[0-9]%', [value])), 4)))) 		
	 END AS [Color]
FROM SubGame
CROSS APPLY string_split([SubGame], ',')
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- Question 1:
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
SELECT SUM([GameId])
FROM (
	SELECT DISTINCT [GameId]
	FROM [Input].[Day2]
	EXCEPT
	SELECT DISTINCT [GameId]
	FROM [Input].[Day2]
	WHERE 
		(Color = 'blue' and [Quantity] > 14) or
		(Color = 'red' and [Quantity] > 12) or
		(Color = 'green' and [Quantity] > 13) 
)A
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- Question 2:
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
SELECT [Sumpower] = SUM([green] * [blue] * [red])
FROM (  
	SELECT [GameId], [Quantity], [Color]
	FROM [Input].[Day2]) p  
	PIVOT (  
		MAX([Quantity])  
		FOR [Color] IN  
			([green], [blue], [red])  
	) AS pvt;