vim.g.dbs = {
  {name = 'hv_proxy_3',  url = 'postgres://postgres:@localhost:60003/hv_proxy'},
  {name = 'hv_part01_3', url = 'postgres://postgres:@localhost:60003/hv_part01'},
  {name = 'hv_part02_3', url = 'postgres://postgres:@localhost:60003/hv_part02'},
}

local sql_with_parameters = [[
parameters AS (
  SELECT p.specific_name, string_agg(p.param_str, E'\n') params_str
  FROM (
    SELECT p.specific_name
      , format('  %s %s %s.%s %s'
        , p.parameter_mode, p.parameter_name, p.udt_schema, p.udt_name
        , CASE WHEN p.parameter_default IS NOT NULL
            THEN '= ' || p.parameter_default
            ELSE ''
          END
      ) param_str
    FROM (
      SELECT * FROM information_schema.parameters p ORDER BY p.ordinal_position
    ) p
  ) p
  GROUP BY p.specific_name
)
]]

local sql_with_triggers = [[
triggers AS (
/* Bits within tgtype
#define TRIGGER_TYPE_Row         (1 << 0)
#define TRIGGER_TYPE_Before      (1 << 1)
#define TRIGGER_TYPE_Insert      (1 << 2)
#define TRIGGER_TYPE_Delete      (1 << 3)
#define TRIGGER_TYPE_Update      (1 << 4)
#define TRIGGER_TYPE_Truncate    (1 << 5)
#define TRIGGER_TYPE_iNstead     (1 << 6)

#define TRIGGER_TYPE_LEVEL_MASK  (TRIGGER_TYPE_ROW)
#define TRIGGER_TYPE_STATEMENT   0
*/
  SELECT trig.tgfoid, t.traceable_table, format(
'  %s  
  %s  '
      , trig.tgtype::bigint::bit(7)
      , 'NTUDIBR'
    ) trigger_type, format('%s ::%s', col.attname, col_type.name) traceable_column, trig.tgtype
    FROM pg_trigger trig
      INNER JOIN (
        SELECT t.oid, format('%s.%s', ns.nspname, t.relname) traceable_table
          FROM pg_class t
            INNER JOIN pg_namespace ns ON ns.oid=t.relnamespace
      ) t ON t.oid=trig.tgrelid
      LEFT OUTER JOIN pg_attribute col ON t.oid=col.attrelid AND trig.tgattr::text=col.attnum::text
      LEFT OUTER JOIN (
        SELECT col_type.oid, format('%s.%s', ns.nspname, col_type.typname) name
          FROM pg_type col_type
            INNER JOIN pg_namespace ns ON ns.oid=col_type.typnamespace
      ) col_type ON col_type.oid=col.atttypid
)
]]

local sql_with_block = 'WITH ' .. sql_with_parameters .. ', ' .. sql_with_triggers

local sql_format_body = [[
format(
'%s.%s(
%s
)
RETURNS %s
AS $$
%s
$$ LANGUAGE %s;

// ---------------END---------------
'
, r.specific_schema
, r.routine_name
, p.params_str
, r.data_type
, replace(r.routine_definition, E'\r', '')
, r.external_language
) definition
]]

local sql_format_signature = [[
format(
'%s.%s(
%s
) %s ;
// ---------------END---------------
'
, r.specific_schema
, r.routine_name
, p.params_str
, r.external_language
) definition
]]

local sql_func_bodies = sql_with_block .. [[
, func_def AS (
SELECT
    trig.traceable_table, trig.traceable_column, trig.trigger_type,
]] .. sql_format_body .. [[
  FROM information_schema.routines r
    INNER JOIN pg_proc proc ON proc.proname=r.routine_name
    LEFT OUTER JOIN triggers trig ON trig.tgfoid=proc.oid
    LEFT OUTER JOIN parameters p ON r.specific_name=p.specific_name
  WHERE (
    r.specific_schema='{schema}'
  )
  ORDER BY r.specific_schema, r.routine_name
)
SELECT DISTINCT * FROM func_def
;
]]

