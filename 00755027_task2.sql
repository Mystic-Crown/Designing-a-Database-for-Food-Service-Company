--Step1: create the FoodserviceDB Database--
CREATE DATABASE FoodserviceDB;

--Step2: Use the FoodserviceDB Database--
USE FoodserviceDB;
Go

--Step3: Import the csv files to the FoodserviceDB database--

--Step4: Adding foreign key constraints
-- Add foreign key constraint for Consumer_id in Ratings Table
ALTER TABLE Ratings
ADD CONSTRAINT FK_ratings_consumer FOREIGN KEY (Consumer_ID) REFERENCES Consumers(Consumer_ID);

-- Add foreign key constraint for Restaurant_id in Ratings Table
ALTER TABLE Ratings
ADD CONSTRAINT FK_ratings_restaurant FOREIGN KEY (Restaurant_ID) REFERENCES Restaurants(Restaurant_ID);

-- Adding foreign key constraint for Restaurant_ID in  Restaurant_Cuisines table
ALTER TABLE Restaurant_Cuisines
ADD FOREIGN KEY (Restaurant_ID) REFERENCES Restaurants(Restaurant_ID);

-- Step5: Creating the Database Diagram 

-- Q1. Query to list all restaurants with Medium range price, open area, serving Mexican food.
SELECT r.Name AS Restaurant_Names
FROM Restaurants AS r
JOIN Restaurant_Cuisines AS rc ON r.Restaurant_id = rc.Restaurant_id
WHERE r.Price = 'Medium' AND r.Area = 'Open' AND rc.Cuisine = 'Mexican';

-- Q2. 
-- Query to return the total number of restaurants with overall rating 1 serving Mexican food.
SELECT 
    (SELECT COUNT(DISTINCT Restaurant_id) 
     FROM Ratings 
     WHERE Overall_Rating = 1 
     AND Restaurant_id IN (SELECT Restaurant_id 
                           FROM Restaurant_Cuisines 
                           WHERE Cuisine = 'Mexican')
    ) AS Mexican_Restaurants;
-- Query to return the total number of restaurants with overall rating 1 serving Italian food.
SELECT 
    (SELECT COUNT(DISTINCT Restaurant_id) 
     FROM Ratings 
     WHERE Overall_Rating = 1 
     AND Restaurant_id IN (SELECT Restaurant_id 
                           FROM Restaurant_Cuisines 
                           WHERE Cuisine = 'Italian')
    ) AS Italian_Restaurants;

-- Q3. Query to calculate the average age of consumers who gave a 0 rating to the 'Service_rating' column.
SELECT ROUND(AVG(c.Age), 0) AS Average_Age
FROM Consumers c
JOIN Ratings AS rt ON c.Consumer_id = rt.Consumer_id
WHERE rt.Service_Rating = 0;

-- Q4. Query to return restaurants ranked by the youngest consumer and their food rating, sorted by food rating from high to low.
SELECT r.Name AS Restaurants_Name,c.Age AS Youngest_Consumer_Age, rt.Food_Rating
FROM Restaurants r
JOIN Ratings AS rt ON r.Restaurant_id = rt.Restaurant_id
JOIN Consumers AS c ON rt.Consumer_id = c.Consumer_id
WHERE c.Age = (SELECT MIN(AGE) FROM Consumers)
ORDER BY rt.Food_Rating DESC;


-- Q5. Stored procedure to update the Service_rating of all restaurants to '2' if they have parking available ('yes' or 'public').
CREATE PROCEDURE UpdateServiceRating AS
BEGIN
    UPDATE Ratings
    SET Service_rating = '2'
    WHERE Restaurant_id IN (SELECT Restaurant_id FROM Restaurants WHERE Parking IN ('yes', 'public'))
END;

-- Excecuting the Stored procedure
EXEC UpdateServiceRating PRINT 'Service_rating updated for Restaurants with Parking';

-- Q6. 
-- (1) Using Nested queries-EXISTS: To find Which restaurants in the city 'Jiutepec' have received ratings?
SELECT Name
FROM Restaurants AS r
WHERE City = 'Jiutepec'
AND EXISTS (
    SELECT 1
    FROM Ratings AS rt
    WHERE r.Restaurant_id = rt.Restaurant_id
);

-- (2) USing Nested queries-IN: To find out which cuisines are preferred by consumers who have a 'High' budget
SELECT DISTINCT Cuisine
FROM Restaurant_Cuisines
WHERE Restaurant_id IN (
    SELECT Restaurant_id
    FROM Ratings
    WHERE Consumer_id IN (
        SELECT Consumer_id
        FROM Consumers
        WHERE Budget = 'High')
);


--(3) USing System functions: To find out the average rating for each cuisine
SELECT rc.Cuisine, AVG(rt.Overall_Rating) as Average_Rating
FROM Restaurant_Cuisines AS rc
JOIN Ratings AS rt ON rc.Restaurant_id = rt.Restaurant_id
GROUP BY rc.Cuisine;

--(4) Using GROUP BY, HAVING, and ORDER BY: To find out the city with the highest number of restaurants
SELECT City, COUNT(*) as Number_of_Restaurants
FROM Restaurants
GROUP BY City
HAVING COUNT(*) > 1
ORDER BY Number_of_Restaurants DESC;