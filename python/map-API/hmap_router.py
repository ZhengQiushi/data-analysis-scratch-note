import requests
import urllib

from haversine import haversine
import math
import json
from GPS_trasfrom import wgs84_to_gcj02, gcj02_to_wgs84, pi
import numpy as np

src_pos = [120.224699, 30.212403]
dst_pos = [120.198967, 30.209625]

def Hmap_get_points_arr(search_res, src_pos, dst_pos):
    '''
        从hmap中提取有效信息，并计算距离
        @brief src_pos, dst_pos 是高德点
        @note 没把起始和终点加到json response中！
    '''
    Lat = []
    Lon = []
    distance = 0
    Lat.append(src_pos[1])
    Lon.append(src_pos[0])

    steps = search_res["data"]

    for i, per_step in enumerate(steps):
        # 遍历每一步
        cur_points = per_step['geometry']
        # 遍历每一步里的每一个点
        # LINESTRING (120.223493385663 30.2112191588722, 120.225383922004 30.2111891566213)
        res = cur_points[cur_points.find("(") + 1: cur_points.find(")")]
        
        start_point = res.split(",")[0].split(' ')
        end_point = res.split(",")[1].split(' ')
        
        try:
            start_point.remove("")
        except:
            pass
        try:
            end_point.remove("")
        except:
            pass

        start_point_f = [float(start_point[0]), float(start_point[1])]

        end_point_f = [float(end_point[0]), float(end_point[1])]
        # WGS84->GCJ-02
        start_point_f = wgs84_to_gcj02(start_point_f[0], start_point_f[1])
        end_point_f = wgs84_to_gcj02(end_point_f[0], end_point_f[1])

        # ['120.223493385663', '30.2112191588722'] ['', '120.225383922004', '30.2111891566213']
        # distance += GetDistance(start_point_f, end_point_f) # haversine(start_point_f, end_point_f)
        
        # if i == 0:
        #     distance += GetDistance(start_point_f, src_pos)
        # if i == len(steps):
        #     distance += GetDistance(dst_pos, end_point_f)

        # points_arr = cur_points.split(';')
        Lat.append(end_point_f[1])
        Lon.append(end_point_f[0])
    
    


    Lat.append(dst_pos[1])
    Lon.append(dst_pos[0])    
        
    cal_distance = 0
    for i in range(0, len(Lat)):
        if i == 0:
            continue
        cal_distance += haversine([Lat[i], Lon[i]], [Lat[i - 1], Lon[i - 1]])


    all_points = np.array(list(zip(Lat, Lon)))
    return all_points, cal_distance

def Hmap_ret_route(src_pos, dst_pos):
    
    url = " http://10.19.154.66:1709/hmap-server/service/rs/v2/AStarAnalysis/AStarAnalysisByXY"
    head = {"Content-Type": "application/x-www-form-urlencoded"}

    src_pos_Hmap = gcj02_to_wgs84(src_pos[0], src_pos[1])
    dst_pos_Hmap = gcj02_to_wgs84(dst_pos[0], dst_pos[1])

    data ={
        "data": [
        {"x": src_pos_Hmap[0], "y": src_pos_Hmap[1] },
        {"x": dst_pos_Hmap[0], "y": dst_pos_Hmap[1] }
        ]
    }
    # print(data)
    body_value  = urllib.parse.urlencode(data)
    body_value = body_value.replace("%27", "%22")
    #字符串格式
    res = requests.post(url=url, data=body_value, headers=head)
    search_res = json.loads(res.text)
    # print(search_res)
    
    all_points, distance = Hmap_get_points_arr(search_res, src_pos, dst_pos)

    # all_points = [src_pos, all_points]
    # res = np.append(src_pos, all_points)
    # res = np.append(res, dst_pos)
    
    # print(all_points, distance)
    # 但是可以根据每一段路径的geometry，
    return all_points, distance

ret_route, ret_distance = Hmap_ret_route(src_pos, dst_pos) # print)
print(ret_distance)