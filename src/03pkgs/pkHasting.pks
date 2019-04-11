CREATE OR REPLACE PACKAGE pkHasting
IS
   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        pkHasting
    * Description: Metropolis Hasting Package
    * Author:      Diego Garcia
    * Date:        27th April 2016
    *
    * Modification Log:
    * ---------------------------
    * 2016-04-27   Diego Garcia    Creation.
    * 2016-05-12   Diego Garcia    Modify procedure: metropolis
    *                               Add procedure: withoutLikelihood, simulationLikelihood
    *                               Initialize
    * 2016-08-08   Diego Garcia     Fix calculate transition probability between x and x' graphs
    *                               and implementation of edge reverse operator
    * 2016-09-29    Diego Garcia    Enable calculate Local LogLikelihood
    * 2017-06-07    Diego Garcia    Add procedure : simulationPosterior
    *                               Implementation of MH algorithm usign
    *                               Conjugate Distribution (Diritchlet) of Multinomial Model
    *                               as Stationary distribution.
    * 2017-06-12    Diego Garcia    Add method: simulationLogPosterior
    * 2017-06-16    Diego GArcia    modify method: simulationLogPosterior
    *                               comment compare adjacency matix with the original matrix
    * 2017-06-22    Diego Garcia    Add method: iterationSimulaLogPosterior
    * 2017-07-24    Diego Garcia    Modify method: iterationSimulaLogPosterior
    * 2017-07-28    Diego Garcia    Modify method: simulationLogPosterior
    *                               Add function : FindMinorEpsilonEdge
    * 2018-09-18    Diego Garcia    Modify method: simulationPosterior
    *                               pkConjugate.saveAllHypParam (Deprecated)
    */

   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        simulationLikelihood
    * Description: Bayesian structure learning with score likelihood function
    *
    * Parametros :  Descripcion
    * -            -
    *
    * Author:      Diego Garcia
    * Date:        12th May 2016
    *
    * Modification Log:
    * ---------------------------
    * 2016-05-12   Diego Garcia    Creation.
    */
   PROCEDURE simulationLikelihood (inuNumSim IN INTEGER);

   PROCEDURE withoutLikelihood;

   PROCEDURE metropolis;
-- Tests
  /**
   * Propiedad intelectual de la Universidad del Valle
   * Name:        Initialize
   * Description: Initialize power matrix table with Zeros (0)
   *
   * Parametros :  Descripcion
   * -            -
   *
   * Author:      Diego Garcia
   * Date:        12th May 2016
   *
   * Modification Log:
   * ---------------------------
   * 2016-05-12   Diego Garcia    Creation.
   */
--PROCEDURE Initialize;

   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        simulationLikelihood
    * Description: Bayesian structure learning with score likelihood function
    *
    * Parametros :  Descripcion
    * -            -
    *
    * Author:      Diego Garcia
    * Date:        12th May 2016
    *
    * Modification Log:
    * ---------------------------
    * 2016-05-12   Diego Garcia    Creation.
    * 2016-08-08   Diego Garcia     Fix calculate transition probability between x and x' graphs
    *                              and implementation of  edge reverse operator
    */
   PROCEDURE simulationLikelihood (inuNumSim IN INTEGER, inuStrategy in integer);

   PROCEDURE Initialize;
   
--------------------------------------------------------------------------------
   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        simulationPosterior
    * Description: Bayesian structure learning with score likelihood function
    *
    * Parametros :  Descripcion
    * -            -
    *
    * Author:      Diego Garcia
    * Date:        07th Jun 2017
    *
    * Modification Log:
    * ---------------------------
    * 2017-06-07   Diego Garcia    Creation.
    */
   PROCEDURE simulationPosterior (inuNumSim IN INTEGER, inuStrategy in integer);
   /*
    * Propiedad intelectual de la Universidad del Valle
    * Name:        simulationLogPosterior
    * Description: Bayesian structure learning with score Log Posterior function
    *
    * Parametros :  Descripcion
    * inuNumSim     Number of iterations
    * inuStrategy   Strategy to avoid overfitting (0- Without Strategy,
    *               1- NearIndependence, 2- Ingrade constraint, 12 - 1 and 2)
    * Author:      Diego Garcia
    * Date:        012th Jun 2017
    *
    * Modification Log:
    * ---------------------------
    * 2017-06-012   Diego Garcia    Creation.
    */
   PROCEDURE simulationLogPosterior (inuNumSim IN INTEGER, inuStrategy in integer,
                                     inuT IN INTEGER DEFAULT NULL);
--------------------------------------------------------------------------------
   /*
    * Propiedad intelectual de la Universidad del Valle
    * Name:        iterationSimulaLogPosterior
    * Description: Bayesian structure learning with score Log Posterior function
    *
    * Parametros :  Descripcion
    * inuMaxAttempts   Number maximum of attempts without find news structures
    * inuNumSim     Number of iterations
    * inuStrategy   Strategy to avoid overfitting (0- Without Strategy,
    *               1- NearIndependence, 2- Ingrade constraint, 12 - 1 and 2)
    * inuMinPercAttemp  Minimal porcetage of new graphs per attemp
    * Author:      Diego Garcia
    * Date:        22th Jun 2017
    *
    * Modification Log:
    * ---------------------------
    * 2017-06-22   Diego Garcia    Creation.
    * 2017-07-24   Diego Garcia     Add parameter : inuMinPercAttemp
    */
   PROCEDURE iterationSimulaLogPosterior (  inuMaxAttempts IN integer,
                                            inuNumSim IN INTEGER,
                                            inuStrategy in integer,
                                            inuMinPercAttemp in number default 0.1);

END pkHasting;
/
