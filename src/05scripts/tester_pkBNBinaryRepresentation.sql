DECLARE
    tbAdjMatrix   pkBayesianMapper.tytbRow;
BEGIN
    -- Inizializate cardianality of values sets for each variable
    pkBayesianMapper.tbR (1) := 2;
    pkBayesianMapper.tbR (2) := 2;
    pkBayesianMapper.tbR (3) := 2;
    pkBayesianMapper.tbR (4) := 2;
    pkBayesianMapper.tbR (5) := 2;

    pkBNBinaryRepresentation.LoadMassivelyBNBR(32,null,0);
    pkBNBinaryRepresentation.PrintBNBR;
   
    -- 2016-NOV-17
    --tbAdjMatrix := pkBNBinaryRepresentation.ftbLoadAdjMatrix('0000010000110001110111100');
    --pkBNBinaryRepresentation.PrintAdjMatrix(tbAdjMatrix);

END;