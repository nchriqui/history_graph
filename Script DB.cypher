CREATE INDEX ON :FindSpot(name, location, province);
CREATE INDEX ON :Inscription(name, height, width, depth, literature, type, begin, end);
CREATE INDEX ON :Province(name);
CREATE INDEX ON :Country(name);

LOAD CSV WITH HEADERS FROM 'file:///edh_data_pers.csv' AS line
WITH line,
CASE WHEN line.geschlecht = "M" THEN "male" ELSE "female" END AS gender
CREATE (p:People {name: line.name, praenomen: line.praenomen, nomen: line.nomen, cognomen: line.cognomen, gender: gender, hd: line.hd_nr});


LOAD CSV WITH HEADERS FROM 'file:///edh_data_text.csv' AS line
WITH line, CASE WHEN line.fo_antik <> "" THEN line.fo_antik ELSE line.fo_modern END AS spot
WITH split(line.btext,"/") AS transcription, split(line.literatur,"#") AS literature, spot, line
MERGE (s:FindSpot {name: spot, location: line.koordinaten1, province: line.provinz})
CREATE (i:Inscription {name: line.hd_nr, height: toInteger(line.hoehe), width: toInteger(line.breite), depth: toInteger(line.tiefe), literature: [x in literature | trim(x)], transcription: [y in transcription | trim(y)], type: line.i_gattung, begin: toInteger(line.dat_jahr_a), end: toInteger(line.dat_jahr_e)})
MERGE (r:Province {name: line.provinz})
MERGE (c:Country {name: line.land})
CREATE (i)-[:FindIn]->(s)
MERGE (s)-[:LocatedIn]->(r)
MERGE (r)-[:PartOf]->(c);


MATCH (i:Inscription)
WHERE i.height IS NOT NULL
SET i.height = abs(i.height) + " cm";

MATCH (i:Inscription)
WHERE i.width IS NOT NULL
SET i.width = abs(i.width) + " cm";

MATCH (i:Inscription)
WHERE i.depth IS NOT NULL
SET i.depth = abs(i.depth) + " cm";


LOAD CSV WITH HEADERS FROM 'file:///edh_data_text.csv' AS line
WITH split(line.literatur,"#") AS books
UNWIND books AS book
WITH book
WHERE book <> ""
CREATE (:Literature {name: trim(book)});

MATCH (l:Literature)
WITH l.name AS name, collect(l) AS books
WHERE size(books) > 1
FOREACH (n IN tail(books) | DETACH DELETE n);


CREATE INDEX ON :Inscription(literature);
CREATE INDEX ON :Literature(name);

MATCH (i:Inscription) WHERE i.literature IS NOT NULL WITH i
MATCH (l:Literature) WHERE l.name IN i.literature WITH i, l
MERGE (i)-[:NamedIn]->(l)
REMOVE i.literature;


CREATE INDEX ON :People(hd);
CREATE INDEX ON :Inscription(name);

MATCH (i:Inscription) WITH i
MATCH (p:People) WHERE p.hd = i.name WITH i, p
MERGE (p)-[:AppearsIn]->(i)
REMOVE p.hd;

MATCH (p:People)-[:AppearsIn]->(i:Inscription)
WITH p.name AS name, p.nomen AS nomen, p.cognomen AS cognomen, p.gender AS gender, i.begin AS begin, i.end AS end, collect(p) AS people
WHERE size(people) > 1 AND name <> "[---]" AND name <> "[----]" AND name <> "[[---]]"
CALL apoc.refactor.mergeNodes(people, {properties: "discard", mergeRels:true}) YIELD node
RETURN node;


MATCH (p:People)
WITH p.nomen AS nomen, p.cognomen AS cognomen, collect(DISTINCT p) AS people
WHERE size(people) > 1 AND nomen <> "00" AND cognomen <> "00"
FOREACH (i in range(0, size(people) - 2) |
 FOREACH (node1 in [people[i]] |
    FOREACH(j in range(i, size(people) - 2) |
        FOREACH (node2 in [people[j+1]] |
            MERGE (node1)-[:Homonym]-(node2)))));


MATCH (p:People)-[:AppearsIn]->(:Inscription)-[:NamedIn]->(l:Literature)
WITH l.name AS name, collect(DISTINCT p) AS people
WHERE size(people) > 1
FOREACH (i in range(0, size(people) - 2) |
 FOREACH (node1 in [people[i]] |
    FOREACH(j in range(i, size(people) - 2) |
        FOREACH (node2 in [people[j+1]] |
            MERGE (node1)-[:`Co-appearing`]-(node2)))));


LOAD CSV WITH HEADERS FROM 'file:///inscriptions.csv' AS line
MATCH (i:Inscription)
WHERE i.type = line.code
SET i.type = line.type;


MATCH (i:Inscription) WHERE i.type <> ""
WITH DISTINCT i.type AS type, collect(DISTINCT i) AS inscriptions
CALL apoc.create.addLabels(inscriptions, [type]) YIELD node
RETURN count(node);

MATCH (i:Inscription) 
WHERE i.type = ""
SET i.type = "Inscription";


LOAD CSV WITH HEADERS FROM 'file:///iso.csv' AS line
MATCH (c:Country)
WHERE toUpper(c.name) = line.alpha
SET c.name = line.name;


LOAD CSV WITH HEADERS FROM 'file:///provinz.csv' AS line FIELDTERMINATOR ';'
MATCH (p:Province)
WHERE p.name = line.code
SET p.name = line.provinz;


DROP INDEX ON :FindSpot(name, location, province);
DROP INDEX ON :Inscription(name, height, width, depth, literature, type, begin, end);
DROP INDEX ON :Province(name);
DROP INDEX ON :Country(name);

DROP INDEX ON :Inscription(literature);
DROP INDEX ON :Literature(name);

DROP INDEX ON :People(hd);
DROP INDEX ON :Inscription(name);
