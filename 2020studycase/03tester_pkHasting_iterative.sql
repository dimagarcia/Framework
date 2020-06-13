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
	/* pkBayesianMapper.tbR(7) := 3; pkBayesianMapper.tbR(8) := 3;
	pkBayesianMapper.tbR(9) := 3; --pkBayesianMapper.tbR(10) := 3;*/
	--pkBayesianMapper.tbR(11) := 3; --pkBayesianMapper.tbR(12) := 3;
 /*pkBayesianMapper.tbR(13) := 3; pkBayesianMapper.tbR(14) := 3;
	pkBayesianMapper.tbR(15) := 3; pkBayesianMapper.tbR(16) := 3;*/
    -- Activate Oracle trace
	--DBMS_SESSION.SET_SQL_TRACE(TRUE);

    --pkBayesianMapper.gnuEpsilon := 0.009;
    --pkBayesianMapper.gnuInGrade := 2;

    -- Testing simulation iterative metropolis hasting with Cumulative Log Posterior Change
    -- 05-JUL-2017
    -->pkHasting.iterationSimulaLogPosterior(5,1000,0);
    --> pkHasting.iterationSimulaLogPosterior(3,600,0);
    --pkHasting.iterationSimulaLogPosterior(1,500,0);
    
    -- 18-Jul-2017
    --pkBayesianMapper.gnuInGrade := 5;
    --pkHasting.iterationSimulaLogPosterior(5,1000,2);

    -- 24-Jul-2017
/*    pkBayesianMapper.gnuInGrade := 5;
    pkBayesianMapper.gnuEpsilon := 0.01;
    pkHasting.iterationSimulaLogPosterior(1,1000,12,0.1);*/
    
    -- 25-Jul-2017
    --pkHasting.iterationSimulaLogPosterior(1,500,0,0.1);

    -- 02-Mar-2019
    --pkHasting.iterationSimulaLogPosterior(1,100,0,0.1);
    
    -- 20-Mar-2019
    --pkHasting.iterationSimulaLogPosterior(1,1000,0,0.1);
    
    -- 31-MAr-2019
    --pkGeneexpression.gvcSamplesName := 'SAMPLE_ECOLI_CTRL';
    -- pkHasting.iterationSimulaLogPosterior(1,1000,4,0.1);

    -- 26-Abr-2019
    --pkGeneexpression.gvcSamplesName := 'SAMPLE_ECOLI_CTRL2';
    --pkHasting.iterationSimulaLogPosterior(1,1000,5,0.1);

    -- 04-May-2019
    --pkGeneexpression.gvcSamplesName := 'SAMPLE_ECOLI_INTERMOD';
    --pkHasting.iterationSimulaLogPosterior(1,1000,6,0.1);
    
    -- 28-Jul-2019
    --pkGeneexpression.gvcSamplesName := 'SAMPLE_CANCER';
    --pkHasting.iterationSimulaLogPosterior(1,1000,10,0.1);
    
    -- 12-Aug-2019
    --pkGeneexpression.gvcSamplesName := 'SAMPLE_ECOLI8_22';
    --pkHasting.iterationSimulaLogPosterior(1,1000,11,0.1);

    -- 12-Jun-2020
    pkGeneexpression.gvcSamplesName := 'SAMPLE_ECOLI8_22_T';
    -- select max(strategy) from trace
    pkHasting.iterationSimulaLogPosterior(1,1000,14,0.1);

end;
/
SPOOL OFF
