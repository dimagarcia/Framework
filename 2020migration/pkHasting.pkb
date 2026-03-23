CREATE OR REPLACE PACKAGE BODY pkHasting
IS
   /*
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
   PROCEDURE Initialize
   IS
   BEGIN
      -- Clear power matrix table
      DELETE FROM power_matrix
            WHERE pomapow > 0;

      -- Initialization power one
      FOR i IN 1 .. pkBayesianMapper.tbR.COUNT
      LOOP
         FOR j IN 1 .. pkBayesianMapper.tbR.COUNT
         LOOP
            INSERT INTO POWER_MATRIX
                 VALUES (1,
                         i,
                         j,
                         0);
         END LOOP;
      END LOOP;

      -- Commit
      COMMIT;
   END Initialize;


   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        withoutLikelihood
    * Description: Bayesian structure learning without score likelihood function
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

   PROCEDURE withoutLikelihood
   IS
      tbPowerMatrix   pkBayesianMapper.tytbRow;
      tbIdentity      pkBayesianMapper.tytbRow;
      tbTranspose     pkBayesianMapper.tytbRow;
      tbTruthMatrix   pkBayesianMapper.tytbRow;

      tbPosibles      pkBayesianMapper.tytbRow;
      tbPositions0    pkBayesianMapper.tytbRow;
      tbPositions1    pkBayesianMapper.tytbRow;

      nuIdx           INTEGER;
      nuIdx2          INTEGER;
      nuRow           INTEGER;
      nuCol           INTEGER;
      nuT             INTEGER := 1;
   BEGIN
      -- Initialization power matrices with Zeros (0)
      Initialize;

      -- Load last adjacency matrix (power one)
      pkBayesianMapper.tbAdjacencyMatrix :=
         pkBayesianMapper.ftbLoadMatrix (1);
      /*      nuIdx := pkBayesianMapper.tbAdjacencyMatrix.first;
            LOOP
             EXIT WHEN nuIdx IS NULL;

             nuIdx2 := pkBayesianMapper.tbAdjacencyMatrix(nuIdx).first;
             LOOP
              EXIT WHEN nuIdx2 IS NULL;

              dbms_output.put_line(nuIdx||','||nuIdx2||' : '||pkBayesianMapper.tbAdjacencyMatrix(nuIdx)(nuIdx2));

              nuIdx2 := pkBayesianMapper.tbAdjacencyMatrix(nuIdx).next(nuIdx2);
             END LOOP;

             nuIdx := pkBayesianMapper.tbAdjacencyMatrix.next(nuIdx);
            END LOOP;*/

      tbTruthMatrix := pkBayesianMapper.ftbLoadMatrix (0);

      /*      nuIdx := tbTruthMatrix.first;
            LOOP
             EXIT WHEN nuIdx IS NULL;

             nuIdx2 := tbTruthMatrix(nuIdx).first;
             LOOP
              EXIT WHEN nuIdx2 IS NULL;

              dbms_output.put_line(nuIdx||','||nuIdx2||' : '||tbTruthMatrix(nuIdx)(nuIdx2));

              nuIdx2 := tbTruthMatrix(nuIdx).next(nuIdx2);
             END LOOP;

             nuIdx := tbTruthMatrix.next(nuIdx);
            END LOOP;*/

      LOOP
         -- Calculate space of possible operations
         tbIdentity :=
            pkBayesianMapper.ftbIdentMatrix (pkBayesianMapper.tbR.COUNT);
         -- Calculate matrix identity plus A
         tbPosibles :=
            pkBayesianMapper.ftbSumMatrix (
               tbIdentity,
               pkBayesianMapper.tbAdjacencyMatrix);
         -- Calculate all walks
         tbPowerMatrix := pkBayesianMapper.tbAdjacencyMatrix; --pkBayesianMapper.ftbLoadMatrix(1);
         tbTranspose := pkBayesianMapper.ftbTransMatrix (tbPowerMatrix);
         tbPosibles :=
            pkBayesianMapper.ftbSumMatrix (tbPosibles, tbTranspose);

         FOR i IN 2 .. pkBayesianMapper.tbR.COUNT - 1
         LOOP
            tbPowerMatrix := pkBayesianMapper.ftbMultMatrix (tbPowerMatrix);
            tbTranspose := pkBayesianMapper.ftbTransMatrix (tbPowerMatrix);
            tbPosibles :=
               pkBayesianMapper.ftbSumMatrix (tbPosibles, tbTranspose);
         END LOOP;

         /*          nuIdx := tbPosibles.first;
                   LOOP
                    EXIT WHEN nuIdx IS NULL;

                    nuIdx2 := tbPosibles(nuIdx).first;
                    LOOP
                     EXIT WHEN nuIdx2 IS NULL;

                     dbms_output.put_line(nuIdx||','||nuIdx2||' : '||tbPosibles(nuIdx)(nuIdx2));

                     nuIdx2 := tbPosibles(nuIdx).next(nuIdx2);
                    END LOOP;

                    nuIdx := tbPosibles.next(nuIdx);
                   END LOOP;*/

         -- Get positions to change in tha adjacency matrix
         tbPositions0 :=
            pkBayesianMapper.ftbGetPositionsMatrix (tbPosibles, 0);
         tbPositions1 :=
            pkBayesianMapper.ftbGetPositionsMatrix (
               pkBayesianMapper.tbAdjacencyMatrix,
               1);

         -- Determine the next local operation over structure graph
         nuIdx :=
            CEIL (
               DBMS_RANDOM.VALUE (0, tbPositions0.COUNT + tbPositions1.COUNT));

         --dbms_output.put_line('nuIdx: '||nuIdx||' max: '||to_char(tbPositions0.count + tbPositions1.count));

         IF (nuIdx <= tbPositions0.COUNT)
         THEN
            nuRow := tbPositions0 (nuIdx) (1);
            nuCol := tbPositions0 (nuIdx) (2);
         ELSE
            nuRow := tbPositions1 (nuIdx - tbPositions0.COUNT) (1);
            nuCol := tbPositions1 (nuIdx - tbPositions0.COUNT) (2);
         END IF;

         --dbms_output.put_line(nuRow||','||nuCol);
         pkBayesianMapper.tbAdjacencyMatrix (nuRow) (nuCol) :=
            1 - pkBayesianMapper.tbAdjacencyMatrix (nuRow) (nuCol);

         IF (pkBayesianMapper.fblCompMatrix (
                pkBayesianMapper.tbAdjacencyMatrix,
                tbTruthMatrix))
         THEN
            DBMS_OUTPUT.put_line (
               'se logr??? matriz verdadera en intento: ' || nuT);
         END IF;

         EXIT WHEN nuT = 100000;
         nuT := nuT + 1;
      END LOOP;

      nuIdx := pkBayesianMapper.tbAdjacencyMatrix.FIRST;

      LOOP
         EXIT WHEN nuIdx IS NULL;

         nuIdx2 := pkBayesianMapper.tbAdjacencyMatrix (nuIdx).FIRST;

         LOOP
            EXIT WHEN nuIdx2 IS NULL;

            DBMS_OUTPUT.put_line (
                  nuIdx
               || ','
               || nuIdx2
               || ' : '
               || pkBayesianMapper.tbAdjacencyMatrix (nuIdx) (nuIdx2));

            nuIdx2 :=
               pkBayesianMapper.tbAdjacencyMatrix (nuIdx).NEXT (nuIdx2);
         END LOOP;

         nuIdx := pkBayesianMapper.tbAdjacencyMatrix.NEXT (nuIdx);
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.put_line ('Err: ' || nuRow || ',' || nuCol);
   END withoutLikelihood;

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
   PROCEDURE simulationLikelihood (inuNumSim IN INTEGER)
   IS
      tbPowerMatrix             pkBayesianMapper.tytbRow;
      tbIdentity                pkBayesianMapper.tytbRow
         := pkBayesianMapper.ftbIdentMatrix (pkBayesianMapper.tbR.COUNT);
      tbTranspose               pkBayesianMapper.tytbRow;
      tbTruthMatrix             pkBayesianMapper.tytbRow;

      tbPosibles                pkBayesianMapper.tytbRow;
      tbPositions0              pkBayesianMapper.tytbRow;
      tbPositions1              pkBayesianMapper.tytbRow;
      -- 2016-07-22 DGArcia inverse operator
      --tbPositions2        pkBayesianMapper.tytbRow;
      --tbMatrixBackup       pkBayesianMapper.tytbRow;
      nuRowOld                  INTEGER;
      nuColOld                  INTEGER;
      nuLogLikelihoodPartialOld   NUMBER;

      nuIdx                     INTEGER;
      nuIdx2                    INTEGER;
      nuRow                     INTEGER;
      nuCol                     INTEGER;
      nuT                       INTEGER := 1;

      -- Hasting variables
      nuPx                      NUMBER;
      nuPxp                     NUMBER;
      nuAlpha                   NUMBER;
      nuR                       NUMBER;

      nuLogLikelihood           NUMBER;
      nuLogLikelihoodPartial    NUMBER;
      nuLogLikelihoodPrevious   NUMBER;
      nuE              CONSTANT NUMBER := EXP (1);

      nuLenghListPrev           NUMBER;
      nuLn_Beta                 NUMBER;
      nuLn_Delta                NUMBER;
      nuLn_Alpha                NUMBER;
      nuLn_r                    NUMBER;
      tbPositions0old           pkBayesianMapper.tytbRow;
      tbPositions1old           pkBayesianMapper.tytbRow;
      nuBestLogLikelihood       NUMBER := 0;

      blEdgeReversal            BOOLEAN := FALSE;
      grade                     INTEGER;

-- 2016-09-29 DGarcia  Enable calculate Local LogLikelihood
      nuLogLikelihoodPartial2    NUMBER;
      tbPositions0old2           pkBayesianMapper.tytbRow;
      tbPositions1old2           pkBayesianMapper.tytbRow;

      /**********************************************************************************************************************************
       ** EMBEDDED METHODS
       **********************************************************************************************************************************/
      /**
        * Propiedad intelectual de la Universidad del Valle
        * Name:        ftbCalculateGraphsAcyclic
        * Description: Calculate space of possible operations
        *
        * Parametros :  Descripcion
        * -            -
        *
        * Author:      Diego Garcia
        * Date:        08th Aug 2016
        *
        * Modification Log:
        * ---------------------------
        * 2016-08-08   Diego Garcia    Creation.
        */
      FUNCTION ftbCalculateGraphsAcyclic
         RETURN pkBayesianMapper.tytbRow
      IS
      BEGIN
         -- Calculate matrix identity plus A
         tbPosibles := pkBayesianMapper.ftbSumMatrix (tbIdentity,
               				pkBayesianMapper.tbAdjacencyMatrix);
         -- Calculate all walks
         tbPowerMatrix := pkBayesianMapper.tbAdjacencyMatrix; --pkBayesianMapper.ftbLoadMatrix(1);
         tbTranspose := pkBayesianMapper.ftbTransMatrix (tbPowerMatrix);
         tbPosibles := pkBayesianMapper.ftbSumMatrix (tbPosibles, tbTranspose);

         FOR i IN 2 .. pkBayesianMapper.tbR.COUNT - 1
         LOOP
            tbPowerMatrix := pkBayesianMapper.ftbMultMatrix (tbPowerMatrix);
            tbTranspose := pkBayesianMapper.ftbTransMatrix (tbPowerMatrix);
            tbPosibles := pkBayesianMapper.ftbSumMatrix (tbPosibles, tbTranspose);
         END LOOP;

         RETURN tbPosibles;
      END ftbCalculateGraphsAcyclic;

      /**
        * Propiedad intelectual de la Universidad del Valle
        * Name:        printAdjacencyMatrix
        * Description: Print Adjacency Matrix
        *
        * Parametros :  Descripcion
        * -            -
        *
        * Author:      Diego Garcia
        * Date:        11th Aug 2016
        *
        * Modification Log:
        * ---------------------------
        * 2016-08-11   Diego Garcia    Creation.
        */
      PROCEDURE printAdjacencyMatrix
      IS
      BEGIN
         nuIdx := pkBayesianMapper.tbAdjacencyMatrix.FIRST;

         LOOP
            EXIT WHEN nuIdx IS NULL;
            nuIdx2 := pkBayesianMapper.tbAdjacencyMatrix (nuIdx).FIRST;

            LOOP
               EXIT WHEN nuIdx2 IS NULL;
               DBMS_OUTPUT.put_line (nuIdx || ',' || nuIdx2 || ' : '
                  || pkBayesianMapper.tbAdjacencyMatrix (nuIdx) (nuIdx2));
               nuIdx2 := pkBayesianMapper.tbAdjacencyMatrix (nuIdx).NEXT (nuIdx2);
            END LOOP;

            nuIdx := pkBayesianMapper.tbAdjacencyMatrix.NEXT (nuIdx);
         END LOOP;
      END printAdjacencyMatrix;
      
      PROCEDURE GetAdjacencyMatrixIndexes
      IS
      BEGIN
         IF (nuIdx <= tbPositions0.COUNT)
         THEN
            nuRow := tbPositions0 (nuIdx) (1);
            nuCol := tbPositions0 (nuIdx) (2);
         ELSIF (    nuIdx > tbPositions0.COUNT
                AND nuIdx <= tbPositions1.COUNT + tbPositions0.COUNT)
         THEN
            nuRow := tbPositions1 (nuIdx - tbPositions0.COUNT) (1);
            nuCol := tbPositions1 (nuIdx - tbPositions0.COUNT) (2);
         ELSE
            nuRow := tbPositions1 (nuIdx - tbPositions0.COUNT - tbPositions1.COUNT) (1);
            nuCol := tbPositions1 (nuIdx - tbPositions0.COUNT - tbPositions1.COUNT) (2);
         END IF;
      END GetAdjacencyMatrixIndexes;
   BEGIN
      -- Initialization power matrices with Zeros (0)
      Initialize;

      -- Load last adjacency matrix (power one)
      pkBayesianMapper.tbAdjacencyMatrix := pkBayesianMapper.ftbLoadMatrix (1);
	  
	  --2016-08-18 DGarcia Save graph's structure into adjacency_matrix_log
	  pkBayesianMapper.insMatrix (pkBayesianMapper.tbAdjacencyMatrix, 0, false, null);

      -- 2016-06-01 DGarcia set CPT Cache
      pkBayesianMapper.gblCPTcacheON := FALSE;
      -- 2016-06-05 09:56 DGarcia Clear Cache CPT

      -- 2016-06-14 DGarcia Fix updateing LogLikelihood in Hasting algorithm
      nuLogLikelihoodPrevious := pkLikelihood.fnuLogLikelihood (0);
      pkBayesianMapper.gblCPTcacheON := TRUE;

      -- 2016-06-14 DGarcia Fix updateing LogLikelihood in Hasting algorithm and Alpha evaluation criteria
      --nuPx := power(nuE, nuLogLikelihoodPrevious);
      --INSERT INTO trace VALUES ('Log Likelihood', 0, nuLogLikelihoodPrevious);

      tbTruthMatrix := pkBayesianMapper.ftbLoadMatrix (0);

      --20160623 DGarcia Fix Hasting
      -- Calculate space of possible operations
      tbPosibles := ftbCalculateGraphsAcyclic;

      -- Get positions to change in tha adjacency matrix
      tbPositions0 := pkBayesianMapper.ftbGetPositionsMatrix (tbPosibles, 0);
      tbPositions1 := pkBayesianMapper.ftbGetPositionsMatrix (pkBayesianMapper.tbAdjacencyMatrix, 1);
      -- 20160812 print grade
      grade := tbPositions1.COUNT;
      INSERT INTO trace VALUES (grade, 0, nuLogLikelihoodPrevious, null, 0, null);

      -- 20160623 DGarcia calculus Q(x | x') / Q(x' | x)
      --nuLenghListPrev := tbPositions0.count + tbPositions1.count;
      -- 20160808 DGarcia New operator : edge reverse (edge deletion + edge addition)
      nuLenghListPrev := tbPositions0.COUNT + tbPositions1.COUNT + tbPositions1.COUNT;

      LOOP
         -- Determine the next local operation over structure graph
         --nuIdx := ceil(dbms_random.value(0, tbPositions0.count + tbPositions1.count));
         --dbms_output.put_line('nuIdx: '||nuIdx||' max: '||to_char(tbPositions0.count + tbPositions1.count));

         -- 20160808 DGarcia New operator : edge reverse (edge deletion + edge addition)
         nuIdx := CEIL ( DBMS_RANDOM.VALUE (0, tbPositions0.COUNT + 2 * tbPositions1.COUNT));
         --nuIdx := CEIL ( DBMS_RANDOM.VALUE (0, tbPositions0.COUNT + tbPositions1.COUNT));

         -- 2016-09-12 DGarcia Fixes
         GetAdjacencyMatrixIndexes; -- set nuRow, nuCol
         -- dbms_output.put_line(nuRow||','||nuCol);

         -- Apply changes to adjancecy matrix
         pkBayesianMapper.tbAdjacencyMatrix (nuRow) (nuCol) := 1 - pkBayesianMapper.tbAdjacencyMatrix (nuRow) (nuCol);

