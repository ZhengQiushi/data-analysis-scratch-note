import folium
import geohash

class my_map_compare():
    def __init__(self, src_pos, dst_pos):
        self.san_map = folium.Map(
            location=[(src_pos[1] + dst_pos[1]) / 2, (src_pos[0] + dst_pos[0]) / 2], 
            zoom_start=16,
            tiles='http://webrd02.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=7&x={x}&y={y}&z={z}', # 高德街道图
            attr='default'
        )

    def contrast_between_Amap_Hmap(self, src_pos, dst_pos, ret_route_Hmap, ret_route_Amap):
        '''
        @params src_pos, dst_pos 起点与终点
        @params ret_route_Hmap, ret_route_Amap 两条路径
        '''
        folium.Circle(radius=100,location=[src_pos[1], src_pos[0]],tooltip="center",color='#000000').add_to(self.san_map)
        folium.Circle(radius=100,location=[dst_pos[1], dst_pos[0]],tooltip="center",color='#666666').add_to(self.san_map)

        for per_point in ret_route_Hmap:
            folium.Circle(radius=10, location=[per_point[0], per_point[1]],tooltip="center",color='#000000').add_to(self.san_map)
        folium.PolyLine(ret_route_Hmap,color='#000000').add_to(self.san_map)

        for per_point in ret_route_Amap:
            folium.Circle(radius=1,location=[per_point[0], per_point[1]],tooltip="center",color='#3388ff').add_to(self.san_map)
        folium.PolyLine(ret_route_Amap,color='#3388ff').add_to(self.san_map)

    def add_point(self, pos, color = '#000000'):
        '''
        @params 
        @brief 添加一个点
        '''
        folium.Circle(radius=100,location=[pos[1], pos[0]],tooltip="center",color=color).add_to(self.san_map)
    
    
    def draw_route(self, src_pos, dst_pos, ret_route_Amap, color_router = "#000000", start_tip = "start", end_tip = "end", router_tip = "router"):
        '''
        @brief 画一条导航路线
        @params src_pos, dst_pos 起点与终点
        @params ret_route_Amap 导航路线
        '''
        folium.Circle(radius=100,location=[src_pos[1], src_pos[0]], tooltip = start_tip,color = '#000000').add_to(self.san_map)
        folium.Circle(radius=100,location=[dst_pos[1], dst_pos[0]], tooltip = end_tip,color = '#666666').add_to(self.san_map)
        for per_point in ret_route_Amap:
            folium.Circle(radius=10, location=[per_point[0], per_point[1]],tooltip = router_tip,color=color_router).add_to(self.san_map)
        folium.PolyLine(ret_route_Amap,color=color_router).add_to(self.san_map)


    def save_(self, name = "test-HmapVsAmap"):
        '''
        @params 保存
        '''
        self.san_map.save(f'')

    def draw_polygon(self, router, color = "#000000"):
        folium.PolyLine(router, color=color).add_to(self.san_map)

    def draw_geohash(self, geohash_val, color = "#000000"):
        bbox_start = geohash.bbox(geohash_val)

        point = [[bbox_start['s'],bbox_start['e']], 
                [bbox_start['n'],bbox_start['e']],
                [bbox_start['n'],bbox_start['w']], 
                [bbox_start['s'],bbox_start['w']],
                [bbox_start['s'],bbox_start['e']]]

        self.draw_polygon(point, color)
