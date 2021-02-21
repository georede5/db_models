-- Database generated with pgModeler (PostgreSQL Database Modeler).
-- pgModeler  version: 0.9.2
-- PostgreSQL version: 12.0
-- Project Site: pgmodeler.io
-- Model Author: ---

SET check_function_bodies = false;
-- ddl-end --


-- Database creation must be done outside a multicommand file.
-- These commands were put in this file only as a convenience.
-- -- object: teste | type: DATABASE --
-- -- DROP DATABASE IF EXISTS teste;
-- CREATE DATABASE teste
-- 	ENCODING = 'UTF8'
-- 	LC_COLLATE = 'en_US.utf8'
-- 	LC_CTYPE = 'en_US.utf8'
-- 	TABLESPACE = pg_default
-- 	OWNER = postgres;
-- -- ddl-end --
-- 

-- object: sgrr | type: SCHEMA --
-- DROP SCHEMA IF EXISTS sgrr CASCADE;
CREATE SCHEMA sgrr;
-- ddl-end --
-- ALTER SCHEMA sgrr OWNER TO postgres;
-- ddl-end --

SET search_path TO pg_catalog,public,sgrr;
-- ddl-end --

CREATE EXTENSION postgis;
-- ddl-end --
COMMENT ON EXTENSION postgis IS E'PostGIS geometry, geography, and raster spatial types and functions';
-- ddl-end --

-- object: sgrr.calcula_area_afectada | type: FUNCTION --
-- DROP FUNCTION IF EXISTS sgrr.calcula_area_afectada() CASCADE;
CREATE FUNCTION sgrr.calcula_area_afectada ()
	RETURNS trigger
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	AS $$


BEGIN 
NEW.area_afectada := (NEW.end_m-NEW.start_m)*NEW.largura;
RETURN NEW;
END;

$$;
-- ddl-end --
-- ALTER FUNCTION sgrr.calcula_area_afectada() OWNER TO postgres;
-- ddl-end --

-- object: sgrr.dynamic_geom | type: FUNCTION --
-- DROP FUNCTION IF EXISTS sgrr.dynamic_geom() CASCADE;
CREATE FUNCTION sgrr.dynamic_geom ()
	RETURNS trigger
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	AS $$

BEGIN

        IF (TG_OP = 'UPDATE') THEN
           IF ((NEW.start_m <> OLD.start_m) OR (NEW.end_m <> OLD.end_m)) THEN

                  SELECT ST_LocateBetween(e.geom, NEW.start_m, NEW.end_m)
                         INTO NEW.geom
                         FROM sgrr.estradas AS e
                         WHERE e.id=NEW.id_estradas;
                  RETURN NEW;
           END IF;

        ELSE IF (TG_OP = 'INSERT') THEN

                  SELECT ST_LocateBetween(e.geom, NEW.start_m, NEW.end_m)
                         INTO NEW.geom
                         FROM sgrr.estradas AS e
                         WHERE e.id=NEW.id_estradas;
                  RETURN NEW;

        END IF;
        END IF;

        RETURN NEW;

END;

$$;
-- ddl-end --
-- ALTER FUNCTION sgrr.dynamic_geom() OWNER TO postgres;
-- ddl-end --

-- object: sgrr.dynamic_geom_point | type: FUNCTION --
-- DROP FUNCTION IF EXISTS sgrr.dynamic_geom_point() CASCADE;
CREATE FUNCTION sgrr.dynamic_geom_point ()
	RETURNS trigger
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	AS $$

BEGIN

        IF (TG_OP = 'UPDATE') THEN
           IF (NEW.medicao <> OLD.medicao) THEN

                  SELECT ST_LocateAlong(e.geom, NEW.medicao)
                         INTO NEW.geom
                         FROM sgrr.estradas AS e
                         WHERE e.id=NEW.id_estradas;
                  RETURN NEW;
           END IF;

        ELSE IF (TG_OP = 'INSERT') THEN

                 SELECT ST_LocateAlong(e.geom, NEW.medicao)
                         INTO NEW.geom
                         FROM sgrr.estradas AS e
                         WHERE e.id=NEW.id_estradas;
                  RETURN NEW;

        END IF;
        END IF;

        RETURN NEW;