-- 2016-09-12 DGArcia Drop Calculate Likelihood Partially
         --20160623 DGarcia Fix Hasting
-- 2016-09-29 DGarcia Move calculus of search space

-- 		 -- 2016-06-14 DGarcia Implementation calculate of log likelihood partially for x'
-- 2016-09-29 DGarcia  Enable calculate Local LogLikelihood
        --dbms_output.put_line('Begin pkLikelihood.fnuLogLikelihoodPartial');
 		 nuLogLikelihoodPartial := pkLikelihood.fnuLogLikelihoodPartial (nuCol);
        --dbms_output.put_line('End pkLikelihood.fnuLogLikelihoodPartial');

-- 
-- 		 -- 2016-06-14 DGarcia Fix updateing LogLikelihood for x' in Hasting algorithm
-- 		 --                    and Alpha evaluation criteria
-- 		 nuLogLikelihood := nuLogLikelihoodPrevious
-- 							- pkLikelihood.tbLogLikelihood (nuCol)
-- 							+ nuLogLikelihoodPartial;
-- 2016-08-18 DGarcia Fix two
-- 2016-09-29 DGarcia  Enable calculate Local LogLikelihood
 		/* pkBayesianMapper.gblCPTcacheON := FALSE;
 		nuLogLikelihood := pkLikelihood.fnuLogLikelihood (0);
 		pkBayesianMapper.gblCPTcacheON := TRUE;   */
 		
-- 2016-09-12 DGArcia Drop Calculate Likelihood Partially
        -- 		nuLogLikelihoodPartial := pkLikelihood.tbLogLikelihood (nuCol);
        -- 2016-08-20 0224 DGarcia Remove Global score
        --		 nuLogLikelihoodPartial := pkLikelihood.fnuLogLikelihoodPartial (nuCol);

         /*******************************************************************************************************/
         -- 20160809 DGarcia Operator edge deletion + edge addition
         IF (nuIdx > tbPositions1.COUNT + tbPositions0.COUNT)
         THEN
		 	-- 20160820 DGarcia Fix Score Trace
		 	
            -- 2016-09-12 DGArcia Drop Calculate Likelihood Partially
		 	--nuLogLikelihoodPartialOld := nuLogLikelihoodPartial;
-- 2016-09-29 DGarcia  Enable calculate Local LogLikelihood
		 	nuLogLikelihoodPartialOld := nuLogLikelihoodPartial;

            -- Get positions to change in tha adjacency matrix for x'
            --tbPositions0 := pkBayesianMapper.ftbGetPositionsMatrix (tbPosibles, 0);
            -- o Determine the next local operation over structure graph
            --nuIdx2 := CEIL (DBMS_RANDOM.VALUE (0, tbPositions0.COUNT));
            --nuRowOld := nuRow;
            --nuColOld := nuCol;
            --nuRow := tbPositions0 (nuIdx2) (1);
            --nuCol := tbPositions0 (nuIdx2) (2);
            -- Apply operator edge addition to adjacency matrix x-{e}
            --pkBayesianMapper.tbAdjacencyMatrix (nuRow) (nuCol) :=
            --   1 - pkBayesianMapper.tbAdjacencyMatrix (nuRow) (nuCol);
            --    for idx in tbPositions0.first..tbPositions0.last loop
            --     if (tbPositions0(idx)(1) = nuCol AND
            --      tbPositions0(idx)(2) = nuRow ) then
            --      -- Apply operator edge addition to adjacency matrix x-{e}
            --      pkBayesianMapper.tbAdjacencyMatrix (nuCol) (nuRow) :=
            --         1 - pkBayesianMapper.tbAdjacencyMatrix (nuCol) (nuRow);
            --      -- Calculate of log likelihood partially for new Structure (x-{e}+{a})
            --      nuLogLikelihoodPartial2 := pkLikelihood.fnuLogLikelihoodPartial (nuRow);
            --      -- Update global Log Likelihood x-{e}+{a}
            --      nuLogLikelihood := nuLogLikelihood
            --       - pkLikelihood.tbLogLikelihood(nuRow) + nuLogLikelihoodPartial2;
            blEdgeReversal := true;
            --     end if;
            --    end loop;

