/*
  * Propiedad intelectual de la Universidad del Valle
  * Name: script_calculate_Epsilon.sql
  * Description: Script masive that calculates  the Conditional  Probabilities associated
  *              of a node and determine if exists almost independence in their edges (epsilon)
  * Parametros :  Descripcion
  * -            -
  *
  * Author:      Diego Garcia
  * Date:        13th Oct 2016
  *
  * Modification Log:
  * ---------------------------
  * 2016-10-13   Diego Garcia    Creation.    1712 sec. 23-JUN-2016
*/

DECLARE
    sbIdx varchar2(36);
    nuId number := 1;

   nuLogLikelihood0   NUMBER;
   nuLogLikelihood   NUMBER;
   nuEpsilon number;
   tbPositions1              pkBayesianMapper.tytbRow;
   nuMaxIngradeGraph integer;
    nuMinRow binary_integer;
    nuMinCol binary_integer;
    nuMinor number;
    nuMaxIngrade integer := 0;

   CURSOR cuOptimalLevel(inuOptLvl in integer) IS
    select id from trace where id >= inuOptLvl order by id;
  --------------------------------------------------------------------------
  -- Calculate the maximum Ingrade for the current graph - 15/11/2016 DGarcia
  FUNCTION fnuMaxIngrade RETURN INTEGER
  IS
    nuParen binary_integer;
    nuChild binary_integer;
    nuCurIngrade integer;
  BEGIN
     nuChild := pkBayesianMapper.tbAdjacencyMatrix.FIRST;
     LOOP
        EXIT WHEN nuChild IS NULL;
        nuCurIngrade := 0;
        nuParen := pkBayesianMapper.tbAdjacencyMatrix (nuChild).FIRST;

        LOOP
           EXIT WHEN nuParen IS NULL;

           IF (pkBayesianMapper.tbAdjacencyMatrix (nuParen) (nuChild) = '1') THEN -- Is 'nuParen' parent of 'nuChild' ?
             nuCurIngrade := nuCurIngrade + 1;
           END IF;

           nuParen := pkBayesianMapper.tbAdjacencyMatrix (nuChild).NEXT (nuParen);
        END LOOP;

        IF (nuCurIngrade > nuMaxIngrade) THEN
          nuMaxIngrade := nuCurIngrade;
        END IF;

        nuChild := pkBayesianMapper.tbAdjacencyMatrix.NEXT (nuChild);
     END LOOP;
     RETURN nuMaxIngrade;
  END fnuMaxIngrade;
  --------------------------------------------------------------------------
  PROCEDURE FindMinorEpsilonEdge (onuMinor out number,
                                  onuMinRow out binary_integer,
                                  ionuMinCol in out binary_integer)
  IS
    nuIdx binary_integer;
    nuIdx2 binary_integer;
  BEGIN
    -- Initialize
    onuMinor := 1;

    -- BEGIN Looking for smallest Epsilon in Graph
    nuIdx := pkBayesianMapper.tbAdjacencyMatrix.FIRST;
    LOOP
      EXIT WHEN nuIdx IS NULL;
      IF (ionuMinCol IS NULL) THEN
          nuIdx2 := pkBayesianMapper.tbAdjacencyMatrix (nuIdx).FIRST;
          LOOP
            EXIT WHEN nuIdx2 IS NULL;
            IF (pkBayesianMapper.tbAdjacencyMatrix(nuIdx)(nuIdx2) = '1') THEN

              -- Calculus Epsilon for each edge in Graph
              --nuEpsilon := pkFiltering.fnuGetepsilon(nuIdx,nuIdx2);
              nuEpsilon := pkFiltering.fnuGetepsilon2(nuIdx,nuIdx2);

              --dbms_output.put_line('Epsilon('||nuIdx||','||nuIdx2||')='||nuEpsilon);
              if (onuMinor > nuEpsilon) then
                 onuMinor := nuEpsilon;
                 onuMinRow := nuIdx;
                 ionuMinCol := nuIdx2;
              end if;
            END IF;
            nuIdx2 := pkBayesianMapper.tbAdjacencyMatrix (nuIdx).NEXT (nuIdx2);
          END LOOP;
      ELSE
        IF (pkBayesianMapper.tbAdjacencyMatrix(nuIdx)(ionuMinCol) = '1') THEN
          nuEpsilon := pkFiltering.fnuGetepsilon2(nuIdx,ionuMinCol);
          if (onuMinor > nuEpsilon) then
             onuMinor := nuEpsilon;
             onuMinRow := nuIdx;
          end if;
        END IF;
      END IF;
      nuIdx := pkBayesianMapper.tbAdjacencyMatrix.NEXT (nuIdx);
    END LOOP;

  END FindMinorEpsilonEdge;
  --------------------------------------------------------------------------
  PROCEDURE FindMaxIngradeNode (onuMaxIngrade out integer,
                                onuChild out binary_integer)
  IS
    nuParen binary_integer;
    nuChild binary_integer;
    nuCurIngrade integer;
  BEGIN
     onuMaxIngrade := 0;
     nuChild := pkBayesianMapper.tbAdjacencyMatrix.FIRST;
     LOOP
        EXIT WHEN nuChild IS NULL;
        nuCurIngrade := 0;
        nuParen := pkBayesianMapper.tbAdjacencyMatrix (nuChild).FIRST;

        LOOP
           EXIT WHEN nuParen IS NULL;

           IF (pkBayesianMapper.tbAdjacencyMatrix (nuParen) (nuChild) = '1') THEN -- Is 'nuParen' parent of 'nuChild' ?
             nuCurIngrade := nuCurIngrade + 1;
           END IF;

           nuParen := pkBayesianMapper.tbAdjacencyMatrix (nuChild).NEXT (nuParen);
        END LOOP;

        IF (nuCurIngrade > onuMaxIngrade) THEN
          onuMaxIngrade := nuCurIngrade;
          onuChild := nuChild;
        END IF;

        nuChild := pkBayesianMapper.tbAdjacencyMatrix.NEXT (nuChild);
     END LOOP;
     --RETURN nuMaxIngrade;
  END FindMaxIngradeNode;
  --------------------------------------------------------------------------
