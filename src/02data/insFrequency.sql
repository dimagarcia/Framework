DECLARE
--   CURSOR cu is
-- 	SELECT * FROM TABLE(pkFrequecy.MyList); --COLUMN_VALUE
	TYPE tytbList IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
	MyList tytbList;
    s number := 1;
BEGIN
	MyList.delete;
  --pkFrequecy.MyList.Extend(32);
  MyList(1) := 47;
  MyList(2) := 27;
  MyList(3) := 6;
  MyList(4) := 2;
  MyList(5) := 149;
  MyList(6) := 369;
  MyList(7) := 638;
  MyList(8) := 1477;
  MyList(9) := 9;
  MyList(10) := 4;
  MyList(11) := 0;
  MyList(12) := 1;
  MyList(13) := 381;
  MyList(14) := 842;
  MyList(15) := 1526;
  MyList(16) := 3506;
  MyList(17) := 8;
  MyList(18) := 4;
  MyList(19) := 0;
  MyList(20) := 0;
  MyList(21) := 20;
  MyList(22) := 38;
  MyList(23) := 70;
  MyList(24) := 166;
  MyList(25) := 13;
  MyList(26) := 5;
  MyList(27) := 1;
  MyList(28) := 0;
  MyList(29) := 36;
  MyList(30) := 101;
  MyList(31) := 171;
  MyList(32) := 383;
  --FOR idx IN pkFrequecy.MyList.first..pkFrequecy.MyList.last LOOP
  FOR idx IN 1..32 LOOP
    dbms_output.put_line('INSERT INTO frequency VALUES('||s||','||MyList(idx)||');');
    INSERT INTO frequency VALUES(s,MyList(idx));
    s := s + 1;  	
  END LOOP;
  COMMIT;
END;
/
