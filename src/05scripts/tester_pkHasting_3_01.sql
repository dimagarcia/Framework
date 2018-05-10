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
  * 2016-10-13   Diego Garcia    Creation.
*/

DECLARE
   nuLogLikelihood0   NUMBER;
   nuLogLikelihood   NUMBER;
   nuIdx binary_integer;
   nuIdx2 binary_integer;
   nuMinRow binary_integer;
   nuMinCol binary_integer;
   nuMinor number;
   nuEpsilon number;
   tbPositions1              pkBayesianMapper.tytbRow;
   nuMaxIngradeGraph integer;

   CURSOR cuOptimalLevel(inuOptLvl in integer) IS
    select id from trace where id >= inuOptLvl order by id;
  --------------------------------------------------------------------------
  -- Calculate the maximum Ingrade for the current graph - 15/11/2016 DGarcia
  FUNCTION fnuMaxIngrade RETURN INTEGER
  IS
    nuChild binary_integer;
    nuParen binary_integer;
    nuMaxIngrade integer := 0;
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
BEGIN
   DBMS_OUTPUT.put_line ('INICIO');

   -- Inizializate cardianality of values sets for each variable
   pkBayesianMapper.tbR (1) := 2;
   pkBayesianMapper.tbR (2) := 2;
   pkBayesianMapper.tbR (3) := 2;
   pkBayesianMapper.tbR (4) := 2;
   pkBayesianMapper.tbR (5) := 2;

   -- Declare Epsilon parameter
   ----pkBayesianMapper.gnuEpsilon := 0.003;
   --pkBayesianMapper.gnuEpsilon := 0.005;
   --pkBayesianMapper.gnuEpsilon := 0.007;
   pkBayesianMapper.gnuEpsilon := 0.009;

   --pkBayesianMapper.tbAdjacencyMatrix := pkBayesianMapper.ftbLoadMatrix (15 , null);
   pkBayesianMapper.tbAdjacencyMatrix := pkBayesianMapper.ftbLoadMatrix (1);
   pkBayesianMapper.gblCPTcacheON := FALSE;
   nuLogLikelihood0 := pkLikelihood.fnuLogLikelihood (0);
   --dbms_output.put_line(nuLogLikelihood0);


   -- Massive
   FOR rc IN cuOptimalLevel(32) LOOP

       pkBayesianMapper.tbAdjacencyMatrix := pkBayesianMapper.ftbLoadMatrix (rc.id,false);

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
           --dbms_output.put_line('nuMinor:'||nuMinor||' nuMinRow:'||nuMinRow||' nuMinCol:'||nuMinCol);

         EXIT WHEN nuMinor > pkBayesianMapper.gnuEpsilon ;
         -- Apply changes to adjancecy matrix
         pkBayesianMapper.tbAdjacencyMatrix (nuMinRow) (nuMinCol) :=
            1 - pkBayesianMapper.tbAdjacencyMatrix (nuMinRow) (nuMinCol);

         --dbms_output.put_line('Removing edge '||nuMinRow|| ' -> ' || nuMinCol);
         --dbms_output.put_line('with Epsilon: '||nuMinor);
         -- Calculate Global LogLikelihood
         --pkBayesianMapper.gblCPTcacheON := FALSE;
         --nuLogLikelihood := pkLikelihood.fnuLogLikelihood (0);
         --dbms_output.put_line('New LogLikelihood: '||nuLogLikelihood);
       END LOOP;
       -- Output
       tbPositions1 := pkBayesianMapper.ftbGetPositionsMatrix (pkBayesianMapper.tbAdjacencyMatrix, 1);
       -- Print number of edges
       dbms_output.put(tbPositions1.count);
       -- Print Max InGrade Graph
       nuMaxIngradeGraph := fnuMaxIngrade;
       dbms_output.put(chr(9)||nuMaxIngradeGraph);
       -- Print Likelihood
       pkBayesianMapper.gblCPTcacheON := FALSE;
       nuLogLikelihood := pkLikelihood.fnuLogLikelihood (0);
       dbms_output.put_line(chr(9)||(nuLogLikelihood-nuLogLikelihood0));

	 -- Save graph's structure into adjacency_matrix_log
	 pkBayesianMapper.insMatrix (pkBayesianMapper.tbAdjacencyMatrix, rc.id, false, 4);

   END LOOP; --- Massive

   DBMS_OUTPUT.put_line ('FIN');
END;
/
