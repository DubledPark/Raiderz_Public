PGDMP         &            
    t            rz_logdb_test    9.6.1    9.6.1 ?    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                       false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                       false            �           1262    16500    rz_logdb_test    DATABASE     �   CREATE DATABASE rz_logdb_test WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'English_United States.1252' LC_CTYPE = 'English_United States.1252';
    DROP DATABASE rz_logdb_test;
             postgres    false            �           1262    16500    rz_logdb_test    COMMENT     �   COMMENT ON DATABASE rz_logdb_test IS 'RZ_LOGDB:
  This DB stores server logs. You can put all logs here from every worlds (at your option).';
                  postgres    false    2218                        2615    2200    public    SCHEMA        CREATE SCHEMA public;
    DROP SCHEMA public;
             postgres    false            �           0    0    SCHEMA public    COMMENT     6   COMMENT ON SCHEMA public IS 'standard public schema';
                  postgres    false    3                        3079    12387    plpgsql 	   EXTENSION     ?   CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;
    DROP EXTENSION plpgsql;
                  false            �           0    0    EXTENSION plpgsql    COMMENT     @   COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';
                       false    1            �           1247    16394    rz_account_status    TYPE     |   CREATE TYPE rz_account_status AS ENUM (
    'ACTIVE',
    'INACTIVE',
    'SUSPENDED',
    'BLOCKED',
    'UNREGISTERED'
);
 $   DROP TYPE public.rz_account_status;
       public       postgres    false    3            �           0    0    TYPE rz_account_status    COMMENT     f  COMMENT ON TYPE rz_account_status IS 'ACTIVE: Account is fine and ready to use.
INACTIVE: Account is waiting for activation (e.g. Confirm by email).
SUSPENDED: Account is invalidated because not been used for a long (Reactivation is required).
BLOCKED: Account is banned for violation against rules.
UNREGISTERED: Account is deleted due to user''s request';
            public       postgres    false    500            �           1247    16406    rz_server_state    TYPE     U   CREATE TYPE rz_server_state AS ENUM (
    'FINE',
    'MAINTENANCE',
    'CLOSED'
);
 "   DROP TYPE public.rz_server_state;
       public       postgres    false    3            �           0    0    TYPE rz_server_state    COMMENT     �   COMMENT ON TYPE rz_server_state IS 'FINE: the server is publicly available.
MAINTENANCE: the server is under maintenance.
CLOSED: the server is shut down and no longer available.';
            public       postgres    false    503            I           1247    16414    rz_server_type    TYPE     q   CREATE TYPE rz_server_type AS ENUM (
    'LoginServer',
    'MasterServer',
    'GameServer',
    'AppServer'
);
 !   DROP TYPE public.rz_server_type;
       public       postgres    false    3            �            1255    16423 #   rz_account_insert(text, text, text)    FUNCTION     w  CREATE FUNCTION rz_account_insert(p_username text, p_password text, p_email text DEFAULT NULL::text, OUT "IS_MADE" boolean, OUT "ACCN_SN" bigint, OUT "CONN_SN" bigint) RETURNS record
    LANGUAGE plpgsql
    AS $$DECLARE
  v_accn_sn bigint;
  c_conn_sn CONSTANT bigint NOT NULL DEFAULT rz_gen_conn_sn();
    
BEGIN
  IF strpos(p_username, ' ') <> 0 THEN
    SELECT FALSE, 0, 0 INTO "IS_MADE", "ACCN_SN", "CONN_SN";
    RETURN;
  END IF;
  
  p_username := lower(p_username);
  
  SELECT accn_sn INTO v_accn_sn FROM rz_account WHERE username = p_username;

  IF FOUND THEN
    SELECT FALSE, v_accn_sn, c_conn_sn INTO "IS_MADE", "ACCN_SN", "CONN_SN";
    RETURN;
  END IF;

  INSERT INTO rz_account (username, password, email) VALUES (p_username, p_password, p_email)
    RETURNING accn_sn INTO v_accn_sn;

  SELECT TRUE, v_accn_sn, c_conn_sn INTO "IS_MADE", "ACCN_SN", "CONN_SN";