-- 2016-09-29 DGarcia Move calculus of search space
            -- Get positions to change in adjacency matrix of new Structure (x')
            tbPositions0old2 := tbPositions0;
            tbPositions1old2 := tbPositions1;
            -- Calculate space of possible operations for new Structure (x')
            --dbms_output.put_line('Begin ftbCalculateGraphsAcyclic');
            tbPosibles := ftbCalculateGraphsAcyclic;
            --dbms_output.put_line('End ftbCalculateGraphsAcyclic');
            tbPositions0 := pkBayesianMapper.ftbGetPositionsMatrix (tbPosibles, 0);
            --dbms_output.put_line('Control point 1');
            tbPositions1 := pkBayesianMapper.ftbGetPositionsMatrix (pkBayesianMapper.tbAdjacencyMatrix, 1);
            --dbms_output.put_line('Control point 2');
            /*
            IF (   pkBayesianMapper.tbAdjacencyMatrix (nuCol) (nuRow) = 0
                OR NOT blEdgeReversal)
            THEN */
               -- o Determine the next local operation over structure graph
               nuIdx2 := CEIL (DBMS_RANDOM.VALUE (0, tbPositions0.COUNT));
               nuRowOld := nuRow;
               nuColOld := nuCol;
               -- dbms_output.put_line(nuRowOld||','||nuColOld);

                --dbms_output.put_line('Control point 3');
               nuRow := tbPositions0 (nuIdx2) (1);
                --dbms_output.put_line('Control point 4');
               nuCol := tbPositions0 (nuIdx2) (2);
                --dbms_output.put_line('Control point 5');
               -- Apply operator edge addition to adjacency matrix x-{e}
               pkBayesianMapper.tbAdjacencyMatrix (nuRow) (nuCol) :=
                  1 - pkBayesianMapper.tbAdjacencyMatrix (nuRow) (nuCol);
-- 			   -- Calculate of log likelihood partially for new Structure (x-{e}+{a})
-- 			   nuLogLikelihoodPartial2 := pkLikelihood.fnuLogLikelihoodPartial (nuCol);
-- 			   -- Update global Log Likelihood x-{e}+{a}
-- 			   nuLogLikelihood := nuLogLikelihood
-- 								  - pkLikelihood.tbLogLikelihood (nuCol)
-- 								  + nuLogLikelihoodPartial2;

-- 2016-09-12 DGArcia Drop Calculate Likelihood Partially
-- 2016-08-18 DGarcia Fix two

-- 2016-09-29 DGarcia  Enable calculate Local LogLikelihood
 				/* pkBayesianMapper.gblCPTcacheON := FALSE;
 				nuLogLikelihood := pkLikelihood.fnuLogLikelihood (0);
 				pkBayesianMapper.gblCPTcacheON := TRUE; */

-- 				nuLogLikelihoodPartial2 := pkLikelihood.tbLogLikelihood (nuCol);
-- 2016-08-20 0224 DGarcia Remove Global score
-- 2016-09-29 DGarcia  Enable calculate Local LogLikelihood
                --dbms_output.put_line('Begin pkLikelihood.fnuLogLikelihoodPartial Two');
 				nuLogLikelihoodPartial := pkLikelihood.fnuLogLikelihoodPartial (nuCol);
                --dbms_output.put_line('End pkLikelihood.fnuLogLikelihoodPartial Two');
		 	-- 20160820 DGarcia Fix Score Trace

-- 2016-09-12 DGArcia Drop Calculate Likelihood Partially
--				nuLogLikelihoodPartial := pkLikelihood.fnuLogLikelihoodPartial (nuCol);
          /*  END IF; */

-- 2016-09-29 DGarcia Move calculus of search space

-- 2016-08-20 0224 DGarcia Remove Global score
-- 2016-09-29 DGarcia  Enable calculate Local LogLikelihood
 			 nuLn_Delta := nuLogLikelihoodPartial - pkLikelihood.tbLogLikelihood (nuCol) +
 							nuLogLikelihoodPartialOld - pkLikelihood.tbLogLikelihood (nuColOld);
		 	-- 20160820 DGarcia Fix Score Trace							
/*			 nuLn_Delta := nuLogLikelihoodPartial - pkLikelihood.tbLogLikelihood (nuCol) +
			 				nuLogLikelihoodPartialOld - pkLikelihood.tbLogLikelihood (nuColOld);*/

-- 2016-09-12 DGArcia Drop Calculate Likelihood Partially
-- 2016-09-29 DGarcia  Enable calculate Local LogLikelihood
			 --nuLn_Delta := nuLogLikelihood - nuLogLikelihoodPrevious;
		 ELSE
-- 2016-08-20 0224 DGarcia Remove Global score
-- 		 nuLn_Delta := nuLogLikelihood - nuLogLikelihoodPrevious;

-- 2016-09-29 DGarcia  Enable calculate Local LogLikelihood
             --dbms_output.put_line('nuCol='||nuCol);
			 nuLn_Delta := nuLogLikelihoodPartial - pkLikelihood.tbLogLikelihood (nuCol);

-- 2016-09-12 DGArcia Drop Calculate Likelihood Partially
-- 2016-09-29 DGarcia  Enable calculate Local LogLikelihood
			 --nuLn_Delta := nuLogLikelihood - nuLogLikelihoodPrevious;
         END IF;

         /*******************************************************************************************************/
-- 2016-09-29 DGarcia Move calculus of search space
            -- Calculate space of possible operations for new Structure (x-{e}+{a})
            --dbms_output.put_line('Begin ftbCalculateGraphsAcyclic Two');
            tbPosibles := ftbCalculateGraphsAcyclic;
            --dbms_output.put_line('End ftbCalculateGraphsAcyclic Two');

            -- 2016-10-03 06:52 DGarcia Fix  ORA-06502: PL/SQL: numeric or value error: NULL index table key value
            tbPositions0old := tbPositions0;
            tbPositions1old := tbPositions1;

            -- Get positions to change in adjacency matrix of new Structure (x')
            tbPositions0 := pkBayesianMapper.ftbGetPositionsMatrix (tbPosibles, 0);
            --dbms_output.put_line('Control point One');
            tbPositions1 := pkBayesianMapper.ftbGetPositionsMatrix (pkBayesianMapper.tbAdjacencyMatrix,1);
            --dbms_output.put_line('Control point Two'||tbPositions0.COUNT);
            --dbms_output.put_line('Control point Two'||tbPositions1.COUNT);

         -- 20160623 DGarcia Fix calculus Alpha = [P(x') / P(x)].[Q(x | x') / Q(x' | x)]
         --nuLn_Beta := ln( nuLenghListPrev / (tbPositions0.count + tbPositions1.count) );
         -- 20160808 DGarcia New operator : edge reverse (edge deletion + edge addition)
         nuLn_Beta := LN ( nuLenghListPrev / (tbPositions0.COUNT + 2 * tbPositions1.COUNT));
            --dbms_output.put_line('Control point Two');

         nuLn_Alpha := nuLn_Delta + nuLn_Beta;

         -- Compute Ln_r = nim (Ln_Alpha, 0)
         IF (nuLn_Alpha < 0)
         THEN
            nuLn_r := nuLn_Alpha;
         ELSE
            nuLn_r := 0;
         END IF;

         -- 2016-06-14 Dgarcia Improve Alpha evaluation criteria
         IF (LN (DBMS_RANDOM.VALUE (0, 1)) < nuLn_r)
         THEN
           INSERT INTO trace VALUES (grade, nuT, nuLn_Delta, null, 0, null);
            -- Updating current values
            --nuPx := nuPxp;
-- 2016-08-18 DGarcia Fix two
-- 			nuLogLikelihoodPrevious := nuLogLikelihood;


-- 2016-09-12 DGArcia Drop Calculate Likelihood Partially
-- 2016-10-01 Dgarcia Enable calculus of local Likelihood
            -- 20160809 DGarcia Operator edge deletion + edge addition
            /* IF (nuIdx > tbPositions1old.COUNT + tbPositions0old.COUNT)
            THEN */
            IF (blEdgeReversal)
               THEN
               dbms_output.put_line(nuT||' Double operation.');
            -- 20160623 DGarcia calculus Q(x | x') / Q(x' | x)
            --nuLenghListPrev := tbPositions0.count + tbPositions1.count;
            -- 20160808 DGarcia New operator : edge reverse (edge deletion + edge addition)
            nuLenghListPrev := tbPositions0old2.COUNT + 2 * tbPositions1old2.COUNT;
               /*
-- 				  pkLikelihood.tbLogLikelihood (nuCol) := nuLogLikelihoodPartial;
-- 				  pkLikelihood.tbLogLikelihood (nuRow) := nuLogLikelihoodPartial2;
		 	-- 20160820 DGarcia Fix Score Trace							
                  pkLikelihood.tbLogLikelihood (nuCol) := nuLogLikelihoodPartial;
                  pkLikelihood.tbLogLikelihood (nuRow) := nuLogLikelihoodPartialOld;
               ELSE */
-- 				  pkLikelihood.tbLogLikelihood (nuColOld) := nuLogLikelihoodPartial;
-- 				  pkLikelihood.tbLogLikelihood (nuCol) := nuLogLikelihoodPartial2;
-- 2016-10-01 Dgarcia Enable calculus of local Likelihood
                -- 20160812 print grade
            --dbms_output.put_line('Control point Three');
                grade := tbPositions1old2.COUNT;
                /*
                INSERT INTO trace VALUES (grade, nuT, nuLogLikelihoodPartialOld);
                INSERT INTO trace VALUES (grade, nuT, -pkLikelihood.tbLogLikelihood (nuColOld));

            --dbms_output.put_line('Control point Four');
                -- 20160812 print grade
                grade := tbPositions1old.COUNT;
                INSERT INTO trace VALUES (grade, nuT, nuLogLikelihoodPartial);
                INSERT INTO trace VALUES (grade, nuT, -pkLikelihood.tbLogLikelihood (nuCol));
                */

		 	-- 20160820 DGarcia Fix Score Trace
                  --dbms_output.put_line('nuColOld='||nuColOld||', nuCol='||nuCol);
				  pkLikelihood.tbLogLikelihood (nuColOld) := nuLogLikelihoodPartialOld;
				  pkLikelihood.tbLogLikelihood (nuCol) := nuLogLikelihoodPartial;
               /* END IF; */
            ELSE
            -- 20160623 DGarcia calculus Q(x | x') / Q(x' | x)
            --nuLenghListPrev := tbPositions0.count + tbPositions1.count;
            -- 20160808 DGarcia New operator : edge reverse (edge deletion + edge addition)
            nuLenghListPrev := tbPositions0old.COUNT + 2 * tbPositions1old.COUNT;

                -- 20160812 print grade
            --dbms_output.put_line('Control point Five');
                grade := tbPositions1old.COUNT;
-- 2016-10-01 Dgarcia Enable calculus of local Likelihood
                /*
                INSERT INTO trace VALUES (grade, nuT, nuLogLikelihoodPartial);
                INSERT INTO trace VALUES (grade, nuT, -pkLikelihood.tbLogLikelihood (nuCol));
                */
            --dbms_output.put_line('Control point Six');
                 --dbms_output.put_line('nuCol='||nuCol);
                pkLikelihood.tbLogLikelihood (nuCol) := nuLogLikelihoodPartial;
            END IF;

		  --2016-08-18 DGarcia Save graph's structure into adjacency_matrix_log
		  pkBayesianMapper.insMatrix (pkBayesianMapper.tbAdjacencyMatrix, nuT, false, NULL);
           --INSERT INTO trace VALUES (grade, nuT, nuLogLikelihoodPrevious);
		   -- 2016-08-20 DGarcia Fix score partial trace
           --INSERT INTO trace VALUES (grade, nuT, nuLogLikelihoodPartial);

			--nuLogLikelihoodPrevious := nuLogLikelihoodPrevious + nuLn_Delta;
            -- 2016-09-12 DGArcia Drop Calculate Likelihood Partially
-- 2016-09-12 DGArcia Drop Calculate Likelihood Partially
			--nuLogLikelihoodPrevious := nuLogLikelihoodPartial;
-- 2016-10-01 Dgarcia Enable calculus of local Likelihood
			--nuLogLikelihoodPrevious := nuLogLikelihood;

-- 			INSERT INTO trace VALUES (grade, nuLn_Delta, nuLogLikelihoodPrevious);
-- 2016-10-01 Dgarcia Enable calculus of local Likelihood
           	--INSERT INTO trace VALUES (grade, nuT, nuLogLikelihoodPrevious);

         ELSE -- Reject : reverse to below structure
            /*
                -- 2016-08-05 Dgarcia New Operator (delete + addition edge)
                IF (nuIdx > tbPositions0.count) THEN -- Current operator is deleting
                 -- o Accepting temporary
                 -- o Compute set of pair nodes where it is possible add edge
                 --   Calculate space of possible operations
                 --   Calculate matrix identity plus A
                 tbPosibles := pkBayesianMapper.ftbSumMatrix(tbIdentity, pkBayesianMapper.tbAdjacencyMatrix);
                 -- o Calculate all walks
                 tbPosibles := ftbCalculateGraphsAcyclic;

                 -- Get positions to change in tha adjacency matrix
                 tbPositions0 := pkBayesianMapper.ftbGetPositionsMatrix(tbPosibles, 0);
                 -- o Determine the next local operation over structure graph
                 nuIdx := ceil(dbms_random.value(0, tbPositions0.count));
                 nuRowOld := nuRow;
                 nuColOld := nuCol;
                 nuRow := tbPositions0(nuIdx)(1);
                 nuCol := tbPositions0(nuIdx)(2);
                 -- Apply operator to adjacency matrix
                           pkBayesianMapper.tbAdjacencyMatrix(nuRow)(nuCol) := 1 - pkBayesianMapper.tbAdjacencyMatrix(nuRow)(nuCol);
                 -- Update global Log Likelihood
                     nuLogLikelihood := nuLogLikelihood - nuLogLikelihoodPartial;
                 -- Calculate of log likelihood partially
                 nuLogLikelihoodPartial2 := pkLikelihood.fnuLogLikelihoodPartial(nuCol);
                     nuLogLikelihood := nuLogLikelihood +  nuLogLikelihoodPartial2;

                 -- o Calculus Alpha = [P(x') / P(x)].[Q(x | x') / Q(x' | x)]
                 nuLn_Beta := ln( nuLenghListPrev / tbPositions0.count );
                 nuLn_Delta := nuLogLikelihood - nuLogLikelihoodPrevious;
                 nuLn_Alpha :=  nuLn_Delta + nuLn_Beta;
                 -- Compute Ln_r = nim (Ln_Alpha, 0)
                 if (nuLn_Alpha < 0) then
                  nuLn_r := nuLn_Alpha;
                 else
                  nuLn_r := 0;
                 end if;

                 -- o Apply criteria of acceptance
                 if (ln (dbms_random.value(0, 1)) < nuLn_r) then
                  -- Updating current values
                  --nuPx := nuPxp;
                  nuLogLikelihoodPrevious := nuLogLikelihood;
                  pkLikelihood.tbLogLikelihood(nuCol) := nuLogLikelihoodPartial2;
                  pkLikelihood.tbLogLikelihood(nuColOld) := nuLogLikelihoodPartial;

                  -- For calculus Q(x | x') / Q(x' | x)
                  nuLenghListPrev := tbPositions0.count;
                 else -- 20160804 Dgarcia We Reject proposal definitely
                  pkBayesianMapper.tbAdjacencyMatrix(nuRow)(nuCol) := 1 - pkBayesianMapper.tbAdjacencyMatrix(nuRow)(nuCol);
                  pkBayesianMapper.tbAdjacencyMatrix(nuRowOld)(nuColOld) := 1 - pkBayesianMapper.tbAdjacencyMatrix(nuRowOld)(nuColOld);
                  -- 20160624 DGarcia Fix Hasting
                  tbPositions0 := tbPositions0old;
                  tbPositions1 := tbPositions1old;
                 end if;

                ELSE -- 20160804 Dgarcia We Reject proposal definitely
            */

            -- 20160809 DGarcia Operator edge deletion + edge addition
-- 2016-10-03 06:28 Dgarcia Fix ORA-06502: PL/SQL: numeric or value error: NULL index table key value
            -- IF (nuIdx > tbPositions1old.COUNT + tbPositions0old.COUNT)
            --THEN
               IF (blEdgeReversal)
                THEN /*
                  pkBayesianMapper.tbAdjacencyMatrix (nuRow) (nuCol) :=
                     1 - pkBayesianMapper.tbAdjacencyMatrix (nuRow) (nuCol);
                  pkBayesianMapper.tbAdjacencyMatrix (nuCol) (nuRow) :=
                     1 - pkBayesianMapper.tbAdjacencyMatrix (nuCol) (nuRow);
               ELSE */
                  pkBayesianMapper.tbAdjacencyMatrix (nuRowOld) (nuColOld) :=
                       1 - pkBayesianMapper.tbAdjacencyMatrix (nuRowOld) (nuColOld);
                  pkBayesianMapper.tbAdjacencyMatrix (nuRow) (nuCol) :=
                     1 - pkBayesianMapper.tbAdjacencyMatrix (nuRow) (nuCol);
               -- END IF;
            -- 20160624 DGarcia Fix Hasting
            tbPositions0 := tbPositions0old2;
            tbPositions1 := tbPositions1old2;
            ELSE
               pkBayesianMapper.tbAdjacencyMatrix (nuRow) (nuCol) :=
                  1 - pkBayesianMapper.tbAdjacencyMatrix (nuRow) (nuCol);
            -- 20160624 DGarcia Fix Hasting
            tbPositions0 := tbPositions0old;
            tbPositions1 := tbPositions1old;
            END IF;
         --    END IF;

         END IF;

         blEdgeReversal := FALSE;

         IF (pkBayesianMapper.fblCompMatrix ( pkBayesianMapper.tbAdjacencyMatrix,
                tbTruthMatrix))
         THEN
            nuBestLogLikelihood := nuLogLikelihoodPrevious;
            DBMS_OUTPUT.put_line ( 'se logro matriz verdadera en intento: '
               || nuT
               || ' Likelihood:'
               || nuBestLogLikelihood);
         END IF;

         --20160624 Dgarcia Show the best structure
         IF (    nuBestLogLikelihood < 0
             AND nuLogLikelihoodPrevious < nuBestLogLikelihood)
         THEN
            nuBestLogLikelihood := nuLogLikelihoodPrevious;
            DBMS_OUTPUT.put_line ( 'se logro mejor aprox. en intento: '
               || nuT
               || ' Likelihood:'
               || nuBestLogLikelihood);
            printAdjacencyMatrix;
            DBMS_OUTPUT.put_line ('fin mejor aprox.');
         END IF;

         -- 2016-06-14 Dgarcia print trace Likelihood and logLikelihood
         --INSERT INTO trace VALUES ('Likelihood', nuT, nuPx);
         --INSERT INTO trace VALUES ('Log Likelihood', nuT, nuLogLikelihoodPrevious);

         IF (MOD (nuT, 100) = 0)
         THEN
            COMMIT;
         END IF;

         EXIT WHEN nuT = inuNumSim;                             --100000;--30;
         nuT := nuT + 1;
      END LOOP;

      printAdjacencyMatrix;
-- 201609121603 DGarcia Other Fix for NO DATA FOUND Error
/*
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.put_line ('Err: ' || nuRow|| ',' || nuCol || '|' || nuT
            || '|' || TO_CHAR (nuAlpha, '99999999.99999999')
            || '|' || TO_CHAR (nuPx, '99999999.99999999999')
            || '|' || TO_CHAR (nuPxp, '99999999.99999999999'));
         DBMS_OUTPUT.put_line ('Err: ' || SQLERRM);
         printAdjacencyMatrix;
*/
   END simulationLikelihood;

--------------------------------------------------------------------------------

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
   PROCEDURE simulationLikelihood (inuNumSim IN INTEGER, inuStrategy in integer)
   IS
      tbPowerMatrix             pkBayesianMapper.tytbRow;
      tbIdentity                pkBayesianMapper.tytbRow
         := pkBayesianMapper.ftbIdentMatrix (pkBayesianMapper.tbR.COUNT);
      tbTranspose               pkBayesianMapper.tytbRow;
      tbTruthMatrix             pkBayesianMapper.tytbRow;

      tbPosibles                pkBayesianMapper.tytbRow;
      tbPositions0              pkBayesianMapper.tytbRow;
      tbPositions1              pkBayesianMapper.tytbRow;
      nuRowOld                  INTEGER;
      nuColOld                  INTEGER;
      nuLogLikelihoodPartialOld   NUMBER;

      nuIdx                     INTEGER;
      nuIdx2                    INTEGER;
      nuRow                     INTEGER;
      nuCol                     INTEGER;
      nuT                       INTEGER := 1;
      --l                         binary_integer;
      --m                         binary_integer;

      -- Hasting variables
      nuPx                      NUMBER;
      nuPxp                     NUMBER;
      nuAlpha                   NUMBER;
      nuR                       NUMBER;

      nuLogLikelihood           NUMBER;
      nuLogLikelihoodPartial    NUMBER;
      nuLogLikelihoodPrevious   NUMBER;
      nuE              CONSTANT NUMBER := EXP (1);

      nuLenghListPrev           NUMBER;
      nuLn_Beta                 NUMBER;
      nuLn_Delta                NUMBER;
      nuLn_Delta1               NUMBER;
      nuLn_Delta2               NUMBER;
      nuLn_Alpha                NUMBER;
      nuLn_r                    NUMBER;
      tbPositions0old           pkBayesianMapper.tytbRow;
      tbPositions1old           pkBayesianMapper.tytbRow;
      nuBestLogLikelihood       NUMBER := 0;

      blEdgeReversal            BOOLEAN := FALSE;
      grade                     INTEGER;

    -- 2016-09-29 DGarcia  Enable calculate Local LogLikelihood
      nuLogLikelihoodPartial2    NUMBER;
      tbPositions0old2           pkBayesianMapper.tytbRow;
      tbPositions1old2           pkBayesianMapper.tytbRow;
      blAccept                   BOOLEAN := FALSE;
      /*************************************************************************
       ** EMBEDDED METHODS
       *************************************************************************
      /**
      * Propiedad intelectual de la Universidad del Valle
      * Name:        ftbCalculateGraphsAcyclic
      * Description: Calculate space of possible operations
      *
      * Parametros :  Descripcion
      * -            -
      *
      * Author:      Diego Garcia
      * Date:        08th Aug 2016
      *
      * Modification Log:
      * ---------------------------
      * 2016-08-08   Diego Garcia    Creation.
      */
      FUNCTION ftbCalculateGraphsAcyclic
         RETURN pkBayesianMapper.tytbRow
      IS
      BEGIN
         -- Calculate matrix identity plus A
         tbPosibles := pkBayesianMapper.ftbSumMatrix (tbIdentity,
               				pkBayesianMapper.tbAdjacencyMatrix);
         -- Calculate all walks
         tbPowerMatrix := pkBayesianMapper.tbAdjacencyMatrix; --pkBayesianMapper.ftbLoadMatrix(1);
         tbTranspose := pkBayesianMapper.ftbTransMatrix (tbPowerMatrix);
         tbPosibles := pkBayesianMapper.ftbSumMatrix (tbPosibles, tbTranspose);

         FOR i IN 2 .. pkBayesianMapper.tbR.COUNT - 1
         LOOP
            tbPowerMatrix := pkBayesianMapper.ftbMultMatrix (tbPowerMatrix);
            tbTranspose := pkBayesianMapper.ftbTransMatrix (tbPowerMatrix);
            tbPosibles := pkBayesianMapper.ftbSumMatrix (tbPosibles, tbTranspose);
         END LOOP;

         RETURN tbPosibles;
      END ftbCalculateGraphsAcyclic;
      /**
      * Propiedad intelectual de la Universidad del Valle
      * Name:        printAdjacencyMatrix
      * Description: Print Adjacency Matrix
      *
      * Parametros :  Descripcion
      * -            -
      *
      * Author:      Diego Garcia
      * Date:        11th Aug 2016
      *
      * Modification Log:
      * ---------------------------
      * 2016-08-11   Diego Garcia    Creation.
      */
      PROCEDURE printAdjacencyMatrix
      IS
      BEGIN
         nuIdx := pkBayesianMapper.tbAdjacencyMatrix.FIRST;
         LOOP
            EXIT WHEN nuIdx IS NULL;
            nuIdx2 := pkBayesianMapper.tbAdjacencyMatrix (nuIdx).FIRST;
            LOOP
               EXIT WHEN nuIdx2 IS NULL;
               DBMS_OUTPUT.put_line (nuIdx || ',' || nuIdx2 || ' : '
                  || pkBayesianMapper.tbAdjacencyMatrix (nuIdx) (nuIdx2));
               nuIdx2 := pkBayesianMapper.tbAdjacencyMatrix (nuIdx).NEXT (nuIdx2);
            END LOOP;
            nuIdx := pkBayesianMapper.tbAdjacencyMatrix.NEXT (nuIdx);
         END LOOP;
      END printAdjacencyMatrix;
      --------------------------------------------------------------------------
      PROCEDURE GetAdjacencyMatrixIndexes
      IS
      BEGIN
         IF (nuIdx <= tbPositions0.COUNT) THEN
            nuRow := tbPositions0 (nuIdx) (1);
            nuCol := tbPositions0 (nuIdx) (2);
         ELSIF (    nuIdx > tbPositions0.COUNT
                AND nuIdx <= tbPositions1.COUNT + tbPositions0.COUNT) THEN
            nuRow := tbPositions1 (nuIdx - tbPositions0.COUNT) (1);
            nuCol := tbPositions1 (nuIdx - tbPositions0.COUNT) (2);
         ELSE
            nuRow := tbPositions1 (nuIdx - tbPositions0.COUNT - tbPositions1.COUNT) (1);
            nuCol := tbPositions1 (nuIdx - tbPositions0.COUNT - tbPositions1.COUNT) (2);
         END IF;
      END GetAdjacencyMatrixIndexes;
      --------------------------------------------------------------------------
      PROCEDURE GetSearchSpace IS
      BEGIN
          -- Calculate space of possible operations
          tbPosibles := ftbCalculateGraphsAcyclic;

          -- Get positions to change in the adjacency matrix
          tbPositions0 := pkBayesianMapper.ftbGetPositionsMatrix (tbPosibles, 0);
          tbPositions1 := pkBayesianMapper.ftbGetPositionsMatrix (pkBayesianMapper.tbAdjacencyMatrix, 1);
      END GetSearchSpace;
      --------------------------------------------------------------------------
      PROCEDURE InitializeMatrices IS
      BEGIN
          -- Load last adjacency matrix (power one) without edges
          pkBayesianMapper.tbAdjacencyMatrix := pkBayesianMapper.ftbLoadMatrix (1);
          -- Load truth matrix (original)
          tbTruthMatrix := pkBayesianMapper.ftbLoadMatrix (0);
      END InitializeMatrices;
      --------------------------------------------------------------------------
      -- Calculate the maximum Ingrade for the current graph - 15/11/2016 DGarcia
      FUNCTION fnuMaxIngradeNode RETURN INTEGER
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
      END fnuMaxIngradeNode;
      --------------------------------------------------------------------------
      PROCEDURE SaveProcessTrace(inuIter in integer, inuValue in number, inuGrade in integer) IS
        nuMaxIngrade number;
      BEGIN
          nuMaxIngrade := fnuMaxIngradeNode;
          -- Print grade
          INSERT INTO trace VALUES (inuGrade, inuIter, inuValue, inuStrategy, nuMaxIngrade, null);
    	  -- Save graph's structure into adjacency_matrix_log
    	  pkBayesianMapper.insMatrix (pkBayesianMapper.tbAdjacencyMatrix, inuIter, false, inuStrategy);
      END SaveProcessTrace;
      --------------------------------------------------------------------------
      PROCEDURE PickOneChangeforStructure(inuLengthSearchSpace in integer) IS
      BEGIN
         -- Determine the next local operation over structure graph
         -- New operator : edge reverse (edge deletion + edge addition)
         nuIdx := CEIL ( DBMS_RANDOM.VALUE (0, inuLengthSearchSpace));
         -- Set nuRow and nuCol indexes necesary for change structure network
         GetAdjacencyMatrixIndexes;

      END PickOneChangeforStructure;
      --------------------------------------------------------------------------
      -- Save all variables in case of roll back (this is, if reject proposal structure)
      PROCEDURE SaveRollBackVariables IS
      BEGIN
        -- Save local (in nuCol) LogLikelihood after of apply deleting operation
        nuLogLikelihoodPartialOld := nuLogLikelihoodPartial;
        -- Save searchSpace before to change in adjacency matrix of new Structure (x')
        tbPositions0old := tbPositions0;
        tbPositions1old := tbPositions1;
        -- Save indexes used for change structure (if rollback must do)
        nuRowOld := nuRow;
        nuColOld := nuCol;
      END SaveRollBackVariables;
      --------------------------------------------------------------------------
   BEGIN
      -- Initialization power matrices with Zeros (0)
      Initialize;

      -- Load last adjacency matrix (power one) without edges
      -- Load truth matrix (original)
      InitializeMatrices;
      
      -- Set CPT Cache
      -- Calculate Global LogLikelihood
      pkBayesianMapper.gblCPTcacheON := FALSE;
      nuLogLikelihoodPrevious := pkLikelihood.fnuLogLikelihood (0);
      pkBayesianMapper.gblCPTcacheON := TRUE;


      -- Calculate space for looking for an operation that change network structure
      GetSearchSpace;

      -- Save grade and Save graph's structure into adjacency_matrix_log
      SaveProcessTrace(0,nuLogLikelihoodPrevious, tbPositions1.COUNT);

      -- Support calculus Q(x | x') / Q(x' | x)
      -- New operator : edge reverse (edge deletion + edge addition)
      nuLenghListPrev := tbPositions0.COUNT + 2 * tbPositions1.COUNT;

      LOOP
         -- Determine the next local operation over structure graph
         -- including New operator : edge reverse (edge deletion + edge addition)
         -- And set nuRow and nuCol indexes necesary for change structure network
         PickOneChangeforStructure(tbPositions0.COUNT + 2 * tbPositions1.COUNT);

         -- Apply changes to adjancecy matrix
         pkBayesianMapper.tbAdjacencyMatrix (nuRow) (nuCol) := 1 - pkBayesianMapper.tbAdjacencyMatrix (nuRow) (nuCol);

         -- Calculate local (in nuCol) LogLikelihood (After of change structure network)
 		 nuLogLikelihoodPartial := pkLikelihood.fnuLogLikelihoodPartial (nuCol);
 		 
		 nuLn_Delta1 := nuLogLikelihoodPartial - pkLikelihood.tbLogLikelihood (nuCol);
		 nuLn_Delta2 := 0;
         -- Save all variables in case of roll back (this is, if reject proposal structure)
         SaveRollBackVariables;
         /*******************************************************************************************************/
         -- Apply double Operator: edge deletion + edge addition
         IF (nuIdx > tbPositions1.COUNT + tbPositions0.COUNT) THEN
            -- Enabled flag of double operation
            blEdgeReversal := true;

            -- Calculate space of possible operations for new Structure (x')
            GetSearchSpace;

            -- Get positions to change in adjacency matrix of new Structure (x')
               -- o Determine the next local operation over structure graph
            PickOneChangeforStructure(tbPositions0.COUNT);

            -- Apply operator edge addition to adjacency matrix (this is, x-{e}+{a})
            pkBayesianMapper.tbAdjacencyMatrix (nuRow) (nuCol) := 1 - pkBayesianMapper.tbAdjacencyMatrix (nuRow) (nuCol);

            -- Calculate local (in nuCol) LogLikelihood (After of change structure network for second time)
			nuLogLikelihoodPartial := pkLikelihood.fnuLogLikelihoodPartial (nuCol);
			   
            if (nuCol != nuColOld) then
		      nuLn_Delta2 :=   nuLogLikelihoodPartial - pkLikelihood.tbLogLikelihood (nuCol);
		    else
		      nuLn_Delta2 :=   nuLogLikelihoodPartial - nuLogLikelihoodPartialOld;
            end if;
         END IF;
         /*******************************************************************************************************/
         nuLn_Delta := nuLn_Delta1 + nuLn_Delta2;

         -- Calculate space of possible operations for new Structure (x')
         GetSearchSpace;

         -- calculus Alpha = [P(x') / P(x)].[Q(x | x') / Q(x' | x)]
         nuLn_Beta := LN ( nuLenghListPrev / (tbPositions0.COUNT + 2 * tbPositions1.COUNT));

         nuLn_Alpha := nuLn_Delta + nuLn_Beta;

         -- Compute Ln_r = nim (Ln_Alpha, 0)
         IF (nuLn_Alpha < 0) THEN
            nuLn_r := nuLn_Alpha;
         ELSE
            nuLn_r := 0;
         END IF;

         -- Alpha evaluation criteria
         IF (LN (DBMS_RANDOM.VALUE (0, 1)) < nuLn_r) THEN
            -- Apply Strategies for avoid overfitting
            IF (blEdgeReversal OR (NOT blEdgeReversal AND NOT (nuIdx > tbPositions1.COUNT + tbPositions0.COUNT) ) ) THEN
               -- Apply Strategies for avoid overfitting
               IF (inuStrategy = 1 AND -- Pass filtering : Epsilon
                    pkBayesianMapper.gnuEpsilon <= pkFiltering.fnuGetepsilon(nuRow, nuCol) ) THEN
                        blAccept := true;
               ELSIF (inuStrategy = 2 AND -- Pass filtering : GradeIn
                    pkBayesianMapper.gnuInGrade >= pkFiltering.fnuGetInGrade(nuCol) ) THEN
                        blAccept := true;
               ELSIF (inuStrategy = 12 AND -- Pass filtering : Epsilon + GradeIn
                    pkBayesianMapper.gnuEpsilon <= pkFiltering.fnuGetepsilon(nuRow, nuCol) AND
                    pkBayesianMapper.gnuInGrade >= pkFiltering.fnuGetInGrade(nuCol)) THEN
                        blAccept := true;
               ELSIF (inuStrategy = 0) then
                        blAccept := true;
               ELSE-- No pass filtering
                    blAccept := false;
               END IF;
             ELSE -- Except deleting operation
                        blAccept := true;
             END IF;
          ELSE-- No pass Alpha criteria
            blAccept := false;
          END IF;
        
         IF (blAccept) THEN

           -- Save grade and Save graph's structure into adjacency_matrix_log
           SaveProcessTrace(nuT, nuLn_Delta, tbPositions1.COUNT);

           nuLenghListPrev := tbPositions0old.COUNT + 2 * tbPositions1old.COUNT;

            -- Operator edge deletion + edge addition
            IF (blEdgeReversal) THEN
			  pkLikelihood.tbLogLikelihood (nuColOld) := nuLogLikelihoodPartialOld;
			  pkLikelihood.tbLogLikelihood (nuCol) := nuLogLikelihoodPartial;
            ELSE
                pkLikelihood.tbLogLikelihood (nuCol) := nuLogLikelihoodPartial;
            END IF;

         ELSE -- Reject : reverse to below structure
            tbPositions0 := tbPositions0old;
            tbPositions1 := tbPositions1old;
            -- Operator edge deletion + edge addition
            IF (blEdgeReversal) THEN
                  pkBayesianMapper.tbAdjacencyMatrix (nuRowOld) (nuColOld) :=
                       1 - pkBayesianMapper.tbAdjacencyMatrix (nuRowOld) (nuColOld);
                  pkBayesianMapper.tbAdjacencyMatrix (nuRow) (nuCol) :=
                     1 - pkBayesianMapper.tbAdjacencyMatrix (nuRow) (nuCol);
            ELSE
               pkBayesianMapper.tbAdjacencyMatrix (nuRow) (nuCol) :=
                  1 - pkBayesianMapper.tbAdjacencyMatrix (nuRow) (nuCol);
            END IF;

         END IF;

         blEdgeReversal := FALSE;

         IF (pkBayesianMapper.fblCompMatrix ( pkBayesianMapper.tbAdjacencyMatrix,
                tbTruthMatrix)) THEN
            nuBestLogLikelihood := nuLogLikelihoodPrevious;
            DBMS_OUTPUT.put_line ( 'se logro matriz verdadera en intento: '
               || nuT
               || ' Likelihood:'
               || nuBestLogLikelihood);
         END IF;

         --20160624 Dgarcia Show the best structure
         IF (    nuBestLogLikelihood < 0
             AND nuLogLikelihoodPrevious < nuBestLogLikelihood) THEN
            nuBestLogLikelihood := nuLogLikelihoodPrevious;
            DBMS_OUTPUT.put_line ( 'se logro mejor aprox. en intento: '
               || nuT
               || ' Likelihood:'
               || nuBestLogLikelihood);
            printAdjacencyMatrix;
            DBMS_OUTPUT.put_line ('fin mejor aprox.');
         END IF;


         IF (MOD (nuT, 100) = 0)
         THEN
            COMMIT;
         END IF;

         EXIT WHEN nuT = inuNumSim;                             --100000;--30;
         nuT := nuT + 1;
      END LOOP;

      printAdjacencyMatrix;

   EXCEPTION
      WHEN OTHERS THEN
         DBMS_OUTPUT.put_line ('Err: ' || nuRow|| ',' || nuCol || '|' || nuT
            || '|' || TO_CHAR (nuAlpha, '99999999.99999999')
            || '|' || TO_CHAR (nuPx, '99999999.99999999999')
            || '|' || TO_CHAR (nuPxp, '99999999.99999999999'));
         DBMS_OUTPUT.put_line ('Err: ' || SQLERRM);
         printAdjacencyMatrix;

   END simulationLikelihood;

   PROCEDURE metropolis
   IS
      nuFrom   INTEGER := 1;
      nuTo     INTEGER := 2;
      nuOp     INTEGER := 1;
   BEGIN
      -- 0. Loop until t
      FOR t IN 1 .. 1
      LOOP
         -- 0. Determine the next local operation over structure graph
         --nuOp := dbms_random.value(1,2);
         DBMS_OUTPUT.put_line ('Op: ' || nuOp);

         IF (nuOp = 1)
         THEN                                                      -- Add edge
            -- 1. Generate adjacency matrix position, randomly
            --nuFrom := dbms_random.value(1,pkBayesianMapper.tbAdjacencyMatrix.count);
            --nuTo := dbms_random.value(1,pkBayesianMapper.tbAdjacencyMatrix.count);
            LOOP
               EXIT WHEN nuFrom <> nuTo;
               nuTo :=
                  DBMS_RANDOM.VALUE (
                     1,
                     pkBayesianMapper.tbAdjacencyMatrix.COUNT);
            END LOOP;

            DBMS_OUTPUT.put_line ('Edge: ' || nuFrom || ', ' || nuTo);


            -- 2. Validate acyclic graph
            --    a Zero(0) in (nuTo,nuFrom) can change by One(1) if only if  (nuFrom,nuTo) is Zero too
            IF (    pkBayesianMapper.tbAdjacencyMatrix (nuTo) (nuFrom) = 0
                AND                                         -- Operation valid
                   pkBayesianMapper.tbAdjacencyMatrix (nuFrom) (nuTo) = 0)
            THEN                                            -- Avoiding cycles
               -- Conditions for keep the graph acyclic (size walk two)
               -- We can add one edge from nuFrom to nuTo, if exist not some walk of size two, from nuFrom to nuTo
               NULL;
            END IF;
         END IF;
      -- 3. Modify adjacency matrix
      -- 4. Calculate Likelihood function
      -- 5. Evaluate score fuction
      -- 6. Acept or reject proposal structure
      -- 7. Update adjacency matrix with proposal

      -- 8. End loop
      END LOOP;
   END metropolis;
   
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
    * 2018-09-18    Diego Garcia    Modify method: simulationPosterior
    *                               pkConjugate.saveAllHypParam (Deprecated)
    * 2017-06-07   Diego Garcia    Creation.
    */
   PROCEDURE simulationPosterior (inuNumSim IN INTEGER, inuStrategy in integer)
   IS
      tbPowerMatrix             pkBayesianMapper.tytbRow;
      tbIdentity                pkBayesianMapper.tytbRow
         := pkBayesianMapper.ftbIdentMatrix (pkBayesianMapper.tbR.COUNT);
      tbTranspose               pkBayesianMapper.tytbRow;
      tbTruthMatrix             pkBayesianMapper.tytbRow;

      tbPosibles                pkBayesianMapper.tytbRow;
      tbPositions0              pkBayesianMapper.tytbRow;
      tbPositions1              pkBayesianMapper.tytbRow;
      nuRowOld                  INTEGER;
      nuColOld                  INTEGER;
      nuLogLikelihoodPartialOld   NUMBER;

      nuIdx                     INTEGER;
      nuIdx2                    INTEGER;
      nuRow                     INTEGER;
      nuCol                     INTEGER;
      nuT                       INTEGER := 1;
      --l                         binary_integer;
      --m                         binary_integer;

      -- Hasting variables
      nuPx                      NUMBER;
      nuPxp                     NUMBER;
      nuAlpha                   NUMBER;
      nuR                       NUMBER;

      nuLogLikelihood           NUMBER;
      nuLogLikelihoodPartial    NUMBER;
      nuLogLikelihoodPrevious   NUMBER;
      nuE              CONSTANT NUMBER := EXP (1);

      nuLenghListPrev           NUMBER;
      nuLn_Beta                 NUMBER;
      nuLn_Delta                NUMBER;
      nuLn_Delta1               NUMBER;
      nuLn_Delta2               NUMBER;
      nuLn_Alpha                NUMBER;
      nuLn_r                    NUMBER;
      tbPositions0old           pkBayesianMapper.tytbRow;
      tbPositions1old           pkBayesianMapper.tytbRow;
      nuBestLogLikelihood       NUMBER := 0;

      blEdgeReversal            BOOLEAN := FALSE;
      grade                     INTEGER;

    -- 2016-09-29 DGarcia  Enable calculate Local LogLikelihood
      nuLogLikelihoodPartial2    NUMBER;
      tbPositions0old2           pkBayesianMapper.tytbRow;
      tbPositions1old2           pkBayesianMapper.tytbRow;
      blAccept                   BOOLEAN := FALSE;
      /*************************************************************************
       ** EMBEDDED METHODS
       *************************************************************************
      /**
      * Propiedad intelectual de la Universidad del Valle
      * Name:        ftbCalculateGraphsAcyclic
      * Description: Calculate space of possible operations
      *
      * Parametros :  Descripcion
      * -            -
      *
      * Author:      Diego Garcia
      * Date:        08th Aug 2016
      *
      * Modification Log:
      * ---------------------------
      * 2016-08-08   Diego Garcia    Creation.
      */
      FUNCTION ftbCalculateGraphsAcyclic
         RETURN pkBayesianMapper.tytbRow
      IS
      BEGIN
         -- Calculate matrix identity plus A
         tbPosibles := pkBayesianMapper.ftbSumMatrix (tbIdentity,
               				pkBayesianMapper.tbAdjacencyMatrix);
         -- Calculate all walks
         tbPowerMatrix := pkBayesianMapper.tbAdjacencyMatrix; --pkBayesianMapper.ftbLoadMatrix(1);
         tbTranspose := pkBayesianMapper.ftbTransMatrix (tbPowerMatrix);
         tbPosibles := pkBayesianMapper.ftbSumMatrix (tbPosibles, tbTranspose);

         FOR i IN 2 .. pkBayesianMapper.tbR.COUNT - 1
         LOOP
            tbPowerMatrix := pkBayesianMapper.ftbMultMatrix (tbPowerMatrix);
            tbTranspose := pkBayesianMapper.ftbTransMatrix (tbPowerMatrix);
            tbPosibles := pkBayesianMapper.ftbSumMatrix (tbPosibles, tbTranspose);
         END LOOP;

         RETURN tbPosibles;
      END ftbCalculateGraphsAcyclic;
      /**
      * Propiedad intelectual de la Universidad del Valle
      * Name:        printAdjacencyMatrix
      * Description: Print Adjacency Matrix
      *
      * Parametros :  Descripcion
      * -            -
      *
      * Author:      Diego Garcia
      * Date:        11th Aug 2016
      *
      * Modification Log:
      * ---------------------------
      * 2016-08-11   Diego Garcia    Creation.
      */
      PROCEDURE printAdjacencyMatrix
      IS
      BEGIN
         nuIdx := pkBayesianMapper.tbAdjacencyMatrix.FIRST;
         LOOP
            EXIT WHEN nuIdx IS NULL;
            nuIdx2 := pkBayesianMapper.tbAdjacencyMatrix (nuIdx).FIRST;
            LOOP
               EXIT WHEN nuIdx2 IS NULL;
               DBMS_OUTPUT.put_line (nuIdx || ',' || nuIdx2 || ' : '
                  || pkBayesianMapper.tbAdjacencyMatrix (nuIdx) (nuIdx2));
               nuIdx2 := pkBayesianMapper.tbAdjacencyMatrix (nuIdx).NEXT (nuIdx2);
            END LOOP;
            nuIdx := pkBayesianMapper.tbAdjacencyMatrix.NEXT (nuIdx);
         END LOOP;
      END printAdjacencyMatrix;
      --------------------------------------------------------------------------
      PROCEDURE GetAdjacencyMatrixIndexes
      IS
      BEGIN
         IF (nuIdx <= tbPositions0.COUNT) THEN
            nuRow := tbPositions0 (nuIdx) (1);
            nuCol := tbPositions0 (nuIdx) (2);
         ELSIF (    nuIdx > tbPositions0.COUNT
                AND nuIdx <= tbPositions1.COUNT + tbPositions0.COUNT) THEN
            nuRow := tbPositions1 (nuIdx - tbPositions0.COUNT) (1);
            nuCol := tbPositions1 (nuIdx - tbPositions0.COUNT) (2);
         ELSE
            nuRow := tbPositions1 (nuIdx - tbPositions0.COUNT - tbPositions1.COUNT) (1);
            nuCol := tbPositions1 (nuIdx - tbPositions0.COUNT - tbPositions1.COUNT) (2);
         END IF;
      END GetAdjacencyMatrixIndexes;
      --------------------------------------------------------------------------
      PROCEDURE GetSearchSpace IS
      BEGIN
          -- Calculate space of possible operations
          tbPosibles := ftbCalculateGraphsAcyclic;

          -- Get positions to change in the adjacency matrix
          tbPositions0 := pkBayesianMapper.ftbGetPositionsMatrix (tbPosibles, 0);
          tbPositions1 := pkBayesianMapper.ftbGetPositionsMatrix (pkBayesianMapper.tbAdjacencyMatrix, 1);
      END GetSearchSpace;
      --------------------------------------------------------------------------
      PROCEDURE InitializeMatrices IS
      BEGIN
          -- Load last adjacency matrix (power one) without edges
          pkBayesianMapper.tbAdjacencyMatrix := pkBayesianMapper.ftbLoadMatrix (1);
          -- Load truth matrix (original)
          tbTruthMatrix := pkBayesianMapper.ftbLoadMatrix (0);
      END InitializeMatrices;
      --------------------------------------------------------------------------
      -- Calculate the maximum Ingrade for the current graph - 15/11/2016 DGarcia
      FUNCTION fnuMaxIngradeNode RETURN INTEGER
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
      END fnuMaxIngradeNode;
      --------------------------------------------------------------------------
      PROCEDURE SaveProcessTrace(inuIter in integer, inuValue in number, inuGrade in integer) IS
        nuMaxIngrade number;
      BEGIN
          nuMaxIngrade := fnuMaxIngradeNode;
          -- Print grade
          INSERT INTO trace VALUES (inuGrade, inuIter, inuValue, inuStrategy, nuMaxIngrade, null);
    	  -- Save graph's structure into adjacency_matrix_log
    	  pkBayesianMapper.insMatrix (pkBayesianMapper.tbAdjacencyMatrix, inuIter, false, inuStrategy);
      END SaveProcessTrace;
      --------------------------------------------------------------------------
      PROCEDURE PickOneChangeforStructure(inuLengthSearchSpace in integer) IS
      BEGIN
         -- Determine the next local operation over structure graph
         -- New operator : edge reverse (edge deletion + edge addition)
         nuIdx := CEIL ( DBMS_RANDOM.VALUE (0, inuLengthSearchSpace));
         -- Set nuRow and nuCol indexes necesary for change structure network
         GetAdjacencyMatrixIndexes;

      END PickOneChangeforStructure;
      --------------------------------------------------------------------------
      -- Save all variables in case of roll back (this is, if reject proposal structure)
      PROCEDURE SaveRollBackVariables IS
      BEGIN
        -- Save local (in nuCol) LogLikelihood after of apply deleting operation
        nuLogLikelihoodPartialOld := nuLogLikelihoodPartial;
        -- Save searchSpace before to change in adjacency matrix of new Structure (x')
        tbPositions0old := tbPositions0;
        tbPositions1old := tbPositions1;
        -- Save indexes used for change structure (if rollback must do)
        nuRowOld := nuRow;
        nuColOld := nuCol;
      END SaveRollBackVariables;
      --------------------------------------------------------------------------
   BEGIN
      -- Initialization power matrices with Zeros (0)
      Initialize;

      -- Load last adjacency matrix (power one) without edges
      -- Load truth matrix (original)
      InitializeMatrices;
      
      -- Clear pkConjugate.tbHyperparam
      pkConjugate.clearHypParam;

      -- Empty structure is initialized with hyperparamters value equal to 2
      pkConjugate.initHypParam;

      -- Save All tbHyperparam
      --pkConjugate.saveAllHypParam;

      -- Set CPT Cache
      -- Calculate Global LogLikelihood
      pkBayesianMapper.gblCPTcacheON := FALSE;
      --nuLogLikelihoodPrevious := pkLikelihood.fnuLogLikelihood (0);
      
      nuLogLikelihoodPrevious := pkConjugate.fnuPosterior (0);
      pkBayesianMapper.gblCPTcacheON := TRUE;


      -- Calculate space for looking for an operation that change network structure
      GetSearchSpace;

      -- Save grade and Save graph's structure into adjacency_matrix_log
      SaveProcessTrace(0,nuLogLikelihoodPrevious, tbPositions1.COUNT);

      -- Support calculus Q(x | x') / Q(x' | x)
      -- New operator : edge reverse (edge deletion + edge addition)
      nuLenghListPrev := tbPositions0.COUNT + 2 * tbPositions1.COUNT;

      LOOP
         -- Determine the next local operation over structure graph
         -- including New operator : edge reverse (edge deletion + edge addition)
         -- And set nuRow and nuCol indexes necesary for change structure network
         PickOneChangeforStructure(tbPositions0.COUNT + 2 * tbPositions1.COUNT);

         -- Apply changes to adjancecy matrix
         pkBayesianMapper.tbAdjacencyMatrix (nuRow) (nuCol) := 1 - pkBayesianMapper.tbAdjacencyMatrix (nuRow) (nuCol);

         -- Calculate local (in nuCol) LogLikelihood (After of change structure network)
 		 --nuLogLikelihoodPartial := pkLikelihood.fnuLogLikelihoodPartial (nuCol);
 		 nuLogLikelihoodPartial := pkConjugate.fnuPosteriorPartial(nuCol);

		 --nuLn_Delta1 := nuLogLikelihoodPartial - pkLikelihood.tbLogLikelihood (nuCol);
		 nuLn_Delta1 := nuLogLikelihoodPartial / pkConjugate.tbPosterior(nuCol);

		 nuLn_Delta2 := 0;
         -- Save all variables in case of roll back (this is, if reject proposal structure)
         SaveRollBackVariables;

         --******************************************************************************************************
         -- Apply double Operator: edge deletion + edge addition
         IF (nuIdx > tbPositions1.COUNT + tbPositions0.COUNT) THEN
            -- Enabled flag of double operation
            blEdgeReversal := true;

            -- Calculate space of possible operations for new Structure (x')
            GetSearchSpace;

            -- Get positions to change in adjacency matrix of new Structure (x')
               -- o Determine the next local operation over structure graph
            PickOneChangeforStructure(tbPositions0.COUNT);

            -- Apply operator edge addition to adjacency matrix (this is, x-{e}+{a})
            pkBayesianMapper.tbAdjacencyMatrix (nuRow) (nuCol) := 1 - pkBayesianMapper.tbAdjacencyMatrix (nuRow) (nuCol);

            -- Calculate local (in nuCol) LogLikelihood (After of change structure network for second time)
			--nuLogLikelihoodPartial := pkLikelihood.fnuLogLikelihoodPartial (nuCol);
			nuLogLikelihoodPartial := pkConjugate.fnuPosteriorPartial(nuCol);

            if (nuCol != nuColOld) then
		      --nuLn_Delta2 :=   nuLogLikelihoodPartial - pkLikelihood.tbLogLikelihood (nuCol);
		      nuLn_Delta2 :=   nuLogLikelihoodPartial / pkConjugate.tbPosterior(nuCol);
		    else
		      --nuLn_Delta2 :=   nuLogLikelihoodPartial - nuLogLikelihoodPartialOld;
		      nuLn_Delta2 :=   nuLogLikelihoodPartial / nuLogLikelihoodPartialOld;
            end if;
         END IF;
         --******************************************************************************************************
         nuLn_Delta := nuLn_Delta1 + nuLn_Delta2;

         -- Calculate space of possible operations for new Structure (x')
         GetSearchSpace;

         -- calculus Alpha = [P(x') / P(x)].[Q(x | x') / Q(x' | x)]
         nuLn_Beta := LN ( nuLenghListPrev / (tbPositions0.COUNT + 2 * tbPositions1.COUNT));

         nuLn_Alpha := nuLn_Delta + nuLn_Beta;

         -- Compute Ln_r = nim (Ln_Alpha, 0)
         IF (nuLn_Alpha < 0) THEN
            nuLn_r := nuLn_Alpha;
         ELSE
            nuLn_r := 0;
         END IF;

         -- Alpha evaluation criteria
         IF (LN (DBMS_RANDOM.VALUE (0, 1)) < nuLn_r) THEN
            -- Apply Strategies for avoid overfitting
            IF (blEdgeReversal OR (NOT blEdgeReversal AND NOT (nuIdx > tbPositions1.COUNT + tbPositions0.COUNT) ) ) THEN
               -- Apply Strategies for avoid overfitting
               IF (inuStrategy = 1 AND -- Pass filtering : Epsilon
                    pkBayesianMapper.gnuEpsilon <= pkFiltering.fnuGetepsilon(nuRow, nuCol) ) THEN
                        blAccept := true;
               ELSIF (inuStrategy = 2 AND -- Pass filtering : GradeIn
                    pkBayesianMapper.gnuInGrade >= pkFiltering.fnuGetInGrade(nuCol) ) THEN
                        blAccept := true;
               ELSIF (inuStrategy = 12 AND -- Pass filtering : Epsilon + GradeIn
                    pkBayesianMapper.gnuEpsilon <= pkFiltering.fnuGetepsilon(nuRow, nuCol) AND
                    pkBayesianMapper.gnuInGrade >= pkFiltering.fnuGetInGrade(nuCol)) THEN
                        blAccept := true;
               ELSIF (inuStrategy = 0) then
                        blAccept := true;
               ELSE-- No pass filtering
                    blAccept := false;
               END IF;
             ELSE -- Except deleting operation
                        blAccept := true;
             END IF;
          ELSE-- No pass Alpha criteria
            blAccept := false;
          END IF;

         IF (blAccept) THEN

           -- Save grade and Save graph's structure into adjacency_matrix_log
           SaveProcessTrace(nuT, nuLn_Delta, tbPositions1.COUNT);

           nuLenghListPrev := tbPositions0old.COUNT + 2 * tbPositions1old.COUNT;

            -- Operator edge deletion + edge addition
            IF (blEdgeReversal) THEN
			  --pkLikelihood.tbLogLikelihood (nuColOld) := nuLogLikelihoodPartialOld;
			  --pkLikelihood.tbLogLikelihood (nuCol) := nuLogLikelihoodPartial;
			  pkConjugate.tbPosterior (nuColOld) := nuLogLikelihoodPartialOld;
			  pkConjugate.tbPosterior (nuCol) := nuLogLikelihoodPartial;
            ELSE
                --pkLikelihood.tbLogLikelihood (nuCol) := nuLogLikelihoodPartial;
                pkConjugate.tbPosterior (nuCol) := nuLogLikelihoodPartial;
            END IF;

         ELSE -- Reject : reverse to below structure
            tbPositions0 := tbPositions0old;
            tbPositions1 := tbPositions1old;
            -- Operator edge deletion + edge addition
            IF (blEdgeReversal) THEN
                  pkBayesianMapper.tbAdjacencyMatrix (nuRowOld) (nuColOld) :=
                       1 - pkBayesianMapper.tbAdjacencyMatrix (nuRowOld) (nuColOld);
                  pkBayesianMapper.tbAdjacencyMatrix (nuRow) (nuCol) :=
                     1 - pkBayesianMapper.tbAdjacencyMatrix (nuRow) (nuCol);
            ELSE
               pkBayesianMapper.tbAdjacencyMatrix (nuRow) (nuCol) :=
                  1 - pkBayesianMapper.tbAdjacencyMatrix (nuRow) (nuCol);
            END IF;

         END IF;

         blEdgeReversal := FALSE;

         IF (pkBayesianMapper.fblCompMatrix ( pkBayesianMapper.tbAdjacencyMatrix,
                tbTruthMatrix)) THEN
            nuBestLogLikelihood := nuLogLikelihoodPrevious;
            DBMS_OUTPUT.put_line ( 'se logro matriz verdadera en intento: '
               || nuT
               || ' Posterior:'
               || nuBestLogLikelihood);
         END IF;

         --20160624 Dgarcia Show the best structure
         IF (    nuBestLogLikelihood < 0
             AND nuLogLikelihoodPrevious < nuBestLogLikelihood) THEN
            nuBestLogLikelihood := nuLogLikelihoodPrevious;
            DBMS_OUTPUT.put_line ( 'se logro mejor aprox. en intento: '
               || nuT
               || ' Posterior:'
               || nuBestLogLikelihood);
            printAdjacencyMatrix;
            DBMS_OUTPUT.put_line ('fin mejor aprox.');
         END IF;


         IF (MOD (nuT, 100) = 0)
         THEN
            COMMIT;
         END IF;

         EXIT WHEN nuT = inuNumSim;                             --100000;--30;
         nuT := nuT + 1;
      END LOOP;

      printAdjacencyMatrix;

   EXCEPTION
      WHEN OTHERS THEN
         DBMS_OUTPUT.put_line ('Err: ' || nuRow|| ',' || nuCol || '|' || nuT
            || '|' || TO_CHAR (nuAlpha, '99999999.99999999')
            || '|' || TO_CHAR (nuPx, '99999999.99999999999')
            || '|' || TO_CHAR (nuPxp, '99999999.99999999999'));
         DBMS_OUTPUT.put_line ('Err: ' || SQLERRM);
         printAdjacencyMatrix;

   END simulationPosterior;

--------------------------------------------------------------------------------
   /**
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
    * 2017-07-28    Diego Garcia    Add function : FindMinorEpsilonEdge
    */
   PROCEDURE simulationLogPosterior (inuNumSim IN INTEGER, inuStrategy in integer,
                                     inuT IN INTEGER DEFAULT NULL)
   IS
      tbPowerMatrix             pkBayesianMapper.tytbRow;
      tbIdentity                pkBayesianMapper.tytbRow
         := pkBayesianMapper.ftbIdentMatrix (pkBayesianMapper.tbR.COUNT);
      tbTranspose               pkBayesianMapper.tytbRow;
      --2017-JUN-16
      --tbTruthMatrix             pkBayesianMapper.tytbRow;

      tbPosibles                pkBayesianMapper.tytbRow;
      tbPositions0              pkBayesianMapper.tytbRow;
      tbPositions1              pkBayesianMapper.tytbRow;
      nuRowOld                  INTEGER;
      nuColOld                  INTEGER;
      nuLogLikelihoodPartialOld   NUMBER;

      nuIdx                     INTEGER;
      nuIdx2                    INTEGER;
      nuRow                     INTEGER;
      nuCol                     INTEGER;
      nuT                       INTEGER := NVL(inuT,1);
      --l                         binary_integer;
      --m                         binary_integer;

      -- Hasting variables
      nuPx                      NUMBER;
      nuPxp                     NUMBER;
      nuAlpha                   NUMBER;
      nuR                       NUMBER;

      nuLogLikelihood           NUMBER;
      nuLogLikelihoodPartial    NUMBER;
      nuLogLikelihoodPrevious   NUMBER;
      nuE              CONSTANT NUMBER := EXP (1);

      nuLenghListPrev           NUMBER;
      nuLn_Beta                 NUMBER;
      nuLn_Delta                NUMBER;
      nuLn_Delta1               NUMBER;
      nuLn_Delta2               NUMBER;
      nuLn_Alpha                NUMBER;
      nuLn_r                    NUMBER;
      tbPositions0old           pkBayesianMapper.tytbRow;
      tbPositions1old           pkBayesianMapper.tytbRow;
      --2017-JUN-16
      --nuBestLogLikelihood       NUMBER := 0;

      blEdgeReversal            BOOLEAN := FALSE;
      grade                     INTEGER;

    -- 2016-09-29 DGarcia  Enable calculate Local LogLikelihood
      nuLogLikelihoodPartial2    NUMBER;
      tbPositions0old2           pkBayesianMapper.tytbRow;
      tbPositions1old2           pkBayesianMapper.tytbRow;
      blAccept                   BOOLEAN := FALSE;
      -- 28-JUN-2017
        -- Se definen las variables para calcular el tiempo que demora el procedimiento.
        dtTiempoInicia      TIMESTAMP(9);
        dtTiempoTermina     TIMESTAMP(9);
        dtTiempoUtilizado   INTERVAL DAY TO SECOND(9);

      /*************************************************************************
       ** EMBEDDED METHODS
       *************************************************************************
      /**
      * Propiedad intelectual de la Universidad del Valle
      * Name:        ftbCalculateGraphsAcyclic
      * Description: Calculate space of possible operations
      *
      * Parametros :  Descripcion
      * -            -
      *
      * Author:      Diego Garcia
      * Date:        08th Aug 2016
      *
      * Modification Log:
      * ---------------------------
      * 2016-08-08   Diego Garcia    Creation.
      */
      FUNCTION ftbCalculateGraphsAcyclic
         RETURN pkBayesianMapper.tytbRow
      IS
      BEGIN
         -- Calculate matrix identity plus A
         tbPosibles := pkBayesianMapper.ftbSumMatrix (tbIdentity,
               				pkBayesianMapper.tbAdjacencyMatrix);
         -- Calculate all walks
         tbPowerMatrix := pkBayesianMapper.tbAdjacencyMatrix; --pkBayesianMapper.ftbLoadMatrix(1);
         tbTranspose := pkBayesianMapper.ftbTransMatrix (tbPowerMatrix);
         tbPosibles := pkBayesianMapper.ftbSumMatrix (tbPosibles, tbTranspose);

         FOR i IN 2 .. pkBayesianMapper.tbR.COUNT - 1
         LOOP
            tbPowerMatrix := pkBayesianMapper.ftbMultMatrix (tbPowerMatrix);
            tbTranspose := pkBayesianMapper.ftbTransMatrix (tbPowerMatrix);
            tbPosibles := pkBayesianMapper.ftbSumMatrix (tbPosibles, tbTranspose);
         END LOOP;

         RETURN tbPosibles;
      END ftbCalculateGraphsAcyclic;
      /**
      * Propiedad intelectual de la Universidad del Valle
      * Name:        printAdjacencyMatrix
      * Description: Print Adjacency Matrix
      *
      * Parametros :  Descripcion
      * -            -
      *
      * Author:      Diego Garcia
      * Date:        11th Aug 2016
      *
      * Modification Log:
      * ---------------------------
      * 2016-08-11   Diego Garcia    Creation.
      */
      PROCEDURE printAdjacencyMatrix
      IS
      BEGIN
         nuIdx := pkBayesianMapper.tbAdjacencyMatrix.FIRST;
         LOOP
            EXIT WHEN nuIdx IS NULL;
            nuIdx2 := pkBayesianMapper.tbAdjacencyMatrix (nuIdx).FIRST;
            LOOP
               EXIT WHEN nuIdx2 IS NULL;
               DBMS_OUTPUT.put_line (nuIdx || ',' || nuIdx2 || ' : '
                  || pkBayesianMapper.tbAdjacencyMatrix (nuIdx) (nuIdx2));
               nuIdx2 := pkBayesianMapper.tbAdjacencyMatrix (nuIdx).NEXT (nuIdx2);
            END LOOP;
            nuIdx := pkBayesianMapper.tbAdjacencyMatrix.NEXT (nuIdx);
         END LOOP;
      END printAdjacencyMatrix;
      --------------------------------------------------------------------------
      PROCEDURE GetAdjacencyMatrixIndexes
      IS
      BEGIN
         IF (nuIdx <= tbPositions0.COUNT) THEN
            nuRow := tbPositions0 (nuIdx) (1);
            nuCol := tbPositions0 (nuIdx) (2);
         ELSIF (    nuIdx > tbPositions0.COUNT
                AND nuIdx <= tbPositions1.COUNT + tbPositions0.COUNT) THEN
            nuRow := tbPositions1 (nuIdx - tbPositions0.COUNT) (1);
            nuCol := tbPositions1 (nuIdx - tbPositions0.COUNT) (2);
         ELSE
            nuRow := tbPositions1 (nuIdx - tbPositions0.COUNT - tbPositions1.COUNT) (1);
            nuCol := tbPositions1 (nuIdx - tbPositions0.COUNT - tbPositions1.COUNT) (2);
         END IF;
      END GetAdjacencyMatrixIndexes;
      --------------------------------------------------------------------------
      PROCEDURE GetSearchSpace IS
      BEGIN
          -- Calculate space of possible operations
          tbPosibles := ftbCalculateGraphsAcyclic;

          -- Get positions to change in the adjacency matrix
          tbPositions0 := pkBayesianMapper.ftbGetPositionsMatrix (tbPosibles, 0);
          tbPositions1 := pkBayesianMapper.ftbGetPositionsMatrix (pkBayesianMapper.tbAdjacencyMatrix, 1);
      END GetSearchSpace;
      --------------------------------------------------------------------------
      PROCEDURE InitializeMatrices IS
      BEGIN
          -- Load last adjacency matrix (power one) without edges
          pkBayesianMapper.tbAdjacencyMatrix := pkBayesianMapper.ftbLoadMatrix (1);
          -- Load truth matrix (original)
          --2017-JUN-16
          --tbTruthMatrix := pkBayesianMapper.ftbLoadMatrix (0);
      END InitializeMatrices;
      --------------------------------------------------------------------------
      -- Calculate the maximum Ingrade for the current graph - 15/11/2016 DGarcia
      FUNCTION fnuMaxIngradeNode RETURN INTEGER
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
      END fnuMaxIngradeNode;
      --------------------------------------------------------------------------
  PROCEDURE FindMinorEpsilonEdge (onuMinor out number,
                                  onuMinRow out binary_integer,
                                  ionuMinCol in out binary_integer)
  IS
    idx binary_integer;
    idx2 binary_integer;
    nuEpsilon number;
  BEGIN
    -- Initialize
    onuMinor := 1;

    -- BEGIN Looking for smallest Epsilon in Graph
    idx := pkBayesianMapper.tbAdjacencyMatrix.FIRST;
    LOOP
      EXIT WHEN idx IS NULL;
      IF (ionuMinCol IS NULL) THEN
          idx2 := pkBayesianMapper.tbAdjacencyMatrix (idx).FIRST;
          LOOP
            EXIT WHEN idx2 IS NULL;
            IF (pkBayesianMapper.tbAdjacencyMatrix(idx)(idx2) = '1') THEN

              -- Calculus Epsilon for each edge in Graph
              --nuEpsilon := pkFiltering.fnuGetepsilon(nuIdx,nuIdx2);
              nuEpsilon := pkFiltering.fnuGetepsilon2(idx,idx2);

              --dbms_output.put_line('Epsilon('||nuIdx||','||nuIdx2||')='||nuEpsilon);
              if (onuMinor > nuEpsilon) then
                 onuMinor := nuEpsilon;
                 onuMinRow := idx;
                 ionuMinCol := idx2;
              end if;
            END IF;
            idx2 := pkBayesianMapper.tbAdjacencyMatrix (idx).NEXT (idx2);
          END LOOP;
      ELSE
        IF (pkBayesianMapper.tbAdjacencyMatrix(nuIdx)(ionuMinCol) = '1') THEN
          nuEpsilon := pkFiltering.fnuGetepsilon2(idx,ionuMinCol);
          if (onuMinor > nuEpsilon) then
             onuMinor := nuEpsilon;
             onuMinRow := idx;
          end if;
        END IF;
      END IF;
      idx := pkBayesianMapper.tbAdjacencyMatrix.NEXT (idx);
    END LOOP;

  END FindMinorEpsilonEdge;
  --------------------------------------------------------------------------
      PROCEDURE SaveProcessTrace(inuIter in integer, inuValue in number, inuGrade in integer) IS
        nuMaxIngrade number;
        nuMinDepend number := null;
        nuMinRow binary_integer := null;
        nuMinCol binary_integer := null;
      BEGIN
          nuMaxIngrade := fnuMaxIngradeNode;
  	      -- 2018-09-21 DGarcia Experimentation with a more general method of genes selection
          --FindMinorEpsilonEdge(nuMinDepend, nuMinRow, nuMinCol);
          -- Print grade
          INSERT INTO trace VALUES (inuGrade, inuIter, inuValue, inuStrategy, nuMaxIngrade, nuMinDepend);
    	  -- Save graph's structure into adjacency_matrix_log
    	  pkBayesianMapper.insMatrix (pkBayesianMapper.tbAdjacencyMatrix, inuIter, false, inuStrategy);
      END SaveProcessTrace;
      --------------------------------------------------------------------------
      PROCEDURE PickOneChangeforStructure(inuLengthSearchSpace in integer) IS
      BEGIN
         -- Determine the next local operation over structure graph
         -- New operator : edge reverse (edge deletion + edge addition)
         nuIdx := CEIL ( DBMS_RANDOM.VALUE (0, inuLengthSearchSpace));
         -- Set nuRow and nuCol indexes necesary for change structure network
         GetAdjacencyMatrixIndexes;

      END PickOneChangeforStructure;
      --------------------------------------------------------------------------
      -- Save all variables in case of roll back (this is, if reject proposal structure)
      PROCEDURE SaveRollBackVariables IS
      BEGIN
        -- Save local (in nuCol) LogLikelihood after of apply deleting operation
        nuLogLikelihoodPartialOld := nuLogLikelihoodPartial;
        -- Save searchSpace before to change in adjacency matrix of new Structure (x')
        tbPositions0old := tbPositions0;
        tbPositions1old := tbPositions1;
        -- Save indexes used for change structure (if rollback must do)
        nuRowOld := nuRow;
        nuColOld := nuCol;
      END SaveRollBackVariables;

      --------------------------------------------------------------------------
   BEGIN
      -- Initialization power matrices with Zeros (0)
      Initialize;

      -- Load last adjacency matrix (power one) without edges
      -- Load truth matrix (original)
      InitializeMatrices;

      /* 28-JUN-2017
      -- Clear pkConjugate.tbHyperparam
      pkConjugate.clearHypParam;

      -- Empty structure is initialized with hyperparamters value equal to 2
      pkConjugate.initHypParam;

      -- Save All tbHyperparam
      pkConjugate.saveAllHypParam;
      */
      -- Set CPT Cache
      -- Calculate Global LogLikelihood
      pkBayesianMapper.gblCPTcacheON := FALSE;
      --nuLogLikelihoodPrevious := pkLikelihood.fnuLogLikelihood (0);
    --dtTiempoInicia := SYSTIMESTAMP;
      nuLogLikelihoodPrevious := pkConjugate.fnuLogPosterior (0);
    --dtTiempoTermina   := SYSTIMESTAMP ;
    --dbms_output.put_line('nuT='||nuT||', pkConjugate.fnuLogPosterior : '||dtTiempoUtilizado);
      pkBayesianMapper.gblCPTcacheON := TRUE;

    --almacena la hora de inicio del proceso
    -->dtTiempoInicia := SYSTIMESTAMP;
      -- Calculate space for looking for an operation that change network structure
      GetSearchSpace;
    -- Se captura el tiempo final y se carga el tiempo de procesamiento para impresion.
    -->dtTiempoTermina   := SYSTIMESTAMP ;
    -->dtTiempoUtilizado := dtTiempoTermina - dtTiempoInicia ;
    -->dbms_output.put_line('nuT='||nuT||', GetSearchSpace : '||dtTiempoUtilizado);
    
      -- Save grade and Save graph's structure into adjacency_matrix_log
      SaveProcessTrace(0,nuLogLikelihoodPrevious, tbPositions1.COUNT);

      -- Support calculus Q(x | x') / Q(x' | x)
      -- New operator : edge reverse (edge deletion + edge addition)
      nuLenghListPrev := tbPositions0.COUNT + 2 * tbPositions1.COUNT;

      LOOP
         -- Determine the next local operation over structure graph
         -- including New operator : edge reverse (edge deletion + edge addition)
         -- And set nuRow and nuCol indexes necesary for change structure network
         PickOneChangeforStructure(tbPositions0.COUNT + 2 * tbPositions1.COUNT);

         -- Apply changes to adjancecy matrix
         pkBayesianMapper.tbAdjacencyMatrix (nuRow) (nuCol) := 1 - pkBayesianMapper.tbAdjacencyMatrix (nuRow) (nuCol);

         -- Calculate local (in nuCol) LogLikelihood (After of change structure network)
 		 --nuLogLikelihoodPartial := pkLikelihood.fnuLogLikelihoodPartial (nuCol);
    --dtTiempoInicia := SYSTIMESTAMP;
 		 nuLogLikelihoodPartial := pkConjugate.fnuLogPosteriorPartial(nuCol);
 		 -- 2018-09-21 DGarcia Experimentation with a more general method of genes selection
 		 --dbms_output.put_line(' pkConjugate.fnuLogPosteriorPartial -> '||'nuT='||nuT||'nuCol='||nuCol);
    --dtTiempoTermina   := SYSTIMESTAMP ;
    --dtTiempoUtilizado := dtTiempoTermina - dtTiempoInicia ;
    --dbms_output.put_line('nuT='||nuT||', pkConjugate.fnuLogPosteriorPartial : '||dtTiempoUtilizado);

		 --nuLn_Delta1 := nuLogLikelihoodPartial - pkLikelihood.tbLogLikelihood (nuCol);
		 nuLn_Delta1 := nuLogLikelihoodPartial - pkConjugate.tbLogPosterior(nuCol);

		 nuLn_Delta2 := 0;
         -- Save all variables in case of roll back (this is, if reject proposal structure)
         SaveRollBackVariables;

         --******************************************************************************************************
         -- Apply double Operator: edge deletion + edge addition
         IF (nuIdx > tbPositions1.COUNT + tbPositions0.COUNT) THEN
            -- Enabled flag of double operation
            blEdgeReversal := true;

            -- Calculate space of possible operations for new Structure (x')
            GetSearchSpace;

            -- Get positions to change in adjacency matrix of new Structure (x')
               -- o Determine the next local operation over structure graph
            PickOneChangeforStructure(tbPositions0.COUNT);

            -- Apply operator edge addition to adjacency matrix (this is, x-{e}+{a})
            pkBayesianMapper.tbAdjacencyMatrix (nuRow) (nuCol) := 1 - pkBayesianMapper.tbAdjacencyMatrix (nuRow) (nuCol);

            -- Calculate local (in nuCol) LogLikelihood (After of change structure network for second time)
			--nuLogLikelihoodPartial := pkLikelihood.fnuLogLikelihoodPartial (nuCol);
			nuLogLikelihoodPartial := pkConjugate.fnuLogPosteriorPartial(nuCol);

            if (nuCol != nuColOld) then
		      --nuLn_Delta2 :=   nuLogLikelihoodPartial - pkLikelihood.tbLogLikelihood (nuCol);
		      nuLn_Delta2 :=   nuLogLikelihoodPartial - pkConjugate.tbLogPosterior(nuCol);
		    else
		      --nuLn_Delta2 :=   nuLogLikelihoodPartial - nuLogLikelihoodPartialOld;
		      nuLn_Delta2 :=   nuLogLikelihoodPartial - nuLogLikelihoodPartialOld;
            end if;
         END IF;
         --******************************************************************************************************
         nuLn_Delta := nuLn_Delta1 + nuLn_Delta2;
 		 -- 2018-09-21 DGarcia Experimentation with a more general method of genes selection
         --dbms_output.put_line('nuLn_Delta1='||nuLn_Delta1||', nuLn_Delta2='||nuLn_Delta2||', nuLn_Delta='||nuLn_Delta);

    --almacena la hora de inicio del proceso
    -->dtTiempoInicia := SYSTIMESTAMP;
         -- Calculate space of possible operations for new Structure (x')
         GetSearchSpace;
    -- Se captura el tiempo final y se carga el tiempo de procesamiento para impresion.
    -->dtTiempoTermina   := SYSTIMESTAMP ;
    -->dtTiempoUtilizado := dtTiempoTermina - dtTiempoInicia ;
    -->dbms_output.put_line('nuT='||nuT||', GetSearchSpace : '||dtTiempoUtilizado);

         -- calculus Alpha = [P(x') / P(x)].[Q(x | x') / Q(x' | x)]
         nuLn_Beta := LN ( nuLenghListPrev / (tbPositions0.COUNT + 2 * tbPositions1.COUNT));

         nuLn_Alpha := nuLn_Delta + nuLn_Beta;

         -- Compute Ln_r = nim (Ln_Alpha, 0)
         IF (nuLn_Alpha < 0) THEN
            nuLn_r := nuLn_Alpha;
         ELSE
            nuLn_r := 0;
         END IF;


         -- Alpha evaluation criteria
         IF (LN (DBMS_RANDOM.VALUE (0, 1)) < nuLn_r) THEN
            -- Apply Strategies for avoid overfitting
            IF (blEdgeReversal OR (NOT blEdgeReversal AND NOT (nuIdx > tbPositions1.COUNT + tbPositions0.COUNT) ) ) THEN
               -- Apply Strategies for avoid overfitting
               IF (   inuStrategy = 0
                      OR 
                      inuStrategy >= 4
                      OR 
                     (inuStrategy = 1 AND -- Pass filtering : Epsilon
                       -- 18-Jul-2017 pkBayesianMapper.gnuEpsilon <= pkFiltering.fnuGetepsilon(nuRow, nuCol) ) THEN
                      pkBayesianMapper.gnuEpsilon <= pkFiltering.fnuGetepsilon2(nuRow, nuCol) )
                      OR 
                     (inuStrategy = 2 AND -- Pass filtering : GradeIn
                      pkBayesianMapper.gnuInGrade >= pkFiltering.fnuGetInGrade(nuCol) )
                      OR                                            
                     (inuStrategy = 12 AND -- Pass filtering : Epsilon + GradeIn
                      -- 18-Jul-2017 pkBayesianMapper.gnuEpsilon <= pkFiltering.fnuGetepsilon(nuRow, nuCol) AND
                      pkBayesianMapper.gnuEpsilon <= pkFiltering.fnuGetepsilon2(nuRow, nuCol) AND
                      pkBayesianMapper.gnuInGrade >= pkFiltering.fnuGetInGrade(nuCol))
                   ) then
                        blAccept := true;
               ELSE-- No pass filtering
                    blAccept := false;
               END IF;
            ELSE -- Except deleting operation
                 blAccept := true;
            END IF;
         ELSE-- No pass Alpha criteria
            blAccept := false;
         END IF;
  		 -- 2018-09-21 DGarcia Experimentation with a more general method of genes selection
         --dbms_output.put_line('nuLn_Alpha='||nuLn_Alpha||', nuLn_Beta='||nuLn_Beta||', nuLn_r='||nuLn_r);

         IF (blAccept) THEN
  		    -- 2018-09-21 DGarcia Experimentation with a more general method of genes selection
            --dbms_output.put_line('blAccept');

           -- Save grade and Save graph's structure into adjacency_matrix_log
           SaveProcessTrace(nuT, nuLn_Delta, tbPositions1.COUNT);

           nuLenghListPrev := tbPositions0old.COUNT + 2 * tbPositions1old.COUNT;

            -- Operator edge deletion + edge addition
            IF (blEdgeReversal) THEN
  		      -- 2018-09-21 DGarcia Experimentation with a more general method of genes selection
              --dbms_output.put_line('blEdgeReversal');
			  --pkLikelihood.tbLogLikelihood (nuColOld) := nuLogLikelihoodPartialOld;
			  --pkLikelihood.tbLogLikelihood (nuCol) := nuLogLikelihoodPartial;
			  pkConjugate.tbLogPosterior (nuColOld) := nuLogLikelihoodPartialOld;
			  pkConjugate.tbLogPosterior (nuCol) := nuLogLikelihoodPartial;
            ELSE
  		        -- 2018-09-21 DGarcia Experimentation with a more general method of genes selection
                --dbms_output.put_line('Not blEdgeReversal');
                --pkLikelihood.tbLogLikelihood (nuCol) := nuLogLikelihoodPartial;
                pkConjugate.tbLogPosterior (nuCol) := nuLogLikelihoodPartial;
            END IF;

         ELSE -- Reject : reverse to below structure

  		    -- 2018-09-21 DGarcia Experimentation with a more general method of genes selection
            --dbms_output.put_line('Reject');

            tbPositions0 := tbPositions0old;
            tbPositions1 := tbPositions1old;
            -- Operator edge deletion + edge addition
            IF (blEdgeReversal) THEN
  		        -- 2018-09-21 DGarcia Experimentation with a more general method of genes selection
                --dbms_output.put_line('blEdgeReversal');
                  pkBayesianMapper.tbAdjacencyMatrix (nuRowOld) (nuColOld) :=
                       1 - pkBayesianMapper.tbAdjacencyMatrix (nuRowOld) (nuColOld);
                  pkBayesianMapper.tbAdjacencyMatrix (nuRow) (nuCol) :=
                     1 - pkBayesianMapper.tbAdjacencyMatrix (nuRow) (nuCol);
            ELSE
  		       -- 2018-09-21 DGarcia Experimentation with a more general method of genes selection
               --dbms_output.put_line('Not blEdgeReversal');
               pkBayesianMapper.tbAdjacencyMatrix (nuRow) (nuCol) :=
                  1 - pkBayesianMapper.tbAdjacencyMatrix (nuRow) (nuCol);
            END IF;

         END IF;

         blEdgeReversal := FALSE;
         --2017-JUN-16
         /*
         IF (pkBayesianMapper.fblCompMatrix ( pkBayesianMapper.tbAdjacencyMatrix,
                tbTruthMatrix)) THEN
            nuBestLogLikelihood := nuLogLikelihoodPrevious;
            DBMS_OUTPUT.put_line ( 'se logro matriz verdadera en intento: '
               || nuT
               || ' Posterior:'
               || nuBestLogLikelihood);
         END IF;
         */
         --2017-JUN-16
         /*
         --20160624 Dgarcia Show the best structure
         IF (    nuBestLogLikelihood < 0
             AND nuLogLikelihoodPrevious < nuBestLogLikelihood) THEN
            nuBestLogLikelihood := nuLogLikelihoodPrevious;
            DBMS_OUTPUT.put_line ( 'se logro mejor aprox. en intento: '
               || nuT
               || ' Posterior:'
               || nuBestLogLikelihood);
            printAdjacencyMatrix;
            DBMS_OUTPUT.put_line ('fin mejor aprox.');
         END IF;
         */

         IF (MOD (nuT, 10) = 0) -- 100
         THEN
            --DBMS_OUTPUT.put_line ('nuT='||nuT);
            COMMIT;
         END IF;

         EXIT WHEN nuT = inuNumSim;                             --100000;--30;
  		 -- 2018-09-21 DGarcia Experimentation with a more general method of genes selection
         dbms_output.put_line('End iteration '||nuT);
         nuT := nuT + 1;
      END LOOP;

      -- 05-JUL-2017
      --> printAdjacencyMatrix;

   EXCEPTION
      WHEN OTHERS THEN
         DBMS_OUTPUT.put_line ('Err: ' || nuRow|| ',' || nuCol || '|' || nuT
            || '|' || TO_CHAR (nuAlpha, '99999999.99999999')
            || '|' || TO_CHAR (nuPx, '99999999.99999999999')
            || '|' || TO_CHAR (nuPxp, '99999999.99999999999'));
         DBMS_OUTPUT.put_line ('Err: ' || SQLERRM);
         --printAdjacencyMatrix;

   END simulationLogPosterior;

--------------------------------------------------------------------------------
   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        iterationSimulaLogPosterior
    * Description: Bayesian structure learning with score Log Posterior function
    *
    * Parametros :  Descripcion
    * inuMaxAttempts   Number maximum of attempts without find new structures
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
                                            inuMinPercAttemp in number default 0.1)
  IS
    nuOptimal_level integer := 1;
    inuAttempts integer := 0;
    BNBRsize integer := NULL;
    percAttemp number;
  BEGIN

    LOOP
      -- Execute simulation
      --pkHasting.simulationLogPosterior(inuNumSim, inuStrategy, nuOptimal_level);
      -- 2019-03-02 Fix 
      pkHasting.simulationLogPosterior(nuOptimal_level+inuNumSim-1, inuStrategy, nuOptimal_level);
      -- Load adjacency matrices into binary representation vector
      --pkBNBinaryRepresentation.LoadMassivelyBNBR(nuOptimal_level,null,inuStrategy);
      -- 2019-03-02 Fix retart 
      pkBNBinaryRepresentation.LoadMassivelyBNBR(nuOptimal_level,nuOptimal_level+inuNumSim-1,inuStrategy);
      -- 2019-03-03 Fix percent
      percAttemp := (pkBNBinaryRepresentation.tbBNBR.count - NVL(BNBRsize,0)) / NVL(BNBRsize,pkBNBinaryRepresentation.tbBNBR.count);
      debug.g_debugging := true;
      debug.OUTPUT('Desde='||nuOptimal_level||' Hasta='||(nuOptimal_level+inuNumSim-1)||' Porcentaje='||percAttemp,0,inuStrategy);

      -- Update argument from where will be taken the following structure
      nuOptimal_level := nuOptimal_level + inuNumSim;
      -- Counting of attempt if  structures new were not found
      --IF pkBNBinaryRepresentation.tbBNBR.count = BNBRsize THEN
      -- 2017-07-24
      -- 2019-03-02
      IF ( percAttemp -- Porcentage found
          <= inuMinPercAttemp)
      THEN
        inuAttempts := inuAttempts + 1;
        BNBRsize := pkBNBinaryRepresentation.tbBNBR.count;
      ELSE
        BNBRsize := pkBNBinaryRepresentation.tbBNBR.count;
      END IF;
      -- Validates the number maximum of attempts without find new structures
      EXIT WHEN inuAttempts = inuMaxAttempts;
    END LOOP;
   
  END iterationSimulaLogPosterior;

END pkHasting;
/
