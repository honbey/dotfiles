CREATE USER convex WITH PASSWORD '';

CREATE DATABASE convex_self_hosted
    ENCODING 'UTF8'
    LC_COLLATE = 'C'
    LC_CTYPE = 'C'
    TEMPLATE = template0
    OWNER = convex;

GRANT ALL PRIVILEGES ON DATABASE convex_self_hosted TO convex;
