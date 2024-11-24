CREATE OR REPLACE PACKAGE pkFiltering
IS
   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        pkFilteringRules
    * Description: Filtering Rules Package
    * Author:      Diego Garcia
    * Date:        27th September 2016
    *
    * Modification Log:
    * ---------------------------
    * 2016-09-27   Diego Garcia    Creation.
    * 2017-06-22   Diego Garcia    Add Methods: Include support Log Posterior Distribution (Dirichlet)
    *                               GetRho2(inuI)
    *                               GetPofChildGivenParents2(inuI)
    *                               GetPofOldParents2(inuI,inuP)
    *                               GetPofAllWithoutCandidate2(inuI,inuP)
    *                               fnuGetEpsilon2(inuP, inuI)
    * 2017-07-24    Diego Garcia    Modify method: fnuGetEpsilon2
    *                                               Replace called to GetPofOldParents2 per GetPofOldParents3
    *                                               Replace called to GetPofAllWithoutCandidate2 per GetGetPofAllWithoutCandidate3PofOldParents3
    *                                              GetRho2
    *                                               Replace calling pkBayesianMapper.fnuGetN2
    *                                               by pkGeneExpression.fnuGetN3
    *                               Add method: GetPofOldParents3
    *                                           GetPofAllWithoutCandidate3
    *                                               Using pkGeneExpression package
    *
    */
   --------------------------------------------
   -- Global variables
   --------------------------------------------

   -- Data structures
   tbStates pkBayesianMapper.tytbRow2;


   TYPE tytb3d IS TABLE OF pkBayesianMapper.tytbRow2 INDEX BY BINARY_INTEGER;
   tbRho tytb3d;

   tbPofChildGivenParents pkBayesianMapper.tytbColumn2;
   tbPofOldParents pkBayesianMapper.tytbColumn2;
   tbPofAllGivenCandidate pkBayesianMapper.tytbColumn2;
   tbPofAllWithoutCandidate pkBayesianMapper.tytbColumn2;


  -- Methods
   /**
   ***************************************************************
   Unidad   : fsbVersion
   Descripcion : Obtiene la version del paquete
   *****************************************************************
   */
   FUNCTION fsbVersion
      RETURN VARCHAR2;

   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        GetRho
    * Description: Rho i,j,k is the probability of variable Vi in state j
    *               conditioned on that pa(Vi) is in state k
    * Author:      Diego Garcia
    * Date:        13th September 2016
    * Parametros :  Descripcion
    * -             -
    *
    * Modification Log:
    * ---------------------------
    * 2016-09-13   Diego Garcia    Creation.
    */
   PROCEDURE GetRho;
   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        GetRho
    * Description: Rho i,j,k is the probability of variable Vi in state j
    *               conditioned on that pa(Vi) is in state k
    * Author:      Diego Garcia
    * Date:        13th September 2016
    * Parametros :  Descripcion
    * inuI          Vi variable or node
    *
    * Modification Log:
    * ---------------------------
    * 2016-09-13   Diego Garcia    Creation.
    */
   PROCEDURE GetRho(inuI in integer);

   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        GetPofChildGivenParents
    * Description: Obtain the probability of variable inuI (Vi) Given
    *              their parents pa(Vi). this is P(Vi|pa(Vi))
    * Author:      Diego Garcia
    * Date:        13th September 2016
    * Parametros :  Descripcion
    * inuI          I variable corresponding to child node (Vi)
    *
    * Modification Log:
    * ---------------------------
    * 2016-09-13   Diego Garcia    Creation.
    */
   PROCEDURE GetPofChildGivenParents(inuI in number);

   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        GetPofOldParents
    * Description: Obtain the probability of old parents of variable inuI (Vi).
    *               this is P(Old pa(Vi))
    * Author:      Diego Garcia
    * Date:        13th September 2016
    * Parametros :  Descripcion
    * inuI          I variable corresponding to child node
    * inuP          parent node candidate
    *
    * Modification Log:
    * ---------------------------
    * 2016-09-13   Diego Garcia    Creation.
    */
   PROCEDURE GetPofOldParents(inuI in number, inuP in number);

   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        GetStates
    * Description: Obtain states correspond to variables Child and Parents
    * Author:      Diego Garcia
    * Date:        8th October 2016
    * Parametros :  Descripcion
    * inuI          Variable correspond to child node
    *
    * Modification Log:
    * ---------------------------
    * 2016-10-08   Diego Garcia    Creation.
    */
    PROCEDURE  GetStates(inuI in integer);

   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        GetPofAllGivenCandidate
    * Description:  Calculate product of the probability of variable inuI (Vi) Given
    *              their parents pa(Vi) by the probability of old parents of variable inuI (Vi)
    * Author:      Diego Garcia
    * Date:        07th September 2016
    * Parametros :  Descripcion
    * -             -
    *
    * Modification Log:
    * ---------------------------
    * 2016-09-07   Diego Garcia    Creation.
    */
    PROCEDURE GetPofAllGivenCandidate;

   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        GetPofAllWithoutCandidate
    * Description: Obtain the probability of variable Vi(inuI) And their old parents.
    *               this is P(Vi And Old pa(Vi))
    * Author:      Diego Garcia
    * Date:        13th September 2016
    * Parametros :  Descripcion
    * inuI          I variable corresponding to child node
    * inuP          parent node candidate
    *
    * Modification Log:
    * ---------------------------
    * 2016-09-13   Diego Garcia    Creation.
    */
   PROCEDURE GetPofAllWithoutCandidate(inuI in number, inuP in number);

   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        fnuGetEpsilon
    * Description:  Calculate almost independence between a variable or node given
    *               and a varible or node candidate to parent for it
    * Author:      Diego Garcia
    * Date:        07th October 2016
    * Parametros :  Descripcion
    * inuP          parent node candidate
    * inuI          I variable corresponding to child node
    *
    * Modification Log:
    * ---------------------------
    * 2016-09-07   Diego Garcia    Creation.
    */
    FUNCTION fnuGetEpsilon(inuP in number, inuI in number) RETURN number;

   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        fnuGetInGrade
    * Description:  Obtain In  Grade of a node given
    * Author:      Diego Garcia
    * Date:        05th October 2016
    * Parametros :  Descripcion
    * inuI          I variable corresponding to child node
    *
    * Modification Log:
    * ---------------------------
    * 2016-10-05   Diego Garcia    Creation.
    */
    FUNCTION fnuGetInGrade (inuI in number)  RETURN integer;

   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        ApplyPostOptimalStrategy
    * Description:  Apply Post-Optimal Strategy to Graphs of Optimal-Level
    * Author:      Diego Garcia
    * Date:        17th November 2016
    * Parametros :  Descripcion
    * inuFrom       Index from where will begin loading
    *
    * Modification Log:
    * ---------------------------
    * 2016-11-17   Diego Garcia    Creation.
    */
    PROCEDURE ApplyPostOptimalStrategy (inuFrom in number);  -- prune

   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        GetRho2
    * Description: Rho i,j,k is the probability of variable Vi in state j
    *               conditioned on that pa(Vi) is in state k
    * Author:      Diego Garcia
    * Date:        22th June 2017
    * Parametros :  Descripcion
    * inuI          Vi variable or node
    *
    * Modification Log:
    * ---------------------------
    * 2017-06-22   Diego Garcia    Creation.
    * 2017-07-24    Diego Garcia    Replace calling pkBayesianMapper.fnuGetN2
    *                               by pkGeneExpression.fnuGetN3
    */
   PROCEDURE GetRho2(inuI in integer);

   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        GetPofChildGivenParents2
    * Description: Obtain the probability of variable inuI (Vi) Given
    *              their parents pa(Vi). this is P(Vi|pa(Vi))
    * Author:      Diego Garcia
    * Date:        23th June 2017
    * Parametros :  Descripcion
    * inuI          I variable corresponding to child node (Vi)
    *
    * Modification Log:
    * ---------------------------
    * 2017-06-23   Diego Garcia    Creation.
    */
   PROCEDURE GetPofChildGivenParents2(inuI in number);

   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        GetPofOldParents2
    * Description: Obtain the probability of old parents of variable inuI (Vi).
    *               this is P(Old pa(Vi))
    * Author:      Diego Garcia
    * Date:        23th June 2017
    * Parametros :  Descripcion
    * inuI          I variable corresponding to child node
    * inuP          parent node candidate
    *
    * Modification Log:
    * ---------------------------
    * 2017-06-23   Diego Garcia    Creation.
    */
   PROCEDURE GetPofOldParents2(inuI in number, inuP in number);

   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        GetPofAllWithoutCandidate2
    * Description: Obtain the probability of variable Vi(inuI) And their old parents.
    *               this is P(Vi And Old pa(Vi))
    * Author:      Diego Garcia
    * Date:        23th June 2017
    * Parametros :  Descripcion
    * inuI          I variable corresponding to child node
    * inuP          parent node candidate
    *
    * Modification Log:
    * ---------------------------
    * 2017-06-23   Diego Garcia    Creation.
    */
   PROCEDURE GetPofAllWithoutCandidate2(inuI in number, inuP in number);
   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        GetPofOldParents3
    * Description: Obtain the probability of old parents of variable inuI (Vi).
    *               this is P(Old pa(Vi))
    * Author:      Diego Garcia
    * Date:        24th July 2017
    * Parametros :  Descripcion
    * inuI          I variable corresponding to child node
    * inuP          parent node candidate
    *
    * Modification Log:
    * ---------------------------
    * 2017-07-24   Diego Garcia    Creation.
    */
   PROCEDURE GetPofOldParents3(nuI in number, nuP in number);
   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        GetPofAllWithoutCandidate3
    * Description: Obtain the probability of variable Vi(inuI) And their old parents.
    *               this is P(Vi And Old pa(Vi))
    * Author:      Diego Garcia
    * Date:        24th July 2017
    * Parametros :  Descripcion
    * inuI          I variable corresponding to child node
    * inuP          parent node candidate
    *
    * Modification Log:
    * ---------------------------
    * 2017-07-24   Diego Garcia    Creation.
    */
   PROCEDURE GetPofAllWithoutCandidate3(nuI in number, nuP in number);

   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        fnuGetEpsilon2
    * Description:  Calculate almost independence between a variable or node given
    *               and a varible or node candidate to parent for it
    * Author:      Diego Garcia
    * Date:        23th June 2017
    * Parametros :  Descripcion
    * inuP          parent node candidate
    * inuI          I variable corresponding to child node
    *
    * Modification Log:
    * ---------------------------
    * 2017-06-23   Diego Garcia    Creation.
    */
    FUNCTION fnuGetEpsilon2(inuP in number, inuI in number) RETURN number;

END pkFiltering;
/
