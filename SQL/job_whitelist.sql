-- Apply your configured feedback table prefix to `job_whitelist` if your server uses one.
CREATE TABLE IF NOT EXISTS `job_whitelist` (
  `ckey` varchar(32) NOT NULL,
  `whitelist_id` varchar(64) NOT NULL,
  `granted_by_ckey` varchar(32) NOT NULL,
  `granted_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ckey`, `whitelist_id`),
  KEY `idx_job_whitelist_id` (`whitelist_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
