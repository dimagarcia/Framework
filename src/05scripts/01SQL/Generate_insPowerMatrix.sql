DECLARE
 nuVars integer := 6; --16;
BEGIN
  FOR i IN 1..nuVars LOOP
    FOR j IN 1..nuVars LOOP
        --dbms_output.put_line('insert into power_matrix values (0,'||
        dbms_output.put_line('insert into power_matrix values (1,'||
            i||','||j||',0)');
        dbms_output.put_line('/');
    END LOOP;
  END LOOP;
END;