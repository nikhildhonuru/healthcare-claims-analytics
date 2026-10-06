/*
Healthcare Claims Analytics
Author: Nikhil Kumar Reddy Dhonuru

Purpose:
Analyze synthetic healthcare claims data to identify
claim volumes, approval rates, financial trends,
processing efficiency, and provider performance.
*/


-- =====================================================
-- 1. OVERALL CLAIMS KPIs
-- =====================================================

SELECT
    COUNT(*) AS total_claims,
    ROUND(SUM(Claim_Amount), 2) AS total_claim_amount,
    ROUND(SUM(Approved_Amount), 2) AS total_approved_amount,
    ROUND(AVG(Claim_Amount), 2) AS average_claim_amount,
    ROUND(AVG(Processing_Days), 2) AS average_processing_days
FROM healthcare_claims;


-- =====================================================
-- 2. CLAIM STATUS DISTRIBUTION
-- =====================================================

SELECT
    Claim_Status,
    COUNT(*) AS claim_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_claims
FROM healthcare_claims
GROUP BY Claim_Status
ORDER BY claim_count DESC;


-- =====================================================
-- 3. APPROVAL RATE
-- =====================================================

SELECT
    ROUND(
        SUM(CASE WHEN Claim_Status = 'Approved' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS approval_rate_percentage
FROM healthcare_claims;


-- =====================================================
-- 4. DENIAL RATE
-- =====================================================

SELECT
    ROUND(
        SUM(CASE WHEN Claim_Status = 'Denied' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS denial_rate_percentage
FROM healthcare_claims;


-- =====================================================
-- 5. CLAIM PERFORMANCE BY CLAIM TYPE
-- =====================================================

SELECT
    Claim_Type,
    COUNT(*) AS total_claims,
    ROUND(SUM(Claim_Amount), 2) AS total_claim_amount,
    ROUND(SUM(Approved_Amount), 2) AS approved_amount,
    ROUND(AVG(Claim_Amount), 2) AS average_claim_amount
FROM healthcare_claims
GROUP BY Claim_Type
ORDER BY total_claim_amount DESC;


-- =====================================================
-- 6. DIAGNOSIS CATEGORY ANALYSIS
-- =====================================================

SELECT
    Diagnosis_Category,
    COUNT(*) AS total_claims,
    ROUND(SUM(Claim_Amount), 2) AS total_claim_amount,
    ROUND(AVG(Claim_Amount), 2) AS average_claim_amount
FROM healthcare_claims
GROUP BY Diagnosis_Category
ORDER BY total_claim_amount DESC;


-- =====================================================
-- 7. MONTHLY CLAIM TREND
-- PostgreSQL syntax
-- =====================================================

SELECT
    DATE_TRUNC('month', Claim_Date) AS claim_month,
    COUNT(*) AS total_claims,
    ROUND(SUM(Claim_Amount), 2) AS total_claim_amount,
    ROUND(SUM(Approved_Amount), 2) AS approved_amount
FROM healthcare_claims
GROUP BY DATE_TRUNC('month', Claim_Date)
ORDER BY claim_month;


-- =====================================================
-- 8. PROVIDER PERFORMANCE
-- =====================================================

SELECT
    Provider_ID,
    COUNT(*) AS total_claims,
    ROUND(SUM(Claim_Amount), 2) AS total_claim_amount,
    ROUND(AVG(Processing_Days), 2) AS avg_processing_days,
    ROUND(
        SUM(CASE WHEN Claim_Status = 'Approved' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS approval_rate
FROM healthcare_claims
GROUP BY Provider_ID
HAVING COUNT(*) >= 10
ORDER BY total_claim_amount DESC;


-- =====================================================
-- 9. INSURANCE PLAN ANALYSIS
-- =====================================================

SELECT
    Insurance_Plan,
    COUNT(*) AS total_claims,
    ROUND(SUM(Claim_Amount), 2) AS total_claim_amount,
    ROUND(SUM(Approved_Amount), 2) AS approved_amount,
    ROUND(AVG(Processing_Days), 2) AS avg_processing_days
FROM healthcare_claims
GROUP BY Insurance_Plan
ORDER BY total_claim_amount DESC;


-- =====================================================
-- 10. STATE-LEVEL CLAIM ANALYSIS
-- =====================================================

SELECT
    State,
    COUNT(*) AS total_claims,
    ROUND(SUM(Claim_Amount), 2) AS total_claim_amount,
    ROUND(AVG(Claim_Amount), 2) AS average_claim_amount
FROM healthcare_claims
GROUP BY State
ORDER BY total_claim_amount DESC;


-- =====================================================
-- 11. HIGH-VALUE CLAIMS
-- =====================================================

SELECT
    Claim_ID,
    Provider_ID,
    Claim_Type,
    Diagnosis_Category,
    Claim_Amount,
    Approved_Amount,
    Claim_Status
FROM healthcare_claims
WHERE Claim_Amount > 5000
ORDER BY Claim_Amount DESC;


-- =====================================================
-- 12. PROCESSING EFFICIENCY
-- =====================================================

SELECT
    Claim_Status,
    ROUND(AVG(Processing_Days), 2) AS avg_processing_days,
    MIN(Processing_Days) AS fastest_processing_days,
    MAX(Processing_Days) AS longest_processing_days
FROM healthcare_claims
GROUP BY Claim_Status
ORDER BY avg_processing_days;


-- =====================================================
-- 13. ADVANCED ANALYSIS - CTE
-- Rank providers by total claim amount
-- =====================================================

WITH provider_summary AS (
    SELECT
        Provider_ID,
        COUNT(*) AS total_claims,
        SUM(Claim_Amount) AS total_claim_amount,
        SUM(Approved_Amount) AS total_approved_amount
    FROM healthcare_claims
    GROUP BY Provider_ID
)

SELECT
    Provider_ID,
    total_claims,
    ROUND(total_claim_amount, 2) AS total_claim_amount,
    ROUND(total_approved_amount, 2) AS total_approved_amount,
    RANK() OVER (
        ORDER BY total_claim_amount DESC
    ) AS provider_rank
FROM provider_summary
ORDER BY provider_rank;


-- =====================================================
-- 14. ADVANCED ANALYSIS - WINDOW FUNCTION
-- Rank highest-value claims within each claim type
-- =====================================================

WITH ranked_claims AS (
    SELECT
        Claim_ID,
        Claim_Type,
        Claim_Amount,
        Claim_Status,
        ROW_NUMBER() OVER (
            PARTITION BY Claim_Type
            ORDER BY Claim_Amount DESC
        ) AS claim_rank
    FROM healthcare_claims
)

SELECT
    Claim_ID,
    Claim_Type,
    Claim_Amount,
    Claim_Status,
    claim_rank
FROM ranked_claims
WHERE claim_rank <= 5
ORDER BY Claim_Type, claim_rank;
