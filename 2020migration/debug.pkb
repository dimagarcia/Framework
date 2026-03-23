CREATE OR REPLACE package body debug
IS
---------------------------------------------------------
function getId RETURN integer IS
 nuid integer;
BEGIN
    select max(id) into nuid from debug_messages;
    return NVL(nuid,1);
END getId;
---------------------------------------------------------
procedure output (p_text varchar2, p_level integer, p_strategy integer) is
   pragma autonomous_transaction;
begin
   if g_debugging and p_level >= g_level then
      insert into debug_messages (id, username, datetime, text, strategy)
      values ( debug.getId, user, sysdate, p_text, p_strategy);
      commit;
      dbms_output.put_line(LPAD('',p_level)||p_text);
   end if;
end;
---------------------------------------------------------
end debug;
/
