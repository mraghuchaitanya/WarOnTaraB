/*Function to evaluate War at Tara*/
/*Input required Number of Horses, Elephants, Armoured Tanks, Sling Guns*/

SET SERVEROUT ON

CREATE OR REPLACE FUNCTION war_at_tara (
   /*Attack variables*/
    a_h    IN NUMBER DEFAULT 0,
    a_e    IN NUMBER DEFAULT 0,
    a_at   IN NUMBER DEFAULT 0,
    a_sg   IN NUMBER DEFAULT 0
) RETURN VARCHAR2 AS

    war_result   VARCHAR2(150) := 'Lengaburu safe!';
    /*Defence variables*/
    d_h          NUMBER := 0;
    d_e          NUMBER := 0;
    d_at         NUMBER := 0;
    d_sg         NUMBER := 0;
    /*Defence reserve variables*/
    dr_h         NUMBER := 0;
    dr_e         NUMBER := 0;
    dr_at        NUMBER := 0;
    dr_sg        NUMBER := 0;
    /*Attack reserve variables*/
    ar_h         NUMBER := 0;
    ar_e         NUMBER := 0;
    ar_at        NUMBER := 0;
    ar_sg        NUMBER := 0;
    /*Strenght and gap variables*/
    tot_a        NUMBER := 0;
    tot_d        NUMBER := 0;
    tot_dr       NUMBER := 0;
    gap          NUMBER := 0;
    
    /*Defence reserve cursor*/
    CURSOR defence_reserve IS SELECT
                                  horses,
                                  elephants,
                                  armoured_tanks,
                                  sling_guns
                              FROM
                                  the_armies
                              WHERE
                                  army = 'Lengaburu';

    /*Attack reserve cursor*/

    CURSOR attack_reserve IS SELECT
                                horses,
                                elephants,
                                armoured_tanks,
                                sling_guns
                            FROM
                                the_armies
                            WHERE
                                army = 'Falicornia';

