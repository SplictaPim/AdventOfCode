DROP TABLE IF EXISTS [input].[Day1]

CREATE TABLE [input].[Day1] (
[CalibrationValue] varchar(255) NULL)

BULK INSERT [input].[Day1]
FROM 'C:\Users\pim\OneDrive\Documenten\Training\Advent of Code\2023\Input\Day1.txt'
WITH 
  (
    FIELDTERMINATOR = ';', 
    ROWTERMINATOR = '\n' 
  )
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- vraag 1
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
SELECT SUM(
		CONVERT(int, 
			SUBSTRING(t1.[CalibrationValue], PATINDEX('%[0-9]%', t1.[CalibrationValue]), 1)
			+
			SUBSTRING(REVERSE(t1.[CalibrationValue]), PATINDEX('%[0-9]%', REVERSE(t1.[CalibrationValue])), 1)
			)
		)
FROM [AdventOfCode].[Input].[Day1] t1
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- vraag 2
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
;WITH num_to_text AS (
	SELECT [CalibrationValue]
		,[SpelledNumbers] =
		REPLACE(
			REPLACE(
				REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(
									REPLACE(
										REPLACE(
											REPLACE([CalibrationValue], 'zero', 'z0o')
											, 'one', 'o1e')
										, 'two', 't2o')
									, 'three', 't3e')
								, 'four', 'f4r')
							, 'five', 'f5e')
						, 'six', 's6x')
					, 'seven', 's7n')
				, 'eight', 'e8t')
			, 'nine', 'n9e')
	FROM [AdventOfCode].[Input].[Day1]
)

SELECT SUM(
		CONVERT(int, 
			SUBSTRING([SpelledNumbers], PATINDEX('%[0-9]%', [SpelledNumbers]), 1)
			+
			SUBSTRING(REVERSE([SpelledNumbers]), PATINDEX('%[0-9]%', REVERSE([SpelledNumbers])), 1)
			)
		)
FROM num_to_text
