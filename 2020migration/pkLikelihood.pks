CREATE OR REPLACE PACKAGE pkLikelihood
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

	tbLogLikelihood pkBayesianMapper.tytbColumn2;
	tbNik pkBayesianMapper.tytbColumn2;

    FUNCTION fnuLogLikelihood(inuVar in integer)
	RETURN NUMBER;

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
	RETURN NUMBER;


END pkLikelihood;
/
