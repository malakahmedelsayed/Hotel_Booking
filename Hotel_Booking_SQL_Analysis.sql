-------------------------------------Data Base--------------------------------------------------------------

USE HotelBookingAnalysis;

------------------------------------ DATA VALIDATION-----------------------------------------------------
SELECT *
FROM [dbo].[HotelBookings];

SELECT COUNT(*) AS Total_Rows
FROM [dbo].[HotelBookings];

SELECT
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'HotelBookings'
ORDER BY ORDINAL_POSITION;

SELECT TOP 10 *
FROM [dbo].[HotelBookings];

------------------------------- 1. What is the overall cancellation rate?-----------------------------------------
SELECT
    COUNT(*) AS Total_Bookings,
    SUM([is_canceled]) AS Canceled_Bookings,
    COUNT(*) - SUM([is_canceled]) AS Not_Canceled_Bookings,
    ROUND(
        100.0 * SUM([is_canceled]) / COUNT(*),2
    ) AS Cancellation_Rate_Percent
FROM [dbo].[HotelBookings];


-------------------------------2. Which hotel has the highest cancellation rate?-----------------------------

SELECT [hotel] ,
    COUNT(*) AS Total_Bookings,
    SUM([is_canceled]) AS Canceled_Bookings,
    ROUND(
        100.0 * SUM([is_canceled]) / COUNT(*),
        2
    ) AS Cancellation_Rate_Percent
FROM [dbo].[HotelBookings]
GROUP BY [hotel]
ORDER BY Cancellation_Rate_Percent DESC;

--------------------------------3. Cancellation Rate by Market Segment----------------------------------------

SELECT  [market_segment] ,
    COUNT(*) AS Total_Bookings,
    SUM([is_canceled]) AS Canceled_Bookings,

    ROUND(100.0 * SUM([is_canceled]) / COUNT(*),2) AS Cancellation_Rate_Percent

FROM [dbo].[HotelBookings]
GROUP BY [market_segment]
ORDER BY Cancellation_Rate_Percent DESC;

-------------------------------4. Cancellation Rate by Lead Time----------------------------------------------

SELECT
    CASE
        WHEN [lead_time] <= 7 THEN '0-7 Days'
        WHEN [lead_time] <= 30 THEN '8-30 Days'
        WHEN [lead_time]<= 90 THEN '31-90 Days'
        WHEN [lead_time]<= 180 THEN '91-180 Days'
        ELSE '181+ Days'
    END AS Lead_Time_Group,
    
    COUNT(*) AS Total_Bookings,
    SUM([is_canceled]) AS Canceled_Bookings,

    ROUND(
        100.0 * SUM([is_canceled]) / COUNT(*),2) AS Cancellation_Rate_Percent

FROM [dbo].[HotelBookings]

GROUP BY
    CASE
        WHEN [lead_time]<= 7 THEN '0-7 Days'
        WHEN [lead_time] <= 30 THEN '8-30 Days'
        WHEN [lead_time] <= 90 THEN '31-90 Days'
        WHEN [lead_time] <= 180 THEN '91-180 Days'
        ELSE '181+ Days'
    END

ORDER BY Cancellation_Rate_Percent DESC;

----------------------------------------5. Revenue by Customer Type----------------------------------------

SELECT [customer_type] ,
    COUNT(*) AS Total_Bookings,
    SUM([total_stay_revenue]) AS Total_Stay_Revenue,
    SUM([net_revenue]) AS Total_Net_Revenue,
    AVG([adr]) AS Average_ADR
FROM [dbo].[HotelBookings]
GROUP BY [customer_type]
ORDER BY Total_Net_Revenue DESC;

----------------------------------------6. Which hotel generates more net revenue?----------------------------

SELECT [hotel] ,
    COUNT(*) AS Total_Bookings,
    SUM([net_revenue]) AS Total_Net_Revenue,
    AVG([adr]) AS Average_ADR
FROM [dbo].[HotelBookings]
GROUP BY [hotel]
ORDER BY Total_Net_Revenue DESC;

----------------------------------------7. How did bookings and revenue change over the years and month?-------

SELECT
   [arrival_date_year] ,
   [arrival_date_month],
    COUNT(*) AS Total_Bookings,
    SUM([net_revenue]) AS Total_Net_Revenue
FROM [dbo].[HotelBookings]
GROUP BY
   [arrival_date_year] ,
    [arrival_date_month]
ORDER BY
    [arrival_date_year],
    Total_Bookings DESC;

----------------------------------------8. Revenue by Market Segment---------------------------------------

SELECT
    [market_segment],
    COUNT(*) AS Total_Bookings,
    SUM([net_revenue]) AS Total_Net_Revenue,
    AVG([adr]) AS Average_ADR
