-- *** STRUCTURE: `tbl_authors` ***
/*Add enum replacement for sqlite*/
DROP TABLE IF EXISTS `tbl_authors_user_type_enum`;
CREATE TABLE `tbl_authors_user_type_enum` (
    user_type TEXT
);
INSERT INTO tbl_authors_user_type_enum(user_type) VALUES('author'), ('manager'), ('developer');

DROP TABLE IF EXISTS `tbl_authors_primary_enum`;
CREATE TABLE `tbl_authors_primary_enum` (
    `primary` TEXT
);
INSERT INTO tbl_authors_primary_enum(`primary`) VALUES('yes'), ('no');

DROP TABLE IF EXISTS `tbl_authors_auth_token_active_enum`;
CREATE TABLE `tbl_authors_auth_token_active_enum` (
    `auth_token_active` TEXT
);
INSERT INTO tbl_authors_auth_token_active_enum(auth_token_active) VALUES('yes'), ('no');

DROP TABLE IF EXISTS `tbl_authors`;
CREATE TABLE `tbl_authors` (
  `id` INTEGER PRIMARY KEY,
  `username` TEXT NOT NULL DEFAULT '' UNIQUE,
  `password` TEXT NOT NULL,
  `first_name` TEXT DEFAULT NULL,
  `last_name` TEXT DEFAULT NULL,
  `email` TEXT DEFAULT NULL UNIQUE,
  `last_seen` TEXT DEFAULT '0000-00-00 00:00:00',
  `user_type` TEXT NOT NULL DEFAULT 'author',
  `primary` TEXT NOT NULL DEFAULT 'no',
  `default_area` TEXT DEFAULT NULL,
  `auth_token_active` TEXT NOT NULL DEFAULT 'no',
  `language` TEXT DEFAULT NULL,
  FOREIGN KEY(`user_type`) REFERENCES tbl_authors_user_type_enum(`user_type`),
  FOREIGN KEY(`primary`) REFERENCES tbl_authors_primary_enum(`primary`),
  FOREIGN KEY(`auth_token_active`) REFERENCES tbl_authors_auth_token_active_enum(`auth_token_active`)
);

-- *** STRUCTURE: `tbl_cache` ***
DROP TABLE IF EXISTS `tbl_cache`;
CREATE TABLE `tbl_cache` (
  `id` INTEGER PRIMARY KEY,
  `hash` TEXT NOT NULL DEFAULT '' UNIQUE,
  `namespace` TEXT DEFAULT NULL,
  `creation` INTEGER NOT NULL DEFAULT '0',
  `expiry` INTEGER unsigned DEFAULT NULL,
  `data` TEXT NOT NULL
);

-- *** STRUCTURE: `tbl_entries` ***
DROP TABLE IF EXISTS `tbl_entries`;
CREATE TABLE `tbl_entries` (
  `id` INTEGER PRIMARY KEY,
  `section_id` INTEGER unsigned NOT NULL,
  `author_id` INTEGER unsigned NOT NULL,
  `creation_date` TEXT NOT NULL,
  `creation_date_gmt` TEXT NOT NULL,
  `modification_date` TEXT NOT NULL,
  `modification_date_gmt` TEXT NOT NULL
);

-- *** STRUCTURE: `tbl_extensions` ***
DROP TABLE IF EXISTS `tbl_extensions_status_enum`;
CREATE TABLE `tbl_extensions_status_enum` (
    `status` TEXT
);
INSERT INTO tbl_extensions_status_enum(`status`) VALUES('enabled'), ('disabled');

DROP TABLE IF EXISTS `tbl_extensions`;
CREATE TABLE `tbl_extensions` (
  `id` INTEGER PRIMARY KEY,
  `name` TEXT NOT NULL DEFAULT '',
  `status` TEXT NOT NULL DEFAULT 'enabled',
  `version` TEXT NOT NULL,
  FOREIGN KEY(`status`) REFERENCES tbl_extensions_status_enum(`status`)
);

