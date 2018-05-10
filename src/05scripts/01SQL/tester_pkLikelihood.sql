declare
	  tbMatrix       pkBayesianMapper.tytbRow;
begin

	dbms_output.put_line('BEGIN');

	-- Inizializate cardianality of values sets for each variable
	pkBayesianMapper.tbR(1) := 2; pkBayesianMapper.tbR(2) := 2;
	pkBayesianMapper.tbR(3) := 2; pkBayesianMapper.tbR(4) := 2;
	pkBayesianMapper.tbR(5) := 2;

    --pkBayesianMapper.tbAdjacencyMatrix := pkBayesianMapper.ftbLoadMatrix(0);
    /*
    dbms_output.put_line(pkBayesianMapper.fnuGetN2(3,0,1));
    dbms_output.put_line(pkBayesianMapper.fnuGetN2(3,0,2));
    dbms_output.put_line(pkBayesianMapper.fnuGetN2(3,0,3));
    dbms_output.put_line(pkBayesianMapper.fnuGetN2(3,0,4));
    dbms_output.put_line(pkBayesianMapper.fnuGetN2(3,1,1));
    dbms_output.put_line(pkBayesianMapper.fnuGetN2(3,1,2));
    dbms_output.put_line(pkBayesianMapper.fnuGetN2(3,1,3));
    dbms_output.put_line(pkBayesianMapper.fnuGetN2(3,1,4));
    */
    --dbms_output.put_line(pkLikelihood.fnuLogLikelihood(0));

    pkBayesianMapper.tbAdjacencyMatrix := pkBayesianMapper.ftbLoadMatrix(1);

    dbms_output.put_line(pkLikelihood.fnuLogLikelihood(0));


	dbms_output.put_line('END');

end;
/
/*
BEGIN
127
127
127
127
9873
9873
9873
9873
END
BEGIN
82
12
14
19
2633
294
6255
691
END
BEGIN
-21075.8268853865364340473748896599025541
END
BEGIN
-21340.349875460767960479099663008704527
END
*/