END;

$$;
-- ddl-end --
-- ALTER FUNCTION sgrr.dynamic_geom_point() OWNER TO postgres;
-- ddl-end --

-- object: sgrr.caract_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS sgrr.caract_id_seq CASCADE;
CREATE SEQUENCE sgrr.caract_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
-- ALTER SEQUENCE sgrr.caract_id_seq OWNER TO postgres;
-- ddl-end --

-- object: sgrr.caract | type: TABLE --
-- DROP TABLE IF EXISTS sgrr.caract CASCADE;
CREATE TABLE sgrr.caract (
	id integer NOT NULL DEFAULT nextval('sgrr.caract_id_seq'::regclass),
	designacao text,
	extensao double precision,
	largura_m numeric(2,2),
	t_horizontal character varying(12),
	t_vertical character varying(12),
	sinal_vert boolean,
	sinal_horiz boolean,
	berma_larg numeric(2,2),
	ilumi_nos boolean,
	obs text,
	id_estradas integer,
	CONSTRAINT caract_uq UNIQUE (id_estradas),
	CONSTRAINT rv_caract_pk PRIMARY KEY (id)

);
-- ddl-end --
-- ALTER TABLE sgrr.caract OWNER TO postgres;
-- ddl-end --

-- object: sgrr.estado_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS sgrr.estado_id_seq CASCADE;
CREATE SEQUENCE sgrr.estado_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
-- ALTER SEQUENCE sgrr.estado_id_seq OWNER TO postgres;
-- ddl-end --

-- object: sgrr.estado | type: TABLE --
-- DROP TABLE IF EXISTS sgrr.estado CASCADE;
CREATE TABLE sgrr.estado (
	id integer NOT NULL DEFAULT nextval('sgrr.estado_id_seq'::regclass),
	descricao text,
	CONSTRAINT estado_pk PRIMARY KEY (id)

);
-- ddl-end --
-- ALTER TABLE sgrr.estado OWNER TO postgres;
-- ddl-end --

-- object: sgrr.estradas_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS sgrr.estradas_id_seq CASCADE;
CREATE SEQUENCE sgrr.estradas_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
-- ALTER SEQUENCE sgrr.estradas_id_seq OWNER TO postgres;
-- ddl-end --

-- object: sgrr.estradas | type: TABLE --
-- DROP TABLE IF EXISTS sgrr.estradas CASCADE;
CREATE TABLE sgrr.estradas (
	id integer NOT NULL DEFAULT nextval('sgrr.estradas_id_seq'::regclass),
	geom geometry(MULTILINESTRINGM, 3763),
	start_m double precision,
	end_m double precision,
	ref character varying(8),
	obs text,
	CONSTRAINT pk PRIMARY KEY (id)

);
-- ddl-end --
-- ALTER TABLE sgrr.estradas OWNER TO postgres;
-- ddl-end --

-- object: sgrr.insert | type: TABLE --
-- DROP TABLE IF EXISTS sgrr.insert CASCADE;
CREATE TABLE sgrr.insert (
	id numeric NOT NULL,
	geom geometry(MULTILINESTRING, 3763),
	descr character varying(255),
	CONSTRAINT insert_pkey PRIMARY KEY (id)

);
-- ddl-end --
-- ALTER TABLE sgrr.insert OWNER TO postgres;
-- ddl-end --

-- object: sgrr.intevencoes_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS sgrr.intevencoes_id_seq CASCADE;
CREATE SEQUENCE sgrr.intevencoes_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
-- ALTER SEQUENCE sgrr.intevencoes_id_seq OWNER TO postgres;
-- ddl-end --

-- object: sgrr.intevencoes | type: TABLE --
-- DROP TABLE IF EXISTS sgrr.intevencoes CASCADE;
CREATE TABLE sgrr.intevencoes (
	id integer NOT NULL DEFAULT nextval('sgrr.intevencoes_id_seq'::regclass),
	data_inter date,
	desc_inter text,
	valor double precision,
	obs text,
	id_trocos integer,
	CONSTRAINT intervencoes_pk PRIMARY KEY (id)

);
-- ddl-end --
-- ALTER TABLE sgrr.intevencoes OWNER TO postgres;
-- ddl-end --