local sql_func_signatures = sql_with_block .. [[
, func_def AS (
SELECT
    trig.traceable_table, trig.traceable_column, trig.trigger_type,
]] .. sql_format_signature .. [[
  FROM information_schema.routines r
    INNER JOIN pg_proc proc ON proc.proname=r.routine_name
    LEFT OUTER JOIN triggers trig ON trig.tgfoid=proc.oid
    LEFT OUTER JOIN parameters p ON r.specific_name=p.specific_name
  WHERE (
    r.specific_schema='{schema}'
  )
  ORDER BY r.specific_schema, r.routine_name
)
SELECT DISTINCT * FROM func_def
;
]]

local sql_trig_select = sql_with_block .. [[
, func_def AS (
SELECT
    trig.traceable_table, trig.traceable_column, trig.trigger_type,
]]

local sql_trig_join = [[
  FROM information_schema.routines r
    INNER JOIN pg_proc proc ON proc.proname=r.routine_name
    LEFT OUTER JOIN triggers trig ON trig.tgfoid=proc.oid
    LEFT OUTER JOIN parameters p ON r.specific_name=p.specific_name
  WHERE (
    trig.traceable_table='{schema}.{table}'
  )
  ORDER BY r.specific_schema, r.routine_name
  )
  SELECT DISTINCT * FROM func_def
;
]]

local sql_trig_bodies = sql_trig_select .. sql_format_body .. sql_trig_join
local sql_trig_signatures = sql_trig_select .. sql_format_signature .. sql_trig_join

local sql_FK = [[
SELECT DISTINCT
    tc.constraint_name
  , tc.table_schema
  , tc.table_name
  , kcu.column_name
  , ccu.table_schema AS foreign_table_schema
  , ccu.table_name AS foreign_table_name
  , ccu.column_name AS foreign_column_name
  , rc.update_rule
  , rc.delete_rule
  FROM
       information_schema.table_constraints AS tc
       JOIN information_schema.key_column_usage AS kcu
         ON tc.constraint_name = kcu.constraint_name
       JOIN information_schema.referential_constraints AS rc
         ON tc.constraint_name = rc.constraint_name
       JOIN information_schema.constraint_column_usage AS ccu
         ON ccu.constraint_name = tc.constraint_name
  WHERE constraint_type = 'FOREIGN KEY'
  AND tc.table_name = '{table}'
  AND tc.table_schema = '{schema}'
;
]]

local sql_Columns = [[
SELECT
    obj_description(format('%s.%s', table_schema, table_name)::regclass)
  , col_description(
      format('%s.%s', table_schema, table_name)::regclass, ordinal_position::int
    )
  , *
  FROM information_schema.columns
  WHERE table_name='{table}' AND table_schema='{schema}'
;
]]

local sql_Types = [[
SELECT
    n.nspname AS schema
  , t.typname AS type
  , a.attname
  , n1.nspname AS field_schema
  , t1.typname AS field_type
  FROM pg_type t
    LEFT JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
    LEFT JOIN pg_attribute a ON a.attrelid = t.typrelid
    LEFT JOIN pg_type t1 ON a.atttypid = t1.oid
    LEFT JOIN pg_catalog.pg_namespace n1 ON n1.oid = t1.typnamespace
  WHERE (
      t.typrelid = 0 OR (
        SELECT c.relkind = 'c'
          FROM pg_catalog.pg_class c
          WHERE c.oid = t.typrelid
          LIMIT 1
      )
    )
    AND NOT EXISTS(
      SELECT 1
        FROM pg_catalog.pg_type el
        WHERE el.oid = t.typelem
          AND el.typarray = t.oid
        LIMIT 1
    )
    AND n.nspname='{schema}'
  ORDER BY schema, type, a.attnum
;
]]

vim.g.db_ui_table_helpers = {
  postgres = {
    My_Ls_Function_bodies = sql_func_bodies
  , My_Ls_Function_signatures = sql_func_signatures
  , My_Ls_Triggers_bodies = sql_trig_bodies
  , My_Ls_Triggers_signatures = sql_trig_signatures
  , My_Ls_Types = sql_Types
  , My_Foreign_Keys = sql_FK
  , My_Columns = sql_Columns
  }
}
