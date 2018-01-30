INSERT INTO rolePlays (
	id,
	name,
	code,
	isPrivate,
	startingStatAmount,
	startingAbilityAmount,
	description,
	creator,
	battleSystemId
) VALUES (
	1,
	"test rp",
	"1234567",
	0,
	25,
	3,
	"Some test description",
	"68026ea182128245c9fe6aeb549578853db0a166",
	2
);
INSERT INTO players (
	id,
	userId,
	rpId,
	is_GM
) VALUES(
	1,
	"68026ea182128245c9fe6aeb549578853db0a166",
	1,
	1
);
INSERT INTO actions (rpId,name,code,description)
	SELECT 1 AS rpId, name,code,description
	FROM defaultActions
	WHERE battleSystemId = 2;
DELETE FROM stats WHERE 1;
INSERT INTO stats (rpId,name, internalName,description)
	SELECT 1 AS rpId, name,intName AS internalName,description
	FROM defaultStats
	WHERE battleSystemId = 2;
