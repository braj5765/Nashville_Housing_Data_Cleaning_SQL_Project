--Cleaning Data in SQL Queries

select * 
from Portfolioproject..NashvilleHousing

--------------------------------------------------------------------------------------------------
--Standardize Date Format

select SaleDate,CONVERT(date,SaleDate) 
from Portfolioproject..NashvilleHousing

alter table NashvilleHousing
add SaleDateConverted date;

update NashvilleHousing
set SaleDateConverted= convert(date,SaleDate)

--------------------------------------------------------------------------------------------------------
--Populate property address data
select PropertyAddress 
from Portfolioproject..NashvilleHousing

select a.ParcelID,a.PropertyAddress, b.ParcelID,b.PropertyAddress
from Portfolioproject..NashvilleHousing a
join Portfolioproject..NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID] <>b.[UniqueID]
where a.PropertyAddress is null

update a
set PropertyAddress= isnull(a.PropertyAddress,b.PropertyAddress)
from Portfolioproject..NashvilleHousing a
join Portfolioproject..NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID] <>b.[UniqueID]
where a.PropertyAddress is null

------------------------------------------------------------------------------------------------------
--Breaking out Address into Individual coulmns(Address,City,State)

select PropertyAddress 
from Portfolioproject..NashvilleHousing

select 
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
--SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) as Address
from Portfolioproject..NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress= SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity= SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

select
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from Portfolioproject..NashvilleHousing


alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress= PARSENAME(REPLACE(OwnerAddress,',','.'),3)


alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity= PARSENAME(REPLACE(OwnerAddress,',','.'),2)


alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState= PARSENAME(REPLACE(OwnerAddress,',','.'),1)

-----------------------------------------------------------------------------------------------------------------
--Change Y and N to Yes and No in 'Sold as vacant' field
select distinct(SoldAsVacant),count(SoldAsVacant)
from Portfolioproject..NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant,
case when SoldAsVacant='Y' then 'Yes'
     when SoldAsVacant='N' then 'No'
	 else SoldAsVacant
end
from Portfolioproject..NashvilleHousing

update Portfolioproject..NashvilleHousing
set SoldAsVacant= case when SoldAsVacant='Y' then 'Yes'
					   when SoldAsVacant='N' then 'No'
					   else SoldAsVacant
				  end

----------------------------------------------------------------------------------------------------
--Remove Duplicates
with RowNumCTE as(
select *,
ROW_NUMBER() over (
partition by ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference
order by UniqueID) row_num
from Portfolioproject..NashvilleHousing)

delete from RowNumCTE
where row_num>1

-----------------------------------------------------------------------------------------------------
--Delete Unused columns
select * 
from Portfolioproject..NashvilleHousing

alter table Portfolioproject..NashvilleHousing
drop column OwnerAddress,TaxDistrict,PropertyAddress

alter table Portfolioproject..NashvilleHousing
drop column SaleDate