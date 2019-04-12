DROP TABLE POWER_MATRIX CASCADE CONSTRAINTS;

CREATE TABLE POWER_MATRIX
(
  POMAPOW  NUMBER,
  POMAROW  NUMBER,
  POMACOL  NUMBER,
  POMAVAL  NUMBER
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

COMMENT ON TABLE POWER_MATRIX IS 'Powers of the adjacency matrix';

COMMENT ON COLUMN POWER_MATRIX.POMAPOW IS 'Power';

COMMENT ON COLUMN POWER_MATRIX.POMAROW IS 'Row of the adjacency matrix';

COMMENT ON COLUMN POWER_MATRIX.POMACOL IS 'Column of the adjacency matrix';

COMMENT ON COLUMN POWER_MATRIX.POMAVAL IS 'Power value of the [row,col] position';

