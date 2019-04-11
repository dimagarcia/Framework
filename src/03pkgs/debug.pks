CREATE OR REPLACE package debug
IS
g_debugging boolean := false;
g_level integer := 0;
function getId RETURN integer;
procedure output (p_text varchar2, p_level integer, p_strategy integer);
END debug;
/
