-- Copyright (c) 2013-2015 Snowplow Analytics Ltd. All rights reserved.
--
-- This program is licensed to you under the Apache License Version 2.0,
-- and you may not use this file except in compliance with the Apache License Version 2.0.
-- You may obtain a copy of the Apache License Version 2.0 at http://www.apache.org/licenses/LICENSE-2.0.
--
-- Unless required by applicable law or agreed to in writing,
-- software distributed under the Apache License Version 2.0 is distributed on an
-- "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the Apache License Version 2.0 for the specific language governing permissions and limitations there under.
--
-- Authors: Yali Sassoon, Christophe Bogaert
-- Copyright: Copyright (c) 2013-2015 Snowplow Analytics Ltd
-- License: Apache License Version 2.0

-- The sessions_basic table has one line per session (in this batch) and contains
-- basic information that can be derived from a single table scan.

-- The standard model identifies sessions using only first party cookies and session domain indexes.

DROP TABLE IF EXISTS snowplow_intermediary.sessions_basic;
CREATE TABLE snowplow_intermediary.sessions_basic
  DISTKEY (domain_userid) -- Optimized to join on other session_intermediary.session_X tables
  SORTKEY (domain_userid, domain_sessionidx) -- Optimized to join on other session_intermediary.session_X tables
  AS (
    SELECT
      blended_user_id, -- One row per domain_userid, so no problem with GROUP BY
      inferred_user_id, -- At most one per domain_userid, so no problem with GROUP BY
      domain_userid,
      domain_sessionidx,
      MAX(etl_tstamp) AS etl_tstamp, -- Included for debugging
      MIN(collector_tstamp) AS session_start_tstamp,
      MAX(collector_tstamp) AS session_end_tstamp,
      COUNT(*) AS event_count,
      COUNT(DISTINCT(FLOOR(EXTRACT (EPOCH FROM collector_tstamp)/30)))/2::FLOAT AS time_engaged_with_minutes
    FROM
      snowplow_intermediary.events_enriched_final
    GROUP BY 1,2,3,4
  );
