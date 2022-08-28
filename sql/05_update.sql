ALTER TABLE raid_data
ADD `raids_7` int(11) DEFAULT NULL;
ADD `raids_8` int(11) DEFAULT NULL;

ALTER TABLE quest_data
CHANGE `value` `value_total` int(11);
ADD `value` int(11) DEFAULT NULL;
ADD `value_alt` int(11) DEFAULT NULL;

ALTER TABLE tr_data
CHANGE `value` `value_total` int(11);
ADD `value` int(11) DEFAULT NULL;
ADD `grunt` int(11) DEFAULT NULL;
ADD `boss` int(11) DEFAULT NULL;
ADD `npc` int(11) DEFAULT NULL;