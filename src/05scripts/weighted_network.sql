DECLARE
    tbWeightedAdjacencyMatrix pkBayesianMapper.tytbRow; --pkBayesianMapper.tytbRow2;
    nuN integer; -- Quantity of network
    nuOptimal_level INTEGER := 176;
    nuStrategy INTEGER := 0;
    --sbIdx varchar2(25);
    sbIdx varchar2(36);
    idx binary_integer;
    idx2 binary_integer;
    CURSOR cu(nuIter in adjacency_matrix_log.admaiter%type,
              nuStartegy in adjacency_matrix_log.strategy%type) IS
        SELECT admarow, admacol
        FROM adjacency_matrix_log
        WHERE admaiter >= nuIter AND admaval=1
        AND     strategy = nuStartegy
        ORDER BY admaiter, admarow, admacol;
    ----------------------------------------------------------------------------
      PROCEDURE printAdjacencyMatrix(inuNetworks in integer)
      IS
          nuIdx                     INTEGER;
          nuIdx2                    INTEGER;
      BEGIN
         nuIdx := tbWeightedAdjacencyMatrix.FIRST;
         LOOP
            EXIT WHEN nuIdx IS NULL;
            nuIdx2 := tbWeightedAdjacencyMatrix (nuIdx).FIRST;
            LOOP
               EXIT WHEN nuIdx2 IS NULL;
               DBMS_OUTPUT.put_line (nuIdx || ',' || nuIdx2 || ' : '
                  || tbWeightedAdjacencyMatrix (nuIdx) (nuIdx2) / inuNetworks);
                  --|| tbWeightedAdjacencyMatrix (nuIdx) (nuIdx2) );
               nuIdx2 := tbWeightedAdjacencyMatrix (nuIdx).NEXT (nuIdx2);
            END LOOP;
            nuIdx := tbWeightedAdjacencyMatrix.NEXT (nuIdx);
         END LOOP;
      END printAdjacencyMatrix;
    ----------------------------------------------------------------------------
BEGIN
    -- Define optimal level
    -- 25-JUN-2017
    nuOptimal_level := 1; --146; --84; --28; --176;
    nuStrategy := 4;
    -- Counting nertworks
    SELECT count(1) as networks INTO nuN FROM ( SELECT 1
    FROM adjacency_matrix_log
    WHERE admaiter >= nuOptimal_level -- 176
    AND   strategy = nuStrategy
    GROUP BY admaiter); -- 952 45154
    dbms_output.put_line('Number of networks:'||nuN); -- 4802 -- 214
    
	-- Inizializate cardianality of values sets for each variable
	pkBayesianMapper.tbR(1) := 3; pkBayesianMapper.tbR(2) := 3;
	pkBayesianMapper.tbR(3) := 3; pkBayesianMapper.tbR(4) := 3;
	pkBayesianMapper.tbR(5) := 3; pkBayesianMapper.tbR(6) := 3;
    -- Initialize Adjacency Matrix
    tbWeightedAdjacencyMatrix := pkBayesianMapper.ftbLoadMatrix (1);
    --printAdjacencyMatrix;
