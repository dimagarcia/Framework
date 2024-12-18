CREATE OR REPLACE PACKAGE BODY pkFiltering
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
   -- Constantes
   --------------------------------------------
   csbVersion   CONSTANT VARCHAR2 (250) := '2016-09-30';


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
   PROCEDURE GetRho IS
    nuSumNijk         NUMBER := 0;
    nuQi              NUMBER;
    idx binary_integer := 1;
   BEGIN
       FOR i IN 1 .. pkBayesianMapper.tbR.COUNT LOOP
          nuQi := pkBayesianMapper.fnuGetQ (i);
          FOR k IN 1 .. nuQi LOOP
    	  	-- 2016-08-23 16:52 DGarcia Fix script in calculate of CPTs
    	  	nuSumNijk := 0;
             FOR j IN 0 .. pkBayesianMapper.tbR (i) - 1 LOOP
    			pkLikelihood.tbNik (j + 1) := pkBayesianMapper.fnuGetN2 (i, j, k);
                nuSumNijk := nuSumNijk + pkLikelihood.tbNik (j + 1);
             END LOOP;
             FOR j IN 0 .. pkBayesianMapper.tbR (i) - 1 LOOP
                tbRho(i)(k)(j) := pkLikelihood.tbNik (j + 1) / nuSumNijk;
                --DBMS_OUTPUT.put_line ( 'i=' || i || ' k=' || k || ' j=' || j || ' Rho(i,k,j)=' || tbRho(i)(k)(j));
             END LOOP;
          END LOOP;
       END LOOP;
   END GetRho;

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
   PROCEDURE GetRho(inuI in integer) IS
    nuSumNijk         NUMBER := 0;
    nuQi              NUMBER;
    idx binary_integer := 1;
   BEGIN
      nuQi := pkBayesianMapper.fnuGetQ (inuI);
      FOR k IN 1 .. nuQi LOOP
	  	-- 2016-08-23 16:52 DGarcia Fix script in calculate of CPTs
	  	nuSumNijk := 0;
         FOR j IN 0 .. pkBayesianMapper.tbR (inuI) - 1 LOOP
			pkLikelihood.tbNik (j + 1) := pkBayesianMapper.fnuGetN2 (inuI, j, k);
            nuSumNijk := nuSumNijk + pkLikelihood.tbNik (j + 1);
         END LOOP;
         FOR j IN 0 .. pkBayesianMapper.tbR (inuI) - 1 LOOP
            tbRho(inuI)(k)(j) := pkLikelihood.tbNik (j + 1) / nuSumNijk;
            --DBMS_OUTPUT.put_line ( 'inuI=' || inuI || ' k=' || k || ' j=' || j || ' Rho(inuI,k,j)=' || tbRho(inuI)(k)(j));
         END LOOP;
      END LOOP;
   END GetRho;


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
    PROCEDURE  GetStates(inuI in integer)
    IS
      ---------------------------------------------------------------------------------------------------------
      -- Embebed methods
      ---------------------------------------------------------------------------------------------------------
      PROCEDURE clearStates
      IS
         idx   BINARY_INTEGER;
      BEGIN
         -- Clear tbCPT
         idx := tbStates.FIRST;
         LOOP
            EXIT WHEN idx IS NULL;
            tbStates (idx).delete;
            idx := tbStates.NEXT (idx);
         END LOOP;
         tbStates.delete;
      END clearStates;
      ---------------------------------------------------------------------------------------------------------
      PROCEDURE loadStates
      IS
         nuPrev   NUMBER := NULL;
         nuPos    NUMBER;
         nuQi    NUMBER := pkBayesianMapper.fnuGetQ (inuI);
      BEGIN
         -- Clear tbStates
         clearStates;
         -- Load tbCPT
         FOR s IN 1 .. nuQi  LOOP
            nuPos := 0;
            FOR k IN pkBayesianMapper.tbAdjacencyMatrix.FIRST .. pkBayesianMapper.tbAdjacencyMatrix.LAST LOOP
               IF (pkBayesianMapper.tbAdjacencyMatrix (k) (inuI) = '1') -- Is 'k' parent of nuI ?
               THEN
