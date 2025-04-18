-- Postgres SQL

-- 1.1: active subscription per product, desc
SELECT 
    productId,
    COUNT(*) AS active_subscriptions
FROM Subscriptions
WHERE SubscriptionEndDate IS NULL OR CURRENT_TIMESTAMP BETWEEN SubscriptionStartDate AND SubscriptionEndDate
GROUP BY productId
ORDER BY COUNT(*) DESC;

-- 1.2. how many users have how many subscriptions
WITH users_subscriptions AS(
    SELECT 
        userId,
        COUNT(*) AS active_subscriptions
    FROM Subscriptions
    WHERE SubscriptionEndDate IS NULL OR CURRENT_TIMESTAMP BETWEEN SubscriptionStartDate AND SubscriptionEndDate
    GROUP BY userId
)

SELECT 
    active_subscriptions,
    COUNT(*) AS users_amount
FROM users_subscriptions
GROUP BY active_subscriptions
ORDER BY active_subscriptions ASC;

----- 2
-- A daily registered user (DRU) is a logged-in user that visited Seeking Alpha on a given
-- day. Logged out users don’t have a UserId.
-- 2.1 day/ DRU per platform, DRU total
with platform_per_date as (
	select 
		ts_date,
        platform,
        count(*) as amount
	from seeking.events
	where userId is not NULL
	group by ts_date, platform
)
select 
	ts_date,
	sum(case when platform = 'desktop' then amount end) as desktop,
	sum(case when platform = 'mobile' then amount end) as mobile,
	sum(case when platform = 'tablet' then amount end) as tablet,
	sum(amount) as total
from platform_per_date
group by ts_date

-- 2.2 time series, with DRU which used only one platform that day
with one_platform_daily_users as (
	select 
		ts_date, 
		userId
	from seeking.events
	where userId is not null 
	group by ts_date, userId
	having count(distinct platform) = 1
)

,platform_usage_per_date as (
	select 
		u.ts_date, 
        u.platform, 
        count(*) as amount
	from seeking.events u
	inner join one_platform_daily_users o
		on u.userId = o.userId and u.ts_date = o.ts_date
	group by u.ts_date, u.platform
)
select 
	ts_date,
	sum(case when platform = 'desktop' then amount end) as desktop,
	sum(case when platform = 'mobile' then amount end) as mobile,
	sum(case when platform = 'tablet' then amount end) as tablet
from platform_usage_per_date
group by ts_date

-- 2.3 date, DRU per subscription.
with events_with_subscriptions as (
	select 
		distinct
		e.ts_date, 
		e.userId,
		s.productId
	from seeking.events e
	inner join seeking.subscriptions s
		on s.userId = e.userId
		and e.ts_date between s.SubscriptionStartDate and COALESCE(s.SubscriptionEndDate, CURRENT_DATE + 1)
	where e.userId is not null
)

,subscription_per_date as (
	select 
		e.ts_date, 
        e.productId, 
        count(*) as amount
	from events_with_subscriptions e
	group by e.ts_date, e.productId
)
select 
	ts_date,
	sum(case when productId = 'pro' then amount end) as pro,
	sum(case when productId = 'mp' then amount end) as mp,
	sum(amount) as total
from subscription_per_date
group by ts_date

-----
-- 3.1 the percent of the top contributing page of each day out of all the days.

WITH subscription_with_totals AS (
    SELECT
        s.ts_date,
        s.page_before_subscription,
        s.total_subscriptions,
        sum(s.total_subscriptions) OVER(partition by ts_date) as daily_total,
        sum(s.total_subscriptions) OVER() as total
    from seeking.subscriptions1 s
)
SELECT
    st.ts_date,
    st.page_before_subscription,
    round(st.total_subscriptions * 100.0 / st.daily_total, 2) || '%' AS "Percentage out of total subscription that day",
    round(st.total_subscriptions * 100.0 / st.total, 2) || '%' AS "Percentage out of total subscription"
FROM
    subscription_with_totals st;