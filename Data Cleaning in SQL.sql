/*

Cleaning Data in SQL Queries

*/


SELECT *
FROM `PortfolioProject.Nashville Housing`;

----------------------------------------------------------------

-- Standardizing date format (French to English) and updating the table with the converted date

SELECT PARSE_DATE('%B %d, %Y',
    CASE
      WHEN REGEXP_CONTAINS(SaleDate, r'janvier') THEN REPLACE(SaleDate, 'janvier', 'January')
      WHEN REGEXP_CONTAINS(SaleDate, r'février') THEN REPLACE(SaleDate, 'février', 'February')
      WHEN REGEXP_CONTAINS(SaleDate, r'mars') THEN REPLACE(SaleDate, 'mars', 'March')
      WHEN REGEXP_CONTAINS(SaleDate, r'avril') THEN REPLACE(SaleDate, 'avril', 'April')
      WHEN REGEXP_CONTAINS(SaleDate, r'mai') THEN REPLACE(SaleDate, 'mai', 'May')
      WHEN REGEXP_CONTAINS(SaleDate, r'juin') THEN REPLACE(SaleDate, 'juin', 'June')
      WHEN REGEXP_CONTAINS(SaleDate, r'juillet') THEN REPLACE(SaleDate, 'juillet', 'July')
      WHEN REGEXP_CONTAINS(SaleDate, r'août') THEN REPLACE(SaleDate, 'août', 'August')
      WHEN REGEXP_CONTAINS(SaleDate, r'septembre') THEN REPLACE(SaleDate, 'septembre', 'September')
      WHEN REGEXP_CONTAINS(SaleDate, r'octobre') THEN REPLACE(SaleDate, 'octobre', 'October')
      WHEN REGEXP_CONTAINS(SaleDate, r'novembre') THEN REPLACE(SaleDate, 'novembre', 'November')
      WHEN REGEXP_CONTAINS(SaleDate, r'décembre') THEN REPLACE(SaleDate, 'décembre', 'December')
    END
  )
FROM `PortfolioProject.Nashville Housing`;

UPDATE `PortfolioProject.Nashville Housing`
SET SaleDate = FORMAT_DATE('%Y-%m-%d',
  PARSE_DATE('%B %d, %Y',
    CASE
      WHEN REGEXP_CONTAINS(SaleDate, r'janvier') THEN REPLACE(SaleDate, 'janvier', 'January')
      WHEN REGEXP_CONTAINS(SaleDate, r'février') THEN REPLACE(SaleDate, 'février', 'February')
      WHEN REGEXP_CONTAINS(SaleDate, r'mars') THEN REPLACE(SaleDate, 'mars', 'March')
      WHEN REGEXP_CONTAINS(SaleDate, r'avril') THEN REPLACE(SaleDate, 'avril', 'April')
      WHEN REGEXP_CONTAINS(SaleDate, r'mai') THEN REPLACE(SaleDate, 'mai', 'May')
      WHEN REGEXP_CONTAINS(SaleDate, r'juin') THEN REPLACE(SaleDate, 'juin', 'June')
      WHEN REGEXP_CONTAINS(SaleDate, r'juillet') THEN REPLACE(SaleDate, 'juillet', 'July')
      WHEN REGEXP_CONTAINS(SaleDate, r'août') THEN REPLACE(SaleDate, 'août', 'August')
      WHEN REGEXP_CONTAINS(SaleDate, r'septembre') THEN REPLACE(SaleDate, 'septembre', 'September')
      WHEN REGEXP_CONTAINS(SaleDate, r'octobre') THEN REPLACE(SaleDate, 'octobre', 'October')
      WHEN REGEXP_CONTAINS(SaleDate, r'novembre') THEN REPLACE(SaleDate, 'novembre', 'November')
      WHEN REGEXP_CONTAINS(SaleDate, r'décembre') THEN REPLACE(SaleDate, 'décembre', 'December')
    END
  )
)
WHERE 1 = 1;

----------------------------------------------------------------

-- Populate Property Address data

SELECT *
FROM `PortfolioProject.Nashville Housing`
-- WHERE PropertyAddress is null
ORDER BY ParcelID;


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress,b.PropertyAddress)
FROM `PortfolioProject.Nashville Housing` a
JOIN `PortfolioProject.Nashville Housing` b
  ON a.ParcelID = b.ParcelID
  AND a.UniqueID_ <> b.UniqueID_
WHERE a.PropertyAddress is null;