END;$$;
 �   DROP FUNCTION public.rz_account_insert(p_username text, p_password text, p_email text, OUT "IS_MADE" boolean, OUT "ACCN_SN" bigint, OUT "CONN_SN" bigint);
       public       postgres    false    3    1            �           0    0 �   FUNCTION rz_account_insert(p_username text, p_password text, p_email text, OUT "IS_MADE" boolean, OUT "ACCN_SN" bigint, OUT "CONN_SN" bigint)    COMMENT     W  COMMENT ON FUNCTION rz_account_insert(p_username text, p_password text, p_email text, OUT "IS_MADE" boolean, OUT "ACCN_SN" bigint, OUT "CONN_SN" bigint) IS 'This function is called when the user''s account was not exist and the LoginServer is configurated to automatically create an account.
You may also want to use this function by your own registration web page.

Inputs are:
  p_username: User ID you wish to register. the ID can''t contain spaces (in such case, set of zero values returned).
  p_password: Plain text password you wish to use.
  p_email: Email address of the user. Leave this NULL if not needed.

Outputs are:
  IS_MADE: If the account is successfully made, then TRUE. but if another account with same username existing, then FALSE.
  ACCN_SN: ACCN_SN of newely made. or existing ACCN_SN when not made.
  CONN_SN: Assigned CONN_SN.';
            public       postgres    false    195            �            1255    16424 "   rz_account_update_reg_date(bigint)    FUNCTION     �   CREATE FUNCTION rz_account_update_reg_date(p_accn_sn bigint) RETURNS void
    LANGUAGE sql
    AS $$UPDATE rz_account
   SET first_char_create_time = CURRENT_TIMESTAMP
 WHERE accn_sn = p_accn_sn
   AND first_char_create_time IS NULL;$$;
 C   DROP FUNCTION public.rz_account_update_reg_date(p_accn_sn bigint);
       public       postgres    false    3            �            1255    16954 :   rz_conn_single_log(bigint, integer, integer, bigint, inet)    FUNCTION     E  CREATE FUNCTION rz_conn_single_log(p_conn_sn bigint, p_server_id integer, p_world_id integer, p_accn_sn bigint, p_conn_ip inet) RETURNS void
    LANGUAGE sql
    AS $$INSERT INTO rz_connect (conn_sn, server_id, world_id, accn_sn, conn_ip)
                VALUES (p_conn_sn, p_server_id, p_world_id, p_accn_sn, p_conn_ip);$$;
 �   DROP FUNCTION public.rz_conn_single_log(p_conn_sn bigint, p_server_id integer, p_world_id integer, p_accn_sn bigint, p_conn_ip inet);
       public       postgres    false    3            �            1255    16425    rz_gen_conn_sn()    FUNCTION     o   CREATE FUNCTION rz_gen_conn_sn() RETURNS bigint
    LANGUAGE sql
    AS $$SELECT nextval('rz_conn_sn_seq');$$;
 '   DROP FUNCTION public.rz_gen_conn_sn();
       public       postgres    false    3            �           0    0    FUNCTION rz_gen_conn_sn()    COMMENT     X   COMMENT ON FUNCTION rz_gen_conn_sn() IS 'See comment on rz_conn_sn_seq for more info.';
            public       postgres    false    197            �            1255    16426    rz_login_get_info(text)    FUNCTION     �  CREATE FUNCTION rz_login_get_info(p_username text, OUT "ACCN_SN" bigint, OUT "PWD" text, OUT "NEW_ACC" boolean, OUT "CONN_SN" bigint, OUT "DEF_WORLD_ID" integer, OUT "DEF_CHAR_SN" bigint, OUT "STATUS" rz_account_status) RETURNS SETOF record
    LANGUAGE sql ROWS 1
    AS $$SELECT accn_sn,
       password,
       (first_char_create_time IS NULL)::boolean,
       rz_gen_conn_sn(),
       def_world_id,
       def_char_sn,
       status
  FROM rz_account
 WHERE username = lower(p_username);$$;
 �   DROP FUNCTION public.rz_login_get_info(p_username text, OUT "ACCN_SN" bigint, OUT "PWD" text, OUT "NEW_ACC" boolean, OUT "CONN_SN" bigint, OUT "DEF_WORLD_ID" integer, OUT "DEF_CHAR_SN" bigint, OUT "STATUS" rz_account_status);
       public       postgres    false    3    500            �           0    0 �   FUNCTION rz_login_get_info(p_username text, OUT "ACCN_SN" bigint, OUT "PWD" text, OUT "NEW_ACC" boolean, OUT "CONN_SN" bigint, OUT "DEF_WORLD_ID" integer, OUT "DEF_CHAR_SN" bigint, OUT "STATUS" rz_account_status)    COMMENT       COMMENT ON FUNCTION rz_login_get_info(p_username text, OUT "ACCN_SN" bigint, OUT "PWD" text, OUT "NEW_ACC" boolean, OUT "CONN_SN" bigint, OUT "DEF_WORLD_ID" integer, OUT "DEF_CHAR_SN" bigint, OUT "STATUS" rz_account_status) IS 'Inputs are:
  p_username: Information with this username will be returned.