BEGIN
   DBMS_OUTPUT.put_line ('INICIO');

   -- Inizializate cardianality of values sets for each variable
   pkBayesianMapper.tbR (1) := 3;
   pkBayesianMapper.tbR (2) := 3;
   pkBayesianMapper.tbR (3) := 3;
   pkBayesianMapper.tbR (4) := 3;
   pkBayesianMapper.tbR (5) := 3;
   pkBayesianMapper.tbR (6) := 3;

   -- Declare Epsilon parameter
   --pkBayesianMapper.gnuEpsilon := 0.0000000001;
   --pkBayesianMapper.gnuEpsilon := 0.0001;
--   pkBayesianMapper.gnuEpsilon := 0.001;
   ----pkBayesianMapper.gnuEpsilon := 0.003;
--no   pkBayesianMapper.gnuEpsilon := 0.005;
   --pkBayesianMapper.gnuEpsilon := 0.007;
   --pkBayesianMapper.gnuEpsilon := 0.009; -- 1708.813 sec.
   -- 25-JUN-2017
   --pkBayesianMapper.gnuEpsilon := 0.0001;
   --pkBayesianMapper.gnuEpsilon := 0.09; -- 92 447.89 sec. 2053.031 sec.
   -- 26-JUN-2017
   --pkBayesianMapper.gnuEpsilon := 0.01; -- 136
   --pkBayesianMapper.gnuEpsilon := 0.05;
   --pkBayesianMapper.gnuEpsilon := 0.07; -- 2772.844 sec.
   pkBayesianMapper.gnuEpsilon := 0.03;

   --pkBayesianMapper.tbAdjacencyMatrix := pkBayesianMapper.ftbLoadMatrix (15 , null);