BEGIN
    /*Attack values*/
    dbms_output.put_line('Falicornia attacks with : '
                           || a_h
                           || ' H, '
                           || a_e
                           || ' E, '
                           || a_at
                           || ' AT, '
                           || a_sg
                           || ' SG');
    
    /*Attack reserve check and exit if insufficient*/

    OPEN attack_reserve;
    FETCH attack_reserve INTO
        ar_h,
        ar_e,
        ar_at,
        ar_sg;
    CLOSE attack_reserve;
    IF ( ar_h < a_h OR ar_e < a_e OR ar_at < a_at OR ar_sg < a_sg ) THEN
        dbms_output.put_line('Falicornia attack failed - not enough reserve');
        GOTO warexit;
    END IF;

    /*Attack strenght in Horse power - converting 
    Elephant = 2 * Horse
    Armoured Tank = 2 * 2 * Horse
    Sling Gun = 2 * 2 * 2 * Horse
    */

    tot_a := a_h + ( 2 * a_e ) + ( 2 * 2 * a_at ) + ( 2 * 2 * 2 * a_sg );
    /*dbms_output.put_line('Falicornia attack horse power : ' || tot_a);*/

    /*Defence reserve check*/

    OPEN defence_reserve;
    FETCH defence_reserve INTO
        dr_h,
        dr_e,
        dr_at,
        dr_sg;
    CLOSE defence_reserve;

    /*Defence reserve strenght in Horse power - conversion along with 2X strenght against Attackers */
    tot_dr := 2 * ( dr_h + ( 2 * dr_e ) + ( 2 * 2 * dr_at ) + ( 2 * 2 * 2 * dr_sg ) );
    /*dbms_output.put_line('Lengaburu reserve horse power : ' || tot_dr);*/

    /*Defence reserve strenght check with Attack strenght and minimum required*/

    IF ( tot_dr >= tot_a ) THEN
        tot_d := tot_a;
    END IF;
    /*dbms_output.put_line('Lengaburu defence horse power required : ' || tot_d);*/
    /*Basic retaliation required*/
    d_h := ceil(a_h / 2);
    d_e := ceil(a_e / 2);
    d_at := ceil(a_at / 2);
    d_sg := ceil(a_sg / 2);
    /*dbms_output.put_line('Lengaburu initial deploy  : '
                           || d_h
                           || ' H, '
                           || dr_h
                           || ' R H, '
                           || d_e
                           || ' E, '
                           || dr_e
                           || ' R E, '
                           || d_at
                           || ' AT, '
                           || dr_at
                           || ' R AT, '
                           || d_sg
                           || ' SG, '
                           || dr_sg
                           || ' R SG');*/

    /*Basic retaliation comparision with defence reserves & strenght correction*/
    IF d_sg > dr_sg THEN
        d_sg := dr_sg;
    END IF;
    IF d_at > dr_at THEN
        d_at := dr_at;
    END IF;
    IF d_e > dr_e THEN
        d_e := dr_e;
    END IF;
    IF d_h > dr_h THEN
        d_h := dr_h;
    END IF;
    tot_d := 2 * ( d_h + ( 2 * d_e ) + ( 2 * 2 * d_at ) + ( 2 * 2 * 2 * d_sg ) );

    /*dbms_output.put_line('Lengaburu updated deploy  : '
                           || d_h
                           || ' H, '
                           || dr_h
                           || ' R H, '
                           || d_e
                           || ' E, '
                           || dr_e
                           || ' R E, '
                           || d_at
                           || ' AT, '
                           || dr_at
                           || ' R AT, '
                           || d_sg
                           || ' SG, '
                           || dr_sg
                           || ' R SG');

    dbms_output.put_line('Lengaburu defence horse power current : '
                           || tot_d
                           || ' available reserve:'
                           || (tot_dr - tot_d)
                           || ' additional required:'
                           || (tot_a - tot_d) );*/
                           
    /*Available defence reserves & gap coparision with substitution logic*/

    IF ( ( tot_dr - tot_d > 0 ) AND ( tot_d < tot_a ) ) THEN
        gap := ( tot_a - tot_d ) / 2;
        /*Horse defence with remaining gap if less than reserve - strenght update*/
        IF d_h < dr_h AND d_h + gap <= dr_h AND ( ( tot_dr - tot_d ) > ( tot_a - tot_d ) ) THEN
            d_h := d_h + gap;
            tot_d := tot_d + 2 * d_h;
            dbms_output.put_line('11 tot_d:'
                                   || tot_d
                                   || ' gap:'
                                   || gap);
        /*Horse defence with remaining gap with reserve capping - strenght and gap update*/
        ELSIF d_h < dr_h AND d_h + gap > dr_h AND ( ( tot_dr - tot_d ) > ( tot_a - tot_d ) ) THEN
            d_h := dr_h;
            tot_d := tot_d + 2 * d_h;
            gap := ( tot_a - tot_d ) / 2;
            dbms_output.put_line('12 tot_d:'
                                   || tot_d
                                   || ' gap:'
                                   || gap);
        END IF;

        /*Elephant defence with remaining gap if less than reserve - strenght update*/

        IF d_e < dr_e AND d_e + ceil(gap / 2) <= dr_e AND ( ( tot_dr - tot_d ) > ( tot_a - tot_d ) ) THEN
            d_e := d_e + ceil(gap / 2);
            tot_d := tot_d + 4 * d_e;
            dbms_output.put_line('21 tot_d:'
                                   || tot_d
                                   || ' gap:'
                                   || gap);
        /*Elephant defence with remaining gap with reserve capping - strenght and gap update*/
        ELSIF d_e < dr_e AND d_e + ceil(gap / 2) > dr_e AND ( ( tot_dr - tot_d ) > ( tot_a - tot_d ) ) THEN
            d_e := dr_e;
            tot_d := tot_d + 4 * d_e;
            gap := ( tot_a - tot_d ) / 2;
            dbms_output.put_line('22 tot_d:'
                                   || tot_d
                                   || ' gap:'
                                   || gap);
        END IF;

        /*Armoured Tanks defence with remaining gap if less than reserve - strenght update*/

        IF d_at < dr_at AND d_at + ceil(gap / 4) <= dr_at AND ( ( tot_dr - tot_d ) > ( tot_a - tot_d ) ) THEN
            d_at := d_at + ceil(gap / 2);
            tot_d := tot_d + 8 * d_at;
            dbms_output.put_line('31 tot_d:'
                                   || tot_d
                                   || ' gap:'
                                   || gap);
        /*Armoured Tanks defence with remaining gap with reserve capping - strenght and gap update*/
        ELSIF d_at < dr_at AND d_at + ceil(gap / 4) > dr_at AND ( ( tot_dr - tot_d ) > ( tot_a - tot_d ) ) THEN
            d_at := dr_at;
            tot_d := tot_d + 8 * d_at;
            gap := ( tot_a - tot_d ) / 2;
            dbms_output.put_line('32 tot_d:'
                                   || tot_d
                                   || ' gap:'
                                   || gap);
        END IF;

        /*Sling Guns defence with remaining gap if less than reserve - strenght update*/

        IF d_sg < dr_sg AND d_sg + ceil(gap / 8) <= dr_sg AND ( ( tot_dr - tot_d ) > ( tot_a - tot_d ) ) THEN
            d_sg := d_sg + ceil(gap / 2);
            tot_d := tot_d + 16 * d_sg;
            dbms_output.put_line('41 tot_d:'
                                   || tot_d
                                   || ' gap:'
                                   || gap);
        /*Sling Guns defence with remaining gap with reserve capping - strenght and gap update*/
        ELSIF d_sg < dr_sg AND d_sg + ceil(gap / 8) > dr_sg AND ( ( tot_dr - tot_d ) > ( tot_a - tot_d ) ) THEN
            d_sg := dr_sg;
            tot_d := tot_d + 16 * d_sg;
            gap := ( tot_a - tot_d ) / 2;
            dbms_output.put_line('42 tot_d:'
                                   || tot_d
                                   || ' gap:'
                                   || gap);
        END IF;

    END IF;

    /*dbms_output.put_line('Lengaburu defence horse power adjusted : '
                           || tot_d
                           || ' new available reserve:'
                           || (tot_dr - tot_d) );*/

    /*War Result build using defence against attack*/

    war_result := 'Lengaburu deploys  : '
                  || d_h
                  || ' H, '
                  || d_e
                  || ' E, '
                  || d_at
                  || ' AT, '
                  || d_sg
                  || ' SG'
                  || ' and ';

    IF tot_d > tot_a THEN
        war_result := war_result || ' wins!';
    ELSE
        war_result := war_result || ' loses.';
    END IF;

    dbms_output.put_line(war_result);
    << warexit >> RETURN war_result;
EXCEPTION
    WHEN OTHERS THEN
        RETURN war_result;
END war_at_tara;
/
