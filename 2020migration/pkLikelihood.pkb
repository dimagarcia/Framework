CREATE OR REPLACE PACKAGE BODY pkLikelihood
IS
   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        pkLikelihood
    * Description: Likelihood function of the Bayesian network model Package
    * Author:      Diego Garcia
    * Date:        14th April 2016
    *
    * Modification Log:
    * ---------------------------
    * 2016-04-14   Diego Garcia    Creation.
    * 2016-06-01   Diego Garcia    Add function: fnuLogLikelihood
	*							   Add Collection: tbLogLikelihood
	* 2016-06-06   Diego Garcia    Drop function: fnuSum, fnuLogCoefMN, fnuSumLogRho
	*   						   Add function: fnuLogLikelihoodHelper
	*							   Fix Factorial Sum Nijk
	*							   Modify function: fnuLogLikelihood
	*							   Improve performance
	*							   Add Collection:  tbNik, tbLogLikelihood
	* 2016-06-14   Diego Garcia    Add function: fnuLogLikelihoodPartial
	* 2016-08-16   Diego Garcia 	Modify function: fnuLogLikelihoodHelper
	*								Fix Invalid Value Error by ln(0)=-Infinity
    */

	----------------------------------------------------------------------------------
	/**
		1. log (Sum Nijk)!
		2. Sum log(Nijk!)

		3. logCoefMN
		4. Sum log(Pijk^Nijk)

	*/
    FUNCTION fnuLogLikelihoodHelper(i IN number, k IN number)
	RETURN NUMBER
	IS
		nuSumNijk number := 0;
		nuLogSumNijk number := 0;
		nuSumLogNijk number := 0;
		nuSumLogRho number := 0;
		-- 20160816 0648 Dgarcia Fix Invalid Value Error
		nuLn_Nijk number;
		nuLn_SumNijk number;
	BEGIN
		-- 2016-06-06 07:35 DGarcia Fix Factorial Sum Nijk
		tbNik.delete;
		FOR j IN 0..pkBayesianMapper.tbR(i)-1 LOOP
-- 201609121603 DGarcia Other Fix for NO DATA FOUND Error
            -- 2016-06-09 Dgarcia Improve performance
			tbNik(j+1) := pkBayesianMapper.fnuGetN2(i,j,k);

			-- 2016-08-20 DGarcia Implements Pseudo-Counter
-- 			tbNik(j+1) := pkBayesianMapper.fnuGetN2(i,j,k)+1;
			nuSumNijk := nuSumNijk + tbNik(j+1);
			-- Calculate Sum of logarithms
			FOR f IN 1..tbNik(j+1) LOOP
				nuSumLogNijk := nuSumLogNijk + ln(f);
			END LOOP;
		END LOOP;
		-- Calculate logarithms Sum
		FOR f IN 1..nuSumNijk LOOP
			nuLogSumNijk := nuLogSumNijk + ln(f);
		END LOOP;
		-- Calculate Rho's
		FOR j IN 0..pkBayesianMapper.tbR(i)-1 LOOP
			-- 20160816 0648 Dgarcia Fix Invalid Value Error by ln(0)=-Infinity
			BEGIN
				nuLn_Nijk := ln(tbNik(j+1));
			EXCEPTION
				WHEN VALUE_ERROR THEN  -- ln(0)
					nuLn_Nijk := pkBayesianMapper.cnuLnEpsilon;
			END;
			BEGIN
				nuLn_SumNijk := ln(nuSumNijk);
			EXCEPTION
				WHEN VALUE_ERROR THEN  -- ln(0)
					nuLn_SumNijk := pkBayesianMapper.cnuLnEpsilon;
			END;
			nuSumLogRho := nuSumLogRho + tbNik(j+1) * (nuLn_Nijk - nuLn_SumNijk);
		END LOOP;
		RETURN nuSumLogRho; --nuLogSumNijk - nuSumLogNijk + nuSumLogRho;
		--RETURN nuLogSumNijk - nuSumLogNijk + nuSumLogRho;
