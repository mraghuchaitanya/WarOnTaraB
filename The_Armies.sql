/*Base Table Creation*/
CREATE TABLE "THE_ARMIES" (
    "ARMY"             VARCHAR2(20 BYTE)
        NOT NULL ENABLE,
    "LEADER"           VARCHAR2(20 BYTE),
    "HORSES"           NUMBER,
    "ELEPHANTS"        NUMBER,
    "ARMOURED_TANKS"   NUMBER,
    "SLING_GUNS"       NUMBER
);
/
/*Basic Army Data Insert*/

INSERT INTO the_armies (
    army,
    leader,
    horses,
    elephants,
    armoured_tanks,
    sling_guns
) VALUES (
    'Lengaburu',
    'King Shan',
    100,
    50,
    10,
    5
);

INSERT INTO the_armies (
    army,
    leader,
    horses,
    elephants,
    armoured_tanks,
    sling_guns
) VALUES (
    'Falicornia',
    'Al Falcone',
    300,
    200,
    40,
    20
);

COMMIT;
/
