-- *** STRUCTURE: `tbl_authors` ***
DROP TABLE IF EXISTS `tbl_authors_user_type_enum`;
CREATE TABLE IF NOT EXISTS `tbl_authors_user_type_enum` (
    user_type TEXT
);
INSERT INTO tbl_authors_user_type_enum(user_type) VALUES('author'), ('manager'), ('developer');

DROP TABLE IF EXISTS `tbl_authors_primary_enum`;
CREATE TABLE IF NOT EXISTS `tbl_authors_primary_enum` (
    `primary` TEXT
);
INSERT INTO tbl_authors_primary_enum(`primary`) VALUES('yes'), ('no');

DROP TABLE IF EXISTS `tbl_authors_auth_token_active_enum`;
CREATE TABLE IF NOT EXISTS `tbl_authors_auth_token_active_enum` (
    `auth_token_active` TEXT
);
INSERT INTO tbl_authors_auth_token_active_enum(auth_token_active) VALUES('yes'), ('no');

DROP TABLE IF EXISTS `tbl_authors`;
CREATE TABLE IF NOT EXISTS `tbl_authors` (
  `id` INTEGER PRIMARY KEY,
  `username` TEXT NOT NULL UNIQUE ON CONFLICT IGNORE,
  `password` TEXT NOT NULL,
  `first_name` TEXT DEFAULT NULL,
  `last_name` TEXT DEFAULT NULL,
  `email` TEXT DEFAULT NULL,
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
CREATE TABLE IF NOT EXISTS `tbl_cache` (
  `id` INTEGER PRIMARY KEY,
  `hash` TEXT NOT NULL UNIQUE,
  `namespace` TEXT DEFAULT NULL,
  `creation` INTEGER NOT NULL DEFAULT '0',
  `expiry` INTEGER unsigned DEFAULT NULL,
  `data` TEXT NOT NULL
);

-- *** STRUCTURE: `tbl_entries` ***
DROP TABLE IF EXISTS `tbl_entries`;
CREATE TABLE IF NOT EXISTS `tbl_entries` (
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
CREATE TABLE IF NOT EXISTS `tbl_extensions_status_enum` (
    `status` TEXT
);
INSERT INTO tbl_extensions_status_enum(`status`) VALUES('enabled'), ('disabled');

DROP TABLE IF EXISTS `tbl_extensions`;
CREATE TABLE IF NOT EXISTS `tbl_extensions` (
  `id` INTEGER PRIMARY KEY,
  `name` TEXT NOT NULL DEFAULT '',
  `status` TEXT NOT NULL DEFAULT 'enabled',
  `version` TEXT NOT NULL,
  FOREIGN KEY(`status`) REFERENCES tbl_extensions_status_enum(`status`)
);

-- *** STRUCTURE: `tbl_extensions_delegates` ***
DROP TABLE IF EXISTS `tbl_extensions_delegates`;
CREATE TABLE IF NOT EXISTS `tbl_extensions_delegates` (
  `id` INTEGER PRIMARY KEY,
  `extension_id` INTEGER NOT NULL,
  `page` TEXT NOT NULL,
  `delegate` TEXT NOT NULL,
  `callback` TEXT NOT NULL
);

-- *** STRUCTURE: `tbl_fields` ***
DROP TABLE IF EXISTS `tbl_fields_required_enum`;
CREATE TABLE IF NOT EXISTS `tbl_fields_required_enum` (
    `required` TEXT
);
INSERT INTO tbl_fields_required_enum(`required`) VALUES('yes'), ('no');

DROP TABLE IF EXISTS `tbl_fields_location_enum`;
CREATE TABLE IF NOT EXISTS `tbl_fields_location_enum` (
    `location` TEXT
);
INSERT INTO tbl_fields_location_enum(`location`) VALUES('main'), ('sidebar');

DROP TABLE IF EXISTS `tbl_fields_show_column_enum`;
CREATE TABLE IF NOT EXISTS `tbl_fields_show_column_enum` (
    `show_column` TEXT
);
INSERT INTO tbl_fields_show_column_enum(`show_column`) VALUES('yes'), ('no');

DROP TABLE IF EXISTS `tbl_fields`;
CREATE TABLE IF NOT EXISTS `tbl_fields` (
  `id` INTEGER PRIMARY KEY,
  `label` TEXT NOT NULL,
  `element_name` TEXT NOT NULL,
  `type` TEXT NOT NULL,
  `parent_section` TEXT NOT NULL DEFAULT '0',
  `required` TEXT NOT NULL DEFAULT 'yes',
  `sortorder` INTEGER NOT NULL DEFAULT '1',
  `location` TEXT NOT NULL DEFAULT 'main',
  `show_column` TEXT NOT NULL DEFAULT 'no',
  FOREIGN KEY(`required`) REFERENCES tbl_fields_required_enum(`required`),
  FOREIGN KEY(`location`) REFERENCES tbl_fields_location_enum(`location`),
  FOREIGN KEY(`show_column`) REFERENCES tbl_fields_show_column_enum(`show_column`)
);

-- *** STRUCTURE: `tbl_fields_author` ***
DROP TABLE IF EXISTS `tbl_fields_author`;
CREATE TABLE IF NOT EXISTS `tbl_fields_author` (
  `id` INTEGER PRIMARY KEY,
  `field_id` INTEGER NOT NULL UNIQUE,
  `allow_multiple_selection` TEXT NOT NULL DEFAULT 'no',
  `default_to_current_user` TEXT NOT NULL,
  `author_types` TEXT DEFAULT NULL,
  FOREIGN KEY(`allow_multiple_selection`) REFERENCES tbl_fields_required_enum(`required`),
  FOREIGN KEY(`default_to_current_user`) REFERENCES tbl_fields_required_enum(`required`)
);

-- *** STRUCTURE: `tbl_fields_checkbox` ***
DROP TABLE IF EXISTS `tbl_fields_checkbox_default_state_enum`;
CREATE TABLE IF NOT EXISTS `tbl_fields_checkbox_default_state_enum` (
    `default_state` TEXT
);
INSERT INTO tbl_fields_checkbox_default_state_enum(`default_state`) VALUES('on'), ('off');

DROP TABLE IF EXISTS `tbl_fields_checkbox`;
CREATE TABLE IF NOT EXISTS `tbl_fields_checkbox` (
  `id` INTEGER PRIMARY KEY,
  `field_id` INTEGER NOT NULL,
  `default_state` TEXT NOT NULL DEFAULT 'on',
  `description` TEXT DEFAULT NULL,
  FOREIGN KEY(`default_state`) REFERENCES tbl_fields_checkbox_default_state_enum(`default_state`)
);

-- *** STRUCTURE: `tbl_fields_date` ***
DROP TABLE IF EXISTS `tbl_fields_date`;
CREATE TABLE IF NOT EXISTS `tbl_fields_date` (
  `id` INTEGER PRIMARY KEY,
  `field_id` INTEGER NOT NULL,
  `pre_populate` TEXT DEFAULT NULL,
  `calendar` TEXT NOT NULL DEFAULT 'no',
  `time` TEXT NOT NULL DEFAULT 'yes',
  FOREIGN KEY(`calendar`) REFERENCES tbl_fields_required_enum(`required`),
  FOREIGN KEY(`time`) REFERENCES tbl_fields_required_enum(`required`)
);

-- *** STRUCTURE: `tbl_fields_input` ***
DROP TABLE IF EXISTS `tbl_fields_input`;
CREATE TABLE IF NOT EXISTS `tbl_fields_input` (
  `id` INTEGER PRIMARY KEY,
  `field_id` INTEGER unsigned NOT NULL,
  `validator` TET DEFAULT NULL
);

-- *** STRUCTURE: `tbl_fields_select` ***
DROP TABLE IF EXISTS `tbl_fields_select`;
CREATE TABLE IF NOT EXISTS `tbl_fields_select` (
  `id` INTEGER PRIMARY KEY,
  `field_id` INTEGER unsigned NOT NULL,
  `allow_multiple_selection` TEXT NOT NULL DEFAULT 'no',
  `sort_options` TEXT NOT NULL DEFAULT 'no',
  `static_options` TEXT,
  `dynamic_options` INTEGER DEFAULT NULL,
  FOREIGN KEY(`allow_multiple_selection`) REFERENCES tbl_fields_required_enum(`required`),
  FOREIGN KEY(`sort_options`) REFERENCES tbl_fields_required_enum(`required`)
);

-- *** STRUCTURE: `tbl_fields_taglist` ***
DROP TABLE IF EXISTS `tbl_fields_taglist`;
CREATE TABLE IF NOT EXISTS `tbl_fields_taglist` (
  `id` INTEGER PRIMARY KEY,
  `field_id` INTEGER NOT NULL,
  `validator` TEXT DEFAULT NULL,
  `pre_populate_source` TEXT DEFAULT NULL
);

-- *** STRUCTURE: `tbl_fields_textarea` ***
DROP TABLE IF EXISTS `tbl_fields_textarea`;
CREATE TABLE IF NOT EXISTS `tbl_fields_textarea` (
  `id` INTEGER PRIMARY KEY,
  `field_id` INTEGER unsigned NOT NULL,
  `formatter` TEXT DEFAULT NULL,
  `size` INTEGER NOT NULL
);

-- *** STRUCTURE: `tbl_fields_upload` ***
DROP TABLE IF EXISTS `tbl_fields_upload`;
CREATE TABLE IF NOT EXISTS `tbl_fields_upload` (
  `id` INTEGER PRIMARY KEY,
  `field_id` INTEGER NOT NULL,
  `destination` TEXT NOT NULL,
  `validator` TEXT DEFAULT NULL
);

-- *** STRUCTURE: `tbl_forgotpass` ***
DROP TABLE IF EXISTS `tbl_forgotpass`;
CREATE TABLE IF NOT EXISTS `tbl_forgotpass` (
  `author_id` INTEGER NOT NULL DEFAULT '0' PRIMARY KEY,
  `token` varchar(16) NOT NULL,
  `expiry` varchar(25) NOT NULL
);

-- *** STRUCTURE: `tbl_pages` ***
DROP TABLE IF EXISTS `tbl_pages`;
CREATE TABLE IF NOT EXISTS `tbl_pages` (
  `id` INTEGER PRIMARY KEY,
  `parent` INTEGER DEFAULT NULL,
  `title` TEXT NOT NULL DEFAULT '',
  `handle` TEXT DEFAULT NULL,
  `path` TEXT DEFAULT NULL,
  `params` TEXT DEFAULT NULL,
  `data_sources` text,
  `events` text,
  `sortorder` INTEGER NOT NULL DEFAULT '0'
);

-- *** STRUCTURE: `tbl_pages_types` ***
DROP TABLE IF EXISTS `tbl_pages_types`;
CREATE TABLE IF NOT EXISTS `tbl_pages_types` (
  `id` INTEGER PRIMARY KEY,
  `page_id` INTEGER unsigned NOT NULL,
  `type` varchar(50) NOT NULL
);

-- *** STRUCTURE: `tbl_sections` ***
DROP TABLE IF EXISTS `tbl_sections`;
CREATE TABLE IF NOT EXISTS `tbl_sections` (
  `id` INTEGER PRIMARY KEY,
  `name` TEXT NOT NULL DEFAULT '',
  `handle` TEXT NOT NULL UNIQUE,
  `sortorder` INTEGER NOT NULL DEFAULT '0',
  `hidden` TEXT NOT NULL DEFAULT 'no',
  `filter` TEXT NOT NULL DEFAULT 'yes',
  `navigation_group` TEXT NOT NULL DEFAULT 'Content',
  FOREIGN KEY(`hidden`) REFERENCES tbl_fields_required_enum(`required`),
  FOREIGN KEY(`filter`) REFERENCES tbl_fields_required_enum(`required`)
);

-- *** STRUCTURE: `tbl_sections_association` ***
DROP TABLE IF EXISTS `tbl_sections_association`;
CREATE TABLE IF NOT EXISTS `tbl_sections_association` (
  `id` INTEGER PRIMARY KEY,
  `parent_section_id` INTEGER unsigned NOT NULL,
  `parent_section_field_id` INTEGER unsigned DEFAULT NULL,
  `child_section_id` INTEGER unsigned NOT NULL,
  `child_section_field_id` INTEGER unsigned NOT NULL,
  `hide_association` TEXT NOT NULL DEFAULT 'no',
  `interface` TEXT DEFAULT NULL,
  `editor` TEXT DEFAULT NULL,
  FOREIGN KEY(`hide_association`) REFERENCES tbl_fields_required_enum(`required`)
);

-- *** STRUCTURE: `tbl_sessions` ***
DROP TABLE IF EXISTS `tbl_sessions`;
CREATE TABLE IF NOT EXISTS `tbl_sessions` (
  `session` TEXT NOT NULL PRIMARY KEY,
  `session_expires` INTEGER unsigned NOT NULL DEFAULT '0',
  `session_data` text
);
