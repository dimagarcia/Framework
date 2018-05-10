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

SPOOL test_hasting_&fechfile

PROMPT =============================
PROMPT Test hasting
PROMPT =============================
PROMPT Usuario : &usuario
PROMPT Instancia : &instancia
PROMPT Fecha : &fecha
PROMPT =============================


begin
	-- Inizializate cardianality of values sets for each variable
	pkBayesianMapper.tbR(1) := 3; pkBayesianMapper.tbR(2) := 3;
	pkBayesianMapper.tbR(3) := 3; pkBayesianMapper.tbR(4) := 3;
	pkBayesianMapper.tbR(5) := 3; pkBayesianMapper.tbR(6) := 3;
	pkBayesianMapper.tbR(7) := 3; pkBayesianMapper.tbR(8) := 3;
	pkBayesianMapper.tbR(9) := 3; pkBayesianMapper.tbR(10) := 3;
	pkBayesianMapper.tbR(11) := 3; pkBayesianMapper.tbR(12) := 3;
	pkBayesianMapper.tbR(13) := 3; pkBayesianMapper.tbR(14) := 3;
	pkBayesianMapper.tbR(15) := 3; pkBayesianMapper.tbR(16) := 3;
    -- Activate Oracle trace
	--DBMS_SESSION.SET_SQL_TRACE(TRUE);

    --pkBayesianMapper.gnuEpsilon := 0.009;
    --pkBayesianMapper.gnuInGrade := 2;

    -- Testing simulation iterative metropolis hasting with Cumulative Log Posterior Change
    -- 05-JUL-2017
    -->pkHasting.iterationSimulaLogPosterior(5,1000,0);
    pkHasting.iterationSimulaLogPosterior(3,600,0);
    --pkHasting.iterationSimulaLogPosterior(1,500,0);

end;
/
SPOOL OFF