-- *** STRUCTURE: `tbl_extensions_delegates` ***
DROP TABLE IF EXISTS `tbl_extensions_delegates`;
CREATE TABLE `tbl_extensions_delegates` (
  `id` INTEGER PRIMARY KEY,
  `extension_id` INTEGER NOT NULL,
  `page` TEXT NOT NULL,
  `delegate` TEXT NOT NULL,
  `callback` TEXT NOT NULL
);

-- *** STRUCTURE: `tbl_fields` ***
DROP TABLE IF EXISTS `tbl_fields`;
CREATE TABLE `tbl_fields` (
  `id` INTEGER PRIMARY KEY,
  `label` varchar(255) NOT NULL,
  `element_name` varchar(50) NOT NULL,
  `type` TEXT NOT NULL,
  `parent_section` int(11) NOT NULL DEFAULT '0',
  `required` enum('yes','no') NOT NULL DEFAULT 'yes',
  `sortorder` int(11) NOT NULL DEFAULT '1',
  `location` enum('main','sidebar') NOT NULL DEFAULT 'main',
  `show_column` enum('yes','no') NOT NULL DEFAULT 'no',
  PRIMARY KEY (`id`),
  KEY `index` (`element_name`,`type`,`parent_section`)
);

-- *** STRUCTURE: `tbl_fields_author` ***
DROP TABLE IF EXISTS `tbl_fields_author`;
CREATE TABLE `tbl_fields_author` (
  `id` INTEGER PRIMARY KEY,
  `field_id` int(11) unsigned NOT NULL,
  `allow_multiple_selection` enum('yes','no') NOT NULL DEFAULT 'no',
  `default_to_current_user` enum('yes','no') NOT NULL,
  `author_types` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `field_id` (`field_id`)
);