-- object: sgrr.lado_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS sgrr.lado_id_seq CASCADE;
CREATE SEQUENCE sgrr.lado_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
-- ALTER SEQUENCE sgrr.lado_id_seq OWNER TO postgres;
-- ddl-end --

-- object: sgrr.lado | type: TABLE --
-- DROP TABLE IF EXISTS sgrr.lado CASCADE;
CREATE TABLE sgrr.lado (
	id integer NOT NULL DEFAULT nextval('sgrr.lado_id_seq'::regclass),
	descricao text,
	CONSTRAINT lado_pk PRIMARY KEY (id)

);
-- ddl-end --
-- ALTER TABLE sgrr.lado OWNER TO postgres;
-- ddl-end --

-- object: sgrr.lrs_line_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS sgrr.lrs_line_id_seq CASCADE;
CREATE SEQUENCE sgrr.lrs_line_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
-- ALTER SEQUENCE sgrr.lrs_line_id_seq OWNER TO postgres;
-- ddl-end --

-- object: sgrr.lrs_line | type: TABLE --
-- DROP TABLE IF EXISTS sgrr.lrs_line CASCADE;
CREATE TABLE sgrr.lrs_line (
	id integer NOT NULL DEFAULT nextval('sgrr.lrs_line_id_seq'::regclass),
	geom geometry(MULTILINESTRINGM, 3763),
	start_m double precision,
	end_m double precision,
	obs text,
	id_estradas integer,
	id_tipo_line integer,
	id_estado integer,
	id_lado integer,
	CONSTRAINT lcadastro_pk PRIMARY KEY (id)

);
-- ddl-end --
-- ALTER TABLE sgrr.lrs_line OWNER TO postgres;
-- ddl-end --

-- object: sgrr.lrs_node_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS sgrr.lrs_node_id_seq CASCADE;
CREATE SEQUENCE sgrr.lrs_node_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
-- ALTER SEQUENCE sgrr.lrs_node_id_seq OWNER TO postgres;
-- ddl-end --

-- object: sgrr.lrs_node | type: TABLE --
-- DROP TABLE IF EXISTS sgrr.lrs_node CASCADE;
CREATE TABLE sgrr.lrs_node (
	id integer NOT NULL DEFAULT nextval('sgrr.lrs_node_id_seq'::regclass),
	geom geometry(MULTIPOINTM, 3763),
	medicao double precision,
	dimensoes text,
	obs text,
	id_estradas integer,
	id_tipo_node integer,
	id_estado integer,
	id_lado integer,
	CONSTRAINT opontos PRIMARY KEY (id)

);
-- ddl-end --
-- ALTER TABLE sgrr.lrs_node OWNER TO postgres;
-- ddl-end --

-- object: sgrr.patologias_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS sgrr.patologias_id_seq CASCADE;
CREATE SEQUENCE sgrr.patologias_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
-- ALTER SEQUENCE sgrr.patologias_id_seq OWNER TO postgres;
-- ddl-end --

-- object: sgrr.patologias | type: TABLE --
-- DROP TABLE IF EXISTS sgrr.patologias CASCADE;
CREATE TABLE sgrr.patologias (
	id integer NOT NULL DEFAULT nextval('sgrr.patologias_id_seq'::regclass),
	geom geometry(MULTILINESTRINGM, 3763),
	nivel smallint,
	start_m double precision,
	end_m double precision,
	area_afectada double precision,
	largura double precision,
	profundidade double precision,
	data_reparacao date,
	data_levantamento date,
	largura_real double precision,
	obs text,
	id_estradas integer NOT NULL,
	id_tipo_patologias integer NOT NULL,
	CONSTRAINT reparacoes_pk PRIMARY KEY (id,id_estradas,id_tipo_patologias)

);
-- ddl-end --
-- ALTER TABLE sgrr.patologias OWNER TO postgres;
-- ddl-end --

-- object: sgrr.rails_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS sgrr.rails_id_seq CASCADE;
CREATE SEQUENCE sgrr.rails_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
-- ALTER SEQUENCE sgrr.rails_id_seq OWNER TO postgres;
-- ddl-end --