-->   pkBayesianMapper.tbAdjacencyMatrix := pkBayesianMapper.ftbLoadMatrix (1);
-->   pkBayesianMapper.gblCPTcacheON := FALSE;
-->   nuLogLikelihood0 := pkLikelihood.fnuLogLikelihood (0);
   --dbms_output.put_line(nuLogLikelihood0);

   pkBayesianMapper.gnuInGrade := 2; -- 16 2 -> 2545.797 sec.
   -- 1837.203 sec.

   -- Massive
   --FOR rc IN cuOptimalLevel(32) LOOP
    sbIdx := pkBNBinaryRepresentation.tbBNBR.first;
    LOOP
        EXIT WHEN sbIdx IS NULL;
        pkBayesianMapper.tbAdjacencyMatrix := pkBNBinaryRepresentation.ftbLoadAdjMatrix(sbIdx);
        --dbms_output.put_line(sbIdx);
        -->
       --pkBayesianMapper.tbAdjacencyMatrix := pkBayesianMapper.ftbLoadMatrix (rc.id,false);

       -- 26-JUN-2016 PostOptimal Strategy with Maximum InGrade Constraint
       --nuMaxIngradeGraph := fnuMaxIngrade;
       --/* 27-JUN-2017
       LOOP
         nuMaxIngradeGraph:=null; nuMinCol:=null;
         FindMaxIngradeNode(nuMaxIngradeGraph, nuMinCol);
         --dbms_output.put_line('nuMaxIngradeGraph='||nuMaxIngradeGraph||', nuMinCol='||nuMinCol);
         EXIT WHEN nuMaxIngradeGraph <= pkBayesianMapper.gnuInGrade;
       --IF (nuMaxIngradeGraph > pkBayesianMapper.gnuInGrade) THEN
         --/* 27-JUN-2017
          FOR i IN 1..(nuMaxIngradeGraph - pkBayesianMapper.gnuInGrade) LOOP
            FindMinorEpsilonEdge(nuMinor, nuMinRow, nuMinCol);
            --dbms_output.put_line('nuMinor='||nuMinor||', nuMinRow='||nuMinRow);
            pkBayesianMapper.tbAdjacencyMatrix (nuMinRow) (nuMinCol) :=
                1 - pkBayesianMapper.tbAdjacencyMatrix (nuMinRow) (nuMinCol);
          END LOOP;
    	  --*/
       --END IF;
       END LOOP;
       --*/
       /* 26-JUN-2016
       -- PostOptimal Strategy with Epsilon-Independence
       LOOP
         FindMinorEpsilonEdge(nuMinor, nuMinRow, nuMinCol);
            -- END Looking for minor Epsilon in Graph
           --dbms_output.put_line('nuMinor:'||nuMinor||' nuMinRow:'||nuMinRow||' nuMinCol:'||nuMinCol);
         EXIT WHEN nuMinor > pkBayesianMapper.gnuEpsilon ;
         -- Apply changes to adjancecy matrix
         pkBayesianMapper.tbAdjacencyMatrix (nuMinRow) (nuMinCol) :=
            1 - pkBayesianMapper.tbAdjacencyMatrix (nuMinRow) (nuMinCol);
         -- 25-JUN-2017
         --dbms_output.put('Graph No: '||nuId);
         --dbms_output.put(' Removing edge '||nuMinRow|| ' -> ' || nuMinCol);
         --dbms_output.put_line(' with Epsilon: '||nuMinor);
         
         -- Calculate Global LogLikelihood
         --pkBayesianMapper.gblCPTcacheON := FALSE;
         --nuLogLikelihood := pkLikelihood.fnuLogLikelihood (0);
         --dbms_output.put_line('New LogLikelihood: '||nuLogLikelihood);
       END LOOP;
       */
	   -- Save graph's structure into adjacency_matrix_log
	   pkBayesianMapper.insMatrix (pkBayesianMapper.tbAdjacencyMatrix, nuId , false, 4); -- rc.id
	   nuId := nuId + 1;

    -- Output
    --/*  27-JUN-2017
    tbPositions1 := pkBayesianMapper.ftbGetPositionsMatrix (pkBayesianMapper.tbAdjacencyMatrix, 1);
    -- Print number of edges
    dbms_output.put(tbPositions1.count);
    -- Print Max InGrade Graph
    nuMaxIngradeGraph := fnuMaxIngrade;
    dbms_output.put_line(chr(9)||nuMaxIngradeGraph);
    --*/
    -- Print Likelihood
    -->pkBayesianMapper.gblCPTcacheON := FALSE;
    -->nuLogLikelihood := pkLikelihood.fnuLogLikelihood (0);
    -->dbms_output.put_line(chr(9)||(nuLogLikelihood-nuLogLikelihood0));
    --<
    sbIdx := pkBNBinaryRepresentation.tbBNBR.next(sbIdx);
   END LOOP; --- Massive

   DBMS_OUTPUT.put_line ('FIN');
END;
/
