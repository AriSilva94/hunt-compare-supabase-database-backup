


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE OR REPLACE FUNCTION "public"."get_weapon_details_by_id"("weapon_id" integer) RETURNS TABLE("id" integer, "name" "text", "slug" "text", "weapon" "text", "url" "text", "image" "text", "description_raw" "text", "vocation" "text", "imbuement_slots" integer, "classification" integer, "max_tier" integer, "weight" "text", "proficiencies" json)
    LANGUAGE "sql"
    AS $$
SELECT
  wi.id,
  wi.name,
  wi.slug,
  wi.weapon,
  wi.url,
  wi.image,
  wi.description_raw,
  wi.vocation,
  wi.imbuement_slots,
  wi.classification,
  wi.max_tier,
  wi.weight,
  JSON_AGG(
    JSON_BUILD_OBJECT(
      'level', wp.level,
      'description', wp.description,
      'icons', wp.icons
    )
    ORDER BY wp.level
  ) FILTER (WHERE wp.level IS NOT NULL) AS proficiencies
FROM weapon_items wi
LEFT JOIN weapon_proficiencies wp ON wi.id = wp.item_id
WHERE wi.id = weapon_id
GROUP BY wi.id;
$$;


ALTER FUNCTION "public"."get_weapon_details_by_id"("weapon_id" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_updated_at_column"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_updated_at_column"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."characters" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "name" character varying(100) NOT NULL,
    "level" integer DEFAULT 1,
    "vocation" character varying(50),
    "world" character varying(50),
    "avatar_url" "text",
    "is_active" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "sex" character varying(10)
);


ALTER TABLE "public"."characters" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."missing_images" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "image_name" character varying(255) NOT NULL,
    "image_url" "text" NOT NULL,
    "monster_name" character varying(255) NOT NULL,
    "first_detected_at" timestamp with time zone DEFAULT "now"(),
    "last_detected_at" timestamp with time zone DEFAULT "now"(),
    "detection_count" integer DEFAULT 1,
    "is_resolved" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."missing_images" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."records" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "data" "jsonb" NOT NULL,
    "is_public" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "character_id" "uuid",
    "has_bestiary" boolean DEFAULT false
);


ALTER TABLE "public"."records" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."weapon_items" (
    "id" bigint NOT NULL,
    "weapon" "text" NOT NULL,
    "name" "text" NOT NULL,
    "slug" "text" NOT NULL,
    "image" "text",
    "url" "text",
    "description_raw" "text",
    "attack" integer,
    "defense" integer,
    "skill_boost" "text",
    "vocation" "text",
    "level_requirement" integer,
    "imbuement_slots" integer,
    "classification" integer,
    "max_tier" integer,
    "weight" "text"
);


ALTER TABLE "public"."weapon_items" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."weapon_items_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."weapon_items_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."weapon_items_id_seq" OWNED BY "public"."weapon_items"."id";



CREATE TABLE IF NOT EXISTS "public"."weapon_proficiencies" (
    "id" bigint NOT NULL,
    "item_id" bigint,
    "level" integer NOT NULL,
    "description" "text" NOT NULL,
    "icons" "jsonb"
);


ALTER TABLE "public"."weapon_proficiencies" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."weapon_proficiencies_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."weapon_proficiencies_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."weapon_proficiencies_id_seq" OWNED BY "public"."weapon_proficiencies"."id";



ALTER TABLE ONLY "public"."weapon_items" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."weapon_items_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."weapon_proficiencies" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."weapon_proficiencies_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."characters"
    ADD CONSTRAINT "characters_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."missing_images"
    ADD CONSTRAINT "missing_images_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."records"
    ADD CONSTRAINT "records_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."weapon_items"
    ADD CONSTRAINT "weapon_items_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."weapon_proficiencies"
    ADD CONSTRAINT "weapon_proficiencies_pkey" PRIMARY KEY ("id");



CREATE INDEX "idx_characters_is_active" ON "public"."characters" USING "btree" ("is_active");



CREATE INDEX "idx_characters_user_id" ON "public"."characters" USING "btree" ("user_id");



CREATE INDEX "idx_missing_images_image_name" ON "public"."missing_images" USING "btree" ("image_name");



CREATE INDEX "idx_missing_images_is_resolved" ON "public"."missing_images" USING "btree" ("is_resolved");



CREATE INDEX "idx_missing_images_last_detected" ON "public"."missing_images" USING "btree" ("last_detected_at");



CREATE INDEX "idx_missing_images_monster_name" ON "public"."missing_images" USING "btree" ("monster_name");



