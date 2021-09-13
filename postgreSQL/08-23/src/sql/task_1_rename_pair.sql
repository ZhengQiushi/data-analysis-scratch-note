/* 
  根据 task2_1_geohash_combine.ipynb 得到的 hash_table.to_csv("C:\\Users\\zhengqiushi\\Desktop\\hik\\21-08-23\\data\\all_pairs_hash.csv") 
  导入PG new_hash
*/

-- Drop table

-- DROP TABLE public.new_hash;

CREATE TABLE public.new_hash (
	indexx varchar NULL,
	"from" varchar NULL,
	"to" varchar NULL,
	pair_name varchar NULL
);

CREATE INDEX new_hash_from_idx ON new_hash USING hash ("from");
CREATE INDEX new_hash_to_idx ON new_hash USING hash ("to");


 update k_top_router as out_tab 
 set pair_name =  in_tab.pair_name 
        from 
                new_hash in_tab
        where
                in_tab."from" = out_tab.cl_cfa_geohash_short and  in_tab."to" = out_tab.cl_dd_geohash_short
;