-- 				  dbms_output.put_line('k:'||k||' tbR( k ):'||tbR( k )||' nuPos:'||nuPos||' nuPrev:'||nuPrev);
                  IF (nuPrev IS NULL) THEN
                     tbStates(s)(k) := MOD (CEIL (s / POWER (pkBayesianMapper.tbR (k), nuPos)) - 1, pkBayesianMapper.tbR (k));
                  ELSE
                     tbStates(s)(k) := MOD (CEIL (s / POWER (pkBayesianMapper.tbR (nuPrev), nuPos)) - 1, pkBayesianMapper.tbR (k));
                  END IF;
 				  --dbms_output.put_line('s:'||s||' k:'||k||' tbStates (s) (k):'||tbStates (s) (k));
                  nuPrev := k;
                  nuPos := NuPos + 1;
               END IF;
            END LOOP;
         END LOOP;
      END loadStates;
   ---------------------------------------------------------------------------------------------------------
    BEGIN
        loadStates;
    END GetStates;


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
   PROCEDURE GetPofChildGivenParents(inuI in number) IS
    nuQi    NUMBER;
    idx     binary_integer := 1;
   BEGIN
    GetRho(inuI);

    nuQi := pkBayesianMapper.fnuGetQ (inuI);
    FOR k IN 1 .. nuQi LOOP
     FOR j IN 0 .. pkBayesianMapper.tbR (inuI) - 1 LOOP
        tbPofChildGivenParents(idx) := tbRho(inuI)(k)(j);
        --DBMS_OUTPUT.put_line ( 'idx=' || idx || ' k=' || k || ' j=' || j || ' tbPofChildGivenParents(idx)=' || tbPofChildGivenParents(idx));
        idx := idx + 1;
     END LOOP;
    END LOOP;
   END GetPofChildGivenParents;

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
   PROCEDURE GetPofOldParents(inuI in number, inuP in number) IS
    nuQi    NUMBER;
    idx     binary_integer;
    idx2     binary_integer;
    idx3     binary_integer := 1;
      nuN   NUMBER := -1;
      sbS   VARCHAR2 (2000) := 'SELECT SUM (f) as freq  FROM frequency2';
      sbW   VARCHAR2 (2000);
      TYPE  tycu IS REF CURSOR;
      cu    tycu;
      nuSizeSample number;
   BEGIN
    -- Get parents states
    pkFiltering.GetStates(inuI);
    -- Get size sample
    BEGIN
      OPEN cu FOR sbS;
      FETCH cu INTO nuSizeSample;
      CLOSE cu;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            nuSizeSample := 0;
    END;
    -- Get probability of Vi old parents
    idx := tbStates.first;
    LOOP
        EXIT WHEN idx IS NULL;
        --dbms_output.put('idx='||idx);
        FOR j IN 0 .. pkBayesianMapper.tbR(inuI) - 1 LOOP
            sbW := ' WHERE v' || inuI || ' = v'|| inuI;
            idx2 := tbStates(idx).first;
            LOOP
                EXIT WHEN idx2 IS NULL;

                IF (idx2 != inuP) THEN
                    -- Where clause generation
                    sbW := sbW || CHR (10) || ' AND v' || idx2 || ' = ' || tbStates(idx)(idx2);
                    --dbms_output.put(' idx2='||idx2||' tbStates(idx)(idx2)='||tbStates(idx)(idx2));
                END IF;

                idx2 := tbStates(idx).next(idx2);
            END LOOP;
            BEGIN
              OPEN cu FOR sbS || sbW;
              FETCH cu INTO nuN;
              CLOSE cu;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    nuN := 0;
            END;
            tbPofOldParents(idx3) := nuN / nuSizeSample;
            --DBMS_OUTPUT.put_line ( 'idx3=' || idx3 || ' tbPofOldParents(idx3)=' || tbPofOldParents(idx3));
            idx3 := idx3 + 1;
            --dbms_output.new_line;
        END LOOP;
        idx := tbStates.next(idx);
    END LOOP;
   END GetPofOldParents;

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
    PROCEDURE GetPofAllGivenCandidate IS
      idx   BINARY_INTEGER := NULL;
    BEGIN
        idx := tbPofOldParents.first;
        LOOP
            EXIT WHEN idx IS NULL;
            tbPofAllGivenCandidate(idx) := tbPofChildGivenParents(idx) * tbPofOldParents(idx);
            --dbms_output.put_line('idx:'||idx||' tbPofAllGivenCandidate(idx):'||tbPofAllGivenCandidate(idx));
            idx := tbPofOldParents.next(idx);
        END LOOP;
    END GetPofAllGivenCandidate;

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
   PROCEDURE GetPofAllWithoutCandidate(inuI in number, inuP in number) IS
    nuQi    NUMBER;
    idx     binary_integer;
    idx2     binary_integer;
    idx3     binary_integer := 1;
      nuN   NUMBER := -1;
      sbS   VARCHAR2 (2000) := 'SELECT SUM (f) as freq  FROM frequency2';
      sbW   VARCHAR2 (2000);
      TYPE  tycu IS REF CURSOR;
      cu    tycu;
      nuSizeSample number;
   BEGIN
    -- Get parents states
    --pkFiltering.GetStates(inuI);
    -- Get size sample
    BEGIN
      OPEN cu FOR sbS;
      FETCH cu INTO nuSizeSample;
      CLOSE cu;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            nuSizeSample := 0;
    END;
    -- Get probability of Vi old parents
    idx := tbStates.first;
    LOOP
        EXIT WHEN idx IS NULL;
        --dbms_output.put('idx='||idx);
        FOR j IN 0 .. pkBayesianMapper.tbR(inuI) - 1 LOOP
            sbW := ' WHERE v' || inuI || ' = '|| j;
            idx2 := tbStates(idx).first;
            LOOP
                EXIT WHEN idx2 IS NULL;

                IF (idx2 != inuP) THEN
                    -- Where clause generation
                    sbW := sbW || CHR (10) || ' AND v' || idx2 || ' = ' || tbStates(idx)(idx2);
                    --dbms_output.put(' idx2='||idx2||' tbStates(idx)(idx2)='||tbStates(idx)(idx2));
                END IF;

                idx2 := tbStates(idx).next(idx2);
            END LOOP;
            BEGIN
              OPEN cu FOR sbS || sbW;
              FETCH cu INTO nuN;
              CLOSE cu;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    nuN := 0;
            END;
            tbPofAllWithoutCandidate(idx3) := nuN / nuSizeSample;
            --DBMS_OUTPUT.put_line ( 'idx3=' || idx3 || ' tbPofAllWithoutCandidate(idx3)=' || tbPofAllWithoutCandidate(idx3));
            idx3 := idx3 + 1;
            --dbms_output.new_line;
        END LOOP;
        idx := tbStates.next(idx);
    END LOOP;
   END GetPofAllWithoutCandidate;

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
    FUNCTION fnuGetEpsilon(inuP in number, inuI in number) RETURN number
    IS
      idx   BINARY_INTEGER := NULL;
      nuEpsilon number := 0;
      nuAbsSubstration number;
    BEGIN
       pkFiltering.GetPofChildGivenParents(inuI);
       pkFiltering.GetPofOldParents(inuI,inuP);
       pkFiltering.GetPofAllGivenCandidate;
       pkFiltering.GetPofAllWithoutCandidate(inuI,inuP);

        idx := tbPofAllGivenCandidate.first;
        LOOP
            EXIT WHEN idx IS NULL;
            nuAbsSubstration := abs(tbPofAllGivenCandidate(idx) - tbPofAllWithoutCandidate(idx));
            IF (nuAbsSubstration > nuEpsilon) THEN
                nuEpsilon := nuabsSubstration;
            END IF;
            --dbms_output.put_line('idx:'||idx||' nuAbsSubstration:'||nuAbsSubstration);
            idx := tbPofAllGivenCandidate.next(idx);
        END LOOP;
        RETURN nuEpsilon;
    END fnuGetEpsilon;

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
    FUNCTION fnuGetInGrade (inuI in number)  RETURN integer
    IS
      nuInGrade integer := 0;
    BEGIN
        FOR k IN pkBayesianMapper.tbAdjacencyMatrix.FIRST .. pkBayesianMapper.tbAdjacencyMatrix.LAST LOOP
           IF (pkBayesianMapper.tbAdjacencyMatrix (k) (inuI) = '1') -- Is 'k' parent of nuI ?
           THEN
             nuInGrade := nuInGrade + 1;
           END IF;
        END LOOP;
        RETURN nuInGrade;
    END;

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
    PROCEDURE ApplyPostOptimalStrategy (inuFrom in number)
    IS
      nuId number := 1;
      --
      PROCEDURE ProcessAdjMatrix
      IS
           nuIdx binary_integer;
           nuIdx2 binary_integer;
           nuMinRow binary_integer;
           nuMinCol binary_integer;
           nuMinor number;
           nuEpsilon number;
      BEGIN
           LOOP
               -- Initialize
               nuMinor := 1;

               -- BEGIN Looking for smallest Epsilon in Graph
               nuIdx := pkBayesianMapper.tbAdjacencyMatrix.FIRST;
               LOOP
                 EXIT WHEN nuIdx IS NULL;
                 nuIdx2 := pkBayesianMapper.tbAdjacencyMatrix (nuIdx).FIRST;
                 LOOP
                   EXIT WHEN nuIdx2 IS NULL;
                   IF (pkBayesianMapper.tbAdjacencyMatrix(nuIdx)(nuIdx2) = '1') THEN

                     -- Calculus Epsilon for each edge in Graph
                     nuEpsilon := pkFiltering.fnuGetepsilon(nuIdx,nuIdx2);

                     --dbms_output.put_line('Epsilon('||nuIdx||','||nuIdx2||')='||nuEpsilon);
                     if (nuMinor > nuEpsilon) then
                         nuMinor := nuEpsilon;
                         nuMinRow := nuIdx;
                         nuMinCol := nuIdx2;
                     end if;
                   END IF;
                   nuIdx2 := pkBayesianMapper.tbAdjacencyMatrix (nuIdx).NEXT (nuIdx2);
                 END LOOP;
                 nuIdx := pkBayesianMapper.tbAdjacencyMatrix.NEXT (nuIdx);
               END LOOP;
               -- END Looking for minor Epsilon in Graph

             EXIT WHEN nuMinor > pkBayesianMapper.gnuEpsilon ;
             -- Apply changes to adjancecy matrix
             pkBayesianMapper.tbAdjacencyMatrix (nuMinRow) (nuMinCol) :=
                1 - pkBayesianMapper.tbAdjacencyMatrix (nuMinRow) (nuMinCol);

           END LOOP;

    	 -- Save graph's structure in B   inary Representation

    	 pkBayesianMapper.insMatrix (pkBayesianMapper.tbAdjacencyMatrix, nuId , false, 4); -- rc.id
    	 nuId := nuId + 1;

      END ProcessAdjMatrix;
      --
    BEGIN
        -- Load Adjacency Matrix in Binary Representation (To prune duplicates)
        pkBNBinaryRepresentation.LoadMassivelyBNBR(inuFrom, null,
                            pkBNBinaryRepresentation.gnuWithoutStrategy);
        --pkBNBinaryRepresentation.PrintBNBR;

      -- Process each matrix
      pkBNBinaryRepresentation.gsbIdxBNBR := pkBNBinaryRepresentation.tbBNBR.first;
      LOOP
        EXIT WHEN pkBNBinaryRepresentation.gsbIdxBNBR IS NULL;

        --dbms_output.put_line(gsbIdxBNBR||chr(9)||tbBNBR(gsbIdxBNBR));
        -- Get Adjacency Matrix from Binary representation
        pkBayesianMapper.tbAdjacencyMatrix := pkBNBinaryRepresentation.ftbLoadAdjMatrix(
                                                pkBNBinaryRepresentation.gsbIdxBNBR);
        -- Process Adjacency Matrix
        ProcessAdjMatrix;

        pkBNBinaryRepresentation.gsbIdxBNBR := pkBNBinaryRepresentation.tbBNBR.next(
                                                    pkBNBinaryRepresentation.gsbIdxBNBR);
      END LOOP;


    END ApplyPostOptimalStrategy;

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
   PROCEDURE GetRho2(inuI in integer) IS
    nuSumNijk         NUMBER := 0;
    nuQi              NUMBER;
    idx binary_integer := 1;
   BEGIN
       --dbms_output.put_line('Init pkFiltering.GetRho2');
      nuQi := pkBayesianMapper.fnuGetQ (inuI);
      FOR k IN 1 .. nuQi LOOP

	  	-- 2016-08-23 16:52 DGarcia Fix script in calculate of CPTs
	  	nuSumNijk := 0;
         FOR j IN 0 .. pkBayesianMapper.tbR (inuI) - 1 LOOP
            -- 2017-07-24
			pkLikelihood.tbNik (j + 1) := pkGeneExpression.fnuGetN3(inuI,j,k) + 2;
			--pkLikelihood.tbNik (j + 1) := pkBayesianMapper.fnuGetN2 (inuI, j, k) + 2;
			--pkLikelihood.tbNik (j + 1) := pkBayesianMapper.fnuGetN3 (inuI, j, k);
            nuSumNijk := nuSumNijk + pkLikelihood.tbNik (j + 1);
         END LOOP;
         FOR j IN 0 .. pkBayesianMapper.tbR (inuI) - 1 LOOP
            tbRho(inuI)(k)(j) := pkLikelihood.tbNik (j + 1) / nuSumNijk;
            --DBMS_OUTPUT.put_line ( 'inuI=' || inuI || ' k=' || k || ' j=' || j || ' Rho(inuI,k,j)=' || tbRho(inuI)(k)(j));
         END LOOP;
      END LOOP;
       --dbms_output.put_line('Init pkFiltering.GetRho2');
   END GetRho2;
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
   PROCEDURE GetPofChildGivenParents2(inuI in number) IS
    nuQi    NUMBER;
    idx     binary_integer := 1;
   BEGIN
       --dbms_output.put_line('Init pkFiltering.GetPofChildGivenParents2');
    GetRho2(inuI);

    nuQi := pkBayesianMapper.fnuGetQ (inuI);
    FOR k IN 1 .. nuQi LOOP
     FOR j IN 0 .. pkBayesianMapper.tbR (inuI) - 1 LOOP
        tbPofChildGivenParents(idx) := tbRho(inuI)(k)(j);
        --DBMS_OUTPUT.put_line ( 'idx=' || idx || ' k=' || k || ' j=' || j || ' tbPofChildGivenParents(idx)=' || tbPofChildGivenParents(idx));
        idx := idx + 1;
     END LOOP;
    END LOOP;
       --dbms_output.put_line('Init pkFiltering.GetPofChildGivenParents2');
   END GetPofChildGivenParents2;

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
   PROCEDURE GetPofOldParents2(inuI in number, inuP in number) IS
    nuQi    NUMBER;
    idx     binary_integer;
    idx2     binary_integer;
    idx3     binary_integer := 1;
      nuN   NUMBER := -1;
      sbS   VARCHAR2 (2000) := 'SELECT SUM (f) as freq  FROM frequency4';
      --sbS   VARCHAR2 (2000) := 'SELECT SUM (f) as freq  FROM frequency5';
      --sbS   VARCHAR2 (2000) := 'SELECT SUM (f) as freq  FROM frequency2';
      sbW   VARCHAR2 (2000);
      TYPE  tycu IS REF CURSOR;
      cu    tycu;
      nuSizeSample number;
   BEGIN
    -- Get parents states
    pkFiltering.GetStates(inuI);
    -- Get size sample
    BEGIN
      OPEN cu FOR sbS;
      FETCH cu INTO nuSizeSample;
      CLOSE cu;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            nuSizeSample := 0;
    END;
    -- Get probability of Vi old parents
    idx := tbStates.first;
    LOOP
        EXIT WHEN idx IS NULL;
        --dbms_output.put('idx='||idx);
        FOR j IN 0 .. pkBayesianMapper.tbR(inuI) - 1 LOOP
            sbW := ' WHERE v' || inuI || ' = v'|| inuI;
            idx2 := tbStates(idx).first;
            LOOP
                EXIT WHEN idx2 IS NULL;

                IF (idx2 != inuP) THEN
                    -- Where clause generation
                    sbW := sbW || CHR (10) || ' AND v' || idx2 || ' = ' || tbStates(idx)(idx2);
                    --dbms_output.put(' idx2='||idx2||' tbStates(idx)(idx2)='||tbStates(idx)(idx2));
                END IF;

                idx2 := tbStates(idx).next(idx2);
            END LOOP;
            BEGIN
              OPEN cu FOR sbS || sbW;
              FETCH cu INTO nuN;
              CLOSE cu;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    nuN := 0;
            END;
            tbPofOldParents(idx3) := nuN / nuSizeSample;
            --DBMS_OUTPUT.put_line ( 'idx3=' || idx3 || ' tbPofOldParents(idx3)=' || tbPofOldParents(idx3));
            idx3 := idx3 + 1;
            --dbms_output.new_line;
        END LOOP;
        idx := tbStates.next(idx);
    END LOOP;
   END GetPofOldParents2;

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
   PROCEDURE GetPofAllWithoutCandidate2(inuI in number, inuP in number) IS
    nuQi    NUMBER;
    idx     binary_integer;
    idx2     binary_integer;
    idx3     binary_integer := 1;
      nuN   NUMBER := -1;
      sbS   VARCHAR2 (2000) := 'SELECT SUM (f) as freq  FROM frequency4';
      --sbS   VARCHAR2 (2000) := 'SELECT SUM (f) as freq  FROM frequency5';
      --sbS   VARCHAR2 (2000) := 'SELECT SUM (f) as freq  FROM frequency2';
      sbW   VARCHAR2 (2000);
      TYPE  tycu IS REF CURSOR;
      cu    tycu;
      nuSizeSample number;

   BEGIN
    -- Get parents states
    --pkFiltering.GetStates(inuI);
    -- Get size sample
    BEGIN
      OPEN cu FOR sbS;
      FETCH cu INTO nuSizeSample;
      CLOSE cu;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            nuSizeSample := 0;
    END;
    -- Get probability of Vi old parents
    idx := tbStates.first;
    LOOP
        EXIT WHEN idx IS NULL;
        --dbms_output.put('idx='||idx);
        FOR j IN 0 .. pkBayesianMapper.tbR(inuI) - 1 LOOP
            sbW := ' WHERE v' || inuI || ' = '|| j;
            idx2 := tbStates(idx).first;
            LOOP
                EXIT WHEN idx2 IS NULL;

                IF (idx2 != inuP) THEN
                    -- Where clause generation
                    sbW := sbW || CHR (10) || ' AND v' || idx2 || ' = ' || tbStates(idx)(idx2);
                    --dbms_output.put(' idx2='||idx2||' tbStates(idx)(idx2)='||tbStates(idx)(idx2));
                END IF;

                idx2 := tbStates(idx).next(idx2);
            END LOOP;
            BEGIN
              OPEN cu FOR sbS || sbW;
              FETCH cu INTO nuN;
              CLOSE cu;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    nuN := 0;
            END;
            tbPofAllWithoutCandidate(idx3) := nuN / nuSizeSample;
            --DBMS_OUTPUT.put_line ( 'idx3=' || idx3 || ' tbPofAllWithoutCandidate(idx3)=' || tbPofAllWithoutCandidate(idx3));
            idx3 := idx3 + 1;
            --dbms_output.new_line;
        END LOOP;
        idx := tbStates.next(idx);
    END LOOP;
   END GetPofAllWithoutCandidate2;

