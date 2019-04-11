DROP TABLE TRACE CASCADE CONSTRAINTS;

CREATE TABLE TRACE
(
  TYPE        NUMBER,
  ID          NUMBER,
  VALUE       NUMBER,
  STRATEGY    NUMBER,
  MAXINGRADE  NUMBER,
  MINDEPEND   NUMBER
)
TABLESPACE USERS
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING;

COMMENT ON TABLE TRACE IS 'This table save the score function value for each simulation';

COMMENT ON COLUMN TRACE.TYPE IS 'Number of edges for the current simulation';

COMMENT ON COLUMN TRACE.ID IS 'Number of simulation for the current simulation';

COMMENT ON COLUMN TRACE.VALUE IS 'Score function value for the current simulation';

COMMENT ON COLUMN TRACE.STRATEGY IS 'Type of simulation for the current simulation';

COMMENT ON COLUMN TRACE.MAXINGRADE IS 'Maximum in-grade for the current simulation';

COMMENT ON COLUMN TRACE.MINDEPEND IS 'Minimum value of probabilistic for the current simulation';


