-- 案例：多终端活跃用户内容消费与流失风险分级统计
WITH user_play_summary AS (
    SELECT 
        user_id,
        device_type,  -- pc, mobile, watch, iot (对应云音乐等多终端生态)
        COUNT(song_id) AS total_play_count,
        SUM(play_duration) AS total_duration,
        MAX(action_time) AS last_active_time
    FROM netease_user_action_log
    WHERE action_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
    GROUP BY user_id, device_type
),
user_retention_flag AS (
    SELECT 
        u.*,
        DATEDIFF(CURRENT_DATE(), u.last_active_time) AS silent_days,
        CASE 
            WHEN COUNT(user_id) OVER(PARTITION BY user_id) > 1 THEN 1 
            ELSE 0 
        END AS is_multi_device_user -- 跨终端活跃用户识别
    FROM user_play_summary u
)
SELECT 
    device_type,
    is_multi_device_user,
    COUNT(DISTINCT user_id) AS active_user_count,
    ROUND(AVG(total_duration), 2) AS avg_play_minutes,
    -- 基于沉寂时间的大模型/AI召回策略分级打标 (对标策略精细化运营)
    SUM(CASE WHEN silent_days > 7 THEN 1 ELSE 0 END) AS high_risk_churn_count
FROM user_retention_flag
GROUP BY device_type, is_multi_device_user
ORDER BY active_user_count DESC;