Outputs are:
  ACCN_SN: Unique ID number for this account.
  PWD: Password of this account. Compare this value with user''s password input to check the password is correct or not.
  NEW_ACC: If the user never made a character even once, this will return TRUE. otherwise FALSE.
  CONN_SN: Check comment written in rz_conn_sn_seq for more info.
  DEF_WORLD_ID: Default WORLD_ID. You can use this ID for a purpose like automatically select a world by system.
  DEF_CHAR_SN: Default CHAR_SN. CHAR_SN differs between worlds. So this parameter should be used with DEF_WORLD_ID together.
  STATUS: Account status. See a comment on rz_account_status for more info.

If the account is found, return a row. Otherwise, no rows returned.';
            public       postgres    false    199            �            1255    16427 +   rz_server_get_status_info(integer, integer)    FUNCTION     �  CREATE FUNCTION rz_server_get_status_info(p_world_id integer, p_server_id integer, OUT "IS_RUN" boolean, OUT "SERVABLE" boolean) RETURNS SETOF record
    LANGUAGE sql STABLE ROWS 1
    AS $$SELECT ((CURRENT_TIMESTAMP - ss.last_update_time) < s.alive_timeout)::boolean,
       ss.servable
  FROM rz_server        AS s,
       rz_server_status AS ss
 WHERE s.server_id = ss.server_id
   AND s.world_id  = ss.world_id
   AND s.server_id = p_server_id
   AND s.world_id  = p_world_id;$$;
 �   DROP FUNCTION public.rz_server_get_status_info(p_world_id integer, p_server_id integer, OUT "IS_RUN" boolean, OUT "SERVABLE" boolean);
       public       postgres    false    3            �           0    0 y   FUNCTION rz_server_get_status_info(p_world_id integer, p_server_id integer, OUT "IS_RUN" boolean, OUT "SERVABLE" boolean)    COMMENT     �  COMMENT ON FUNCTION rz_server_get_status_info(p_world_id integer, p_server_id integer, OUT "IS_RUN" boolean, OUT "SERVABLE" boolean) IS 'IS_RUN: If this was FALSE, then something wrong happened to server. e.g. crash, hang or lost internet connection etc.
SERVABLE: This will be TRUE when the server is self-proclaimed I''m ready to do my jobs.

