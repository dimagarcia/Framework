CREATE OR REPLACE PACKAGE BODY pkGeneExpression
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
    * 2017-07-05    Diego Garcia   Add Method:  fnuGetN3
    * 2017-07-04    Diego Garcia   Add Methods:  fnuGetN2 and loadCPT
    * 2017-07-01   Diego Garcia    Creation.
    */
   --------------------------------------------
   -- Constantes
   --------------------------------------------
   csbVersion   CONSTANT VARCHAR2 (250) := '2017-07-01';

   --------------------------------------------
   -- Funciones y Procedimientos
   --------------------------------------------
   FUNCTION fsbVersion
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN csbVersion;
   END;

    /*
    * 2019-03-31    Diego Garcia    Add global variable : gvcSamplesName
    *                               Medify method: Initialize
    *                               Use  gvcSamplesName variable to make SQL sentence    
    */
   PROCEDURE Initialize IS
        rfCursor tyCursor;
   BEGIN
    -- Initialize INSTANCE
    IF (tbMicroarray.count = 0) THEN
        FOR i IN 1..pkBayesianMapper.tbR.count LOOP
            --OPEN rfCursor FOR 'SELECT V'||i||' FROM SAMPLE2';
            --OPEN rfCursor FOR 'SELECT V'||i||' FROM SAMPLE34';
            --OPEN rfCursor FOR 'SELECT V'||i||' FROM SAMPLE40';
            --OPEN rfCursor FOR 'SELECT V'||i||' FROM SAMPLE52';
            --OPEN rfCursor FOR 'SELECT V'||i||' FROM SAMPLE_ECOLI34';
            -- 2019-02-13 Maltose
            --OPEN rfCursor FOR 'SELECT V'||i||' FROM SAMPLE_ECOLI42';
            -- 2019-02-13 Hydrogenase
            --OPEN rfCursor FOR 'SELECT V'||i||' FROM SAMPLE_ECOLI8_24';
            -- 2019-03-02
            -- OK Lactose OPEN rfCursor FOR 'SELECT V'||i||' FROM SAMPLE_ECOLI34';
            --OPEN rfCursor FOR 'SELECT V'||i||' FROM SAMPLE_ECOLI42';
            -- 2019-03-20 8.21 Hyc (intermodulares)
            OPEN rfCursor FOR 'SELECT V'||i||' FROM '|| pkGeneExpression.gvcSamplesName; --SAMPLE_ECOLI8_24';
            FETCH rfCursor BULK COLLECT INTO tbMicroarray(i);
            CLOSE rfCursor;
        END LOOP;
    END IF;
   END;

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
    FUNCTION fnuGetN(itbGeneExpr IN tytbGeneExpr) RETURN INTEGER
    IS
        nuGene BINARY_INTEGER;
        nuN INTEGER := 0;
        blMatch boolean;
        idx binary_integer;
    BEGIN
        -- Counting
        Initialize;
        idx := tbMicroarray(1).first;
        LOOP
            EXIT WHEN idx IS NULL;
            -->
            blMatch := true;
            nuGene := itbGeneExpr.first;
            LOOP
                EXIT WHEN nuGene IS NULL;
                if ( tbMicroarray(nuGene)(idx) != itbGeneExpr(nuGene) ) then
                    blMatch := false;
                end if;
                nuGene := itbGeneExpr.next(nuGene);
            END LOOP;
            if (blMatch) then
                    nuN := nuN + 1;
            end if;
            --<
            idx := tbMicroarray(1).next(idx);
        END LOOP;
        return nuN;
    END;
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
    *  k               Values combination of the current variable Parents    * Modification Log:
    * ---------------------------
    * 2017-07-01   Diego Garcia    Creation.
    */
   FUNCTION fnuGetN (nuI IN NUMBER, nuJ IN NUMBER, nuK IN NUMBER)
      RETURN NUMBER
   IS
      nuN   NUMBER;
      ---------------------------------------------------------------------------------------------------------
      -- Embebed methods
      ---------------------------------------------------------------------------------------------------------
      PROCEDURE clearCPT
      IS
         idx   BINARY_INTEGER;
      BEGIN
         -- Clear tbCPT
         idx := pkBayesianMapper.tbCPT.FIRST;
         LOOP
            EXIT WHEN idx IS NULL;
            pkBayesianMapper.tbCPT (idx).delete;
            idx := pkBayesianMapper.tbCPT.NEXT (idx);
         END LOOP;
         pkBayesianMapper.tbCPT.delete;
      END clearCPT;
      ---------------------------------------------------------------------------------------------------------
      PROCEDURE loadCPT (nuI IN NUMBER)
      IS
         nuPrev   NUMBER := NULL;
         nuPos    NUMBER;
         nuQi    NUMBER := pkBayesianMapper.fnuGetQ (nuI);
      BEGIN
         --     dbms_output.put_line('Begin loadCPT');
         -- Clear tbCPT
         clearCPT;
         -- Load tbCPT
         FOR s IN 1 .. nuQi
         LOOP
            nuPos := 0;
            FOR k IN pkBayesianMapper.tbAdjacencyMatrix.FIRST .. pkBayesianMapper.tbAdjacencyMatrix.LAST
            LOOP
               IF (pkBayesianMapper.tbAdjacencyMatrix (k) (nuI) = '1') -- Is 'k' parent of nuI ?
               THEN
