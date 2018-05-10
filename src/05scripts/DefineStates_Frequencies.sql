DECLARE
    idx binary_integer;
    idx2  binary_integer;
    tbStates pkBayesianMapper.tytbRow2;
      --------------------------------------------------------------------------
      -- Embebed methods
      --------------------------------------------------------------------------
      FUNCTION fnuGetStatesNumber RETURN integer IS
        nuQi integer := 1;
      BEGIN
        FOR i IN 1..pkBayesianMapper.tbR.count LOOP
            nuQi := nuQi * pkBayesianMapper.tbR(i);
        END LOOP;
        --dbms_output.put_line('nuQi='||nuQi);
        RETURN nuQi;
      END fnuGetStatesNumber;
      --------------------------------------------------------------------------
      PROCEDURE clearStates
      IS
         idx   BINARY_INTEGER;
      BEGIN
         -- Clear tbCPT
         idx := tbStates.FIRST;
         LOOP
            EXIT WHEN idx IS NULL;
            tbStates(idx).delete;
            idx := tbStates.NEXT (idx);
         END LOOP;
         tbStates.delete;
      END clearStates;
      --------------------------------------------------------------------------
      PROCEDURE loadStates
      IS
         nuPrev   NUMBER := NULL;
         nuPos    NUMBER;
      BEGIN
        --dbms_output.put_line('nuStates = '||fnuGetStatesNumber);
        FOR s IN 1 .. fnuGetStatesNumber LOOP
            nuPos := 0;
            FOR k IN 1..pkBayesianMapper.tbR.count LOOP
        	  --dbms_output.put_line('k:'||k||' tbR( k ):'||pkBayesianMapper.tbR( k )||' nuPos:'||nuPos||' nuPrev:'||nuPrev);
              IF (nuPrev IS NULL) THEN
                 tbStates(s)(k) := MOD(CEIL(s / POWER(pkBayesianMapper.tbR(k), nuPos)) - 1, pkBayesianMapper.tbR(k));
              ELSE
                 tbStates(s)(k) := MOD(CEIL(s / POWER(pkBayesianMapper.tbR(nuPrev), nuPos)) - 1, pkBayesianMapper.tbR(k));
              END IF;
              --dbms_output.put_line('s:'||s||' k:'||k||' tbStates(s)(k):'||tbStates(s)(k));
              nuPrev := k;
              nuPos := NuPos + 1;
            END LOOP;
        END LOOP;
      END loadStates;

BEGIN
	-- Inizializate cardianality of values sets for each variable
	pkBayesianMapper.tbR.delete;
	pkBayesianMapper.tbR(1) := 3; pkBayesianMapper.tbR(2) := 3;
	pkBayesianMapper.tbR(3) := 3; pkBayesianMapper.tbR(4) := 3;
	pkBayesianMapper.tbR(5) := 3; pkBayesianMapper.tbR(6) := 3;

    --pkCorrelation.DefineStates;
    -- Clear tbStates
    clearStates;

    -- Load tbStates
    loadStates;

    idx := tbStates.first;
    LOOP
        EXIT WHEN idx IS NULL;
        idx2 := tbStates(idx).first;
        --dbms_output.put('{');
        LOOP
            EXIT WHEN idx2 IS NULL;
            --dbms_output.put('"');
            dbms_output.put(tbStates(idx)(idx2));
            --dbms_output.put('"');
            idx2 := tbStates(idx).next(idx2);
            IF idx2 IS NOT NULL THEN
                dbms_output.put(',');
                --dbms_output.put(chr(9));
            END IF;
        END LOOP;
        dbms_output.put_line('');
        --dbms_output.put_line('},');
        idx := tbStates.next(idx);
        /*IF idx IS NOT NULL THEN
            dbms_output.put_line(',');
        END IF;*/
    END LOOP;
END;
/