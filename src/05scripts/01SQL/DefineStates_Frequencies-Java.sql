SET serveroutput ON
SET timing ON
DEF usuario
DEF instancia
DEF fecha

COLUMN usuario_exec new_value usuario
COLUMN instance_name new_value instancia
COLUMN fecha_exec new_value fecha
COLUMN fecha_short new_value fechfile

SELECT USER usuario_exec,
		SYS_CONTEXT('USERENV','DB_NAME') instance_name,
		TO_CHAR(SYSDATE,'dd-mm-rrrr hh24:mi:ss') fecha_exec,
		TO_CHAR(SYSDATE,'rrrrmmddhh24mi') fecha_short FROM DUAL;

SPOOL States_Java_&fechfile

PROMPT =============================
PROMPT Test hasting
PROMPT =============================
PROMPT Usuario : &usuario
PROMPT Instancia : &instancia
PROMPT Fecha : &fecha
PROMPT =============================
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
	pkBayesianMapper.tbR(7) := 3; pkBayesianMapper.tbR(8) := 3;
	pkBayesianMapper.tbR(9) := 3; pkBayesianMapper.tbR(10) := 3;
	pkBayesianMapper.tbR(11) := 3; pkBayesianMapper.tbR(12) := 3;
	pkBayesianMapper.tbR(13) := 3; pkBayesianMapper.tbR(14) := 3;

    --pkCorrelation.DefineStates;
    -- Clear tbStates
    clearStates;

    -- Load tbStates
    loadStates;

    idx := tbStates.first;
    LOOP
        EXIT WHEN idx IS NULL;
        idx2 := tbStates(idx).first;
        dbms_output.put('{');
        LOOP
            EXIT WHEN idx2 IS NULL;
            dbms_output.put('"');
            dbms_output.put(tbStates(idx)(idx2));
            dbms_output.put('"');
            idx2 := tbStates(idx).next(idx2);
            IF idx2 IS NOT NULL THEN
                dbms_output.put(',');
            END IF;
        END LOOP;
        dbms_output.put_line('},');
        idx := tbStates.next(idx);

    END LOOP;
END;
/
SPOOL OFF