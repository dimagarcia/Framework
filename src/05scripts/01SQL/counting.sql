-- 22-JUN-2017
SELECT SUM (1) as freq  FROM frequency5
WHERE v2 = 0
AND v3 = 0; -- 63
SELECT SUM (1) as freq  FROM frequency5
WHERE v2 = 1
AND v3 = 0; -- 54
--------
SELECT SUM (f) as freq  FROM frequency2
WHERE v2 = 0
AND v3 = 0; -- 102

SELECT SUM (f) as freq  FROM frequency2
WHERE v2 = 1
AND v3 = 0; -- 41

SELECT SUM (f) as freq  FROM frequency2
WHERE v2 = 0
AND v3 = 1; -- 2935

SELECT SUM (f) as freq  FROM frequency2
WHERE v2 = 1
AND v3 = 1; -- 6954