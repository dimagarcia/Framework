CREATE OR REPLACE PACKAGE pkGeneExpression
IS
   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        pkGeneExpression
    * Description: Gene Expression Package
    * Author:      Diego Garcia
    * Date:        01th July 2017
    *
    * Modification Log:
    * ---------------------------
    * 2019-03-31    Diego Garcia    Add global variable : gvcSamplesName
    *                               Medify method: Initialize
    *                               Use  gvcSamplesName variable to make SQL sentence
    * 2017-07-05    Diego Garcia   Add Method:  fnuGetN3
    * 2017-07-04    Diego Garcia   Add Methods:  fnuGetN2 and loadCPT
    * 2017-07-01   Diego Garcia    Creation.
    */
   --------------------------------------------
   -- Global variables
   --------------------------------------------
    --------------------------------------------------------------------
    -- GENE EXPRESSION INSTANCE
    --------------------------------------------------------------------
    TYPE tytbGeneExpr IS TABLE OF BINARY_INTEGER INDEX BY BINARY_INTEGER;
    TYPE tytbMicroarr IS TABLE OF tytbGeneExpr INDEX BY BINARY_INTEGER;
    tbMicroarray tytbMicroarr;
    tbGeneExpr tytbGeneExpr;
    gvcSamplesName varchar2(100);
    --------------------------------------------------------------------
    TYPE tyCursor IS REF CURSOR;

   -- Methods
   /*****************************************************************
   Unidad   : fsbVersion
   Descripcion : Obtiene la version del paquete
   ******************************************************************/
   FUNCTION fsbVersion
      RETURN VARCHAR2;
   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        fnuGetN
    * Description: Get Nijk (Denote the number of samples for which
    *   Vi is in state j AND pa(Vi) is instate k.
    * Author:      Diego Garcia
    * Date:        01th July 2017
    *
    * Parametros	:  Descripcion
    *  itbGeneExpr     Input vector that cointain the pair: gene / expression value.
    *                   The event that match will be counted from samples
    *                   Example:  Gene 1 / Expression value 2, Gene 3 / Expression value 2,..
    *                   tbGeneExpr(1) := 2;
    *                   tbGeneExpr(3) := 2;
    *                   :
    * Modification Log:
    * ---------------------------
    * 2017-07-01   Diego Garcia    Creation.
    */
    FUNCTION fnuGetN(itbGeneExpr IN tytbGeneExpr) RETURN INTEGER;
   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        fnuGetN
    * Description: Get Nijk (Denote the number of samples for which
    *   Vi is in state j AND pa(Vi) is instate k.
    * Author:      Diego Garcia
    * Date:        01th July 2017
    *
    * Parametros	:  Descripcion
    *  i               Child node
    *  j               Child node value
    *  k               Values combination of the current variable Parents
    * Modification Log:
    * ---------------------------
    * 2017-07-01   Diego Garcia    Creation.
    */
   FUNCTION fnuGetN (nuI IN NUMBER, nuJ IN NUMBER, nuK IN NUMBER)
      RETURN NUMBER;

      ---------------------------------------------------------------------------------------------------------
      PROCEDURE loadCPT (inuI IN NUMBER);

   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        fnuGetN2
    * Description: Get Nijk (Denote the number of samples for which
    *   Vi is in state j AND pa(Vi) is instate k.
    * Author:      Diego Garcia
    * Date:        04th July 2017
    *
    * Parametros	:  Descripcion
    *  i               Child node
    *  j               Child node value
    *  k               Values combination of the current variable Parents    * Modification Log:
    * ---------------------------
    * 2017-07-04   Diego Garcia    Creation.
    */
   FUNCTION fnuGetN2 (nuI IN NUMBER, nuJ IN NUMBER, nuK IN NUMBER)
      RETURN NUMBER;

   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        fnuGetN3
    * Description: Get Nijk (Denote the number of samples for which
    *   Vi is in state j AND pa(Vi) is instate k.
    * Author:      Diego Garcia
    * Date:        05th July 2017
    *
    * Parametros	:  Descripcion
    *  i               Child node
    *  j               Child node value
    *  k               Values combination of the current variable Parents    * Modification Log:
    * ---------------------------
    * 2017-07-05   Diego Garcia    Creation.
    */
   FUNCTION fnuGetN3 (nuI IN NUMBER, nuJ IN NUMBER, nuK IN NUMBER)
      RETURN NUMBER;

END pkGeneExpression;
/