Usually, these both values must be TRUE. If not, the server is not working or inproperly configured.';
            public       postgres    false    212            �            1255    16428 `   rz_server_start(integer, integer, text, text, text, integer, integer, integer, integer, integer)    FUNCTION       CREATE FUNCTION rz_server_start(p_world_id integer, p_server_id integer, p_name text, p_version text, p_host_address text, p_port integer, p_type integer, p_max_players_capacity integer, p_update_elapsed_time integer, p_allow_delay_time integer) RETURNS void
    LANGUAGE sql
    AS $$INSERT INTO rz_server (server_id,
                       world_id,
                       name,
                       version,
                       address,
                       port,
                       type,
                       max_players_capacity,
                       alive_timeout)
VALUES (p_server_id,
        p_world_id,
        p_name,
        p_version,
        p_host_address,
        p_port, 
        rz_server_type_by_num(p_type),
        p_max_players_capacity,
        ((p_update_elapsed_time + p_allow_delay_time) || ' seconds')::interval)
ON CONFLICT DO NOTHING;

INSERT INTO rz_server_status (server_id,
                              world_id,
                              start_time,
                              last_update_time)
VALUES (p_server_id,
        p_world_id,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP)
ON CONFLICT (server_id, world_id)
DO UPDATE SET start_time       = EXCLUDED.start_time,
              last_update_time = EXCLUDED.last_update_time,
              servable         = FALSE,
              task_count       = 0,
              cpu_usage        = 0,
              memory_usage     = 0,
              fps              = 0,
              field_count      = 0,
              shutdown_state   = 0;$$;
 �   DROP FUNCTION public.rz_server_start(p_world_id integer, p_server_id integer, p_name text, p_version text, p_host_address text, p_port integer, p_type integer, p_max_players_capacity integer, p_update_elapsed_time integer, p_allow_delay_time integer);
       public       postgres    false    3            �            1255    16429    rz_server_type_by_num(integer)    FUNCTION     0  CREATE FUNCTION rz_server_type_by_num(type integer) RETURNS rz_server_type
    LANGUAGE sql IMMUTABLE
    AS $$SELECT (CASE type
          WHEN 0 THEN 'LoginServer'
          WHEN 1 THEN 'MasterServer'
          WHEN 2 THEN 'GameServer'
          WHEN 3 THEN 'AppServer'
        END)::rz_server_type;$$;
 :   DROP FUNCTION public.rz_server_type_by_num(type integer);
       public       postgres    false    3    585            �           0    0 ,   FUNCTION rz_server_type_by_num(type integer)    COMMENT     �   COMMENT ON FUNCTION rz_server_type_by_num(type integer) IS 'NOTE: If you altered values of this function, then alter rz_server_type_to_num() too!';
            public       postgres    false    193            �            1255    16430 %   rz_server_type_to_num(rz_server_type)    FUNCTION     A  CREATE FUNCTION rz_server_type_to_num(p_server_type rz_server_type) RETURNS integer
    LANGUAGE sql IMMUTABLE
    AS $$SELECT (CASE p_server_type
          WHEN 'LoginServer'  THEN 0
          WHEN 'MasterServer' THEN 1
          WHEN 'GameServer'   THEN 2
          WHEN 'AppServer'    THEN 3
        END)::integer;$$;
 J   DROP FUNCTION public.rz_server_type_to_num(p_server_type rz_server_type);
       public       postgres    false    3    585            �           0    0 <   FUNCTION rz_server_type_to_num(p_server_type rz_server_type)    COMMENT     �   COMMENT ON FUNCTION rz_server_type_to_num(p_server_type rz_server_type) IS 'NOTE: If you altered values of this function, then alter rz_server_type_by_num() too!';
            public       postgres    false    194            �            1255    16431 a   rz_server_update(integer, integer, integer, boolean, integer, integer, integer, integer, integer)    FUNCTION     Y  CREATE FUNCTION rz_server_update(p_world_id integer, p_server_id integer, p_active_players integer, p_servable boolean, p_task_count integer, p_cpu_usage integer, p_memory_usage integer, p_field_count integer, p_fps integer) RETURNS void
    LANGUAGE sql
    AS $$INSERT INTO rz_server_status (server_id,
                              world_id,
                              start_time,
                              active_players,
                              servable,
                              task_count,
                              cpu_usage,
                              memory_usage,
                              fps,
                              field_count)
VALUES (p_server_id,
        p_world_id,
        CURRENT_TIMESTAMP,
        p_active_players,
        p_servable,
        p_task_count,
        p_cpu_usage,
        p_memory_usage,
        p_fps,
        p_field_count)
ON CONFLICT (server_id, world_id)
DO UPDATE SET active_players   = EXCLUDED.active_players,
              last_update_time = EXCLUDED.last_update_time,
              servable         = EXCLUDED.servable,
              task_count       = EXCLUDED.task_count,
              cpu_usage        = EXCLUDED.cpu_usage,
              memory_usage     = EXCLUDED.memory_usage,
              fps              = EXCLUDED.fps,
              field_count      = EXCLUDED.field_count;$$;
 �   DROP FUNCTION public.rz_server_update(p_world_id integer, p_server_id integer, p_active_players integer, p_servable boolean, p_task_count integer, p_cpu_usage integer, p_memory_usage integer, p_field_count integer, p_fps integer);
       public       postgres    false    3            �            1255    16432    rz_world_get_list()    FUNCTION     �  CREATE FUNCTION rz_world_get_list(OUT "WORLD_ID" integer, OUT "NAME" text, OUT "IP" text, OUT "TYPE" integer, OUT "CUR_PLAYER_COUNT" integer, OUT "MAX_PLAYER_COUNT" integer, OUT "SERVABLE" boolean, OUT "EXPIRE" boolean, OUT "STATE" rz_server_state, OUT "ORD_NUM" integer) RETURNS SETOF record
    LANGUAGE sql STABLE ROWS 5
    AS $$SELECT world_id,
       name,
       host_address, 
       rz_server_type_to_num(type),
       cur_players,
       max_players,
       servable,
       ((CURRENT_TIMESTAMP - last_update_time) >= alive_timeout)::boolean,
       state,
       order_num
  FROM rz_world
 WHERE state <> 'CLOSED'
 ORDER BY order_num, world_id, server_id;$$;
   DROP FUNCTION public.rz_world_get_list(OUT "WORLD_ID" integer, OUT "NAME" text, OUT "IP" text, OUT "TYPE" integer, OUT "CUR_PLAYER_COUNT" integer, OUT "MAX_PLAYER_COUNT" integer, OUT "SERVABLE" boolean, OUT "EXPIRE" boolean, OUT "STATE" rz_server_state, OUT "ORD_NUM" integer);
       public       postgres    false    503    3            �            1255    16433 Q   rz_world_insert(integer, text, text, integer, integer, boolean, integer, integer)    FUNCTION     �  CREATE FUNCTION rz_world_insert(p_world_id integer, p_name text, p_host_address text, p_type integer, p_max_players_capacity integer, p_servable boolean, p_state integer, p_alive_timeout integer) RETURNS void
    LANGUAGE sql
    AS $$INSERT INTO rz_world (world_id,
                      name,
                      host_address,
                      type,
                      max_players, 
                      last_update_time,
                      servable,
                      state,
                      alive_timeout)
VALUES (p_world_id,
        p_name,
        p_host_address,
        rz_server_type_by_num(p_type),
        p_max_players_capacity,
        CURRENT_TIMESTAMP,
        p_servable,
        'FINE',
        (p_alive_timeout || ' seconds')::interval)
ON CONFLICT (server_id, world_id)
DO UPDATE SET name             = EXCLUDED.name,
              host_address     = EXCLUDED.host_address,
              type             = EXCLUDED.type,
              max_players      = EXCLUDED.max_players,
              last_update_time = EXCLUDED.last_update_time,
              servable         = EXCLUDED.servable,
              state            = EXCLUDED.state,
              alive_timeout    = EXCLUDED.alive_timeout;$$;
 �   DROP FUNCTION public.rz_world_insert(p_world_id integer, p_name text, p_host_address text, p_type integer, p_max_players_capacity integer, p_servable boolean, p_state integer, p_alive_timeout integer);
       public       postgres    false    3            �           0    0 �   FUNCTION rz_world_insert(p_world_id integer, p_name text, p_host_address text, p_type integer, p_max_players_capacity integer, p_servable boolean, p_state integer, p_alive_timeout integer)    COMMENT     �   COMMENT ON FUNCTION rz_world_insert(p_world_id integer, p_name text, p_host_address text, p_type integer, p_max_players_capacity integer, p_servable boolean, p_state integer, p_alive_timeout integer) IS 'TODO: properly insert server state.';
            public       postgres    false    216            �            1255    16434    rz_world_set_maintenance()    FUNCTION     �   CREATE FUNCTION rz_world_set_maintenance() RETURNS void
    LANGUAGE sql
    AS $$UPDATE rz_world SET state = 'MAINTENANCE' WHERE state = 'FINE';$$;
 1   DROP FUNCTION public.rz_world_set_maintenance();
       public       postgres    false    3            �            1255    16435    rz_world_unset_maintenance()    FUNCTION     �   CREATE FUNCTION rz_world_unset_maintenance() RETURNS void
    LANGUAGE sql
    AS $$UPDATE rz_world SET state = 'FINE' WHERE state = 'MAINTENANCE';$$;
 3   DROP FUNCTION public.rz_world_unset_maintenance();
       public       postgres    false    3            �            1255    16436 *   rz_world_update(integer, integer, boolean)    FUNCTION     9  CREATE FUNCTION rz_world_update(p_world_id integer, p_cur_players integer, p_servable boolean) RETURNS void
    LANGUAGE sql
    AS $$UPDATE rz_world 
   SET   cur_players      = p_cur_players,
         servable         = p_servable,
         last_update_time = CURRENT_TIMESTAMP
 WHERE world_id = p_world_id;$$;
 e   DROP FUNCTION public.rz_world_update(p_world_id integer, p_cur_players integer, p_servable boolean);
       public       postgres    false    3            �            1259    16437 
   rz_account    TABLE     �  CREATE TABLE rz_account (
    accn_sn bigint NOT NULL,
    username text NOT NULL,
    password text NOT NULL,
    email text,
    def_world_id integer,
    def_char_sn bigint,
    play_time interval DEFAULT '00:00:00'::interval NOT NULL,
    reg_time timestamp with time zone DEFAULT now() NOT NULL,
    status rz_account_status DEFAULT 'ACTIVE'::rz_account_status NOT NULL,
    last_status_update timestamp with time zone DEFAULT now() NOT NULL,
    last_play_time timestamp with time zone,
    last_play_world_id integer,
    last_play_char_sn bigint,
    first_char_create_time timestamp with time zone,
    cash integer DEFAULT 0 NOT NULL
);
    DROP TABLE public.rz_account;
       public         postgres    false    500    3    500            �           0    0    TABLE rz_account    COMMENT     �   COMMENT ON TABLE rz_account IS 'ToDo: do not store account password as plain text.

Use rz_account_insert() to create an account.';
            public       postgres    false    185            �            1259    16448    rz_account_accn_sn_seq    SEQUENCE     x   CREATE SEQUENCE rz_account_accn_sn_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.rz_account_accn_sn_seq;
       public       postgres    false    3    185            �           0    0    rz_account_accn_sn_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE rz_account_accn_sn_seq OWNED BY rz_account.accn_sn;
            public       postgres    false    186            �            1259    16450    rz_conn_sn_seq    SEQUENCE     p   CREATE SEQUENCE rz_conn_sn_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.rz_conn_sn_seq;
       public       postgres    false    3            �           0    0    SEQUENCE rz_conn_sn_seq    COMMENT       COMMENT ON SEQUENCE rz_conn_sn_seq IS 'CONN_SN is an unique serial number assigned for each user''s connections.

It''s used to determine which information should be updated on RZ_LOGDB.
(Log is created for each user''s sessions, not for each accounts or characters.)
';
            public       postgres    false    187            �            1259    16955 
   rz_connect    TABLE     
  CREATE TABLE rz_connect (
    log_sn bigint NOT NULL,
    conn_sn bigint NOT NULL,
    server_id integer NOT NULL,
    world_id integer NOT NULL,
    accn_sn bigint NOT NULL,
    conn_ip inet NOT NULL,
    log_time timestamp with time zone DEFAULT now() NOT NULL
);
    DROP TABLE public.rz_connect;
       public         postgres    false    3            �            1259    16962    rz_connect_log_sn_seq    SEQUENCE     w   CREATE SEQUENCE rz_connect_log_sn_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public.rz_connect_log_sn_seq;
       public       postgres    false    191    3            �           0    0    rz_connect_log_sn_seq    SEQUENCE OWNED BY     A   ALTER SEQUENCE rz_connect_log_sn_seq OWNED BY rz_connect.log_sn;
            public       postgres    false    192            �            1259    16452 	   rz_server    TABLE     �  CREATE TABLE rz_server (
    server_id integer NOT NULL,
    world_id integer NOT NULL,
    open_time timestamp with time zone DEFAULT now() NOT NULL,
    close_time timestamp with time zone,
    version text,
    name text,
    description text,
    type rz_server_type,
    address text,
    port integer,
    max_players_capacity integer DEFAULT 0 NOT NULL,
    alive_timeout interval DEFAULT '00:01:00'::interval NOT NULL,
    state rz_server_state DEFAULT 'FINE'::rz_server_state NOT NULL
);
    DROP TABLE public.rz_server;
       public         postgres    false    503    3    503    585            �            1259    16462    rz_server_status    TABLE       CREATE TABLE rz_server_status (
    server_id integer NOT NULL,
    world_id integer NOT NULL,
    start_time timestamp with time zone,
    active_players integer DEFAULT 0 NOT NULL,
    last_update_time timestamp with time zone,
    servable boolean DEFAULT false NOT NULL,
    task_count integer DEFAULT 0 NOT NULL,
    cpu_usage integer DEFAULT 0 NOT NULL,
    memory_usage integer DEFAULT 0 NOT NULL,
    fps integer DEFAULT 0 NOT NULL,
    field_count integer DEFAULT 0 NOT NULL,
    shutdown_state integer DEFAULT 0 NOT NULL
);
 $   DROP TABLE public.rz_server_status;
       public         postgres    false    3            �            1259    16473    rz_world    TABLE     e  CREATE TABLE rz_world (
    server_id integer NOT NULL,
    world_id integer NOT NULL,
    name text NOT NULL,
    host_address text NOT NULL,
    port integer DEFAULT 7501 NOT NULL,
    type rz_server_type DEFAULT 'LoginServer'::rz_server_type NOT NULL,
    cur_players integer DEFAULT 0 NOT NULL,
    max_players integer DEFAULT 0 NOT NULL,
    last_update_time timestamp with time zone,
    servable boolean DEFAULT false NOT NULL,
    alive_timeout interval DEFAULT '00:01:00'::interval NOT NULL,
    state rz_server_state DEFAULT 'FINE'::rz_server_state NOT NULL,
    order_num integer DEFAULT 0 NOT NULL
);
    DROP TABLE public.rz_world;
       public         postgres    false    585    503    3    503    585                       2604    16487    rz_account accn_sn    DEFAULT     j   ALTER TABLE ONLY rz_account ALTER COLUMN accn_sn SET DEFAULT nextval('rz_account_accn_sn_seq'::regclass);
 A   ALTER TABLE public.rz_account ALTER COLUMN accn_sn DROP DEFAULT;
       public       postgres    false    186    185                       2604    16964    rz_connect log_sn    DEFAULT     h   ALTER TABLE ONLY rz_connect ALTER COLUMN log_sn SET DEFAULT nextval('rz_connect_log_sn_seq'::regclass);
 @   ALTER TABLE public.rz_connect ALTER COLUMN log_sn DROP DEFAULT;
       public       postgres    false    192    191            �          0    16437 
   rz_account 
   TABLE DATA               �   COPY rz_account (accn_sn, username, password, email, def_world_id, def_char_sn, play_time, reg_time, status, last_status_update, last_play_time, last_play_world_id, last_play_char_sn, first_char_create_time, cash) FROM stdin;
    public       postgres    false    185   {       �           0    0    rz_account_accn_sn_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('rz_account_accn_sn_seq', 1, false);
            public       postgres    false    186            �           0    0    rz_conn_sn_seq    SEQUENCE SET     6   SELECT pg_catalog.setval('rz_conn_sn_seq', 1, false);
            public       postgres    false    187            �          0    16955 
   rz_connect 
   TABLE DATA               _   COPY rz_connect (log_sn, conn_sn, server_id, world_id, accn_sn, conn_ip, log_time) FROM stdin;
    public       postgres    false    191   #{       �           0    0    rz_connect_log_sn_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('rz_connect_log_sn_seq', 78, true);
            public       postgres    false    192            �          0    16452 	   rz_server 
   TABLE DATA               �   COPY rz_server (server_id, world_id, open_time, close_time, version, name, description, type, address, port, max_players_capacity, alive_timeout, state) FROM stdin;
    public       postgres    false    188   [       �          0    16462    rz_server_status 
   TABLE DATA               �   COPY rz_server_status (server_id, world_id, start_time, active_players, last_update_time, servable, task_count, cpu_usage, memory_usage, fps, field_count, shutdown_state) FROM stdin;
    public       postgres    false    189   x       �          0    16473    rz_world 
   TABLE DATA               �   COPY rz_world (server_id, world_id, name, host_address, port, type, cur_players, max_players, last_update_time, servable, alive_timeout, state, order_num) FROM stdin;
    public       postgres    false    190   �                  2606    16489    rz_account rz_account_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY rz_account
    ADD CONSTRAINT rz_account_pkey PRIMARY KEY (accn_sn);
 D   ALTER TABLE ONLY public.rz_account DROP CONSTRAINT rz_account_pkey;
       public         postgres    false    185    185                        2606    16491 "   rz_account rz_account_username_key 
   CONSTRAINT     Z   ALTER TABLE ONLY rz_account
    ADD CONSTRAINT rz_account_username_key UNIQUE (username);
 L   ALTER TABLE ONLY public.rz_account DROP CONSTRAINT rz_account_username_key;
       public         postgres    false    185    185            (           2606    16966    rz_connect rz_connect_pkey 
   CONSTRAINT     U   ALTER TABLE ONLY rz_connect
    ADD CONSTRAINT rz_connect_pkey PRIMARY KEY (log_sn);
 D   ALTER TABLE ONLY public.rz_connect DROP CONSTRAINT rz_connect_pkey;
       public         postgres    false    191    191            "           2606    16493    rz_server rz_server_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY rz_server
    ADD CONSTRAINT rz_server_pkey PRIMARY KEY (server_id, world_id);
 B   ALTER TABLE ONLY public.rz_server DROP CONSTRAINT rz_server_pkey;
       public         postgres    false    188    188    188            $           2606    16495 &   rz_server_status rz_server_status_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY rz_server_status
    ADD CONSTRAINT rz_server_status_pkey PRIMARY KEY (server_id, world_id);
 P   ALTER TABLE ONLY public.rz_server_status DROP CONSTRAINT rz_server_status_pkey;
       public         postgres    false    189    189    189            &           2606    16497    rz_world rz_world_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY rz_world
    ADD CONSTRAINT rz_world_pkey PRIMARY KEY (server_id, world_id);
 @   ALTER TABLE ONLY public.rz_world DROP CONSTRAINT rz_world_pkey;
       public         postgres    false    190    190    190            �      x������ � �      �   (  x���ˑ$9�,)J��?�YF9���#�Vy�J7F �i�E#����^���������X��}��,��!o�~��+~�����w�E~��dd�o�.O��~2��L�l����ߌ}�m�s|�'c8g�Ŧ��q� h�(bM|$� �P��di@�PG�_�o��_[�I�O��e��6) �EA�5���zB �I)(�nN$�U�d4�g�h�s�, �I�#4��ݙ�@Z-�/reY'�^Z� Ҋ��  :���
�U����C�OE��o
Eu�����p���L�8�,��~й񗲏��W�( ܹQe9
����2�s�(4����r>��(J�$�WQ6�s�/��^C��h���l�K>�q�^N7�p�FPQ��i�.Q���(��^�^�h�D:7�BG��d�E/��"�I��)�i� ���8�(ˤ0DZ5��(�m'�"��Q(e�-R�G��j��鋲!���g(/�h�V���Ԁ�'چ8Ӯh���7�u :T66 �R���פbx�����u���@�ˌ�ޟ������/5.�u�.���DjЊC\�:i<}�*�0�L+�@��FP�(���f���C���!"ɮ�!}���C�T��u�}�J9�<-[5���Cb���ZѸ�Z5j��ȟe��Z7jG	�:r5�k�H�bᘲ�VQ���������FfAX�FB�b�X�7���٪� �O�����Z5<���l�h b�I!ɐ��ŤLʇ�j�����r�W ֪���VJe�ZQ��V��,�y�x�d�j�/��laq��n� D�k,4c�` �3�B�A3�Ug��5@�*���9�!��P��y��k��j�%Hb+Gm-���5�&=z��()��P�sCA�P'��"t�~�T�]]�"��j��\'?�����[5��F^�y��@�u��ע[��[7��P�p�2g��x�FQ7v^ܽ��@�u:o�\����@�u#)�5,6{ߺS��V��TBCQ��|x�FQK�Ճ=4�3�U�(�<�G���???����8      �      x������ � �      �      x������ � �      �      x������ � �     