-- object: sgrr.rails | type: TABLE --
-- DROP TABLE IF EXISTS sgrr.rails CASCADE;
CREATE TABLE sgrr.rails (
	id integer NOT NULL DEFAULT nextval('sgrr.rails_id_seq'::regclass),
	geom geometry(MULTILINESTRINGM, 3763),
	start_m double precision,
	end_m double precision,
	refletor boolean,
	pmoto boolean,
	cauda character varying(24),
	obs text,
	id_estradas integer,
	id_estado integer,
	id_lado integer,
	CONSTRAINT lcadastro_1 PRIMARY KEY (id)

);
-- ddl-end --
-- ALTER TABLE sgrr.rails OWNER TO postgres;
-- ddl-end --

-- object: sgrr.tipo_line_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS sgrr.tipo_line_id_seq CASCADE;
CREATE SEQUENCE sgrr.tipo_line_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
-- ALTER SEQUENCE sgrr.tipo_line_id_seq OWNER TO postgres;
-- ddl-end --

-- object: sgrr.tipo_line | type: TABLE --
-- DROP TABLE IF EXISTS sgrr.tipo_line CASCADE;
CREATE TABLE sgrr.tipo_line (
	id integer NOT NULL DEFAULT nextval('sgrr.tipo_line_id_seq'::regclass),
	descricao text,
	CONSTRAINT lcadastro_pk_1 PRIMARY KEY (id)

);
-- ddl-end --
-- ALTER TABLE sgrr.tipo_line OWNER TO postgres;
-- ddl-end --

-- object: sgrr.tipo_node_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS sgrr.tipo_node_id_seq CASCADE;
CREATE SEQUENCE sgrr.tipo_node_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
-- ALTER SEQUENCE sgrr.tipo_node_id_seq OWNER TO postgres;
-- ddl-end --

-- object: sgrr.tipo_node | type: TABLE --
-- DROP TABLE IF EXISTS sgrr.tipo_node CASCADE;
CREATE TABLE sgrr.tipo_node (
	id integer NOT NULL DEFAULT nextval('sgrr.tipo_node_id_seq'::regclass),
	descricao text,
	CONSTRAINT tpcadastro_pk PRIMARY KEY (id)

);
-- ddl-end --
-- ALTER TABLE sgrr.tipo_node OWNER TO postgres;
-- ddl-end --

-- object: sgrr.tipo_patologias_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS sgrr.tipo_patologias_id_seq CASCADE;
CREATE SEQUENCE sgrr.tipo_patologias_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
-- ALTER SEQUENCE sgrr.tipo_patologias_id_seq OWNER TO postgres;
-- ddl-end --

-- object: sgrr.tipo_patologias | type: TABLE --
-- DROP TABLE IF EXISTS sgrr.tipo_patologias CASCADE;
CREATE TABLE sgrr.tipo_patologias (
	id integer NOT NULL DEFAULT nextval('sgrr.tipo_patologias_id_seq'::regclass),
	descricao character varying(16),
	cod character varying(4),
	CONSTRAINT tpatologias_pk PRIMARY KEY (id)

);
-- ddl-end --
-- ALTER TABLE sgrr.tipo_patologias OWNER TO postgres;
-- ddl-end --

-- object: sgrr.tipo_pavimento_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS sgrr.tipo_pavimento_id_seq CASCADE;
CREATE SEQUENCE sgrr.tipo_pavimento_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
-- ALTER SEQUENCE sgrr.tipo_pavimento_id_seq OWNER TO postgres;
-- ddl-end --

-- object: sgrr.tipo_pavimento | type: TABLE --
-- DROP TABLE IF EXISTS sgrr.tipo_pavimento CASCADE;
CREATE TABLE sgrr.tipo_pavimento (
	id integer NOT NULL DEFAULT nextval('sgrr.tipo_pavimento_id_seq'::regclass),
	descricao text,
	cod character varying(6),
	CONSTRAINT tpavimento_pk PRIMARY KEY (id)

);
-- ddl-end --
-- ALTER TABLE sgrr.tipo_pavimento OWNER TO postgres;
-- ddl-end --