-- 				  dbms_output.put_line('k:'||k||' tbR( k ):'||tbR( k )||' nuPos:'||nuPos||' nuPrev:'||nuPrev);
                  IF (nuPrev IS NULL) THEN
                     pkBayesianMapper.tbCPT (s) (k) := MOD (CEIL (s / POWER (pkBayesianMapper.tbR (k), nuPos)) - 1, pkBayesianMapper.tbR (k));
                  ELSE
                     pkBayesianMapper.tbCPT (s) (k) := MOD (CEIL (s / POWER (pkBayesianMapper.tbR (nuPrev), nuPos)) - 1, pkBayesianMapper.tbR (k));
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
    PROCEDURE loadGeneExpr IS
    BEGIN
      tbGeneExpr.delete;
      tbGeneExpr(nuI) := nuJ;
      FOR k IN pkBayesianMapper.tbAdjacencyMatrix.FIRST .. pkBayesianMapper.tbAdjacencyMatrix.LAST
      LOOP
         IF (pkBayesianMapper.tbAdjacencyMatrix (k) (nuI) = '1')  -- Is 'k' parent of nuI :var1
         THEN
            tbGeneExpr(k) := pkBayesianMapper.tbCPT (nuK) (k);
         END IF;
      END LOOP;
    END loadGeneExpr;
   ---------------------------------------------------------------------------------------------------------
   BEGIN
      -- Determine who are nuI's parents
      loadCPT (nuI);

      loadGeneExpr;
      
      nuN := fnuGetN(tbGeneExpr);

      RETURN NVL(nuN,0);
   END fnuGetN;
--*************************************************************************************************************
--*************************************************************************************************************
      ---------------------------------------------------------------------------------------------------------
      PROCEDURE loadCPT (inuI IN NUMBER)
      IS
         nuPrev   NUMBER := NULL;
         nuPos    NUMBER;
         nuQi    NUMBER := pkBayesianMapper.fnuGetQ (inuI);
      ---------------------------------------------------------------------------------------------------------
      -- Embebed methods
      ---------------------------------------------------------------------------------------------------------
      PROCEDURE clearCPT
      IS
         idx   BINARY_INTEGER;
      BEGIN
         -- Clear tbCPT
         idx := pkBayesianMapper.tbCPT.FIRST;
         LOOP
            EXIT WHEN idx IS NULL;
            pkBayesianMapper.tbCPT (idx).delete;
            idx := pkBayesianMapper.tbCPT.NEXT (idx);
         END LOOP;
         pkBayesianMapper.tbCPT.delete;
      END clearCPT;
      ---------------------------------------------------------------------------------------------------------
      BEGIN
         --     dbms_output.put_line('Begin loadCPT');
         -- Clear tbCPT
         clearCPT;
         -- Load tbCPT
         FOR s IN 1 .. nuQi
         LOOP
            nuPos := 0;
            FOR k IN pkBayesianMapper.tbAdjacencyMatrix.FIRST .. pkBayesianMapper.tbAdjacencyMatrix.LAST
            LOOP
               IF (pkBayesianMapper.tbAdjacencyMatrix (k) (inuI) = '1') -- Is 'k' parent of nuI ?
               THEN
