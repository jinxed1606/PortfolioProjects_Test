/*
Portfolio Project 2 - Data Cleaning using SQL
Skills Used - Date Standardization, separating data into columns, removing duplicates, adding/modifying/deleting columns and column values.
*/

SELECT *
FROM [SQL Portfolio Project - Alex].dbo.[NashvilleHousingData];

---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Standardizing the Date Format
---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Method 1 - Converting datetime to date for SaleDate
SELECT SaleDate, CONVERT(date, SaleDate)
FROM [SQL Portfolio Project - Alex].dbo.[NashvilleHousingData];

UPDATE [SQL Portfolio Project - Alex].dbo.[NashvilleHousingData]
SET SaleDate = CONVERT(date, SaleDate);

-- Method 2 - Adding new column with date type and adding the converted date to new column.
ALTER TABLE [SQL Portfolio Project - Alex].dbo.[NashvilleHousingData]
ADD SaleDateConverted date;

UPDATE [SQL Portfolio Project - Alex].dbo.[NashvilleHousingData]
SET SaleDateConverted = CONVERT(date, SaleDate);

---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Populating the Property Address Data using the ParcelID
---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Check for NULL Data in Property Address, Ordered by Parcel ID
SELECT *
FROM [SQL Portfolio Project - Alex].dbo.[NashvilleHousingData]
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID;

-- Join the Table to itself, based on same parcel ID and different Unique ID.
SELECT NHD1.[UniqueID ], NHD2.[UniqueID ], NHD1.ParcelID, NHD2.ParcelID, 
		NHD1.PropertyAddress, NHD2.PropertyAddress, ISNULL(NHD1.PropertyAddress, NHD2.PropertyAddress)
FROM [SQL Portfolio Project - Alex].dbo.[NashvilleHousingData] AS NHD1
JOIN [SQL Portfolio Project - Alex].dbo.[NashvilleHousingData] AS NHD2
	ON NHD1.ParcelID = NHD2.ParcelID
	AND NHD1.[UniqueID ] <> NHD2.[UniqueID ]
WHERE NHD1.PropertyAddress IS NULL;

-- Update the Property Address field for NULL Values.
UPDATE NHD1
SET PropertyAddress = ISNULL(NHD1.PropertyAddress, NHD2.PropertyAddress)
FROM [SQL Portfolio Project - Alex].dbo.[NashvilleHousingData] AS NHD1
JOIN [SQL Portfolio Project - Alex].dbo.[NashvilleHousingData] AS NHD2
	ON NHD1.ParcelID = NHD2.ParcelID
	AND NHD1.[UniqueID ] <> NHD2.[UniqueID ]
WHERE NHD1.PropertyAddress IS NULL;

---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Separating Address Values into Individual Columns (Address, City, State)
---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Search for ',' separator and split the PropertyAddress string based on ',' position into Address and City
SELECT 
	SUBSTRING(PropertyAddress, 1, (CHARINDEX(',', PropertyAddress) - 1)) AS PropAddress,
	SUBSTRING(PropertyAddress, (CHARINDEX(',', PropertyAddress) + 1), LEN(PropertyAddress)) AS PropCity
FROM [SQL Portfolio Project - Alex].dbo.[NashvilleHousingData]

-- Add Two new columns and update with the split data
ALTER TABLE [SQL Portfolio Project - Alex].dbo.[NashvilleHousingData]
ADD PropAddress NVARCHAR(255);

UPDATE [SQL Portfolio Project - Alex].dbo.[NashvilleHousingData]
SET PropAddress =  SUBSTRING(PropertyAddress, 1, (CHARINDEX(',', PropertyAddress) - 1))


ALTER TABLE [SQL Portfolio Project - Alex].dbo.[NashvilleHousingData]
ADD PropCity NVARCHAR(255);

UPDATE [SQL Portfolio Project - Alex].dbo.[NashvilleHousingData]
SET PropCity =  SUBSTRING(PropertyAddress, (CHARINDEX(',', PropertyAddress) + 1), LEN(PropertyAddress))

---------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Splitting OwnerAddress using PARSENAME function
-- PARSENAME function only splits based on '.' Hence replace ',' with '.' and then split
-- PARSENAME splits backward (Right first then left), hence reverse order for columns
SELECT OwnerAddress,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM [SQL Portfolio Project - Alex].dbo.[NashvilleHousingData]


-- Add 3 new columns and update with the split data address, city, state
ALTER TABLE [SQL Portfolio Project - Alex].dbo.[NashvilleHousingData]
ADD OwnrAddress NVARCHAR(255);

UPDATE [SQL Portfolio Project - Alex].dbo.[NashvilleHousingData]
SET OwnrAddress =  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE [SQL Portfolio Project - Alex].dbo.[NashvilleHousingData]
ADD OwnrCity NVARCHAR(255);

UPDATE [SQL Portfolio Project - Alex].dbo.[NashvilleHousingData]
SET OwnrCity =  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE [SQL Portfolio Project - Alex].dbo.[NashvilleHousingData]
ADD OwnrState NVARCHAR(255);

UPDATE [SQL Portfolio Project - Alex].dbo.[NashvilleHousingData]
SET OwnrState =  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Changing Y/N to Yes/No in 'Sold As Vacant' field
---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Checking the different types of values in 'SoldAsVacant' Column and their count
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [SQL Portfolio Project - Alex].dbo.[NashvilleHousingData]
GROUP BY SoldAsVacant
ORDER BY SoldAsVacant

-- Changing N to No and Y to Yes in SoldAsVacant column
SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'N' THEN 'No'
		 WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 ELSE SoldAsVacant
	END
FROM [SQL Portfolio Project - Alex].dbo.[NashvilleHousingData]

-- Updating the data in the table
UPDATE [SQL Portfolio Project - Alex].dbo.[NashvilleHousingData]
SET SoldAsVacant = 
		CASE WHEN SoldAsVacant = 'N' THEN 'No'
			 WHEN SoldAsVacant = 'Y' THEN 'Yes'
			ELSE SoldAsVacant
		END

---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Removing Duplicate Data
---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Create row_num column containing 1 for different rows and >1 for duplicate rows
WITH RowNumCTE AS (
	SELECT *, 
		ROW_NUMBER() OVER (
			PARTITION BY ParcelID,
						 PropertyAddress,
						 SalePrice,
						 SaleDate,
						 LegalReference
			ORDER BY UniqueID) AS row_num
	FROM [SQL Portfolio Project - Alex].dbo.[NashvilleHousingData]
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress	

---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Delete Unused Columns
---------------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT *
FROM [SQL Portfolio Project - Alex].dbo.[NashvilleHousingData]

-- Delete OwnerAddress, PropertyAddress, TaxDistrict, SaleDate columns from the table
ALTER TABLE [SQL Portfolio Project - Alex].dbo.[NashvilleHousingData]
DROP COLUMN SaleDate
--DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

---------------------------------------------------------------------------------------------------------------------------------------------------------------