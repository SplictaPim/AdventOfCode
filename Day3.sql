USE [AdventOfCode]
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- Prepare data
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS #GameRow
DROP TABLE IF EXISTS #SubGame
DROP TABLE IF EXISTS #Input
DROP TABLE IF EXISTS [Input].[Day3]
DROP TABLE IF EXISTS [Input].[Day3Part]

CREATE TABLE [Input].[Day3] (
	[EngineLineId] int IDENTITY(1,1) NOT NULL,
	[EngineLine] varchar(1000) NOT NULL
)

CREATE TABLE [Input].[Day3Part] (
	[EngineLineId] int NOT NULL,
	[EnginePart] int NOT NULL,
	[PositionInvalidChar] int NOT NULL
)

DECLARE @CrLf CHAR(2) = CHAR(13) + CHAR(10)
DECLARE @BulkColumn VARCHAR(max)
DECLARE @MaxLine int = 0
DECLARE @CurrentLine int = 1
DECLARE @InvalidChar varchar(50) = '%[^a-zA-Z0-9.]%'
DECLARE @EndChar varchar(50) = '%[^0-9]%'
DECLARE @PositionInvalidChar int
DECLARE @MaxPositionInvalidChar int

SELECT @BulkColumn = replace(BulkColumn, char(10), '~')
FROM OPENROWSET(BULK 'C:\Users\***\Input\Day3.txt', SINGLE_CLOB) MyFile

INSERT INTO [Input].[Day3] ([EngineLine])
SELECT [value]
FROM string_split(@BulkColumn, '~')

SET @MaxLine = (select max(EngineLineId) from [Input].[Day3])

