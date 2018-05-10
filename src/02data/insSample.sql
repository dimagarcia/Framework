DECLARE
  nuvar number := 5;
  nusamples number := 1;
  type tytb is table of number index by binary_integer;
  tbr tytb; 
BEGIN
  tbr(1):=2; tbr(2):=2; tbr(3):=2; tbr(4):=2; tbr(5):=2;
  FOR i IN 1..nuvar LOOP
    --dbms_output.put_line(tbr(i)||' ');
    nusamples := nusamples * tbr(i);
  END LOOP;
  --dbms_output.put_line(nusamples);  
  
  FOR s IN 1..nusamples LOOP
    FOR i IN 1..nuvar LOOP
      IF i = 1 THEN
        INSERT INTO sample VALUES (s,nuvar+1-i,mod( ceil(s/power(tbr( i ), i-1) ) - 1 ,tbr(i)) );
        --dbms_output.put_line('INSERT INTO sample VALUES ('||s||','||i||','|| mod( ceil(s/power(tbr( i ), i-1) ) - 1 ,tbr(i)) ||')');
      ELSE
        INSERT INTO sample VALUES (s,nuvar+1-i, mod( ceil(s/power(tbr( i-1 ), i-1) ) - 1 ,tbr(i)) );
        --dbms_output.put_line('INSERT INTO sample VALUES ('||s||','||i||','|| mod( ceil(s/power(tbr( i-1 ), i-1) ) - 1 ,tbr(i)) ||')');
      END IF;
    END LOOP;
    --dbms_output.put_line('');
  END LOOP;
  -- Commit
  COMMIT;
END;
/