/*
    FOR rc IN cu(nuOptimal_level, nuStartegy) LOOP
        tbWeightedAdjacencyMatrix(rc.admarow)(rc.admacol) :=
            tbWeightedAdjacencyMatrix(rc.admarow)(rc.admacol) + 1;
    END LOOP;
    --printAdjacencyMatrix(nuN);
*/
   -- 129.875 sec.
   --pkBNBinaryRepresentation.LoadMassivelyBNBR(nuOptimal_level,null,0);
   -- 25-JUN-2017
   pkBNBinaryRepresentation.tbBNBR.delete;
   --FOR i IN 1..136 LOOP
   -- 27-JUN-2017
   FOR i IN 1..489 LOOP
    tbWeightedAdjacencyMatrix := pkBayesianMapper.ftbLoadMatrix (i, false, nuStrategy);
    pkBNBinaryRepresentation.LoadBNBR(tbWeightedAdjacencyMatrix);
   END LOOP;
   pkBNBinaryRepresentation.PrintBNBR;
 /*
    sbIdx := pkBNBinaryRepresentation.tbBNBR.first;
    LOOP
        EXIT WHEN sbIdx IS NULL;
        pkBayesianMapper.tbAdjacencyMatrix := pkBNBinaryRepresentation.ftbLoadAdjMatrix(sbIdx);
        -->
         idx := pkBayesianMapper.tbAdjacencyMatrix.FIRST;
         LOOP
            EXIT WHEN idx IS NULL;
            idx2 := pkBayesianMapper.tbAdjacencyMatrix (idx).FIRST;
            LOOP
               EXIT WHEN idx2 IS NULL;
               IF (pkBayesianMapper.tbAdjacencyMatrix (idx)(idx2) = 1) THEN
                tbWeightedAdjacencyMatrix(idx)(idx2) :=
                    tbWeightedAdjacencyMatrix(idx)(idx2) + 1;
               END IF;
               idx2 := pkBayesianMapper.tbAdjacencyMatrix (idx).NEXT (idx2);
            END LOOP;
            idx := pkBayesianMapper.tbAdjacencyMatrix.NEXT (idx);
         END LOOP;
        --<
        sbIdx := pkBNBinaryRepresentation.tbBNBR.next(sbIdx);
    END LOOP;
    --printAdjacencyMatrix(1);
    printAdjacencyMatrix(136);--20);--17);--14);
*/
END;
/* 18-JUN-2017
1,1 : 0
1,2 : .1911764705882352941176470588235294117647
1,3 : .5661764705882352941176470588235294117647
1,4 : .5073529411764705882352941176470588235294
1,5 : .2058823529411764705882352941176470588235
1,6 : .2058823529411764705882352941176470588235
2,1 : .8088235294117647058823529411764705882353
2,2 : 0
2,3 : .8970588235294117647058823529411764705882
2,4 : .8161764705882352941176470588235294117647
2,5 : .5220588235294117647058823529411764705882
2,6 : .5147058823529411764705882352941176470588
3,1 : .4338235294117647058823529411764705882353
3,2 : .1029411764705882352941176470588235294118
3,3 : 0
3,4 : .4338235294117647058823529411764705882353
3,5 : .1323529411764705882352941176470588235294
3,6 : .125
4,1 : .4926470588235294117647058823529411764706
4,2 : .1838235294117647058823529411764705882353
4,3 : .5661764705882352941176470588235294117647
4,4 : 0
4,5 : .1985294117647058823529411764705882352941
4,6 : .1838235294117647058823529411764705882353
5,1 : .7941176470588235294117647058823529411765
5,2 : .4779411764705882352941176470588235294118
5,3 : .8676470588235294117647058823529411764706
5,4 : .8014705882352941176470588235294117647059
5,5 : 0
5,6 : .5
6,1 : .7941176470588235294117647058823529411765
6,2 : .4852941176470588235294117647058823529412
6,3 : .875
6,4 : .8161764705882352941176470588235294117647
6,5 : .5
6,6 : 0
-- 17-JUN-2017
1,1 : 0
1,2 : .75
1,3 : 1
1,4 : 1
1,5 : .75
1,6 : .75
2,1 : .25
2,2 : 0
2,3 : 1
2,4 : .9
2,5 : .55
2,6 : .45
3,1 : 0
3,2 : 0
3,3 : 0
3,4 : .15
3,5 : 0
3,6 : 0
4,1 : 0
4,2 : .1
4,3 : .85
4,4 : 0
4,5 : 0
4,6 : 0
5,1 : .25
5,2 : .45
5,3 : 1
5,4 : 1
5,5 : 0
5,6 : .45
6,1 : .25
6,2 : .55
6,3 : 1
6,4 : 1
6,5 : .55
6,6 : 0
--------------------------------------------------------------------------------
1,1 : 0
1,2 : .2405462184873949579831932773109243697479
1,3 : .6932773109243697478991596638655462184874
1,4 : .4789915966386554621848739495798319327731
2,1 : .7594537815126050420168067226890756302521
2,2 : 0
2,3 : .905462184873949579831932773109243697479
2,4 : .841386554621848739495798319327731092437
3,1 : .3067226890756302521008403361344537815126
3,2 : .094537815126050420168067226890756302521
3,3 : 0
3,4 : .2079831932773109243697478991596638655462
4,1 : .5210084033613445378151260504201680672269
4,2 : .158613445378151260504201680672268907563
4,3 : .7920168067226890756302521008403361344538
4,4 : 0

0000100111011000	74
0000101010001110	43
0000101110001010	56
0000101110011000	89
0001100111010000	16
0001101110010000	14
0010101000001110	95
0010101100001010	133
0011101100000010	199
0011101100010000	4
0110001000001110	6
0111001000000110	7
0111001100000010	215
0111001100010000	1
                    952

1,1 : 0
1,2 : .2857142857142857142857142857142857142857
1,3 : .5714285714285714285714285714285714285714
1,4 : .5
2,1 : .7142857142857142857142857142857142857143
2,2 : 0
2,3 : .8571428571428571428571428571428571428571
2,4 : .7142857142857142857142857142857142857143
3,1 : .4285714285714285714285714285714285714286
3,2 : .1428571428571428571428571428571428571429
3,3 : 0
3,4 : .4285714285714285714285714285714285714286
4,1 : .5
4,2 : .2857142857142857142857142857142857142857
4,3 : .5714285714285714285714285714285714285714
4,4 : 0

Number of networks:45154
1,1 : 0
1,2 : .2352941176470588235294117647058823529412
1,3 : .5294117647058823529411764705882352941176
1,4 : .4705882352941176470588235294117647058824
2,1 : .7058823529411764705882352941176470588235
2,2 : 0
2,3 : .7647058823529411764705882352941176470588
2,4 : .6470588235294117647058823529411764705882
3,1 : .4705882352941176470588235294117647058824
3,2 : .2352941176470588235294117647058823529412
3,3 : 0
3,4 : .4117647058823529411764705882352941176471
4,1 : .5294117647058823529411764705882352941176
4,2 : .3529411764705882352941176470588235294118
4,3 : .5882352941176470588235294117647058823529
4,4 : 0
*/