--DROP FUNCTION IF EXISTS geohash_bit;
/* 
    计算geohash
*/
create or replace FUNCTION geohash_bit(
    _bit integer
)
RETURNS integer
AS
$func$
declare
BEGIN
    RETURN CASE _bit
        WHEN 0 THEN 16
        WHEN 1 THEN 8
        WHEN 2 THEN 4
        WHEN 3 THEN 2
        WHEN 4 THEN 1
        end;
END
$func$ language plpgsql; 


-- DROP FUNCTION IF EXISTS geohash_base32;


CREATE or replace FUNCTION geohash_base32 (
    _index integer
)
RETURNS CHAR(1)
AS
$func$
declare
BEGIN
    RETURN CASE _index
        WHEN 0 THEN '0'
        WHEN 1 THEN '1'
        WHEN 2 THEN '2'
        WHEN 3 THEN '3'
        WHEN 4 THEN '4'
        WHEN 5 THEN '5'
        WHEN 6 THEN '6'
        WHEN 7 THEN '7'
        WHEN 8 THEN '8'
        WHEN 9 THEN '9'
        WHEN 10 THEN 'b'
        WHEN 11 THEN 'c'
        WHEN 12 THEN 'd'
        WHEN 13 THEN 'e'
        WHEN 14 THEN 'f'
        WHEN 15 THEN 'g'
        WHEN 16 THEN 'h'
        WHEN 17 THEN 'j'
        WHEN 18 THEN 'k'
        WHEN 19 THEN 'm'
        WHEN 20 THEN 'n'
        WHEN 21 THEN 'p'
        WHEN 22 THEN 'q'
        WHEN 23 THEN 'r'
        WHEN 24 THEN 's'
        WHEN 25 THEN 't'
        WHEN 26 THEN 'u'
        WHEN 27 THEN 'v'
        WHEN 28 THEN 'w'
        WHEN 29 THEN 'x'
        WHEN 30 THEN 'y'
        WHEN 31 THEN 'z'
    end;
END
$func$ language plpgsql; 

DROP FUNCTION IF EXISTS geohash_base32_index;


CREATE or replace FUNCTION geohash_base32_index (
    _ch CHAR(1)
)
RETURNS integer
AS
$func$
declare
BEGIN
    RETURN CASE _ch
        WHEN '0' THEN 0
        WHEN '1' THEN 1
        WHEN '2' THEN 2
        WHEN '3' THEN  3
        WHEN '4' THEN 4
        WHEN '5' THEN 5
        WHEN '6' THEN 6
        WHEN '7' THEN 7
        WHEN '8' THEN 8
        WHEN '9' THEN 9
        WHEN 'b' THEN 10
        WHEN 'c' THEN 11
        WHEN 'd' THEN 12
        WHEN 'e' THEN 13
        WHEN 'f' THEN 14
        WHEN 'g' THEN 15
        WHEN 'h' THEN 16
        WHEN 'j' THEN 17
        WHEN 'k' THEN 18
        WHEN 'm' THEN 19
        WHEN 'n' THEN 20
        WHEN 'p' THEN 21
        WHEN 'q' THEN 22
        WHEN 'r' THEN 23
        WHEN 's' THEN 24
        WHEN 't' THEN 25
        WHEN 'u' THEN 26
        WHEN 'v' THEN 27
        WHEN 'w' THEN 28
        WHEN 'x' THEN 29
        WHEN 'y' THEN 30
        WHEN 'z' THEN 31
    end;
END
$func$ language plpgsql; 

-- DROP FUNCTION IF EXISTS geohash_encode;


create or replace FUNCTION geohash_encode (
    _latitude DECIMAL(10, 7),
    _longitude DECIMAL(10, 7),
    _precision integer
)
RETURNS VARCHAR(12)
AS
$func$
declare
    is_even integer := 1;
    i integer := 0;

    latL DECIMAL(38, 35) := -90.0;
    latR DECIMAL(38, 35) := 90.0;

    lonT DECIMAL(38, 34) := -180.0;
    lonB DECIMAL(38, 34) := 180.0;

    _bit integer := 0;
    ch integer := 0;
    
    mid DECIMAL(12, 8) := null;
    
    geohash VARCHAR(12) := '';
BEGIN
    IF _latitude IS NULL OR _longitude IS null then 
        RETURN null;
   
    IF _precision IS null then 
        _precision := 12;

    WHILE char_length(geohash) < _precision loop
        IF is_even = 1 then 
            mid := (lonT + lonB) / 2;
			
            IF _longitude > mid then 
                ch := ch | geohash_bit(_bit);
                lonT := mid;
            ELSE
                lonB := mid;
            END if;
           
        ELSE
            mid := (latL + latR) / 2;
            IF mid < _latitude then
                ch := ch | geohash_bit(_bit);
                latL := mid;
            ELSE
                latR := mid;
            end if;
           
        end if;

        IF is_even = 0 then
            is_even := 1;
        ELSE
            is_even := 0;
		end if;
		
        IF _bit < 4 then
            _bit := _bit + 1;
        else 
            geohash := CONCAT(geohash, geohash_base32(ch));
            _bit := 0;
            ch := 0;
        end if;
       
    end loop;

    RETURN geohash;
END
$func$ language plpgsql; 