-- 201609121603 DGarcia Other Fix for NO DATA FOUND Error
/*    EXCEPTION
        WHEN OTHERS THEN
			-- dbms_output.put_line('tbNik(1)='||tbNik(1)||' - tbNik(2)='||tbNik(2));

            raise;
*/
	END fnuLogLikelihoodHelper;

	----------------------------------------------------------------------------------
   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        fnuLogLikelihood
    * Description: Calculate Logarithm of Likelihood function asociated with adjacency matrix pkBayesianMapper.tbAdjacencyMatrix
	*
    * Author:      Diego Garcia
    * Date:        02th Jun 2016
	*
    * Parametros	:  Descripcion
    * inuVar              Variable to update
    *
    * Modification Log:
    * ---------------------------
    * 2016-06-01   Diego Garcia    Creation.
    */
    FUNCTION fnuLogLikelihood(inuVar in integer)
	RETURN NUMBER
	IS
		nuLogLikelihood number := 0;
		nuQi number;
	BEGIN
		IF (NOT pkBayesianMapper.gblCPTcacheON) THEN
			tbLogLikelihood.delete;
		END IF;
		FOR i IN 1..pkBayesianMapper.tbR.COUNT LOOP
			--dbms_output.put('i='||i);
			IF (i = inuVar OR NOT pkBayesianMapper.gblCPTcacheON) THEN

				tbLogLikelihood(i) := 0;
				nuQi := pkBayesianMapper.fnuGetQ(i);
				FOR k IN 1..nuQi LOOP
					-- Log Coef multinomial
					-- Sum log Pho
					--dbms_output.put_line(' Before fnuLogLikelihoodHelper');
					tbLogLikelihood(i) := tbLogLikelihood(i) + fnuLogLikelihoodHelper(i,k);
					--dbms_output.put_line('k='||k||' After fnuLogLikelihoodHelper');
					--dbms_output.new_line;
				END LOOP;

			END IF;
			nuLogLikelihood := nuLogLikelihood + tbLogLikelihood(i);
		END LOOP;

		RETURN nuLogLikelihood;

-- 201609121603 DGarcia Other Fix for NO DATA FOUND Error
/*
    EXCEPTION
        WHEN VALUE_ERROR THEN  -- ln(0)
            return to_binary_float('-inf'); -- Likelihood = 0 => Ln(Likelihood) = -Infinity
*/
	END fnuLogLikelihood;

   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        fnuLogLikelihoodPartial
    * Description: Calculate partially the Logarithm of Likelihood function asociated with adjacency matrix pkBayesianMapper.tbAdjacencyMatrix
	*
    * Author:      Diego Garcia
    * Date:        14th Jun 2016
	*
    * Parametros	:  Descripcion
    * inuVar              Variable to be updated
    *
    * Modification Log:
    * ---------------------------
    * 2016-06-14   Diego Garcia    Creation.
    */
    FUNCTION fnuLogLikelihoodPartial(inuVar in integer)
	RETURN NUMBER
	IS
		nuLogLikelihoodPartial number := 0;
		nuQi number := pkBayesianMapper.fnuGetQ(inuVar);
	BEGIN
		FOR k IN 1..nuQi LOOP
			-- Log Coef multinomial
			-- Sum log Pho
			nuLogLikelihoodPartial := nuLogLikelihoodPartial + fnuLogLikelihoodHelper(inuVar,k);
		END LOOP;
		RETURN nuLogLikelihoodPartial;
-- 201609121603 DGarcia Other Fix for NO DATA FOUND Error
/*    EXCEPTION
        WHEN VALUE_ERROR THEN  -- ln(0)
            return to_binary_float('-inf'); -- Likelihood = 0 => Ln(Likelihood) = -Infinity
            */
	END fnuLogLikelihoodPartial;


END pkLikelihood;
/