WHILE @CurrentLine <= @MaxLine
BEGIN

	SET @PositionInvalidChar = 
		(SELECT PATINDEX(@InvalidChar, [engineline]) AS [PositionInvalidChar]
		FROM [Input].[Day3]
		WHERE [EngineLineId] = @CurrentLine
		)
	SET @MaxPositionInvalidChar = 
	(SELECT LEN([Engineline]) - PATINDEX(@InvalidChar, REVERSE([engineline]))+ 1 AS [PositionInvalidChar]
		FROM [Input].[Day3]
		WHERE [EngineLineId] = @CurrentLine
	)

	SET @PositionInvalidChar = (select IIF(@PositionInvalidChar = 0 , (select LEN([Engineline]) FROM [Input].[Day3]
		WHERE [EngineLineId] = @CurrentLine) + 1 , @PositionInvalidChar))

	WHILE @PositionInvalidChar <= @MaxPositionInvalidChar
	BEGIN

		DECLARE @intLeftAbove	int = (SELECT TRY_CONVERT(int, SUBSTRING([engineline], @PositionInvalidChar - 1, 1)) FROM [Input].[Day3] WHERE [EngineLineId] = @CurrentLine - 1)
		DECLARE @intMiddleAbove int = (SELECT TRY_CONVERT(int, SUBSTRING([engineline], @PositionInvalidChar, 1)) FROM [Input].[Day3] WHERE [EngineLineId] = @CurrentLine - 1)
		DECLARE @intRightAbove	int = (SELECT TRY_CONVERT(int, SUBSTRING([engineline], @PositionInvalidChar + 1, 1)) FROM [Input].[Day3] WHERE [EngineLineId] = @CurrentLine - 1)
		DECLARE @intLeftUnder	int = (SELECT TRY_CONVERT(int, SUBSTRING([engineline], @PositionInvalidChar - 1, 1)) FROM [Input].[Day3] WHERE [EngineLineId] = @CurrentLine + 1)
		DECLARE @intMiddleUnder int = (SELECT TRY_CONVERT(int, SUBSTRING([engineline], @PositionInvalidChar, 1)) FROM [Input].[Day3] WHERE [EngineLineId] = @CurrentLine + 1)
		DECLARE @intRightUnder	int = (SELECT TRY_CONVERT(int, SUBSTRING([engineline], @PositionInvalidChar + 1, 1)) FROM [Input].[Day3] WHERE [EngineLineId] = @CurrentLine + 1)
		DECLARE @intLeft		int = (SELECT TRY_CONVERT(int, SUBSTRING([engineline], @PositionInvalidChar - 1, 1)) FROM [Input].[Day3] WHERE [EngineLineId] = @CurrentLine)
		DECLARE @intRight		int = (SELECT TRY_CONVERT(int, SUBSTRING([engineline], @PositionInvalidChar + 1, 1)) FROM [Input].[Day3] WHERE [EngineLineId] = @CurrentLine)
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------	 
-- left above
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
		IF @intLeftAbove >= 0 AND @intMiddleAbove IS NULL
		BEGIN
			INSERT INTO [Input].[Day3Part] ([EngineLineId], [EnginePart], [PositionInvalidChar])
			SELECT @CurrentLine
				  ,REVERSE(SUBSTRING(REVERSE(SUBSTRING([Engineline], 1, @PositionInvalidChar - 1)), 1, IIF(PATINDEX(@EndChar, REVERSE(SUBSTRING([Engineline], 1, @PositionInvalidChar - 1))) = 0, @PositionInvalidChar, PATINDEX(@EndChar, REVERSE(SUBSTRING([Engineline], 1, @PositionInvalidChar - 1))))-1 ))
				  ,@PositionInvalidChar
			FROM [Input].[Day3]
			WHERE [EngineLineId] = @CurrentLine - 1
		END 
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- left under
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
		IF @intLeftUnder >= 0 AND @intMiddleUnder IS NULL
		BEGIN
			INSERT INTO [Input].[Day3Part] ([EngineLineId], [EnginePart], [PositionInvalidChar])
			SELECT @CurrentLine
				  ,REVERSE(SUBSTRING(REVERSE(SUBSTRING([Engineline], 1, @PositionInvalidChar - 1)), 1, IIF(PATINDEX(@EndChar, REVERSE(SUBSTRING([Engineline], 1, @PositionInvalidChar - 1))) = 0, @PositionInvalidChar, PATINDEX(@EndChar, REVERSE(SUBSTRING([Engineline], 1, @PositionInvalidChar - 1))))-1 ))
				  ,@PositionInvalidChar
			FROM [Input].[Day3]
			WHERE [EngineLineId] = @CurrentLine + 1
		END 
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- right above
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
		IF @intRightAbove >= 0 AND @intMiddleAbove IS NULL
		BEGIN
			INSERT INTO [Input].[Day3Part] ([EngineLineId], [EnginePart], [PositionInvalidChar])
			SELECT @CurrentLine
				  ,SUBSTRING([EngineLine], @PositionInvalidChar + 1, IIF(PATINDEX(@EndChar, SUBSTRING([EngineLine], @PositionInvalidChar + 1, 4)) = 0, 3, PATINDEX(@EndChar, SUBSTRING([EngineLine], @PositionInvalidChar + 1, 4)) -1))
				  ,@PositionInvalidChar
			FROM [Input].[Day3]
			WHERE [EngineLineId] = @CurrentLine - 1
		END 
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- right under
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
		IF @intRightUnder >= 0 AND @intMiddleUnder IS NULL
		BEGIN 
			INSERT INTO [Input].[Day3Part] ([EngineLineId], [EnginePart], [PositionInvalidChar])
			SELECT @CurrentLine
				  ,SUBSTRING([EngineLine], @PositionInvalidChar + 1, IIF(PATINDEX(@EndChar, SUBSTRING([EngineLine], @PositionInvalidChar + 1, 4)) = 0, 3, PATINDEX(@EndChar, SUBSTRING([EngineLine], @PositionInvalidChar + 1, 4)) -1))
				  ,@PositionInvalidChar
			FROM [Input].[Day3]
			WHERE [EngineLineId] = @CurrentLine + 1
		END 
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- middle above
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
		IF @intMiddleAbove >= 0
		BEGIN
			IF @intLeftAbove IS NULL AND @intRightAbove >= 0
			BEGIN
				INSERT INTO [Input].[Day3Part] ([EngineLineId], [EnginePart], [PositionInvalidChar])
				SELECT @CurrentLine
					  ,SUBSTRING([EngineLine], @PositionInvalidChar, IIF(PATINDEX(@EndChar, SUBSTRING([EngineLine], @PositionInvalidChar, 4)) = 0, 3, PATINDEX(@EndChar, SUBSTRING([EngineLine], @PositionInvalidChar, 4)) -1))
				  ,@PositionInvalidChar
				FROM [Input].[Day3]
				WHERE [EngineLineId] = @CurrentLine - 1
			END
			IF @intRightAbove IS NULL AND @intLeftAbove >= 0
			BEGIN
				INSERT INTO [Input].[Day3Part] ([EngineLineId], [EnginePart], [PositionInvalidChar])
				SELECT @CurrentLine
					  ,REVERSE(SUBSTRING(REVERSE(SUBSTRING([Engineline], 1, @PositionInvalidChar)), 1, IIF(PATINDEX(@EndChar, REVERSE(SUBSTRING([Engineline], 1, @PositionInvalidChar))) = 0, @PositionInvalidChar, PATINDEX(@EndChar, REVERSE(SUBSTRING([Engineline], 1, @PositionInvalidChar))))-1 ))
				  ,@PositionInvalidChar
				FROM [Input].[Day3]
				WHERE [EngineLineId] = @CurrentLine - 1
			END
			IF @intRightAbove >= 0 AND @intLeftAbove >= 0
			BEGIN
				INSERT INTO [Input].[Day3Part] ([EngineLineId], [EnginePart], [PositionInvalidChar])
				SELECT @CurrentLine
					  ,SUBSTRING([EngineLine], @PositionInvalidChar - 1, 3)
				  ,@PositionInvalidChar
				FROM [Input].[Day3]
				WHERE [EngineLineId] = @CurrentLine - 1
			END
			IF @intRightAbove IS NULL AND @intLeftAbove IS NULL
			BEGIN
				INSERT INTO [Input].[Day3Part] ([EngineLineId], [EnginePart], [PositionInvalidChar])
				SELECT @CurrentLine
					  ,SUBSTRING([EngineLine], @PositionInvalidChar, 1)
				  ,@PositionInvalidChar
				FROM [Input].[Day3]
				WHERE [EngineLineId] = @CurrentLine - 1
			END
		END
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- middle under
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
		IF @intMiddleUnder >= 0
		BEGIN
			IF @intLeftUnder IS NULL AND @intRightUnder >= 0
			BEGIN
				INSERT INTO [Input].[Day3Part] ([EngineLineId], [EnginePart], [PositionInvalidChar])
				SELECT @CurrentLine
					  ,SUBSTRING([EngineLine], @PositionInvalidChar, IIF(PATINDEX(@EndChar, SUBSTRING([EngineLine], @PositionInvalidChar, 4)) = 0, 3, PATINDEX(@EndChar, SUBSTRING([EngineLine], @PositionInvalidChar, 4)) -1))
				  ,@PositionInvalidChar
				FROM [Input].[Day3]
				WHERE [EngineLineId] = @CurrentLine + 1
			END
			IF @intRightUnder IS NULL AND @intLeftUnder >=0
			BEGIN
				INSERT INTO [Input].[Day3Part] ([EngineLineId], [EnginePart], [PositionInvalidChar])
				SELECT @CurrentLine
					  ,REVERSE(SUBSTRING(REVERSE(SUBSTRING([Engineline], 1, @PositionInvalidChar)), 1, IIF(PATINDEX(@EndChar, REVERSE(SUBSTRING([Engineline], 1, @PositionInvalidChar))) = 0, @PositionInvalidChar, PATINDEX(@EndChar, REVERSE(SUBSTRING([Engineline], 1, @PositionInvalidChar ))))-1 ))
				  ,@PositionInvalidChar
				FROM [Input].[Day3]
				WHERE [EngineLineId] = @CurrentLine + 1
			END
			IF @intRightUnder >= 0 AND @intLeftUnder >= 0
			BEGIN
				INSERT INTO [Input].[Day3Part] ([EngineLineId], [EnginePart], [PositionInvalidChar])
				SELECT @CurrentLine
					  ,SUBSTRING([EngineLine], @PositionInvalidChar - 1, 3)
				  ,@PositionInvalidChar
				FROM [Input].[Day3]
				WHERE [EngineLineId] = @CurrentLine + 1
			END
			IF @intRightUnder IS NULL AND @intLeftUnder IS NULL
			BEGIN
				INSERT INTO [Input].[Day3Part] ([EngineLineId], [EnginePart], [PositionInvalidChar])
				SELECT @CurrentLine
					  ,SUBSTRING([EngineLine], @PositionInvalidChar, 1)
				  ,@PositionInvalidChar
				FROM [Input].[Day3]
				WHERE [EngineLineId] = @CurrentLine + 1
			END
		END
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- left
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
		IF @intLeft >= 0
		BEGIN
			INSERT INTO [Input].[Day3Part] ([EngineLineId], [EnginePart], [PositionInvalidChar])
			SELECT @CurrentLine
				  ,REVERSE(SUBSTRING(REVERSE(SUBSTRING([Engineline], 1, @PositionInvalidChar - 1)), 1, IIF(PATINDEX(@EndChar, REVERSE(SUBSTRING([Engineline], 1, @PositionInvalidChar - 1))) = 0, @PositionInvalidChar, PATINDEX(@EndChar, REVERSE(SUBSTRING([Engineline], 1, @PositionInvalidChar - 1))))-1 ))
				  ,@PositionInvalidChar
			FROM [Input].[Day3]
			WHERE [EngineLineId] = @CurrentLine
		END
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- Right
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
		IF @intRight >= 0
		BEGIN
			INSERT INTO [Input].[Day3Part] ([EngineLineId], [EnginePart], [PositionInvalidChar])
			SELECT @CurrentLine
				  ,SUBSTRING([EngineLine], @PositionInvalidChar + 1, IIF(PATINDEX(@EndChar, SUBSTRING([EngineLine], @PositionInvalidChar + 1, 4)) = 0, 3, PATINDEX(@EndChar, SUBSTRING([EngineLine], @PositionInvalidChar + 1, 4)) -1))
				  ,@PositionInvalidChar
			FROM [Input].[Day3]
			WHERE [EngineLineId] = @CurrentLine
		END
		
		SET @PositionInvalidChar += (SELECT IIF(PATINDEX(@InvalidChar, SUBSTRING([EngineLine], @PositionInvalidChar + 1, LEN([EngineLine]))) = 0, 1, PATINDEX(@InvalidChar, SUBSTRING([EngineLine], @PositionInvalidChar + 1, LEN([EngineLine]))))
		FROM [Input].[Day3]
		WHERE [EngineLineId] = @CurrentLine
		)

	END

	SET @CurrentLine += 1
END
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- Question 1: 532428
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
SELECT SUM([EnginePart])
FROM [Input].[Day3Part]
WHERE [EnginePart] != ''
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- Question 2: 84051670
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
SELECT SUM([1]*[2]) AS [TotalRatio]
FROM (
	SELECT [EngineLineId], [EnginePart], [PositionInvalidChar]
		 ,ROW_NUMBER() OVER(PARTITION BY [EngineLineId], [PositionInvalidChar] ORDER BY [EnginePart]) AS [Gear]
	FROM [Input].[Day3Part] ) p
	PIVOT (
		MAX([EnginePart])
		FOR [Gear] IN
			([1], [2])
		) AS pvt
WHERE [2] IS NOT NULL
ORDER BY [EngineLineId], [PositionInvalidChar]