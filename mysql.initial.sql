-- Roundcube Webmail initial database structure


/*!40014  SET FOREIGN_KEY_CHECKS=0 */;

-- Table structure for table `session`

CREATE TABLE `session` (
 `sess_id` varchar(128) NOT NULL,
 `changed` datetime NOT NULL DEFAULT '1000-01-01 00:00:00',
 `ip` varchar(40) NOT NULL,
 `vars` mediumtext NOT NULL,
 PRIMARY KEY(`sess_id`),
 INDEX `changed_index` (`changed`)
) /*!40000 ENGINE=INNODB */ /*!40101 CHARACTER SET utf8 COLLATE utf8_general_ci */;


-- Table structure for table `users`

CREATE TABLE `users` (
 `user_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
 `username` varchar(128) BINARY NOT NULL,
 `mail_host` varchar(128) NOT NULL,
 `created` datetime NOT NULL DEFAULT '1000-01-01 00:00:00',
 `last_login` datetime DEFAULT NULL,
 `failed_login` datetime DEFAULT NULL,
 `failed_login_counter` int(10) UNSIGNED DEFAULT NULL,
 `language` varchar(5),
 `preferences` longtext,
 PRIMARY KEY(`user_id`),
 UNIQUE `username` (`username`, `mail_host`)
) /*!40000 ENGINE=INNODB */ /*!40101 CHARACTER SET utf8 COLLATE utf8_general_ci */;


-- Table structure for table `cache`

CREATE TABLE `cache` (
 `user_id` int(10) UNSIGNED NOT NULL,
 `cache_key` varchar(128) /*!40101 CHARACTER SET ascii COLLATE ascii_general_ci */ NOT NULL,
 `expires` datetime DEFAULT NULL,
 `data` longtext NOT NULL,
 PRIMARY KEY (`user_id`, `cache_key`),
 CONSTRAINT `user_id_fk_cache` FOREIGN KEY (`user_id`)
   REFERENCES `users`(`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
 INDEX `expires_index` (`expires`)
) /*!40000 ENGINE=INNODB */ /*!40101 CHARACTER SET utf8 COLLATE utf8_general_ci */;


-- Table structure for table `cache_shared`

CREATE TABLE `cache_shared` (
 `cache_key` varchar(255) /*!40101 CHARACTER SET ascii COLLATE ascii_general_ci */ NOT NULL,
 `expires` datetime DEFAULT NULL,
 `data` longtext NOT NULL,
 PRIMARY KEY (`cache_key`),
 INDEX `expires_index` (`expires`)
) /*!40000 ENGINE=INNODB */ /*!40101 CHARACTER SET utf8 COLLATE utf8_general_ci */;


-- Table structure for table `cache_index`

