from func_timeout import func_set_timeout
import requests
import urllib

from haversine import haversine
import math
import json
from GPS_trasfrom import wgs84_to_gcj02, gcj02_to_wgs84, pi
import numpy as np


def Hmap_new_get_points_arr(search_res, dist_only):
    '''
        从hmap中提取有效信息，并计算距离
    '''
    Lat = []
    Lon = []
    all_points = []
    # print(search_res)
    
    distance = search_res['data']['paths'][0]['distance']
    if dist_only == True:
        return all_points, distance

    steps = search_res["data"]["paths"][0]["steps"]
    for per_step in steps:
        
        # 遍历每一步
        cur_points = per_step['polyline']
        # 遍历每一步里的每一个点
        # LINESTRING (120.223493385663 30.2112191588722, 120.225383922004 30.2111891566213)
        res = cur_points[cur_points.find("(") + 1: cur_points.find(")")]
        
        start_point = res.split(",")[0].split(' ')
        end_point = res.split(",")[1].split(' ')
        
        start_point_f = [float(start_point[0]), float(start_point[1])]
        end_point_f = [float(end_point[1]), float(end_point[2])]
        # WGS84->GCJ-02
        start_point_f = wgs84_to_gcj02(start_point_f[0], start_point_f[1])
        end_point_f = wgs84_to_gcj02(end_point_f[0], end_point_f[1])

        # ['120.223493385663', '30.2112191588722'] ['', '120.225383922004', '30.2111891566213']
        Lat.append(start_point_f[1])
        Lon.append(start_point_f[0])

        Lat.append(end_point_f[1])
        Lon.append(end_point_f[0])
          
    all_points = np.array(list(zip(Lat, Lon)))
    
    return all_points, distance

@func_set_timeout(2)
def Hmap_new_ret_route(src_pos, dst_pos, dist_only):
    
    # url = 'https://10.19.124.62/hmappublish/service/rs/v1/netWork/shortPath/network_server' 
    url = 'https://10.19.124.63/hmappublish/service/rs/v1/netWork/shortPath/network_server' # 210831
    head = {"Content-Type": "application/json"}


    src_pos = gcj02_to_wgs84(src_pos[0], src_pos[1])
    dst_pos = gcj02_to_wgs84(dst_pos[0], dst_pos[1])

    data ={
        "origin": f"{src_pos[0]}, {src_pos[1]}",
        "destination": f"{dst_pos[0]}, {dst_pos[1]}",
        "drivingStrategy": 2
    }

    #字符串格式
    requests.packages.urllib3.disable_warnings()
    data = json.dumps(data)
    res = requests.post(url = url, data = data, headers=head,verify=False)
    search_res = json.loads(res.text)
    # print(search_res)

    all_points, distance = Hmap_new_get_points_arr(search_res, dist_only)
    # 但是可以根据每一段路径的geometry，
    return all_points, distance

def Hmap_new_ret_route_pack(src_pos, dst_pos, dist_only = True):
    is_sucess = False
    retry_times = 0
    retry_limit = 10
    all_points = []
    distance = -1
    while(retry_times < retry_limit and is_sucess == False):
        try:
            retry_times += 1
            all_points, distance = Hmap_new_ret_route(src_pos, dst_pos, dist_only)
        except:
            pass
        else:
            is_sucess = True

    return all_points, distance / 1000
# Hmap_new_get_points_arr(search_res)


src_pos = [120.224699, 30.212403]
dst_pos = [120.198967, 30.209625]

cur_all_points, ret_distance = Hmap_new_ret_route_pack(src_pos, dst_pos)

print(ret_distance, cur_all_points)


# EARTH_RADIUS = 6378.137;# 地球半径
 
# def rad(d):
#     return d * pi/ 180.0

# def GetDistance(src_pos, dst_pos):
#     radLat1 = rad(src_pos[1])
#     radLat2 = rad(dst_pos[1])
#     a = radLat1 - radLat2
#     b = rad(src_pos[0]) - rad(dst_pos[0])


#     s = 2 * math.asin(math.sqrt(math.pow(math.sin(a / 2), 2) +
#             math.cos(radLat1) * math.cos(radLat2) * math.pow(math.sin(b / 2), 2)))
    
#     s = s * EARTH_RADIUS
#     return s


# src_pos = [120.224699, 30.212403]
# dst_pos = [120.198967, 30.209625]

# print(GetDistance(src_pos, dst_pos), haversine(src_pos, dst_pos))