CREATE OR REPLACE PACKAGE BODY pkBNBinaryRepresentation
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
   -- Constantes
   --------------------------------------------
   csbVersion   CONSTANT VARCHAR2 (250) := '2016-11-11';


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
   PROCEDURE ClearBNBR
   IS
   BEGIN
    tbBNBR.delete;
   END ClearBNBR;

   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        LoadBNBR
    * Description:  Load Bayesian Nerwork Binary Representation From A Adjacency Matrix Given
    * Author:      Diego Garcia
    * Date:        11th November 2016
    * Parametros :  Descripcion
    * itbAdjMatrix  Adjacency Matrix to loading
    *
    * Modification Log:
    * ---------------------------
    * 2016-11-11   Diego Garcia    Creation.
    */
   PROCEDURE LoadBNBR (itbAdjMatrix IN pkBayesianMapper.tytbRow)
   IS
    nuParen binary_integer;
    nuChild binary_integer;
   BEGIN
     gsbIdxBNBR := '';
     nuParen := itbAdjMatrix.FIRST;
     LOOP
        EXIT WHEN nuParen IS NULL;

        nuChild := itbAdjMatrix (nuParen).FIRST;
        LOOP
           EXIT WHEN nuChild IS NULL;

           gsbIdxBNBR := gsbIdxBNBR || to_char(itbAdjMatrix(nuParen)(nuChild));
           nuChild := itbAdjMatrix (nuParen).NEXT(nuChild);
        END LOOP;

        nuParen := itbAdjMatrix.NEXT (nuParen);
     END LOOP;

     IF ( NOT tbBNBR.exists(gsbIdxBNBR) ) THEN
        tbBNBR(gsbIdxBNBR) := 1;
     ELSE
        tbBNBR(gsbIdxBNBR) := tbBNBR(gsbIdxBNBR) + 1;
     END IF;

   END LoadBNBR;

   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        LoadMassivelyBNBR
    * Description:  Load Bayesian Nerwork Binary Representation From Adjacency_Matrix_Log Table
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
    * 2019-02-25   Diego Garcia     Se corrige llamado a carga masiva
    *                               pkBNBinaryRepresentation.LoadMassivelyBNBR
    *                               Para que tenga en cuenta el parametro inuTo

    */
   PROCEDURE LoadMassivelyBNBR (inuFrom IN integer, inuTo IN integer, inuStrategy in number)
   IS
     tbAdjMatrix pkBayesianMapper.tytbRow;

     CURSOR cuOptimalLevel(inuOptLvl in integer, nuStrategy in integer) IS
        --select id from trace where id >= inuOptLvl order by id;
        SELECT *
        FROM (SELECT admaiter as id
                FROM adjacency_matrix_log
                WHERE strategy = nuStrategy
                AND admaiter >= inuOptLvl
                GROUP BY admaiter)
        ORDER BY id;
     CURSOR cuOptimalLevel2(inuOptLvl in integer,
                            inuOptLvl2 in integer,
                            nuStrategy in integer) IS
        --select id from trace where id >= inuOptLvl order by id;
        SELECT *
        FROM (SELECT admaiter as id
                FROM adjacency_matrix_log
                WHERE strategy = nuStrategy
                AND admaiter >= inuOptLvl
                AND admaiter <= inuOptLvl2
                GROUP BY admaiter)
        ORDER BY id;

   BEGIN
   
    IF inuTo IS NULL Then
   
       ClearBNBR;

       -- Massive
       FOR rc IN cuOptimalLevel(inuFrom, inuStrategy) LOOP
         tbAdjMatrix := pkBayesianMapper.ftbLoadMatrix (rc.id, false, inuStrategy);
         LoadBNBR(tbAdjMatrix);
       END LOOP;
    ELSE
       FOR rc IN cuOptimalLevel2(inuFrom, inuTo, inuStrategy) LOOP
         tbAdjMatrix := pkBayesianMapper.ftbLoadMatrix (rc.id, false, inuStrategy);
         LoadBNBR(tbAdjMatrix);
       END LOOP;
    END IF;

   END LoadMassivelyBNBR;
   
   /**
    * Propiedad intelectual de la Universidad del Valle
    * Name:        LoadMassivelyBNBR
    * Description:  Load Bayesian Nerwork Binary Representation From Adjacency_Matrix_Log Table
    * Author:      Diego Garcia
    * Date:        11th November 2016
    * Parametros :  Descripcion
    * inuFrom       Index from where will begin loading
    * inuTo         Index until where will go loading
    *
    * Modification Log:
    * ---------------------------
    * 2019-03-06   Diego Garcia     Xreaxion
    */
    PROCEDURE IterLoadMassivelyBNBR (inuNumSim IN INTEGER, inuFrom IN integer, inuTo IN integer, inuStrategy in number)
    IS
        TYPE tyIntervals IS TABLE OF INTEGER INDEX BY BINARY_INTEGER;
        tbtyIntervals tyIntervals;
        tbtyIntervals2 tyIntervals;
        ------------------------------------------------------------------------
        PROCEDURE InitilizeIntervalS IS
            idx BINARY_INTEGER := inuFrom;
        BEGIN
            LOOP
                EXIT WHEN (idx + inuNumSim - 1) > inuTo;
                tbtyIntervals(idx) := idx + inuNumSim - 1;
                idx := tbtyIntervals(idx)+1;
            END LOOP;
            tbtyIntervals(idx) := inuTo;
            
        END InitilizeIntervalS;
        ------------------------------------------------------------------------
        PROCEDURE getMaxSimulationValues IS
            idx BINARY_INTEGER := tbtyIntervals.first;
            idx2 BINARY_INTEGER;
            nuMax integer;
            nuCumulative number;
             CURSOR cuOptimalLevel(inuOptLvl in integer,
                                    inuOptLvl2 in integer,
                                    nuStrategy in integer) IS
                SELECT trace.id , trace.value
                FROM trace
                WHERE trace.strategy = nuStrategy
                AND trace.id >= inuOptLvl
                AND trace.id <= inuOptLvl2
                ORDER BY trace.id;

        BEGIN
            LOOP
                --LoadMassivelyBNBR (idx, tbtyIntervals(idx), inuStrategy);
                --dbms_output.put_line('LoadMassivelyBNBR ('||idx||', '||tbtyIntervals(idx)||', '||inuStrategy||')');
                FOR rc IN cuOptimalLevel(idx,tbtyIntervals(idx),inuStrategy) LOOP
                    IF (rc.id = idx) THEN
                        nuCumulative := rc.value;
                        nuMax := nuCumulative;
                    ELSE
                        nuCumulative := nuCumulative + rc.value;
                        IF (nuCumulative > nuMax) THEN
                            nuMax := nuCumulative;
                            idx2 := rc.id;
                        END IF;
                    END IF;
                END LOOP;
                tbtyIntervals2(idx2) := tbtyIntervals(idx);
                idx := tbtyIntervals.next(idx);
                EXIT WHEN idx IS NULL;
            END LOOP;
        END getMaxSimulationValues;
        PROCEDURE load IS
            idx2 BINARY_INTEGER := tbtyIntervals2.first;
        BEGIN
            LOOP
                LoadMassivelyBNBR (idx2, tbtyIntervals2(idx2), inuStrategy);
                dbms_output.put_line('LoadMassivelyBNBR ('||idx2||', '||tbtyIntervals2(idx2)||', '||inuStrategy||')');
                idx2 := tbtyIntervals2.next(idx2);
                EXIT WHEN idx2 IS NULL;
            END LOOP;
        END load;
    BEGIN
        -- 0. INtialize intervals of each simulation
        InitilizeIntervalS;
        -- 1. get Maximum Values of each simulation
        getMaxSimulationValues;
        -- 2. For each interval loadMassivelyBNBR
        load;
        
    END IterLoadMassivelyBNBR;

   
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
   PROCEDURE PrintBNBR
   IS
   BEGIN
      gsbIdxBNBR := tbBNBR.first;
      LOOP
        EXIT WHEN gsbIdxBNBR IS NULL;

        dbms_output.put_line(gsbIdxBNBR||chr(9)||tbBNBR(gsbIdxBNBR));
        gsbIdxBNBR := tbBNBR.next(gsbIdxBNBR);
      END LOOP;
   END PrintBNBR;

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
      RETURN pkBayesianMapper.tytbRow
   IS
      tbAdjMatrix   pkBayesianMapper.tytbRow;
      nuNodes integer := pkBayesianMapper.tbR.count;
   BEGIN
     tbAdjMatrix.delete;
     FOR i IN 1..nuNodes LOOP
       FOR j IN 1..nuNodes LOOP
         tbAdjMatrix(i)(j) := substr(isbIdxBNBR,((i-1)*pkBayesianMapper.tbR.count + j),1);
         --dbms_output.put_line(i||','||j||':'||((i-1)*pkBayesianMapper.tbR.count + j)||' -> '||tbAdjMatrix(i)(j));
       END LOOP;
     END LOOP;
     RETURN tbAdjMatrix;
   END ftbLoadAdjMatrix;
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
   PROCEDURE PrintAdjMatrix (itbAdjMatrix in pkBayesianMapper.tytbRow)
   IS
     nuIdx binary_integer;
     nuIdx2 binary_integer;
   BEGIN
     nuIdx := itbAdjMatrix.FIRST;
     LOOP
        EXIT WHEN nuIdx IS NULL;
        nuIdx2 := itbAdjMatrix (nuIdx).FIRST;
        LOOP
           EXIT WHEN nuIdx2 IS NULL;
           DBMS_OUTPUT.put_line (nuIdx || ',' || nuIdx2 || ' : '
              || itbAdjMatrix (nuIdx) (nuIdx2));
           nuIdx2 := itbAdjMatrix (nuIdx).NEXT (nuIdx2);
        END LOOP;
        nuIdx := itbAdjMatrix.NEXT (nuIdx);
     END LOOP;
   END PrintAdjMatrix;

END pkBNBinaryRepresentation;
/
