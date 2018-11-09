/*Simple Function call to evaluate War at Tara*/
/*Input required Number of Horses, Elephants, Armoured Tanks, Sling Guns*/

SET SERVEROUT ON

BEGIN
    dbms_output.put_line(war_at_tara(&horse,&elephant,&armouredtanks,&slingguns) );
END;
/
