Select * from portfolioproject.nashville_housing;

-- Standardize date format

update nashville_housing
set SaleDate = str_to_date(SaleDate,"%M %e, %Y");

-- Populate property Address data

select *
from PortfolioProject.nashville_housing
-- where PropertyAddress is null
order by ParcelID;

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ifnull(a.propertyaddress, b.propertyaddress)
from PortfolioProject.nashville_housing a 
join PortfolioProject.nashville_housing b
on a.parcelid = b.parcelid
and a.uniqueid <> b.UniqueID
where a.propertyaddress is null;

update PortfolioProject.nashville_housing a 
join PortfolioProject.nashville_housing b 
on a.parcelid = b.parcelid
and a.uniqueid <> b.uniqueid
set a.propertyaddress = ifnull(a.propertyaddress, b.propertyaddress)
where a.propertyaddress is null;

-- Breaking out address into Individual Columns (Address, City, State)

select propertyaddress 
from PortfolioProject.nashville_housing;

select substring_index(propertyaddress, ',', 1) as Address,
substring_index(propertyaddress, ',', -1) as Address
from PortfolioProject.nashville_housing;

alter table nashville_housing
add PropertySplitAddress text;

update nashville_housing
set PropertySplitAddress = substring_index(propertyaddress, ',', 1);

alter table nashville_housing
add PropertySplitCity text;

update nashville_housing
set PropertySplitCity = substring_index(propertyaddress, ',', -1);

select *
from PortfolioProject.nashville_housing;

select owneraddress
from PortfolioProject.nashville_housing;

select 
substring_index(owneraddress, ',', 1),
substring_index(substring_index(owneraddress, ',', 2),',',-1),
substring_index(owneraddress, ',', -1)
from PortfolioProject.nashville_housing;

alter table nashville_housing
add OwnerSplitAddress text;

update nashville_housing
set OwnerSplitAddress = substring_index(owneraddress, ',', 1);

alter table nashville_housing
add OwnerSplitCity text;

update nashville_housing
set OwnerSplitCity = substring_index(substring_index(owneraddress, ',', 2), ',', -1);

alter table nashville_housing
add OwnerSplitState text;

update nashville_housing
set OwnerSplitState = substring_index(owneraddress, ',', -1);

select * from PortfolioProject.nashville_housing;

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject.nashville_housing
group by SoldAsVacant
order by 2;

Select SoldAsVacant, 
case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
    else SoldAsVacant
    end
from portfolioproject.nashville_housing;

update nashville_housing
set SoldAsVacant =case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
    else SoldAsVacant
    end;
    

-- Remove Duplicates

-- with RowNumCTE as (
-- Select *,
-- row_number() over(
-- 	partition by ParcelID,
-- 				PropertyAddress,
--                 SalePrice,
--                 SaleDate,
--                 LegalReference
--                 order by 
-- 					uniqueid) row_num
-- from PortfolioProject.nashville_housing
-- -- order by parcelid;
-- )
-- Delete
-- from RowNumCTE
-- where row_num > 1;

DELETE FROM PortfolioProject.nashville_housing
WHERE uniqueid IN (
    SELECT uniqueid
    FROM (
        SELECT uniqueid,
               ROW_NUMBER() OVER (
                   PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
                   ORDER BY uniqueid
               ) as row_num
        FROM PortfolioProject.nashville_housing
    ) as temp_table
    WHERE row_num > 1
);


-- Delete unused columns

Select *
from PortfolioProject.nashville_housing;

alter table PortfolioProject.nashville_housing
drop column OwnerAddress, 
drop column TaxDistrict, 
drop column PropertyAddress;

alter table PortfolioProject.nashville_housing
drop column SaleDate;