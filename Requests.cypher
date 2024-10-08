//Comparison between all inscription type's overall
MATCH (i:Inscription)
WITH count(i) AS nb_total
MATCH (i:Inscription)
WITH i.type AS type, i, nb_total
RETURN type, count(i) AS nb_inscriptions, apoc.number.format((count(i)*100.0)/nb_total,'.###') + "%" as percent
ORDER BY type


//Comparison between Epitaphs and Votive inscriptions for each province
MATCH (i:Epitaph)-[:FindIn]->(f:FindSpot)-[:LocatedIn]->(p:Province)
WHERE p.name <> ""
WITH p.name AS province, i
RETURN province, count(i) AS nb_epitaph
ORDER BY province

MATCH (i:`Votive inscription`)-[:FindIn]->(f:FindSpot)-[:LocatedIn]->(p:Province)
WHERE p.name <> ""
WITH p.name AS province, i
RETURN province, count(i) AS nb_votive
ORDER BY province

MATCH (i:Inscription)-[:FindIn]->(f:FindSpot)-[:LocatedIn]->(p:Province)
WHERE p.name <> ""
WITH p.name AS province, collect(i) as inscriptions
RETURN province, size(inscriptions)
ORDER BY province


//Statistics on types of monuments for Britannia
MATCH (i:Inscription)-[:FindIn]->(f:FindSpot)-[:LocatedIn]->(p:Province)
WHERE p.name = "Britannia"
WITH count(i) AS nb_total
MATCH (i:Inscription)-[:FindIn]->(f:FindSpot)-[:LocatedIn]->(p:Province)
WHERE p.name = "Britannia"
WITH i.type AS type, i, nb_total
RETURN type, count(i) AS nb_inscriptions, apoc.number.format((count(i)*100.0)/nb_total,'.###') + "%" as percent
ORDER BY type


//Attested persons in Britannia
MATCH (n:People)
WITH count(n) AS nb_total
MATCH (n:People)-[:AppearsIn]-(i:Inscription)-[:FindIn]-(f:FindSpot)-[:LocatedIn]-(p:Province)
WHERE p.name = "Britannia"
WITH n, nb_total
RETURN count(DISTINCT n) AS nb_people, apoc.number.format((count(DISTINCT n)*100.0)/nb_total,'.###') + "%" as percent


//Number of individuals with the same name in Britannia
MATCH (n:People)-[:AppearsIn]->(i:Inscription)-[:FindIn]->(f:FindSpot)-[:LocatedIn]->(p:Province)
WHERE p.name = "Britannia"
WITH count(n) AS nb_total
MATCH (n:People)-[:AppearsIn]->(i:Inscription)-[:FindIn]->(f:FindSpot)-[:LocatedIn]->(p:Province)
WHERE p.name = "Britannia"
WITH n.name AS name, collect(DISTINCT n) AS people, nb_total
WHERE size(people) > 1 AND name <> "[---]" AND name <> "[----]" AND name <> "[[---]]"
RETURN name, size(people) AS nb_people, apoc.number.format((size(people)*100.0)/nb_total,'.###') + "%" as percent


//Number of individuals with same nomen and cognomen (homonym) in Britannia
MATCH (p:Province)<-[:LocatedIn]-(:FindSpot)<-[:FindIn]-(:Inscription)<-[:AppearsIn]-(n:People)-[r:Homonym]-(m:People)-[:AppearsIn]->(:Inscription)-[:FindIn]->(:FindSpot)-[:LocatedIn]->(p:Province)
WHERE p.name = "Britannia"
RETURN count(DISTINCT n)


//Statistics on types of monuments for Dacia
MATCH (i:Inscription)-[:FindIn]->(f:FindSpot)-[:LocatedIn]->(p:Province)
WHERE p.name = "Dacia"
WITH count(i) AS nb_total
MATCH (i:Inscription)-[:FindIn]->(f:FindSpot)-[:LocatedIn]->(p:Province)
WHERE p.name = "Dacia"
WITH i.type AS type, i, nb_total
RETURN type, count(i) AS nb_inscriptions, apoc.number.format((count(i)*100.0)/nb_total,'.###') + "%" as percent
ORDER BY type


//Attested persons in Dacia
MATCH (n:People)
WITH count(n) AS nb_total
MATCH (n:People)-[:AppearsIn]-(i:Inscription)-[:FindIn]-(f:FindSpot)-[:LocatedIn]-(p:Province)
WHERE p.name = "Dacia"
WITH n, nb_total
RETURN count(DISTINCT n) AS nb_people, apoc.number.format((count(DISTINCT n)*100.0)/nb_total,'.###') + "%" as percent


//Number of individuals with the same name in Dacia
MATCH (n:People)-[:AppearsIn]->(i:Inscription)-[:FindIn]->(f:FindSpot)-[:LocatedIn]->(p:Province)
WHERE p.name = "Dacia"
WITH count(n) AS nb_total
MATCH (n:People)-[:AppearsIn]->(i:Inscription)-[:FindIn]->(f:FindSpot)-[:LocatedIn]->(p:Province)
WHERE p.name = "Dacia"
WITH n.name AS name, collect(DISTINCT n) AS people, nb_total
WHERE size(people) > 1 AND name <> "[---]" AND name <> "[----]" AND name <> "[[---]]"
RETURN name, size(people) AS nb_people, apoc.number.format((size(people)*100.0)/nb_total,'.###') + "%" as percent


//Number of individuals with same nomen and cognomen (homonym) in Dacia
MATCH (p:Province)<-[:LocatedIn]-(:FindSpot)<-[:FindIn]-(:Inscription)<-[:AppearsIn]-(n:People)-[r:Homonym]-(m:People)-[:AppearsIn]->(:Inscription)-[:FindIn]->(:FindSpot)-[:LocatedIn]->(p:Province)
WHERE p.name = "Dacia"
RETURN count(DISTINCT n)


//Statistical of where Acclamations appear by province
MATCH (a:Acclamation)
WITH count(a) AS nb_total_acclamation
MATCH (i:Acclamation)-[:FindIn]->(f:FindSpot)-[:LocatedIn]->(p:Province)
WHERE p.name <> ""
WITH p.name AS province, i, nb_total_acclamation
RETURN province, count(i) AS nb_acclamation, apoc.number.format((count(i)*100.0)/nb_total_acclamation,'.###') + "%" as percent
ORDER BY province


//Statistical of where Acclamations appear by country
MATCH (a:Acclamation)
WITH count(a) as nb_total_acclamation
MATCH (i:Acclamation)-[:FindIn]->(f:FindSpot)-[:LocatedIn]->(p:Province)-[:PartOf]->(c:Country)
WHERE p.name <> "" AND c.name <> ""
WITH c.name AS country, i, nb_total_acclamation
RETURN country, count(i) AS nb_acclamation, apoc.number.format((count(i)*100.0)/nb_total_acclamation,'.###') + "%" as percent
ORDER BY country


//Period of time when Acclamations appear
MATCH (a:Acclamation)
WITH count(a) AS nb_total_acclamation
MATCH (a:Acclamation) 
RETURN a.begin AS period_start, a.end AS period_end, count(a) AS nb_acclamation, apoc.number.format((count(a)*100.0)/nb_total_acclamation,'.###') + "%" as percent
ORDER BY period_start