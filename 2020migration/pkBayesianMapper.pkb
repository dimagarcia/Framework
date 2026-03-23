CREATE OR REPLACE PACKAGE BODY pkBayesianMapper
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
   -- Constantes
   --------------------------------------------
   csbVersion   CONSTANT VARCHAR2 (250) := '2016-06-01';


   --------------------------------------------
   -- Funciones y Procedimientos
   --------------------------------------------
   FUNCTION fsbVersion
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN csbVersion;
   END;

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
    * 2016-04-13   Diego Garcia     Creation.
    * 2016-05-12   Diego Garcia     Modify adjacency matrix structure
    */
   FUNCTION fnuGetQ (nuI IN NUMBER)
      RETURN NUMBER
   IS
      nuQi   NUMBER := 1;
   BEGIN
      -- Calculate possible values for the joint Vj ? pa(Vi )
      -- state of the parents of Vi
      FOR k IN tbAdjacencyMatrix.FIRST .. tbAdjacencyMatrix.LAST
      LOOP
         IF (tbAdjacencyMatrix (k) (nuI) = 1)    -- Is 'k' parent of nuI :var1
         THEN
            nuQi := nuQi * tbR (k);
         END IF;
      END LOOP;

      RETURN nuQi;
   END fnuGetQ;

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
    * 2016-04-07   Diego Garcia    Creation.
    * 2016-05-12   Diego Garcia   Modify adjacency matrix structure
    */
   FUNCTION fnuGetN (nuI IN NUMBER, nuJ IN NUMBER, nuK IN NUMBER)
      RETURN NUMBER
   IS
      nuN   NUMBER := -1;
      sbS   VARCHAR2 (2000)
         :=    'SELECT SUM (f.freqvalu) as freq FROM frequency f WHERE f.sampleid IN (SELECT s'
            || nuI
            || '.sampleid';
      sbF   VARCHAR2 (2000) := ' FROM sample s' || nuI;
      sbW   VARCHAR2 (2000)
         :=    ' WHERE s'
            || nuI
            || '.variname = '
            || nuI
            || ' AND s'
            || nuI
            || '.varivalu = '
            || nuJ;
      idx   BINARY_INTEGER;

      TYPE tycu IS REF CURSOR;

      cu    tycu;

      ---------------------------------------------------------------------------------------------------------
      -- Embebed methods
      ---------------------------------------------------------------------------------------------------------
      PROCEDURE clearCPT
      IS
         idx   BINARY_INTEGER;
      BEGIN
         -- Clear tbCPT
         idx := tbCPT.FIRST;

         LOOP
            EXIT WHEN idx IS NULL;
            tbCPT (idx).delete;
            idx := tbCPT.NEXT (idx);
         END LOOP;

         tbCPT.delete;
      END clearCPT;

      ---------------------------------------------------------------------------------------------------------
      PROCEDURE loadCPT (nuI IN NUMBER)
      IS
         nuPrev   NUMBER := NULL;
         nuPos    NUMBER;
      BEGIN
         --     dbms_output.put_line('Begin loadCPT');

         -- Clear tbCPT
         clearCPT;

         -- Load tbCPT
         FOR s IN 1 .. fnuGetQ (nuI)
         LOOP
            nuPos := 0;

            FOR k IN tbAdjacencyMatrix.FIRST .. tbAdjacencyMatrix.LAST
            LOOP
               IF (tbAdjacencyMatrix (k) (nuI) = '1') -- Is 'k' parent of nuI ?
               THEN
                  --dbms_output.put_line('k:'||k||' tbR( k ):'||tbR( k )||' nuPos:'||nuPos||' nuPrev:'||nuPrev);
                  IF (nuPrev IS NULL)
                  THEN
                     tbCPT (s) (k) :=
                        MOD (CEIL (s / POWER (tbR (k), nuPos)) - 1, tbR (k));
                  ELSE
                     tbCPT (s) (k) :=
                        MOD (CEIL (s / POWER (tbR (nuPrev), nuPos)) - 1,
                             tbR (k));
                  END IF;

                  nuPrev := k;
                  nuPos := NuPos + 1;
               END IF;
            END LOOP;
         END LOOP;
      -- 20160601 12:19 DGarcia Implementation of CPT Cache
      --insCondProb(tbCPT, nuI, nuJ);
      -- 20160603 12:49 DGarcia Improve CPT Cache
      --insCondProb(tbCPT, nuI, nuJ);

      --    dbms_output.put_line('End loadCPT');
      EXCEPTION
         WHEN OTHERS
         THEN
            DBMS_OUTPUT.put_line (SQLERRM);
      END loadCPT;
   ---------------------------------------------------------------------------------------------------------
   BEGIN
      -- Determine who are nuI's parents
      ---loadAdjacencyMatrix;
      --dbms_output.put_line('nuI:'||nuI||' tbAdjacencyMatrix (nuI).FIRST:'||tbAdjacencyMatrix (nuI).FIRST||' tbAdjacencyMatrix (nuI).LAST:'||tbAdjacencyMatrix (nuI).LAST);
      ---loadR;
      loadCPT (nuI);

      --    idx :=  tbCPT.first;
      --    LOOP
      --   EXIT WHEN idx IS NULL;
      --   FOR j IN tbCPT(idx).first..tbCPT(idx).last
      --   LOOP
      --    dbms_output.put_line('tbCPT('||idx||')('||j||'):'||tbCPT(idx)(j));
      --   END LOOP;
      --   idx := tbCPT.next(idx);
      --    END LOOP;


      FOR k IN tbAdjacencyMatrix.FIRST .. tbAdjacencyMatrix.LAST
      LOOP
         IF (tbAdjacencyMatrix (k) (nuI) = '1')  -- Is 'k' parent of nuI :var1
         THEN
            -- From clause generation
            sbF := sbF || ', sample s' || k || ' ';
            -- Where clause generation
            sbW :=
                  sbW
               || CHR (10)
               || ' AND s'
               || k
               || '.variname = '
               || k
               || ' AND s'
               || k
               || '.varivalu = '
               || tbCPT (nuK) (k);                                     --idx);
            --idx := idx + 1; -- Mapping
            sbW :=
                  sbW
               || CHR (10)
               || ' AND s'
               || k
               || '.sampleid = s'
               || nuI
               || '.sampleid ';
         END IF;
      END LOOP;

      sbW := sbW || ')';

      --    DBMS_OUTPUT.put_line (sbS);
      --    DBMS_OUTPUT.put_line (sbF);
      --    DBMS_OUTPUT.put_line (sbW);

      OPEN cu FOR sbS || sbF || sbW;

      FETCH cu INTO nuN;

      CLOSE cu;


      RETURN nuN;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN -1;
   END fnuGetN;

   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        fnuGetN2
    * Description: Get Nijk (Denote the number of samples for which
    *               Vi is in state j AND pa(Vi) is instate k.
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
      RETURN NUMBER
   IS
      nuN   NUMBER := -1;
      --sbS   VARCHAR2 (2000) := 'SELECT SUM (f) as freq  FROM frequency2';
      --sbS   VARCHAR2 (2000) := 'SELECT SUM (f) as freq  FROM frequency3';
      sbS   VARCHAR2 (2000) := 'SELECT SUM (f) as freq  FROM frequency4';
      --sbS   VARCHAR2 (2000) := 'SELECT SUM (f) as freq  FROM frequency5';
      sbW   VARCHAR2 (2000) := ' WHERE v' || nuI || ' = ' || nuJ;
      idx   BINARY_INTEGER;
      TYPE tycu IS REF CURSOR;
      cu    tycu;
      ---------------------------------------------------------------------------------------------------------
      -- Embebed methods
      ---------------------------------------------------------------------------------------------------------
      PROCEDURE clearCPT
      IS
         idx   BINARY_INTEGER;
      BEGIN
         -- Clear tbCPT
         idx := tbCPT.FIRST;
         LOOP
            EXIT WHEN idx IS NULL;
            tbCPT (idx).delete;
            idx := tbCPT.NEXT (idx);
         END LOOP;
         tbCPT.delete;
      END clearCPT;
      ---------------------------------------------------------------------------------------------------------
      PROCEDURE loadCPT (nuI IN NUMBER)
      IS
         nuPrev   NUMBER := NULL;
         nuPos    NUMBER;
         nuQi    NUMBER := fnuGetQ (nuI);
      BEGIN
         --     dbms_output.put_line('Begin loadCPT');
         -- Clear tbCPT
         clearCPT;
         -- Load tbCPT
         FOR s IN 1 .. nuQi
         LOOP
            nuPos := 0;
            FOR k IN tbAdjacencyMatrix.FIRST .. tbAdjacencyMatrix.LAST
            LOOP
               IF (tbAdjacencyMatrix (k) (nuI) = '1') -- Is 'k' parent of nuI ?
               THEN
-- 				  dbms_output.put_line('k:'||k||' tbR( k ):'||tbR( k )||' nuPos:'||nuPos||' nuPrev:'||nuPrev);
                  IF (nuPrev IS NULL) THEN
                     tbCPT (s) (k) := MOD (CEIL (s / POWER (tbR (k), nuPos)) - 1, tbR (k));
                  ELSE
                     tbCPT (s) (k) := MOD (CEIL (s / POWER (tbR (nuPrev), nuPos)) - 1, tbR (k));
                  END IF;
-- 				  dbms_output.put_line('s:'||s||' k:'||k||' tbCPT (s) (k):'||tbCPT (s) (k));
                  nuPrev := k;
                  nuPos := NuPos + 1;
               END IF;
            END LOOP;
         END LOOP;
      -- 20160601 12:19 DGarcia Implementation of CPT Cache
      --insCondProb(tbCPT, nuI, nuJ);
      -- 20160603 12:49 DGarcia Improve CPT Cache
      --insCondProb(tbCPT, nuI, nuJ);

      --    dbms_output.put_line('End loadCPT');
      EXCEPTION
         WHEN OTHERS
         THEN
            DBMS_OUTPUT.put_line (SQLERRM);
      END loadCPT;
   ---------------------------------------------------------------------------------------------------------
   BEGIN
      -- Determine who are nuI's parents
      ---loadAdjacencyMatrix;
      --dbms_output.put_line('nuI:'||nuI||' tbAdjacencyMatrix (nuI).FIRST:'||tbAdjacencyMatrix (nuI).FIRST||' tbAdjacencyMatrix (nuI).LAST:'||tbAdjacencyMatrix (nuI).LAST);
      ---loadR;
      loadCPT (nuI);

-- 	  idx :=  tbCPT.first;
-- 	  LOOP
-- 		EXIT WHEN idx IS NULL;
-- 		FOR j IN tbCPT(idx).first..tbCPT(idx).last
-- 		LOOP
-- 				dbms_output.put_line('tbCPT('||idx||')('||j||'):'||tbCPT(idx)(j));
-- 		END LOOP;
-- 		idx := tbCPT.next(idx);
-- 	  END LOOP;


      FOR k IN tbAdjacencyMatrix.FIRST .. tbAdjacencyMatrix.LAST
      LOOP
         IF (tbAdjacencyMatrix (k) (nuI) = '1')  -- Is 'k' parent of nuI :var1
         THEN
            -- Where clause generation
            sbW :=
               sbW || CHR (10) || ' AND v' || k || ' = ' || tbCPT (nuK) (k);
         END IF;
      END LOOP;

      --   sbW := sbW ;
         --DBMS_OUTPUT.put_line (sbS);
      --    DBMS_OUTPUT.put_line (sbF);
         --DBMS_OUTPUT.put_line (sbW);

-- 201609121603 DGarcia Other Fix for NO DATA FOUND Error
        BEGIN
          OPEN cu FOR sbS || sbW;
          FETCH cu INTO nuN;
          CLOSE cu;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                dbms_output.put_line('NO_DATA_FOUND:'||sbS || sbW);
                -- 2016-09-29 22:02 DGarcia Reverse pseudo-counting here
                nuN := 1;
        END;

-- 201609121603 DGarcia Other Fix for NO DATA FOUND Error : Pseudo-counting
      --RETURN nuN+1;
      -- 2016-09-29 22:02 DGarcia Reverse pseudo-counting here
      RETURN nuN;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN -1;
   END fnuGetN2;

   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        fnuGetN3
    * Description: Get Nijk (Denote the number of samples for which
    *               Vi is in state j AND pa(Vi) is instate k.
    * Author:      Diego Garcia
    * Date:        22th June 2017
    *
    * Modification Log:
    * ---------------------------
    * 2017-06-22   Diego Garcia    Creation.
    */
   FUNCTION fnuGetN3 (nuI IN NUMBER, nuJ IN NUMBER, nuK IN NUMBER)
      RETURN NUMBER
   IS
      nuN   NUMBER := -1;
      sbS   VARCHAR2 (2000) := 'SELECT SUM (1) as freq  FROM sample2';
      sbW   VARCHAR2 (2000) := ' WHERE v' || nuI || ' = ' || nuJ;
      idx   BINARY_INTEGER;
      TYPE tycu IS REF CURSOR;
      cu    tycu;
      ---------------------------------------------------------------------------------------------------------
      -- Embebed methods
      ---------------------------------------------------------------------------------------------------------
      PROCEDURE clearCPT
      IS
         idx   BINARY_INTEGER;
      BEGIN
         -- Clear tbCPT
         idx := tbCPT.FIRST;
         LOOP
            EXIT WHEN idx IS NULL;
            tbCPT (idx).delete;
            idx := tbCPT.NEXT (idx);
         END LOOP;
         tbCPT.delete;
      END clearCPT;
      ---------------------------------------------------------------------------------------------------------
      PROCEDURE loadCPT (nuI IN NUMBER)
      IS
         nuPrev   NUMBER := NULL;
         nuPos    NUMBER;
         nuQi    NUMBER := fnuGetQ (nuI);
      BEGIN
         --     dbms_output.put_line('Begin loadCPT');
         -- Clear tbCPT
         clearCPT;
         -- Load tbCPT
         FOR s IN 1 .. nuQi
         LOOP
            nuPos := 0;
            FOR k IN tbAdjacencyMatrix.FIRST .. tbAdjacencyMatrix.LAST
            LOOP
               IF (tbAdjacencyMatrix (k) (nuI) = '1') -- Is 'k' parent of nuI ?
               THEN
-- 				  dbms_output.put_line('k:'||k||' tbR( k ):'||tbR( k )||' nuPos:'||nuPos||' nuPrev:'||nuPrev);
                  IF (nuPrev IS NULL) THEN
                     tbCPT (s) (k) := MOD (CEIL (s / POWER (tbR (k), nuPos)) - 1, tbR (k));
                  ELSE
                     tbCPT (s) (k) := MOD (CEIL (s / POWER (tbR (nuPrev), nuPos)) - 1, tbR (k));
                  END IF;
-- 				  dbms_output.put_line('s:'||s||' k:'||k||' tbCPT (s) (k):'||tbCPT (s) (k));
                  nuPrev := k;
                  nuPos := NuPos + 1;
               END IF;
            END LOOP;
         END LOOP;
      --    dbms_output.put_line('End loadCPT');
      EXCEPTION
         WHEN OTHERS
         THEN
            DBMS_OUTPUT.put_line (SQLERRM);
      END loadCPT;
   ---------------------------------------------------------------------------------------------------------
   BEGIN
      --dbms_output.put_line('Init pkBayesianMapper.fnuGetN3');
      -- Determine who are nuI's parents
      --dbms_output.put_line('nuI:'||nuI||' tbAdjacencyMatrix (nuI).FIRST:'||tbAdjacencyMatrix (nuI).FIRST||' tbAdjacencyMatrix (nuI).LAST:'||tbAdjacencyMatrix (nuI).LAST);
      loadCPT (nuI);

      FOR k IN tbAdjacencyMatrix.FIRST .. tbAdjacencyMatrix.LAST
      LOOP
         IF (tbAdjacencyMatrix (k) (nuI) = '1')  -- Is 'k' parent of nuI :var1
         THEN
            -- Where clause generation
            sbW :=
               sbW || CHR (10) || ' AND v' || k || ' = ' || tbCPT (nuK) (k);
         END IF;
      END LOOP;

        BEGIN
          OPEN cu FOR sbS || sbW;
          FETCH cu INTO nuN;
          CLOSE cu;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                dbms_output.put_line('NO_DATA_FOUND:'||sbS || sbW);
                nuN := 1;
        END;
        --dbms_output.put_line(nuN||' : '||sbS || sbW);
      --dbms_output.put_line('Finish pkBayesianMapper.fnuGetN3');
      RETURN NVL(nuN,0);
   EXCEPTION
      WHEN OTHERS
      THEN
         dbms_output.put_line('Error OTHERS in pkBayesianMapper.fnuGetN3:'||sbS || sbW);
         RETURN -1;
   END fnuGetN3;

   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        fnuGetRho
    * Description:
    *               Rho i,j,k is the probability of variable
    *               Vi in state j conditioned on that pa(Vi) is in state k
    * Author:      Diego Garcia
    * Date:        13th April 2016
    *
    * Modification Log:
    * ---------------------------
    * 2016-04-13   Diego Garcia    Creation.
    */
   FUNCTION fnuGetRho (nuI IN NUMBER, nuJ IN NUMBER, nuK IN NUMBER)
      RETURN NUMBER
   IS
      nuRho   NUMBER := -1;
      tot     NUMBER := 0;
   --nuResult NUMBER(12,11);
   BEGIN
      ---loadR;
      FOR j IN 0 .. tbR (nuI) - 1
      LOOP
         IF (nuJ = j)
         THEN
            nuRho := fnuGetN (nuI, j, nuK);
            tot := tot + nuRho;
         ELSE
            tot := tot + fnuGetN (nuI, j, nuK);
         END IF;
      END LOOP;

      --nuResult := nuRho/tot;
      --RETURN nuResult;
      RETURN nuRho / tot;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN -1;
   END fnuGetRho;

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
      RETURN tytbRow
   IS
      tbMatrix   tytbRow;
      nuDim      INTEGER := tbR.COUNT;

      CURSOR cuMatrix (inuPow INTEGER, nuRow INTEGER)
      IS
           SELECT pomaval
             FROM power_matrix
            WHERE pomarow = nuRow AND pomapow = inuPow
         ORDER BY pomacol;
   BEGIN
      -- Load  matrix from data base
      FOR i IN 1 .. nuDim
      LOOP
         OPEN cuMatrix (inuPow, i);

         FETCH cuMatrix BULK COLLECT INTO tbMatrix (i);

         CLOSE cuMatrix;
      END LOOP;

      RETURN tbMatrix;
   END ftbLoadMatrix;


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
      RETURN tytbRow
   IS
      tbMatrix   tytbRow;
      nuDim      INTEGER := tbR.COUNT;
   BEGIN
      -- Calculate powers
      FOR i IN 1 .. nuDim
      LOOP
         FOR j IN 1 .. nuDim
         LOOP
            tbMatrix (i) (j) := 0;

            FOR k IN 1 .. nuDim
            LOOP
               tbMatrix (i) (j) :=
                    tbMatrix (i) (j)
                  + itbPowerMatrix (i) (k) * tbAdjacencyMatrix (k) (j);
            END LOOP;
         /*            dbms_output.put_line(i||','||
                                          j||' : '||
                                          tbPowerMatrix(i)(j)
                                          );*/


         END LOOP;
      END LOOP;

      RETURN tbMatrix;
   END ftbMultMatrix;

   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        insPowerMatrix
    * Description: Insert into power matrix table
    *
    * Author:      Diego Garcia
    * Date:        05th May 2016
    *
    * Modification Log:
    * ---------------------------
    * 2016-05-05   Diego Garcia    Creation.
    */
   PROCEDURE insPowerMatrix (itbPowerMatrix IN tytbRow, inuPow IN INTEGER)
   IS
   BEGIN
      FOR i IN itbPowerMatrix.FIRST .. itbPowerMatrix.LAST
      LOOP
         FOR j IN itbPowerMatrix (i).FIRST .. itbPowerMatrix (i).LAST
         LOOP
            --dbms_output.put_line(i||','||j||' : '||itbPowerMatrix(i)(j));
            INSERT INTO POWER_MATRIX (POMAPOW,
                                      POMAROW,
                                      POMACOL,
                                      POMAVAL)
                 VALUES (inuPow,
                         i,
                         j,
                         itbPowerMatrix (i) (j));

            COMMIT;
         END LOOP;
      END LOOP;
   END insPowerMatrix;


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
      RETURN tytbRow
   IS
      tbMatrix   tytbRow;
   BEGIN
      FOR i IN 1 .. inuDim
      LOOP
         FOR j IN 1 .. inuDim
         LOOP
            IF (i = j)
            THEN
               tbMatrix (i) (j) := 1;
            ELSE
               tbMatrix (i) (j) := 0;
            END IF;
         END LOOP;
      END LOOP;

      RETURN tbMatrix;
   END ftbIdentMatrix;


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
      RETURN tytbRow
   IS
      tbMatrix   tytbRow;
   BEGIN
      FOR i IN 1 .. itbMatrix.COUNT
      LOOP
         FOR j IN 1 .. itbMatrix (i).COUNT
         LOOP
            tbMatrix (i) (j) := itbMatrix (j) (i);
         END LOOP;
      END LOOP;

      RETURN tbMatrix;
   END ftbTransMatrix;


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
      RETURN tytbRow
   IS
      tbMatrix   tytbRow;
   BEGIN
      FOR i IN 1 .. itbA.COUNT
      LOOP
         FOR j IN 1 .. itbA (i).COUNT
         LOOP
            tbMatrix (i) (j) := itbA (i) (j) + itbB (i) (j);
         END LOOP;
      END LOOP;

      RETURN tbMatrix;
   END ftbSumMatrix;

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
      RETURN tytbRow
   IS
      tbMatrix   tytbRow;
   BEGIN
      FOR i IN 1 .. itbMatrix.COUNT
      LOOP
         FOR j IN 1 .. itbMatrix (i).COUNT
         LOOP
            IF (itbMatrix (i) (j) = inuBitin)
            THEN
               tbMatrix (tbMatrix.COUNT + 1) (1) := i;
               tbMatrix (tbMatrix.COUNT) (2) := j;
            END IF;
         END LOOP;
      END LOOP;

      RETURN tbMatrix;
   END ftbGetPositionsMatrix;

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
      RETURN BOOLEAN
   IS
      nuI       INTEGER;
      nuJ       INTEGER;
      blIqual   BOOLEAN := TRUE;
   BEGIN
      nuI := itbA.FIRST;

      LOOP
         EXIT WHEN nuI IS NULL;
         --
         nuJ := itbA (nuI).FIRST;

         LOOP
            EXIT WHEN nuJ IS NULL;

            IF (itbA (nuI) (nuJ) <> itbB (nuI) (nuJ))
            THEN
               blIqual := FALSE;
            END IF;

            nuJ := itbA (nuI).NEXT (nuJ);
         END LOOP;

         nuI := itbA.NEXT (nuI);
      END LOOP;

      RETURN blIqual;
   END fblCompMatrix;

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
      RETURN tytbRow
   IS
      tbMatrix   tytbRow;
      nuDim      INTEGER := tbR.COUNT;

      CURSOR cuMatrix (inuPow INTEGER, nuRow INTEGER)
      IS
           SELECT pomaval
             FROM power_matrix
            WHERE pomarow = nuRow AND pomapow = inuPow
         ORDER BY pomacol;

      CURSOR cuMatrixLog (inuIter INTEGER, nuRow INTEGER)
      IS
           SELECT admaval
             FROM adjacency_matrix_log
            WHERE admarow = nuRow AND admaiter = inuIter
         ORDER BY admacol;
   BEGIN

	IF (iblPower) THEN
		-- Load  matrix from data base
		FOR i IN 1 .. nuDim LOOP
			OPEN cuMatrix (inuPow, i);
			FETCH cuMatrix BULK COLLECT INTO tbMatrix (i);
			CLOSE cuMatrix;
		END LOOP;
	ELSE
		-- Load  matrix from data base
		FOR i IN 1 .. nuDim LOOP
			OPEN cuMatrixLog (inuPow, i);
			FETCH cuMatrixLog BULK COLLECT INTO tbMatrix (i);
			CLOSE cuMatrixLog;
		END LOOP;

	END IF;

      RETURN tbMatrix;
   END ftbLoadMatrix;

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
      RETURN tytbRow
   IS
      tbMatrix   tytbRow;
      nuDim      INTEGER := tbR.COUNT;

      CURSOR cuMatrix (inuPow INTEGER, nuRow INTEGER)
      IS
           SELECT pomaval
             FROM power_matrix
            WHERE pomarow = nuRow AND pomapow = inuPow
         ORDER BY pomacol;

      CURSOR cuMatrixLog (inuIter INTEGER, nuRow INTEGER)
      IS
           SELECT admaval
             FROM adjacency_matrix_log
            WHERE admarow = nuRow AND admaiter = inuIter
              AND strategy = inuStrategy
         ORDER BY admacol;
   BEGIN

	IF (iblPower) THEN
		-- Load  matrix from data base
		FOR i IN 1 .. nuDim LOOP
			OPEN cuMatrix (inuPow, i);
			FETCH cuMatrix BULK COLLECT INTO tbMatrix (i);
			CLOSE cuMatrix;
		END LOOP;
	ELSE
		-- Load  matrix from data base
		FOR i IN 1 .. nuDim LOOP
			OPEN cuMatrixLog (inuPow, i);
			FETCH cuMatrixLog BULK COLLECT INTO tbMatrix (i);
			CLOSE cuMatrixLog;
		END LOOP;

	END IF;

      RETURN tbMatrix;
   END ftbLoadMatrix;


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
   PROCEDURE insMatrix (itbPowerMatrix IN tytbRow, inuPow IN INTEGER, iblPower in boolean)
   IS
   BEGIN
	IF (iblPower) THEN
      FOR i IN itbPowerMatrix.FIRST .. itbPowerMatrix.LAST
      LOOP
         FOR j IN itbPowerMatrix (i).FIRST .. itbPowerMatrix (i).LAST
         LOOP
            --dbms_output.put_line(i||','||j||' : '||itbPowerMatrix(i)(j));
            INSERT INTO POWER_MATRIX (POMAPOW,
                                      POMAROW,
                                      POMACOL,
                                      POMAVAL)
                 		VALUES (inuPow,i,j,itbPowerMatrix (i) (j));
            COMMIT;
         END LOOP;
      END LOOP;
	ELSE
      FOR i IN itbPowerMatrix.FIRST .. itbPowerMatrix.LAST
      LOOP
         FOR j IN itbPowerMatrix (i).FIRST .. itbPowerMatrix (i).LAST
         LOOP
            INSERT INTO ADJACENCY_MATRIX_LOG (ADMAITER,
                                      ADMAROW,
                                      ADMACOL,
                                      ADMAVAL)
                 		VALUES (inuPow,i,j,itbPowerMatrix (i) (j));
            COMMIT;
         END LOOP;
      END LOOP;
	END IF;
   END insMatrix;

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
   PROCEDURE insMatrix (itbPowerMatrix IN tytbRow, inuPow IN INTEGER, iblPower in boolean, inuStrategy in number)
   IS
   BEGIN
	IF (iblPower) THEN
      FOR i IN itbPowerMatrix.FIRST .. itbPowerMatrix.LAST
      LOOP
         FOR j IN itbPowerMatrix (i).FIRST .. itbPowerMatrix (i).LAST
         LOOP
            --dbms_output.put_line(i||','||j||' : '||itbPowerMatrix(i)(j));
            INSERT INTO POWER_MATRIX (POMAPOW,
                                      POMAROW,
                                      POMACOL,
                                      POMAVAL)
                 		VALUES (inuPow,i,j,itbPowerMatrix (i) (j));
            COMMIT;
         END LOOP;
      END LOOP;
	ELSE
      FOR i IN itbPowerMatrix.FIRST .. itbPowerMatrix.LAST
      LOOP
         FOR j IN itbPowerMatrix (i).FIRST .. itbPowerMatrix (i).LAST
         LOOP
            INSERT INTO ADJACENCY_MATRIX_LOG (ADMAITER,
                                      ADMAROW,
                                      ADMACOL,
                                      ADMAVAL, STRATEGY)
                 		VALUES (inuPow,i,j,itbPowerMatrix (i) (j), inuStrategy);
            COMMIT;
         END LOOP;
      END LOOP;
	END IF;
   END insMatrix;


END pkBayesianMapper;
/
