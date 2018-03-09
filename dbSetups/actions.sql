INSERT INTO
	`characters`
(
	`id`,
	`playerId`,
	`name`,
	`age`,
	`appearancePicture`,
	`appearanceDescription`,
	`isLocalImage`,
	`backstory`,
	`personality`,
	`code`,
	`notes`,
	`hiddenData`
) VALUES (
	2,
	1,
	"Some second test name",
	13,
	null,
	"Some second description",
	0,
	"Some second test backstory",
	"Some second test personality",
	"char321",
	"Some second notes",
	"Some second hidden data"
);
INSERT INTO `abilities`
(
	`id`,
	`charId`,
	`actionId`,
	`name`,
	`description`,
	`cooldown`,
	`countDown`
) VALUES (
	2,
	1,
	1,
	"some_second_special_attack",
	"A test description",
	"3",
	0
);
INSERT INTO `modifiers`
(
	`charId`,
	`statId`,
	`isBase`,
	`name`,
	`value`,
	`countDown`
)
SELECT
	2 AS charId,
	id AS statId,
	1 AS isBase,
	"Base" AS name,
	3 AS value,
	-1 AS countDown
FROM stats
WHERE rpId = 1;
INSERT INTO `battle`
(
	`id`,
	`rpId`,
	`name`,
	`link`
) VALUES (
	1,
	1,
	"some test battle",
	null
);
INSERT INTO `charsInBattle`
(
	`id`,
	`charId`,
	`battleId`,
	`turnOrder`,
	`isTurn`,
	`isRemoved`
) VALUES (
	1,
	1,
	1,
	1,
	1,
	0
), (
	2,
	2,
	1,
	2,
	0,
	0
);
