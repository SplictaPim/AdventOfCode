------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- Prepare data
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
DECLARE @CrLf CHAR(2) = CHAR(13) + CHAR(10)
DECLARE @BulkColumn VARCHAR(max)
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS [input].[Hand]
DROP TABLE IF EXISTS [input].[HandType]
DROP TABLE IF EXISTS [input].[CardPart1]
DROP TABLE IF EXISTS [input].[CardPart2]

CREATE TABLE [input].[Hand] (
	[HandId] int NOT NULL,
	[Bid] int NOT NULL,
	[Hand] varchar(5) NOT NULL,
	[HandRank] int NULL,
	[CardRank] int NULL,
	[JokerHand] varchar(5) NULL,
	[JokerHandRank] int NULL,
	[JokerCardRank] int NULL
)

CREATE TABLE [input].[HandType] (
	[Description] varchar(20) NOT NULL,
	[Card1LabelAmount] int NOT NULL,
	[Card2LabelAmount] int NULL,
	[Rank] int NOT NULL
)

CREATE TABLE [input].[CardPart1] (
	[Card] varchar(1) NOT NULL,
	[Rank] int NOT NULL
)

CREATE TABLE [input].[CardPart2] (
	[Card] varchar(1) NOT NULL,
	[Rank] int NOT NULL
)
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- Read file into table
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
SELECT @BulkColumn = replace(BulkColumn, @CrLf, '~')
FROM OPENROWSET(BULK 'C:\Users\**\Day7.txt', SINGLE_CLOB) MyFile

INSERT INTO [input].[Hand] ([HandId], [Hand], [Bid])
SELECT ROW_NUMBER() OVER(ORDER BY (select NULL)) 
	,SUBSTRING([value], 1, CHARINDEX(' ', [value])- 1) 
	,CONVERT(int, REVERSE(SUBSTRING(REVERSE([value]), 1, CHARINDEX(' ', REVERSE([value]))- 1))) 
FROM string_split(@BulkColumn, '~')
WHERE [value] != ''
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- HandType
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
INSERT INTO [input].[HandType] ([Description], [Card1LabelAmount], [Card2LabelAmount], [Rank])
VALUES
('Five of a kind', 5, 0, 7),
('Four of a kind', 4, 1, 6),
('Full house', 3, 2, 5),
('Three of a kind', 3, 1, 4),
('Two pair', 2, 2, 3),
('One pair', 2, 1, 2),
('High card', 1, 1, 1)
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- Card
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
INSERT INTO [input].[CardPart1]([Card], [Rank])
VALUES
 ('A', 13),
 ('K', 12),
 ('Q', 11),
 ('J', 10),
 ('T', 9),
 ('9', 8),
 ('8', 7),
 ('7', 6),
 ('6', 5),
 ('5', 4),
 ('4', 3),
 ('3', 2),
 ('2', 1)

INSERT INTO [input].[CardPart2]([Card], [Rank])
VALUES
 ('A', 13),
 ('K', 12),
 ('Q', 11),
 ('J', 1),
 ('T', 10),
 ('9', 9),
 ('8', 8),
 ('7', 7),
 ('6', 6),
 ('5', 5),
 ('4', 4),
 ('3', 3),
 ('2', 2)
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- Rank by hand
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
;WITH handbycard AS ( 
	SELECT [HandId]
		  ,SUBSTRING([Hand], 1, 1) AS [Card1]
		  ,SUBSTRING([Hand], 2,1)	 AS [Card2]
		  ,SUBSTRING([Hand], 3,1)	 AS [Card3]
		  ,SUBSTRING([Hand], 4,1)	 AS [Card4]
		  ,SUBSTRING([Hand], 5,1)	 AS [Card5]
	FROM [input].[Hand]
)
, CountOccurence AS (
SELECT [HandId], [Card], COUNT([card]) AS [Count]
	,ROW_NUMBER() OVER(PARTITION BY [HandId] ORDER BY COUNT([Card]) DESC) AS [RowNumber]
FROM (
	SELECT [HandId]
		  ,[Card1]
		  ,[Card2]
		  ,[Card3]
		  ,[Card4]
		  ,[Card5]
	FROM handbycard) a
UNPIVOT
	([Card] FOR [Cards] IN
		([Card1], [Card2], [Card3], [Card4], [Card5])
	) as unpvt
GROUP BY [HandId], [Card]
)
UPDATE t3
SET [HandRank] = t2.[Rank]
--SELECT [HandId], [1] AS [Card1], [2] AS [Card2], t2.[Rank]
FROM (
	SELECT [HandId], [Count], [RowNumber] 
	FROM [CountOccurence]
	WHERE [RowNumber] <= 2 ) b
