CREATE TABLE IF NOT EXISTS `jail` (
  `identifier` varchar(100) NOT NULL DEFAULT '0',
  `name` varchar(100) NOT NULL DEFAULT '0',
  `characterid` varchar(5) NOT NULL DEFAULT '0',
  `time_s` varchar(100) NOT NULL DEFAULT '0',
  `jaillocation` varchar(100) NOT NULL DEFAULT '0'
);

INSERT IGNORE INTO `items` (`item`, `label`, `limit`, `can_remove`, `type`, `usable`, `metadata`, `desc`, `weight`) VALUES
("handcuffs", "Handcuffs", 200, 1, "item_standard", 1, "{}", "They are used to handcuff the prisoner", 0.1);