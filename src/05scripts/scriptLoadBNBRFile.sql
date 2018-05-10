/************************************************************************************
    Propiedad Intelectual de Universidad del Valle

    Script:    LoadBNBRFile

    Autor:    Diego García
    Fecha:    29/May/2017

    Descripcion:   Load BNBR File (BUILD SUCCESSFUL (total time: 31 seconds))

      crea un archivo general del proceso (hora inicio, fin, reg. procesados, etc)
                  LoadExpressionData_OUT_yyyymmdd_hh24miss.txt

*************************************************************************************/


DECLARE
    ---Archivo plano de entrada
    sbArchivoDatosEntrada           VARCHAR2(200);
    iflFileHandle                   utl_file.file_TYPE;     -- Tipo archivo del sistema

    ---Archivos planos de salida
    sbArchivoDatosSalida            VARCHAR2 (200);

    -- Se definen las variables para calcular el tiempo que demora el procedimiento.
    dtTiempoInicia      TIMESTAMP(9);
    dtTiempoTermina     TIMESTAMP(9);
    dtTiempoUtilizado   INTERVAL DAY TO SECOND(9);
    
    --Variable donde se almacena la linea leida del archivo
    osbLine             VARCHAR2(900);

    --ruta donde se buscaran los archivos
    --sbRuta              VARCHAR2(100) := 'C:\Users\prior';
    --sbRuta              VARCHAR2(100) := 'C://Users//prior';
    sbRuta              VARCHAR2(100) := 'C:\\Users\\prior';

    --mensaje de error
    sbErrorMessage      VARCHAR2(2000);

    --Conteo de registros
    nuTotal             PLS_INTEGER := 0; -- Remplazar por NUMBER si se calcula que el dato excede de 2147483648

    --Posiscion inicial para buscar en la cadena
    nuNRO               PLS_INTEGER;
    nuLongitud          PLS_INTEGER;
    N_POSI              PLS_INTEGER;

    --Campos obtenidos desde el archivo
    sbLinea             varchar2(36);

BEGIN
    dbms_output.put_line('INICIO');
    --almacena la hora de inicio del proceso
    dtTiempoInicia := SYSTIMESTAMP;

    ---Archivo plano de entrada
    sbArchivoDatosEntrada   := 'tbBNBR2.txt';
    iflFileHandle           := utl_file.fopen ('TEMP_DIR', sbArchivoDatosEntrada, 'r');
    
    pkBNBinaryRepresentation.tbBNBR.delete;
    LOOP
	    BEGIN
            UTL_FILE.get_line( iflFileHandle, sbLinea);
            -- Procesar Linea
            dbms_output.put_line(sbLinea);
            pkBNBinaryRepresentation.tbBNBR(sbLinea) := 1;

 		EXCEPTION
		    WHEN NO_DATA_FOUND THEN
                 utl_file.fclose (iflFileHandle);
				 EXIT;
	    END;
    END LOOP;


    -- Se captura el tiempo final y se carga el tiempo de procesamiento para impresion.
    dtTiempoTermina   := SYSTIMESTAMP ;
    dtTiempoUtilizado := dtTiempoTermina - dtTiempoInicia ;

    --Cierra los archivos
    --utl_file.fclose (iflFileHandle);
    dbms_output.put_line('FIN');

EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Error:'||SQLERRM);
        utl_file.fclose (iflFileHandle);

END;
/
-- CREATE OR REPLACE DIRECTORY TEMP_DIR AS 'C:\Users\dgarcia';
-- GRANT READ, WRITE ON DIRECTORY TEMP_DIR TO BAYES;
-- RegPrecise