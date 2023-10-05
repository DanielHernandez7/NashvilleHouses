/*

Data Cleaning for my Portfolio Project at DanielHernandez.ca

*/

-- Begin with an overview of the NashvilleHousing dataset
Select *
From PortfolioProject.dbo.NashvilleHousing

-- Standardize the date format for better consistency
Select saleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing

-- Convert the SaleDate for uniformity
Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

-- If above conversion doesn't work, creating an alternative column to store the converted date
ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

-- Fetching data where PropertyAddress might be missing, to ensure data integrity
Select *
From PortfolioProject.dbo.NashvilleHousing
order by ParcelID

-- Using JOIN operation to populate null PropertyAddress
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Segregating PropertyAddress into separate address, city, and state columns for ease of access and analysis
ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);
ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);
ALTER TABLE NashvilleHousing
Add PropertySplitState Nvarchar(255);

Update NashvilleHousing
SET 
PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ),
PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

-- Reviewing the updated table
Select *
From PortfolioProject.dbo.NashvilleHousing

-- Splitting owner address into different columns
Update NashvilleHousing
SET 
OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

-- Review the dataset post owner address split
Select *
From PortfolioProject.dbo.NashvilleHousing

-- Updating SoldAsVacant column from 'Y' and 'N' to 'Yes' and 'No' for better clarity
Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-- Remove duplicates to ensure data uniqueness and integrity
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From PortfolioProject.dbo.NashvilleHousing
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

-- Cleaning up the dataset by dropping unused columns
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
