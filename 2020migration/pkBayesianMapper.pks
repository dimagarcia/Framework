CREATE OR REPLACE PACKAGE pkBayesianMapper
IS
   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        pkBayesianMapper
    * Description: Bayesian Mapper Package
    * Author:      Diego Garcia
    * Date:        07th April 2016
    *
    * Modification Log:
    * ---------------------------
    * 2016-04-07   Diego Garcia    Creation.
    * 2016-05-05   Diego Garcia    Add Collection:  tbPowerMatrix
    *                                   tbPositionsMatrix
    *                              Add procedure:   insPowerMatrix
    *                              Add function:    ftbLoadMatrix
    *                                   ftbMultMatrix
    *                                   ftbIdentMatrix
    *                                   ftbTransMatrix
    *                                   ftbSumMatrix
    *                                   fsbVersion
    *                                   ftbGetPositionsMatrix
    * 2016-05-12    Diego Garcia    Drop procedure: loadAdjacencyMatrix
    *                               loadR
    *                               Modify function: fnuGetN, fnuGetQ
    * 2016-05-13    Diego Garcia    Add function: fblCompMatrix
    * 2016-06-01    Diego Garcia    Add procedure: insCondProb
    * 2016-08-17    Diego Garcia    Add constant: cnuEpsilon
    * 2016-08-18    Diego Garcia    Add function: ftbLoadMatrix
    *							    Add procedure: insMatrix
    * 2016-09-29    Diego Garcia    Modify function: fnuGetN2
    *                               Reverse Pseudo-Counting here
    *                               It will managed from Frequency2 table.
    * 2017-06-22    Diego Garcia    Add Methd: fnuGetN3
    *                                Counting of samples from Sample2
    * 2018-09-18    Diego Garcia    Drop procedure: insCondProb (deprecated)
    */

   --------------------------------------------
   -- Global variables
   --------------------------------------------
   gnuEpsilon number;
   gnuInGrade integer;
   gblCPTcacheON           BOOLEAN := FALSE;
   cnuEpsilon     CONSTANT NUMBER := 1E-128;                        -- -294.73
   cnuLnEpsilon   CONSTANT NUMBER := LN (cnuEpsilon);              --1E125*-1;

   -- Data structures
   TYPE tytbColumn IS TABLE OF INTEGER                          --VARCHAR2 (1)
      INDEX BY BINARY_INTEGER;


   TYPE tytbRow IS TABLE OF tytbColumn
      INDEX BY BINARY_INTEGER;


   tbAdjacencyMatrix       tytbRow;
   tbPowerMatrix           tytbRow;
   tbPositionsMatrix       tytbRow;



   TYPE tytbColumn2 IS TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;


   TYPE tytbRow2 IS TABLE OF tytbColumn2
      INDEX BY BINARY_INTEGER;


   tbCPT                   tytbRow2;

   tbR                     tytbColumn2;

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
    * Name:        fnuGetQ
    * Description: Calculate possible values for the joint
    *               state of the parents of Vi
    * Author:      Diego Garcia
    * Date:        13th April 2016
    *
    * Modification Log:
    * ---------------------------
    * 2016-04-13   Diego Garcia    Creation.
    * 2016-05-12   Diego Garcia   Modify adjacency matrix structure
    */
   FUNCTION fnuGetQ (nuI IN NUMBER)
      RETURN NUMBER;

   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        fnuGetN
    * Description: Get Nijk (Denote the number of samples for which
    *   Vi is in state j AND pa(Vi) is instate k.
    * Author:      Diego Garcia
    * Date:        07th April 2016
    *
    * Modification Log:
    * ---------------------------
    * 2016-04-07   Diego Garcia   Creation.
    * 2016-05-12   Diego Garcia   Modify adjacency matrix structure
    */
   FUNCTION fnuGetN (nuI IN NUMBER, nuJ IN NUMBER, nuK IN NUMBER)
      RETURN NUMBER;

   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        fnuGetN2
    * Description: Get Nijk (Denote the number of samples for which
    *   Vi is in state j AND pa(Vi) is instate k.
    * Author:      Diego Garcia
    * Date:        07th April 2016
    *
    * Modification Log:
    * ---------------------------
    * 2016-04-07   Diego Garcia    Creation.
    * 2016-05-12   Diego Garcia   Modify adjacency matrix structure
    * 2016-06-09   Diego Garcia   Improve perfomance
    */
   FUNCTION fnuGetN2 (nuI IN NUMBER, nuJ IN NUMBER, nuK IN NUMBER)
      RETURN NUMBER;

   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        fnuGetN3
    * Description: Get Nijk (Denote the number of samples for which
    *   Vi is in state j AND pa(Vi) is instate k.
    * Author:      Diego Garcia
    * Date:        22th June 2017
    *
    * Modification Log:
    * ---------------------------
    * 2017-06-22   Diego Garcia    Creation.
    */
   FUNCTION fnuGetN3 (nuI IN NUMBER, nuJ IN NUMBER, nuK IN NUMBER)
      RETURN NUMBER;

   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:         fnuGetRho
    * Description:
    *               Rho i,j,k is the probability of variable
    *               Vi in state j conditioned on that pa(Vi) is in state k
    * Author:       Diego Garcia
    * Date:         07th April 2016
    *
    * Modification Log:
    * ---------------------------
    * 2016-04-07   Diego Garcia    Creation.
    */
   FUNCTION fnuGetRho (nuI IN NUMBER, nuJ IN NUMBER, nuK IN NUMBER)
      RETURN NUMBER;


   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        ftbLoadMatrix
    * Description: Load power matrix from power_matrix table
    *
    * Author:      Diego Garcia
    * Date:        05th May 2016
    *
    * Modification Log:
    * ---------------------------
    * 2016-05-05   Diego Garcia    Creation.
    */
   FUNCTION ftbLoadMatrix (inuPow IN INTEGER)
      RETURN tytbRow;


   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        ftbMultMatrix
    * Description: Multiplication power matrix by adjacency matrix
    *
    * Author:      Diego Garcia
    * Date:        05th May 2016
    *
    * Modification Log:
    * ---------------------------
    * 2016-05-05   Diego Garcia    Creation.
    */
   FUNCTION ftbMultMatrix (itbPowerMatrix IN tytbRow)
      RETURN tytbRow;

   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        insPowerMatrix
    * Description: Insert power matrix
    *
    * Author:      Diego Garcia
    * Date:        05th May 2016
    *
    * Modification Log:
    * ---------------------------
    * 2016-05-05   Diego Garcia    Creation.
    */
   PROCEDURE insPowerMatrix (itbPowerMatrix IN tytbRow, inuPow IN INTEGER);

   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        ftbIdentMatrix
    * Description: Return Identity Matrix of inuDim dimension
    *
    * Author:      Diego Garcia
    * Date:        05th May 2016
    *
    * Modification Log:
    * ---------------------------
    * 2016-05-05   Diego Garcia    Creation.
    */
   FUNCTION ftbIdentMatrix (inuDim IN INTEGER)
      RETURN tytbRow;


   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        ftbTransMatrix
    * Description: Return Transpose of the A Matrix given
    *
    * Author:      Diego Garcia
    * Date:        05th May 2016
    *
    * Modification Log:
    * ---------------------------
    * 2016-05-05   Diego Garcia    Creation.
    */
   FUNCTION ftbTransMatrix (itbMatrix IN tytbRow)
      RETURN tytbRow;


   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        ftbSumMatrix
    * Description: Return Sum of A plus B Matrix
    *
    * Parametros :  Descripcion
    * itbA              A matrix
    * itbB              B matrix
    *
    * Author:      Diego Garcia
    * Date:        05th May 2016
    *
    * Modification Log:
    * ---------------------------
    * 2016-05-05   Diego Garcia    Creation.
    */
   FUNCTION ftbSumMatrix (itbA IN tytbRow, itbB IN tytbRow)
      RETURN tytbRow;


   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        ftbGetPositionsMatrix
    * Description: Return positions in matrix with 1 or 0
    *
    * Parametros :  Descripcion
    * itbMatrix             matrix
    * inuBitin              1 or 0
    *
    * Author:      Diego Garcia
    * Date:        05th May 2016
    *
    * Modification Log:
    * ---------------------------
    * 2016-05-05   Diego Garcia    Creation.
    */
   FUNCTION ftbGetPositionsMatrix (itbMatrix IN tytbRow, inuBitin IN INTEGER)
      RETURN tytbRow;

   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        fblCompMatrix
    * Description: Compare Two Matrices and Return True if are equal
    *
    * Parametros :  Descripcion
    * itbA             A matrix
    * itbB             B matrix
    *
    * Author:      Diego Garcia
    * Date:        13th May 2016
    *
    * Modification Log:
    * ---------------------------
    * 2016-05-13   Diego Garcia    Creation.
    */
   FUNCTION fblCompMatrix (itbA IN tytbRow, itbB IN tytbRow)
      RETURN BOOLEAN;

   /**
   * Propiedad intelectual de la Universidad del Valle
   * Name:        ftbLoadMatrix
   * Description: Load matrix from power_matrix or adjacency_matrix_log table
   *
   * Author:      Diego Garcia
   * Date:        18th Aug 2016
   *
   * Modification Log:
   * ---------------------------
   * 2016-08-18   Diego Garcia    Creation.
   */
   FUNCTION ftbLoadMatrix (inuPow IN INTEGER, iblPower in boolean)
      RETURN tytbRow;
   /**
   * Propiedad intelectual de la Universidad del Valle
   * Name:        ftbLoadMatrix
   * Description: Load matrix from power_matrix or adjacency_matrix_log table
   *
   * Author:      Diego Garcia
   * Date:        18th Aug 2016
   *
   * Modification Log:
   * ---------------------------
   * 2016-08-18   Diego Garcia    Creation.
   */
   FUNCTION ftbLoadMatrix (inuPow IN INTEGER, iblPower in boolean, inuStrategy in integer)
      RETURN tytbRow;

   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        insMatrix
    * Description: Insert into power or adjacency matrix table
    *
    * Author:      Diego Garcia
    * Date:        18th Aug 2016
    *
    * Modification Log:
    * ---------------------------
    * 2016-08-18   Diego Garcia    Creation.
    */
   PROCEDURE insMatrix (itbPowerMatrix IN tytbRow, inuPow IN INTEGER, iblPower in boolean);

   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        insMatrix
    * Description: Insert into power or adjacency matrix table
    *
    * Author:      Diego Garcia
    * Date:        18th Aug 2016
    *
    * Modification Log:
    * ---------------------------
    * 2016-08-18   Diego Garcia    Creation.
    */
   PROCEDURE insMatrix (itbPowerMatrix IN tytbRow, inuPow IN INTEGER, iblPower in boolean, inuStrategy in number);

END pkBayesianMapper;
/
