程序说明

- py

  - task1_1_multi_thread.ipynb

      ​	调用高德api/调用hmap接口, 利用python线程池进行多线程调用Hmap-API，计算实际距离；

      ​	获取的距离修改到`ods_july_only_cut_cal_0701_0707_0826_1.csv`中

  - task1_2_draw_dist_diff.ipynb

    ​    筛选出 zke_lch_jyqk - Hmap_dist > 1 （考虑了Hmap与高德Amap本身的导航距离差异）的里程差异分布图（司机比导航多开的路程），画**箱线图**并统计数值特征；

    ​	输出`task1_ods_july_diff_with_hmap_describe.csv`

    ![image-20210913112838136](C:\Users\zhengqiushi\AppData\Roaming\Typora\typora-user-images\image-20210913112838136.png)

  - task2_1_geohash_combine.ipynb

    ​	输入`k_top_router_0902.csv`
    
    ​	处理geohash对， 为 A-B 和 B-A 都生成 A_B 的pairs字段，并存放到 `all_pairs_hash.csv`
    
    ![image-20210913113422801](C:\Users\zhengqiushi\AppData\Roaming\Typora\typora-user-images\image-20210913113422801.png)
    
    并统计坐标对之间的订单实际里程分布关系
    
    
    
  - task2_2_plot_k_top.ipynb

      具体分析某坐标对之间的topk路线，直接画到图上,并保存为html

      ![image-20210913113144811](C:\Users\zhengqiushi\AppData\Roaming\Typora\typora-user-images\image-20210913113144811.png)

      ![image-20210913113157465](C:\Users\zhengqiushi\AppData\Roaming\Typora\typora-user-images\image-20210913113157465.png)

- sql

  - task_0_correct.sql

     ​	修正异常经纬度数据，直接除以 1000000 即可...

  - task_0_filter_date.sql

    ​	筛出某日期的记录

  - task_1_geohash.sql

     ​	计算异常经纬度的geohash

  - task_1_rename_pair.sql

     根据 task2_1_geohash_combine.ipynb 得到的 all_pairs_hash.csv") 

      导入PG new_hash

  - task3_2_K-top-router.sql

     没什么大用...