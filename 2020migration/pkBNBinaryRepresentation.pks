CREATE OR REPLACE PACKAGE pkBNBinaryRepresentation
IS
   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        pkBNBinaryRepresentation
    * Description: Bayesian Nerwork Binary Representation Package
    * Author:      Diego Garcia
    * Date:        11th November 2016
    *
    * Modification Log:
    * ---------------------------
    * 2016-11-11   Diego Garcia    Creation.
    * 2017-07-26    Diego Garcia    Modify method: LoadMassivelyBNBR
    *                               Modify CURSOR to query in adjacency_matrix_log table
    *                               and including strategy parameter
    *                               modify size of global variable : gsbIdxBNBR
    *                               modify size of type: tytbBNBR
    * 2019-03-06 Diego Garcia       Add  Method IterLoadMassivelyBNBR
    */
   --------------------------------------------
   -- Global variables
   --------------------------------------------
   --gsbIdxBNBR varchar2(25);
   gsbIdxBNBR varchar2(256);
   gnuStrategyPost constant number := 4; -- Post-Optimal
   gnuWithoutStrategy constant number := 0; -- Post-Optimal

   -- Data structures
   TYPE tytbBNBR IS TABLE OF integer INDEX BY varchar2(256);
   tbBNBR tytbBNBR;

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
    * Name:        ClearBNBR
    * Description:  Clear Bayesian Nerwork Binary Representation
    * Author:      Diego Garcia
    * Date:        11th November 2016
    * Parametros :  Descripcion
    * -             -
    *
    * Modification Log:
    * ---------------------------
    * 2016-11-11   Diego Garcia    Creation.
    */
   PROCEDURE ClearBNBR;

   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        LoadBNBR
    * Description:  Load Bayesian Nerwork Binary Representation From A Adjacency Matrix Given
    * Author:      Diego Garcia
    * Date:        11th November 2016
    * Parametros :  Descripcion
    * itbAdjMatrix  Adjacency Matrix to Loading
    *
    * Modification Log:
    * ---------------------------
    * 2016-11-11   Diego Garcia    Creation.
    */
   PROCEDURE LoadBNBR (itbAdjMatrix IN pkBayesianMapper.tytbRow);

   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        LoadMassivelyBNBR
    * Description:  Load Massively Bayesian Nerwork Binary Representation From Adjacency_Matrix_Log Table
    * Author:      Diego Garcia
    * Date:        11th November 2016
    * Parametros :  Descripcion
    * inuFrom       Index from where will begin loading
    * inuTo         Index until where will go loading
    *
    * Modification Log:
    * ---------------------------
    * 2016-11-11   Diego Garcia    Creation.
    * 2017-07-26    Diego Garcia    Modify CURSOR to query in adjacency_matrix_log table
    *                               and including strategy parameter
    */
   PROCEDURE LoadMassivelyBNBR (inuFrom IN integer, inuTo IN integer, inuStrategy in number);

   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        PrintBNBR
    * Description:  Print Bayesian Nerwork Binary Representation
    * Author:      Diego Garcia
    * Date:        11th November 2016
    * Parametros :  Descripcion
    * -             -
    *
    * Modification Log:
    * ---------------------------
    * 2016-11-11   Diego Garcia    Creation.
    */
   PROCEDURE PrintBNBR;

   /**
   * Propiedad intelectual de la Universidad del Valle
   * Name:        ftbLoadAdjMatrix
   * Description: Load matrix from tbBNBR to adjacency matrix table
   * Author:      Diego Garcia
   * Date:        17th Nov 2016
   * Parametros :  Descripcion
   * isbIdxBNBR    Index of Bayesian Network Binary Representation Table
   *
   * Modification Log:
   * ---------------------------
   * 2016-11-17   Diego Garcia    Creation.
   */
   FUNCTION ftbLoadAdjMatrix (isbIdxBNBR IN VARCHAR2)
      RETURN pkBayesianMapper.tytbRow;

   /**
   * Propiedad intelectual de la Universidad del Valle
   * Name:        PrintAdjMatrix
   * Description: Print Adjacency Matrix
   *
   * Parametros :  Descripcion
   * itbAdjMatrix  Adjacency Matrix to loading
   *
   * Author:      Diego Garcia
   * Date:        11th Aug 2016
   *
   * Modification Log:
   * ---------------------------
   * 2016-08-11   Diego Garcia    Creation.
   */
   PROCEDURE PrintAdjMatrix (itbAdjMatrix in pkBayesianMapper.tytbRow);
   
   PROCEDURE IterLoadMassivelyBNBR (inuNumSim IN INTEGER, inuFrom IN integer, inuTo IN integer, inuStrategy in number);

END pkBNBinaryRepresentation;
/
