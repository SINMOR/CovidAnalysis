--cleaning data in sql queries
SELECT *
FROM NashvilleHousingData

--standardizing date format
SELECT SaleDate ,CONVERT(date , SaleDate )
FROM NashvilleHousingData

UPDATE NashvilleHousingData
SET SaleDate =CONVERT(date ,SaleDate )

ALTER TABLE NashvilleHousingData
ADD saledateconverted DATE;

UPDATE NashvilleHousingData
SET saledateconverted = CONVERT(date ,SaleDate )

SELECT saleDate 
FROM NashvilleHousingData
SELECT saledateconverted
FROM NashvilleHousingData
--|GETTING RID OF NULL VALUES |
--populate property address data

SELECT PropertysplitAddress
FROM NashvilleHousingData
WHERE PropertysplitAddress IS NULL
ORDER BY ParcelID

 SELECT a.ParcelID, a.PropertysplitAddress, b.ParcelID, b.PropertysplitAddress,ISNULL(a.PropertysplitAddress, b.PropertysplitAddress)
 FROM NashvilleHousingData a
 JOIN NashvilleHousingData b ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
 WHERE a.PropertysplitAddress is NULL

 UPDATE a 
 SET PropertysplitAddress = ISNULL(a.PropertysplitAddress, b.PropertysplitAddress)
 FROM NashvilleHousingData a
 JOIN NashvilleHousingData b ON a.ParcelID = b.ParcelID AND a.[UniqueID ]<> b.[UniqueID ]

 --breaking address and city  into individual  columns 
 --
 SELECT PropertyAddress
FROM NashvilleHousingData
 SELECT propertsplitcity,propertysplitaddress
 FROM NashvilleHousingData

 SELECT SUBSTRING( PropertyAddress,1, CHARINDEX(',' ,PropertyAddress ) -1) AS Address,SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address
 FROM NashvilleHousingData

 ALTER TABLE NashvilleHousingData
ADD propertysplitaddress  NVARCHAR(255);

UPDATE NashvilleHousingData
SET propertysplitaddress =  SUBSTRING( PropertyAddress,1, CHARINDEX(',' ,PropertyAddress ) -1) 

SELECT SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as city
 FROM NashvilleHousingData

ALTER TABLE NashvilleHousingData
ADD propertsplitcity NVARCHAR(255);

UPDATE NashvilleHousingData 
SET propertsplitcity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))
---breaking the ownersaddress into state city and address
SELECT  PARSENAME(REPLACE(OwnerAddress, ',','.') , 3),PARSENAME(REPLACE(OwnerAddress, ',','.') , 2),PARSENAME(REPLACE(OwnerAddress, ',','.') , 1)
FROM NashvilleHousingData
WHERE OwnerAddress IS NOT NULL

ALTER TABLE NashvilleHousingData
ADD ownerssplitaddress  NVARCHAR(255);
UPDATE NashvilleHousingData
SET ownerssplitaddress =  PARSENAME(REPLACE(OwnerAddress, ',','.') , 3)

ALTER TABLE NashvilleHousingData
ADD ownerssplitcity NVARCHAR(255);
UPDATE NashvilleHousingData 
SET ownerssplitcity= PARSENAME(REPLACE(OwnerAddress, ',','.') , 2)

ALTER TABLE NashvilleHousingData
ADD ownerssplitstate NVARCHAR(255);
UPDATE NashvilleHousingData 
SET ownerssplitstate = PARSENAME(REPLACE(OwnerAddress, ',','.') , 1)

SELECT OwnerAddress
FROM NashvilleHousingData
SELECT ownerssplitcity,ownerssplitaddress,ownerssplitstate
FROM NashvilleHousingData

SELECT SoldAsVacant,
CASE WHEN soldasvacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
     ELSE SoldAsVacant
     END
FROM NashvilleHousingData


UPDATE NashvilleHousingData 
SET SoldAsVacant = CASE WHEN soldasvacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
     ELSE SoldAsVacant
     END

SELECT DISTINCT(SoldAsVacant) ,COUNT(SoldAsVacant)
FROM NashvilleHousingData
GROUP BY SoldAsVacant
ORDER BY 2

--REMOVING DUPLICATES
WITH Duplicates AS (
SELECT *,
ROW_NUMBER () OVER ( 
  PARTITION BY ParcelID,saledateconverted,saleprice,legalreference ORDER BY uniqueID) AS ROW_NUM
FROM NashvilleHousingData
)
SELECT COUNT(*) as Duplicates
FROM Duplicates
WHERE ROW_NUM > 1

---There are 104 duplicate rows so we are going to delete 
WITH Duplicates AS (
SELECT *,
ROW_NUMBER () OVER ( 
  PARTITION BY ParcelID,SaleDate,saleprice,legalreference ORDER BY uniqueID) AS ROW_NUM
FROM NashvilleHousingData
)
DELETE
FROM Duplicates
WHERE ROW_NUM > 1
---104 duplicate rows deleted successfully 

--Delete unused/unneceesary columns 
SELECT * 
FROM NashvilleHousingData

ALTER TABLE NashvilleHousingData
DROP COLUMN PropertyAddress,owneraddress,taxdistrict,saleDate