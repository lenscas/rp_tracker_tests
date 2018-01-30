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
	1,
	1,
	"Some test name",
	13,
	null,
	"Some description",
	0,
	"Some test backstory",
	"Some test personality",
	"char123",
	"Some notes",
	"Some hidden data"
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
	1,
	1,
	1,
	"some_special_attack",
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
	1 AS charId,
	id AS statId,
	1 AS isBase,
	"Base" AS name,
	4 AS value,
	-1 AS countDown
FROM stats
WHERE rpId = 1;
