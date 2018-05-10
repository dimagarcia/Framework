/*
  * Propiedad intelectual de la Universidad del Valle
  * Name:        script_calculate_Correlations
  * Description: Calculate Correlation Coefficients Script
  *
  * Parametros :  Descripcion
  * -            -
  *
  * Author:      Diego Garcia
  * Date:        21th Sep 2016
  *
  * Modification Log:
  * ---------------------------
  * 2016-08-21   Diego Garcia    Creation.
*/

DECLARE
   nuLogLikelihood   NUMBER;
   nuQi              NUMBER;
   nuSumNijk         NUMBER := 0;
BEGIN
   DBMS_OUTPUT.put_line ('INICIO');
   
   -- Inizializate cardianality of values sets for each variable
   pkBayesianMapper.tbR (1) := 2;
   pkBayesianMapper.tbR (2) := 2;
   pkBayesianMapper.tbR (3) := 2;
   pkBayesianMapper.tbR (4) := 2;
   pkBayesianMapper.tbR (5) := 2;

   --pkCorrelation.DefineStates(2); -- exclude variable two (Smoker) - row is state (s) and col is var (k)
   --pkCorrelation.DefineStates;
   
   --pkCorrelation.GetProfile(2); -- exclude variable two (Smoker) - row is profile (s) and col is var excluded (k)
   ---->pkCorrelation.GetProfiles(2,5);
   
   --pkCorrelation.GetAvarages;
   ---->pkCorrelation.GetAvarages(2,5);

   ---->pkCorrelation.GetProfileMinusAvarage(2,5);
   
   --pkCorrelation.GetCovariances;
   --pkCorrelation.GetCovariance(2,5);

   --pkCorrelation.GetDeviation(2,5);
   /*
    dbms_output.put_line('fnuGetPerarsonsCoefficient('||1||','||2||'):'||
                            pkCorrelation.fnuGetPerarsonsCoefficient(1,2)
                        );
    dbms_output.put_line('fnuGetPerarsonsCoefficient('||2||','||5||'):'||
                            pkCorrelation.fnuGetPerarsonsCoefficient(2,5)
                        );
    */
    pkCorrelation.GetCorrelationMatrix;

   DBMS_OUTPUT.put_line ('FIN');
END;
/
/*
INICIO
i:1 j:2 tbCorrelations(i)(j):.3328373906887415008150720323226290976471
i:1 j:3 tbCorrelations(i)(j):-.2802598986687083143307934978579920923237
i:1 j:4 tbCorrelations(i)(j):.1183795230526802394790843974549866547766
i:1 j:5 tbCorrelations(i)(j):.3470174933385343359829460655990349829517
i:2 j:3 tbCorrelations(i)(j):.9098824428819139652664595046675888409353
i:2 j:4 tbCorrelations(i)(j):.9846220453345639857252443944423809032355
i:2 j:5 tbCorrelations(i)(j):.9999006678860040067444791253388708425491
i:3 j:4 tbCorrelations(i)(j):.9699466127939676886845674420721274232967
i:3 j:5 tbCorrelations(i)(j):.9045436246922563213202471706818065185319
i:4 j:5 tbCorrelations(i)(j):.9822590866464295178439631880296031951357
FIN
*/