FROM [dbo].[HotelBookings]
GROUP BY [market_segment]
ORDER BY Total_Net_Revenue DESC;

----------------------------------------9. Special Requests vs Cancellation-------------------------------------

SELECT
    [total_of_special_requests],
    COUNT(*) AS Total_Bookings,
    SUM([is_canceled]) AS Canceled_Bookings,
    ROUND(
        100.0 * SUM([is_canceled]) / COUNT(*),2) AS Cancellation_Rate_Percent
FROM [dbo].[HotelBookings]
GROUP BY [total_of_special_requests]
ORDER BY [total_of_special_requests];

-----------------------------------------10. Which countries generate the most bookings?-----------------------

SELECT TOP 10 [country],
    COUNT(*) AS Total_Bookings
FROM [dbo].[HotelBookings]
GROUP BY [country]
ORDER BY Total_Bookings DESC;

---------------------------------------11. How often is the assigned room different from the reserved room?-----------------------------------

SELECT
    [reserved_room_type],
    [assigned_room_type],
    COUNT(*) AS Booking_Count
FROM [dbo].[HotelBookings]
WHERE reserved_room_type <> assigned_room_type
GROUP BY
   [reserved_room_type] ,
   [assigned_room_type]
ORDER BY Booking_Count DESC;

--------------------------------------12. The percentage Different_Room_Assignments------------------------------------

SELECT
    COUNT(*) AS Different_Room_Assignments,
    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*) FROM [dbo].[HotelBookings]),2) AS Different_Room_Percentage
FROM [dbo].[HotelBookings]
WHERE [reserved_room_type] <> [assigned_room_type];

--------------------------------------------------CTE-------------------------------------------------------

---------------------------------------13. Which hotels have more than 4,000 bookings?--------------------------

WITH HotelSummary AS
(
    SELECT
       [hotel] ,
        COUNT(*) AS Total_Bookings,
        SUM([is_canceled]) AS Canceled_Bookings
    FROM [dbo].[HotelBookings]
    GROUP BY [hotel]
)

SELECT
    [hotel],
    Total_Bookings,
    Canceled_Bookings
FROM HotelSummary
WHERE Total_Bookings > 4000
ORDER BY Total_Bookings DESC;

---------------------------------------Window Function-----------------------------------------------------

WITH SegmentRevenue AS
(
    SELECT
       [market_segment] ,
        SUM([net_revenue]) AS Total_Net_Revenue
    FROM [dbo].[HotelBookings]
    GROUP BY [market_segment]
)

SELECT
    [market_segment],
    Total_Net_Revenue,
    RANK() OVER (
        ORDER BY Total_Net_Revenue DESC
    ) AS Revenue_Rank
FROM SegmentRevenue
ORDER BY Revenue_Rank;


----------------------------------------14. Bookings by Year-------------------------------------------

SELECT
    [arrival_date_year],
    COUNT(*) AS Total_Bookings,
    SUM([is_canceled]) AS Canceled_Bookings,
    ROUND(
        100.0 * SUM([is_canceled]) / COUNT(*),2) AS Cancellation_Rate_Percent,
    SUM([net_revenue]) AS Total_Net_Revenue
FROM [dbo].[HotelBookings]
GROUP BY [arrival_date_year]
ORDER BY [arrival_date_year];
-----------------------------------------Filtering-------------------------------------------------
-----------------------------------------15. Cancelled bookings---------------------------------------
SELECT TOP 100 *
FROM [dbo].[HotelBookings]
WHERE  [is_canceled]= 1;

-----------------------------------------Sorting------------------------------------------------------
-----------------------------------------16. Top Revenue Ranking------------------------------------------
SELECT TOP 10 [hotel],[net_revenue]
    
FROM [dbo].[HotelBookings]
ORDER BY [net_revenue] DESC;

------------------------------------------17. Hotel + Year Analysis----------------------------------------

SELECT
    [arrival_date_year],
    [hotel],
    COUNT(*) AS Total_Bookings,
    SUM([is_canceled]) AS Canceled_Bookings,
    ROUND(
        100.0 * SUM([is_canceled]) / COUNT(*),2) AS Cancellation_Rate_Percent,
    SUM([net_revenue]) AS Total_Net_Revenue
FROM [dbo].[HotelBookings]
GROUP BY
   [arrival_date_year] ,
    [hotel]
ORDER BY
    [arrival_date_year],
    Total_Net_Revenue DESC;

-----------------------------------------18. The value of the bookings that got canceled------------

SELECT
    [hotel],
    COUNT(*) AS Canceled_Bookings,
    SUM([total_stay_revenue]) AS Potential_Canceled_Revenue
FROM [dbo].[HotelBookings]
WHERE [is_canceled] = 1
GROUP BY [hotel]
ORDER BY Potential_Canceled_Revenue DESC;

------------------------------------------------------------------------------------------------------------