--******************************************************************************
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
   PROCEDURE GetPofOldParents3(nuI in number, nuP in number) IS
    nuQi    NUMBER;
    idx     binary_integer := 1;
      nuN   NUMBER := -1;
      nuSizeSample number;
    ---------------------------------------------------------------------------------------------------------
    PROCEDURE loadGeneExpr(inuI IN NUMBER, inuJ IN NUMBER, inuK IN NUMBER, inuP IN NUMBER) IS
     nuPrev   NUMBER := NULL;
     nuPos    NUMBER;
      s integer;
    BEGIN
      pkGeneExpression.tbGeneExpr.delete;
      --pkGeneExpression.tbGeneExpr(inuI) := inuJ;
     s := inuK;
        nuPos := 0;
        FOR k IN pkBayesianMapper.tbAdjacencyMatrix.FIRST .. pkBayesianMapper.tbAdjacencyMatrix.LAST
        LOOP
           IF (pkBayesianMapper.tbAdjacencyMatrix (k) (inuI) = '1'
                AND k != inuP) -- Is 'k' parent of nuI ?
           THEN
-- 				  dbms_output.put_line('k:'||k||' tbR( k ):'||tbR( k )||' nuPos:'||nuPos||' nuPrev:'||nuPrev);
              IF (nuPrev IS NULL) THEN
                 -->pkBayesianMapper.tbCPT (s) (k) := MOD (CEIL (s / POWER (pkBayesianMapper.tbR (k), nuPos)) - 1, pkBayesianMapper.tbR (k));
                pkGeneExpression.tbGeneExpr(k) := MOD (CEIL (s / POWER (pkBayesianMapper.tbR (k), nuPos)) - 1, pkBayesianMapper.tbR (k));
              ELSE
                 -->pkBayesianMapper.tbCPT (s) (k) := MOD (CEIL (s / POWER (pkBayesianMapper.tbR (nuPrev), nuPos)) - 1, pkBayesianMapper.tbR (k));
                 pkGeneExpression.tbGeneExpr(k) := MOD (CEIL (s / POWER (pkBayesianMapper.tbR (nuPrev), nuPos)) - 1, pkBayesianMapper.tbR (k));
              END IF;
