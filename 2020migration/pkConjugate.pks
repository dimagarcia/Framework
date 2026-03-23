CREATE OR REPLACE PACKAGE pkConjugate
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
    * 2018-09-18    Diego Garcia    Remove methods: saveAllHypParam, saveHypParams_ik (Deprecated)
    *                                               fnuDDirichlet(inuI in integer, inuK in integer)
    * 2017-07-05    Diego Garcia    Modify Method: fnuPosteriorHelper
    *                               Replace Call to pkGeneExpression.fnuGetN
    *                               by pkGeneExpression.fnuGetN3
    * 2017-07-01    Diego Garcia    Modify Method: fnuPosteriorHelper
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
    
    TYPE tytbRow3 IS TABLE OF pkBayesianMapper.tytbRow2
      INDEX BY BINARY_INTEGER;

    tbHyperparam    tytbRow3;
    
	tbConjugate    pkBayesianMapper.tytbRow2;
	tbPosterior    pkBayesianMapper.tytbColumn2;
	tbLogConjugate    pkBayesianMapper.tytbRow2;
	tbLogPosterior    pkBayesianMapper.tytbColumn2;
	
    TYPE tytbVector IS TABLE OF NUMBER INDEX BY binary_integer;
    tbAlpha tytbVector;
    tbX tytbVector;

    -- Clear pkConjugate.tbHyperparam
    PROCEDURE clearHypParam;
    
    -- Empty structure is initialized with hyperparamters value equal to 2
    PROCEDURE initHypParam;
    
    PROCEDURE clearConjugate;
    
   -- Save All tbHyperparam
   -- PROCEDURE saveAllHypParam;
    -- Save tbHyperparam(i)(1)(k)..tbHyperparam(i)(r_i)(k)
    --PROCEDURE saveHypParams_ik(nuI IN integer, nuK IN integer);

    FUNCTION fnuCallDDirichletR(i IN integer, k IN integer)
	RETURN NUMBER;
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
	-- Author: Diego Garcia
	-- Date:   07-Jun-2017
    -- Parametros	:  Descripcion
    --  i               Current Variable
    --  k               Values combination of the current variable Parents
	-- Modification Log:
	-- 07-Jun-2017 Diego Garcia    Creation.
    */
    FUNCTION fnuPosteriorHelper(i IN integer, k IN integer)
	RETURN NUMBER;

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
	RETURN NUMBER;

    PROCEDURE clearLogConjugate;

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
    * inuVar           Variable to update
    *
    * Modification Log:
    * ---------------------------
    * 2017-06-07   Diego Garcia    Creation.
    */
    FUNCTION fnuPosteriorPartial(inuVar in integer)
	RETURN NUMBER;

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
	RETURN NUMBER;

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
	RETURN NUMBER;

    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    FUNCTION fnuDDirichlet(itbX in tytbVector, itbAlpha in tytbVector)
    RETURN NUMBER;
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    FUNCTION fnuDDirichlet(itbAlpha in tytbVector)
    RETURN NUMBER;
END pkConjugate;
/