CREATE TABLE `cache_index` (
 `user_id` int(10) UNSIGNED NOT NULL,
 `mailbox` varchar(255) BINARY NOT NULL,
 `expires` datetime DEFAULT NULL,
 `valid` tinyint(1) NOT NULL DEFAULT '0',
 `data` longtext NOT NULL,
 CONSTRAINT `user_id_fk_cache_index` FOREIGN KEY (`user_id`)
   REFERENCES `users`(`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
 INDEX `expires_index` (`expires`),
 PRIMARY KEY (`user_id`, `mailbox`)
) /*!40000 ENGINE=INNODB */ /*!40101 CHARACTER SET utf8 COLLATE utf8_general_ci */;


-- Table structure for table `cache_thread`

CREATE TABLE `cache_thread` (
 `user_id` int(10) UNSIGNED NOT NULL,
 `mailbox` varchar(255) BINARY NOT NULL,
 `expires` datetime DEFAULT NULL,
 `data` longtext NOT NULL,
 CONSTRAINT `user_id_fk_cache_thread` FOREIGN KEY (`user_id`)
   REFERENCES `users`(`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
 INDEX `expires_index` (`expires`),
 PRIMARY KEY (`user_id`, `mailbox`)
) /*!40000 ENGINE=INNODB */ /*!40101 CHARACTER SET utf8 COLLATE utf8_general_ci */;


-- Table structure for table `cache_messages`

CREATE TABLE `cache_messages` (
 `user_id` int(10) UNSIGNED NOT NULL,
 `mailbox` varchar(255) BINARY NOT NULL,
 `uid` int(11) UNSIGNED NOT NULL DEFAULT '0',
 `expires` datetime DEFAULT NULL,
 `data` longtext NOT NULL,
 `flags` int(11) NOT NULL DEFAULT '0',
 CONSTRAINT `user_id_fk_cache_messages` FOREIGN KEY (`user_id`)
   REFERENCES `users`(`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
 INDEX `expires_index` (`expires`),
 PRIMARY KEY (`user_id`, `mailbox`, `uid`)
) /*!40000 ENGINE=INNODB */ /*!40101 CHARACTER SET utf8 COLLATE utf8_general_ci */;


-- Table structure for table `contacts`

CREATE TABLE `contacts` (
 `contact_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
 `changed` datetime NOT NULL DEFAULT '1000-01-01 00:00:00',
 `del` tinyint(1) NOT NULL DEFAULT '0',
 `name` varchar(128) NOT NULL DEFAULT '',
 `email` text NOT NULL,
 `firstname` varchar(128) NOT NULL DEFAULT '',
 `surname` varchar(128) NOT NULL DEFAULT '',
 `vcard` longtext NULL,
 `words` text NULL,
 `user_id` int(10) UNSIGNED NOT NULL,
 PRIMARY KEY(`contact_id`),
 CONSTRAINT `user_id_fk_contacts` FOREIGN KEY (`user_id`)
   REFERENCES `users`(`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
 INDEX `user_contacts_index` (`user_id`,`del`)
) /*!40000 ENGINE=INNODB */ /*!40101 CHARACTER SET utf8 COLLATE utf8_general_ci */;

-- Table structure for table `contactgroups`

CREATE TABLE `contactgroups` (
  `contactgroup_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` int(10) UNSIGNED NOT NULL,
  `changed` datetime NOT NULL DEFAULT '1000-01-01 00:00:00',
  `del` tinyint(1) NOT NULL DEFAULT '0',
  `name` varchar(128) NOT NULL DEFAULT '',
  PRIMARY KEY(`contactgroup_id`),
  CONSTRAINT `user_id_fk_contactgroups` FOREIGN KEY (`user_id`)
    REFERENCES `users`(`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  INDEX `contactgroups_user_index` (`user_id`,`del`)
) /*!40000 ENGINE=INNODB */ /*!40101 CHARACTER SET utf8 COLLATE utf8_general_ci */;

CREATE TABLE `contactgroupmembers` (
  `contactgroup_id` int(10) UNSIGNED NOT NULL,
  `contact_id` int(10) UNSIGNED NOT NULL,
  `created` datetime NOT NULL DEFAULT '1000-01-01 00:00:00',
  PRIMARY KEY (`contactgroup_id`, `contact_id`),
  CONSTRAINT `contactgroup_id_fk_contactgroups` FOREIGN KEY (`contactgroup_id`)
    REFERENCES `contactgroups`(`contactgroup_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `contact_id_fk_contacts` FOREIGN KEY (`contact_id`)
    REFERENCES `contacts`(`contact_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  INDEX `contactgroupmembers_contact_index` (`contact_id`)
) /*!40000 ENGINE=INNODB */;


-- Table structure for table `identities`

CREATE TABLE `identities` (
 `identity_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
 `user_id` int(10) UNSIGNED NOT NULL,
 `changed` datetime NOT NULL DEFAULT '1000-01-01 00:00:00',
 `del` tinyint(1) NOT NULL DEFAULT '0',
 `standard` tinyint(1) NOT NULL DEFAULT '0',
 `name` varchar(128) NOT NULL,
 `organization` varchar(128) NOT NULL DEFAULT '',
 `email` varchar(128) NOT NULL,
 `reply-to` varchar(128) NOT NULL DEFAULT '',
 `bcc` varchar(128) NOT NULL DEFAULT '',
 `signature` longtext,
 `html_signature` tinyint(1) NOT NULL DEFAULT '0',
 PRIMARY KEY(`identity_id`),
 CONSTRAINT `user_id_fk_identities` FOREIGN KEY (`user_id`)
   REFERENCES `users`(`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
 INDEX `user_identities_index` (`user_id`, `del`),
 INDEX `email_identities_index` (`email`, `del`)
) /*!40000 ENGINE=INNODB */ /*!40101 CHARACTER SET utf8 COLLATE utf8_general_ci */;


-- Table structure for table `dictionary`

CREATE TABLE `dictionary` (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, -- redundant, for compat. with Galera Cluster
  `user_id` int(10) UNSIGNED DEFAULT NULL, -- NULL here is for "shared dictionaries"
  `language` varchar(5) NOT NULL,
  `data` longtext NOT NULL,
  CONSTRAINT `user_id_fk_dictionary` FOREIGN KEY (`user_id`)
    REFERENCES `users`(`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  UNIQUE `uniqueness` (`user_id`, `language`)
) /*!40000 ENGINE=INNODB */ /*!40101 CHARACTER SET utf8 COLLATE utf8_general_ci */;


-- Table structure for table `searches`

CREATE TABLE `searches` (
 `search_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
 `user_id` int(10) UNSIGNED NOT NULL,
 `type` int(3) NOT NULL DEFAULT '0',
 `name` varchar(128) NOT NULL,
 `data` text,
 PRIMARY KEY(`search_id`),
 CONSTRAINT `user_id_fk_searches` FOREIGN KEY (`user_id`)
   REFERENCES `users`(`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
 UNIQUE `uniqueness` (`user_id`, `type`, `name`)
) /*!40000 ENGINE=INNODB */ /*!40101 CHARACTER SET utf8 COLLATE utf8_general_ci */;


-- Table structure for table `system`

CREATE TABLE `system` (
 `name` varchar(64) NOT NULL,
 `value` mediumtext,
 PRIMARY KEY(`name`)
) /*!40000 ENGINE=INNODB */ /*!40101 CHARACTER SET utf8 COLLATE utf8_general_ci */;

/*!40014 SET FOREIGN_KEY_CHECKS=1 */;

INSERT INTO system (name, value) VALUES ('roundcube-version', '2016112200');
/**
 * Roundcube Calendar
 *
 * Plugin to add a calendar to Roundcube.
 *
 * @author Lazlo Westerhof
 * @author Thomas Bruederli
 * @licence GNU AGPL
 * @copyright (c) 2010 Lazlo Westerhof - Netherlands
 * @copyright (c) 2014 Kolab Systems AG
 *
 **/

CREATE TABLE IF NOT EXISTS `calendars` (
  `calendar_id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` int(10) UNSIGNED NOT NULL DEFAULT '0',
  `name` varchar(255) NOT NULL,
  `color` varchar(8) NOT NULL,
  `showalarms` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY(`calendar_id`),
  INDEX `user_name_idx` (`user_id`, `name`),
  CONSTRAINT `fk_calendars_user_id` FOREIGN KEY (`user_id`)
    REFERENCES `users`(`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) /*!40000 ENGINE=INNODB */ /*!40101 CHARACTER SET utf8 COLLATE utf8_general_ci */;

CREATE TABLE IF NOT EXISTS `events` (
  `event_id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `calendar_id` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `recurrence_id` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `uid` varchar(255) NOT NULL DEFAULT '',
  `instance` varchar(16) NOT NULL DEFAULT '',
  `isexception` tinyint(1) NOT NULL DEFAULT '0',
  `created` datetime NOT NULL DEFAULT '1000-01-01 00:00:00',
  `changed` datetime NOT NULL DEFAULT '1000-01-01 00:00:00',
  `sequence` int(1) UNSIGNED NOT NULL DEFAULT '0',
  `start` datetime NOT NULL DEFAULT '1000-01-01 00:00:00',
  `end` datetime NOT NULL DEFAULT '1000-01-01 00:00:00',
  `recurrence` varchar(255) DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `location` varchar(255) NOT NULL DEFAULT '',
  `categories` varchar(255) NOT NULL DEFAULT '',
  `url` varchar(255) NOT NULL DEFAULT '',
  `all_day` tinyint(1) NOT NULL DEFAULT '0',
  `free_busy` tinyint(1) NOT NULL DEFAULT '0',
  `priority` tinyint(1) NOT NULL DEFAULT '0',
  `sensitivity` tinyint(1) NOT NULL DEFAULT '0',
  `status` varchar(32) NOT NULL DEFAULT '',
  `alarms` text DEFAULT NULL,
  `attendees` text DEFAULT NULL,
  `notifyat` datetime DEFAULT NULL,
  PRIMARY KEY(`event_id`),
  INDEX `uid_idx` (`uid`),
  INDEX `recurrence_idx` (`recurrence_id`),
  INDEX `calendar_notify_idx` (`calendar_id`,`notifyat`),
  CONSTRAINT `fk_events_calendar_id` FOREIGN KEY (`calendar_id`)
    REFERENCES `calendars`(`calendar_id`) ON DELETE CASCADE ON UPDATE CASCADE
) /*!40000 ENGINE=INNODB */ /*!40101 CHARACTER SET utf8 COLLATE utf8_general_ci */;

CREATE TABLE IF NOT EXISTS `attachments` (
  `attachment_id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `event_id` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `filename` varchar(255) NOT NULL DEFAULT '',
  `mimetype` varchar(255) NOT NULL DEFAULT '',
  `size` int(11) NOT NULL DEFAULT '0',
  `data` longtext NOT NULL,
  PRIMARY KEY(`attachment_id`),
  CONSTRAINT `fk_attachments_event_id` FOREIGN KEY (`event_id`)
    REFERENCES `events`(`event_id`) ON DELETE CASCADE ON UPDATE CASCADE
) /*!40000 ENGINE=INNODB */ /*!40101 CHARACTER SET utf8 COLLATE utf8_general_ci */;

CREATE TABLE IF NOT EXISTS `itipinvitations` (
  `token` VARCHAR(64) NOT NULL,
  `event_uid` VARCHAR(255) NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL DEFAULT '0',
  `event` TEXT NOT NULL,
  `expires` DATETIME DEFAULT NULL,
  `cancelled` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
  PRIMARY KEY(`token`),
  INDEX `uid_idx` (`user_id`,`event_uid`),
  CONSTRAINT `fk_itipinvitations_user_id` FOREIGN KEY (`user_id`)
    REFERENCES `users`(`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) /*!40000 ENGINE=INNODB */ /*!40101 CHARACTER SET utf8 COLLATE utf8_general_ci */;

REPLACE INTO system (name, value) VALUES ('calendar-database-version', '2015022700');
/**
 * Roundcube Tasklist plugin database
 *
 * @version @package_version@
 * @author Thomas Bruederli
 * @licence GNU AGPL
 * @copyright (C) 2012, Kolab Systems AG
 */

CREATE TABLE IF NOT EXISTS `tasklists` (
  `tasklist_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) unsigned NOT NULL,
  `name` varchar(255) NOT NULL,
  `color` varchar(8) NOT NULL,
  `showalarms` tinyint(2) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`tasklist_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `fk_tasklist_user_id` FOREIGN KEY (`user_id`)
    REFERENCES `users`(`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) /*!40000 ENGINE=InnoDB CHARACTER SET utf8 COLLATE utf8_general_ci */;

CREATE TABLE IF NOT EXISTS `tasks` (
  `task_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `tasklist_id` int(10) unsigned NOT NULL,
  `parent_id` int(10) unsigned DEFAULT NULL,
  `uid` varchar(255) NOT NULL,
  `created` datetime NOT NULL,
  `changed` datetime NOT NULL,
  `del` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `title` varchar(255) NOT NULL,
  `description` text,
  `tags` text,
  `date` varchar(10) DEFAULT NULL,
  `time` varchar(5) DEFAULT NULL,
  `startdate` varchar(10) DEFAULT NULL,
  `starttime` varchar(5) DEFAULT NULL,
  `flagged` tinyint(4) NOT NULL DEFAULT '0',
  `complete` float NOT NULL DEFAULT '0',
  `status` enum('','NEEDS-ACTION','IN-PROCESS','COMPLETED','CANCELLED') NOT NULL DEFAULT '',
  `alarms` varchar(255) DEFAULT NULL,
  `recurrence` varchar(255) DEFAULT NULL,
  `organizer` varchar(255) DEFAULT NULL,
  `attendees` text,
  `notify` datetime DEFAULT NULL,
  PRIMARY KEY (`task_id`),
  KEY `tasklisting` (`tasklist_id`,`del`,`date`),
  KEY `uid` (`uid`),
  CONSTRAINT `fk_tasks_tasklist_id` FOREIGN KEY (`tasklist_id`)
    REFERENCES `tasklists`(`tasklist_id`) ON DELETE CASCADE ON UPDATE CASCADE
) /*!40000 ENGINE=InnoDB CHARACTER SET utf8 COLLATE utf8_general_ci */;

REPLACE INTO `system` (`name`, `value`) VALUES ('tasklist-database-version', '2014051900');
CREATE TABLE `auth_tokens` (
    `token` varchar(128) NOT NULL,
    `expires` datetime NOT NULL,
    `user_id` int(10) unsigned NOT NULL,
    `user_name` varchar(128) NOT NULL,
    `user_pass` varchar(128) NOT NULL,
    KEY `user_id_fk_auth_tokens` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

ALTER TABLE `auth_tokens`
    ADD CONSTRAINT `auth_tokens_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Update Version 2.0
--

ALTER TABLE `auth_tokens`
    ADD `host` varchar(255) NOT NULL;

--
-- Update Version 5.1.0
-- Issue #36
--

ALTER TABLE `auth_tokens`
    ADD PRIMARY KEY(`token`);