-- 				  dbms_output.put_line('s:'||s||' k:'||k||' tbCPT (s) (k):'||tbCPT (s) (k));
              nuPrev := k;
              nuPos := NuPos + 1;
           END IF;
        END LOOP;
     -->END LOOP;

    END loadGeneExpr;
    -- pkGeneExpression.tbMicroarray
    ---------------------------------------------------------------------------------------------------------
   BEGIN
    -- Get parents states
    --pkFiltering.GetStates(inuI);
    -- Get size sample
    nuSizeSample := pkGeneExpression.tbMicroarray(1).count;

    -- Get probability of Vi old parents
	nuQi := pkBayesianMapper.fnuGetQ(nuI);
	FOR k IN 1..nuQi LOOP

        --dbms_output.put('idx='||idx);
        FOR j IN 0 .. pkBayesianMapper.tbR(nuI) - 1 LOOP

            loadGeneExpr(nuI, j, k, nuP);

            nuN := pkGeneExpression.fnuGetN(pkGeneExpression.tbGeneExpr);

            tbPofOldParents(idx) := nuN / nuSizeSample;
            --DBMS_OUTPUT.put_line ( 'idx3=' || idx3 || ' tbPofOldParents(idx3)=' || tbPofOldParents(idx3));
            idx := idx + 1;
            --dbms_output.new_line;
        END LOOP;

    END LOOP;
   END GetPofOldParents3;

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
   PROCEDURE GetPofAllWithoutCandidate3(nuI in number, nuP in number) IS
    nuQi    NUMBER;
    idx     binary_integer := 1;
      nuN   NUMBER := -1;
      nuSizeSample number;
    ---------------------------------------------------------------------------------------------------------
    PROCEDURE loadGeneExpr(inuI IN NUMBER, inuJ IN NUMBER, inuK IN NUMBER, inuP IN NUMBER) IS
     nuPrev   NUMBER := NULL;
     nuPos    NUMBER;
      s integer;
    BEGIN
      pkGeneExpression.tbGeneExpr.delete;
      pkGeneExpression.tbGeneExpr(inuI) := inuJ;
     s := inuK;
        nuPos := 0;
        FOR k IN pkBayesianMapper.tbAdjacencyMatrix.FIRST .. pkBayesianMapper.tbAdjacencyMatrix.LAST
        LOOP
           IF (pkBayesianMapper.tbAdjacencyMatrix (k) (inuI) = '1'
                AND k != inuP) -- Is 'k' parent of nuI ?
           THEN