-- 				  dbms_output.put_line('k:'||k||' tbR( k ):'||tbR( k )||' nuPos:'||nuPos||' nuPrev:'||nuPrev);
                  IF (nuPrev IS NULL) THEN
                     pkBayesianMapper.tbCPT (s) (k) := MOD (CEIL (s / POWER (pkBayesianMapper.tbR (k), nuPos)) - 1, pkBayesianMapper.tbR (k));
                  ELSE
                     pkBayesianMapper.tbCPT (s) (k) := MOD (CEIL (s / POWER (pkBayesianMapper.tbR (nuPrev), nuPos)) - 1, pkBayesianMapper.tbR (k));
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
      RETURN NUMBER
   IS
      nuN   NUMBER;
      ---------------------------------------------------------------------------------------------------------
      -- Embebed methods
      ---------------------------------------------------------------------------------------------------------
    PROCEDURE loadGeneExpr(inuI IN NUMBER, inuJ IN NUMBER, inuK IN NUMBER) IS
    BEGIN
      tbGeneExpr.delete;
      tbGeneExpr(inuI) := inuJ;
      FOR k IN pkBayesianMapper.tbAdjacencyMatrix.FIRST .. pkBayesianMapper.tbAdjacencyMatrix.LAST
      LOOP
         IF (pkBayesianMapper.tbAdjacencyMatrix (k) (inuI) = '1')  -- Is 'k' parent of nuI :var1
         THEN
            tbGeneExpr(k) := pkBayesianMapper.tbCPT (inuK) (k);
         END IF;
      END LOOP;
    END loadGeneExpr;
   ---------------------------------------------------------------------------------------------------------
   BEGIN
      -- Determine who are nuI's parents
      --loadCPT (nuI);

      loadGeneExpr(nuI,nuJ,nuK);

      nuN := fnuGetN(tbGeneExpr);

      RETURN NVL(nuN,0);
   END fnuGetN2;
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
      RETURN NUMBER
   IS
      nuN   NUMBER;
      ---------------------------------------------------------------------------------------------------------
      -- Embebed methods
      ---------------------------------------------------------------------------------------------------------
    PROCEDURE loadGeneExpr(inuI IN NUMBER, inuJ IN NUMBER, inuK IN NUMBER) IS
     nuPrev   NUMBER := NULL;
     nuPos    NUMBER;
      s integer;
    BEGIN
      tbGeneExpr.delete;
      tbGeneExpr(inuI) := inuJ;
      /*FOR k IN pkBayesianMapper.tbAdjacencyMatrix.FIRST .. pkBayesianMapper.tbAdjacencyMatrix.LAST
      LOOP
         IF (pkBayesianMapper.tbAdjacencyMatrix (k) (inuI) = '1')  -- Is 'k' parent of nuI :var1
         THEN
            tbGeneExpr(k) := pkBayesianMapper.tbCPT (inuK) (k);
         END IF;
      END LOOP;*/
      -- 05-JUL-2017
     --FOR s IN 1 .. nuQi
     --LOOP
     s := inuK;
        nuPos := 0;
        FOR k IN pkBayesianMapper.tbAdjacencyMatrix.FIRST .. pkBayesianMapper.tbAdjacencyMatrix.LAST
        LOOP
           IF (pkBayesianMapper.tbAdjacencyMatrix (k) (inuI) = '1') -- Is 'k' parent of nuI ?
           THEN
-- 				  dbms_output.put_line('k:'||k||' tbR( k ):'||tbR( k )||' nuPos:'||nuPos||' nuPrev:'||nuPrev);
              IF (nuPrev IS NULL) THEN
                 -->pkBayesianMapper.tbCPT (s) (k) := MOD (CEIL (s / POWER (pkBayesianMapper.tbR (k), nuPos)) - 1, pkBayesianMapper.tbR (k));
                tbGeneExpr(k) := MOD (CEIL (s / POWER (pkBayesianMapper.tbR (k), nuPos)) - 1, pkBayesianMapper.tbR (k));
              ELSE
                 -->pkBayesianMapper.tbCPT (s) (k) := MOD (CEIL (s / POWER (pkBayesianMapper.tbR (nuPrev), nuPos)) - 1, pkBayesianMapper.tbR (k));
                 tbGeneExpr(k) := MOD (CEIL (s / POWER (pkBayesianMapper.tbR (nuPrev), nuPos)) - 1, pkBayesianMapper.tbR (k));
              END IF;
-- 				  dbms_output.put_line('s:'||s||' k:'||k||' tbCPT (s) (k):'||tbCPT (s) (k));
              nuPrev := k;
              nuPos := NuPos + 1;
           END IF;
        END LOOP;
     -->END LOOP;

    END loadGeneExpr;
   ---------------------------------------------------------------------------------------------------------
   BEGIN
      -- Determine who are nuI's parents
      --loadCPT (nuI);

      loadGeneExpr(nuI,nuJ,nuK);

      nuN := fnuGetN(tbGeneExpr);

      RETURN NVL(nuN,0);
   END fnuGetN3;

END pkGeneExpression;
/
