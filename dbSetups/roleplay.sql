INSERT INTO users (
	id,
	username,
	password,
	email,
	hasActivated,
	activationCode
) VALUES (
	"someUserId",
	"someUserName",
	"somePassword",
	"noEmail@localhost.com",
	1,
	""
);
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
	"test rp join",
	"1234567",
	0,
	25,
	3,
	"This is to correctly test joing an RP",
	"someUserId",
	2
);
INSERT INTO players(
	id,
	userId,
	rpId,
	is_GM
) VALUES (
	1,
	"someUserId",
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