-- 				  dbms_output.put_line('k:'||k||' tbR( k ):'||tbR( k )||' nuPos:'||nuPos||' nuPrev:'||nuPrev);
              IF (nuPrev IS NULL) THEN
                 -->pkBayesianMapper.tbCPT (s) (k) := MOD (CEIL (s / POWER (pkBayesianMapper.tbR (k), nuPos)) - 1, pkBayesianMapper.tbR (k));
                pkGeneExpression.tbGeneExpr(k) := MOD (CEIL (s / POWER (pkBayesianMapper.tbR (k), nuPos)) - 1, pkBayesianMapper.tbR (k));
              ELSE
                 -->pkBayesianMapper.tbCPT (s) (k) := MOD (CEIL (s / POWER (pkBayesianMapper.tbR (nuPrev), nuPos)) - 1, pkBayesianMapper.tbR (k));
                 pkGeneExpression.tbGeneExpr(k) := MOD (CEIL (s / POWER (pkBayesianMapper.tbR (nuPrev), nuPos)) - 1, pkBayesianMapper.tbR (k));
              END IF;
-- 				  dbms_output.put_line('s:'||s||' k:'||k||' tbCPT (s) (k):'||tbCPT (s) (k));
              nuPrev := k;
              nuPos := NuPos + 1;
           END IF;
        END LOOP;
     -->END LOOP;

    END loadGeneExpr;
    -- pkGeneExpression.tbMicroarray
    ---------------------------------------------------------------------------------------------------------
   BEGIN
    nuSizeSample := pkGeneExpression.tbMicroarray(1).count;

    -- Get probability of Vi old parents
	nuQi := pkBayesianMapper.fnuGetQ(nuI);
	FOR k IN 1..nuQi LOOP

        --dbms_output.put('idx='||idx);
        FOR j IN 0 .. pkBayesianMapper.tbR(nuI) - 1 LOOP

            loadGeneExpr(nuI, j, k, nuP);

            nuN := pkGeneExpression.fnuGetN(pkGeneExpression.tbGeneExpr);

            tbPofAllWithoutCandidate(idx) := nuN / nuSizeSample;
            --DBMS_OUTPUT.put_line ( 'idx3=' || idx3 || ' tbPofOldParents(idx3)=' || tbPofOldParents(idx3));
            idx := idx + 1;
            --dbms_output.new_line;
        END LOOP;

    END LOOP;

   END GetPofAllWithoutCandidate3;