PIVOT
	( MAX([Count])
		FOR [RowNumber] IN ([1], [2])
	) as pvt
INNER JOIN [input].[HandType] T2
	ON pvt.[1] = t2.[Card1LabelAmount]
	AND ISNULL(pvt.[2], 0) = t2.[Card2LabelAmount]
INNER JOIN [input].[Hand] t3
	ON t3.HandId = pvt.[HandId]
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- Rank by Card
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
;WITH handbycard AS ( 
	SELECT [HandId]
		  ,SUBSTRING([Hand], 1, 1) AS [Card1]
		  ,SUBSTRING([Hand], 2,1)	 AS [Card2]
		  ,SUBSTRING([Hand], 3,1)	 AS [Card3]
		  ,SUBSTRING([Hand], 4,1)	 AS [Card4]
		  ,SUBSTRING([Hand], 5,1)	 AS [Card5]
	FROM [input].[Hand]
)
, RankByCard AS (
	SELECT t1.[HandId]
		  ,ROW_NUMBER() OVER(ORDER BY t2.[Rank] ASC,t3.[Rank] ASC,t4.[Rank] ASC,t5.[Rank] ASC,t6.[Rank] ASC) AS [RowNumber]
	FROM handbycard t1
	INNER JOIN [Input].[CardPart1] t2
		ON t2.[Card] = t1.[Card1]
	INNER JOIN [Input].[CardPart1] t3
		ON t3.[Card] = t1.[Card2]
	INNER JOIN [Input].[CardPart1] t4
		ON t4.[Card] = t1.[Card3]
	INNER JOIN [Input].[CardPart1] t5
		ON t5.[Card] = t1.[Card4]
	INNER JOIN [Input].[CardPart1] t6
		ON t6.[Card] = t1.[Card5]
)
UPDATE t1
SET [CardRank] = t2.[RowNumber]
FROM [Input].[Hand] t1
INNER JOIN RankByCard t2
	ON t2.[HandId] = t1.[HandId]
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- Final answer part 1 (250254244)
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
SELECT SUM([Winnings]) AS [TotalWinnings] 
FROM (
	SELECT *
		,ROW_NUMBER() OVER(ORDER BY [HandRank], [CardRank]) * [Bid] AS [Winnings]
	FROM [Input].[Hand]
	) a
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- Part 2:
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
;WITH handbycard AS ( 
	SELECT [HandId]
		  ,SUBSTRING([Hand], 1, 1) AS [Card1]
		  ,SUBSTRING([Hand], 2,1)	 AS [Card2]
		  ,SUBSTRING([Hand], 3,1)	 AS [Card3]
		  ,SUBSTRING([Hand], 4,1)	 AS [Card4]
		  ,SUBSTRING([Hand], 5,1)	 AS [Card5]
	FROM [input].[Hand]
)
, CountOccurence AS (
SELECT [HandId], [Card], COUNT([card]) AS [Count]
	,ROW_NUMBER() OVER(PARTITION BY [HandId] ORDER BY COUNT([Card]) DESC) AS [RowNumber]
FROM (
	SELECT [HandId]
		  ,[Card1]
		  ,[Card2]
		  ,[Card3]
		  ,[Card4]
		  ,[Card5]
	FROM handbycard) a
UNPIVOT
	([Card] FOR [Cards] IN
		([Card1], [Card2], [Card3], [Card4], [Card5])
	) as unpvt
WHERE [Card] != 'J'
GROUP BY [HandId], [Card]
)
UPDATE t1
SET [JokerHand] = REPLACE([Hand], 'J', ISNULL(t2.[Card], 'J'))
FROM [Input].[Hand] t1
LEFT JOIN CountOccurence t2
	ON t1.[HandId] = t2.[HandId]
	AND t2.[RowNumber] = 1
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- Determine Hand Rank
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
;WITH handbycard AS ( 
	SELECT [HandId]
		  ,SUBSTRING([JokerHand], 1,1) AS [Card1]
		  ,SUBSTRING([JokerHand], 2,1) AS [Card2]
		  ,SUBSTRING([JokerHand], 3,1) AS [Card3]
		  ,SUBSTRING([JokerHand], 4,1) AS [Card4]
		  ,SUBSTRING([JokerHand], 5,1) AS [Card5]
	FROM [input].[Hand]
)
, CountOccurence AS (
SELECT [HandId], [Card], COUNT([card]) AS [Count]
	,ROW_NUMBER() OVER(PARTITION BY [HandId] ORDER BY COUNT([Card]) DESC) AS [RowNumber]
FROM (
	SELECT [HandId]
		  ,[Card1]
		  ,[Card2]
		  ,[Card3]
		  ,[Card4]
		  ,[Card5]
	FROM handbycard) a
UNPIVOT
	([Card] FOR [Cards] IN
		([Card1], [Card2], [Card3], [Card4], [Card5])
	) as unpvt
GROUP BY [HandId], [Card]
)
UPDATE t3
SET [JokerHandRank] = t2.[Rank]
FROM (
	SELECT [HandId], [Count], [RowNumber] 
	FROM [CountOccurence]
	WHERE [RowNumber] <= 2 ) b