-- object: sgrr.tipo_valeta_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS sgrr.tipo_valeta_id_seq CASCADE;
CREATE SEQUENCE sgrr.tipo_valeta_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
-- ALTER SEQUENCE sgrr.tipo_valeta_id_seq OWNER TO postgres;
-- ddl-end --

-- object: sgrr.tipo_valeta | type: TABLE --
-- DROP TABLE IF EXISTS sgrr.tipo_valeta CASCADE;
CREATE TABLE sgrr.tipo_valeta (
	id integer NOT NULL DEFAULT nextval('sgrr.tipo_valeta_id_seq'::regclass),
	descricao character varying(24),
	CONSTRAINT tvaleta_pk PRIMARY KEY (id)

);
-- ddl-end --
-- ALTER TABLE sgrr.tipo_valeta OWNER TO postgres;
-- ddl-end --

-- object: sgrr.trocos_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS sgrr.trocos_id_seq CASCADE;
CREATE SEQUENCE sgrr.trocos_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
-- ALTER SEQUENCE sgrr.trocos_id_seq OWNER TO postgres;
-- ddl-end --

-- object: sgrr.trocos | type: TABLE --
-- DROP TABLE IF EXISTS sgrr.trocos CASCADE;
CREATE TABLE sgrr.trocos (
	id integer NOT NULL DEFAULT nextval('sgrr.trocos_id_seq'::regclass),
	geom geometry(MULTILINESTRINGM, 3763),
	irl double precision,
	start_m double precision,
	end_m double precision,
	id_estradas integer,
	id_tipo_pavimento integer,
	CONSTRAINT trocos_pk PRIMARY KEY (id)

);
-- ddl-end --
-- ALTER TABLE sgrr.trocos OWNER TO postgres;
-- ddl-end --

-- object: sgrr.valetas_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS sgrr.valetas_id_seq CASCADE;
CREATE SEQUENCE sgrr.valetas_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
-- ALTER SEQUENCE sgrr.valetas_id_seq OWNER TO postgres;
-- ddl-end --

-- object: sgrr.valetas | type: TABLE --
-- DROP TABLE IF EXISTS sgrr.valetas CASCADE;
CREATE TABLE sgrr.valetas (
	id integer NOT NULL DEFAULT nextval('sgrr.valetas_id_seq'::regclass),
	geom geometry(MULTILINESTRINGM, 3763),
	start_m double precision,
	end_m double precision,
	dimensoes text,
	drenos boolean,
	obs text,
	id_estradas integer,
	id_tipo_valeta integer,
	id_estado integer,
	id_lado integer,
	CONSTRAINT obras_artes PRIMARY KEY (id)

);
-- ddl-end --
-- ALTER TABLE sgrr.valetas OWNER TO postgres;
-- ddl-end --

-- object: area_afetda | type: TRIGGER --
-- DROP TRIGGER IF EXISTS area_afetda ON sgrr.patologias CASCADE;
CREATE TRIGGER area_afetda
	BEFORE INSERT OR UPDATE
	ON sgrr.patologias
	FOR EACH ROW
	EXECUTE PROCEDURE sgrr.calcula_area_afectada();
-- ddl-end --

-- object: teste | type: TRIGGER --
-- DROP TRIGGER IF EXISTS teste ON sgrr.lrs_line CASCADE;
CREATE TRIGGER teste
	BEFORE INSERT OR UPDATE
	ON sgrr.lrs_line
	FOR EACH ROW
	EXECUTE PROCEDURE sgrr.dynamic_geom();
-- ddl-end --

-- object: teste | type: TRIGGER --
-- DROP TRIGGER IF EXISTS teste ON sgrr.patologias CASCADE;
CREATE TRIGGER teste
	BEFORE INSERT OR UPDATE
	ON sgrr.patologias
	FOR EACH ROW
	EXECUTE PROCEDURE sgrr.dynamic_geom();
-- ddl-end --

