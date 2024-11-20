--Cleaning data in sql Queries
select *
from PortfolioProject.dbo.NashvilleHousing

--standardize Data Format
select SaleDate, CONVERT(Date,SaleDate)
from PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

select SaleDateConverted, CONVERT(Date,SaleDate)
from PortfolioProject.dbo.NashvilleHousing

--Populate poperty Adress data

select *
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID ,a.PropertyAddress,a.OwnerAddress ,b.ParcelID, b.PropertyAddress,b.OwnerAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[uniqueID] <> b.[uniqueID]
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[uniqueID] <> b.[uniqueID]
where a.PropertyAddress is null

--Breaking out adress into individual Columns (adress,city,state)
select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing

--charindex is for find var index
select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1 ,LEN(PropertyAddress)) as Address
from PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1 ,LEN(PropertyAddress))

select * from PortfolioProject.dbo.NashvilleHousing

--jb hissa karna hu tu parsname use karta ha (ya ulta chalta ha or full stop dehktha ha )
select 
PARSENAME(REPLACE(OwnerAddress, ',' , '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',' , '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',' , '.'),1)
from PortfolioProject.dbo.NashvilleHousing

select REPLACE(OwnerAddress, ',' , '.') from PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.'),3)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity =PARSENAME(REPLACE(OwnerAddress, ',' , '.'),2)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState =PARSENAME(REPLACE(OwnerAddress, ',' , '.'),1)


select * from PortfolioProject.dbo.NashvilleHousing

select a.PropertyAddress,a.OwnerAddress, b.PropertyAddress,b.OwnerAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[uniqueID] <> b.[uniqueID]
where a.OwnerAddress is null

Update a
SET OwnerAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[uniqueID] <> b.[uniqueID]
where a.OwnerAddress  is null

--this is the final, query

Update a
SET OwnerAddress = ISNULL( OwnerAddress,PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
where a.OwnerAddress  is null

--change Y and N to Yes and no in "sold as vacant" field 

select Distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

select SoldAsVacant,
CASE when SoldAsVacant  = 'Y' then 'Yes'
     when  SoldAsVacant  = 'N' then 'No'
	 ELSE  SoldAsVacant 
END
from PortfolioProject.dbo.NashvilleHousing

Update PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant=CASE when SoldAsVacant  = 'Y' then 'Yes'
     when  SoldAsVacant  = 'N' then 'No'
	 ELSE  SoldAsVacant 
END
from PortfolioProject.dbo.NashvilleHousing

--Remove Duplicate
with RowNumCTE  AS (
select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
from PortfolioProject.dbo.NashvilleHousing
)
Delete 
from RowNumCTE 
where row_num > 1

--Delete Unused Columns
select * from PortfolioProject.dbo.NashvilleHousing


Alter table PortfolioProject.dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress
