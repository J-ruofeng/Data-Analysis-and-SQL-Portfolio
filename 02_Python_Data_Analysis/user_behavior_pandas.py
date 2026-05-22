import pandas as pd
import numpy as np

def analyze_user_engagement(file_path):
    print("正在加载海量多终端用户行为日志...")
    # 模拟读取大盘业务数据或外部公开日志矩阵
    df = pd.read_csv(file_path)
    
    # 1. 自动化执行脏数据清洗与异常打标 (体现数据产品人的严谨性)
    df['play_duration'] = df['play_duration'].replace([np.inf, -np.inf], np.nan)
    df['play_duration'].fillna(df['play_duration'].median(), inplace=True)
    
    # 2. 按用户和平台进行多维度交叉透视 (对标互联网大厂用户行为分析要求)
    user_cohort = df.groupby(['user_id', 'platform']).agg(
        total_actions=('action_id', 'count'),
        avg_stay_time=('play_duration', 'mean')
    ).reset_index()
    
    # 3. 提取核心 Top 10% 的高粘性种子用户群特征
    high_engagement_threshold = user_cohort['total_actions'].quantile(0.90)
    vip_users = user_cohort[user_cohort['total_actions'] >= high_engagement_threshold]
    
    print(f"数据清洗完毕！成功锁定 Top 10% 关键高潜用户，阈值为: {high_engagement_threshold} 次交互")
    return vip_users

if __name__ == "__main__":
    # 该脚本可在日常数据周复盘、智能化看板冷启动时自动化调度执行
    pass
