CREATE OR REPLACE PACKAGE BODY pkConjugate
IS
   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        pkConjugate
    * Description: Conjugate Distribution of the Bayesian network model Package
    * Author:      Diego Garcia
    * Date:        07th June 2017
    *
    * Modification Log:
    * ---------------------------
    * 2017-07-05    Diego Garc?a    Modify Method: fnuPosteriorHelper
    *                               Replace Call to pkGeneExpression.fnuGetN
    *                               by pkGeneExpression.fnuGetN3
    * 2017-07-01    Diego Garc?a    Modify Method: fnuPosteriorHelper
    *                               Replace Call to pkBayesianMapper.fnuGetN3
    *                               by pkGeneExpression.fnuGetN
    * 2017-06-22    Diego Garcia    Modify Method: fnuPosteriorHelper
    *                               Replace Call to fnuGetN2 by fnuGetN3
    * 2017-06-14    Diego Garcia    Add Method : fnuDDirichlet
    *                               Add TYPE: tytbVector
    *                               Add arrays: tbAlpha, tbX
    * 2017-06-12    Diego Garc?a    Add arrays: tbLogConjugate, tbLogPosterior
    *                               Add Methods: fnuLogPosterior, fnuLogPosteriorPartial
    * 2017-06-07   Diego Garcia    Creation.
    */

    PROCEDURE clearHypParam
    IS
        idx   BINARY_INTEGER;
        idx2   BINARY_INTEGER;
    BEGIN
        -- Clear tbHyperparam
        idx := tbHyperparam.FIRST;
        LOOP
            EXIT WHEN idx IS NULL;
            idx2 := tbHyperparam(idx).FIRST;
            LOOP
                EXIT WHEN idx2 IS NULL;
                tbHyperparam (idx)(idx2).delete;
                idx2 := tbHyperparam(idx).NEXT (idx2);
            END LOOP;
            tbHyperparam(idx).delete;
            idx := tbHyperparam.NEXT (idx);
        END LOOP;
        tbHyperparam.delete;
    END clearHypParam;

    PROCEDURE initHypParam
    IS
    BEGIN
        FOR  i in 1..pkBayesianMapper.tbR.count LOOP
            FOR  j in 1..pkBayesianMapper.tbR(i) LOOP
                tbHyperparam(i)(j)(1) := 2; -- Empty structure is initialized with hyperparamters value equal to 2
            END LOOP;
        END LOOP;
    END initHypParam;

    PROCEDURE clearConjugate
    IS
        idx   BINARY_INTEGER;
    BEGIN
        -- Clear tbConjugate
        idx := tbConjugate.FIRST;
        LOOP
            EXIT WHEN idx IS NULL;
            tbConjugate(idx).delete;
            idx := tbConjugate.NEXT (idx);
        END LOOP;
        tbConjugate.delete;
    END clearConjugate;
	----------------------------------------------------------------------------------
    PROCEDURE clearLogConjugate
    IS
        idx   BINARY_INTEGER;
    BEGIN
        -- Clear tbLogConjugate
        idx := tbLogConjugate.FIRST;
        LOOP
            EXIT WHEN idx IS NULL;
            tbLogConjugate(idx).delete;
            idx := tbLogConjugate.NEXT (idx);
        END LOOP;
        tbLogConjugate.delete;
    END clearLogConjugate;
	----------------------------------------------------------------------------------
    FUNCTION fnuCallDDirichletR(i IN integer, k IN integer)
	RETURN NUMBER
	IS
        TYPE tyRefCur IS REF CURSOR;
        refcur tyRefCur;
        nuResult NUMBER;
	BEGIN
      OPEN refcur FOR 'SELECT * FROM table( rqTableEval(
                                    cursor(SELECT alpha FROM BF_hyperparam WHERE i='||i||' AND k='||k||'),
                                    cursor(SELECT '||pkBayesianMapper.tbR(i)||' "k" FROM dual),
                                    ''SELECT 1 val FROM dual'',''BF_DDirichlet''
                                    )
                                )';
        FETCH refcur INTO nuResult;
        --dbms_output.put_line(nuResult);
        CLOSE refcur;

        RETURN nuResult;
        
	END fnuCallDDirichletR;
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    FUNCTION fnuDDirichlet(itbX in tytbVector, itbAlpha in tytbVector)
    RETURN NUMBER
    IS
        nuIdx binary_integer;
        tbPr tytbVector;
        nuDDirichlet number;
        nuSum number;
        nuLnBeta number;
        ----------------------------------------------------------------------------
        ----------------------------------------------------------------------------
        FUNCTION fnuFact(inuN in number) RETURN NUMBER
        IS
            nuFact number := 1;
        BEGIN
            FOR i in 2..inuN LOOP
                nuFact := nuFact * i;
            END LOOP;
            RETURN nuFact;
        END fnuFact;
        ----------------------------------------------------------------------------
        ----------------------------------------------------------------------------
        FUNCTION fnuGamma(inuN in number) RETURN NUMBER
        IS
        BEGIN
            RETURN fnuFact(inuN-1);
        END fnuGamma;
        ----------------------------------------------------------------------------
        ----------------------------------------------------------------------------
        FUNCTION fnuLnGamma(inuN in number) RETURN NUMBER
        IS
            nuLnGamma number := 0;
        BEGIN
            FOR i in 1..inuN-1 LOOP
                nuLnGamma := nuLnGamma + ln(i);
            END LOOP;
            --RETURN ln(fnuFact(inuN-1));
            RETURN nuLnGamma;
        END fnuLnGamma;
        ----------------------------------------------------------------------------
        ----------------------------------------------------------------------------
        FUNCTION ftbLnGamma(itbVector  in tytbVector) RETURN tytbVector
        IS
            nuIdx binary_integer;
            tbLnGamma tytbVector;
        BEGIN
            tbLnGamma.delete;
            nuIdx := itbVector.first;
            LOOP
                EXIT WHEN nuIdx IS NULL;
                tbLnGamma(nuIdx) := fnuLnGamma(itbVector(nuIdx));
                nuIdx := itbVector.next(nuIdx);
            END LOOP;
            RETURN tbLnGamma;
        END ftbLnGamma;
        ----------------------------------------------------------------------------
        ----------------------------------------------------------------------------
        FUNCTION fnuSumVector(itbVector  in tytbVector) RETURN NUMBER
        IS
            nuSum number := 0;
            nuIdx binary_integer;
        BEGIN
            nuIdx := itbVector.first;
            LOOP
                EXIT WHEN nuIdx IS NULL;
                nuSum := nuSum + itbVector(nuIdx);
                nuIdx := itbVector.next(nuIdx);
            END LOOP;
            RETURN nuSum;
        END fnuSumVector;
        ----------------------------------------------------------------------------
        ----------------------------------------------------------------------------
        FUNCTION fnuLnBeta(itbVector  in tytbVector) RETURN NUMBER
        IS
            nuSum number;
            nuLnGamma number;
        BEGIN
            --dbms_output.put_line('Init pkConjugate.fnuDDirichlet.fnuLnBeta');
            nuSum := fnuSumVector(ftbLnGamma(itbVector));
            nuLnGamma := fnuLnGamma(fnuSumVector(itbVector));
            --dbms_output.put_line('nuSum='||nuSum||' '||'nuLnGamma='||nuLnGamma);
            --dbms_output.put_line('Finish pkConjugate.fnuDDirichlet.fnuLnBeta');
            RETURN nuSum - nuLnGamma;
        END fnuLnBeta;
        ----------------------------------------------------------------------------
        ----------------------------------------------------------------------------
    BEGIN
        --dbms_output.put_line('Init pkConjugate.fnuDDirichlet');
        tbPr.delete;
        nuIdx := itbAlpha.first;
        LOOP
            EXIT WHEN nuIdx IS NULL;
            tbPr(nuIdx) := (itbAlpha(nuIdx)-1)*ln(itbX(nuIdx));
            nuIdx := itbAlpha.next(nuIdx);
        END LOOP;
        nuSum := fnuSumVector (tbPr);
        nuLnBeta := fnuLnBeta(itbAlpha);
        nuDDirichlet := exp( nuSum -  nuLnBeta);
        --dbms_output.put_line('Finish pkConjugate.fnuDDirichlet nuSum='||nuSum||' nuLnBeta='||nuLnBeta);
        --dbms_output.put_line('nuSum -  nuLnBeta = '||(nuSum -  nuLnBeta));
        RETURN nuDDirichlet;
    END fnuDDirichlet;
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    FUNCTION fnuDDirichlet(itbAlpha in tytbVector)
    RETURN NUMBER
    IS
        nuIdx binary_integer;
        nuSumAlpha number := 0;
        nuDDirichlet number;
    BEGIN
        --dbms_output.put('Init pkConjugate.fnuDDirichlet .. ');
        --dbms_output.put_line(itbAlpha.count);
        FOR i IN 1..itbAlpha.count LOOP
            nuSumAlpha := nuSumAlpha + itbAlpha(i);
            --dbms_output.put_line(itbAlpha(i));
        END LOOP;
        tbX.delete;
        FOR i IN 1..itbAlpha.count LOOP
            tbX(i) := itbAlpha(i) / nuSumAlpha;
            --dbms_output.put_line(tbX(i));
        END LOOP;
        nuDDirichlet := fnuDDirichlet(tbX, itbAlpha);
        --dbms_output.put_line('Finish pkConjugate.fnuDDirichlet '||nuDDirichlet);
        RETURN nuDDirichlet;
    END fnuDDirichlet;
    ----------------------------------------------------------------------------
    /**
	----------------------------------------------------------------------------------
    -- Propiedad intelectual de la Universidad del Valle
    -- Name:        fnuPosteriorHelper
	-- Description: Helper of Calculate Posterior distribution asociated
    --              with adjacency matrix pkBayesianMapper.tbAdjacencyMatrix
    --              Function Detail:
	--                 1. Counting n_ijk
	--                 2. Update hyperparameters Alpha : n_ijk + alpha_ijk
    --                 3. Persistence in BF_hyperparam table.
	--                 4. Call R function (Dirichlet Density Function)
	--                 5. Return result
	-- Author: Diego Garc?a
	-- Date:   07-Jun-2017
    -- Parametros	:  Descripcion
    --  i               Current Variable
    --  k               Values combination of the current variable Parents
	-- Modification Log:
	-- 07-Jun-2017 Diego Garcia    Creation.
	-- 22-Jun-2017 Diego Garcia    Replace Call to fnuGetN2 by fnuGetN3.
    --* 2017-07-01    Diego Garc?a    Modify Method: fnuPosteriorHelper
    --*                               Replace Call to pkBayesianMapper.fnuGetN3
    --*                               by pkGeneExpression.fnuGetN
    */
    FUNCTION fnuPosteriorHelper(i IN integer, k IN integer)
	RETURN NUMBER
	IS
        nuPosterior NUMBER;
        nuN_ijk NUMBER;
	BEGIN
        tbAlpha.delete;
        --dbms_output.put_line('Init pkConjugate.fnuPosteriorHelper i='||i||', k='||k);
		FOR j IN 0..pkBayesianMapper.tbR(i)-1 LOOP
            -- 1. Counting n_ijk
            --if (k=2) then
              --dbms_output.put('n('||i||')('||j||')('||k||')=');
            --end if;
            --nuN_ijk := pkBayesianMapper.fnuGetN3(i,j,k);
            
            -- 04-JUL-2017
            --nuN_ijk := pkGeneExpression.fnuGetN(i,j,k);
            -- 05-JUL-2017
            --nuN_ijk := pkGeneExpression.fnuGetN2(i,j,k);
            nuN_ijk := pkGeneExpression.fnuGetN3(i,j,k);
            --if (k=2) then
              --dbms_output.put_line(nuN_ijk);
            --end if;
            -- 2. Update Hyperparameter : n_ijk + alpha_ijk
            /*--> 2017-06-23 IF (NOT tbHyperparam(i)(j+1).exists(k)) THEN
                --tbHyperparam(i)(j+1)(k):=2;
                    -- Persistence
                INSERT INTO BF_hyperparam (i,j,k,alpha)
                VALUES (i,j+1,k,2);
                COMMIT;
                -->tbAlpha(tbAlpha.count + 1) := 2;
            END IF; <--*/
			--> tbHyperparam(i)(j+1)(k) := 2 + nuN_ijk; --tbHyperparam(i)(j+1)(k) + nuN_ijk;
            tbAlpha(tbAlpha.count + 1) := 2 + nuN_ijk;
		END LOOP;
		-- 3. Persistence in BF_hyperparam table.
		--> saveHypParams_ik(i, k);
        -- 4. Call R function (Dirichlet Density Function)
        --nuPosterior := fnuCallDDirichletR(i, k);
        --dbms_output.put_line('fnuCallDDirichletR(i='||i||',k='||k||') = '||nuPosterior);
        nuPosterior :=  fnuDDirichlet(tbAlpha);
        --> nuPosterior :=  fnuDDirichlet(i,k);

        --dbms_output.put_line('Finish pkConjugate.fnuPosteriorHelper');
        -- 5. Return result
		RETURN nuPosterior;
		
	END fnuPosteriorHelper;

	----------------------------------------------------------------------------------
   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        fnuPosterior
    * Description: Calculate Posterior distribution asociated with adjacency matrix pkBayesianMapper.tbAdjacencyMatrix
	*
    * Author:      Diego Garcia
    * Date:        07th Jun 2017
	*
    * Parametros	:  Descripcion
    * inuVar              Variable to update
    *
    * Modification Log:
    * ---------------------------
    * 2017-06-07   Diego Garcia    Creation.
    */
    FUNCTION fnuPosterior(inuVar in integer)
	RETURN NUMBER
	IS
		nuPosterior number := 1;
		nuQi number;
	BEGIN
		IF (NOT pkBayesianMapper.gblCPTcacheON) THEN
			clearConjugate;
			tbPosterior.delete;
		END IF;
		FOR i IN 1..pkBayesianMapper.tbR.COUNT LOOP
			IF (i = inuVar OR NOT pkBayesianMapper.gblCPTcacheON) THEN
				nuQi := pkBayesianMapper.fnuGetQ(i);
                tbPosterior(i) := 1;
				FOR k IN 1..nuQi LOOP
                    tbConjugate(i)(k) := fnuPosteriorHelper(i,k);
			        tbPosterior(i) := tbPosterior(i) * tbConjugate(i)(k);
				END LOOP;
			    nuPosterior := nuPosterior * tbPosterior(i);
			END IF;
		END LOOP;
		RETURN nuPosterior;
	END fnuPosterior;

	----------------------------------------------------------------------------------
   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        fnuPosteriorPartial
    * Description: Calculate Partial Posterior distribution asociated with adjacency matrix pkBayesianMapper.tbAdjacencyMatrix
	*
    * Author:      Diego Garcia
    * Date:        07th Jun 2017
	*
    * Parametros	:  Descripcion
    * inuVar              Variable to update
    *
    * Modification Log:
    * ---------------------------
    * 2017-06-07   Diego Garcia    Creation.
    */
    FUNCTION fnuPosteriorPartial(inuVar in integer)
	RETURN NUMBER
	IS
		nuPosteriorPartial number := 1;
		nuQi number;
	BEGIN
        --dbms_output.put_line('Init pkConjugate.fnuPosteriorPartial '||inuVar);
		nuQi := pkBayesianMapper.fnuGetQ(inuVar);
		FOR k IN 1..nuQi LOOP
	        nuPosteriorPartial := nuPosteriorPartial * fnuPosteriorHelper(inuVar,k);
		END LOOP;
        --dbms_output.put_line('Finish pkConjugate.fnuPosteriorPartial');
		RETURN nuPosteriorPartial;
	END fnuPosteriorPartial;

	----------------------------------------------------------------------------------
   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        fnuLogPosterior
    * Description: Calculate Log Posterior distribution asociated with adjacency matrix pkBayesianMapper.tbAdjacencyMatrix
	*
    * Author:      Diego Garcia
    * Date:        12th Jun 2017
	*
    * Parametros	:  Descripcion
    * inuVar              Variable to update
    *
    * Modification Log:
    * ---------------------------
    * 2017-06-12   Diego Garcia    Creation.
    */
    FUNCTION fnuLogPosterior(inuVar in integer)
	RETURN NUMBER
	IS
		nuLogPosterior number := 0;
		nuQi number;
	BEGIN
        --dbms_output.put_line('INIT pkConjugate.fnuLogPosterior');
		IF (NOT pkBayesianMapper.gblCPTcacheON) THEN
			clearLogConjugate;
			tbLogPosterior.delete;
		END IF;
		FOR i IN 1..pkBayesianMapper.tbR.COUNT LOOP --4..4 LOOP -->
        --dbms_output.put_line('Proccesing variable: '||i);
			IF (i = inuVar OR NOT pkBayesianMapper.gblCPTcacheON) THEN
                -- 04-JUL-2017
                -- 05-JUL-2017 pkGeneExpression.loadCPT(i);
				nuQi := pkBayesianMapper.fnuGetQ(i);
				--dbms_output.put_line('Number of parents:'||nuQi);
                tbLogPosterior(i) := 0;
				FOR k IN 1..nuQi LOOP --1..1 LOOP
                    --dbms_output.put_line('Proccesing parents: '||k||' of '||nuQi);
                    tbLogConjugate(i)(k) := ln(fnuPosteriorHelper(i,k));
			        tbLogPosterior(i) := tbLogPosterior(i) + tbLogConjugate(i)(k);
				END LOOP;
			    nuLogPosterior := nuLogPosterior + tbLogPosterior(i);
			END IF;
		END LOOP;
        --dbms_output.put_line('FINISH pkConjugate.fnuLogPosterior: '||nuLogPosterior);
		RETURN nuLogPosterior;
	END fnuLogPosterior;

	----------------------------------------------------------------------------------
   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        fnuLogPosteriorPartial
    * Description: Calculate Partial Log Posterior distribution asociated with adjacency matrix pkBayesianMapper.tbAdjacencyMatrix
	*
    * Author:      Diego Garcia
    * Date:        22th Jun 2017
	*
    * Parametros	:  Descripcion
    * inuVar              Variable to update
    *
    * Modification Log:
    * ---------------------------
    * 2017-06-12   Diego Garcia    Creation.
    */
    FUNCTION fnuLogPosteriorPartial(inuVar in integer)
	RETURN NUMBER
	IS
		nuLogPosteriorPartial number := 0;
		nuQi number;
	BEGIN
        dbms_output.put_line('Init pkConjugate.fnuLogPosteriorPartial '||inuVar);
        -- 04-JUL-2017
        -- 05-JUL-2017 pkGeneExpression.loadCPT(inuVar);
		nuQi := pkBayesianMapper.fnuGetQ(inuVar);
		FOR k IN 1..nuQi LOOP
	        nuLogPosteriorPartial := nuLogPosteriorPartial + ln(fnuPosteriorHelper(inuVar,k));
		END LOOP;
        dbms_output.put_line('Finish pkConjugate.fnuLogPosteriorPartial');
		RETURN nuLogPosteriorPartial;
	END fnuLogPosteriorPartial;
END pkConjugate;
/