-- *** STRUCTURE: `tbl_fields_checkbox` ***
DROP TABLE IF EXISTS `tbl_fields_checkbox`;
CREATE TABLE `tbl_fields_checkbox` (
  `id` INTEGER PRIMARY KEY,
  `field_id` int(11) unsigned NOT NULL,
  `default_state` enum('on','off') NOT NULL DEFAULT 'on',
  `description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `field_id` (`field_id`)
);

-- *** STRUCTURE: `tbl_fields_date` ***
DROP TABLE IF EXISTS `tbl_fields_date`;
CREATE TABLE `tbl_fields_date` (
  `id` INTEGER PRIMARY KEY,
  `field_id` int(11) unsigned NOT NULL,
  `pre_populate` varchar(80) DEFAULT NULL,
  `calendar` enum('yes','no') NOT NULL DEFAULT 'no',
  `time` enum('yes','no') NOT NULL DEFAULT 'yes',
  PRIMARY KEY (`id`),
  KEY `field_id` (`field_id`)
);

-- *** STRUCTURE: `tbl_fields_input` ***
DROP TABLE IF EXISTS `tbl_fields_input`;
CREATE TABLE `tbl_fields_input` (
  `id` INTEGER PRIMARY KEY,
  `field_id` int(11) unsigned NOT NULL,
  `validator` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `field_id` (`field_id`)
);

-- *** STRUCTURE: `tbl_fields_select` ***
DROP TABLE IF EXISTS `tbl_fields_select`;
CREATE TABLE `tbl_fields_select` (
  `id` INTEGER PRIMARY KEY,
  `field_id` int(11) unsigned NOT NULL,
  `allow_multiple_selection` enum('yes','no') NOT NULL DEFAULT 'no',
  `sort_options` enum('yes','no') NOT NULL DEFAULT 'no',
  `static_options` text COLLATE utf8_unicode_ci,
  `dynamic_options` int(11) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `field_id` (`field_id`)
);

-- *** STRUCTURE: `tbl_fields_taglist` ***
DROP TABLE IF EXISTS `tbl_fields_taglist`;
CREATE TABLE `tbl_fields_taglist` (
  `id` INTEGER PRIMARY KEY,
  `field_id` int(11) unsigned NOT NULL,
  `validator` varchar(255) DEFAULT NULL,
  `pre_populate_source` varchar(15) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `field_id` (`field_id`),
  KEY `pre_populate_source` (`pre_populate_source`)
);

-- *** STRUCTURE: `tbl_fields_textarea` ***
DROP TABLE IF EXISTS `tbl_fields_textarea`;
CREATE TABLE `tbl_fields_textarea` (
  `id` INTEGER PRIMARY KEY,
  `field_id` int(11) unsigned NOT NULL,
  `formatter` varchar(100) DEFAULT NULL,
  `size` int(3) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `field_id` (`field_id`)
);

-- *** STRUCTURE: `tbl_fields_upload` ***
DROP TABLE IF EXISTS `tbl_fields_upload`;
CREATE TABLE `tbl_fields_upload` (
  `id` INTEGER PRIMARY KEY,
  `field_id` int(11) unsigned NOT NULL,
  `destination` varchar(255) NOT NULL,
  `validator` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `field_id` (`field_id`)
);

-- *** STRUCTURE: `tbl_forgotpass` ***
DROP TABLE IF EXISTS `tbl_forgotpass`;
CREATE TABLE `tbl_forgotpass` (
  `author_id` int(11) NOT NULL DEFAULT '0',
  `token` varchar(16) NOT NULL,
  `expiry` varchar(25) NOT NULL,
  PRIMARY KEY (`author_id`)
);

-- *** STRUCTURE: `tbl_pages` ***
DROP TABLE IF EXISTS `tbl_pages`;
CREATE TABLE `tbl_pages` (
  `id` INTEGER PRIMARY KEY,
  `parent` int(11) DEFAULT NULL,
  `title` varchar(255) NOT NULL DEFAULT '',
  `handle` varchar(255) DEFAULT NULL,
  `path` varchar(255) DEFAULT NULL,
  `params` varchar(255) DEFAULT NULL,
  `data_sources` text COLLATE utf8_unicode_ci,
  `events` text COLLATE utf8_unicode_ci,
  `sortorder` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `parent` (`parent`)
);

-- *** STRUCTURE: `tbl_pages_types` ***
DROP TABLE IF EXISTS `tbl_pages_types`;
CREATE TABLE `tbl_pages_types` (
  `id` INTEGER PRIMARY KEY,
  `page_id` int(11) unsigned NOT NULL,
  `type` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `page_id` (`page_id`,`type`)
);

-- *** STRUCTURE: `tbl_sections` ***
DROP TABLE IF EXISTS `tbl_sections`;
CREATE TABLE `tbl_sections` (
  `id` INTEGER PRIMARY KEY,
  `name` varchar(255) NOT NULL DEFAULT '',
  `handle` varchar(255) NOT NULL,
  `sortorder` int(11) NOT NULL DEFAULT '0',
  `hidden` enum('yes','no') NOT NULL DEFAULT 'no',
  `filter` enum('yes','no') NOT NULL DEFAULT 'yes',
  `navigation_group` varchar(255) NOT NULL DEFAULT 'Content',
  PRIMARY KEY (`id`),
  UNIQUE KEY `handle` (`handle`)
);

-- *** STRUCTURE: `tbl_sections_association` ***
DROP TABLE IF EXISTS `tbl_sections_association`;
CREATE TABLE `tbl_sections_association` (
  `id` INTEGER PRIMARY KEY,
  `parent_section_id` int(11) unsigned NOT NULL,
  `parent_section_field_id` int(11) unsigned DEFAULT NULL,
  `child_section_id` int(11) unsigned NOT NULL,
  `child_section_field_id` int(11) unsigned NOT NULL,
  `hide_association` enum('yes','no') NOT NULL DEFAULT 'no',
  `interface` varchar(100) DEFAULT NULL,
  `editor` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `parent_section_id` (`parent_section_id`,`child_section_id`,`child_section_field_id`)
);

-- *** STRUCTURE: `tbl_sessions` ***
DROP TABLE IF EXISTS `tbl_sessions`;
CREATE TABLE `tbl_sessions` (
  `session` varchar(100) NOT NULL,
  `session_expires` int(10) unsigned NOT NULL DEFAULT '0',
  `session_data` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`session`),
  KEY `session_expires` (`session_expires`)
);