PIVOT
	( MAX([Count])
		FOR [RowNumber] IN ([1], [2])
	) as pvt
INNER JOIN [input].[HandType] T2
	ON pvt.[1] = t2.[Card1LabelAmount]
	AND ISNULL(pvt.[2], 0) = t2.[Card2LabelAmount]
INNER JOIN [input].[Hand] t3
	ON t3.HandId = pvt.[HandId]
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- Rank by Card
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
;WITH handbycard AS ( 
	SELECT [HandId]
		  ,SUBSTRING([Hand], 1,1) AS [Card1]
		  ,SUBSTRING([Hand], 2,1) AS [Card2]
		  ,SUBSTRING([Hand], 3,1) AS [Card3]
		  ,SUBSTRING([Hand], 4,1) AS [Card4]
		  ,SUBSTRING([Hand], 5,1) AS [Card5]
	FROM [input].[Hand]
)
, RankByCard AS (
	SELECT t1.[HandId]
		  ,ROW_NUMBER() OVER(ORDER BY t2.[Rank] ASC,t3.[Rank] ASC,t4.[Rank] ASC,t5.[Rank] ASC,t6.[Rank] ASC) AS [RowNumber]
	FROM handbycard t1
	INNER JOIN [Input].[CardPart2] t2
		ON t2.[Card] = t1.[Card1]
	INNER JOIN [Input].[CardPart2] t3
		ON t3.[Card] = t1.[Card2]
	INNER JOIN [Input].[CardPart2] t4
		ON t4.[Card] = t1.[Card3]
	INNER JOIN [Input].[CardPart2] t5
		ON t5.[Card] = t1.[Card4]
	INNER JOIN [Input].[CardPart2] t6
		ON t6.[Card] = t1.[Card5]
)
UPDATE t1
SET [JokerCardRank] = t2.[RowNumber]
FROM [Input].[Hand] t1
INNER JOIN RankByCard t2
	ON t2.[HandId] = t1.[HandId]
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- Final answer Part 2:
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
SELECT SUM([Winnings]) AS [TotalWinnings] 
FROM (
	SELECT *
		,ROW_NUMBER() OVER(ORDER BY [JokerHandRank], [JokerCardRank]) * [Bid] AS [Winnings]
	FROM [Input].[Hand]
	) a