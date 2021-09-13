CREATE INDEX new_hash_from_idx ON new_hash USING hash ("from");
CREATE INDEX new_hash_to_idx ON new_hash USING hash ("to");


 update k_top_router as out_tab 
 set pair_name =  in_tab.pair_name 
        from 
                new_hash in_tab
        where
                in_tab."from" = out_tab.cl_cfa_geohash_short and  in_tab."to" = out_tab.cl_dd_geohash_short

-- where driver_index_code = 'e33a2f8a2e3d4f559d32fada46793df8'
;