-- object: teste | type: TRIGGER --
-- DROP TRIGGER IF EXISTS teste ON sgrr.rails CASCADE;
CREATE TRIGGER teste
	BEFORE INSERT OR UPDATE
	ON sgrr.rails
	FOR EACH ROW
	EXECUTE PROCEDURE sgrr.dynamic_geom();
-- ddl-end --

-- object: estradas_fk | type: CONSTRAINT --
-- ALTER TABLE sgrr.caract DROP CONSTRAINT IF EXISTS estradas_fk CASCADE;
ALTER TABLE sgrr.caract ADD CONSTRAINT estradas_fk FOREIGN KEY (id_estradas)
REFERENCES sgrr.estradas (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;
-- ddl-end --

-- object: trocos_fk | type: CONSTRAINT --
-- ALTER TABLE sgrr.intevencoes DROP CONSTRAINT IF EXISTS trocos_fk CASCADE;
ALTER TABLE sgrr.intevencoes ADD CONSTRAINT trocos_fk FOREIGN KEY (id_trocos)
REFERENCES sgrr.trocos (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;
-- ddl-end --

-- object: estado_fk | type: CONSTRAINT --
-- ALTER TABLE sgrr.lrs_line DROP CONSTRAINT IF EXISTS estado_fk CASCADE;
ALTER TABLE sgrr.lrs_line ADD CONSTRAINT estado_fk FOREIGN KEY (id_estado)
REFERENCES sgrr.estado (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;
-- ddl-end --

-- object: estradas_fk | type: CONSTRAINT --
-- ALTER TABLE sgrr.lrs_line DROP CONSTRAINT IF EXISTS estradas_fk CASCADE;
ALTER TABLE sgrr.lrs_line ADD CONSTRAINT estradas_fk FOREIGN KEY (id_estradas)
REFERENCES sgrr.estradas (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;
-- ddl-end --

-- object: lado_fk | type: CONSTRAINT --
-- ALTER TABLE sgrr.lrs_line DROP CONSTRAINT IF EXISTS lado_fk CASCADE;
ALTER TABLE sgrr.lrs_line ADD CONSTRAINT lado_fk FOREIGN KEY (id_lado)
REFERENCES sgrr.lado (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;
-- ddl-end --

-- object: tipo_line_fk | type: CONSTRAINT --
-- ALTER TABLE sgrr.lrs_line DROP CONSTRAINT IF EXISTS tipo_line_fk CASCADE;
ALTER TABLE sgrr.lrs_line ADD CONSTRAINT tipo_line_fk FOREIGN KEY (id_tipo_line)
REFERENCES sgrr.tipo_line (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;
-- ddl-end --

-- object: estado_fk | type: CONSTRAINT --
-- ALTER TABLE sgrr.lrs_node DROP CONSTRAINT IF EXISTS estado_fk CASCADE;
ALTER TABLE sgrr.lrs_node ADD CONSTRAINT estado_fk FOREIGN KEY (id_estado)
REFERENCES sgrr.estado (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;
-- ddl-end --

-- object: estradas_fk | type: CONSTRAINT --
-- ALTER TABLE sgrr.lrs_node DROP CONSTRAINT IF EXISTS estradas_fk CASCADE;
ALTER TABLE sgrr.lrs_node ADD CONSTRAINT estradas_fk FOREIGN KEY (id_estradas)
REFERENCES sgrr.estradas (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;
-- ddl-end --

-- object: lado_fk | type: CONSTRAINT --
-- ALTER TABLE sgrr.lrs_node DROP CONSTRAINT IF EXISTS lado_fk CASCADE;
ALTER TABLE sgrr.lrs_node ADD CONSTRAINT lado_fk FOREIGN KEY (id_lado)
REFERENCES sgrr.lado (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;
-- ddl-end --

-- object: tipo_node_fk | type: CONSTRAINT --
-- ALTER TABLE sgrr.lrs_node DROP CONSTRAINT IF EXISTS tipo_node_fk CASCADE;
ALTER TABLE sgrr.lrs_node ADD CONSTRAINT tipo_node_fk FOREIGN KEY (id_tipo_node)
REFERENCES sgrr.tipo_node (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;
-- ddl-end --

-- object: estradas_fk | type: CONSTRAINT --
-- ALTER TABLE sgrr.patologias DROP CONSTRAINT IF EXISTS estradas_fk CASCADE;
ALTER TABLE sgrr.patologias ADD CONSTRAINT estradas_fk FOREIGN KEY (id_estradas)
REFERENCES sgrr.estradas (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;
-- ddl-end --

-- object: tipo_patologias_fk | type: CONSTRAINT --
-- ALTER TABLE sgrr.patologias DROP CONSTRAINT IF EXISTS tipo_patologias_fk CASCADE;
ALTER TABLE sgrr.patologias ADD CONSTRAINT tipo_patologias_fk FOREIGN KEY (id_tipo_patologias)
REFERENCES sgrr.tipo_patologias (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;
-- ddl-end --

-- object: estado_fk | type: CONSTRAINT --
-- ALTER TABLE sgrr.rails DROP CONSTRAINT IF EXISTS estado_fk CASCADE;
ALTER TABLE sgrr.rails ADD CONSTRAINT estado_fk FOREIGN KEY (id_estado)
REFERENCES sgrr.estado (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;
-- ddl-end --

-- object: estradas_fk | type: CONSTRAINT --
-- ALTER TABLE sgrr.rails DROP CONSTRAINT IF EXISTS estradas_fk CASCADE;
ALTER TABLE sgrr.rails ADD CONSTRAINT estradas_fk FOREIGN KEY (id_estradas)
REFERENCES sgrr.estradas (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;
-- ddl-end --

-- object: lado_fk | type: CONSTRAINT --
-- ALTER TABLE sgrr.rails DROP CONSTRAINT IF EXISTS lado_fk CASCADE;
ALTER TABLE sgrr.rails ADD CONSTRAINT lado_fk FOREIGN KEY (id_lado)
REFERENCES sgrr.lado (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;
-- ddl-end --

-- object: estradas_fk | type: CONSTRAINT --
-- ALTER TABLE sgrr.trocos DROP CONSTRAINT IF EXISTS estradas_fk CASCADE;
ALTER TABLE sgrr.trocos ADD CONSTRAINT estradas_fk FOREIGN KEY (id_estradas)
REFERENCES sgrr.estradas (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;
-- ddl-end --

-- object: tipo_pavimento_fk | type: CONSTRAINT --
-- ALTER TABLE sgrr.trocos DROP CONSTRAINT IF EXISTS tipo_pavimento_fk CASCADE;
ALTER TABLE sgrr.trocos ADD CONSTRAINT tipo_pavimento_fk FOREIGN KEY (id_tipo_pavimento)
REFERENCES sgrr.tipo_pavimento (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;
-- ddl-end --

-- object: estado_fk | type: CONSTRAINT --
-- ALTER TABLE sgrr.valetas DROP CONSTRAINT IF EXISTS estado_fk CASCADE;
ALTER TABLE sgrr.valetas ADD CONSTRAINT estado_fk FOREIGN KEY (id_estado)
REFERENCES sgrr.estado (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;
-- ddl-end --

-- object: estradas_fk | type: CONSTRAINT --
-- ALTER TABLE sgrr.valetas DROP CONSTRAINT IF EXISTS estradas_fk CASCADE;
ALTER TABLE sgrr.valetas ADD CONSTRAINT estradas_fk FOREIGN KEY (id_estradas)
REFERENCES sgrr.estradas (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;
-- ddl-end --

-- object: lado_fk | type: CONSTRAINT --
-- ALTER TABLE sgrr.valetas DROP CONSTRAINT IF EXISTS lado_fk CASCADE;
ALTER TABLE sgrr.valetas ADD CONSTRAINT lado_fk FOREIGN KEY (id_lado)
REFERENCES sgrr.lado (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;
-- ddl-end --

-- object: tipo_valeta_fk | type: CONSTRAINT --
-- ALTER TABLE sgrr.valetas DROP CONSTRAINT IF EXISTS tipo_valeta_fk CASCADE;
ALTER TABLE sgrr.valetas ADD CONSTRAINT tipo_valeta_fk FOREIGN KEY (id_tipo_valeta)
REFERENCES sgrr.tipo_valeta (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;
-- ddl-end --
