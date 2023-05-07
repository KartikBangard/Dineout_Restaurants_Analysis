-- Restaurants in each city of India

select City,count(*) as Total_Restaurants from Restaurants_data
group by city
order by Total_restaurants desc

Select  * from Restaurants_data

-- Average Spending Cost in every Restaurant per city

select City,avg(cost) as Cost from Restaurants_data
group by City
order by Cost asc

-- Restaurant with the most and least votes

Select top(1) Name as Restaurant_Name, city,Max(Votes) Max_Votes from Restaurants_data as R1
Group by Restaurant_name,city
Order by Max_Votes desc

Select top(1) Restaurant_Name,city, Min(Votes) Min_Votes from Restaurants_data as R2
where Votes > 100
Group by Restaurant_Name,city
Order by Min_Votes


-- Average rating in metro cities

Select City, round(Avg(Rating),2) as Average_Rating from Restaurants_data
--Where City in ('Delhi','Mumbai','Kolkata','Chennai')
Group by City
order by Average_Rating desc


 -- Count of restaurants per CuisineType per City


 Select City,CuisineType,
 Count(CuisineType) as Number_of_Restaurants
 from #Dineout_Restaurants
 group by City,CuisineType
 Order by City, Number_of_Restaurants desc
 


 -- Temp Table to string split Cuisines Type


    Drop Table if exists #Dineout_Restaurants
	Create Table #Dineout_Restaurants
	(Restaurant_Name Varchar(150),
	City Varchar(50),
	Locality varchar(50),
	Rating float,
	Votes int,
	Cost int,
	CuisineType Varchar(50))

	Insert into #Dineout_Restaurants
	Select Name as Restaurant_Name,City,Locality,Rating,Votes,Cost, trim(Value) as CuisineType
       from Restaurants_data
                    Cross Apply
                      string_split(Cuisine,',')
	
-- Ranking Top 5 Cuisines per City

With CuisinesPerCity as 																				 
(
            Select City,CuisineType, 
                  ROW_NUMBER () Over (Partition by City Order by Count_of_CuisineType desc) as Cuisine_Rank -- Ranking Cuisines per City
from
(
 Select City,CuisineType, Count(CuisineType) Count_of_CuisineType  
                                         from #Dineout_Restaurants
                                                 Group By City,CuisineType
                                                                       ) as Count_Cuisines_Total )
	Select * from CuisinesPerCity
	where Cuisine_Rank <= 5



	-- Top restaurants per Cuisine per city

	With Ratings_CTE as 
	(Select City,Locality,CuisineType,Restaurant_Name,Votes,Cost,
	               Max(Rating) Over(Partition by City order by CuisineType desc) as Max_Rating,
	                            ROW_NUMBER() over (Partition by CuisineType,City order by Votes Desc ) as Ranking
	                                                                                                        from #Dineout_Restaurants
                                                                                                                      )
	
	Select * from Ratings_CTE
	Where Ranking <=2 
	Order by City,CuisineType,Ranking


	-- Top restaurants per Cuisine in a City in a given Cost Range

	With Cost_CTE as
	             (Select City,Locality,CuisineType,Restaurant_Name,Votes,Cost,
	                     ROW_NUMBER() over (Partition by CuisineType,City order by Votes Desc ) as Ranking,	                                                                                                      
	Case
	    When Cost between 0 and 500 then '500 or Less'
	    When Cost between 500 and 100 then '500 to 1000'
	    When Cost between 1001 and 1500 then '1000 to 1500'
		When Cost between 1501 and 2000 then '1500 to 2000'
		Else '2000 and above'
		End as Cost_Range
	from #Dineout_Restaurants)

	Select Restaurant_Name,City,CuisineType,Cost,Ranking from Cost_CTE
	Where Ranking <=5 
	Order by City,CuisineType,Ranking