--******************************************************************************


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
    * 2017-07-24   Diego Garcia    Updating the counting with the new data source (SAMPLE).
    * 2017-06-23   Diego Garcia    Creation.
    */
    FUNCTION fnuGetEpsilon2(inuP in number, inuI in number) RETURN number
    IS
      idx   BINARY_INTEGER := NULL;
      nuEpsilon number := 0;
      nuAbsSubstration number;
    BEGIN
       --dbms_output.put_line('Init pkFiltering.fnuGetEpsilon2');
       pkFiltering.GetPofChildGivenParents2(inuI);
       --pkFiltering.GetPofOldParents2(inuI,inuP);
       pkFiltering.GetPofOldParents3(inuI,inuP);
       pkFiltering.GetPofAllGivenCandidate;
       --pkFiltering.GetPofAllWithoutCandidate2(inuI,inuP);
       pkFiltering.GetPofAllWithoutCandidate3(inuI,inuP);

        idx := tbPofAllGivenCandidate.first;
        LOOP
            EXIT WHEN idx IS NULL;
            nuAbsSubstration := abs(tbPofAllGivenCandidate(idx) - tbPofAllWithoutCandidate(idx));
            IF (nuAbsSubstration > nuEpsilon) THEN
                nuEpsilon := nuabsSubstration;
            END IF;
            --dbms_output.put_line('idx:'||idx||' nuAbsSubstration:'||nuAbsSubstration);
            idx := tbPofAllGivenCandidate.next(idx);
        END LOOP;
       --dbms_output.put_line('Finish pkFiltering.fnuGetEpsilon2');
        RETURN nuEpsilon;
    END fnuGetEpsilon2;

END pkFiltering;
/
