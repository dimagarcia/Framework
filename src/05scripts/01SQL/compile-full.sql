--PROMPT Appling schema
@tbls/schema.sql

--PROMPT Appling schema 2
@tbls/schema2.sql

--PROMPT Appling schema 3
@tbls/schema3.sql

--PROMPT Appling schema 4
@tbls/schema4.sql

--PROMPT Appling schema 5
@tbls/schema5.sql

PROMPT Compiling pkBayesianMapper
@pkgs/pkBayesianMapper.pkg
PROMPT Compiling pkLikelihood
@pkgs/pkLikelihood.pkg
PROMPT Compiling pkCorrelation
@pkgs/pkCorrelation.pkg
PROMPT Compiling pkFiltering
@pkgs/pkFiltering.pkg
PROMPT Compiling pkHasting
@pkgs/pkHasting.pkg

--PROMPT Appling insFrequency2
@data/insFrequency2.sql

--PROMPT Appling insPowerMatrix
@data/insPowerMatrix.sql

--PROMPT Appling insSample
@data/insSample.sql

--PROMPT Appling insFrequency
@data/insFrequency.sql

