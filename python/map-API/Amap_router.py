import requests, json

def request_url_get(url):
    """ 请求url方法get方法 """
    try:
        
        r = requests.get(url=url, timeout=30)
        if r.status_code == 200:
            return r.text
        return None
    except RequestException:
        print('请求url返回错误异常')
        return None

def parse_json(content_json):
    """  解析json函数 """
    result_json = json.loads(content_json)
    return result_json

def request_api(url):
    """ 请求高德api 解析json """
    result = request_url_get(url)
    # print(result)
    result_json = parse_json(result)
    return result_json

def run(src_pos, dst_pos):
    """ 运行函数 """
    src_longitude = src_pos[0]
    src_latitude = src_pos[1]

    dst_longitude = dst_pos[0]
    dst_latitude = dst_pos[1]
    # https://restapi.amap.com/v3/direction/driving?origin={src_longitude},{src_latitude}&destination={dst_longitude},{dst_latitude}&extensions=all&output=xml&key=<用户的key>
    index_url = f'https://restapi.amap.com/v3/direction/driving?origin={src_longitude},{src_latitude}&' \
        f'destination={dst_longitude},{dst_latitude}&extensions=all&output=json&key={user_key}'
    index_result = request_api(index_url)

    return index_result

import numpy as np

def get_route(src_pos, dst_pos):
    # all_points = np.array(list(zip(Lat, Lon)))
    search_res = run(src_pos, dst_pos)
    # print(search_res)
    Lat = []
    Lon = []
    Lat.append(src_pos[1])
    Lon.append(src_pos[0])


    cur_path = search_res["route"]["paths"][0]
    distance = cur_path['distance']

    cal_distance = 0

    steps = cur_path['steps']
    for per_step in steps:
        # 遍历每一步
        cur_points = per_step['polyline']
        # 遍历每一步里的每一个点
        points_arr = cur_points.split(';')
        for per_point in points_arr:
            cur_cords = per_point.split(',')
            Lat.append(float(cur_cords[1]))
            Lon.append(float(cur_cords[0]))

           
    all_points = np.array(list(zip(Lat, Lon)))

    Lat.append(dst_pos[1])
    Lon.append(dst_pos[0])

    return all_points, int(distance) / 1000


src_pos = [120.224699, 30.212403]
dst_pos = [120.198967, 30.209625]
user_key = '33607b0e4b514deb5ee5086c484b2a24'

cur_all_points, ret_distance = get_route(src_pos, dst_pos)

print(ret_distance)
