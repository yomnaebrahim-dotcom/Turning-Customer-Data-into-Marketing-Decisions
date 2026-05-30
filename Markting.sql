CREATE DATABASE IF NOT EXISTS Marketing 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE Marketing;


CREATE TABLE Customer_Master (
    Id INT PRIMARY KEY,
    Gender VARCHAR(50),
    Age VARCHAR(50),
    Shopping_Frequency VARCHAR(100),
    Discovery_Channel VARCHAR(100),
    Marketing_Influence VARCHAR(100),
    Price_Importance VARCHAR(100),
    Website_UX_Factor VARCHAR(100),
    Cart_Recovery_Factor VARCHAR(100),
    Purchase_Confidence VARCHAR(100),
    Brand_Loyalty_Driver VARCHAR(100),
    Preferred_Offer VARCHAR(100),
    Decision_Time VARCHAR(100),
    Device_Used VARCHAR(100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE Purchase_Motivator (
    Id INT,
    Motivator VARCHAR(255),
    FOREIGN KEY (Id) REFERENCES Customer_Master(Id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE Content_Preference (
    Id INT,
    Preferred_Type VARCHAR(255),
    FOREIGN KEY (Id) REFERENCES Customer_Master(Id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE Cart_Abandonment_Reason (
    Id INT,
    Reason VARCHAR(255),
    FOREIGN KEY (Id) REFERENCES Customer_Master(Id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE Ad_Attention_Driver (
    Id INT,
    Ad_Attention VARCHAR(255),
    FOREIGN KEY (Id) REFERENCES Customer_Master(Id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;



-- Q1: Identify the most effective discovery channels segmented by age group.
-- Helps in understanding which platforms reach specific demographics more effectively.
SELECT Age, Discovery_Channel, COUNT(*)
 AS Total_Users
FROM Customer_Master
GROUP BY Age, Discovery_Channel
ORDER BY Age, Total_Users DESC;

-- Q2: Analyze the correlation between content preferences and ad attention drivers.
-- Useful for tailoring marketing content to match what actually grabs customer attention.
SELECT cp.Preferred_Type, ad.Ad_Attention, COUNT(*) AS Frequency
FROM Content_Preference cp
JOIN Ad_Attention_Driver ad ON cp.Id = ad.Id
GROUP BY cp.Preferred_Type, ad.Ad_Attention
ORDER BY Frequency DESC;

-- Q3: Investigate cart abandonment reasons categorized by the user's device.
-- Detects if technical or UX issues (like slow loading) are specific to mobile or desktop users.
SELECT cm.Device_Used, car.Reason, COUNT(*)
 AS Abandonment_Count
FROM Customer_Master cm
JOIN Cart_Abandonment_Reason car ON cm.Id = car.Id
GROUP BY cm.Device_Used, car.Reason
ORDER BY Abandonment_Count DESC;

-- Q4: Determine preferred offers for "High-Hesitation" customers (Decision time > 1 day).
-- Helps in designing targeted promotional campaigns to convert indecisive shoppers.
SELECT Decision_Time, Preferred_Offer, COUNT(*) AS User_Count
FROM Customer_Master
WHERE Decision_Time IN ('Several days', 'A week or more')
GROUP BY Decision_Time, Preferred_Offer
ORDER BY User_Count DESC;

-- Q5: Cross-analyze brand loyalty drivers with price importance levels.
-- Determines if loyal customers are driven by quality/experience or if they remain price-sensitive.
SELECT Brand_Loyalty_Driver, Price_Importance, COUNT(*) AS Count
FROM Customer_Master
GROUP BY Brand_Loyalty_Driver, Price_Importance
ORDER BY Count DESC;

-- Q6: Identify influencer-driven customers along with their preferences and purchase motivators.
SELECT cm.Id, cm.Gender, cp.Preferred_Type, pm.Motivator
FROM Customer_Master cm
JOIN Content_Preference cp ON cm.Id = cp.Id
JOIN Purchase_Motivator pm ON cm.Id = pm.Id
WHERE cm.Marketing_Influence = 'Influencer marketing';

-- Q7: Calculate the percentage of Gender distribution
-- This version uses a CROSS JOIN which is more stable in MySQL
SELECT 
    Gender, 
    COUNT(*) AS Count,
    ROUND((COUNT(*) / total.total_count) * 100, 2) AS Percentage
FROM Customer_Master
CROSS JOIN (SELECT COUNT(*) AS total_count FROM Customer_Master) AS total
GROUP BY Gender, total.total_count;


-- Q8: Top 3 reasons for cart abandonment for each age group.
-- Helps in understanding age-specific pain points during the checkout process.
SELECT Age, Reason, COUNT(*) as Count
FROM Customer_Master cm
JOIN Cart_Abandonment_Reason car ON cm.Id = car.Id
GROUP BY Age, Reason
ORDER BY Age, Count DESC;

-- Q9: Analyze shopping frequency vs. price importance.
-- Checks if frequent shoppers are more or less sensitive to prices.
SELECT Shopping_Frequency, Price_Importance, COUNT(*) as Count
FROM Customer_Master
GROUP BY Shopping_Frequency, Price_Importance
ORDER BY Count DESC;

-- Q10: Find customers who prefer "Before & After" content and their purchase motivators.
-- This version handles both English/Arabic text and fixes the Group By issue.
SELECT 
    cp.Preferred_Type, 
    pm.Motivator, 
    COUNT(*) as Frequency
FROM Content_Preference cp
JOIN Purchase_Motivator pm ON cp.Id = pm.Id
WHERE cp.Preferred_Type LIKE '%Before & After%' 
GROUP BY cp.Preferred_Type, pm.Motivator
ORDER BY Frequency DESC;

-- Q11: Identify the most common 'Ad Attention Driver' for each 'Discovery Channel'.
-- Shows which ad types work best on which platforms (e.g., Social Media vs. Marketplaces).
SELECT Discovery_Channel, Ad_Attention, COUNT(*) 
as Count FROM Customer_Master cm
JOIN Ad_Attention_Driver ad ON cm.Id = ad.Id
GROUP BY Discovery_Channel, Ad_Attention
ORDER BY Count DESC;

-- Q12: Distribution of 'Device Used' based on 'Shopping Frequency'.
-- Helps optimize the UI for the device most used by loyal/frequent customers.
SELECT Shopping_Frequency, Device_Used, COUNT(*) as Count
FROM Customer_Master
GROUP BY Shopping_Frequency, Device_Used;

-- Q13: Analyze the impact of 'Website UX Factor' on 'Purchase Confidence'.
-- Proves how much a good design/UX contributes to customer trust.
SELECT Website_UX_Factor, Purchase_Confidence, COUNT(*) as Count
FROM Customer_Master
GROUP BY Website_UX_Factor, Purchase_Confidence
ORDER BY Count DESC;

-- Q14: Identify what motivates "High-Hesitation" customers (Decision > 1 week)
-- Fixed the value to 'More than a week' to match the actual CSV data.
SELECT cm.Decision_Time, pm.Motivator, COUNT(*) as Total
FROM Customer_Master cm
JOIN Purchase_Motivator pm ON cm.Id = pm.Id
WHERE cm.Decision_Time = 'More than a week'
GROUP BY cm.Decision_Time, pm.Motivator
ORDER BY Total DESC;

-- Q15: Most effective 'Cart Recovery Factor' for customers who complain about 'Hidden Fees'.
-- Strategic query to find how to win back customers lost due to pricing transparency.
SELECT car.Reason, cm.Cart_Recovery_Factor, COUNT(*) as Success_Count
FROM Cart_Abandonment_Reason car
JOIN Customer_Master cm ON car.Id = cm.Id
WHERE car.Reason = 'Hidden Fees'
GROUP BY cm.Cart_Recovery_Factor;

-- Q16: Compare 'Marketing Influence' between different genders.
-- Shows if males and females are influenced by different marketing tactics (e.g., Ads vs. Reviews).
SELECT Gender, Marketing_Influence, COUNT(*) as Count
FROM Customer_Master
GROUP BY Gender, Marketing_Influence;

-- Q17: Count of unique purchase motivators per customer on average.
-- Helps in understanding if customers are driven by single or multiple factors.
SELECT AVG(motivator_count) as Avg_Motivators_Per_User
FROM (SELECT Id, COUNT(*) as motivator_count 
FROM Purchase_Motivator GROUP BY Id) as subquery;

-- Q18: Identify the 'Preferred Offer' for users who value 'High product quality' as a loyalty driver.
-- Tailoring loyalty rewards (e.g., should we give a discount or free shipping to quality-seekers?).
SELECT Brand_Loyalty_Driver, Preferred_Offer, COUNT(*) as Count
FROM Customer_Master
WHERE Brand_Loyalty_Driver = 'High product quality'
GROUP BY Preferred_Offer;

-- Q19: Find users who discovered the brand via 'Marketplaces' but are motivated by 'Influencers'.
-- Cross-channel behavior analysis.
SELECT Discovery_Channel, Marketing_Influence, COUNT(*) as Count
FROM Customer_Master
WHERE Discovery_Channel = 'Marketplaces' AND Marketing_Influence = 'Influencer marketing';

-- Q20: Detailed report of 'Website UX Factors' for customers using 'Laptop / desktop'.
-- Helps desktop-specific optimization.
SELECT Website_UX_Factor, COUNT(*) as Count
FROM Customer_Master
WHERE Device_Used = 'Laptop / desktop'
GROUP BY Website_UX_Factor;

select * from marketing.customer_master limit 10; -- print everything in the table