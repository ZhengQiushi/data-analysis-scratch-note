程序说明

- py

  - task3.ipynb

      （2） 统计7月份每天每个司机每趟行程里发生的每类报警类型的数量

      （3） 对每个司机每趟行程发生每类报警数量进行分布情况的分析

      （4） 对每个司机每趟行程发生 每类报警数量/行驶时长 进行分布情况的分析行驶时间与发生警告的关系

  - task5_0_stastics.ipynb

    （5）相关系数法，分析当个警报之间的相关性

  - task5_1_patternSeq.ipynb

    （5）时间序列挖掘，分析警报组合的分布情况

- sql

  - task1_0_unify.sql

  - task1_1_route.sql

    （1）统计7月份每天每个司机每趟行程的开始时间、结束时间、里程、行驶时长：合并行程趟（时间阈值为50min）

  - task2_0_pre.sql

  - task2_1_checkEvent.sql

  - task2_2_t_riskOut.sql

     （2） 统计7月份每天每个司机每趟行程里发生的每类报警类型的数量，并将结果存放到‘风险事件分析结果表.xlsx ’

  - task5_0_timestamp.sql

  - task5_1_timestamp_main.sql

    - 输出每一个警告发生的event_type和时间戳。