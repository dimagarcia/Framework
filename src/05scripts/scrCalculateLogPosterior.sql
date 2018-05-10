-- Script:  scrCalculateLogPosterior
-- Author:  Diego Garcia
-- Date:    13-Jul-2017
-- Description: Calculate  Logarithm of the Posterior function given a Graph
declare
        dtTiempoInicia      TIMESTAMP(9);
        dtTiempoTermina     TIMESTAMP(9);
        dtTiempoUtilizado   INTERVAL DAY TO SECOND(9);
        nuLogPost number;
begin
    -- Inizializate cardianality of values sets for each variable
    pkBayesianMapper.tbR(1) := 3; pkBayesianMapper.tbR(2) := 3;
    pkBayesianMapper.tbR(3) := 3; pkBayesianMapper.tbR(4) := 3;
    pkBayesianMapper.tbR(5) := 3; pkBayesianMapper.tbR(6) := 3;
    pkBayesianMapper.tbR(7) := 3; pkBayesianMapper.tbR(8) := 3;
    pkBayesianMapper.tbR(9) := 3; pkBayesianMapper.tbR(10) := 3;
    pkBayesianMapper.tbR(11) := 3; pkBayesianMapper.tbR(12) := 3;
    pkBayesianMapper.tbR(13) := 3; pkBayesianMapper.tbR(14) := 3;
    pkBayesianMapper.tbR(15) := 3; pkBayesianMapper.tbR(16) := 3;

    -- Initialize Adjacency Matrix
    pkBayesianMapper.tbAdjacencyMatrix := pkBayesianMapper.ftbLoadMatrix (1);

    -- Load Graph
    -- Module 33
    pkBayesianMapper.tbAdjacencyMatrix(2)(1) := 1;
    pkBayesianMapper.tbAdjacencyMatrix(2)(3) := 1;
    pkBayesianMapper.tbAdjacencyMatrix(2)(4) := 1;
    -- Global rpoD
    pkBayesianMapper.tbAdjacencyMatrix(5)(1) := 1;
    pkBayesianMapper.tbAdjacencyMatrix(5)(2) := 1;
    pkBayesianMapper.tbAdjacencyMatrix(5)(3) := 1;
    pkBayesianMapper.tbAdjacencyMatrix(5)(4) := 1;
    pkBayesianMapper.tbAdjacencyMatrix(5)(7) := 1;
    pkBayesianMapper.tbAdjacencyMatrix(5)(8) := 1;
    --pkBayesianMapper.tbAdjacencyMatrix(5)(9) := 1;
    --pkBayesianMapper.tbAdjacencyMatrix(5)(10) := 1;
    --pkBayesianMapper.tbAdjacencyMatrix(5)(11) := 1;
    pkBayesianMapper.tbAdjacencyMatrix(5)(16) := 1;
    -- Regulator hns
    pkBayesianMapper.tbAdjacencyMatrix(7)(1) := 1;
    pkBayesianMapper.tbAdjacencyMatrix(7)(3) := 1;
    pkBayesianMapper.tbAdjacencyMatrix(7)(4) := 1;
    -- Regulator crp
    pkBayesianMapper.tbAdjacencyMatrix(8)(1) := 1;
    pkBayesianMapper.tbAdjacencyMatrix(8)(3) := 1;
    pkBayesianMapper.tbAdjacencyMatrix(8)(4) := 1;
    pkBayesianMapper.tbAdjacencyMatrix(8)(14) := 1;
    pkBayesianMapper.tbAdjacencyMatrix(8)(15) := 1;
    -- Module 40
    pkBayesianMapper.tbAdjacencyMatrix(11)(9) := 1;
    pkBayesianMapper.tbAdjacencyMatrix(11)(10) := 1;
    pkBayesianMapper.tbAdjacencyMatrix(11)(12) := 1;
    -- Module 52
    pkBayesianMapper.tbAdjacencyMatrix(14)(13) := 1;
    pkBayesianMapper.tbAdjacencyMatrix(14)(15) := 1;

    pkBayesianMapper.gblCPTcacheON := FALSE;
    dtTiempoInicia := SYSTIMESTAMP;
    nuLogPost := pkConjugate.fnuLogPosterior (0);
    dtTiempoTermina   := SYSTIMESTAMP ;
    dtTiempoUtilizado := dtTiempoTermina - dtTiempoInicia ;
    dbms_output.put_line('pkConjugate.fnuLogPosterior:'||nuLogPost||' Duration:'||dtTiempoUtilizado);
    -- pkConjugate.fnuLogPosterior:733,669018806137443903670987822888253917 Duration:+00 00:00:00.766000000

end;