UPDATE `PortfolioProject.Nashville Housing`
SET PropertyAddress = (
  SELECT IFNULL(a.PropertyAddress, b.PropertyAddress)
  FROM `PortfolioProject.Nashville Housing` a
  JOIN `PortfolioProject.Nashville Housing` b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID_ <> b.UniqueID_
  WHERE a.PropertyAddress IS NULL
)
WHERE PropertyAddress IS NULL;


------------------------------------------------------------------------------------
-- Breaking out address into individual columns (Address, City, State)


SELECT PropertyAddress
FROM `PortfolioProject.Nashville Housing`;
--WHERE PropertyAddress is null
--ORDER BY ParcelID;


SELECT
SUBSTR(PropertyAddress, 1, STRPOS(PropertyAddress, ',')-1) AS Address
, SUBSTR(PropertyAddress, STRPOS(PropertyAddress, ',')+1, LENGTH(PropertyAddress)) AS Address
FROM `PortfolioProject.Nashville Housing`;


ALTER TABLE `PortfolioProject.Nashville Housing`
ADD COLUMN IF NOT EXISTS PropertySplitAddress STRING;


UPDATE `PortfolioProject.Nashville Housing`
SET PropertySplitAddress = SUBSTR(PropertyAddress, 1, STRPOS(PropertyAddress, ',')-1)
WHERE true;


ALTER TABLE `PortfolioProject.Nashville Housing`
ADD COLUMN IF NOT EXISTS PropertySplitCity STRING;


UPDATE `PortfolioProject.Nashville Housing`
SET PropertySplitCity = SUBSTR(PropertyAddress, STRPOS(PropertyAddress, ',')+1, LENGTH(PropertyAddress))
WHERE true;


SELECT
SPLIT(OwnerAddress,',')[SAFE_OFFSET(0)],
SPLIT(OwnerAddress,',')[SAFE_OFFSET(1)],
SPLIT(OwnerAddress,',')[SAFE_OFFSET(2)]
FROM
`PortfolioProject.Nashville Housing`;


ALTER TABLE `PortfolioProject.Nashville Housing`
ADD COLUMN IF NOT EXISTS OwnerSplitAddress STRING;


UPDATE `PortfolioProject.Nashville Housing`
SET OwnerSplitAddress = SPLIT(OwnerAddress,',')[SAFE_OFFSET(0)]
WHERE true;


ALTER TABLE `PortfolioProject.Nashville Housing`
ADD COLUMN IF NOT EXISTS OwnerSplitCity STRING;


UPDATE `PortfolioProject.Nashville Housing`
SET OwnerSplitCity = SPLIT(OwnerAddress,',')[SAFE_OFFSET(1)]
WHERE true;

ALTER TABLE `PortfolioProject.Nashville Housing`
ADD COLUMN IF NOT EXISTS OwnerSplitState STRING;


UPDATE `PortfolioProject.Nashville Housing`
SET OwnerSplitState = SPLIT(OwnerAddress,',')[SAFE_OFFSET(2)]
WHERE true;


-----------------------------------------------------------------------------------
-- Change true and false to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM `PortfolioProject.Nashville Housing`
GROUP BY SoldAsVacant
ORDER BY 2;

--Add a new temporary column
ALTER TABLE `PortfolioProject.Nashville Housing`
ADD COLUMN SoldAsVacant_tmp STRING;

--Update the temporary column with string values based on the boolean values
UPDATE `PortfolioProject.Nashville Housing`
SET SoldAsVacant_tmp = CASE
    WHEN SoldAsVacant THEN 'Yes'
    ELSE 'No'
  END
WHERE 1=1;

--Delete the original column
ALTER TABLE `PortfolioProject.Nashville Housing`
DROP COLUMN SoldAsVacant;

--Rename the temporary column to the original column name
ALTER TABLE `PortfolioProject.Nashville Housing`
RENAME COLUMN SoldAsVacant_tmp TO SoldAsVacant;


-------------------------------------------------------------------------------------------
-- Remove duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID_
					) row_num

From `PortfolioProject.Nashville Housing`
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress;


--------------------------------------------------------------------------------------------
-- Delete unused columns


SELECT *
From `PortfolioProject.Nashville Housing`

ALTER TABLE `PortfolioProject.Nashville Housing`
DROP COLUMN OwnerAddress

ALTER TABLE `PortfolioProject.Nashville Housing`
DROP COLUMN TaxDistrict

ALTER TABLE `PortfolioProject.Nashville Housing`
DROP COLUMN PropertyAddress