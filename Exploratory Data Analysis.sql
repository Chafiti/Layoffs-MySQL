-- Exploratory Data Analysis of Employees Laid Off

SELECT *
FROM layoffs_staging2;

-- Largest layoff by amount and percentage
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

-- Companies that went under
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY country;

-- Total laid off per company
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Time frame of data set
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

-- Total laid off by country
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- Amount of companies with reported layoffs
SELECT DISTINCT(country), COUNT(country)
FROM layoffs_staging2
GROUP BY 1
ORDER BY 2 DESC;

SELECT *
FROM layoffs_staging2
WHERE country = 'Canada';

-- Sorts total layoffs by company stage
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 1 DESC;

-- Tracks layoffs per month
SELECT SUBSTRING(`date`, 1,7) as `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;

WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`, 1,7) as `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
-- Provides an accumulating value of the amount laid off per month
SELECT `MONTH`, total_off, SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;

SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Company layoffs by year
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;


WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(SELECT *, 
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
-- Ranks top five companies per year on total layoffs
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5
;

-- Calculates total employees at the time of layoff
WITH test_cte (company, years, total_emp) AS
(
SELECT company, `date`, (total_laid_off / percentage_laid_off) AS total_emp
FROM layoffs_staging2
)
SELECT company, years, ROUND(total_emp) AS total_employee
FROM test_cte
WHERE total_emp IS NOT NULL
ORDER BY total_employee DESC
;


-- Ranks countries on average percentage laid off
WITH Avg_Per AS
(
SELECT country, COUNT(company), SUBSTRING(AVG(percentage_laid_off), 1, 4) as avg_percentage
FROM layoffs_staging2
WHERE percentage_laid_off IS NOT NULL
GROUP BY country
),
Country_Rank AS
(
SELECT *, DENSE_RANK() OVER (ORDER BY avg_percentage DESC) AS country_rank 
FROM Avg_Per
)
SELECT *
FROM Country_Rank
WHERE country_rank <= 20
;


SELECT *
FROM layoffs_staging2
WHERE country = 'Vietnam'
;