CREATE INDEX "idx_records_character_id" ON "public"."records" USING "btree" ("character_id");



CREATE INDEX "idx_records_created_at" ON "public"."records" USING "btree" ("created_at" DESC);



CREATE INDEX "idx_records_has_bestiary" ON "public"."records" USING "btree" ("has_bestiary");



CREATE INDEX "idx_records_is_public" ON "public"."records" USING "btree" ("is_public");



CREATE INDEX "idx_records_user_id" ON "public"."records" USING "btree" ("user_id");



CREATE OR REPLACE TRIGGER "update_characters_updated_at" BEFORE UPDATE ON "public"."characters" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_missing_images_updated_at" BEFORE UPDATE ON "public"."missing_images" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_records_updated_at" BEFORE UPDATE ON "public"."records" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



ALTER TABLE ONLY "public"."characters"
    ADD CONSTRAINT "characters_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."records"
    ADD CONSTRAINT "records_character_id_fkey" FOREIGN KEY ("character_id") REFERENCES "public"."characters"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."records"
    ADD CONSTRAINT "records_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."weapon_proficiencies"
    ADD CONSTRAINT "weapon_proficiencies_item_id_fkey" FOREIGN KEY ("item_id") REFERENCES "public"."weapon_items"("id") ON DELETE CASCADE;



CREATE POLICY "All users can view weapon items" ON "public"."weapon_items" FOR SELECT TO "authenticated", "anon" USING (true);



CREATE POLICY "Allow all to insert missing images" ON "public"."missing_images" FOR INSERT WITH CHECK (true);



CREATE POLICY "Allow all to update missing images" ON "public"."missing_images" FOR UPDATE USING (true);



CREATE POLICY "Allow all to view missing images" ON "public"."missing_images" FOR SELECT USING (true);



CREATE POLICY "Allow all users to view weapon proficiencies" ON "public"."weapon_proficiencies" FOR SELECT TO "authenticated", "anon" USING (true);



CREATE POLICY "Characters of public records are viewable by everyone" ON "public"."characters" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."records"
  WHERE (("records"."character_id" = "characters"."id") AND ("records"."is_public" = true)))));



CREATE POLICY "Public records are viewable by everyone" ON "public"."records" FOR SELECT USING (("is_public" = true));



CREATE POLICY "Users can create own characters" ON "public"."characters" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can create own records" ON "public"."records" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can delete own characters" ON "public"."characters" FOR DELETE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can delete own records" ON "public"."records" FOR DELETE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can update own characters" ON "public"."characters" FOR UPDATE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can update own records" ON "public"."records" FOR UPDATE USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can view own characters" ON "public"."characters" FOR SELECT USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can view own records" ON "public"."records" FOR SELECT USING (("auth"."uid"() = "user_id"));



ALTER TABLE "public"."characters" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."missing_images" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."records" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."weapon_items" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."weapon_proficiencies" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";

























































































































































GRANT ALL ON FUNCTION "public"."get_weapon_details_by_id"("weapon_id" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."get_weapon_details_by_id"("weapon_id" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_weapon_details_by_id"("weapon_id" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "service_role";


















GRANT ALL ON TABLE "public"."characters" TO "anon";
GRANT ALL ON TABLE "public"."characters" TO "authenticated";
GRANT ALL ON TABLE "public"."characters" TO "service_role";



GRANT ALL ON TABLE "public"."missing_images" TO "anon";
GRANT ALL ON TABLE "public"."missing_images" TO "authenticated";
GRANT ALL ON TABLE "public"."missing_images" TO "service_role";



GRANT ALL ON TABLE "public"."records" TO "anon";
GRANT ALL ON TABLE "public"."records" TO "authenticated";
GRANT ALL ON TABLE "public"."records" TO "service_role";



GRANT ALL ON TABLE "public"."weapon_items" TO "anon";
GRANT ALL ON TABLE "public"."weapon_items" TO "authenticated";
GRANT ALL ON TABLE "public"."weapon_items" TO "service_role";



GRANT ALL ON SEQUENCE "public"."weapon_items_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."weapon_items_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."weapon_items_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."weapon_proficiencies" TO "anon";
GRANT ALL ON TABLE "public"."weapon_proficiencies" TO "authenticated";
GRANT ALL ON TABLE "public"."weapon_proficiencies" TO "service_role";



GRANT ALL ON SEQUENCE "public"."weapon_proficiencies_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."weapon_proficiencies_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."weapon_proficiencies_id_seq" TO "service_role";









ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";































